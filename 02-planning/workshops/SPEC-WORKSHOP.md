# pTTY - Specification Workshop

**Date:** 2025-10-08
**Purpose:** Complete functional & UX specification before implementation
**Participants:** Solution Architect, Tech Lead, Business Analyst, UX Designer

---

## Internal Team Discussion

### Business Analyst (BA):
"Okay team, let's align on the vision. Our user created pTTY because he was losing SSH sessions during:
- Unstable WiFi in cafes
- Laptop going to sleep
- Moving between locations
- Long AI CLI sessions (Claude Code, OpenAI Codex)

He wants something that 'just works' out of the box. No complex config. F-keys like Linux TTY switching. The core value is **persistence + convenience**."

### UX Designer (UX):
"I see two critical UX touchpoints we need to spec out:

1. **Status Bar (always visible)** - This is the user's dashboard. They see it 100% of the time. Needs to show:
   - Where am I? (current console)
   - What's available? (F1-F5 active, F6-F10 suspended)
   - How do I navigate? (F11 Manager, F12 Help)

2. **Manager Menu (F11)** - This is the control center. User presses F11 when they want to:
   - See all consoles at once
   - Manage (restart, kill, activate suspended)
   - Configure settings
   - Get oriented

These two need to work together. Status bar = passive info. Manager = active control."

### Solution Architect (SA):
"Let's talk Manager Menu architecture. Looking at ARCHITECTURE.md, we have:
- File: `src/manager-menu.sh`
- UI: `gum` interactive TUI
- Session: Dedicated 'manager' session

But there's a critical bug - it detaches instead of staying open. Tech Lead, what's your take?"

### Tech Lead (TL):
"I'll need to investigate manager-menu.sh vs help-reference.sh. F12 help works, F11 doesn't. Probably a script exit condition or tmux binding issue.

But before we fix it, we need to know: **What should Manager Menu DO?** We can't implement a solution without requirements.

From ARCHITECTURE.md lines 77-162, I see concepts like:
- Interactive list of consoles
- Show running processes
- Restart/Kill actions
- Settings menu
- Keyboard shortcuts

But this is vague. We need specifics."

### BA:
"Exactly. Let me frame the business requirements. User said:
> 'F11 to taki TUI. Mam interaktywną listę, coś jak te zakładki na dole ale może więcej info o opcji np że można zrestartować czy zabić, jakie skróty do czego etc.'

So Manager Menu needs to be:
1. **Interactive list** (like tabs but richer)
2. **Show more info** per console (status, processes, shortcuts)
3. **Actions available** (restart, kill, activate)
4. **Keyboard shortcuts displayed**

This is more than just 'session list'. It's a full management interface."

### UX:
"Let me sketch what this could look like with `gum`:

```
┌─────────────────────────────────────────────────────────────┐
│             pTTY - Console Manager (F11)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [•] F1: Console-1 (Claude Code)          [Active]         │
│      Process: claude-code                                   │
│      Shortcuts: Ctrl+F1 (direct) | Ctrl+R (restart)         │
│      Actions: [Restart] [Kill] [Attach]                     │
│                                                             │
│  [•] F2: Console-2 (AI CLI)               [Active]         │
│      Process: bash                                          │
│      Shortcuts: Ctrl+F2 (direct) | Ctrl+R (restart)         │
│      Actions: [Restart] [Kill] [Attach]                     │
│                                                             │
│  ... (F3-F5 similar)                                        │
│                                                             │
│  [○] F6: Console-6                        [Suspended]       │
│      Not created yet                                        │
│      Shortcuts: Ctrl+F6 (activate) | F11 → Activate         │
│      Actions: [Activate]                                    │
│                                                             │
│  ... (F7-F10 similar)                                       │
│                                                             │
│  Navigation: ↑↓ (select) | Enter (action) | ESC (close)    │
│  Shortcuts: [S]ettings | [H]elp | [Q]uit                   │
└─────────────────────────────────────────────────────────────┘
```

But I have questions..."

### SA:
"Hold that thought. Before we design the interface, we need functional requirements. Let me organize what we need to decide:

**Category 1: Console Display**
- What info to show per console?
- How to show status (active/suspended/dead)?
- Show running processes? (top process, count, or all?)
- Show resource usage? (CPU, memory?)

