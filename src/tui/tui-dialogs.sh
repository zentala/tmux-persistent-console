#!/bin/bash
# tui-dialogs.sh - Dialog functions (confirm, input, message)

source "$(dirname "${BASH_SOURCE[0]}")/tui-core.sh"

# tui_confirm <question>
# Returns: 0=yes, 1=no
tui_confirm() {
    local question="$1"

    case "$TUI_TOOL" in
        gum)
            gum confirm "$question"
            ;;
        dialog)
            dialog --stdout --title "Confirm" --yesno "$question" 10 60
            ;;
        whiptail)
            whiptail --title "Confirm" --yesno "$question" 10 60
            ;;
        basic)
            read -p "$question (y/N): " -n 1 choice
            echo
            [[ "$choice" =~ ^[Yy]$ ]]
            ;;
    esac
}

# tui_input <prompt> [placeholder]
# Returns: user input
tui_input() {
    local prompt="$1"
    local placeholder="${2:-}"

    case "$TUI_TOOL" in
        gum)
            gum input --placeholder="$placeholder" --prompt="$prompt: "
            ;;
        dialog)
            dialog --stdout --title "Input" --inputbox "$prompt" 10 60 "$placeholder"
            ;;
        whiptail)
            whiptail --title "Input" --inputbox "$prompt" 10 60 "$placeholder" 3>&1 1>&2 2>&3
            ;;
        basic)
            if [ -n "$placeholder" ]; then
                read -p "$prompt [$placeholder]: " input
                echo "${input:-$placeholder}"
            else
                read -p "$prompt: " input
                echo "$input"
            fi
            ;;
    esac
}

# tui_msgbox <title> <message>
tui_msgbox() {
    local title="$1"
    local message="$2"

    case "$TUI_TOOL" in
        gum)
            gum style \
                --border double \
                --border-foreground 212 \
                --padding "1 2" \
                --margin "1" \
                "$title" "" "$message"
            sleep 2
            ;;
        dialog)
            dialog --title "$title" --msgbox "$message" 15 60
            ;;
        whiptail)
            whiptail --title "$title" --msgbox "$message" 15 60
            ;;
        basic)
            echo "╔════════════════════════════════════════════════╗"
            printf "║ %-46s ║\n" "$title"
            echo "╠════════════════════════════════════════════════╣"
            printf "║ %-46s ║\n" "$message"
            echo "╚════════════════════════════════════════════════╝"
            sleep 2
            ;;
    esac
}

# tui_spin <title> <command>
# Shows spinner while command runs (gum only, fallback to simple message)
tui_spin() {
    local title="$1"
    shift
    local command="$@"

    case "$TUI_TOOL" in
        gum)
            gum spin --spinner dot --title "$title" -- $command
            ;;
        *)
            echo "$title..."
            $command
            ;;
    esac
}

# tui_password <prompt>
# Returns: password (hidden input)
tui_password() {
    local prompt="$1"

    case "$TUI_TOOL" in
        gum)
            gum input --password --placeholder="Enter password" --prompt="$prompt: "
            ;;
        dialog)
            dialog --stdout --title "Password" --passwordbox "$prompt" 10 60
            ;;
        whiptail)
            whiptail --title "Password" --passwordbox "$prompt" 10 60 3>&1 1>&2 2>&3
            ;;
        basic)
            read -s -p "$prompt: " password
            echo
            echo "$password"
            ;;
    esac
}
