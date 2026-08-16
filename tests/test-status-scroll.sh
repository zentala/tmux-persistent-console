#!/bin/bash
# Scroll regression test for the native status line.
# v0.2 uses tmux's native status-format line, which by construction stays
# pinned below the pane — it cannot scroll with content. What CAN regress is
# someone reintroducing the legacy in-pane status bar (a script printing the
# F1..F10 bar into pane content, the pre-v0.2 architecture). So this test
# floods a pane with output and asserts:
#   1. the native status line config survives (still on, still bottom,
#      still renders the F-keys), and
#   2. the bar text does NOT appear inside captured pane content — if it
#      does, the legacy in-pane bar is back and WILL scroll with output.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$TMUX" ]; then
    echo -e "${RED}❌ Must run inside tmux session${NC}"
    exit 1
fi

CURRENT_SESSION=$(tmux display-message -p '#S')

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📜 Status Bar Scroll Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_scroll_behavior() {
    local session_name="$1"
    local errors=0

    echo -e "${CYAN}Testing session: $session_name${NC}"

    echo "   Step 1: Generating output to trigger scroll..."
    for i in {1..50}; do
        tmux send-keys -t "$session_name" \
            "echo 'Line $i - scroll test filler'" Enter
    done
    sleep 0.5

    echo "   Step 2: Native status line still configured after scroll..."
    local status_on=$(tmux show-options -gqv status)
    local position=$(tmux show-options -gqv status-position)
    local rendered=$(tmux display-message -p -t "$session_name" '#{T:status-format[0]}')

    if { [ "$status_on" != "on" ] && [ "$status_on" != "2" ]; } \
        || [ "$position" != "bottom" ]; then
        echo -e "   ${RED}❌ FAIL: status='$status_on' position='$position' after scroll${NC}"
        errors=$((errors + 1))
    elif ! echo "$rendered" | grep -q "F1" || ! echo "$rendered" | grep -q "F10"; then
        echo -e "   ${RED}❌ FAIL: rendered status line lost its F-key indicators${NC}"
        errors=$((errors + 1))
    else
        echo -e "   ${GREEN}✅ Status line intact (native, pinned by tmux)${NC}"
    fi

    echo "   Step 3: No legacy in-pane status bar..."
    # grep -c exits 1 on zero matches; || true keeps set -e quiet.
    local in_pane_bars=$(tmux capture-pane -t "$session_name" -p \
        | grep -c "F1.*F2.*F10" || true)
    if [ "$in_pane_bars" -ne 0 ]; then
        echo -e "   ${RED}❌ FAIL: found $in_pane_bars status-bar line(s) inside pane content${NC}"
        echo -e "   ${YELLOW}The legacy in-pane bar is back — it scrolls with output.${NC}"
        errors=$((errors + 1))
    else
        echo -e "   ${GREEN}✅ Pane content is free of injected status bars${NC}"
    fi

    tmux send-keys -t "$session_name" "clear" Enter
    sleep 0.2

    echo ""
    return $errors
}

total_errors=0

for session in console-1 console-2; do
    if ! tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  $session doesn't exist, creating...${NC}"
        tmux new-session -d -s "$session"
        sleep 0.3
    fi
    result=0
    test_scroll_behavior "$session" || result=$?
    total_errors=$((total_errors + result))
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$total_errors" -eq 0 ]; then
    echo -e "${GREEN}✅ Status line survives scroll; no in-pane bar regression${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $total_errors error(s)${NC}"
    exit 1
fi
