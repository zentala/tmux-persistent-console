# pTTY v1 Specification - Team Discussion Round 2

**Date:** 2025-10-08
**Phase:** Complete vision specification before implementation
**Participants:** UX Engineer, DevEx Engineer, Tech Lead, Solution Architect

---

## Phase 1: UX Engineer + DevEx Engineer Discussion

### DevEx Engineer (DevEx):
"Okay, I've processed all user answers. The key insight is: **simplicity first, education second**.

User wants:
1. Clean, minimal UI that 'just works'
2. Visual feedback through icons and colors (no text bloat)
3. Keyboard-driven workflow (mouse is nice-to-have)
4. Self-teaching system - user learns shortcuts naturally

The phased approach is clear:
- **v1 (NOW):** Core functionality, simple and stable
- **v2 (NEXT):** DevEx improvements, onboarding, better config
- **v3 (FUTURE):** Advanced features, monitoring, CLI architecture

Let me organize v1 requirements..."

### UX Engineer (UX):
"I love the focus on visual communication. Let me map out the UX flows:

**Core principle:** Icons + Colors = Status (no text needed)

**Status Bar** = Passive dashboard
- Shows where you are (blue highlight + terminal bg color)
- Shows what's available (icons + colors communicate state)
- Tabs with shadows = clear visual hierarchy
- Current console feels 'connected' to terminal (same bg)

**Manager (F11)** = Active control center
- Vertical list, arrow keys up/down
- Selected console shows actions below
- Enter = most common action (attach/activate)
- Del = destructive action (restart, requires confirmation)
- ESC = go back (submenu → console list → exit to last terminal)

**Help (F12)** = Reference guide
- Static text, keyboard shortcuts
- System info
- Where to find config file

This is elegant. Let me sketch the specs..."

### DevEx:
"Before you sketch, we need **unified terminology**. User is right - we need a glossary.

**Terms to define:**
- **Console** vs **Terminal** vs **Session** - are they same or different?
- **Active** vs **Suspended** vs **Crashed** - lifecycle states
- **Attach** vs **Activate** vs **Switch** - navigation actions
- **Kill** vs **Restart** vs **Detach** - termination actions

**Shortcuts to unify:**
- Ctrl+F(n) = switch to console
- F(n) alone = context-dependent (in Manager)
- Ctrl+Esc = detach (new)
- Ctrl+Del = restart (new)
- Ctrl+H = shortcuts popup
- Ctrl+? = same as Ctrl+H (new)

**Icons to unify:**
- Active console icon
- Suspended console icon
- Crashed console icon
- Manager icon
- Help icon
- Attach/Activate action icon
- Kill/Restart action icon

Let me create GLOSSARY.md first..."

### UX:
"Good call. And we need ICONS-SPEC.md with exact icon-to-state mapping.

From ICONS.md, I see:
- `` (nf-md-play_network) = active terminal
- `` (nf-md-close_network_outline) = crashed/dead
- `` (nf-md-network_outline) = suspended/available
- `` (nf-md-table_network) = Manager (F11)
- `` (nf-md-help_network_outline) = Help (F12)

But we need:
1. **Icon variables** (so we can change themes later)
2. **Color variables** (white, blue, gray, dark red)
3. **Fallback icons** (unicode or ASCII if no Nerd Fonts)

User mentioned 'skins' - can we implement theme system?

**Theme = Shell script with variables:**
```bash
# theme.sh
ICON_ACTIVE=""
ICON_SUSPENDED=""
ICON_CRASHED=""
COLOR_ACTIVE="white"
COLOR_SELECTED="blue"
COLOR_SUSPENDED="gray"
COLOR_CRASHED="#8B0000"  # dark red
```

Then in config: `THEME="default"` (loads `~/.vps/sessions/themes/default.sh`)

This way users can create custom themes in v2/v3!"

### DevEx:
"I like it! Let's spec that out.

Now, critical question: **How do we make this self-teaching?**

User said: 'Chcę aby używanie podpowiadało na przyszłość skróty ale nie więcej.'

Translation: 'I want usage to suggest shortcuts for the future but nothing more.'

**My proposal:**

1. **MOTD on first login** (if new user):
   ```
   Welcome to pTTY (PersistentTTY)!

   Switch consoles: Ctrl+F1 to Ctrl+F12
   Manager: F11 | Help: F12 | Shortcuts: Ctrl+H

   Press F12 for complete reference.
   ```

2. **Manager (F11) shows shortcuts inline**:
   ```
   [•] F1: Claude Code              (Active)
       Actions: [Enter] Attach  [Del] Restart
   ```
   User sees: "Oh, Enter attaches, Del restarts. Got it."

3. **Help (F12) has full keyboard reference**

4. **Ctrl+H popup** - quick shortcuts (already implemented)

