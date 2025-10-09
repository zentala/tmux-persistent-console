**Purpose:** Design principles that guide all decisions in pTTY development

---

# pTTY - Design Principles

These principles guide every decision, from code structure to UI design to feature priority.

---

## 🎯 Core Principles

### 1. Developer Experience (DevEx) First

**The tool should be invisible when it works.**

**What this means:**
- No friction between thought and action
- Intuitive interactions (F-keys, not Ctrl+B+weird combos)
- Self-teaching (status bar, help system)
- Get out of developer's way

**In practice:**
- ✅ F1-F10 immediately switches (no delay, no menu)
- ✅ Status bar shows state without asking
- ✅ F12 help always available
- ❌ No complex configuration required
- ❌ No surprising behavior

**Test:** If user spends time thinking about the tool instead of their work, we failed.

---

### 2. "Just Works" Philosophy

**Zero configuration required to start. Sane defaults for 99% of users.**

**What this means:**
- Works out of the box
- Progressive disclosure (simple → advanced)
- Graceful degradation (works without optional deps)
- No surprises, predictable behavior

**In practice:**
- ✅ SSH + one command = working pTTY
- ✅ Default config covers most use cases
- ✅ Optional features degrade gracefully (no gum? fallback works)
- ❌ No required configuration file
- ❌ No mandatory dependencies beyond tmux

**Test:** Can a new user be productive in 60 seconds?

---

### 3. Resilience Over Features

**Never lose user's work. Stability > novelty.**

