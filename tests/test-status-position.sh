#!/bin/bash
# Test the native tmux status line configuration per session.
# v0.2 renders the bar via status-format (native status line), so position
# and content are asserted through tmux options and format evaluation —
# capture-pane can never contain a native status line.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$TMUX" ]; then
    echo -e "${RED}❌ Must run inside tmux session${NC}"
    exit 1
fi

CURRENT_SESSION=$(tmux display-message -p '#S')

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📐 Status Line Position & Content Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

check_precise_position() {
    local session_name="$1"
    local errors=0

    echo -e "${CYAN}Testing session: $session_name${NC}"

    local status_on=$(tmux show-options -gqv status)
    if [ "$status_on" != "on" ] && [ "$status_on" != "2" ]; then
        echo -e "   ${RED}❌ FAIL: status is '$status_on', expected on${NC}"
        errors=$((errors + 1))
    else
        echo -e "   ${GREEN}✅ status line enabled${NC}"
    fi

    local position=$(tmux show-options -gqv status-position)
    if [ "$position" != "bottom" ]; then
        echo -e "   ${RED}❌ FAIL: status-position is '$position', expected bottom${NC}"
        errors=$((errors + 1))
    else
        echo -e "   ${GREEN}✅ status-position = bottom${NC}"
    fi

    # Evaluate the rendered status line in this session's context.
    local rendered=$(tmux display-message -p -t "$session_name" '#{T:status-format[0]}')
    if [ -z "$rendered" ]; then
        echo -e "   ${RED}❌ FAIL: status-format[0] renders empty${NC}"
        errors=$((errors + 1))
    else
        for key in F1 F10 F11 F12; do
            if ! echo "$rendered" | grep -q "$key"; then
                echo -e "   ${RED}❌ FAIL: rendered status line lacks $key${NC}"
                errors=$((errors + 1))
            fi
        done
        if [ "$errors" -eq 0 ]; then
            echo -e "   ${GREEN}✅ rendered status line contains F1/F10/F11/F12${NC}"
        fi
    fi

    echo ""
    return $errors
}

total_errors=0

result=0
check_precise_position "$CURRENT_SESSION" || result=$?
total_errors=$((total_errors + result))

for i in {1..10}; do
    session="console-$i"

    if ! tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Session $session doesn't exist, skipping${NC}"
        echo ""
        continue
    fi

    result=0
    check_precise_position "$session" || result=$?
    total_errors=$((total_errors + result))
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$total_errors" -eq 0 ]; then
    echo -e "${GREEN}✅ Status line position/content correct in every session${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $total_errors error(s)${NC}"
    exit 1
fi
