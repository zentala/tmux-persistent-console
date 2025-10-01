#!/bin/bash
# Advanced console help and management script for tmux-persistent-console

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

show_main_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                ${BOLD}🖥️  TMUX PERSISTENT CONSOLE${NC}                   ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                    ${CYAN}Main Control Center${NC}                      ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}🚀 Quick Console Access:${NC}"
    echo ""
    echo -e "  ${GREEN}Ctrl+F1${NC}  📟 Console-1 (Claude Code)     ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F2${NC}  🤖 Console-2 (Copilot CLI)    ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F3${NC}  💻 Console-3 (Development)    ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F4${NC}  🧪 Console-4 (Testing)        ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F5${NC}  📊 Console-5 (Monitoring)     ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F6${NC}  🌐 Console-6 (Git/Deploy)     ${YELLOW}Direct switch${NC}"
    echo -e "  ${GREEN}Ctrl+F7${NC}  🔧 Console-7 (System Admin)   ${YELLOW}Direct switch${NC}"
    echo ""
    echo -e "${BOLD}⚡ System Controls:${NC}"
    echo ""
    echo -e "  ${GREEN}Ctrl+F8${NC}  🚪 Disconnect safely          ${YELLOW}Detach session${NC}"
    echo -e "  ${GREEN}Ctrl+F9${NC}  🔄 Toggle last session        ${YELLOW}Switch back${NC}"
    echo -e "  ${GREEN}Ctrl+F10${NC} ⬅️  Previous session          ${YELLOW}Navigate${NC}"
    echo -e "  ${GREEN}Ctrl+F11${NC} ➡️  Next session              ${YELLOW}Navigate${NC}"
    echo -e "  ${GREEN}Ctrl+F12${NC} 📋 This help menu            ${YELLOW}You are here${NC}"
    echo ""
    echo -e "${BOLD}🛠️  Advanced Options:${NC}"
    echo ""
    echo -e "  ${CYAN}r${NC}  🔄 Reset current session        ${PURPLE}Clear & restart${NC}"
    echo -e "  ${CYAN}R${NC}  💥 Reset ALL sessions           ${PURPLE}Nuclear option${NC}"
    echo -e "  ${CYAN}s${NC}  📊 Show session status          ${PURPLE}Detailed info${NC}"
    echo -e "  ${CYAN}n${NC}  ➕ Create new session           ${PURPLE}Custom session${NC}"
    echo -e "  ${CYAN}k${NC}  ❌ Kill session                 ${PURPLE}Remove session${NC}"
    echo -e "  ${CYAN}h${NC}  ❓ Show detailed help           ${PURPLE}Full guide${NC}"
    echo -e "  ${CYAN}q${NC}  🚪 Quit this menu               ${PURPLE}Return to console${NC}"
    echo ""
    echo -e "${BOLD}💡 Pro Tips:${NC}"
    echo -e "  • Function keys work in most terminals (Windows Terminal, iTerm2, etc.)"
    echo -e "  • Sessions persist across SSH disconnects and reboots"
    echo -e "  • Use ${GREEN}Ctrl+b, d${NC} to detach without this menu"
    echo -e "  • Type ${CYAN}connect-console${NC} anytime to access session menu"
    echo ""
    echo -n "Choose option (1-7, r/R/s/n/k/h/q): "
}

show_session_status() {
    clear
    echo -e "${BLUE}📊 Session Status Report${NC}"
    echo "================================="
    echo ""

    # Current session info
    CURRENT_SESSION=$(tmux display-message -p '#S')
    echo -e "${BOLD}Current Session:${NC} ${GREEN}$CURRENT_SESSION${NC}"
    echo ""

    # List all sessions with details
    echo -e "${BOLD}All Sessions:${NC}"
    tmux list-sessions -F "#{?session_attached,${GREEN}● ,${YELLOW}○ }#{session_name}: #{session_windows} windows, #{?session_attached,attached,detached}, created #{session_created_string}" 2>/dev/null || echo "No sessions found"
    echo ""

    # Current session windows
    echo -e "${BOLD}Windows in $CURRENT_SESSION:${NC}"
    tmux list-windows -F "  ${CYAN}#{window_index}${NC}: #{window_name} #{?window_active,(active),} - #{window_panes} panes" 2>/dev/null || echo "No windows found"
    echo ""

    # System info
    echo -e "${BOLD}System Info:${NC}"
    echo -e "  Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    echo -e "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "  Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo ""

    echo -e "Press ${GREEN}Enter${NC} to return to menu..."
    read -r
}

