#!/bin/bash
# tui-status.sh - Status displays, headers, tables

source "$(dirname "${BASH_SOURCE[0]}")/tui-core.sh"

# tui_header <title>
# Display styled header
tui_header() {
    local title="$1"

    case "$TUI_TOOL" in
        gum)
            gum style \
                --border double \
                --border-foreground 212 \
                --align center \
                --width 60 \
                --padding "1 2" \
                "$title"
            ;;
        *)
            echo "╔══════════════════════════════════════════════════════╗"
            printf "║ %-52s ║\n" "$title"
            echo "╚══════════════════════════════════════════════════════╝"
            ;;
    esac
}

# tui_separator [char] [width]
# Print separator line
tui_separator() {
    local char="${1:-─}"
    local width="${2:-60}"

    if $TUI_HAS_GUM; then
        gum style --foreground 240 "$(printf '%*s' "$width" | tr ' ' "$char")"
    else
        printf '%*s\n' "$width" | tr ' ' "$char"
    fi
}

# tui_table <data>
# Pretty print table
tui_table() {
    local data="$1"

    if $TUI_HAS_GUM; then
        echo "$data" | gum table
    else
        echo "$data" | column -t -s $'\t'
    fi
}

# tui_progress <current> <total> <message>
# Show progress bar (gum only, fallback to percentage)
tui_progress() {
    local current="$1"
    local total="$2"
    local message="${3:-Progress}"

    if $TUI_HAS_GUM; then
        local percent=$((current * 100 / total))
        echo "$percent" | gum style --foreground 212 --bold
    else
        local percent=$((current * 100 / total))
        printf "%s: %d%% (%d/%d)\n" "$message" "$percent" "$current" "$total"
    fi
}

# tui_format <text> [style]
# Format text with style (gum only, fallback to plain)
# Styles: bold, italic, underline, strikethrough
tui_format() {
    local text="$1"
    local style="${2:-bold}"

    if $TUI_HAS_GUM; then
        gum style --"$style" "$text"
    else
        # ANSI fallback
        case "$style" in
            bold) echo -e "\033[1m$text\033[0m" ;;
            underline) echo -e "\033[4m$text\033[0m" ;;
            *) echo "$text" ;;
        esac
    fi
}

# tui_color <text> <color>
# Colorize text
# Colors: red, green, yellow, blue, magenta, cyan
tui_color() {
    local text="$1"
    local color="${2:-blue}"

    if $TUI_HAS_GUM; then
        gum style --foreground "$color" "$text"
    else
        # ANSI color codes
        case "$color" in
            red) echo -e "\033[31m$text\033[0m" ;;
            green) echo -e "\033[32m$text\033[0m" ;;
            yellow) echo -e "\033[33m$text\033[0m" ;;
            blue) echo -e "\033[34m$text\033[0m" ;;
            magenta) echo -e "\033[35m$text\033[0m" ;;
            cyan) echo -e "\033[36m$text\033[0m" ;;
            *) echo "$text" ;;
        esac
    fi
}

# tui_box <text>
# Put text in a box
tui_box() {
    local text="$1"
    local border="${2:-single}"

    if $TUI_HAS_GUM; then
        gum style --border "$border" --padding "1 2" "$text"
    else
        echo "┌────────────────────────────────────────┐"
        printf "│ %-38s │\n" "$text"
        echo "└────────────────────────────────────────┘"
    fi
}

# tui_status_line <label> <value> [color]
# Print status line: "Label: Value"
tui_status_line() {
    local label="$1"
    local value="$2"
    local color="${3:-green}"

    if $TUI_HAS_GUM; then
        echo "$(gum style --bold "$label:")" "$(gum style --foreground "$color" "$value")"
    else
        printf "%-20s: %s\n" "$label" "$value"
    fi
}