5. **Status bar** - if user presses Ctrl, maybe show hints? (v2 idea)

User learns: F12 first time → Manager for practice → Shortcuts muscle memory

Good?"

### UX:
"Perfect! One more critical UX element: **Kill confirmation**.

User said: 'Jak osoba kliknie kill to powinno pojawić się w tej samej linii [Cancel] [I am sure, kill console X]'

**Kill flow:**
1. User selects console in Manager
2. Presses right arrow → selects 'Restart' action
3. Presses Enter → confirmation appears
4. Same line shows: `[Cancel] [I am sure, restart console F3]`
5. Default selected: Cancel (safe)
6. User must arrow right + Enter to confirm (deliberate action)
7. Text is red or blue to signal danger

This prevents accidents. Same for CLI (`ptty kill f3` requires confirmation or `--force` flag).

Okay, ready to draft specs. Let me organize:

**Files to create:**
1. `GLOSSARY.md` - Terminology, shortcuts, icons unified
2. `ICONS-SPEC.md` - Icon mapping, colors, themes
3. `MANAGER-SPEC.md` - F11 complete spec (v1)
4. `STATUS-BAR-SPEC.md` - Status bar complete design
5. `FUTURE-VISION.md` - v2/v3 features and questions
6. `CLI-ARCH.md` - Future CLI commands architecture

Should I also create separate version docs?
- `V1-SCOPE.md` - What's in v1
- `V2-SCOPE.md` - DevEx improvements
- `V3-SCOPE.md` - Advanced features

Or keep it in FUTURE-VISION.md?"

### DevEx:
"Keep versions in FUTURE-VISION.md, but structure it clearly:

```markdown
# v1 (NOW) - Core Functionality
- Status bar with tabs + shadows
- Manager (F11) with basic actions
- Help (F12) with shortcuts
- Icons + colors for state
- Config file ~/.ptty.conf (manual edit)

# v2 (NEXT) - DevEx & Onboarding
- First-time user MOTD
- Better onboarding flow
- Ctrl+H improvements (vertical, right-side)
- Config reload without restart
- Process name in Manager
- Last active process display
- Custom console names (optional)
- Hostname/username hide options

# v3 (FUTURE) - Advanced Features
- Process monitoring (CPU, RAM, process count)
- Uptime, last activity stats
- Notifications (crashed console alert)
- Custom console config (auto-start scripts)
- CLI architecture (`ptty` commands)
- Bulk actions (with confirmation)
- Resource usage monitoring
- Console history preservation
- Clone console feature (if possible)
```

Good structure?"

### UX:
"Yes! Now let me call in Tech Lead and Solution Architect for technical review..."

---

## Phase 2: Technical Review (Tech Lead + Solution Architect)

### UX:
"Hey team, we have user requirements processed. Before we write specs, we need your input on technical feasibility and architecture."

### Tech Lead (TL):
"Show me the critical requirements. What's technically challenging?"

### DevEx:
"Here's what worries me:

**1. Status bar with 'shadows' and 'connected to terminal bg'**
- User wants: Current console tab has same bg color as terminal
- Other tabs have bg color 'between terminal bg and bar bg' (gradient effect)
- Tab shadows for 3D effect
- Challenge: tmux doesn't have CSS. How do we fake this?

**2. Theme system with variable substitution**
- Themes as shell scripts with icon/color variables
- How to load theme into tmux config?
- tmux.conf doesn't support variable substitution from external files easily

**3. Real-time Manager updates**
- User changes console state → Manager and status bar update
- How to detect console state changes?
- Polling vs event-driven?

**4. Kill confirmation in Manager**
- User presses Del → inline confirmation appears
- How to show dynamic UI in gum-based menu?
- Can gum handle stateful interactions?

**5. CLI architecture (`ptty` command)**
- `ptty f3 activate --exec="script.sh" --name="Name" --icon="icon"`
- This is v3, but we should design architecture now
- Where does CLI live? Wrapper script? Separate binary?"

### Solution Architect (SA):
"Let me address each:

**1. Status bar shadows/bg - POSSIBLE but limited**