**Category 2: Actions**
- What actions per console?
- Restart, Kill, Activate - anything else?
- Rename console?
- Change console purpose/description?
- View console logs?

**Category 3: Global Features**
- Settings menu?
- Bulk actions? (restart all, kill all suspended?)
- Create new console beyond 1-10?
- Export console sessions?

**Category 4: Navigation & UX**
- How to select console? (arrow keys, number keys, mouse?)
- How to perform action? (Enter, hotkey, submenu?)
- How to exit? (ESC, Q, back button?)
- Keyboard shortcuts shown where?

**Category 5: Status Bar Integration**
- Should Manager update status bar live?
- Click console in status bar → open Manager on that console?
- Visual consistency between Manager and status bar?"

### TL:
"And technical constraints I need to know:

**Category 6: Technical Implementation**
- `gum choose` or `gum filter` or custom layout?
- Real-time updates or static snapshot?
- How to detect running processes? (`tmux list-panes -F` or `ps`?)
- How to handle console that crashed/died?
- Manager session itself - can we restart it? Kill it?

**Category 7: Performance**
- How often to refresh console info?
- What if user has 10 active consoles with heavy processes?
- Caching strategy?

**Category 8: Edge Cases**
- What if user opens Manager from console-1, then kills console-1 from Manager?
- What if console doesn't exist (user manually killed it)?
- What if tmux server is dying?
- Can user open multiple Manager instances?"

### BA:
"Good questions. Now for the Status Bar, similar exercise.

Looking at ICONS.md and past commits, the vision is:
```
[ pTTY ][ user @ host ]  F1  F2  F3 ... F7  [F8-10]  󰒓 F11 Manager   F12 Help
```

But we need details:

