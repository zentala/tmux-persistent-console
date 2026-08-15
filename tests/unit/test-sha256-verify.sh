#!/bin/bash
# Unit tests for install.sh's verify_sha256() helper — pure bash asserts, no
# framework, no network. Extracts the function straight out of install.sh so
# the test always exercises the real implementation, not a copy of it.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

FAILURES=0
CHECKS=0

# verify_sha256() references install.sh's color vars; under `set -u` an
# unbound reference aborts the script, so stub them out here.
RED=""
NC=""

assert_status() {
    local desc="$1" expected="$2" actual="$3"
    CHECKS=$((CHECKS + 1))
    if [ "$expected" -ne "$actual" ]; then
        echo "FAIL: $desc — expected status $expected, got $actual"
        FAILURES=$((FAILURES + 1))
    fi
}

# verify_sha256() lives inline in install.sh's remote-download branch (no
# function library to source), so pull it out the same way test-session-list.sh
# pulls restart_session() out of mission-control.sh.
VERIFY_SHA256_SRC=$(sed -n '/^    verify_sha256() {/,/^    }/p' "$ROOT_DIR/install.sh" | sed 's/^    //')
eval "$VERIFY_SHA256_SRC"

WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

MANIFEST="$WORKDIR/SHA256SUMS"
FILE="$WORKDIR/src/setup.sh"
mkdir -p "$WORKDIR/src"
printf 'echo hello\n' > "$FILE"
sha256sum --text "$FILE" | sed "s#$FILE#src/setup.sh#" > "$MANIFEST"

# --- happy path: matching hash passes -------------------------------------

verify_sha256 "$FILE" "src/setup.sh" "$MANIFEST" >/dev/null 2>&1
status=$?
assert_status "matching sha256 passes" 0 "$status"

# --- tamper path: flipped content fails -----------------------------------

printf 'echo hello world\n' > "$FILE"
verify_sha256 "$FILE" "src/setup.sh" "$MANIFEST" >/dev/null 2>&1
status=$?
assert_status "tampered file fails verification" 1 "$status"

# --- missing manifest entry fails -----------------------------------------

verify_sha256 "$FILE" "src/does-not-exist.sh" "$MANIFEST" >/dev/null 2>&1
status=$?
assert_status "missing manifest entry fails" 1 "$status"

# --- summary ---------------------------------------------------------------

if [ "$FAILURES" -gt 0 ]; then
    echo "FAIL: $FAILURES/$CHECKS checks failed"
    exit 1
fi

echo "PASS: $CHECKS/$CHECKS checks passed"
exit 0
