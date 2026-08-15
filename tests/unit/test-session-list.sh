#!/bin/bash
# Unit tests for src/lib/session-list.sh — pure bash asserts, no framework.
# Must run WITHOUT a real tmux server: tmux is stubbed as a shell function.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../../src/lib/session-list.sh
source "$ROOT_DIR/src/lib/session-list.sh"

FAILURES=0
CHECKS=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    CHECKS=$((CHECKS + 1))
    if [ "$expected" != "$actual" ]; then
        echo "FAIL: $desc — expected '$expected', got '$actual'"
        FAILURES=$((FAILURES + 1))
    fi
}

assert_status() {
    local desc="$1" expected="$2" actual="$3"
    CHECKS=$((CHECKS + 1))
    if [ "$expected" -ne "$actual" ]; then
        echo "FAIL: $desc — expected status $expected, got $actual"
        FAILURES=$((FAILURES + 1))
    fi
}

# --- parse_session_from_line ---------------------------------------------

# Regression: non-current session line, marker is the non-whitespace "·".
# This is the shipped awk field-shift bug — a leading space on the marker
# column used to collapse and shift every field left by one.
line_other="· ○ console-3       [F3] │ (empty)"
result=$(parse_session_from_line "$line_other")
assert_eq "non-current session parses to console-N" "console-3" "$result"

# Current session, marker is "→".
line_current="→ ● console-1       [F1] │ vim"
result=$(parse_session_from_line "$line_current")
assert_eq "current session parses to console-N" "console-1" "$result"

# help session.
line_help="· ○ help            [   ] │ (empty)"
result=$(parse_session_from_line "$line_help")
assert_eq "help session parses to help" "help" "$result"

# --- restart_session guard (from T02, mission-control.sh) ----------------

# Stub tmux to record every call it receives; unit test asserts kill-session
# was never invoked for the guarded special sessions.
TMUX_CALL_LOG="$(mktemp)"
tmux() {
    echo "$*" >> "$TMUX_CALL_LOG"
    return 0
}
export -f tmux

# shellcheck source=../../src/mission-control.sh
# mission-control.sh runs show_mission_control at the bottom on source, which
# would block on fzf — pull out just restart_session() via a filtered source.
RESTART_SESSION_SRC=$(sed -n '/^restart_session()/,/^}/p' "$ROOT_DIR/src/mission-control.sh")
eval "$RESTART_SESSION_SRC"

: > "$TMUX_CALL_LOG"
restart_session "help" >/dev/null 2>&1
status=$?
assert_status "restart_session help returns non-zero" 1 "$status"
if grep -q "kill-session" "$TMUX_CALL_LOG"; then
    echo "FAIL: restart_session help must not call kill-session"
    FAILURES=$((FAILURES + 1))
fi
CHECKS=$((CHECKS + 1))

: > "$TMUX_CALL_LOG"
restart_session "manager" >/dev/null 2>&1
status=$?
assert_status "restart_session manager returns non-zero" 1 "$status"
if grep -q "kill-session" "$TMUX_CALL_LOG"; then
    echo "FAIL: restart_session manager must not call kill-session"
    FAILURES=$((FAILURES + 1))
fi
CHECKS=$((CHECKS + 1))

rm -f "$TMUX_CALL_LOG"

# --- summary ---------------------------------------------------------------

if [ "$FAILURES" -gt 0 ]; then
    echo "FAIL: $FAILURES/$CHECKS checks failed"
    exit 1
fi

echo "PASS: $CHECKS/$CHECKS checks passed"
exit 0
