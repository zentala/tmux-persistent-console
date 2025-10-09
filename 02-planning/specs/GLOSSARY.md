# pTTY - Glossary & Unified Terminology

**Version:** v1.0
**Date:** 2025-10-08
**Purpose:** Single source of truth for terminology, shortcuts, and icons

---

## Table of Contents

1. [Core Terminology](#core-terminology)
2. [Console States](#console-states)
3. [Actions & Operations](#actions--operations)
4. [Keyboard Shortcuts](#keyboard-shortcuts)
5. [Icon Reference](#icon-reference)
6. [Color Scheme](#color-scheme)

---

## Core Terminology

### Console vs Terminal vs Session

**Console** = Persistent tmux session (console-1, console-2, etc.)
- User-facing term: "Console F1", "Console F3"
- Technical term: tmux session named `console-N`
- Persists across SSH disconnections
- Can be Active, Suspended, or Crashed

**Terminal** = Physical terminal emulator window
- The actual SSH session/window user connects from
- Can disconnect and reconnect to consoles

**Session** = tmux concept (same as Console in our context)
- We use "console" for user-facing communication
- "session" appears in technical docs and code

**Usage examples:**
- ✅ "Switch to Console F3"
- ✅ "Restart Console F7"
- ❌ "Restart Terminal F7" (terminal is the SSH window, not the console)

### Special Consoles

**Manager (F11)** = Console management interface
- tmux session named `manager`
- Interactive TUI for managing all consoles
- Cannot be killed (only detached)

**Help (F12)** = Keyboard shortcuts reference
- tmux session named `help`
- Static text display
- Cannot be killed (only detached)

---

## Console States

### Active
**Definition:** Console is created and running
**Visual:** White icon + text, F-key number visible in status bar
**Icon:** `` (nf-md-play_network)
**Color:** White (`colour255`)
**Behavior:** Can attach, restart, or kill

### Suspended
**Definition:** Console is not created yet (F6-F10 by default)
**Visual:** Gray icon + text
**Icon:** `` (nf-md-network_outline)
**Color:** Gray (`colour244`)
**Behavior:** Can activate (create and attach)

### Selected (Current)
**Definition:** Console user is currently in
**Visual:** Blue icon + text, background matches terminal
**Icon:** Same as state (Active/Suspended/Crashed)
**Color:** Blue (`colour39`)
**Behavior:** Highlighted in status bar, marked in Manager

### Crashed
**Definition:** Console died unexpectedly (process exited with error)
**Visual:** Dark red icon + text
**Icon:** `` (nf-md-close_network_outline)
**Color:** Dark red (`colour88`)
**Behavior:** Shows crash dump path, can restart

---

## Actions & Operations

### Navigation Actions

**Switch**
- **Meaning:** Change from current console to another console
- **How:** Ctrl+F(n), or select in Manager + Enter
- **Result:** Leave current console, enter target console
- **Alias:** "Go to", "Jump to"

**Attach**
- **Meaning:** Connect to an already-active console
- **How:** Select console in Manager + Enter
- **Result:** Enter the console (tmux attach)
- **Usage:** For Active consoles only
- **Note:** Same as "Switch" but used in Manager context

**Activate**
- **Meaning:** Create and attach to a suspended console
- **How:** Press F6-F10 (suspended), confirm → OR select in Manager + Enter
- **Result:** Console is created and user enters it
- **Usage:** For Suspended consoles only

**Detach**
- **Meaning:** Leave current console but keep it running
- **How:** Ctrl+Esc (new), or Ctrl+b d (traditional)
- **Result:** Return to last console, current console stays alive
- **Alias:** "Disconnect safely"

### Modification Actions

**Restart**
- **Meaning:** Kill console and immediately recreate it
- **How:** Select console in Manager, arrow right → Restart, Enter, confirm
- **Result:** Console destroyed, new empty console created
- **Requires:** Confirmation (prevent accidents)
- **Alias:** "Reset", "Recreate"

**Kill**
- **Meaning:** Permanently destroy console (v1: same as Restart)
- **How:** (v1: Not separate action, Restart does this)
- **Result:** Console destroyed
- **Note:** In v1, we only have "Restart" which kills and recreates

### Management Actions

**Rename** (v2/v3)
- **Meaning:** Change console custom name
- **How:** Manager → Rename action
- **Result:** Console shows custom name in Manager and status bar

**Configure** (v2/v3)
- **Meaning:** Set console-specific settings (auto-start script, icon, etc.)
- **How:** Config file or Manager → Configure
- **Result:** Console has custom behavior

---

## Keyboard Shortcuts

### Primary Shortcuts (Always Available)

| Shortcut | Action | Context | Description |
|----------|--------|---------|-------------|
| **Ctrl+F1** | Switch to Console 1 | Anywhere | Jump to console-1 |
| **Ctrl+F2** | Switch to Console 2 | Anywhere | Jump to console-2 |
| **Ctrl+F3** | Switch to Console 3 | Anywhere | Jump to console-3 |
| **Ctrl+F4** | Switch to Console 4 | Anywhere | Jump to console-4 |
| **Ctrl+F5** | Switch to Console 5 | Anywhere | Jump to console-5 |
| **Ctrl+F6** | Switch/Activate Console 6 | Anywhere | Activate if suspended, switch if active |
| **Ctrl+F7** | Switch/Activate Console 7 | Anywhere | Activate if suspended, switch if active |
| **Ctrl+F8** | Switch/Activate Console 8 | Anywhere | Activate if suspended, switch if active |
| **Ctrl+F9** | Switch/Activate Console 9 | Anywhere | Activate if suspended, switch if active |
| **Ctrl+F10** | Switch/Activate Console 10 | Anywhere | Activate if suspended, switch if active |
| **Ctrl+F11** | Open Manager | Anywhere | Open console management interface |
| **Ctrl+F12** | Open Help | Anywhere | Open keyboard shortcuts reference |

### Navigation Shortcuts

| Shortcut | Action | Context | Description |
|----------|--------|---------|-------------|
| **Ctrl+Left** | Previous Console | Anywhere | Navigate backwards through consoles |
| **Ctrl+Right** | Next Console | Anywhere | Navigate forwards through consoles |
| **Ctrl+Esc** | Detach | In console | Leave console, return to last console |
| **Ctrl+H** | Shortcuts Popup | Anywhere | Quick reference popup (right side, vertical) |
| **Ctrl+?** | Shortcuts Popup | Anywhere | Same as Ctrl+H |

### Action Shortcuts

| Shortcut | Action | Context | Description |
|----------|--------|---------|-------------|
| **Ctrl+R** | Restart Current Console | In console | Restart with confirmation popup |
| **Ctrl+Del** | Restart Current Console | In console | Same as Ctrl+R (new shortcut) |
| **Ctrl+Alt+R** | Reset Terminal | In console | Clear and reset current terminal |

### Manager (F11) Shortcuts

| Shortcut | Action | Context | Description |
|----------|--------|---------|-------------|
| **↑ / ↓** | Navigate Consoles | Manager | Move up/down console list |
| **→** | Select Action | Manager (console selected) | Move to action submenu (Restart) |
| **←** | Back to Console List | Manager (action selected) | Return from action submenu |
| **Enter** | Execute | Manager | Attach/Activate (default) or confirm action |
| **Del** | Restart | Manager (console selected) | Same as → Restart + Enter |
| **Esc** | Go Back / Exit | Manager | Exit submenu → exit Manager → last console |
| **Ctrl+C** | Exit Submenu | Manager (in submenu) | Return to console list |
| **F1-F10** | (Do nothing) | Manager | Reserved for system/user (not used by Manager) |
| **F11** | (Do nothing) | Manager | Already in Manager |
| **F12** | (Visible in list) | Manager | Help console visible, can select + Enter |

### Traditional tmux Shortcuts (Backup)

| Shortcut | Action | Context | Description |
|----------|--------|---------|-------------|
| **Ctrl+b, s** | Session List | Anywhere | Visual tmux session chooser |
| **Ctrl+b, 1-9** | Switch Console 1-9 | Anywhere | Traditional console switching |
| **Ctrl+b, 0** | Switch Console 10 | Anywhere | Console 10 (0 key) |
| **Ctrl+b, (** | Previous Session | Anywhere | Navigate backwards |
| **Ctrl+b, )** | Next Session | Anywhere | Navigate forwards |
| **Ctrl+b, L** | Last Session | Anywhere | Toggle last used session |
| **Ctrl+b, d** | Detach | Anywhere | Traditional detach |

---

## Icon Reference

### Console State Icons

| State | Icon | Unicode | Color | Nerd Font Code |
|-------|------|---------|-------|----------------|
| **Active** |  | `` | White | `nf-md-play_network` (f08a9) |
| **Suspended** |  | `` | Gray | `nf-md-network_outline` (f0c9d) |
| **Crashed** |  | `` | Dark Red | `nf-md-close_network_outline` (f0c5f) |
| **Selected** | (same as state) | (same) | Blue | (same icon, different color) |

### Special Icons

| Element | Icon | Unicode | Color | Nerd Font Code |
|---------|------|---------|-------|----------------|
| **pTTY Logo** |  | `` | White | `nf-md-console_network_outline` (f0c60) |
| **Manager (F11)** |  | `` | White/Blue | `nf-md-table_network` (f13c9) |
| **Help (F12)** |  | `` | White/Blue | `nf-md-help_network_outline` (f0c8a) |
| **Server/Hostname** |  | `` | White | `nf-md-server_network` (f048d) |
| **Username** |  | `` | White | `nf-md-account_network_outline` (f0be6) |

### Action Icons (v2/v3)

| Action | Icon | Unicode | Description |
|--------|------|---------|-------------|
| **Attach/Enter** |  | `` | Enter console |
| **Activate** |  | `` | Create suspended console |
| **Restart** |  | `` | Kill and recreate |
| **Kill** |  | `` | Destroy permanently |

### Fallback Icons (No Nerd Fonts)

| Element | ASCII Fallback | Unicode Fallback |
|---------|----------------|------------------|
| **Active** | `>` | `▶` |
| **Suspended** | `-` | `○` |
| **Crashed** | `X` | `✗` |
| **pTTY Logo** | `[TTY]` | `⌨` |
| **Manager** | `[M]` | `☰` |
| **Help** | `[?]` | `?` |
| **Server** | `@` | `⚙` |
| **User** | `$` | `👤` |

**Note:** Fallback icons used when `USE_NERD_FONTS=false` in config.

---

## Color Scheme

### Console States

| State | Foreground | Background | tmux Color Code |
|-------|------------|------------|-----------------|
| **Active (normal)** | White | Transparent | `fg=colour255,bg=default` |
| **Active (selected)** | Blue | Terminal BG | `fg=colour39,bg=colour235` |
| **Suspended** | Gray | Transparent | `fg=colour244,bg=default` |
| **Crashed** | Dark Red | Transparent | `fg=colour88,bg=default` |

### Status Bar Elements

| Element | Foreground | Background | Description |
|---------|------------|------------|-------------|
| **pTTY Branding** | White | Dark Gray | `fg=colour255,bg=colour234` |
| **User@Host** | White | Dark Gray | `fg=colour250,bg=colour234` |
| **Current Console Tab** | Blue | Terminal BG | `fg=colour39,bg=colour235` |
| **Adjacent Tab** | Light Gray | Medium Gray | `fg=colour250,bg=colour236` |
| **Far Tab** | Gray | Dark Gray | `fg=colour244,bg=colour234` |
| **F11 Manager** | White | Dark Gray | `fg=colour255,bg=colour234` |
| **F12 Help** | White | Dark Gray | `fg=colour255,bg=colour234` |

### Manager (F11) Colors

| Element | Color | Description |
|---------|-------|-------------|
| **Header** | Bold White | "PersistentTTY Manager" title |
| **Console (active)** | White | Normal active console |
| **Console (selected)** | Blue | Currently highlighted console |
| **Console (suspended)** | Gray | Inactive console |
| **Console (crashed)** | Dark Red | Crashed console |
| **Action (default)** | White | Default action (Attach/Activate) |
| **Action (destructive)** | Red | Restart action (requires confirmation) |
| **Confirmation (cancel)** | White/Green | Cancel button (default selected) |
| **Confirmation (confirm)** | Red | Confirm destructive action |

### Theme Variables

These colors are defined in theme files (`themes/default.sh`):

```bash
# Default theme
export PTTY_COLOR_ACTIVE="colour255"      # White
export PTTY_COLOR_SELECTED="colour39"     # Blue
export PTTY_COLOR_SUSPENDED="colour244"   # Gray
export PTTY_COLOR_CRASHED="colour88"      # Dark Red
export PTTY_COLOR_BG_BAR="colour234"      # Dark Gray (status bar)
export PTTY_COLOR_BG_TERM="colour235"     # Terminal BG
export PTTY_COLOR_BG_TAB="colour236"      # Tab background (between)
```

Users can create custom themes by copying `themes/default.sh` and modifying colors.

---

## Naming Conventions

### Console Identification

**Format:** `F(n)` where n = 1-12

**Examples:**
- F1, F2, F3, ... F10
- F11 (Manager)
- F12 (Help)

**NOT:**
- "Console-1" (too long for status bar)
- "1" (ambiguous)
- "C1" (unclear)

**Custom names (v2/v3):**
- User can optionally add custom name: "F1:Claude" or "F7:Logs"
- Shown in Manager and status bar (if space allows)

### File Naming

**Console crash dumps:**
- Format: `~/.ptty.crash.f(n).dump`
- Example: `~/.ptty.crash.f3.dump`

**Config file:**
- Location: `~/.ptty.conf`

**Theme files:**
- Location: `~/.vps/sessions/themes/(name).sh`
- Example: `themes/default.sh`, `themes/dark.sh`

---

## Abbreviations

| Abbr | Full Term | Usage |
|------|-----------|-------|
| **pTTY** | PersistentTTY | Display name, branding |
| **ptty** | (lowercase) | CLI commands, filesystem |
| **F(n)** | Function key N | Console identifier |
| **NF** | Nerd Fonts | Icon font family |
| **TUI** | Text User Interface | Manager (F11) |
| **MOTD** | Message of the Day | First-time user greeting |
| **BG** | Background | Background color |
| **FG** | Foreground | Foreground/text color |

---

## Version-Specific Terms

### v1 (Current)
- **Active console:** F1-F5 (default)
- **Suspended console:** F6-F10 (default)
- **Actions:** Attach, Activate, Restart
- **Config:** Manual edit only

### v2 (DevEx & Onboarding)
- **Custom names:** User-defined console names
- **Process display:** Show running process name
- **MOTD:** First-time user message
- **Config reload:** Live reload without restart

### v3 (Advanced Features)
- **Process monitoring:** CPU, RAM, process count
- **CLI commands:** `ptty` command suite
- **Bulk actions:** Restart all, kill all (with confirmation)
- **Custom config:** Auto-start scripts per console
- **Clone:** Duplicate console state
- **Notifications:** Alert on crashed console

---

## Related Documentation

- **ICONS-SPEC.md:** Detailed icon mapping and theme system
- **STATUS-BAR-SPEC.md:** Status bar visual design
- **MANAGER-SPEC.md:** Manager (F11) complete specification
- **HELP-SPEC.md:** Help (F12) content structure
- **FUTURE-VISION.md:** v2/v3 feature roadmap
- **CLI-ARCH.md:** CLI command architecture (v3)

---

**END OF GLOSSARY**

This document is the single source of truth for terminology.
All documentation and code MUST use these terms consistently.
