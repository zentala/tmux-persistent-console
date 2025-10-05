#!/bin/bash
# Test script for safe-exit wrapper

echo "======================================"
echo "  SAFE EXIT WRAPPER TEST"
echo "======================================"
echo ""

echo "✅ Running test on: $(hostname)"
echo ""

# Check if safe-exit.sh exists
if [ ! -f ~/.tmux-persistent-console/safe-exit.sh ]; then
    echo "❌ safe-exit.sh not found!"
    echo "   Expected: ~/.tmux-persistent-console/safe-exit.sh"
    exit 1
fi

echo "✅ safe-exit.sh found"
echo ""

# Check if it's sourced in bashrc
if grep -q "safe-exit.sh" ~/.bashrc; then
    echo "✅ safe-exit.sh is sourced in ~/.bashrc"
else
    echo "❌ safe-exit.sh is NOT sourced in ~/.bashrc"
    echo "   Add: [ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh"
    exit 1
fi

echo ""
echo "======================================"
echo "  INTERACTIVE TEST INSTRUCTIONS"
echo "======================================"
echo ""
echo "To test the safe-exit wrapper:"
echo ""
echo "1. Connect to a tmux session:"
echo "   ssh zentala@164.68.104.13 -t \"tmux attach -t console-1\""
echo ""
echo "2. Type: exit"
echo ""
echo "3. You should see the warning menu:"
echo "   ⚠️  WARNING: You are in a tmux session!"
echo ""
echo "4. Test each option:"
echo "   - Press [Enter] → Should detach safely"
echo "   - Reconnect, type 'exit', press [d] → Should detach safely"
echo "   - Reconnect, type 'exit', press [n] → Should cancel and stay"
echo "   - Reconnect, type 'exit', press [y] → Should KILL session"
echo ""
echo "5. Recreate killed session:"
echo "   ssh zentala@164.68.104.13 \"tmux new-session -d -s console-1\""
echo ""
echo "======================================"
echo "  AUTOMATED CHECKS - PASSED ✅"
echo "======================================"
echo ""
