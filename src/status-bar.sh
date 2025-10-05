#!/bin/bash
# Status bar generator for tmux
# Shows all 7 console sessions with icons and colors

# Nerd Font icons
ICON_ACTIVE=""  # Active session (has processes)
ICON_IDLE=""    # Idle session (empty)

# Get current session
CURRENT_SESSION="${1:-$(tmux display-message -p '#S' 2>/dev/null)}"

# Build status bar content
build_status_bar() {
    local output=""

    # Loop through all 7 consoles
    for i in {1..7}; do
        local session="console-$i"
        local icon="$ICON_IDLE"
        local color="colour244"  # Gray for inactive
        local bg="colour234"
        local attrs=""

        # Check if session exists
        if tmux has-session -t "$session" 2>/dev/null; then
            # Check if session has active processes (more than 1 pane or active command)
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            local active_cmd=$(tmux list-panes -t "$session" -F "#{pane_current_command}" 2>/dev/null | grep -v "^zsh$\|^bash$" | head -1)

            if [ "$pane_count" -gt 1 ] || [ -n "$active_cmd" ]; then
                icon="$ICON_ACTIVE"
            fi

            # Get window name
            local window_name=$(tmux list-windows -t "$session" -F "#{window_name}" 2>/dev/null | head -1)
            [ -z "$window_name" ] && window_name="main"

            # Highlight current session
            if [ "$session" = "$CURRENT_SESSION" ]; then
                color="colour39"  # Cyan for active
                attrs=",underscore"
            fi

            # Format: icon number:name
            output+="#[fg=$color,bg=$bg,bold$attrs] $icon $i:${window_name:0:8} #[default]"
        else
            # Session doesn't exist yet (lazy start)
            output+="#[fg=colour240,bg=$bg] $icon $i:--- #[default]"
        fi

        # Add separator between sessions
        if [ $i -lt 7 ]; then
            output+=" "
        fi
    done

    # Add help hint on the right
    output+="#[fg=colour240,bg=colour234]  │ #[fg=colour244]Ctrl+? Help#[default]"

    echo "$output"
}

build_status_bar
