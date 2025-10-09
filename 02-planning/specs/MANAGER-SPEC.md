# pTTY - Manager (F11) Specification

**Version:** v1.0
**Date:** 2025-10-08
**Purpose:** Complete F11 Manager interface specification

---

## Overview

**Manager = Interactive TUI for console management**

- **Access:** Ctrl+F11 (from any console)
- **Session:** Dedicated tmux session `manager`
- **UI:** Full-screen, gum-based interactive menu
- **Purpose:** View all consoles, manage states, perform actions

---

## Layout

### Full Screen Mockup

```
┌─────────────────────────────────────────────────────────────────────┐
│                   󰓉 PersistentTTY Manager                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [•] F1 (Active)                                                   │
│  [•] F2 (Active)                                                   │
│  [•] F3 (Active), Actions: [Enter] Attach  [Del] Restart  ← SELECTED│
│  [•] F4 (Active)                                                   │
│  [•] F5 (Active)                                                   │
│  [○] F6 (Suspended)                                                │
│  [○] F7 (Suspended)                                                │
│  [○] F8 (Suspended)                                                │
│  [○] F9 (Suspended)                                                │
│  [○] F10 (Suspended)                                               │
│  [•] F11 Manager (Inactive - you are here)                         │
│  [•] F12 Help                                                      │
│                                                                     │
│  Navigation: ↑↓ Select | → Action | Enter Execute | Esc Exit       │
└─────────────────────────────────────────────────────────────────────┘
```

**Notes:**
- Only selected console shows ", Actions: ..." on same line
- Selected line highlighted in blue
- (Status) text always gray
- [Enter] [Del] buttons highlighted when focused

### Console Line Format

**ALL IN ONE LINE:**

**Not selected:**
```
[icon] F(n) (Status - gray text)
```

**Selected (highlighted):**
```
[icon] F(n) (Status - gray text), Actions: [Enter] Attach [Del] Restart
```

**Visual example:**
```
[•] F1 (Active)
[•] F2 (Active)
[•] F3 (Active), Actions: [Enter] Attach  [Del] Restart  ← selected (blue highlight)
[•] F4 (Active)
[○] F6 (Suspended)
[○] F7 (Suspended), Actions: [Enter] Activate  ← selected
```

**Color coding:**
- Icon + F(n): White (normal) / Blue (selected)
- (Status): Gray text always
- Actions text: White
- [Enter], [Del]: Highlighted/bold (active = currently selected action)

---

## Navigation

### Keyboard Shortcuts

| Key | Action | Context |
|-----|--------|---------|
| **↑ / ↓** | Navigate list | Move between consoles |
| **→** | Select action | Show action submenu |
| **←** | Back | Return from action to console list |
| **Enter** | Execute | Attach (active) / Activate (suspended) / Confirm action |
| **Del** | Restart | Shortcut for Restart action |
| **Esc** | Exit | Close Manager, return to last console |
| **Ctrl+C** | Cancel | Exit action submenu if in one |

### Navigation Flow

**1. Console selection:**
- User presses ↑/↓ → highlight moves between F1-F12
- Selected console shows actions below
- Default action: [Enter] Attach or Activate

**2. Action selection:**
- User presses → → moves to action submenu (if available)
- Actions: [Restart] shown for active consoles
- User presses → again → selects action
- User presses Enter → executes action (with confirmation if destructive)

**3. Exiting:**
- 1st Esc → Exit action submenu (if in one)
- 2nd Esc → Exit Manager, return to last active console

---

## Console States & Actions

### Active Console (F1-F5)

**Display:**
```
[•] F3 (Active)
    Actions: [Enter] Attach  [Del] Restart
```

**Available actions:**
1. **Attach** (Enter) - Switch to this console
2. **Restart** (Del) - Kill and recreate (requires confirmation)

### Suspended Console (F6-F10)

**Display:**
```
[○] F7 (Suspended)
    Actions: [Enter] Activate
```

**Available actions:**
1. **Activate** (Enter) - Create and attach to console

**Behavior:**
- User selects F7, presses Enter
- Console is created (tmux new-session)
- User is switched to F7
- Status bar updates (F7 now shows active icon)

### Crashed Console

**Display:**
```
[✗] F4 (Crashed)
    Crash dump: ~/.ptty.crash.f4.dump
    Actions: [Enter] Restart
```

**Available actions:**
1. **Restart** (Enter) - Recreate console (auto-confirmed)

**Behavior:**
- Shows path to crash dump
- User can view dump before restarting
- Restart is automatic (no confirmation for crashed consoles)

### Manager & Help (F11, F12)

**Display:**
```
[•] F11 Manager (Inactive - you are here)
[•] F12 Help
```

