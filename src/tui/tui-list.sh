#!/bin/bash
# tui-list.sh - List functions with preview support

source "$(dirname "${BASH_SOURCE[0]}")/tui-core.sh"
source "$(dirname "${BASH_SOURCE[0]}")/tui-menu.sh"

# tui_list_sessions
# Show tmux sessions with preview pane (if fzf available)
tui_list_sessions() {
    if $TUI_HAS_FZF; then
        tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf \
            --prompt="Select session > " \
            --preview='tmux list-windows -t {} 2>/dev/null | head -20' \
            --preview-window=right:60% \
            --border \
            --height=80% \
            --header="Sessions (with window preview)" \
            --reverse
    else
        # Fallback to menu
        local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | tr '\n' ' ')
        tui_menu "Select Session" $sessions
    fi
}

# tui_list_with_preview <items> <preview_command>
# Generic list with preview
tui_list_with_preview() {
    local items="$1"
    local preview_cmd="$2"
    local title="${3:-Select item}"

    if $TUI_HAS_FZF; then
        echo "$items" | fzf \
            --prompt="$title > " \
            --preview="$preview_cmd" \
            --preview-window=right:60% \
            --border \
            --height=80% \
            --reverse
    else
        # Fallback to menu without preview
        tui_menu "$title" $items
    fi
}

# tui_multiselect <title> <options...>
# Multi-select menu (fzf/gum only, fallback to single select)
tui_multiselect() {
    local title="$1"
    shift
    local options=("$@")

    if $TUI_HAS_FZF; then
        printf '%s\n' "${options[@]}" | fzf \
            --multi \
            --prompt="$title (TAB to select multiple) > " \
            --border \
            --height=50% \
            --reverse
    elif $TUI_HAS_GUM; then
        gum choose --no-limit "${options[@]}"
    else
        # Fallback to single select
        echo "Multi-select not available, choose one:"
        tui_menu "$title" "${options[@]}"
    fi
}

# tui_filter <items>
# Fuzzy filter/search through items
tui_filter() {
    local items="$1"
    local prompt="${2:-Filter}"

    if $TUI_HAS_FZF; then
        echo "$items" | fzf \
            --prompt="$prompt > " \
            --border \
            --height=50% \
            --reverse
    elif $TUI_HAS_GUM; then
        echo "$items" | gum filter --placeholder="$prompt"
    else
        # No filtering, just show all
        echo "$items"
    fi
}
