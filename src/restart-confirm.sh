#!/bin/bash
# Ctrl+R - Restart current console with confirmation
# Uses gum for beautiful confirmation dialog

# Get current session
CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null)

# Don't allow restarting special sessions
if [ "$CURRENT_SESSION" = "help" ] || [ "$CURRENT_SESSION" = "manager" ]; then
    if command -v gum &>/dev/null; then
        gum style \
            --border rounded \
            --border-foreground 196 \
            --padding "1 2" \
            "⚠️  Cannot restart special session

Session '$CURRENT_SESSION' is a system window.
Use F1-F7 to switch to a console first."
        sleep 2
    else
        echo "⚠️  Cannot restart special session '$CURRENT_SESSION'"
        echo "Use F1-F7 to switch to a console first."
        sleep 2
    fi
    exit 1
fi

# Check if gum is available
if command -v gum &>/dev/null; then
    # Beautiful gum confirmation
    if gum confirm "⚠️  Restart $CURRENT_SESSION?" \
        --affirmative "Yes, restart now" \
        --negative "No, cancel" \
        --prompt.foreground="226" \
        --selected.background="196" \
        --selected.foreground="255"; then

        # User confirmed - restart session
        gum style --foreground 226 "⚙️  Restarting $CURRENT_SESSION..."

        # Call restart logic
        ~/.vps/sessions/src/restart-session.sh "$CURRENT_SESSION"

        gum style --foreground 46 "✓ Session restarted successfully"
        sleep 1
    else
        # User cancelled
        gum style --foreground 244 "Cancelled - session not restarted"
        sleep 1
    fi
else
    # Fallback without gum
    echo ""
    echo "⚠️  Restart $CURRENT_SESSION?"
    echo ""
    echo "This will:"
    echo "  • Kill current session"
    echo "  • Create new clean session"
    echo "  • Lose unsaved work"
    echo ""
    echo -n "Continue? [y/N]: "
    read -n 1 answer
    echo ""

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        echo "⚙️  Restarting $CURRENT_SESSION..."
        ~/.vps/sessions/src/restart-session.sh "$CURRENT_SESSION"
        echo "✓ Session restarted"
        sleep 1
    else
        echo "Cancelled"
        sleep 1
    fi
fi
