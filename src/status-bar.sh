#!/bin/bash
# Status bar generator for tmux v2.1
# Shows header + all 7 console sessions + F11/F12 tabs

# Nerd Font icons
ICON_ACTIVE=""  # Active session (has processes)
ICON_IDLE=""    # Idle session (empty)
ICON_HEADER="🖥️"  # Header icon

# Get current session and terminal width
CURRENT_SESSION="${1:-$(tmux display-message -p '#S' 2>/dev/null)}"
TERM_WIDTH="${2:-$(tmux display-message -p '#{client_width}' 2>/dev/null)}"
[ -z "$TERM_WIDTH" ] && TERM_WIDTH=80

# Determine if we have enough space
WIDE_MODE=true
if [ "$TERM_WIDTH" -lt 120 ]; then
    WIDE_MODE=false
fi

# Build status bar content
build_status_bar() {
    local output=""

    # HEADER (left side)
    if $WIDE_MODE; then
        # Wide screen: show full header
        local hostname=$(hostname -s)
        output+="#[fg=colour39,bg=colour236,bold] $ICON_HEADER CONSOLE@$hostname #[fg=colour236,bg=colour234]#[default]"
    else
        # Narrow screen: only icon
        output+="#[fg=colour39,bg=colour236,bold] $ICON_HEADER #[fg=colour236,bg=colour234]#[default]"
    fi

    output+=" "

    # CONSOLE SESSIONS (1-7)
    for i in {1..7}; do
        local session="console-$i"
        local icon="$ICON_IDLE"
        local fg="colour244"  # Gray for inactive
        local bg="colour234"
        local shadow=""
        local attrs=""

        # Check if session exists
        if tmux has-session -t "$session" 2>/dev/null; then
            # Check if session has active processes
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            local active_cmd=$(tmux list-panes -t "$session" -F "#{pane_current_command}" 2>/dev/null | grep -v "^zsh$\|^bash$" | head -1)

            if [ "$pane_count" -gt 1 ] || [ -n "$active_cmd" ]; then
                icon="$ICON_ACTIVE"
            fi

            # Get window name
            local window_name=$(tmux list-windows -t "$session" -F "#{window_name}" 2>/dev/null | head -1)
            [ -z "$window_name" ] && window_name="main"

            # Highlight current session (raised tab effect)
            if [ "$session" = "$CURRENT_SESSION" ]; then
                fg="colour39"  # Cyan for active
                bg="colour236"  # Slightly lighter background
                shadow="#[fg=colour236,bg=colour234]#[default]"  # Shadow on right
            else
                bg="colour234"
                shadow=""
            fi

            # Format based on screen width
            if $WIDE_MODE; then
                # Wide: show icon + number:name
                output+="#[fg=$fg,bg=$bg,bold] $icon $i:${window_name:0:6} #[default]$shadow"
            else
                # Narrow: only icon + number
                output+="#[fg=$fg,bg=$bg,bold] $icon$i #[default]$shadow"
            fi
        else
            # Session doesn't exist yet (lazy start)
            if $WIDE_MODE; then
                output+="#[fg=colour240,bg=$bg] $icon $i:--- #[default]"
            else
                output+="#[fg=colour240,bg=$bg] $icon$i #[default]"
            fi
        fi

        # Separator
        output+=" "
    done

    # F11 and F12 TABS
    local f11_label="F11"
    local f12_label="F12"
    local f11_fg="colour244"
    local f12_fg="colour244"
    local f11_bg="colour234"
    local f12_bg="colour234"
    local f11_shadow=""
    local f12_shadow=""

    # Check if we're in F11 or F12 "session" (special handling)
    if [ "$CURRENT_SESSION" = "manager" ]; then
        f11_fg="colour39"
        f11_bg="colour236"
        f11_shadow="#[fg=colour236,bg=colour234]#[default]"
    elif [ "$CURRENT_SESSION" = "help" ]; then
        f12_fg="colour39"
        f12_bg="colour236"
        f12_shadow="#[fg=colour236,bg=colour234]#[default]"
    fi

    if $WIDE_MODE; then
        output+=" #[fg=$f11_fg,bg=$f11_bg,bold] 󰆍 F11:Manager #[default]$f11_shadow "
        output+="#[fg=$f12_fg,bg=$f12_bg,bold] ? F12:Help #[default]$f12_shadow"
    else
        output+=" #[fg=$f11_fg,bg=$f11_bg,bold] F11 #[default]$f11_shadow "
        output+="#[fg=$f12_fg,bg=$f12_bg,bold] F12 #[default]$f12_shadow"
    fi

    echo "$output"
}

build_status_bar
