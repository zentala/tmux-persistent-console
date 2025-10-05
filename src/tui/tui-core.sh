#!/bin/bash
# tui-core.sh - TUI tool detection and core functionality

# Global variables for tool availability
TUI_TOOL=""
TUI_HAS_GUM=false
TUI_HAS_FZF=false
TUI_HAS_WHIPTAIL=false
TUI_HAS_DIALOG=false

# Detect available TUI tools
_tui_detect() {
    command -v gum >/dev/null 2>&1 && TUI_HAS_GUM=true
    command -v fzf >/dev/null 2>&1 && TUI_HAS_FZF=true
    command -v whiptail >/dev/null 2>&1 && TUI_HAS_WHIPTAIL=true
    command -v dialog >/dev/null 2>&1 && TUI_HAS_DIALOG=true

    # Priority order: gum > fzf > dialog > whiptail > basic
    if $TUI_HAS_GUM; then
        TUI_TOOL="gum"
    elif $TUI_HAS_FZF; then
        TUI_TOOL="fzf"
    elif $TUI_HAS_DIALOG; then
        TUI_TOOL="dialog"
    elif $TUI_HAS_WHIPTAIL; then
        TUI_TOOL="whiptail"
    else
        TUI_TOOL="basic"
    fi

    export TUI_TOOL TUI_HAS_GUM TUI_HAS_FZF TUI_HAS_WHIPTAIL TUI_HAS_DIALOG
}

# Get TUI tool info
tui_info() {
    echo "TUI Tool: $TUI_TOOL"
    echo "Available:"
    $TUI_HAS_GUM && echo "  ✓ gum"
    $TUI_HAS_FZF && echo "  ✓ fzf"
    $TUI_HAS_DIALOG && echo "  ✓ dialog"
    $TUI_HAS_WHIPTAIL && echo "  ✓ whiptail"
    [ "$TUI_TOOL" = "basic" ] && echo "  ✓ basic (fallback)"
}

# Run detection on source
_tui_detect
