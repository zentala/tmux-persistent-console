# Persistent Console - Architecture v2.0

**Complete UX redesign** - Bottom status bar + keyboard shortcuts + manager menu

---

## 🎯 CORE CONCEPT

**Bottom status bar shows ALL 7 sessions** (like browser tabs)
- User sees all consoles at once
- Click or keyboard to switch
- Visual indicators (Nerd Font icons)
- Lazy start for consoles 6-7

---

## 📊 BOTTOM STATUS BAR

**Always visible at bottom of screen:**

```
  󰣐 1:claude  󰣐 2:copilot   3:dev   4:test   5:htop   6:git   7:admin  │ Ctrl+? Help
  ▔▔▔▔▔▔▔▔▔
```

**Elements:**
- All 7 sessions visible
- Active session = underlined + cyan color
- Session with processes =  icon (Nerd Font)
- Empty/idle session =  icon (Nerd Font)
- Spinner  when action in progress (optional)
- Right side: `Ctrl+? Help` hint
- Mouse clickable (tmux mouse support)

**Tmux config:**
```bash
set -g status-position bottom
set -g status-left-length 200
# Format: session number + name + icon based on pane count
```

---

## ⌨️ KEYBOARD SHORTCUTS

### Direct Jumping
| Key | Action | Confirmation |
|-----|--------|--------------|
| **F1-F7** | Jump to console 1-7 | No |
| **Ctrl+F1-F7** | Same as F1-F7 | No |
| **Ctrl+1-7** | Jump to console 1-7 | No |
| **Ctrl+←** | Previous console | No |
| **Ctrl+→** | Next console | No |

### Actions
| Key | Action | Confirmation |
|-----|--------|--------------|
| **Ctrl+R** | Restart current console | **YES (popup)** |
| **Ctrl+D** | Disconnect safely (detach) | No |
| **Ctrl+?** | Show shortcuts popup | - |

### Management
| Key | Action | Type |
|-----|--------|------|
| **F11** | Manager Menu (interactive) | gum choose |
| **F12** | Static Help Reference | tmux window |

### Reserved for Future
| Key | Status | Possible Use |
|-----|--------|--------------|
| **F8** | FREE | Quick notes? |
| **F9** | FREE | System monitor? |
| **F10** | FREE | Git status? |

---

## 🎛️ F11 - MANAGER MENU (Interactive)

**File:** `src/manager-menu.sh`
**Tool:** gum choose + gum confirm
**Purpose:** For beginners who prefer menu navigation

### Main Menu

```
CONSOLE MANAGER

Select action:
> 󰣐 Switch to console...
  󰑓 Restart console...
  󰒓 Settings
  󰋗 Disconnect safely
  ? Help & Documentation
```

**NO BORDER AROUND TEXT** - only popup has border

### Submenu: Switch to console

```
Select console:
> 󰣐 console-1 (claude-code)
  󰣐 console-2 (copilot)
   console-3 (dev)
   console-4 (test)
   console-5 (htop)
   console-6 (git)
   console-7 (admin)
```

Then switches immediately (no confirmation).

### Submenu: Restart console

**Step 1:** Select console to restart
```
Select console to restart:
> 󰣐 console-1 (claude-code)
  󰣐 console-2 (copilot)
   console-3 (dev)
```

**Step 2:** Confirm restart (gum confirm)
```
⚠️  Restart console-1?

This will:
  • Kill current session
  • Create new clean session
  • Lose unsaved work

Continue?
> Yes, restart now
  No, cancel
```

If confirmed → restart session + show spinner  → done message.

### Submenu: Settings

```
SETTINGS

  Confirm restart:        [✓] Yes  [ ] No
  Auto-start consoles:    [1-5]
  Mouse support:          [✓] Enabled
  Show process names:     [✓] Enabled

  [S] Save    [ESC] Cancel
```

**NO BORDER** - clean text interface

**Storage:** `~/.config/tmux-console/settings.conf`

**Settings options:**
- `confirm_restart` (bool) - Ask before restart
- `auto_start_count` (1-7) - How many consoles start on boot
- `mouse_support` (bool) - Enable mouse clicks
- `show_process_names` (bool) - Show process in status bar

### Submenu: Help & Documentation

Opens static help (same as F12) or shows:
```
HELP & SUPPORT

  Online Documentation:
    https://github.com/zentala/tmux-persistent-console

  Report Bug / Feature Request:
    https://github.com/zentala/tmux-persistent-console/issues

  [ESC] Back to menu
```

---

## 📚 F12 - STATIC HELP REFERENCE

**File:** `src/help-reference.sh`
**Type:** Static tmux window (not interactive)
**Purpose:** Complete keyboard shortcuts reference

