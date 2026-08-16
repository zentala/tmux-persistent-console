#!/bin/bash
# One-command pTTY release. Bumps the version baked into install.sh,
# regenerates the SHA256SUMS manifest and its pinned hash, commits, tags,
# pushes, and verifies the new tag actually serves the manifest.
#
# Usage:
#   scripts/release.sh 0.2.2            # do the release
#   scripts/release.sh 0.2.2 --dry-run  # print the plan, change nothing
#
# Never edit PTTY_VERSION, MANIFEST_SHA256, SHA256SUMS, or tags by hand —
# this script is the only supported way to cut a release (CLAUDE.md
# "Release Process").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-}"
DRY_RUN=0
[ "${2:-}" = "--dry-run" ] && DRY_RUN=1

die() { echo "release: $*" >&2; exit 1; }

[ -n "$VERSION" ] || die "usage: scripts/release.sh <version> [--dry-run]"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "version must be X.Y.Z, got '$VERSION'"
TAG="v$VERSION"

# --- preflight -------------------------------------------------------------

[ -z "$(git status --porcelain)" ] || die "working tree not clean — commit or stash first"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[ "$BRANCH" = "main" ] || die "releases are cut from main (on '$BRANCH')"

git fetch -q origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] \
    || die "local main differs from origin/main — pull/push first"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null \
    || git ls-remote --tags origin "refs/tags/$TAG" | grep -q .; then
    die "tag $TAG already exists — bump the version instead of re-pointing tags"
fi

grep -q "^## \[$VERSION\]\|^## \[Unreleased\]" CHANGELOG.md \
    || die "CHANGELOG.md needs a '## [Unreleased]' or '## [$VERSION]' section — write it first"

if command -v shellcheck >/dev/null 2>&1; then
    find install.sh src tools scripts -name "*.sh" -type f \
        -exec shellcheck -S error {} + || die "shellcheck failed"
else
    echo "release: shellcheck not found — skipping (CI still enforces it)"
fi
bash -n install.sh || die "install.sh has syntax errors"

# --- plan ------------------------------------------------------------------

echo "Release plan for $TAG:"
echo "  1. install.sh: PTTY_VERSION -> $VERSION"
echo "  2. src/mission-control.sh, src/help-reference.sh: VERSION -> $VERSION"
echo "  3. tools/gen-sha256sums.sh: regenerate SHA256SUMS"
echo "  4. install.sh: MANIFEST_SHA256 -> hash of new SHA256SUMS"
echo "  5. commit 'chore(release): $TAG', tag $TAG"
echo "  6. push main + tag to origin"
echo "  7. verify raw.githubusercontent.com serves SHA256SUMS at $TAG"

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run — nothing changed."
    exit 0
fi

# --- execute ---------------------------------------------------------------

sed -i "s/^PTTY_VERSION=\"[^\"]*\"/PTTY_VERSION=\"$VERSION\"/" install.sh
grep -q "^PTTY_VERSION=\"$VERSION\"" install.sh || die "failed to bump PTTY_VERSION"

# TUI scripts carry their own displayed version — bump every copy, then
# regenerate the manifest (these files are part of it).
for f in src/mission-control.sh src/help-reference.sh; do
    sed -i "s/^VERSION=\"[^\"]*\"/VERSION=\"$VERSION\"/" "$f"
    sed -i "s/pTTY v[0-9]\+\.[0-9]\+\.[0-9]\+/pTTY v$VERSION/" "$f"
done

# Stamp the Unreleased section as this version (keep-a-changelog flow).
if grep -q "^## \[Unreleased\]" CHANGELOG.md; then
    sed -i "s/^## \[Unreleased\].*/## [$VERSION] — $(date +%Y-%m-%d)/" CHANGELOG.md
fi

bash tools/gen-sha256sums.sh >/dev/null
MANIFEST_HASH="$(sha256sum SHA256SUMS | awk '{print $1}')"
sed -i "s/^MANIFEST_SHA256=\"[0-9a-f]*\"/MANIFEST_SHA256=\"$MANIFEST_HASH\"/" install.sh
bash tools/gen-sha256sums.sh --check || die "manifest self-check failed after regeneration"

git add install.sh SHA256SUMS CHANGELOG.md src/mission-control.sh src/help-reference.sh
git commit -m "chore(release): $TAG"
git tag -a "$TAG" -m "pTTY $TAG"

git push origin main
git push origin "$TAG"

# --- post-verify -----------------------------------------------------------
# raw.githubusercontent.com can lag a few seconds behind a fresh push.

RAW_URL="https://raw.githubusercontent.com/zentala/pTTY/$TAG/SHA256SUMS"
echo "Verifying $RAW_URL ..."
for i in $(seq 1 12); do
    REMOTE_HASH="$(curl -fsSL "$RAW_URL" 2>/dev/null | sha256sum | awk '{print $1}')" || REMOTE_HASH=""
    if [ "$REMOTE_HASH" = "$MANIFEST_HASH" ]; then
        echo "OK: $TAG serves SHA256SUMS and it matches the pinned hash."
        echo "Released $TAG."
        exit 0
    fi
    sleep 5
done

die "tag pushed but $RAW_URL does not serve the expected manifest — investigate before announcing"
