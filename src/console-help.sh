#!/bin/bash
# Advanced console help and management - TUI powered
# Refactored to use TUI library (gum/fzf/whiptail/basic)

# Load TUI library
TUI_DIR="$(dirname "${BASH_SOURCE[0]}")/tui"
source "$TUI_DIR/tui-core.sh"
source "$TUI_DIR/tui-menu.sh"
source "$TUI_DIR/tui-dialogs.sh"
source "$TUI_DIR/tui-list.sh"
source "$TUI_DIR/tui-status.sh"

# Main menu
show_main_menu() {
    clear

    tui_header "🖥️  TMUX PERSISTENT CONSOLE - Main Control Center"
    echo ""

    local choice=$(tui_menu "Choose action" \
        "📟 Console-1 (Claude Code)" \
        "🤖 Console-2 (Copilot CLI)" \
        "💻 Console-3 (Development)" \
        "🧪 Console-4 (Testing)" \
        "📊 Console-5 (Monitoring)" \
        "🌐 Console-6 (Git/Deploy)" \
        "🔧 Console-7 (System Admin)" \
        "────────────────────" \
        "🔄 Reset current session" \
        "💥 Reset ALL sessions" \
        "📊 Session status" \
        "➕ New session" \
        "❌ Kill session" \
        "❓ Help" \
        "🚪 Quit")

    echo "$choice"
}

# Switch to console
switch_to_console() {
    local num="$1"
    tmux switch-client -t "console-$num" 2>/dev/null
    tmux kill-window -t "🔧Help" 2>/dev/null
}

# Reset current session
reset_current_session() {
    local session=$(tmux display-message -p '#S')

    if tui_confirm "Reset session '$session'? This will clear terminal and reset environment."; then
        tui_spin "Resetting session..." "sleep 0.5 && reset"
        tui_msgbox "Success" "✅ Session '$session' reset successfully!"
    fi
}

# Reset all sessions
reset_all_sessions() {
    tui_msgbox "Warning" "⚠️ This will KILL ALL console sessions and recreate them!"

    local confirm=$(tui_input "Type 'RESET' to confirm")

    if [ "$confirm" = "RESET" ]; then
        echo "🔄 Resetting all sessions..."

        # Kill all console sessions
        for i in {1..7}; do
            tmux kill-session -t "console-$i" 2>/dev/null && echo "  ✓ Killed console-$i"
        done

        # Recreate
        if command -v setup-console-sessions >/dev/null 2>&1; then
            setup-console-sessions
        else
            for i in {1..7}; do
                tmux new-session -d -s "console-$i" -n "main"
                echo "  ✓ Created console-$i"
            done
        fi

        tui_msgbox "Complete" "✅ All sessions reset! Switching to console-1..."
        sleep 1
        tmux switch-client -t console-1
    else
        tui_msgbox "Cancelled" "Reset cancelled."
    fi
}

# Show session status
show_session_status() {
    if $TUI_HAS_FZF; then
        # FZF with preview
        local session=$(tui_list_sessions)

        if [ -n "$session" ]; then
            if tui_confirm "Switch to session '$session'?"; then
                tmux switch-client -t "$session"
                tmux kill-window -t "🔧Help" 2>/dev/null
            fi
        fi
    else
        # Fallback: show status in msgbox
        clear
        tui_header "📊 Session Status"
        echo ""

        local current=$(tmux display-message -p '#S')
        tui_status_line "Current Session" "$current" "green"
        echo ""

        echo "All Sessions:"
        tmux list-sessions -F "  #{?session_attached,●,○} #{session_name}: #{session_windows} windows" 2>/dev/null
        echo ""

        echo "System Info:"
        tui_status_line "  Uptime" "$(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
        tui_status_line "  Load" "$(uptime | awk -F'load average:' '{print $2}')"
        tui_status_line "  Memory" "$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' || echo 'N/A')"
        echo ""

        read -p "Press Enter to continue..."
    fi
}