### Content

```
┌─────────────────────────────────────────────────────────────┐
│  🖥️  PERSISTENT CONSOLE v1.0.0 - Quick Reference            │
│                                                              │
│  KEYBOARD SHORTCUTS:                                         │
│    F1-F7          Direct jump to console 1-7                │
│    Ctrl+F1-F7     Same as F1-F7                             │
│    Ctrl+←→        Navigate prev/next console                │
│    Ctrl+1-7       Direct jump (alternative)                 │
│                                                              │
│  MANAGEMENT:                                                 │
│    F11            Console Manager (interactive menu)        │
│    Ctrl+R         Restart current console (with confirm)    │
│    Ctrl+D         Disconnect safely                         │
│    Ctrl+?         Show keyboard shortcuts popup             │
│                                                              │
│  MOUSE SUPPORT:                                             │
│    Click tab      Switch to console                         │
│    Scroll wheel   Navigate windows                          │
│                                                              │
│  TIPS:                                                      │
│    • Sessions survive SSH disconnects                       │
│    • Type 'exit' to safely detach (not kill)               │
│    • Consoles 6-7 start on demand (lazy start)             │
│                                                              │
│  HELP & SUPPORT:                                            │
│    Docs:  github.com/zentala/tmux-persistent-console       │
│    Bugs:  github.com/zentala/tmux-persistent-console/issues│
│                                                              │
│  Press F1-F7 or click tab below to switch consoles         │
└─────────────────────────────────────────────────────────────┘
```

**Features:**
- Clean box border (only outer box)
- Static text (read-only)
- Shows as tmux window (tab `8:Help` in status bar)
- User can switch away with F1-F7 or click

---

## ⌨️ CTRL+? - SHORTCUTS POPUP

**File:** `src/shortcuts-popup.sh`
**Tool:** gum style box (overlay)
**Purpose:** Quick reference without switching windows

### Popup Content

```
┌─────────────────────────────────────┐
│  ⌨️  KEYBOARD SHORTCUTS             │
├─────────────────────────────────────┤
│  F1-F7       Jump to console       │
│  Ctrl+←→     Prev/Next             │
│  Ctrl+R      Restart (confirm)     │
│  F11         Manager Menu          │
│  F12         Full Help             │
│  Ctrl+?      This popup            │
│                                     │
│  Press any key to close            │
└─────────────────────────────────────┘
```

**Implementation:**
```bash
gum style \
  --border rounded \
  --border-foreground 212 \
  --padding "1 2" \
  --margin "1" \
  "  ⌨️  KEYBOARD SHORTCUTS

  F1-F7       Jump to console
  Ctrl+←→     Prev/Next
  Ctrl+R      Restart (confirm)
  F11         Manager Menu
  F12         Full Help
  Ctrl+?      This popup

  Press any key to close"

read -n 1
```