reset_current_session() {
    CURRENT_SESSION=$(tmux display-message -p '#S')
    echo -e "${YELLOW}⚠️  Resetting session: $CURRENT_SESSION${NC}"
    echo -e "This will:"
    echo -e "  • Clear the current terminal"
    echo -e "  • Reset the shell environment"
    echo -e "  • Keep the session running"
    echo ""
    echo -n "Continue? (y/N): "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Clear screen and reset terminal
        clear
        reset
        echo -e "${GREEN}✅ Session $CURRENT_SESSION reset successfully!${NC}"
        echo -e "Session is ready for use."
    else
        echo -e "${BLUE}Reset cancelled.${NC}"
    fi
    sleep 1
}

reset_all_sessions() {
    echo -e "${RED}💥 NUCLEAR OPTION: Reset ALL Sessions${NC}"
    echo -e "${YELLOW}⚠️  This will:${NC}"
    echo -e "  • Kill ALL existing console sessions"
    echo -e "  • Create fresh console-1 through console-7"
    echo -e "  • Reset all tmux configuration"
    echo -e "  • ${RED}You will lose all running processes!${NC}"
    echo ""
    echo -n "Type 'RESET' to confirm: "
    read -r confirm

    if [ "$confirm" = "RESET" ]; then
        echo -e "${YELLOW}🔄 Resetting all sessions...${NC}"

        # Kill all console sessions
        for i in {1..7}; do
            tmux kill-session -t "console-$i" 2>/dev/null && echo "  ✓ Killed console-$i"
        done

        # Recreate sessions
        if command -v setup-console-sessions >/dev/null 2>&1; then
            setup-console-sessions
        else
            # Fallback creation
            for i in {1..7}; do
                tmux new-session -d -s "console-$i" -n "main"
                echo "  ✓ Created console-$i"
            done
        fi

        echo -e "${GREEN}✅ All sessions reset successfully!${NC}"
        echo -e "Switching to console-1..."
        sleep 2
        tmux switch-client -t console-1
    else
        echo -e "${BLUE}Reset cancelled.${NC}"
        sleep 1
    fi
}

create_new_session() {
    echo -e "${CYAN}➕ Create New Session${NC}"
    echo ""
    echo -n "Enter session name: "
    read -r session_name

    if [ -z "$session_name" ]; then
        echo -e "${RED}❌ Session name cannot be empty${NC}"
        sleep 1
        return
    fi

    # Check if session already exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Session '$session_name' already exists${NC}"
        echo -n "Switch to it? (y/N): "
        read -r switch_confirm
        if [[ "$switch_confirm" =~ ^[Yy]$ ]]; then
            tmux switch-client -t "$session_name"
        fi
        sleep 1
        return
    fi

    # Create new session
    tmux new-session -d -s "$session_name" -n "main"
    echo -e "${GREEN}✅ Created session: $session_name${NC}"
    echo -n "Switch to it now? (Y/n): "
    read -r switch_confirm

    if [[ ! "$switch_confirm" =~ ^[Nn]$ ]]; then
        tmux switch-client -t "$session_name"
    fi
    sleep 1
}

kill_session_menu() {
    echo -e "${RED}❌ Kill Session${NC}"
    echo ""
    echo -e "${BOLD}Available sessions:${NC}"
    tmux list-sessions -F "  #{session_name} (#{session_windows} windows)" 2>/dev/null
    echo ""
    echo -n "Enter session name to kill (or 'cancel'): "
    read -r session_name

    if [ "$session_name" = "cancel" ] || [ -z "$session_name" ]; then
        echo -e "${BLUE}Kill cancelled.${NC}"
        sleep 1
        return
    fi

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${RED}❌ Session '$session_name' not found${NC}"
        sleep 1
        return
    fi

    echo -e "${YELLOW}⚠️  This will permanently kill session: $session_name${NC}"
    echo -n "Confirm? (y/N): "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        tmux kill-session -t "$session_name"
        echo -e "${GREEN}✅ Session '$session_name' killed${NC}"
    else
        echo -e "${BLUE}Kill cancelled.${NC}"
    fi
    sleep 1
}