# Create new session
create_new_session() {
    local name=$(tui_input "Enter session name" "my-session")

    if [ -z "$name" ]; then
        tui_msgbox "Error" "❌ Session name cannot be empty"
        return
    fi

    if tmux has-session -t "$name" 2>/dev/null; then
        if tui_confirm "Session '$name' exists. Switch to it?"; then
            tmux switch-client -t "$name"
        fi
        return
    fi

    tmux new-session -d -s "$name" -n "main"
    tui_msgbox "Success" "✅ Session '$name' created!"

    if tui_confirm "Switch to it now?"; then
        tmux switch-client -t "$name"
        tmux kill-window -t "🔧Help" 2>/dev/null
    fi
}

# Kill session
kill_session_menu() {
    local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | tr '\n' ' ')

    if [ -z "$sessions" ]; then
        tui_msgbox "Error" "No sessions found"
        return
    fi

    local session=$(tui_menu "Select session to kill" $sessions "Cancel")

    if [ "$session" = "Cancel" ] || [ -z "$session" ]; then
        return
    fi

    if tui_confirm "Kill session '$session'? This action cannot be undone."; then
        tmux kill-session -t "$session" 2>/dev/null
        tui_msgbox "Success" "✅ Session '$session' killed"
    fi
}

# Show detailed help
show_detailed_help() {
    clear
    tui_header "❓ Tmux Persistent Console - Complete Guide"

    cat << 'EOF'

🎯 PURPOSE:
  7 persistent terminal sessions that survive SSH disconnects,
  network issues, and system reboots.

🖥️  CONSOLE LAYOUT:
  Console-1: Claude Code / AI Development
  Console-2: GitHub Copilot CLI / AI Assistant
  Console-3: General Development / Coding
  Console-4: Testing / QA / Validation
  Console-5: Monitoring / Logs / Performance
  Console-6: Git Operations / Deployment
  Console-7: System Administration

⌨️  KEYBOARD SHORTCUTS:
  Function Keys (Global):
    Ctrl+F1-F7   Switch directly to console 1-7
    Ctrl+F8      Disconnect (detach) safely
    Ctrl+F9      Toggle to last used session
    Ctrl+F10     Previous session
    Ctrl+F11     Next session
    Ctrl+F12     This help menu

  Traditional tmux (Ctrl+b prefix):
    Ctrl+b, 1-7  Switch to console 1-7
    Ctrl+b, s    Visual session selector
    Ctrl+b, d    Detach from session

🔧 COMMANDS:
    connect-console          Interactive session menu
    setup-console-sessions   Recreate all 7 sessions
    uninstall-console        Remove this tool

🌐 REMOTE ACCESS:
    ssh user@server -t "tmux attach -t console-1"

💡 TIPS:
  • Sessions persist even if SSH disconnects
  • You can attach from multiple locations
  • Use different consoles for different projects
  • Function keys work in most modern terminals

EOF

    read -p "Press Enter to return to menu..."
}

# Main loop
main() {
    while true; do
        choice=$(show_main_menu)

        case "$choice" in
            *Console-1*) switch_to_console 1; break ;;
            *Console-2*) switch_to_console 2; break ;;
            *Console-3*) switch_to_console 3; break ;;
            *Console-4*) switch_to_console 4; break ;;
            *Console-5*) switch_to_console 5; break ;;
            *Console-6*) switch_to_console 6; break ;;
            *Console-7*) switch_to_console 7; break ;;
            *Reset\ current*) reset_current_session ;;
            *Reset\ ALL*) reset_all_sessions; break ;;
            *Session\ status*) show_session_status ;;
            *New\ session*) create_new_session ;;
            *Kill\ session*) kill_session_menu ;;
            *Help*) show_detailed_help ;;
            *Quit*|"") tmux kill-window -t "🔧Help" 2>/dev/null; break ;;
        esac
    done
}

main
