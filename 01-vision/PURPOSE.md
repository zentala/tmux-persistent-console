**Purpose:** Explain WHY pTTY exists and what problem it solves

---

# pTTY - Purpose & Values

## 💡 The Problem

**Remote development over SSH has a critical flaw: disconnection loses everything.**

### What Happens When You Disconnect:
- 🔴 Long-running jobs terminate
- 🔴 Active debugging sessions vanish
- 🔴 Carefully arranged terminal layouts destroyed
- 🔴 Work context lost
- 🔴 Frustration and wasted time

### Common Scenarios:
- **Network issues** - Unstable WiFi, ISP problems
- **Computer sleep** - Laptop closes, system suspends
- **Location changes** - Moving from café to home, office to remote
- **Intentional disconnects** - Need to close laptop but keep work running

**You can't be mobile. You can't disconnect. You're chained to the connection.**

---

## 🎯 The Solution

**pTTY = Persistent tmux wrapper that just works.**

### What pTTY Provides:
- ✅ **10 persistent sessions** (F1-F10) always available
- ✅ **Instant F-key switching** (like Linux virtual consoles)
- ✅ **Safe exit protection** (prevents accidental detach)
- ✅ **Visual status bar** (see all consoles at a glance)
- ✅ **Crash detection** (know when something failed)
- ✅ **Zero configuration** (works out of the box)

### How It Works:
1. SSH to your server
2. See status bar with 10 consoles
3. Press F1-F10 to switch instantly
4. Disconnect anytime - everything persists
5. Reconnect - pick up exactly where you left off

**It's like having a desktop with multiple virtual consoles, but over SSH.**

---

## 🧠 Core Philosophy

### 1. Developer Experience (DevEx) First
**The tool should be invisible when it works.**

- No friction between thought and action
- Intuitive F-key navigation (borrowed from Linux VTs)
- Self-teaching (status bar shows you what to do)
- Get out of developer's way

### 2. "Just Works" Philosophy
**Zero configuration required to start.**

- Sane defaults for 99% of use cases
- Progressive disclosure (simple → advanced when needed)
- Graceful degradation (works without gum, without Nerd Fonts)
- No surprises, no magic, predictable behavior

### 3. Resilience Over Features
**Never lose user's work.**

- Persistent sessions survive disconnects
- Safe exit wrapper prevents accidents
- Crash detection shows what failed
- Simple, battle-tested technology (tmux + bash)

### 4. Low-Code, High-Impact
**Build with existing tools, not frameworks.**

- Bash scripts (portable, debuggable)
- tmux (proven, stable, widely available)
- Nerd Fonts (optional enhancement)
- gum (optional TUI, not required)

**Why:** Dependencies are liabilities. Use what already exists and works.

---

## 👤 Built for Real Needs

**I built this for myself because I had this exact problem.**

### My Story:
- Working remotely over SSH
- Losing sessions constantly:
  - Network dropouts
  - Laptop sleep when closing lid
  - Moving between café/home/office
  - Needing to disconnect but keep jobs running

**I couldn't be mobile. I was trapped by the connection.**

So I built pTTY - a persistent terminal that never loses my work.

### Target Users:
- **Sysadmins** managing remote servers
- **Developers** working over SSH
- **AI researchers** running long-running training
- **Anyone** who needs persistent remote sessions

---

## 🎨 Design Values

### Simplicity
- One command to start
- F-keys to navigate
- Status bar to understand
- No mental overhead

### Intuitiveness
- F1-F10 like Linux virtual terminals
- Visual feedback (status bar)
- Self-documenting (F12 for help)
- Familiar patterns

### Reliability
- Built on tmux (battle-tested)
- Bash scripts (portable)
- No exotic dependencies
- Fail gracefully

### Respect for User
- Never surprise the user
- Explicit over implicit
- Safe defaults
- Easy to understand what's happening

---

## 🚫 What pTTY Is NOT

- ❌ Not a tmux replacement (it's a wrapper)
- ❌ Not feature-rich like tmux (by design - simplicity)
- ❌ Not for tmux power users (they don't need it)
- ❌ Not a production-grade enterprise tool (yet - it's alpha)

**It's a simple, focused tool for one problem: persistent SSH sessions.**

---

## 🌟 What Makes pTTY Different

### vs. Plain tmux:
- ✅ Out-of-the-box usability
- ✅ F-key navigation (vs. Ctrl+B gymnastics)
- ✅ Visual status bar
- ✅ Safe exit protection
- ✅ Self-teaching

### vs. screen:
- ✅ Modern (tmux is actively maintained)
- ✅ Better defaults
- ✅ Visual feedback

### vs. Other tmux wrappers:
- ✅ Simpler (focused on one problem)
- ✅ Lower learning curve
- ✅ Better DevEx
- ✅ F-key navigation (unique)

---

## 💬 Philosophy in Practice

### Example: Safe Exit
**Problem:** Users type `exit` and lose session.

**Bad solution:** Block exit command (surprising).

**pTTY solution:**
- Show menu: "Do you want to detach or restart?"
- Explain what will happen
- Let user choose
- Respect user's decision

**Why:** Explicit over implicit. Educate, don't block.

### Example: Status Bar
**Problem:** Users don't know which sessions exist.

**Bad solution:** Complex dashboard with too much info.

**pTTY solution:**
- One line at bottom
- Show all 10 consoles
- Visual state (icon + color)
- Current console highlighted
- F-keys to switch

**Why:** Minimal, clear, always visible.

---

## 🎯 Success Criteria

**pTTY succeeds when:**
1. User connects and immediately understands how to use it
2. User can switch sessions without thinking
3. User disconnects without fear of losing work
4. User recommends it to colleagues

**pTTY fails when:**
1. User confused about how to navigate
2. User loses work due to tool behavior
3. User spends time configuring instead of working
4. User prefers plain tmux over pTTY

---

## 🔮 Long-term Vision

### Current: v0.x (Alpha)
Functional prototype, proving the concept works.

### Next: v1.x (Stable)
Production-ready, polished, well-documented.

### Future: v2.x (Advanced)
- CLI interface (`ptty attach 3`)
- Process monitoring (show what's running)
- Custom console names
- Templates and automation

**But always:** Simple, focused, respects user's time.

---

## 🤝 Open Source Philosophy

**pTTY is open source because:**
- I built it for myself and want to share
- Others have this problem too
- Community can improve it
- Transparency builds trust

**Contribution welcome, but:**
- Keep it simple (no feature creep)
- Maintain DevEx focus
- Respect the philosophy
- Test before submitting

---

## 📝 Summary

**Problem:** SSH disconnects lose your work.

**Solution:** Persistent tmux sessions with intuitive F-key navigation.

**Philosophy:** Developer experience, simplicity, reliability.

**Goal:** Tool that gets out of your way and just works.

---

**pTTY exists because remote development should not chain you to a connection.**
