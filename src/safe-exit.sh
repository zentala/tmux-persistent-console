#!/bin/bash
# ~/.vps/sessions/src/safe-exit.sh - Safe exit wrapper for tmux sessions
# Prevents accidental session termination

safe_exit() {
    # ANSI color codes
    local GRAY_BG='\033[48;5;240m'   # Gray background
    local WHITE_TEXT='\033[97m'       # White text
    local BLACK_TEXT='\033[30m'       # Black text for brackets
    local RESET='\033[0m'             # Reset colors
    local BOLD='\033[1m'              # Bold text

    # Key button style with visible brackets
    local BRACKET="${GRAY_BG}${BLACK_TEXT}${BOLD}"
    local KEY_TEXT="${GRAY_BG}${WHITE_TEXT}${BOLD}"
    local KEY_END="${RESET}"

    # Check if we're inside a tmux session
    if [ -n "$TMUX" ]; then
        # Get current session name for restart
        local session_name=$(tmux display-message -p '#S')

        while true; do
            echo ""
            echo "⚠  WARNING: You are in a persistent tmux session!"
            echo ""
            echo "What do you want to do?"
            echo -e "  ${BRACKET}[${KEY_TEXT} ENTER ${BRACKET}]${KEY_END}                   - Detach safely (recommended)"
            echo -e "  ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END}          - Restart session (console will be reset)"
            echo -e "  ${BRACKET}[${KEY_TEXT} ESC ${BRACKET}]${KEY_END}                     - Stay in session"
            echo ""
            printf "Your choice: "

            # Trap Ctrl+C to cancel (inside read to avoid duplicates)
            trap 'echo ""; echo "[OK] Staying in session. You can continue working."; trap - INT; return 0' INT

            # Read single character (works in both bash and zsh)
            if [ -n "$ZSH_VERSION" ]; then
                # In zsh, read -k 1 reads one character including newline
                read -k 1 choice
                # If it's a newline, convert to empty string
                if [[ "$choice" == $'\n' ]]; then
                    choice=""
                fi
            else
                # In bash, read -n 1 works as expected
                read -n 1 choice
            fi

            # Clear trap after read
            trap - INT

            # Show what was pressed (visual feedback)
            case "$choice" in
                Y)
                    echo "SHIFT+Y"
                    ;;
                y)
                    echo "y"
                    ;;
                $'\e')
                    echo "ESC"
                    ;;
                "")
                    echo "ENTER"
                    ;;
                *)
                    echo "'$choice'"
                    ;;
            esac
            echo ""

            case "$choice" in
                Y)
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "🔄 Restarting persistent tmux session '$session_name'..."
                    echo ""
                    echo "Session will be fresh and ready in 1 second."
                    echo "Reconnect with: tmux attach -t $session_name"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo ""

                    # Create a restart script that runs after we exit
                    local restart_script="/tmp/tmux-restart-$session_name.sh"
                    cat > "$restart_script" << EOF
#!/bin/bash
sleep 1
tmux has-session -t "$session_name" 2>/dev/null && tmux kill-session -t "$session_name"
tmux new-session -d -s "$session_name" -n "main"
rm -f "$restart_script"
EOF
                    chmod +x "$restart_script"

                    # Run restart script in background and exit
                    nohup "$restart_script" > /dev/null 2>&1 &

                    sleep 1
                    builtin exit
                    ;;
                $'\e')
                    echo "[OK] Staying in session. You can continue working."
                    return 0
                    ;;
                "")
                    echo "✓ Detached from persistent tmux session '$session_name'"
                    sleep 0.8
                    tmux detach-client
                    return 0
                    ;;
                y)
                    echo -e "[!] You pressed ${BRACKET}[${KEY_TEXT} y ${BRACKET}]${KEY_END} (lowercase). You need ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END} to restart session."
                    sleep 2
                    # Loop continues, showing menu again
                    ;;
                *)
                    echo -e "[!] Invalid choice. Please press ${BRACKET}[${KEY_TEXT} ENTER ${BRACKET}]${KEY_END}, ${BRACKET}[${KEY_TEXT} SHIFT ${BRACKET}]${KEY_END} + ${BRACKET}[${KEY_TEXT} Y ${BRACKET}]${KEY_END}, or ${BRACKET}[${KEY_TEXT} ESC ${BRACKET}]${KEY_END}"
                    sleep 1
                    # Loop continues, showing menu again
                    ;;
            esac
        done
    else
        # Not in tmux, just exit normally
        builtin exit
    fi
}

# Override the exit command
alias exit='safe_exit'

# Inform user about Ctrl+D alternative
if [ -n "$TMUX" ]; then
    # Trap Ctrl+D to also use safe exit
    trap 'safe_exit' SIGINT
fi