**Category 9: Status Bar Layout**
- Exact spacing and padding?
- Separators between sections? (| or spaces or colors?)
- How to show current active console? (highlight, bold, color, icon?)
- Tab shadows - how? (tmux doesn't do CSS box-shadow...)

**Category 10: Status Bar Icons**
- Icon per console always visible?
- Icon changes based on state? (active, suspended, running process, idle?)
- Icon from ICONS.md: which one per state?
- Fallback if no Nerd Fonts?

**Category 11: Status Bar Behavior**
- Click console number → switch to it? (tmux mouse support)
- Hover info? (tmux doesn't really do this...)
- Status bar updates when console state changes?
- Show notifications? (console crashed, new process started?)

**Category 12: Status Bar Information Density**
- Show console names/purposes? ('Claude Code', 'AI CLI'?)
- Show process count? (e.g., 'F1 (3)' = 3 processes?)
- Show alerts? (e.g., 'F2 ⚠' = error in console?)
- Max width? (what if terminal is narrow?)"

### UX:
"I also want to understand user journeys:

**User Journey 1: First-time user**
- User SSHs to server
- Sees status bar with F1-F12
- Presses F12 → sees help with shortcuts
- Presses F1 → in console-1
- Types commands, sees it works
- Presses F11 → sees all consoles listed
- Understands the system

**User Journey 2: Power user**
- User has 5 active consoles running different tasks
- SSH disconnects (WiFi drop)
- User reconnects
- Sees status bar, knows all consoles still alive
- Presses F3 → back to where they were
- Continues work

**User Journey 3: Activating suspended console**
- User has F1-F5 active
- Needs more space for new project
- Presses F6 → popup: 'Console-6 is suspended. Activate?'
- User confirms → console-6 created
- Status bar updates showing F6 as active

**User Journey 4: Managing consoles**
- User has messy console state
- Presses F11 → Manager Menu
- Sees: F1 (active), F2 (crashed), F3 (active), F4 (zombie process)
- Restarts F2
- Kills F4
- Exits Manager
- System is clean

Do these journeys match the vision?"

### SA:
"Great. Now let's create the question list for the user. I'll organize by priority:

---

## Questions for User

### 🔴 CRITICAL - Manager Menu Core Features

**Q1: Manager Menu - Console Information**
What information should we show for each console in Manager Menu?
- [ ] Console number (F1, F2, etc.)
- [ ] Console name/purpose ('Claude Code', 'AI CLI', etc.) - editable?
- [ ] Current status (Active, Suspended, Crashed, Zombie?)
- [ ] Running process (top process, all processes, or process count?)
- [ ] Resource usage (CPU %, memory %, or skip this?)
- [ ] Uptime (how long console has been running?)
- [ ] Last activity (when was last command executed?)
- [ ] Other?

**Q2: Manager Menu - Available Actions**
What actions should be available per console?
- [ ] Attach (switch to this console)
- [ ] Restart (kill and recreate session)
- [ ] Kill (destroy session permanently)
- [ ] Activate (for suspended consoles F6-F10)
- [ ] Rename (change console name/purpose)
- [ ] View logs (see console history/output)
- [ ] Clone (duplicate console with same state)
- [ ] Other?

**Q3: Manager Menu - Global Features**
What global features should Manager Menu have?
- [ ] Settings menu (configure active console count, icons, etc.)
- [ ] Bulk actions (restart all, kill all suspended, etc.)
- [ ] Create new console (beyond F1-F10?)
- [ ] Export/Import console state
- [ ] System info (tmux version, server status, etc.)
- [ ] Keyboard shortcuts reference (or just link to F12?)
- [ ] Other?

**Q4: Manager Menu - Navigation UX**
How should user interact with Manager Menu?
- Arrow keys + Enter to select action?
- Number keys (1-9, 0) to jump to console?
- Letter hotkeys (R=restart, K=kill, A=activate)?
- Mouse support (click actions)?
- Tab key to switch between sections?
- How to exit? (ESC, Q, Ctrl+C, or all of above?)

**Q5: Manager Menu - Visual Design**
What should Manager Menu look like?
- Full-screen TUI or popup/panel?
- Show all 10 consoles always, or only active + option to show suspended?
- Group by status (Active / Suspended / Crashed)?
- Color coding (green=active, gray=suspended, red=crashed)?
- Box drawing (like my mockup above) or simple list?
- Show Manager session itself in list, or hide it?

### 🟡 HIGH - Status Bar Design

**Q6: Status Bar - Current Console Highlight**
How to show which console is currently active?
- Bold text (e.g., **F1** vs F2)?
- Different color (e.g., F1 in green, others in gray)?
- Icon change (e.g., active= inactive=)?
- Background highlight (e.g., [F1] with background)?
- Underline, border, or other visual?
- Combination of above?

**Q7: Status Bar - Console State Icons**
Should each console have a state icon, and what icons?
- Active console:  (terminal icon) or  (play/running)?
- Suspended console:  (paused) or  (empty/available)?
- Crashed/Dead console:  (error) or  (close)?
- No icon, just number (F1, F2)?
- Icon changes based on state?

**Q8: Status Bar - Information Density**
What info to show in status bar per console?
- Just number: `F1 F2 F3`
- Number + icon: ` F1  F2  F3`
- Number + name: `F1:Claude F2:AI F3:Dev` (if enough space)
- Number + process count: `F1(3) F2(1) F3(0)` (3=3 processes running)
- Number + status indicator: `F1• F2• F3○` (•=active, ○=idle)
- Minimal by default, more info on hover/click?

**Q9: Status Bar - Suspended Consoles (F8-F10)**
How to show F8-F10 in status bar?
- Individual: ` F8  F9  F10` (takes more space)
- Collapsed: `[F8-10]` or `[+3 more]` (saves space)
- Hidden unless activated (only show when user enables them)
- Show count: `[+5 suspended]` if F6-F10 all inactive
- Other?

**Q10: Status Bar - Tab Shadows / Visual Style**
What visual style for status bar?
- Flat (no shadows, simple text)
- Tabs with separators: `[ F1 ] | [ F2 ] | [ F3 ]`
- Pseudo-3D (tmux limited, but we can try with box drawing: `┌─┐`)
- Color gradients (tmux supports 256 colors)
- Current tab 'pops out' visually somehow?
- Consistent with Manager Menu design?

### 🟢 MEDIUM - Configuration & Behavior

**Q11: Console Naming**
Should consoles have custom names?
- Default names: F1='Console-1', F2='Console-2', etc.
- User-defined names: F1='Claude Code', F2='AI CLI', etc.
- Edit names via Manager Menu → Rename action?
- Edit names via config file `~/.ptty.conf`?
- Show names in status bar (if space allows)?

**Q12: Console Purpose/Description**
Should consoles have descriptions (metadata)?
- Simple name only (answered in Q11)
- Name + description (e.g., F1='Claude Code' + 'Main AI development session')
- Predefined templates (AI Development, Testing, Monitoring, etc.)?
- Free-form text?
- Shown where? (Manager Menu only, or also in status bar on hover?)

**Q13: Default Active Console Count**
How many consoles active by default?
- Current decision: 5 (F1-F5)
- Allow user to configure in `~/.ptty.conf`?
- Min 1, max 10?
- If user sets to 0 or 'all', all 10 are active?
- Can change on-the-fly via Manager → Settings?

**Q14: Suspended Console Auto-Creation**
When user presses F6-F10 (suspended console):
- Show popup: "Console-6 is suspended. Activate now? [Y/n]"
- Auto-create silently (no popup)?
- Create but show notification "Console-6 activated"?
- Always ask first time, then remember preference?
- Configurable in settings?

**Q15: Console Persistence**
Should console state persist across reboots?
- Console exists until explicitly killed?
- Auto-recreate on tmux server restart (systemd service)?
- Save console state (processes, history) to disk?
- Just recreate empty consoles on boot?
- Let tmux handle it (sessions die with server)?

### 🔵 LOW - Advanced Features

**Q16: Process Monitoring**
How much process info to show?
- Top process only (e.g., 'claude-code')?
- All processes (e.g., 'bash, vim, htop')?
- Process count only (e.g., '3 processes')?
- No process info (keep it simple)?
- Real-time updates or snapshot?

**Q17: Resource Usage**
Show CPU/memory usage per console?
- Yes, show in Manager Menu (e.g., 'F1: 5% CPU, 200MB RAM')
- Yes, show in status bar if high (e.g., 'F1⚠ 90% CPU')
- No, too complex and resource-heavy
- Optional, configurable in settings

**Q18: Notifications / Alerts**
Should pTTY notify user of events?
- Console crashed → show alert in status bar (F1⚠)
- Process exited → notification
- High resource usage → warning
- No notifications, user checks Manager Menu manually
- Configurable per event type?

**Q19: Console Lifecycle Events**
What happens when console crashes or dies?
- Auto-restart console?
- Mark as crashed in status bar, wait for user action?
- Send notification, keep dead console in list?
- Remove from list automatically?
- Configurable behavior?

**Q20: Manager Session Management**
What about the Manager session itself?
- Can user kill Manager session?
- Can user restart Manager?
- Show Manager session in console list, or hide it?
- F11 from Manager → close Manager or do nothing?
- Multiple Manager instances allowed, or singleton?

**Q21: Help Integration**
How do Manager and Help (F12) work together?
- Manager has 'Help' button → opens F12?
- Manager shows inline help (keyboard shortcuts)?
- F12 from Manager → switch to Help session?
- Separate or integrated?

**Q22: Settings Menu**
What settings should be editable in Manager → Settings?
- Active console count (1-10)
- Icon mode (NF icons on/off)
- Console names/purposes
- Auto-create suspended consoles (Y/n)
- Notification preferences
- Status bar layout (full/minimal)
- Color scheme (dark/light/custom)
- Other?

**Q23: Bulk Actions**
Should Manager support bulk operations?
- Restart all active consoles?
- Kill all suspended consoles?
- Activate all suspended consoles (F6-F10)?
- Export all console states?
- Dangerous actions require confirmation?

**Q24: Click Interaction**
Should status bar/Manager support mouse clicks?
- Click console number in status bar → switch to it?
- Click action button in Manager → execute action?
- Click-and-drag to reorder consoles?
- No mouse support (keyboard only)?
- Mouse optional, all features available via keyboard?

**Q25: Keyboard Shortcuts Display**
Where to show keyboard shortcuts?
- F12 Help (already planned)
- Manager Menu (inline, bottom of screen)
- Status bar (e.g., 'F11:Manager' shows the key)
- Popup on Ctrl+H (already implemented)
- All of above?

---

## Summary

**Total questions: 25**

**Critical (answer first): Q1-Q5** - Manager Menu core
**High (answer next): Q6-Q10** - Status Bar design
**Medium (can defer): Q11-Q15** - Configuration & behavior
**Low (nice to have): Q16-Q25** - Advanced features

**Process:**
1. User answers questions (can skip low priority for now)
2. We create detailed specification document
3. User reviews and approves spec
4. We implement complete vision (no incremental phases)

**Ready to proceed?**
