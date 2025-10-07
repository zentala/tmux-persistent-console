#!/bin/bash
# Test to detect status bar flickering
# PASS if status bar stays STABLE (no unwanted changes)
# FAIL if status bar changes frequently (indicates refresh loop)

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

DURATION="${1:-30}"  # Test duration in seconds (default 30)

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔬 Status Bar Flicker Detection Test${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "This test monitors status bar for $DURATION seconds."
echo "Looking for unwanted changes that indicate flickering/refresh loop."
echo ""

# Create temp file for logging
TEMP_LOG=$(mktemp /tmp/flicker-test-XXXXXX.log)
trap "rm -f '$TEMP_LOG'" EXIT

echo -e "${YELLOW}⏱️  Monitoring status bar...${NC}"
echo "   Capturing 1 snapshot per second for $DURATION seconds..."
echo ""

# Capture status bar every second
for i in $(seq 1 $DURATION); do
    # Get last line (where status bar should be)
    capture=$(tmux capture-pane -p | tail -1)
    echo "$capture" >> "$TEMP_LOG"

    # Show progress
    if [ $((i % 5)) -eq 0 ]; then
        echo -e "${CYAN}   [$i/$DURATION] Still monitoring...${NC}"
    fi

    sleep 1
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Analysis Results${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Count unique variants
unique_count=$(sort "$TEMP_LOG" | uniq | wc -l)
total_samples=$DURATION

echo "   Total samples: $total_samples"
echo "   Unique variants: $unique_count"
echo ""

# Calculate change percentage
change_pct=$((unique_count * 100 / total_samples))

# Analyze results
if [ "$unique_count" -eq 1 ]; then
    echo -e "${GREEN}✅ PERFECT: Status bar completely stable${NC}"
    echo "   No changes detected during entire $DURATION second test."
    echo "   This is the ideal behavior - no flickering!"
    echo ""
    exit 0

elif [ "$unique_count" -le 3 ]; then
    echo -e "${GREEN}✅ PASS: Status bar mostly stable${NC}"
    echo "   Only $unique_count variant(s) detected ($change_pct% change rate)."
    echo "   This is acceptable - minor changes may be due to dynamic content."
    echo ""

    echo -e "${CYAN}Variants found:${NC}"
    sort "$TEMP_LOG" | uniq -c | sort -rn
    echo ""
    exit 0

elif [ "$unique_count" -le 10 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Status bar moderately unstable${NC}"
    echo "   Found $unique_count variants ($change_pct% change rate)."
    echo "   This suggests some refresh activity."
    echo ""

    echo -e "${YELLOW}Most common variants:${NC}"
    sort "$TEMP_LOG" | uniq -c | sort -rn | head -5
    echo ""

    echo -e "${YELLOW}Possible causes:${NC}"
    echo "   • status-interval set to low value (check: tmux show-options -g status-interval)"
    echo "   • Dynamic content updating frequently"
    echo "   • External script being called repeatedly"
    echo ""
    exit 1

else
    echo -e "${RED}❌ FAIL: Status bar is FLICKERING!${NC}"
    echo "   Found $unique_count variants in $total_samples samples ($change_pct% change rate)."
    echo "   This is a SEVERE problem - status bar is constantly changing."
    echo ""

    echo -e "${RED}First variant (time 0s):${NC}"
    head -1 "$TEMP_LOG"
    echo ""

    echo -e "${RED}Last variant (time ${DURATION}s):${NC}"
    tail -1 "$TEMP_LOG"
    echo ""

    echo -e "${RED}Change frequency:${NC}"
    sort "$TEMP_LOG" | uniq -c | sort -rn | head -10
    echo ""

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🔧 Debugging Steps:${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "1. Check status refresh interval:"
    echo "   tmux show-options -g status-interval"
    echo "   → Should be 0 (disabled) or high value (60+)"
    echo ""
    echo "2. Check if external script is being called:"
    echo "   tmux show-options -g status-left"
    echo "   → Look for '#(script)' pattern"
    echo ""
    echo "3. Check status-format for dynamic elements:"
    echo "   tmux show-options -g status-format"
    echo "   → Too many #{} variables = frequent updates"
    echo ""
    echo "4. Review PLAN-FIX-FLICKERING.md for solution:"
    echo "   cat ~/.vps/sessions/PLAN-FIX-FLICKERING.md"
    echo ""

    exit 1
fi