**Behavior:**
- Shows as overlay (doesn't change window)
- Any key closes it
- Non-blocking
- Quick reference (5 seconds to read)

---

## 🔄 CTRL+R - RESTART CONFIRMATION

**Purpose:** Restart current console with user confirmation
**When:** User is in console-3 and presses Ctrl+R

### Confirmation Dialog

```
⚠️  Restart console-3?

Current session will be killed and recreated.
You will lose unsaved work.

Continue?
> Yes, restart now
  No, cancel
```

**Implementation:**
```bash
current_session=$(tmux display-message -p '#S')

if gum confirm "⚠️  Restart $current_session?" \
  --affirmative "Yes, restart now" \
  --negative "No, cancel"; then

  # Show spinner during restart
  gum spin --spinner dot --title "Restarting $current_session..." -- \
    bash restart-session.sh "$current_session"

  gum style --foreground 212 "✓ Session restarted"
  sleep 1
fi
```

**Settings integration:**
- If `confirm_restart=false` in settings → skip confirmation
- Directly restart with spinner

---

## 🚀 LAZY START

**Concept:** Consoles 6-7 don't start automatically

**Behavior:**
- On boot: Start consoles 1-5 (default, configurable)
- When user presses F6 or F7:
  - If session doesn't exist → create it
  - Show message: `Creating console-6...`
  - Switch to new session

**Implementation:**
```bash
# In tmux.conf keybinding
bind-key -n C-F6 run-shell "~/.vps/sessions/src/lazy-start.sh console-6"

# lazy-start.sh
session="$1"
if ! tmux has-session -t "$session" 2>/dev/null; then
  gum spin --spinner dot --title "Creating $session..." -- \
    tmux new-session -d -s "$session" -n "main"
fi
tmux switch-client -t "$session"
```

**Settings:**
- `auto_start_count` (default: 5)
- Range: 1-7
- If set to 7 → all start on boot (no lazy start)

---

## 📁 FILE STRUCTURE

```
~/.vps/sessions/
├── src/
│   ├── tmux.conf                  # Updated status bar config
│   ├── setup.sh                   # Modified for lazy start
│   ├── manager-menu.sh            # F11 interactive menu (gum)
│   ├── help-reference.sh          # F12 static help window
│   ├── shortcuts-popup.sh         # Ctrl+? popup overlay
│   ├── restart-confirm.sh         # Ctrl+R confirmation dialog
│   ├── lazy-start.sh              # On-demand session creation
│   ├── safe-exit.sh               # Keep existing
│   └── tui/                       # Keep TUI library
│       ├── tui-core.sh
│       ├── tui-menu.sh
│       └── ...
├── ARCHITECTURE.md                # This file
├── TODO.md                        # Implementation tasks
└── README.md                      # User documentation

~/.config/tmux-console/
└── settings.conf                  # User settings (gitignored)
```

---

## ⚙️ SETTINGS FILE

**Location:** `~/.config/tmux-console/settings.conf`
**Format:** Key=Value (shell source-able)

```bash
# Persistent Console Settings
# Auto-generated - edit via F11 → Settings

# Ask confirmation before restarting session
confirm_restart=true

# How many consoles to auto-start (1-7)
auto_start_count=5

# Enable mouse support for clicking tabs
mouse_support=true

# Show process names in status bar
show_process_names=true
```

**Loading:**
```bash
# Default settings
CONFIRM_RESTART=true
AUTO_START_COUNT=5
MOUSE_SUPPORT=true
SHOW_PROCESS_NAMES=true

# Load user overrides
[ -f ~/.config/tmux-console/settings.conf ] && source ~/.config/tmux-console/settings.conf
```

---

## 🎨 VISUAL DESIGN RULES

### Colors (ANSI)
- **Cyan (39)** - Active session, headers
- **Gray (244)** - Inactive sessions
- **Green (46)** - Success messages
- **Yellow (226)** - Warnings
- **Red (196)** - Errors
- **Magenta (212)** - Accents, borders

### Icons (Nerd Fonts)
-  - Active session (has processes)
-  - Empty/idle session
-  - Spinner (loading/processing)
- 󰆍 - Console manager
- 󰑓 - Restart action
- 󰒓 - Settings
- 󰋗 - Disconnect
-  - Help/documentation

### Borders
- **NO BORDERS around headers/text** (user preference)
- **YES borders for popups** (gum style boxes)
- **YES outer box for F12 help** (static reference)
- **Use `gum style --border rounded`** for popups
- **Use simple box chars** `┌─┐│└┘` for static windows

### Typography
- **Headers:** Simple text, no decorative frames
- **Lists:** Clean bullets or numbers
- **Separators:** `─────` simple lines, not `═══╗`

---

## 🔧 IMPLEMENTATION ORDER

1. **Bottom status bar** (tmux.conf) - Foundation
2. **F12 static help** (help-reference.sh) - Simple text window
3. **Ctrl+? popup** (shortcuts-popup.sh) - Gum overlay
4. **Ctrl+R confirm** (restart-confirm.sh) - Gum confirm
5. **Lazy start** (lazy-start.sh) - On-demand sessions
6. **F11 manager menu** (manager-menu.sh) - Full interactive menu
7. **Settings system** (settings.conf + GUI)
8. **Update install.sh** - Ensure gum installed
9. **Update README.md** - User documentation

---

## ✅ SUCCESS CRITERIA

- [ ] User sees all 7 sessions in bottom bar
- [ ] Click tab switches session
- [ ] F1-F7 direct jump works
- [ ] Ctrl+←→ navigates prev/next
- [ ] Ctrl+R shows confirmation before restart
- [ ] Ctrl+? shows quick shortcuts popup
- [ ] F11 opens interactive manager menu
- [ ] F12 shows static help reference
- [ ] Consoles 6-7 lazy start on first access
- [ ] Settings persist in config file
- [ ] No ugly frames around headers (user preference)
- [ ] Nerd Font icons show session status
- [ ] Mouse clicks work (tmux mouse support)

---

## 🚀 FUTURE ENHANCEMENTS

**Possible uses for F8-F10:**
- **F8** - Quick notes / clipboard manager
- **F9** - System monitor (htop popup)
- **F10** - Git status overview

**Status bar enhancements:**
- Show spinner  during long operations
- Show notification badges (updates available)
- Color coding for different session types

**Auto-update:**
- Check GitHub for new versions
- Notify in status bar
- One-command update via F11 → Settings

---

**Version:** 2.0.0
**Date:** 2025-10-06
**Status:** Architecture approved, ready for implementation
