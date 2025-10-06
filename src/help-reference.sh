#!/bin/bash
# F12 - Static Help Reference Window
# Simple, clean documentation without decorative borders

VERSION="1.0.0"

# Clear screen and show help
clear

cat << 'EOF'

  🖥️  PERSISTENT CONSOLE v1.0.0 - Quick Reference


  KEYBOARD SHORTCUTS

    Direct Jump:
      F1-F7          Jump to console 1-7
      Ctrl+F1-F7     Same as F1-F7
      Ctrl+1-7       Alternative jump

    Navigation:
      Ctrl+←         Previous console
      Ctrl+→         Next console

    Management:
      F11            Console Manager (interactive menu)
      Ctrl+R         Restart current console (with confirmation)
      Ctrl+D         Disconnect safely (detach)
      Ctrl+?         Show keyboard shortcuts popup


  MOUSE SUPPORT

    Click tab      Switch to console
    Scroll wheel   Navigate within console


  STATUS BAR

    Console tabs show:
      Icon     Active session (has processes)
      Icon     Empty/idle session
      Number   Console number (1-7)
      Name     Current window name

    Active tab highlighted in cyan with shadow effect


  SESSIONS

    • All sessions are persistent (survive disconnects)
    • Consoles 1-5 start automatically on boot
    • Consoles 6-7 start on demand (lazy start)
    • Type 'exit' to safely detach (won't kill session)
    • Sessions survive SSH disconnects and server reboots


  HELP & SUPPORT

    Documentation:  github.com/zentala/tmux-persistent-console
    Report Bug:     github.com/zentala/tmux-persistent-console/issues
    Author:         Zentala


  Press F1-F7 or click tab to switch consoles


EOF

# Keep window open (static display, no input)
echo ""
echo "  This is a read-only reference window."
echo "  Switch to another console using F1-F7 or close this tab."
echo ""

# Sleep forever (keep window visible)
sleep infinity
