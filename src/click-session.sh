#!/bin/bash
# Handle mouse clicks on status bar sessions
# Usage: click-session.sh <session_number>

session_num="$1"

if [ -z "$session_num" ]; then
    exit 0
fi

# Validate session number
if ! [[ "$session_num" =~ ^[1-7]$ ]]; then
    exit 0
fi

session_name="console-$session_num"

# Check if session exists
if tmux has-session -t "$session_name" 2>/dev/null; then
    # Switch to existing session
    tmux switch-client -t "$session_name" 2>/dev/null
else
    # Session doesn't exist - lazy start
    # This will be handled by lazy-start.sh later
    # For now, create session immediately
    tmux new-session -d -s "$session_name" -n "main" 2>/dev/null
    tmux switch-client -t "$session_name" 2>/dev/null
fi