tmux supports:
- 256 colors (can simulate gradients with careful color choice)
- Box drawing characters (┌─┐ └─┘ ┃ ─)
- Background colors (#[bg=colour234])

**Proposed solution:**
```tmux
# Current console (blue text, terminal bg)
#[fg=colour39,bg=colour235] F1 #[default]

# Adjacent tabs (lighter bg to simulate 'between')
#[fg=colour250,bg=colour236] F2 #[default]

# Far tabs (darkest bg)
#[fg=colour244,bg=colour234] F3 #[default]

# Pseudo-shadow with box chars
#[fg=colour234,bg=colour235]▐#[default]  # vertical shadow
```

**Mockup:**
```
┌─ pTTY ─┬─ user@host ─┬──────────────────────────────────────┐
│  F1 ▐│ F2 ▐│ F3 ▐│... F11:Manager │ F12:Help  │
```

Not perfect, but achievable. We iterate in v2."

### TL:
"Good. For **2. Theme system**, here's my approach:

**File structure:**
```
~/.vps/sessions/
├── themes/
│   ├── default.sh
│   ├── dark.sh
│   └── light.sh
├── src/
│   ├── tmux.conf.template
│   ├── status-bar.tmux.template
│   └── apply-theme.sh
└── ~/.ptty.conf
```

**Workflow:**
1. User sets `THEME="default"` in `~/.ptty.conf`
2. On tmux start, `apply-theme.sh` runs:
   - Sources `themes/default.sh` (loads icon/color variables)
   - Substitutes variables in `tmux.conf.template`
   - Generates final `tmux.conf`
   - Reloads tmux config

**Example theme file:**
```bash
# themes/default.sh
export PTTY_ICON_ACTIVE=""
export PTTY_ICON_SUSPENDED=""
export PTTY_ICON_CRASHED=""
export PTTY_COLOR_ACTIVE="colour39"    # blue
export PTTY_COLOR_SELECTED="colour39"  # blue
export PTTY_COLOR_SUSPENDED="colour244" # gray
export PTTY_COLOR_CRASHED="colour88"   # dark red
```

**Template:**
```tmux
# tmux.conf.template
set -g status-left "#[fg=${PTTY_ICON_ACTIVE}] pTTY"
```

This allows v3 custom themes without changing core code."

### SA:
"Excellent. For **3. Real-time updates**, we have options:

**Option A: Polling (simple, v1)**
- Manager script runs loop: every 1s check console states
- `tmux list-sessions`, parse output, update display
- Status bar uses `status-interval 5` (refresh every 5s)
- Pros: Simple, no IPC needed
- Cons: 1-5s delay, constant overhead

**Option B: Event hooks (complex, v3)**
- tmux hooks: `set-hook -g session-created 'run-shell notify.sh'`
- When console crashes, hook triggers update
- Pros: Instant, efficient
- Cons: Complex, requires careful hook management

**Recommendation:** Polling for v1, hooks for v3."

### TL:
"Agreed. For **4. Kill confirmation in gum**, I need to investigate.

`gum` has:
- `gum choose` - select from list
- `gum confirm` - yes/no prompt
- `gum input` - text input

**Possible flow:**
1. Manager uses `gum choose` to display console list
2. User selects console → script shows actions with `gum choose` again
3. User selects 'Restart' → `gum confirm 'Restart console F3?'`
4. Problem: This opens new prompt, not inline

**Alternative:**
- Use `gum filter` with dynamic list update
- When user selects action, list changes to:
  ```
  [Cancel] [I am sure, restart F3]
  ```
- Same gum window, different items

I need to prototype this. Mark as 'investigate' for v1."

### SA:
"Fair. For **5. CLI architecture**, let's design now even if we implement in v3:

**Command structure:**
```bash
ptty <command> [target] [options]
```

**Commands:**
- `ptty status` - show all console states (like Manager, but CLI)
- `ptty switch f3` - switch to console F3
- `ptty activate f7` - activate suspended console
- `ptty restart f2` - restart console (requires confirmation)
- `ptty kill f4 --force` - kill console (skip confirmation)
- `ptty config edit` - open config in $EDITOR
- `ptty config reload` - reload config without restart
- `ptty theme list` - show available themes
- `ptty theme set dark` - switch theme

**Advanced (v3):**
```bash
ptty create f10 --name="Logs" --icon="" --exec="tail -f /var/log/syslog"
ptty f3 exec "npm run dev"  # execute command in console F3
ptty export f1 > console-1-state.tar.gz  # backup console state
ptty import f1 < console-1-state.tar.gz  # restore console state
```

**Implementation:**
- Main script: `/usr/local/bin/ptty` (bash, dispatches to subcommands)
- Subcommands: `~/.vps/sessions/cli/ptty-*.sh`
- Uses tmux commands under the hood
- Confirmation prompts use `gum confirm`

Document this in `CLI-ARCH.md` with note: 'Design complete, implement in v3'

Good?"

### DevEx:
"Love it! One more thing: **F11 Manager detach issue**.

User said: 'F11 ona się nie zamyka, ona znam rozłącza tmux jakby robił detach'

TL, can you investigate `src/manager-menu.sh` vs `src/help-reference.sh`?"

### TL:
"I'll check both scripts and compare. Probably manager-menu.sh exits too early or triggers detach somehow. I'll add this to v1 blockers:

**v1 Blockers:**
1. Fix F11 Manager detach issue (CRITICAL)
2. Investigate gum confirmation flow (MEDIUM)
3. Design status bar pseudo-shadows (MEDIUM)

Once these are solved, we can implement full v1 spec."

### SA:
"Okay, let me summarize technical decisions:

**Architecture decisions:**
1. **Theme system:** Template-based, shell variable substitution
2. **State updates:** Polling (v1), hooks (v3)
3. **Status bar:** tmux colors + box chars (pseudo-shadows)
4. **Manager UI:** gum-based, investigate inline confirmation
5. **CLI:** Design now, implement v3
6. **Config:** Manual edit (v1), reload feature (v2)
7. **Persistence:** Session-level only (v1), explore state preservation (v3)

**File structure:**
```
~/.vps/sessions/
├── src/
│   ├── tmux.conf.template
│   ├── tmux.conf (generated)
│   ├── status-bar.tmux.template
│   ├── manager-menu.sh
│   ├── help-reference.sh
│   ├── apply-theme.sh
│   └── ...
├── themes/
│   ├── default.sh
│   ├── dark.sh
│   └── light.sh
├── cli/ (v3)
│   ├── ptty-status.sh
│   ├── ptty-switch.sh
│   └── ...
└── ~/.ptty.conf (user config)
```

**Config file format (`~/.ptty.conf`):**
```bash
# pTTY Configuration

# General
ACTIVE_CONSOLES=5          # Number of active consoles (1-10, default: 5)
THEME="default"            # Theme name (default, dark, light, or custom)

# Status Bar
SHOW_HOSTNAME=true         # Show hostname in status bar
SHOW_USERNAME=true         # Show username in status bar
IDENTIFIER="${USER}@${HOSTNAME}"  # Custom identifier (or empty to hide)
USE_FULL_NAME=false        # "PersistentTTY" vs "pTTY" (default: false)
SHOW_F11_LABEL=true        # Show "Manager" text next to F11
SHOW_F12_LABEL=true        # Show "Help" text next to F12
USE_NERD_FONTS=true        # Use Nerd Font icons (fallback to unicode if false)

# Behavior (v1: manual only, v2: editable in Manager)
AUTO_CREATE_SUSPENDED=false   # Auto-create suspended consoles on F6-F10 press
AUTO_RESTART_CRASHED=false    # Auto-restart crashed consoles
DUMP_CRASHED=true             # Save crashed console logs to ~/.ptty.crash.f(n).dump

# v2/v3 settings (placeholder for future)
# SHOW_PROCESS_NAME=false
# SHOW_RESOURCE_USAGE=false
# NOTIFICATION_ENABLED=false
```

Good to proceed with spec writing?"

### UX & DevEx:
"Yes! Let's create the specification documents."

---

## Specification Documents to Create

### 1. GLOSSARY.md
- Unified terminology
- Keyboard shortcuts complete reference
- Icon reference
- Color scheme reference
- State definitions

### 2. ICONS-SPEC.md
- Icon-to-state mapping
- Color-to-state mapping
- Theme system design
- Fallback icons (no Nerd Fonts)

### 3. MANAGER-SPEC.md (F11)
- Complete UX flow
- Layout mockup (ASCII art)
- Keyboard navigation
- Actions and confirmations
- Edge cases

### 4. STATUS-BAR-SPEC.md
- Complete visual design
- Tab styling (shadows, colors, spacing)
- Current console highlight
- Suspended console display
- Responsive behavior (narrow terminals)

### 5. HELP-SPEC.md (F12)
- Content structure
- Keyboard shortcuts display
- System info display
- Config file location

### 6. FUTURE-VISION.md
- v2 scope (DevEx, onboarding)
- v3 scope (advanced features)
- Open questions for future refinement

### 7. CLI-ARCH.md
- Complete CLI command structure
- Subcommand specifications
- Implementation notes (for v3)

### 8. V1-BLOCKERS.md
- F11 Manager detach issue investigation
- gum confirmation flow investigation
- Status bar pseudo-shadows design

---

## Team Decision: Ready to Write Specs

**DevEx:** "We have everything we need. Let's write the specs and present to user for review."

**UX:** "Agreed. I'll focus on visual specs (STATUS-BAR, MANAGER, ICONS). You handle architecture (GLOSSARY, CLI-ARCH, FUTURE-VISION)."

**TL:** "I'll investigate F11 issue and gum flows. Then review your specs for technical feasibility."

**SA:** "I'll create V1-BLOCKERS.md and review overall architecture coherence."

**All:** "Let's go! 🚀"

---

## Next Steps

1. Create 8 specification documents
2. Tech Lead investigates F11 detach issue
3. Present complete spec package to user
4. User reviews and approves
5. Implement v1 (no incremental phases - complete vision)

**Ready for implementation!**