**Available actions:**
- F11: Cannot attach to itself (you're already here)
- F12: [Enter] Attach - Switch to Help

**Behavior:**
- F11 is grayed out / marked as "current"
- F12 can be selected to view Help

---

## Actions & Confirmations

### Attach Action (Enter)

**For active console:**
```
User: Selects F3 + presses Enter
→ tmux switch-client -t console-3
→ Manager closes, user is in F3
```

**No confirmation needed** (safe operation)

### Activate Action (Enter)

**For suspended console:**
```
User: Selects F7 + presses Enter
→ Show inline confirmation:
    [○] F7 (Suspended)
        Activate console F7? [Enter] Yes  [Esc] Cancel
User: Presses Enter again
→ tmux new-session -d -s console-7
→ tmux switch-client -t console-7
→ Manager closes, user is in F7
```

**Confirmation shown inline** (one-line prompt)

### Restart Action (Del or → Restart + Enter)

**For active console:**
```
User: Selects F3, presses Del (or → then Restart then Enter)
→ Show inline confirmation:
    [•] F3 (Active)
        Actions: [Cancel] [I am sure, restart F3]
                  ^default    ^requires → arrow + Enter
User: Must press → to select "I am sure", then Enter
→ tmux kill-session -t console-3
→ tmux new-session -d -s console-3
→ Manager updates, F3 shows as Active (empty)
```

**Two-step confirmation:**
1. Default is Cancel (safe)
2. User must arrow right + Enter to confirm (deliberate action)

**Color coding:**
- Cancel: Green/White (safe choice)
- Confirm: Red (danger - requires explicit selection)

---

## UI States

### Header

```
󰓉 PersistentTTY Manager
```

- Icon: 󰓉 (nf-md-table_network)
- Centered, bold
- Always visible

### Console List

**Scrollable** (if more than terminal height):
- Shows F1-F12
- Current selection highlighted
- Actions appear below selected console

**Sorting:**
- Always F1-F12 order
- No custom sorting (v1)

### Footer / Navigation Hints

```
Navigation: ↑↓ Select | → Actions | Enter Attach/Activate
Shortcuts: Esc Exit | Del Restart
```

- Always visible at bottom
- Helps users learn shortcuts
- Compact (1-2 lines max)

---

## Implementation

### Entry Point (tmux.conf)

```tmux
bind-key -n C-F11 run-shell "tmux has-session -t manager 2>/dev/null || tmux new-session -d -s manager -n 'Manager' 'bash --noprofile --norc ~/.vps/sessions/src/manager-menu.sh'; tmux switch-client -t manager"
```

### Manager Script (src/manager-menu.sh)

```bash
#!/bin/bash
# Load theme
source ~/.vps/sessions/themes/${THEME}.sh

# Build console list
CONSOLES=()
for i in {1..12}; do
  STATE=$(get_console_state $i)
  case $STATE in
    "active")   ICON="${PTTY_ICON_ACTIVE}";    STATUS="Active" ;;
    "suspended") ICON="${PTTY_ICON_SUSPENDED}"; STATUS="Suspended" ;;
    "crashed")  ICON="${PTTY_ICON_CRASHED}";   STATUS="Crashed" ;;
  esac
  
  if [ "$i" = "11" ]; then
    CONSOLES+=("${ICON} F${i} Manager (Inactive - you are here)")
  elif [ "$i" = "12" ]; then
    CONSOLES+=("${ICON} F${i} Help")
  else
    CONSOLES+=("${ICON} F${i} (${STATUS})")
  fi
done

# Show interactive menu
SELECTED=$(printf '%s\n' "${CONSOLES[@]}" | gum choose --header="󰓉 PersistentTTY Manager")

# Extract console number
CONSOLE_NUM=$(echo "$SELECTED" | grep -oP 'F\K\d+')

# Perform action based on state
STATE=$(get_console_state $CONSOLE_NUM)
if [ "$STATE" = "suspended" ]; then
  # Activate suspended console
  if gum confirm "Activate console F${CONSOLE_NUM}?"; then
    tmux new-session -d -s "console-${CONSOLE_NUM}"
    tmux switch-client -t "console-${CONSOLE_NUM}"
  fi
elif [ "$STATE" = "active" ]; then
  # Show actions for active console
  ACTION=$(echo -e "Attach\nRestart" | gum choose --header="F${CONSOLE_NUM} Actions")
  
  if [ "$ACTION" = "Attach" ]; then
    tmux switch-client -t "console-${CONSOLE_NUM}"
  elif [ "$ACTION" = "Restart" ]; then
    if gum confirm "Restart console F${CONSOLE_NUM}?"; then
      tmux kill-session -t "console-${CONSOLE_NUM}"
      tmux new-session -d -s "console-${CONSOLE_NUM}"
    fi
  fi
fi
```

### Helper Functions

```bash
get_console_state() {
  local num=$1
  if tmux has-session -t "console-${num}" 2>/dev/null; then
    # Check if crashed (exit code from last command?)
    # For v1, assume active if exists
    echo "active"
  else
    echo "suspended"
  fi
}
```

---

## Edge Cases

### 1. Manager opened from Manager (F11 in F11)
**Behavior:** Already in Manager, do nothing or show message

### 2. All consoles active
**Display:** All show as Active, all have Attach/Restart actions

### 3. User kills Manager session manually
**Recovery:** Pressing Ctrl+F11 recreates Manager session

### 4. Very narrow terminal
**Adapt:** Reduce header text, collapse action hints

---

## v2/v3 Enhancements

**v2 (Next):**
- Show running process name per console
- Show last active process (grayed)
- Resource usage indicators (CPU %, RAM %)

**v3 (Future):**
- Process count per console
- Uptime display
- Last activity timestamp
- Clone console action
- Bulk actions (restart all)
- Console rename inline

---

## Related Documentation

- **GLOSSARY.md:** Action definitions
- **ICONS-SPEC.md:** Icon mapping
- **STATUS-BAR-SPEC.md:** How Manager affects status bar
- **FUTURE-VISION.md:** v2/v3 Manager features

---

**END OF MANAGER SPECIFICATION**

---

## Related Architecture Decisions

- **[ADR 003](../../03-architecture/decisions/003-gum-ui-framework.md):** Gum UI Framework - Why gum for F11 Manager
- **[ADR 005](../../03-architecture/decisions/005-no-external-scripts-statusbar.md):** No External Scripts - Exception for F11 (interactive UI allowed)

## Implementation Status

- [x] **v0.1** - Prototype in `src/mission-control.sh` (monolithic)
- [ ] **v0.2** - Refactored in `src/ui/manager/` (Task 002)

## Related Tasks

- **[Task 002](../../04-tasks/002-refactor-ui-components.md):** UI Components refactoring (implements this spec)
