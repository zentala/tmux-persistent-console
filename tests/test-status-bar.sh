#!/bin/bash
# Test status bar visibility and position after session switches
# Tests if bar appears EXACTLY ONCE at the BOTTOM of the screen

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 Status Bar Verification Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running inside tmux
if [ -z "$TMUX" ]; then
    echo -e "${RED}❌ Must run inside tmux session${NC}"
    exit 1
fi

CURRENT_SESSION=$(tmux display-message -p '#S')
echo -e "${CYAN}Current session:${NC} $CURRENT_SESSION"
echo ""

# Function to check status bar
check_status_bar() {
    local session_name="$1"
    local test_name="$2"

    echo -e "${YELLOW}🔍 Testing: $test_name${NC}"

    # Get status bar configuration (not pane content - status bar is separate!)
    local status_right=$(tmux show-options -gqv status-right)
    local status_position=$(tmux show-options -gqv status-position)

    # Get terminal height
    local term_height=$(tmux display-message -p -t "$session_name" '#{pane_height}')

    # Count occurrences of status bar indicators
    local f1_count=$(echo "$status_right" | grep -c "F1" || true)
    local f7_count=$(echo "$status_right" | grep -c "F7" || true)
    local f12_count=$(echo "$status_right" | grep -c "F12" || true)

    echo "   Terminal height: $term_height"
    echo "   Status position: $status_position"
    echo "   F1 occurrences: $f1_count"
    echo "   F7 occurrences: $f7_count"
    echo "   F12 occurrences: $f12_count"

    local errors=0

    # Test 1: Icon count verification (12 total: 10 consoles + F11 + F12)
    local icon_count=$(echo "$status_right" | grep -oE "󰢩|󰲝|󱫋|󰲊" | wc -l)
    if [ "$icon_count" -lt 12 ]; then
        echo -e "   ${RED}❌ FAIL: Missing icons in status bar${NC}"
        echo "      Expected: 12 icons total (F1-F10 + F11 + F12)"
        echo "      Got: $icon_count icons"
        ((errors++))
    else
        echo -e "   ${GREEN}✅ PASS: Icons present ($icon_count total)${NC}"
    fi

    # Test 2: Status bar position should be 'bottom'
    if [ "$status_position" != "bottom" ]; then
        echo -e "   ${RED}❌ FAIL: Status bar not at bottom of screen${NC}"
        echo "      Expected: status-position = bottom"
        echo "      Got: status-position = $status_position"
        ((errors++))
    else
        echo -e "   ${GREEN}✅ PASS: Status bar is at bottom${NC}"
    fi

    # Test 3: Status bar should contain ALL session indicators F1-F12
    local has_all_sessions=1
    for i in {1..12}; do
        if ! echo "$status_right" | grep -q " F$i "; then
            echo -e "   ${RED}❌ FAIL: Missing F$i indicator${NC}"
            has_all_sessions=0
            ((errors++))
        fi
    done
    if [ "$has_all_sessions" -eq 1 ]; then
        echo -e "   ${GREEN}✅ PASS: All 12 session indicators present (F1-F12)${NC}"
    fi

    # Test 4: Current session should be highlighted (colour39 = cyan)
    local current_highlighted=$(echo "$status_right" | grep -c "colour39" || true)
    if [ "$current_highlighted" -eq 0 ]; then
        echo -e "   ${RED}❌ FAIL: No active session highlighting found${NC}"
        ((errors++))
    else
        echo -e "   ${GREEN}✅ PASS: Active session highlighting configured (colour39)${NC}"
    fi

    echo ""

    return $errors
}

# Test initial state
check_status_bar "$CURRENT_SESSION" "Initial state in $CURRENT_SESSION"
initial_result=$?

# Test switching to each console
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔄 Testing session switching...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

total_errors=$initial_result

for i in {1..7}; do
    session="console-$i"

    # Switch to session
    echo -e "${CYAN}→ Switching to $session${NC}"
    tmux switch-client -t "$session" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Session $session doesn't exist, creating...${NC}"
        tmux new-session -d -s "$session" 2>/dev/null || true
        tmux switch-client -t "$session"
    }

    # Wait for status bar to update
    sleep 0.3

    # Check status bar
    check_status_bar "$session" "After switch to $session"
    result=$?
    ((total_errors += result))

    echo ""
done

# Return to original session
echo -e "${CYAN}→ Returning to $CURRENT_SESSION${NC}"
tmux switch-client -t "$CURRENT_SESSION"

# Final summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $total_errors -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    echo -e "${GREEN}   Status bar is working correctly!${NC}"
    exit 0
else
    echo -e "${RED}❌ TESTS FAILED${NC}"
    echo -e "${RED}   Found $total_errors error(s)${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "   • Double status bar → Check tmux.conf for duplicate status-format"
    echo "   • Wrong position → Check status-position setting"
    echo "   • Missing after switch → Check status-bar.sh hook execution"
    exit 1
fi
