#!/bin/bash
# tui-menu.sh - Unified menu interface for all TUI tools

source "$(dirname "${BASH_SOURCE[0]}")/tui-core.sh"

# tui_menu <title> <options...>
# Returns: selected option text
tui_menu() {
    local title="$1"
    shift
    local options=("$@")

    case "$TUI_TOOL" in
        gum)
            _tui_menu_gum "$title" "${options[@]}"
            ;;
        fzf)
            _tui_menu_fzf "$title" "${options[@]}"
            ;;
        dialog)
            _tui_menu_dialog "$title" "${options[@]}"
            ;;
        whiptail)
            _tui_menu_whiptail "$title" "${options[@]}"
            ;;
        basic)
            _tui_menu_basic "$title" "${options[@]}"
            ;;
    esac
}

_tui_menu_gum() {
    local title="$1"
    shift

    # Header with gum style
    gum style \
        --border double \
        --border-foreground 212 \
        --align center \
        --width 60 \
        --padding "0 2" \
        "$title"

    echo ""

    # Menu with gum choose
    gum choose "$@"
}

_tui_menu_fzf() {
    local title="$1"
    shift

    printf '%s\n' "$@" | fzf \
        --prompt="$title > " \
        --height=50% \
        --border \
        --reverse \
        --cycle
}

_tui_menu_dialog() {
    local title="$1"
    shift
    local items=()
    local i=1

    for opt in "$@"; do
        items+=("$i" "$opt")
        ((i++))
    done

    local choice=$(dialog --stdout --title "$title" --menu "Choose option:" 20 70 15 "${items[@]}")
    if [ $? -eq 0 ] && [ -n "$choice" ]; then
        echo "${items[$((choice*2-1))]}"
    fi
}

_tui_menu_whiptail() {
    local title="$1"
    shift
    local items=()
    local i=1

    for opt in "$@"; do
        items+=("$i" "$opt")
        ((i++))
    done

    local choice=$(whiptail --title "$title" --menu "Choose option:" 20 70 10 "${items[@]}" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ] && [ -n "$choice" ]; then
        echo "${items[$((choice*2-1))]}"
    fi
}

_tui_menu_basic() {
    local title="$1"
    shift

    echo "╔════════════════════════════════════════════════╗"
    printf "║ %-46s ║\n" "$title"
    echo "╠════════════════════════════════════════════════╣"

    local i=1
    for opt in "$@"; do
        printf "║ [%d] %-42s ║\n" "$i" "$opt"
        ((i++))
    done

    echo "╚════════════════════════════════════════════════╝"
    echo ""

    read -p "Choose [1-$((i-1))]: " choice

    if [ -n "$choice" ] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        echo "${@:$choice:1}"
    fi
}
