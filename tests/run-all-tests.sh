#!/bin/bash
# Run all status bar tests in sequence

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Status Bar Test Suite - Run All Tests                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ -z "$TMUX" ]; then
    echo -e "${RED}❌ Must run inside tmux session${NC}"
    echo "   Usage: tmux attach -t console-1"
    echo "          $0"
    exit 1
fi

total_failed=0

# Test 1: Full verification
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Test 1/3: Full Status Bar Verification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if "$TESTS_DIR/test-status-bar.sh"; then
    echo ""
    echo -e "${GREEN}✅ Test 1 PASSED${NC}"
else
    echo ""
    echo -e "${RED}❌ Test 1 FAILED${NC}"
    ((total_failed++))
fi

echo ""
echo -e "${YELLOW}Press Enter to continue to next test...${NC}"
read -r

# Test 2: Position verification
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Test 2/3: Precise Position Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if "$TESTS_DIR/test-status-position.sh"; then
    echo ""
    echo -e "${GREEN}✅ Test 2 PASSED${NC}"
else
    echo ""
    echo -e "${RED}❌ Test 2 FAILED${NC}"
    ((total_failed++))
fi

echo ""
echo -e "${YELLOW}Press Enter to continue to next test...${NC}"
read -r

# Test 3: Scroll behavior (CRITICAL)
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Test 3/3: Scroll Behavior Test (CRITICAL)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if "$TESTS_DIR/test-status-scroll.sh"; then
    echo ""
    echo -e "${GREEN}✅ Test 3 PASSED${NC}"
else
    echo ""
    echo -e "${RED}❌ Test 3 FAILED${NC}"
    ((total_failed++))
fi

# Final summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              FINAL TEST RESULTS                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $total_failed -eq 0 ]; then
    echo -e "${GREEN}✅✅✅ ALL 3 TESTS PASSED! ✅✅✅${NC}"
    echo ""
    echo "   Status bar is working perfectly:"
    echo "   • Appears exactly once ✅"
    echo "   • Always at bottom ✅"
    echo "   • Stays pinned when scrolling ✅"
    echo "   • Persists after switching ✅"
    echo ""
    echo -e "${GREEN}   Status bar implementation is PRODUCTION READY! 🎉${NC}"
    exit 0
else
    echo -e "${RED}❌ $total_failed TEST(S) FAILED ❌${NC}"
    echo ""
    echo "   Please review failed tests above."
    echo "   See STATUS-BAR-TESTS.md for troubleshooting."
    echo ""
    echo -e "${YELLOW}   Common fixes:${NC}"
    echo "   • Reload config: tmux source-file ~/.vps/sessions/src/tmux.conf"
    echo "   • Check status-format[1]: tmux show-options -g status-format"
    echo "   • Verify status on: tmux show-options -g status"
    exit 1
fi
