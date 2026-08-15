# pTTY - Icons Specification

**Version:** v1.0
**Date:** 2025-10-08
**Purpose:** Icon mapping, theme system, and visual identity

---

## Table of Contents

1. [Icon Philosophy](#icon-philosophy)
2. [Icon Mapping](#icon-mapping)
3. [Theme System](#theme-system)
4. [Fallback Strategy](#fallback-strategy)
5. [Implementation](#implementation)

---

## Icon Philosophy

### Network Icon Theme

**Why network icons?**
- pTTY is designed for remote SSH sessions
- Network theme emphasizes connectivity and persistence
- Consistent visual metaphor: terminals = network nodes
- All icons from Nerd Fonts Material Design network set

**Design principles:**
1. **Icon communicates state** - No text needed
2. **Color reinforces meaning** - White=active, Gray=suspended, Red=crashed
3. **Consistency** - Same icon family throughout UI
4. **Fallback gracefully** - ASCII/Unicode if no Nerd Fonts

---

## Icon Mapping

### Console State Icons

#### Active Console

**Icon:** `` (nf-md-play_network)
**Code:** `\uf08a9` or `f08a9`
**Color:** White (`colour255`)
**Meaning:** Console is running and operational
**Usage:** Status bar, Manager list
**Fallback:** `▶` (unicode) or `>` (ASCII)

**Visual example:**
```
Status bar:  F1  F2  F3
Manager:     [•] F1 (Active)
```

#### Suspended Console

**Icon:** `` (nf-md-network_outline)
**Code:** `\uf0c9d` or `f0c9d`
**Color:** Gray (`colour244`)
**Meaning:** Console not created yet, available on demand
**Usage:** Status bar (F6-F10), Manager list
**Fallback:** `○` (unicode) or `-` (ASCII)

**Visual example:**
```
Status bar:  F6  F7
Manager:     [○] F6 (Suspended)
```

#### Crashed Console

**Icon:** `` (nf-md-close_network_outline)
**Code:** `\uf0c5f` or `f0c5f`
**Color:** Dark Red (`colour88`)
**Meaning:** Console died unexpectedly
**Usage:** Status bar, Manager list
**Fallback:** `✗` (unicode) or `X` (ASCII)

**Visual example:**
```
Status bar:  F3
Manager:     [✗] F3 (Crashed)
```

#### Selected Console (Current)

**Icon:** Same as state (Active/Suspended/Crashed)
**Code:** (same)
**Color:** Blue (`colour39`)
**Meaning:** Console user is currently in
**Usage:** Status bar (highlighted tab), Manager (highlighted row)
**Fallback:** Same icon, blue color

**Visual example:**
```
Status bar:  F1  F2  F3  (F2 is blue = selected)
Manager:     [•] F2 (Active) ← highlighted in blue
```

---

### Special Element Icons

#### pTTY Logo/Branding

**Icon:** `` (nf-md-console_network_outline)
**Code:** `\uf0c60` or `f0c60`
**Color:** White (`colour255`)
**Meaning:** Application identifier
**Usage:** Status bar left side
**Fallback:** `[TTY]` (ASCII) or `⌨` (unicode)

**Visual example:**
```
Status bar:  pTTY
```

#### Server/Hostname

**Icon:** `` (nf-md-server_network)
**Code:** `\uf048d` or `f048d`
**Color:** White (`colour255`)
**Meaning:** Server hostname
**Usage:** Status bar user@host section
**Fallback:** `@` (ASCII) or `⚙` (unicode)

**Visual example:**
```
Status bar:  zentala @  contabo
```

#### Username

**Icon:** `` (nf-md-account_network_outline)
**Code:** `\uf0be6` or `f0be6`
**Color:** White (`colour255`)
**Meaning:** Logged-in user
**Usage:** Status bar user@host section
**Fallback:** `$` (ASCII) or `👤` (unicode)

**Visual example:**
```
Status bar:  zentala @  contabo
```

#### Manager (F11)

**Icon:** `` (nf-md-table_network)
**Code:** `\uf13c9` or `f13c9`
**Alternative:** `` (nf-md-network_pos - f1acb)
**Color:** White (normal) / Blue (selected)
**Meaning:** Console management interface
**Usage:** Status bar F11 tab, Manager header
**Fallback:** `[M]` (ASCII) or `☰` (unicode)

**Visual example:**
```
Status bar:  F11 Manager
Manager header: 󰓉 PersistentTTY Manager
```

#### Help (F12)

**Icon:** `` (nf-md-help_network_outline)
**Code:** `\uf0c8a` or `f0c8a`
**Color:** White (normal) / Blue (selected)
**Meaning:** Keyboard shortcuts reference
**Usage:** Status bar F12 tab, Help header
**Fallback:** `[?]` (ASCII) or `?` (unicode)

**Visual example:**
```
Status bar:  F12 Help
Help header:  Keyboard Shortcuts Reference
```

---

### Action Icons (v2/v3)

These icons will be used in Manager action menus in future versions:

| Action | Icon | Code | Color | Fallback |
|--------|------|------|-------|----------|
| **Attach/Enter** |  | f0c60 | White | `→` or `>` |
| **Activate** |  | f041a | Green | `+` or `*` |
| **Restart** |  | f0c9b | Yellow | `↻` or `R` |
| **Kill** |  | f0c5f | Red | `✗` or `X` |
| **Settings** |  | f0484 | White | `⚙` or `S` |

**Note:** v1 doesn't show action icons, only text. Icons added in v2.

---

## Theme System

### Theme Architecture

**Purpose:** Allow users to customize icons and colors without modifying core code

**Implementation:**
- Theme = Shell script with exported variables
- Located in `~/.vps/sessions/themes/`
- User selects theme in `~/.ptty.conf`
- `apply-theme.sh` loads theme and generates config

### Theme File Structure

**Location:** `~/.vps/sessions/themes/(theme-name).sh`

**Example: `themes/default.sh`**
```bash
#!/bin/bash
# pTTY Theme: Default
# Network-themed icons with standard colors

# === ICONS ===
# Console States
export PTTY_ICON_ACTIVE=""        # nf-md-play_network
export PTTY_ICON_SUSPENDED=""     # nf-md-network_outline
export PTTY_ICON_CRASHED=""       # nf-md-close_network_outline

# Special Elements
export PTTY_ICON_LOGO=""          # nf-md-console_network_outline
export PTTY_ICON_SERVER=""        # nf-md-server_network
export PTTY_ICON_USER=""          # nf-md-account_network_outline
export PTTY_ICON_MANAGER=""       # nf-md-table_network
export PTTY_ICON_HELP=""          # nf-md-help_network_outline

# === COLORS ===
# Console States
export PTTY_COLOR_ACTIVE="colour255"      # White
export PTTY_COLOR_SELECTED="colour39"     # Blue
export PTTY_COLOR_SUSPENDED="colour244"   # Gray
export PTTY_COLOR_CRASHED="colour88"      # Dark Red

# UI Elements
export PTTY_COLOR_BG_BAR="colour234"      # Status bar background (dark gray)
export PTTY_COLOR_BG_TERM="colour235"     # Terminal background
export PTTY_COLOR_BG_TAB="colour236"      # Tab background (between terminal and bar)
export PTTY_COLOR_TEXT_NORMAL="colour255" # Normal text (white)
export PTTY_COLOR_TEXT_DIM="colour244"    # Dimmed text (gray)

# === FALLBACK ICONS (if USE_NERD_FONTS=false) ===
export PTTY_FALLBACK_ACTIVE="▶"
export PTTY_FALLBACK_SUSPENDED="○"
export PTTY_FALLBACK_CRASHED="✗"
export PTTY_FALLBACK_LOGO="[TTY]"
export PTTY_FALLBACK_SERVER="@"
export PTTY_FALLBACK_USER="$"
export PTTY_FALLBACK_MANAGER="[M]"
export PTTY_FALLBACK_HELP="[?]"
```

### Built-in Themes

#### 1. Default Theme (`themes/default.sh`)
- Network icons
- Standard colors: White, Blue, Gray, Dark Red
- Designed for dark terminals

#### 2. Dark Theme (`themes/dark.sh`) - v2
- Same icons as default
- Darker colors for AMOLED/dark mode
- Higher contrast

#### 3. Light Theme (`themes/light.sh`) - v2
- Same icons as default
- Inverted colors for light terminals
- Dark icons on light background

### Creating Custom Themes

**User workflow:**
1. Copy existing theme: `cp ~/.vps/sessions/themes/default.sh ~/.vps/sessions/themes/mytheme.sh`
2. Edit `mytheme.sh` - change icons and colors
3. Update config: `THEME="mytheme"` in `~/.ptty.conf`
4. Reload config: `ptty config reload` (v2) or restart tmux (v1)

**Icon customization:**
- User can pick ANY Nerd Font icon
- Browse icons at: https://www.nerdfonts.com/cheat-sheet
- Copy icon code (e.g., `f0c60`) and paste in theme
- Icon must be surrounded by `` in theme file

**Example custom theme:**
```bash
# themes/minimal.sh - Minimal theme with symbols instead of network icons
export PTTY_ICON_ACTIVE=""     # Circle (different set)
export PTTY_ICON_SUSPENDED=""  # Empty circle
export PTTY_ICON_CRASHED=""    # X mark
export PTTY_ICON_LOGO=""       # Laptop
# ... etc
```

---

## Fallback Strategy

### When Fallback Activates

**Conditions:**
1. User sets `USE_NERD_FONTS=false` in `~/.ptty.conf`
2. Nerd Fonts not installed (auto-detected - v2 feature)
3. Terminal doesn't support font icons (rare)

### Fallback Icon Set

**Console States:**
```
Active:     ▶  (unicode) or >  (ASCII)
Suspended:  ○  (unicode) or -  (ASCII)
Crashed:    ✗  (unicode) or X  (ASCII)
```

**UI Elements:**
```
pTTY:       [TTY] (ASCII) or ⌨  (unicode)
Server:     @     (ASCII) or ⚙  (unicode)
User:       $     (ASCII) or 👤 (unicode)
Manager:    [M]   (ASCII) or ☰  (unicode)
Help:       [?]   (ASCII) or ?  (unicode)
```

### Fallback Visual Example

**Status bar with Nerd Fonts:**
```
┌─  pTTY ─┬─  zentala @  contabo ─┬─────────────────────────┐
│  F1 │  F2 │  F3 │...│  F11 Manager │  F12 Help │
```

**Status bar without Nerd Fonts (unicode):**
```
┌─ [TTY] ─┬─ $ zentala @ ⚙ contabo ─┬─────────────────────────┐
│ ▶ F1 │ ▶ F2 │ ▶ F3 │...│ ☰ F11 Manager │ ? F12 Help │
```

**Status bar without Nerd Fonts (ASCII only):**
```
┌─ [TTY] ─┬─ $ zentala @ @ contabo ─┬─────────────────────────┐
│ > F1 │ > F2 │ > F3 │...│ [M] F11 Manager │ [?] F12 Help │
```

### Fallback Behavior

**Priority:**
1. **Nerd Fonts** (best, full icon support)
2. **Unicode** (good, common symbols)
3. **ASCII** (minimal, always works)

**Auto-detection (v2):**
```bash
# Detect if Nerd Fonts available
if fc-list | grep -q "Nerd Font"; then
  USE_NERD_FONTS=true
else
  USE_NERD_FONTS=false
  echo "Warning: Nerd Fonts not detected, using fallback icons"
fi
```

**v1 behavior:** User manually sets `USE_NERD_FONTS` in config

---

## Implementation

### Icon Variables in Code

**How icons are used:**

**1. In tmux config template (`src/tmux.conf.template`):**
```tmux
# Status bar with theme variables
set -g status-left "#[fg=${PTTY_COLOR_ACTIVE}]${PTTY_ICON_LOGO} pTTY"

# Console tabs (generated dynamically)
#[fg=${PTTY_COLOR_ACTIVE}]${PTTY_ICON_ACTIVE} F1
#[fg=${PTTY_COLOR_SUSPENDED}]${PTTY_ICON_SUSPENDED} F6
```

**2. In status bar generation script (`src/status-bar.sh`):**
```bash
#!/bin/bash
# Load theme
source ~/.vps/sessions/themes/${THEME}.sh

# Build status bar
STATUS_LEFT="${PTTY_ICON_LOGO} pTTY"
STATUS_RIGHT="${PTTY_ICON_MANAGER} F11 Manager  ${PTTY_ICON_HELP} F12 Help"

# Console tabs
for i in {1..10}; do
  if console_is_active $i; then
    ICON="${PTTY_ICON_ACTIVE}"
    COLOR="${PTTY_COLOR_ACTIVE}"
  elif console_is_suspended $i; then
    ICON="${PTTY_ICON_SUSPENDED}"
    COLOR="${PTTY_COLOR_SUSPENDED}"
  elif console_is_crashed $i; then
    ICON="${PTTY_ICON_CRASHED}"
    COLOR="${PTTY_COLOR_CRASHED}"
  fi

  # If current console, use selected color
  if [ "$i" = "$CURRENT_CONSOLE" ]; then
    COLOR="${PTTY_COLOR_SELECTED}"
  fi

  TABS+="#[fg=${COLOR}]${ICON} F${i} "
done
```

**3. In Manager UI (`src/manager-menu.sh`):**
```bash
#!/bin/bash
# Load theme
source ~/.vps/sessions/themes/${THEME}.sh

# Console list with icons
for i in {1..12}; do
  STATE=$(get_console_state $i)

  case $STATE in
    "active")
      ICON="${PTTY_ICON_ACTIVE}"
      STATUS="Active"
      ;;
    "suspended")
      ICON="${PTTY_ICON_SUSPENDED}"
      STATUS="Suspended"
      ;;
    "crashed")
      ICON="${PTTY_ICON_CRASHED}"
      STATUS="Crashed"
      ;;
  esac

  echo "${ICON} F${i} (${STATUS})"
done | gum choose
```

### Theme Loading Sequence

**On tmux startup:**

1. Read `~/.ptty.conf` → get `THEME` variable
2. Source `~/.vps/sessions/themes/${THEME}.sh` → load icon/color variables
3. Run `src/apply-theme.sh`:
   - Read `src/tmux.conf.template`
   - Substitute `${PTTY_*}` variables
   - Write final `src/tmux.conf`
4. tmux loads `src/tmux.conf`
5. Status bar displays with theme icons/colors

**On theme change (v2):**

```bash
# User runs: ptty theme set dark
ptty config reload  # Re-runs apply-theme.sh and reloads tmux
```

### Icon Rendering in tmux

**tmux icon display:**
```tmux
# Icon with color
#[fg=colour39] #[default]

# Icon without Nerd Fonts (fallback)
#[fg=colour39]▶#[default]
```

**Color codes:**
- `colour39` = Blue
- `colour255` = White
- `colour244` = Gray
- `colour88` = Dark Red
- `colour234` = Dark Gray (bg)

---

## Icon Usage Guidelines

### DO:
✅ Use network-themed icons for consistency
✅ Use color to reinforce meaning (white=active, gray=suspended, red=crashed)
✅ Provide fallback icons for all states
✅ Keep icon size consistent (single character width)
✅ Test icons in actual terminal (not just in docs)

### DON'T:
❌ Mix icon families (e.g., network + file icons)
❌ Use color alone without icon (accessibility)
❌ Use icons that don't render in common terminals
❌ Hardcode icons in scripts (use variables)
❌ Forget fallback for non-NF users

---

## Testing Icon Display

**Test command:**
```bash
# Test Nerd Font icons in terminal
echo " Active   Suspended   Crashed"
echo " pTTY   Manager   Help"
echo " User   Server"
```

**Expected output (with Nerd Fonts):**
```
 Active   Suspended   Crashed
 pTTY   Manager   Help
 User   Server
```

**If icons don't display:** Nerd Fonts not installed or terminal doesn't support them

**Install Nerd Fonts:**
```bash
# Download and install a Nerd Font (e.g., JetBrainsMono Nerd Font)
# https://www.nerdfonts.com/font-downloads
```

---

## Related Documentation

- **GLOSSARY.md:** Icon reference table
- **STATUS-BAR-SPEC.md:** How icons appear in status bar
- **MANAGER-SPEC.md:** How icons appear in Manager UI
- **FUTURE-VISION.md:** v2/v3 icon enhancements (action icons, animations)

---

**END OF ICONS SPECIFICATION**

All icons MUST use theme variables.
All new icons MUST have fallback defined.
All theme changes MUST update theme files, not core code.
