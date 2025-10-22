# pTTY - Unified Specification

**Version:** 3.1
**Date:** 2025-10-08
**Status:** Active specification - all development MUST follow this document

---

## 📋 Table of Contents

1. [Project Identity](#project-identity)
2. [F-Key Bindings](#f-key-bindings)
3. [Status Bar Specification](#status-bar-specification)
4. [Active vs Suspended Terminals](#active-vs-suspended-terminals)
5. [Manager Menu (F11)](#manager-menu-f11)
6. [Help Reference (F12)](#help-reference-f12)
7. [Icons & Iconography](#icons--iconography)
8. [Open Questions](#open-questions)

---

## Project Identity

### Naming Convention

**Primary name:** `pTTY` (PersistentTTY)
**Full name:** `PersistentTTY`
**Short name:** `ptty` (lowercase, filesystem/CLI usage)

**Usage rules:**
- **GUI/Display**: Use `pTTY` with capital letters
- **CLI/Filesystem**: Use lowercase `ptty` (commands, folders, etc.)
- **Status bar**: `pTTY` (branded display)
- **Documentation titles**: `pTTY` or full `PersistentTTY`

**See:** `docs/naming.md` for complete naming conventions

### Application Purpose

**Primary goal:** Provide persistent SSH terminal sessions that survive disconnections.

**Core use cases:**
- Remote server management via SSH
- AI CLI tools (Claude Code, OpenAI Codex CLI)
- Long-running operations during unstable connections
- System updates and maintenance without losing session

**Design principles:**
- Developer-friendly (good DevEx)
- Works out-of-the-box without configuration
- Intuitive interface (self-describing)
- Low-code approach - minimal user setup required
- F-key navigation (familiar from Linux TTY switching)

---

## F-Key Bindings

### Core Concept

**Only 5 active terminals by default (F1-F5)**
**5 suspended terminals available (F6-F10)**
**F11** = Manager Menu (interactive TUI)
**F12** = Help Reference (static text)

### Complete Key Map

| Key | Function | Status | Description |
|-----|----------|--------|-------------|
| **Ctrl+F1** | Console 1 | Active | AI development (Claude Code) |
| **Ctrl+F2** | Console 2 | Active | AI CLI (Copilot, etc.) |
| **Ctrl+F3** | Console 3 | Active | General development |
| **Ctrl+F4** | Console 4 | Active | Testing & QA |
| **Ctrl+F5** | Console 5 | Active | Monitoring & Logs |
| **Ctrl+F6** | Console 6 | Suspended | Available on demand |
| **Ctrl+F7** | Console 7 | Suspended | Available on demand |
| **Ctrl+F8** | Console 8 | Suspended | Available on demand |
| **Ctrl+F9** | Console 9 | Suspended | Available on demand |
| **Ctrl+F10** | Console 10 | Suspended | Available on demand |
| **Ctrl+F11** | Manager Menu | Special | Interactive terminal manager (TUI) |
| **Ctrl+F12** | Help Reference | Special | Static help text |

### Additional Navigation

| Key | Function | Description |
|-----|----------|-------------|
| **Ctrl+Left** | Previous Session | Navigate backwards through sessions |
| **Ctrl+Right** | Next Session | Navigate forwards through sessions |
| **Ctrl+H** | Shortcuts Popup | Quick reference popup |
| **Ctrl+R** | Restart Console | Restart current console (with confirmation) |
| **Ctrl+Alt+R** | Reset Terminal | Clear and reset current terminal |
| **Ctrl+Esc** | Detach | Safe disconnect (future, see Open Questions) |
| **Ctrl+Del** | Restart Terminal | Same popup as Ctrl+R (future) |

### Backup: Traditional tmux navigation

| Key | Function |
|-----|----------|
| **Ctrl+b, s** | Visual session list |
| **Ctrl+b, 1-10** | Switch to console 1-10 |
| **Ctrl+b, (** | Previous session |
| **Ctrl+b, )** | Next session |
| **Ctrl+b, L** | Last used session |

---

## Status Bar Specification

### Complete Status Bar Layout

```
[ 󰢩 pTTY ][ 󰀉 user @ server ]  󰢩 F1  󰢩 F2  󰢩 F3  󰢩 F4  󰢩 F5   F6   F7   F8-10   F11   F12
                                 \______/  \____/  \____/  \_____/  \______/  \______/  \______/
                                  active    avail   avail    susp    manager    help
```

**Note:** Active tab (e.g., "󰢩 F1") has shadow/depth effect with background highlighting

### Status Bar Zones

**Left zone (fixed):**
- Application branding: `[ 󰢩 pTTY ]` - Icon + brand name
- User/host info: `[ 󰀉 zentala @  contabo ]` - User icon + username + server icon + hostname

**Center/Right zone (dynamic):**
- **Sessions F1-F10**: Icon + key label (e.g., `󰢩 F1`, `󰢩 F2`, ` F6`)
- **Grouping**: Consecutive suspended sessions collapse (e.g., ` F8-10` if F8/F9/F10 all suspended)
- **Manager (F11)**: ` F11` - Icon + label
- **Help (F12)**: ` F12` - Icon + label

### Session Tab Format

**Individual tab structure:**
```
<icon> F<number>
```

**Examples:**
- Active session: `󰢩 F1` (cyan, highlighted background with shadow)
- Available session: `󰢩 F2` (white, normal background)
- Suspended session: ` F6` (dark gray, no background)
- Grouped suspended: ` F8-10` (dark gray, collapsed range)

### Visual States

**Session states (color + icon):**

| State | Color | Icon | Description |
|-------|-------|------|-------------|
| **Active** | `colour39` (cyan) | 󰢩 | Currently focused session - NO BOLD |
| **Available** | `colour255` (white) | 󰢩 | Created session, idle |
| **Suspended** | `colour240` (dark gray) |  | Not created yet, available on demand |
| **Crashed** | `colour196` (red) |  | Session killed/crashed |

**Special elements (F11/F12):**

| Element | Color | Icon | Label |
|---------|-------|------|-------|
| **Manager** | `colour255` (white) |  | F11 |
| **Help** | `colour255` (white) |  | F12 |

### Background & Shadow Effects

**Background colors:**
- Status bar background: `colour234` (lighter gray)
- Session terminal background: `colour235` (darker gray)
- Active tab background: `colour236` (medium gray)

**Active tab shadow/depth:**
```tmux
# Active tab with shadow effect:
#[fg=colour236,bg=colour234]  #[fg=colour39,bg=colour236] 󰢩 1 #[fg=colour236,bg=colour234]
  └─ left shadow            └─ tab content            └─ right shadow
```

**Non-active tabs (no shadow):**
```tmux
# Available/suspended tabs (flat):
#[fg=colour255,bg=colour234] 󰢩 2
#[fg=colour240,bg=colour234]  6
```

### Icon Reference

**All icons from:** `docs/ICONS-NETWORK-SET.md` (network theme only)

**Theme configuration:** `src/theme-config.sh`

**Icon variables:**
- `$ICON_SESSION_ACTIVE` = 󰢩 (nf-md-console_network, f08a9)
- `$ICON_SESSION_AVAILABLE` = 󰢩 (nf-md-console_network, f08a9)
- `$ICON_SESSION_SUSPENDED` =  (nf-md-network_outline, f0c9d)
- `$ICON_SESSION_CRASHED` =  (nf-md-close_network, f015b)
- `$ICON_MANAGER` =  (nf-md-network_pos, f1acb)
- `$ICON_HELP` =  (nf-md-help_network, f06f5)

**Fallback mode (non-NF):** See `src/theme-config.sh` for ASCII replacements

### Implementation Requirements

1. **NO FLICKER** - Use native tmux format strings only (NO external scripts)
2. **Dynamic session detection** - Show/hide tabs based on session existence
3. **Auto-grouping** - Collapse consecutive suspended sessions (F8-F10 → ` 8-10`)
4. **Shadow effect** - Active tab has subtle 3D depth using background colors
5. **Responsive layout** - Adjust spacing based on terminal width (future)

---

## Active vs Suspended Terminals

### Default Configuration

**Active terminals (5):**
- Consoles 1-5 are created on startup
- Available immediately via F1-F5
- Visible in status bar with active styling

**Suspended terminals (5):**
- Consoles 6-10 are NOT created by default
- Can be activated on demand
- Show as "available" in status bar (dimmed/empty icons)

### User Configuration

**Settings location:** TBD (likely in config file or F11 Manager → Settings)

**Configurable options:**
- Number of active terminals (default: 5)
- Can increase up to 10 active terminals
- Can decrease to fewer active terminals
- Setting to 0 or "all" = all 10 active

**Questions:**
- Where to store this config? (`~/.vps/sessions/config.yaml`?)
- How to activate suspended terminal? (Auto-create on F6-F10 press?)
- Performance impact of 10 active sessions? (Minimal, but test)

---

## Manager Menu (F11)

### Purpose

**Interactive TUI for terminal management**

**Functionality:**
- List all active terminals (interactive, like tabs on bottom but with more info)
- Show terminal status (active, suspended, running processes)
- Actions: restart, kill, activate suspended terminal
- Show keyboard shortcuts
- Access settings (configure active terminal count)

### Technical Implementation

**File:** `src/manager-menu.sh`
**UI Library:** `gum` (interactive TUI)
**Session:** Creates dedicated "manager" session
**Behavior:** Reuses existing session if already open

**Features:**
- Interactive list of all consoles
- Show running processes per console
- Restart/Kill actions
- Settings menu
- Keyboard shortcut reference

**See:** `ARCHITECTURE.md` lines 77-162 for detailed spec

### Current Issue

**CRITICAL:** F11 currently **exits immediately** instead of staying open

**Investigation needed:**
- Why does manager session close?
- Check `src/manager-menu.sh` script
- Verify tmux session creation
- Compare with F12 help (which works)

**Action:** Fix F11 manager session persistence before implementing new features

---

## Help Reference (F12)

### Purpose

**Static help text - keyboard shortcuts reference**

**Functionality:**
- Display all F-key bindings
- Show additional shortcuts (Ctrl+H, Ctrl+R, etc.)
- Basic usage instructions
- Non-interactive (read-only)

### Technical Implementation

**File:** `src/help-reference.sh`
**UI:** Simple text display (no interaction required)
**Session:** Creates dedicated "help" session
**Behavior:** Reuses existing session if already open

**Current status:** ✅ Working correctly

**See:** `F12-ISSUES-LOG.md` for implementation history

---

## Icons & Iconography

### Icon Set: Nerd Fonts (NF)

**Assumption:** User has Nerd Fonts installed
**Fallback:** TBD - consider icon-free mode for users without NF

### Icon Mapping

**Application & System:**
- **pTTY logo:** `` (nf-md-console_network_outline - f0c60)
- **Server name:** `` (nf-md-server_network - f048d)
- **Username:** `` (nf-md-account_network_outline - f0be6)

**Terminal States:**
- **Active terminal:** `` (nf-md-play_network - f08a9)
- **Suspended/killed terminal:** `` (nf-md-close_network_outline - f0c5f)
- **Available terminal:** `` (nf-md-network_outline - f0c9d)

**Special Functions:**
- **Manager (F11):** `` (nf-md-table_network - f13c9) or `` (nf-md-network_pos - f1acb)
- **Help (F12):** `` (nf-md-help_network_outline - f0c8a)

### Network Icon Theme

**Why network icons?**
- pTTY is designed for remote SSH sessions
- Network theme emphasizes connectivity and persistence
- Consistent visual metaphor (terminals = network nodes)

**Complete NF network icon set available in:** `docs/ICONS.md`

---

## Open Questions

### 1. Ctrl+Esc and Ctrl+Del bindings ✅ RESOLVED

**Decision:** YES - implement both

**Implementation:**
- `Ctrl+Esc` = Detach (safe disconnect)
- `Ctrl+Del` = Restart terminal (same popup as Ctrl+R)

**Status:** ✅ Approved - ready for implementation

### 2. Suspended Terminal Activation ✅ RESOLVED

**Decision:** Hybrid approach - popup + manager view

**Implementation:**
- **On F6-F10 press:** Show popup asking if user wants to activate (it's inactive, you can enable it)
- **Alternative method:** Activate via F11 Manager menu
- **Both methods available** - user can choose preferred workflow

**Behavior:**
- Popup is informative (shows it's inactive state)
- User can confirm activation
- Also manageable through F11 Manager

**Status:** ✅ Approved - ready for implementation

### 3. Configuration File Location ✅ RESOLVED

**Decision:** `~/.ptty.conf`

**Location:** `~/.ptty.conf` (dotfile in home directory)

**Settings to expose:**
- Number of active terminals (default: 5, max: 10)
- Icon mode (NF icons vs plain text fallback)
- Default console names/purposes
- Other user preferences

**Status:** ✅ Approved - ready for implementation

### 4. F11 Manager Detach Issue 🔴 CRITICAL

**Problem:** F11 does detach instead of staying in manager session

**User report:** "F11 ona się nie zamyka, ona znam rozłącza tmux jakby robił detach"

**Root cause investigation needed:**
- Check `src/manager-menu.sh` script
- Why does it trigger detach instead of staying in session?
- Compare with F12 help-reference.sh (which works correctly)

**Critical because:** Can't implement Manager features until session stays open

**Next steps:**
1. Investigate why manager session triggers detach
2. Fix manager-menu.sh to stay in session like help-reference.sh
3. Then implement full Manager Menu vision

**Status:** 🔴 BLOCKING - Must fix before implementing Manager vision

### 5. Status Bar & Manager Menu Vision ⏳ IN PROGRESS

**User requirement:** "Najpierw zróbmy spec na wszystko i dokładną wizję a później będziemy dzielili na etapy. Nie chcę robić etapami tylko chcę mieć skończoną wizję na całość i ją skończyć."

**Action required:**
1. Create complete Manager Menu (F11) specification
   - Full TUI design with gum
   - All features and interactions
   - Complete visual mockup
2. Create complete Status Bar specification
   - Tab shadows implementation
   - Active vs suspended visual states
   - Color scheme
   - Icon placement
   - Complete layout mockup

**Status:** ⏳ Need to create complete vision specs before implementation

**Next step:** Ask user for Manager Menu requirements and create comprehensive spec

---

## References

- **Full naming convention:** `docs/naming.md`
- **Icon reference:** `docs/ICONS.md`
- **Architecture details:** `ARCHITECTURE.md`
- **F12 implementation history:** `F12-ISSUES-LOG.md`
- **Status bar flickering fix:** `techdocs/lesson-01-status-bar-flickering.md`

---

## Changelog

**2025-10-08:** Initial unified specification created
- Consolidated conflicting docs (README, TODO, ICONS, ARCHITECTURE)
- Defined 5 active + 5 suspended terminal model
- Clarified F11 Manager vs F12 Help distinction
- Documented open questions for user decision

---

**END OF SPECIFICATION**

All implementation work MUST reference this document.
All documentation MUST align with this specification.
All conflicts MUST be resolved by updating this SPEC.md first.
