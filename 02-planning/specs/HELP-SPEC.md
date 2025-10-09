# pTTY - Help (F12) Specification

**Version:** v1.0
**Date:** 2025-10-08
**Purpose:** F12 Help content and structure

---

## Overview

**Help (F12) = Static keyboard shortcuts reference**

- **Access:** Ctrl+F12 (from any console)
- **Session:** Dedicated tmux session `help`
- **UI:** Static text display (no interaction)
- **Purpose:** Show all keyboard shortcuts, system info, config location

---

## Content Structure

### Full Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│               Keyboard Shortcuts Reference               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  CONSOLE SWITCHING                                          │
│  ─────────────────                                          │
│  Ctrl+F1-F5     Switch to active console (F1-F5)           │
│  Ctrl+F6-F10    Activate/switch to console (F6-F10)        │
│  Ctrl+F11       Open Manager (console management)          │
│  Ctrl+F12       Show this help                             │
│                                                             │
│  NAVIGATION                                                 │
│  ──────────                                                 │
│  Ctrl+Left      Previous console                           │
│  Ctrl+Right     Next console                               │
│  Ctrl+Esc       Detach (leave console safely)              │
│                                                             │
│  ACTIONS                                                    │
│  ───────                                                    │
│  Ctrl+R         Restart current console                    │
│  Ctrl+Del       Restart current console                    │
│  Ctrl+Alt+R     Reset terminal (clear + reset)             │
│                                                             │
│  HELP & SHORTCUTS                                           │
│  ────────────────                                           │
│  Ctrl+H         Quick shortcuts popup                      │
│  Ctrl+?         Quick shortcuts popup                      │
│                                                             │
│  TRADITIONAL TMUX (backup)                                  │
│  ─────────────────────────                                  │
│  Ctrl+b, s      Session list                               │
│  Ctrl+b, 1-9    Switch to console 1-9                      │
│  Ctrl+b, 0      Switch to console 10                       │
│  Ctrl+b, d      Detach                                     │
│                                                             │
│  SYSTEM INFO                                                │
│  ───────────                                                │
│  pTTY Version:  v1.0                                        │
│  Config File:   ~/.ptty.conf                                │
│  Themes:        ~/.vps/sessions/themes/                     │
│  Crash Dumps:   ~/.ptty.crash.f(n).dump                    │
│                                                             │
│  Press Esc or Ctrl+F12 to close                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Sections

### 1. Console Switching
- Ctrl+F1-F12 shortcuts
- Explain active vs suspended

### 2. Navigation
- Arrow keys
- Detach

### 3. Actions
- Restart
- Reset terminal

### 4. Help & Shortcuts
- Ctrl+H popup
- Ctrl+? alias

### 5. Traditional tmux
- Backup methods for tmux power users

### 6. System Info
- Version
- Config file location
- Theme directory
- Crash dump location

---

## Implementation

### Entry Point (tmux.conf)

```tmux
bind-key -n C-F12 run-shell "tmux has-session -t help 2>/dev/null || tmux new-session -d -s help -n 'Help' '~/.vps/sessions/src/help-reference.sh'; tmux switch-client -t help"
```

### Help Script (src/help-reference.sh)

```bash
#!/bin/bash
# Static help display

clear

cat << 'HELP'
┌─────────────────────────────────────────────────────────────┐
│               Keyboard Shortcuts Reference               │
├─────────────────────────────────────────────────────────────┤

CONSOLE SWITCHING
─────────────────
Ctrl+F1-F5     Switch to active console (F1-F5)
Ctrl+F6-F10    Activate/switch to console (F6-F10)
Ctrl+F11       Open Manager (console management)
Ctrl+F12       Show this help

NAVIGATION
──────────
Ctrl+Left      Previous console
Ctrl+Right     Next console
Ctrl+Esc       Detach (leave console safely)

ACTIONS
───────
Ctrl+R         Restart current console
Ctrl+Del       Restart current console
Ctrl+Alt+R     Reset terminal (clear + reset)

HELP & SHORTCUTS
────────────────
Ctrl+H         Quick shortcuts popup
Ctrl+?         Quick shortcuts popup

TRADITIONAL TMUX (backup)
─────────────────────────
Ctrl+b, s      Session list
Ctrl+b, 1-9    Switch to console 1-9
Ctrl+b, 0      Switch to console 10
Ctrl+b, d      Detach

SYSTEM INFO
───────────
pTTY Version:  v1.0
Config File:   ~/.ptty.conf
Themes:        ~/.vps/sessions/themes/
Crash Dumps:   ~/.ptty.crash.f(n).dump

Press Esc or Ctrl+F12 to close

└─────────────────────────────────────────────────────────────┘
HELP

# Keep shell open so help doesn't close
exec bash --noprofile --norc
```

---

## v2 Enhancements

### Dynamic Content
- Show current config values (theme, active consoles count)
- Show user's custom console names if defined
- Show current tmux version

### Interactive Elements
- Press 'C' to edit config
- Press 'T' to list themes
- Press 'L' to view logs

### Searchable Help (v3)
- Search shortcuts by keyword
- Filter by category
- Copy commands to clipboard

---

## Related Documentation

- **GLOSSARY.md:** Complete shortcuts reference
- **MANAGER-SPEC.md:** F11 Manager helps complement F12 Help
- **FUTURE-VISION.md:** v2/v3 help enhancements

---

**END OF HELP SPECIFICATION**
