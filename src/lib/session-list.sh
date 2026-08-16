#!/bin/bash
# session-list.sh - build and parse the Mission Control (F11) session list.
# Sourced by mission-control.sh. Kept dependency-free (only tmux) so it can
# be sourced from unit tests with a stubbed tmux.

# Build session list with status and details.
# Reads: $CURRENT_SESSION (set by the caller before sourcing/calling).
build_session_list() {
    # sort -V: natural (version) order, so console-10 follows console-9
    # instead of landing between console-1 and console-2.
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort -V)

    if [ -z "$sessions" ]; then
        echo "No sessions found"
        return 1
    fi

    while IFS= read -r session; do
        local status="○"  # foreground command is the login shell (idle)
        local windows=$(tmux list-windows -t "$session" 2>/dev/null | wc -l)
        local current_window=$(tmux list-windows -t "$session" -F "#{window_active} #{window_name} #{pane_current_command}" 2>/dev/null | grep "^1" | cut -d' ' -f2-)

        # ● when the active pane runs something other than a login shell
        # (bash/zsh/sh/fish); ○ when it's idle at the shell prompt.
        local active_cmd=$(tmux display-message -p -t "$session" '#{pane_current_command}' 2>/dev/null)
        case "$active_cmd" in
            bash|zsh|sh|fish|"") ;;
            *) status="●" ;;
        esac

        # Get F-key mapping
        local fkey=""
        case "$session" in
            console-1) fkey="[F1]" ;;
            console-2) fkey="[F2]" ;;
            console-3) fkey="[F3]" ;;
            console-4) fkey="[F4]" ;;
            console-5) fkey="[F5]" ;;
            console-6) fkey="[F6]" ;;
            console-7) fkey="[F7]" ;;
            console-8) fkey="[F8]" ;;
            console-9) fkey="[F9]" ;;
            console-10) fkey="[F10]" ;;
            *) fkey="    " ;;
        esac

        # Format window info
        local window_info="$current_window"
        [ -z "$window_info" ] && window_info="(empty)"

        # Mark current session. The marker must never be whitespace: the
        # session name is parsed back out of this line as awk field 3, and a
        # leading space would shift every field left by one.
        local marker="·"
        [ "$session" = "$CURRENT_SESSION" ] && marker="→"

        # Output format: "marker status session fkey | window_info"
        printf "%s %s %-15s %s │ %s\n" "$marker" "$status" "$session" "$fkey" "$window_info"
    done <<< "$sessions"
}

# Parse the session name out of one build_session_list line.
# Format: "marker status session fkey | window_info" -> field 3 is the name.
parse_session_from_line() {
    echo "$1" | awk '{print $3}'
}