show_detailed_help() {
    clear
    echo -e "${BLUE}❓ Tmux Persistent Console - Complete Guide${NC}"
    echo "=================================================="
    echo ""
    echo -e "${BOLD}🎯 Purpose:${NC}"
    echo "  This tool provides 7 persistent terminal sessions that survive"
    echo "  SSH disconnects, network issues, and system reboots."
    echo ""
    echo -e "${BOLD}🖥️  Console Layout:${NC}"
    echo -e "  Console-1: ${CYAN}Claude Code / AI Development${NC}"
    echo -e "  Console-2: ${CYAN}GitHub Copilot CLI / AI Assistant${NC}"
    echo -e "  Console-3: ${CYAN}General Development / Coding${NC}"
    echo -e "  Console-4: ${CYAN}Testing / QA / Validation${NC}"
    echo -e "  Console-5: ${CYAN}Monitoring / Logs / Performance${NC}"
    echo -e "  Console-6: ${CYAN}Git Operations / Deployment${NC}"
    echo -e "  Console-7: ${CYAN}System Administration / Maintenance${NC}"
    echo ""
    echo -e "${BOLD}⌨️  Keyboard Shortcuts:${NC}"
    echo -e "  ${GREEN}Function Keys (Global):${NC}"
    echo -e "    Ctrl+F1-F7  Switch directly to console 1-7"
    echo -e "    Ctrl+F8     Disconnect (detach) safely"
    echo -e "    Ctrl+F9     Toggle to last used session"
    echo -e "    Ctrl+F10    Previous session in list"
    echo -e "    Ctrl+F11    Next session in list"
    echo -e "    Ctrl+F12    Open this help menu"
    echo ""
    echo -e "  ${GREEN}Traditional tmux (Ctrl+b prefix):${NC}"
    echo -e "    Ctrl+b, 1-7    Switch to console 1-7"
    echo -e "    Ctrl+b, s      Visual session selector"
    echo -e "    Ctrl+b, d      Detach from session"
    echo -e "    Ctrl+b, c      Create new window"
    echo -e "    Ctrl+b, n      Next window"
    echo -e "    Ctrl+b, p      Previous window"
    echo ""
    echo -e "${BOLD}🔧 Commands:${NC}"
    echo -e "    connect-console      Interactive session menu"
    echo -e "    setup-console-sessions   Recreate all 7 sessions"
    echo -e "    uninstall-console    Remove tmux-persistent-console"
    echo ""
    echo -e "${BOLD}🌐 Remote Access:${NC}"
    echo -e "    ssh user@server -t \"tmux attach -t console-1\""
    echo -e "    ssh user@server -t \"connect-console\""
    echo ""
    echo -e "${BOLD}💡 Tips:${NC}"
    echo -e "  • Sessions persist even if SSH disconnects"
    echo -e "  • You can attach from multiple locations simultaneously"
    echo -e "  • Use different consoles for different projects"
    echo -e "  • Function keys work in most modern terminals"
    echo -e "  • This tool is perfect for AI CLI workflows"
    echo ""
    echo -e "Press ${GREEN}Enter${NC} to return to menu..."
    read -r
}

# Main menu loop
main_menu() {
    while true; do
        show_main_menu
        read -r choice

        case "$choice" in
            1|"console-1"|"c1")
                tmux switch-client -t console-1
                tmux kill-window -t "🔧Help"
                break
                ;;
            2|"console-2"|"c2")
                tmux switch-client -t console-2
                tmux kill-window -t "🔧Help"
                break
                ;;
            3|"console-3"|"c3")
                tmux switch-client -t console-3
                tmux kill-window -t "🔧Help"
                break
                ;;
            4|"console-4"|"c4")
                tmux switch-client -t console-4
                tmux kill-window -t "🔧Help"
                break
                ;;
            5|"console-5"|"c5")
                tmux switch-client -t console-5
                tmux kill-window -t "🔧Help"
                break
                ;;
            6|"console-6"|"c6")
                tmux switch-client -t console-6
                tmux kill-window -t "🔧Help"
                break
                ;;
            7|"console-7"|"c7")
                tmux switch-client -t console-7
                tmux kill-window -t "🔧Help"
                break
                ;;
            r|"reset")
                reset_current_session
                ;;
            R|"RESET")
                reset_all_sessions
                break
                ;;
            s|"status")
                show_session_status
                ;;
            n|"new")
                create_new_session
                ;;
            k|"kill")
                kill_session_menu
                ;;
            h|"help")
                show_detailed_help
                ;;
            q|"quit"|"exit")
                tmux kill-window -t "🔧Help"
                break
                ;;
            "")
                # Empty input, continue
                continue
                ;;
            *)
                echo -e "${RED}❌ Invalid option: $choice${NC}"
                echo -e "Try: 1-7, r, R, s, n, k, h, q"
                sleep 1
                ;;
        esac
    done
}

# Run main menu
main_menu