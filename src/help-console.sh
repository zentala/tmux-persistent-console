#!/bin/bash
# Minimalna konsola pomocy - bez ładowania profili
# Używana przez F12 w tmux

# Wyłącz wszystkie profile i rc files
export BASH_ENV=""
export ENV=""

# Proste kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Clear screen i pokaż help
clear

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                🖥️  TMUX PERSISTENT CONSOLE                    ║
║                     Quick Help Reference                      ║
╚═══════════════════════════════════════════════════════════════╝

🚀 CONSOLE SWITCHING:
   Ctrl+F1  📟 Console-1 (Claude Code)
   Ctrl+F2  🤖 Console-2 (Copilot CLI)
   Ctrl+F3  💻 Console-3 (Development)
   Ctrl+F4  🧪 Console-4 (Testing)
   Ctrl+F5  📊 Console-5 (Monitoring)
   Ctrl+F6  🌐 Console-6 (Git/Deploy)
   Ctrl+F7  🔧 Console-7 (System Admin)

⚡ SYSTEM CONTROLS:
   Ctrl+F8   🚪 Disconnect safely (detach)
   Ctrl+F9   🔄 Toggle last session
   Ctrl+F10  ⬅️  Previous session
   Ctrl+F11  ➡️  Next session
   Ctrl+F12  📋 This help window

🛠️  COMMANDS:
   connect-console      Interactive session menu
   console-help        Full management menu
   Ctrl+Alt+R          Reset current terminal

💡 TIPS:
• Sessions survive SSH disconnects & reboots
• Use Ctrl+b,d to detach without menu
• This help window stays open - switch with Ctrl+F1-F7
• Type 'exit' or close window when done

════════════════════════════════════════════════════════════════
EOF

echo -e "${CYAN}Help Console Ready${NC} - Use Ctrl+F1-F7 to switch consoles"
echo -e "${YELLOW}Commands available:${NC} console-help, connect-console, exit"
echo ""

# Prosty shell loop - minimalistyczny
while true; do
    echo -n "help> "
    read -r cmd

    case "$cmd" in
        "exit"|"quit"|"q")
            exit 0
            ;;
        "console-help")
            console-help
            ;;
        "connect-console")
            connect-console
            ;;
        "help"|"")
            echo "Available: console-help, connect-console, exit"
            ;;
        "clear")
            clear
            cat << 'EOF'
🖥️  TMUX PERSISTENT CONSOLE - Help Console

Quick Reference:
• Ctrl+F1-F7: Switch to console 1-7
• Ctrl+F8: Disconnect  • Ctrl+F9: Last session
• Commands: console-help, connect-console, exit
EOF
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Try: console-help, connect-console, clear, exit"
            ;;
    esac
done