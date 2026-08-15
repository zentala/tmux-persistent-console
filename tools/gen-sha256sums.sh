#!/bin/bash
# Regenerates SHA256SUMS at the repo root from the exact file list that
# install.sh's remote download loop fetches. Run after any change to one of
# those files, then paste the printed manifest hash into MANIFEST_SHA256 in
# install.sh.
#
# Usage:
#   tools/gen-sha256sums.sh          # rewrite SHA256SUMS, print its own sha256
#   tools/gen-sha256sums.sh --check  # exit non-zero if SHA256SUMS or
#                                     # install.sh's MANIFEST_SHA256 are stale

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUMS_FILE="$ROOT_DIR/SHA256SUMS"
INSTALL_SH="$ROOT_DIR/install.sh"

# Must match the files downloaded by install.sh's remote (else) branch.
FILES=(
    src/setup.sh
    src/connect.sh
    src/tmux.conf
    src/tmux-console.service
    src/uninstall.sh
    src/safe-exit.sh
    src/console-help.sh
    src/help-reference.sh
    src/status-format-v4.tmux
    src/theme-config.sh
    src/mission-control.sh
    src/shortcuts-popup.sh
    src/click-session.sh
    src/restart-confirm.sh
    src/restart-session.sh
    src/tui/tui-core.sh
    src/tui/tui-menu.sh
    src/tui/tui-dialogs.sh
    src/tui/tui-list.sh
    src/tui/tui-status.sh
    src/lib/session-list.sh
    scripts/doctor.sh
)

generate() {
    local out="$1"
    (
        cd "$ROOT_DIR"
        for f in "${FILES[@]}"; do
            sha256sum --text "$f"
        done
    ) > "$out"
}

manifest_sha256() {
    sha256sum "$1" | awk '{print $1}'
}

if [ "${1:-}" = "--check" ]; then
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT
    generate "$tmp"

    if ! diff -q "$tmp" "$SUMS_FILE" >/dev/null 2>&1; then
        echo "STALE: committed SHA256SUMS does not match the source tree" >&2
        diff "$SUMS_FILE" "$tmp" >&2 || true
        exit 1
    fi

    expected_manifest_hash="$(manifest_sha256 "$SUMS_FILE")"
    installed_hash="$(grep -o 'MANIFEST_SHA256="[0-9a-f]*"' "$INSTALL_SH" | cut -d'"' -f2)"
    if [ "$expected_manifest_hash" != "$installed_hash" ]; then
        echo "STALE: install.sh MANIFEST_SHA256 ($installed_hash) != SHA256SUMS hash ($expected_manifest_hash)" >&2
        exit 1
    fi

    echo "OK: SHA256SUMS and install.sh MANIFEST_SHA256 are up to date"
    exit 0
fi

generate "$SUMS_FILE"
echo "Wrote $SUMS_FILE"
echo "MANIFEST_SHA256=\"$(manifest_sha256 "$SUMS_FILE")\""
