# pTTY - Status Bar Specification

**Version:** v1.0
**Date:** 2025-10-08
**Purpose:** Complete visual design and behavior of status bar

---

## Table of Contents

1. [Overview](#overview)
2. [Layout Structure](#layout-structure)
3. [Visual Design](#visual-design)
4. [Tab States](#tab-states)
5. [Responsive Behavior](#responsive-behavior)
6. [Implementation](#implementation)

---

## Overview

### Purpose

**Status bar = Persistent dashboard visible 100% of the time**

Functions:
1. **Orientation** - Show where you are (current console highlighted)
2. **Navigation** - Show what's available (F1-F12 visible)
3. **Status** - Communicate console states via icons + colors
4. **Branding** - Identify application (pTTY logo)
5. **Context** - Show user@hostname

### Design Principles

1. **Visual hierarchy** - Current tab stands out clearly
2. **Tab metaphor** - Tabs with shadows like browser tabs
3. **Connected feeling** - Current tab shares terminal background
4. **Minimal text** - Icons communicate state
5. **Responsive** - Adapts to narrow terminals

---

## Layout Structure

### Full Layout

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  pTTY │  zentala @  contabo │  F1 │  F2 │  F3 │...│ [F6-10] │  F11 Manager │  F12 Help │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Sections

**Left section (Branding + Context):**
```
│  pTTY │  zentala @  contabo │
```

**Center section (Console Tabs F1-F10):**
```
│  F1 │  F2 │  F3 │  F4 │  F5 │ [F6-10] │
```

**Right section (Special Tabs F11-F12):**
```
│  F11 Manager │  F12 Help │
```

---

## Visual Design

### Tab Anatomy

**Single tab structure:**
```
┌─────────┐
│  F1  │  ← Current tab (blue text, terminal bg, shadow)
└─────────┘▐

 ─ F2 ─     ← Adjacent tab (lighter gray bg)

 ─ F7 ─     ← Far tab (darkest gray bg)
```

### Pseudo-Shadow Effect

**How to create 3D shadow in tmux:**

```tmux
# Current tab with shadow
#[fg=colour39,bg=colour235] F1 #[default]#[fg=colour234]▐#[default]

# Explanation:
# - F1 text in blue (colour39) on terminal bg (colour235)
# - ▐ character creates vertical shadow effect
# - Shadow is dark gray (colour234) to simulate depth
```

**Visual effect:**
```
 F1▐ F2▐ F3▐
```

The `▐` character creates a subtle right-edge shadow.

### Color Gradients for Depth

**Tab background colors create gradient effect:**

```
Current tab:  bg=colour235 (terminal background - lightest)
Adjacent tab: bg=colour236 (medium gray)
Far tab:      bg=colour234 (darkest gray - status bar)
```

**Visual gradient:**
```
┌────┐     ┌────┐     ┌────┐
│ F1 │▐   │ F2 │▐   │ F3 │▐
└────┘     └────┘     └────┘
235        236        234
(lightest) (medium)   (darkest)
```

This creates illusion that current tab is "lifted" above the bar.

### Complete Visual Mockup

**With all elements:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  pTTY │  zentala @  contabo │  F1▐│ F2▐│ F3▐│ F4▐│ F5▐│ [F6-10]│  F11 Manager│  F12 Help│
└─────────────────────────────────────────────────────────────────────────────┘
```

**Legend:**
-  = Icon (Nerd Font)
- F1 = Currently selected (blue text, terminal bg)
- F2-F5 = Active consoles (white text, gradient bg)
- [F6-10] = Suspended consoles collapsed (gray text)
- F11, F12 = Special tabs (white text)

---

## Tab States

### 1. Current Console (Selected)

**Visual:**
- **Text color:** Blue (`colour39`)
- **Background:** Terminal bg (`colour235`)
- **Icon:** Same as state (Active/Suspended/Crashed) but blue
- **Shadow:** Vertical bar `▐` in dark gray

**Example:**
```tmux
#[fg=colour39,bg=colour235] F3 #[default]#[fg=colour234]▐#[default]
```

**Rendered:**
```
 F3▐
```

**Behavior:**
- Clearly stands out from other tabs
- "Connected" to terminal below (same bg color)
- User always knows which console they're in

### 2. Active Console (Not Selected)

**Visual:**
- **Text color:** White (`colour255`)
- **Background:** Gradient based on distance from current
  - Adjacent to current: `colour236` (medium gray)
  - Far from current: `colour234` (dark gray)
- **Icon:**  (play/network icon) in white
- **Shadow:** `▐` in `colour234`

**Example (adjacent):**
```tmux
#[fg=colour255,bg=colour236] F2 #[default]#[fg=colour234]▐#[default]
```

**Example (far):**
```tmux
#[fg=colour255,bg=colour234] F5 #[default]
```

**Rendered:**
```
 F2▐ ... F5
```

### 3. Suspended Console (F6-F10)

**Two display modes:**

**A) Individual (if space allows):**
```
 F6  F7  F8  F9  F10
```

**B) Collapsed (if narrow terminal):**
```
[F6-10]
```

**Visual (individual):**
- **Text color:** Gray (`colour244`)
- **Background:** Dark gray (`colour234`)
- **Icon:**  (network outline) in gray
- **Shadow:** None (dimmed appearance)

**Visual (collapsed):**
- **Text:** `[F6-10]` or `[+5]`
- **Color:** Gray (`colour244`)
- **Background:** Dark gray (`colour234`)
- **Icon:**  (single icon before text)

**Example (individual):**
```tmux
#[fg=colour244,bg=colour234] F6 #[default]
```

**Example (collapsed):**
```tmux
#[fg=colour244,bg=colour234] [F6-10] #[default]
```

### 4. Crashed Console

**Visual:**
- **Text color:** Dark red (`colour88`)
- **Background:** Same gradient as active (based on distance)
- **Icon:**  (close/error icon) in red
- **Shadow:** `▐` in `colour234`
- **Alert:** Blinks or uses different symbol (v2 feature)

**Example:**
```tmux
#[fg=colour88,bg=colour236] F4 #[default]#[fg=colour234]▐#[default]
```

**Rendered:**
```
 F4▐
```

**Behavior:**
- Immediately visible (red color stands out)
- User knows something went wrong
- Can click/switch to see crash dump

### 5. Manager & Help (F11, F12)

**Visual:**
- **Text color:** White (normal) / Blue (if selected)
- **Background:** Dark gray (`colour234`)
- **Icon:**  (Manager),  (Help)
- **Label:** "Manager", "Help" (optional, can hide in narrow terminals)

**Example (F11 normal):**
```tmux
#[fg=colour255,bg=colour234] F11 Manager #[default]
```

**Example (F11 selected):**
```tmux
#[fg=colour39,bg=colour235] F11 Manager #[default]
```

**Rendered:**
```
 F11 Manager   F12 Help
```

---

## Responsive Behavior

### Terminal Width Breakpoints

**Wide (≥120 cols):** Full layout
```
│  pTTY │  zentala @  contabo │  F1 │  F2 │...│  F10 │  F11 Manager │  F12 Help │
```

**Medium (80-119 cols):** Collapse F6-F10
```
│  pTTY │  zentala @  contabo │  F1 │...│  F5 │ [F6-10] │  F11 │  F12 │
```

**Narrow (60-79 cols):** Hide labels, collapse user/host
```
│  pTTY │ zentala@contabo │  F1 │...│  F5 │ [+5] │  F11 │  F12 │
```

**Very Narrow (<60 cols):** Minimal
```
│ pTTY │  F1 │  F2 │  F3 │  F4 │  F5 │ [+5] │  F11 │  F12 │
```

### Element Priority (What to hide first)

**Priority 1 (always show):**
- pTTY logo
- Current console (highlighted)
- F11, F12

**Priority 2 (hide if needed):**
- F11/F12 labels ("Manager", "Help")
- Username or hostname (user configurable)

**Priority 3 (hide if needed):**
- User@host entirely (if `IDENTIFIER=""` in config)

**Priority 4 (collapse if needed):**
- F6-F10 individual tabs → `[F6-10]` or `[+5]`

**Priority 5 (last resort):**
- Icons (keep text only)

### Configurable Hiding

**User config (`~/.ptty.conf`):**

```bash
# Show/hide elements
SHOW_HOSTNAME=true         # Show hostname
SHOW_USERNAME=true         # Show username
IDENTIFIER="${USER}@${HOSTNAME}"  # Custom or empty to hide entirely

# Labels
USE_FULL_NAME=false        # "PersistentTTY" vs "pTTY"
SHOW_F11_LABEL=true        # Show "Manager" text
SHOW_F12_LABEL=true        # Show "Help" text

# Suspended consoles
COLLAPSED_SUSPENDED=auto   # auto, always, never
```

**Behavior:**
- `COLLAPSED_SUSPENDED=auto`: Collapse if terminal < 120 cols
- `COLLAPSED_SUSPENDED=always`: Always show `[F6-10]`
- `COLLAPSED_SUSPENDED=never`: Always show individual F6, F7, ..., F10

---

## Implementation

### tmux Status Bar Configuration

**Main config:**

```tmux
# Status bar positioning and styling
set -g status-position bottom
set -g status-justify left
set -g status-style "bg=colour234,fg=colour255"

# Disable automatic refresh (we use static format)
set -g status-interval 0

# Status bar length
set -g status-left-length 40
set -g status-right-length 60

# Load modular status bar
source-file ~/.vps/sessions/src/status-bar.tmux
```

### Status Bar Template

**File: `src/status-bar.tmux.template`**

```tmux
# Left section: Branding + Context
set -g status-left "#[fg=${PTTY_COLOR_ACTIVE},bg=${PTTY_COLOR_BG_BAR}]${PTTY_ICON_LOGO} #{?${USE_FULL_NAME},PersistentTTY,pTTY} #[default]#[fg=${PTTY_COLOR_TEXT_NORMAL},bg=${PTTY_COLOR_BG_BAR}]│ #{?${SHOW_USERNAME},${PTTY_ICON_USER} #{user},}#{?${SHOW_HOSTNAME}, @ ${PTTY_ICON_SERVER} #{host},} #[default]"

# Center section: Console tabs (generated dynamically)
# See status-bar.sh for tab generation

# Right section: F11 Manager + F12 Help
set -g status-right "#[fg=${PTTY_COLOR_TEXT_NORMAL},bg=${PTTY_COLOR_BG_BAR}]│ ${PTTY_ICON_MANAGER} F11#{?${SHOW_F11_LABEL}, Manager,} #[default] #[fg=${PTTY_COLOR_TEXT_NORMAL},bg=${PTTY_COLOR_BG_BAR}]${PTTY_ICON_HELP} F12#{?${SHOW_F12_LABEL}, Help,} #[default]"
```

### Dynamic Tab Generation

**File: `src/status-bar.sh`**

```bash
#!/bin/bash
# Generate console tabs dynamically based on state

# Load theme
source ~/.vps/sessions/themes/${THEME}.sh
source ~/.ptty.conf

# Get current console number
CURRENT=$(tmux display-message -p '#{session_name}' | grep -oP 'console-\K\d+')

# Get terminal width
TERM_WIDTH=$(tmux display-message -p '#{client_width}')

# Determine if we should collapse F6-F10
if [ "$COLLAPSED_SUSPENDED" = "auto" ]; then
  if [ "$TERM_WIDTH" -lt 120 ]; then
    COLLAPSE=true
  else
    COLLAPSE=false
  fi
elif [ "$COLLAPSED_SUSPENDED" = "always" ]; then
  COLLAPSE=true
else
  COLLAPSE=false
fi

# Build tabs string
TABS=""

# Active consoles (F1-F5)
for i in {1..5}; do
  STATE=$(get_console_state $i)

  if [ "$i" = "$CURRENT" ]; then
    # Current console (blue, terminal bg, shadow)
    COLOR="${PTTY_COLOR_SELECTED}"
    BG="${PTTY_COLOR_BG_TERM}"
    SHADOW="#[fg=${PTTY_COLOR_BG_BAR}]▐#[default]"
  else
    # Active but not current
    COLOR="${PTTY_COLOR_ACTIVE}"
    # Calculate distance for gradient
    DIST=$((i - CURRENT))
    [ $DIST -lt 0 ] && DIST=$((-DIST))
    if [ $DIST -eq 1 ]; then
      BG="${PTTY_COLOR_BG_TAB}"  # Adjacent
    else
      BG="${PTTY_COLOR_BG_BAR}"  # Far
    fi
    SHADOW="#[fg=${PTTY_COLOR_BG_BAR}]▐#[default]"
  fi

  case $STATE in
    "crashed")
      ICON="${PTTY_ICON_CRASHED}"
      COLOR="${PTTY_COLOR_CRASHED}"
      ;;
    "active")
      ICON="${PTTY_ICON_ACTIVE}"
      ;;
    *)
      ICON="${PTTY_ICON_ACTIVE}"
      ;;
  esac

  TABS+="#[fg=${COLOR},bg=${BG}]${ICON} F${i} #[default]${SHADOW}"
done

# Suspended consoles (F6-F10)
if [ "$COLLAPSE" = true ]; then
  # Collapsed view
  TABS+="#[fg=${PTTY_COLOR_SUSPENDED},bg=${PTTY_COLOR_BG_BAR}]${PTTY_ICON_SUSPENDED} [F6-10] #[default]"
else
  # Individual tabs
  for i in {6..10}; do
    if console_exists $i; then
      # If activated, show as active
      ICON="${PTTY_ICON_ACTIVE}"
      COLOR="${PTTY_COLOR_ACTIVE}"
    else
      # Suspended
      ICON="${PTTY_ICON_SUSPENDED}"
      COLOR="${PTTY_COLOR_SUSPENDED}"
    fi

    if [ "$i" = "$CURRENT" ]; then
      COLOR="${PTTY_COLOR_SELECTED}"
      BG="${PTTY_COLOR_BG_TERM}"
    else
      BG="${PTTY_COLOR_BG_BAR}"
    fi

    TABS+="#[fg=${COLOR},bg=${BG}]${ICON} F${i} #[default]"
  done
fi

# Write tabs to tmux config
tmux set-option -g status-center "$TABS"
```

### Auto-Update Status Bar

**On console state change:**

```bash
# When console crashes/restarts/activates, refresh status bar
tmux refresh-client -S
```

**Polling method (v1):**
- Status bar refreshes every 5 seconds (`status-interval 5`)
- Detects state changes and updates colors/icons

**Event-driven method (v3):**
- tmux hooks trigger refresh on state change
- Instant updates, no polling overhead

---

## Edge Cases

### 1. More than 10 consoles (v3)

**Not supported in v1/v2.** Max 10 consoles (F1-F10).

In v3, if we allow custom consoles beyond F10:
- Status bar shows scrollable list
- Or shows only recent/pinned consoles
- Requires redesign

### 2. Very long hostname/username

**Problem:** `zentala@very-long-hostname-example.com` overflows

**Solution:**
- Truncate hostname: `zentala@very-long-hos...`
- Or allow user to set custom identifier: `IDENTIFIER="VPS1"`

**Config option:**
```bash
# Custom short identifier
IDENTIFIER="VPS1"  # Instead of "zentala@very-long-hostname"
```

### 3. Terminal with no color support

**Fallback:**
- No background colors
- Use bold for current console
- Use symbols instead of colors

**Example:**
```
[ pTTY | zentala@contabo | *F1* | F2 | F3 | [F6-10] | F11 Manager | F12 Help ]
```

(`*F1*` = current, bold)

### 4. Mouse click on tab (v2/v3)

**Behavior:**
- User clicks on "F3" in status bar
- Switches to console F3

**Implementation:**
```tmux
# Enable mouse support
set -g mouse on

# Bind mouse click on status bar to switch console
# (Complex, requires mapping click position to console number)
# Deferred to v3
```

---

## Testing Checklist

### Visual Tests

- [ ] Current console clearly highlighted (blue text, terminal bg)
- [ ] Tabs have visible shadow effect (`▐` character)
- [ ] Active consoles show play icon ()
- [ ] Suspended consoles show network outline icon ()
- [ ] Crashed consoles show red X icon ()
- [ ] Gradient bg creates depth (current > adjacent > far)
- [ ] F11 and F12 visible on right side
- [ ] Icons align correctly (no spacing issues)

### Responsive Tests

- [ ] Wide terminal (120+ cols): All tabs individual
- [ ] Medium terminal (80-119 cols): F6-F10 collapsed
- [ ] Narrow terminal (60-79 cols): Labels hidden
- [ ] Very narrow (<60 cols): Minimal layout, still readable

### State Tests

- [ ] Switch between consoles → highlight updates
- [ ] Crash console → red icon appears
- [ ] Restart console → icon changes from red to white
- [ ] Activate suspended console → icon changes to active
- [ ] All 10 consoles active → no overflow

### Config Tests

- [ ] `SHOW_HOSTNAME=false` → hostname hidden
- [ ] `SHOW_USERNAME=false` → username hidden
- [ ] `IDENTIFIER=""` → entire user@host section hidden
- [ ] `SHOW_F11_LABEL=false` → "Manager" text hidden, icon remains
- [ ] `SHOW_F12_LABEL=false` → "Help" text hidden, icon remains
- [ ] `USE_FULL_NAME=true` → "PersistentTTY" instead of "pTTY"
- [ ] `COLLAPSED_SUSPENDED=always` → [F6-10] even in wide terminal

---

## Related Documentation

- **GLOSSARY.md:** Color scheme reference
- **ICONS-SPEC.md:** Icon definitions and theme system
- **MANAGER-SPEC.md:** How Manager interacts with status bar
- **FUTURE-VISION.md:** v2/v3 status bar enhancements

---

**END OF STATUS BAR SPECIFICATION**

Status bar is the primary UI - must be perfect!
All changes to status bar MUST reference this spec.
All new features MUST consider impact on status bar layout.