**What this means:**
- Sessions persist through disconnects
- Safe defaults (ask before destructive actions)
- Fail gracefully (show error, don't crash)
- Recovery mechanisms (crash detection)

**In practice:**
- ✅ Persistent tmux sessions
- ✅ Safe exit wrapper (prevents accidents)
- ✅ Crash detection with dumps
- ✅ Confirmation for restart actions
- ❌ No silent failures
- ❌ No data loss

**Test:** Can you disconnect at any time without fear?

---

### 4. Low-Code, High-Impact

**Build with existing, proven tools. Dependencies are liabilities.**

**What this means:**
- Bash scripts (portable, debuggable, universal)
- tmux (battle-tested, stable, widely available)
- Optional enhancements (gum, Nerd Fonts) degrade gracefully
- No exotic frameworks

**In practice:**
- ✅ Pure bash + tmux core
- ✅ gum optional (fallback to bash read)
- ✅ Nerd Fonts optional (fallback to ASCII)
- ❌ No Node.js, Python, Go dependencies for core
- ❌ No complex build systems

**Test:** Can it run on a fresh Debian/Ubuntu without installing new languages?

---

### 5. Explicit Over Implicit

**User should always know what's happening and why.**

**What this means:**
- Clear feedback for every action
- Explain consequences before destructive operations
- No magic, no hidden state
- Predictable behavior

**In practice:**
- ✅ Safe exit menu explains options
- ✅ Status bar shows current state
- ✅ Manager shows what will happen (Attach, Restart)
- ❌ No silent mode changes
- ❌ No "clever" automatic behaviors

**Test:** Can user predict what will happen before action?

---

### 6. Progressive Disclosure

**Simple by default, powerful when needed.**

**What this means:**
- Core features immediately visible
- Advanced features discoverable
- Layered complexity (beginner → intermediate → expert)
- Don't overwhelm new users

**In practice:**
- ✅ F1-F10 switching = main feature (obvious)
- ✅ F11 Manager = intermediate (one keypress away)
- ✅ Config file = advanced (for power users)
- ❌ No feature overload in UI
- ❌ No 50-option menus

**Test:** Can user accomplish 80% of tasks knowing only F-keys?

---

### 7. Respect User's Time

**Every interaction should be fast and purposeful.**

**What this means:**
- Instant feedback (<100ms for UI)
- No unnecessary steps
- No waiting for things to load
- Keyboard-first (mouse optional)

**In practice:**
- ✅ F-key switching instant
- ✅ Status bar updates without flicker
- ✅ All actions keyboard-accessible
- ❌ No loading screens
- ❌ No forced mouse usage

**Test:** Does any action feel sluggish?

---

### 8. Conventions Over Configuration

**Follow established patterns. Don't reinvent.**

**What this means:**
- F1-F10 like Linux virtual terminals
- tmux keybindings where appropriate
- Standard UNIX conventions
- Familiar patterns

**In practice:**
- ✅ F-keys follow Linux VT pattern
- ✅ Ctrl+C, Ctrl+D work as expected
- ✅ Config file in ~/.ptty.conf (standard location)
- ❌ No weird custom conventions
- ❌ No fighting muscle memory

**Test:** Do experienced Linux users feel at home?

---

## 🎨 Design Values

### Simplicity
**Do one thing well. Resist feature creep.**

- Focus on persistent SSH sessions
- Don't try to replace tmux
- Don't try to be a full IDE
- Stay in your lane

### Intuitiveness
**Tool should teach itself.**

- Visual feedback (status bar)
- Discoverable features (F12 help)
- Self-documenting (clear labels)
- Natural interactions

### Reliability
**Work every time, the same way.**

- Predictable behavior
- No race conditions
- Proper error handling
- Tested before release

### Transparency
**No hidden magic, no surprises.**

- Clear what's happening
- Errors explained
- State visible
- Actions explicit

---

## 🚫 Anti-Patterns to Avoid

### 1. Magic Behavior
**Bad:** Automatically restart crashed consoles without asking
**Why:** Surprising, user loses control
**Good:** Detect crash, show in status bar, let user decide

### 2. Feature Creep
**Bad:** Add email notifications, Slack integration, AI suggestions
**Why:** Scope creep, maintenance burden, complexity
**Good:** Stay focused on persistent sessions

### 3. Configuration Hell
**Bad:** Require 50-line config file to start
**Why:** Barrier to entry, maintenance burden
**Good:** Works with zero config, customize if wanted

### 4. Silent Failures
**Bad:** Session fails to create, no error shown
**Why:** User doesn't know what went wrong
**Good:** Show clear error message with solution

### 5. Dependency Bloat
**Bad:** Require Node.js + 500MB of node_modules
**Why:** Deployment complexity, version conflicts
**Good:** Bash + tmux, optional enhancements

### 6. Clever Code
**Bad:** Bash one-liners that are impossible to debug
**Why:** Maintenance nightmare
**Good:** Clear, readable code even if longer

---

## ⚖️ Trade-off Decisions

### When Principles Conflict:

**Simplicity vs. Features**
→ Choose simplicity. Features can wait.

**Performance vs. Readability**
→ Choose readability unless performance critical.

**Convenience vs. Safety**
→ Choose safety. Confirm destructive actions.

**Innovation vs. Conventions**
→ Choose conventions. Users know them already.

**Power vs. Accessibility**
→ Choose accessibility. Power users can configure.

---

## 📏 Decision Framework

**When adding a feature, ask:**

1. **Does it solve a real problem?** (not hypothetical)
2. **Does it align with core principles?** (check above)
3. **Is it the simplest solution?** (avoid over-engineering)
4. **Can we maintain it long-term?** (complexity debt)
5. **Does it respect existing users?** (breaking changes?)

**If any answer is "no" → reconsider or redesign.**

---

## 🎯 Measuring Success

**We're successful when:**
- User connects and immediately understands (intuitive)
- User doesn't think about the tool (invisible when working)
- User disconnects without worry (resilient)
- User recommends it to colleagues (valuable)

**We're failing when:**
- User confused about navigation (not intuitive)
- User loses work (not resilient)
- User spends time configuring (not "just works")
- User prefers plain tmux (not adding value)

---

## 🔗 Related

- **[PURPOSE.md](PURPOSE.md)** - Why we exist
- **[ROADMAP.md](ROADMAP.md)** - Where we're going
- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - What we're building

---

**These principles are not rules to follow blindly, but values to guide decisions.**

When in doubt, ask: "Does this make the developer's life easier or harder?"
