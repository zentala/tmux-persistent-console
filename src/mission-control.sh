#!/bin/bash
# Mission Control - F11 panel for tmux session management
# Persistent Console v0.2.0

# Version info
VERSION="0.2.0"  # keep in sync with install.sh PTTY_VERSION
HEADER="🖥️  PERSISTENT CONSOLE v${VERSION}"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Get current session for highlighting
CURRENT_SESSION="${TMUX_SESSION:-$(tmux display-message -p '#S' 2>/dev/null)}"

# build_session_list() and parse_session_from_line() live in session-list.sh
# so they can be unit-tested without a running tmux server.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/session-list.sh
source "$SCRIPT_DIR/lib/session-list.sh"

# Preview mode: fzf invokes "$0 --preview <line>" to render the preview
# pane for a candidate session and exits. Passing the line as an argv
# element (rather than interpolating it into an inline "echo {} | awk ..."
# shell string) means a hostile session name can only ever be seen as
# $2, never as text that gets re-parsed by a shell.
if [ "${1:-}" = "--preview" ]; then
    preview_session=$(awk '{print $3}' <<< "${2:-}")
    if [ -n "$preview_session" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Session: $preview_session"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        tmux list-windows -t "$preview_session" -F "Window #{window_index}: #{window_name} (#{window_panes} panes)" 2>/dev/null
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Current pane:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        tmux capture-pane -t "$preview_session" -p -S -15 2>/dev/null
    fi
    exit 0
fi

# Restart session
restart_session() {
    local session="$1"

    if [ -z "$session" ]; then
        echo "No session specified"
        return 1
    fi

    # Don't allow restarting special sessions (mirrors restart-confirm.sh)
    if [ "$session" = "help" ] || [ "$session" = "manager" ]; then
        echo ""
        echo "⚠️  Cannot restart special session '$session'"
        echo "Use F1-F10 to switch to a console first."
        sleep 2
        return 1
    fi

    # Create temp script for background restart
    local temp_dir="${HOME}/.cache/tmux-console"
    (umask 077 && mkdir -p "$temp_dir")

    local restart_script=$(mktemp "$temp_dir/restart-XXXXXX.sh")
    # Session names come from tmux and may contain characters that are
    # unsafe in a filesystem path (e.g. "/", ".."); strip anything outside
    # a safe set before using it to build the lock file path. The real
    # (unsanitized) name is still used for the tmux commands below.
    local safe_session="${session//[^A-Za-z0-9_-]/_}"
    local lock_file="$temp_dir/restart-${safe_session}.lock"

    cat > "$restart_script" << 'RESTART_SCRIPT'
#!/bin/bash
session_name="$1"
temp_script="$2"
lock_file="$3"

touch "$lock_file" 2>/dev/null
sleep 0.5

if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux kill-session -t "$session_name" 2>/dev/null
fi

# Wait for session to terminate
for i in {1..50}; do
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

sleep 0.2

# Create new session
tmux new-session -d -s "$session_name" -n "main" 2>/dev/null

rm -f "$temp_script" "$lock_file"
exit 0
RESTART_SCRIPT

    chmod 700 "$restart_script"
    nohup "$restart_script" "$session" "$restart_script" "$lock_file" > /dev/null 2>&1 &

    echo "✓ Session $session restarting..."
    sleep 1
}

# Main mission control interface
show_mission_control() {
    # Check if fzf is available
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for Mission Control"
        echo "Install: sudo apt-get install fzf"
        sleep 2
        return 1
    fi

    # Build session list
    local session_list=$(build_session_list)

    if [ -z "$session_list" ]; then
        echo "No tmux sessions found"
        sleep 2
        return 1
    fi

    # Re-invoke this script in preview mode; see the "--preview" handler
    # near the top of the file. Keeps the selected line out of an inline
    # shell string entirely.
    local preview_cmd="bash \"$SCRIPT_DIR/mission-control.sh\" --preview {}"

    # fzf with preview and keybindings (compatible with fzf 0.20+)
    local selected=$(echo "$session_list" | fzf \
        --height=100% \
        --border \
        --prompt="> " \
        --header="$HEADER | [ENTER] Select  [ESC] Close" \
        --preview="$preview_cmd" \
        --preview-window=right:60% \
        --reverse)

    # Extract session name from selection
    local session_name=$(parse_session_from_line "$selected")

    if [ -n "$session_name" ]; then
        # Ask what to do with selected session
        clear
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Session: $session_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  [ENTER]  Switch to this session"
        echo "  [R]      Restart session (kill + recreate)"
        echo "  [ESC]    Cancel"
        echo ""
        echo -n "Choose action: "

        read -n 1 action
        echo ""

        case "$action" in
            r|R)
                echo ""
                echo "⚠  Restarting session '$session_name'..."
                if restart_session "$session_name"; then
                    echo ""
                    echo "✓ Session restarted. Press any key to continue..."
                else
                    echo "Press any key to continue..."
                fi
                read -n 1
                ;;
            ""|$'\n')
                # Switch to selected session
                if [ -n "$TMUX" ]; then
                    tmux switch-client -t "$session_name" 2>/dev/null
                else
                    tmux attach-session -t "$session_name" 2>/dev/null
                fi
                ;;
            *)
                # Cancel - do nothing
                ;;
        esac
    fi
}

# Run mission control
show_mission_control
