# pTTY - Naming & Brand Identity

**Version:** v0.2
**Last Updated:** 2025-10-09
**Purpose:** Define project naming conventions, brand identity, and terminology

---

## 🎯 Final Decision: **PersistentTTY (pTTY)**

### Core Name
**Full name:** PersistentTTY
**Short name:** pTTY
**CLI/filesystem:** ptty (lowercase)

### Meaning
- **Persistent + TTY** = Terminal that never dies
- **TTY** = "teletype terminal" (classic Unix terminal name)
- Pronunciation: *persistent-tee-tee-why*
- Short, memorable, Unix-native feel

---

## 🧠 Brand Essence

**Core Promise:**
> "Your permanent TTY — the shell that never dies."

**Taglines:**
- "Attach once. Stay forever."
- "Resilient virtual console for SSH workflows."
- "Persistent SSH workspace for long-running jobs."
- "The shell that survives disconnects."

**Target Audience:**
- Sysadmins managing remote servers
- Developers working over SSH
- AI researchers running long jobs
- Anyone who needs persistent remote sessions

---

## 🏷️ Naming Conventions

### Project Identity
- **Display name:** pTTY
- **Full name:** PersistentTTY
- **CLI binary:** `ptty`
- **Daemon:** `pttyd` (future)
- **Config file:** `~/.ptty.conf`

### Repository & Web
- **GitHub:** `github.com/zentala/tmux-persistent-console` (current)
- **Future repo:** `github.com/zentala/ptty`
- **Website ideas:** `ptty.dev`, `persistenttty.io`

### In Code
- **Namespace:** `PTTY_*` for environment variables
- **Functions:** `ptty_*` prefix
- **Shell scripts:** `ptty-*.sh`

---

## 📚 Terminology

### Console States
- **Active** - Console running with tmux session
- **Suspended** - Console slot available but not created
- **Crashed** - Console terminated unexpectedly

### Components
- **Console** - Single tmux session (F1-F10)
- **Manager** - F11 interactive menu
- **Help** - F12 reference guide
- **Status Bar** - Bottom bar showing all consoles

### User Actions
- **Attach** - Connect to existing console
- **Activate** - Create and start suspended console
- **Detach** - Disconnect from session (safe)
- **Restart** - Kill and recreate console

---

## 🧩 Keyword Families

These keyword groups informed the naming decision:

### 1️⃣ Persistence & Continuity
**permanent**, **persist**, **stay**, **keep**, **hold**, **alive**, **resume**, **lasting**, **forever**, **immortal**
> Evoke reliability, uptime, durability

### 2️⃣ Terminal Domain
**tty**, **term**, **shell**, **console**, **vterm**, **cli**, **session**
> Unix-native, familiar to sysadmins

### 3️⃣ Virtualization / Multiplexing
**virtual**, **multi**, **hub**, **mux**, **pane**, **deck**, **matrix**, **switch**
> Multiple terminals in one

### 4️⃣ Service Layer
**daemon**, **core**, **svc**, **engine**, **system**, **orchestrator**
> Background service, always-on

### 5️⃣ Human / Workspace
**workspace**, **env**, **station**, **base**, **dock**, **nest**, **home**
> Personal, daily-use tool

---

## 🔄 Alternative Names Considered

| Name | Meaning | Decision |
|------|---------|----------|
| **Permashell** | Permanent shell | Too generic, less Unix feel |
| **StayTTY** | Stay + TTY | Good but less clear |
| **PermaTTY** | Permanent TTY | Similar but "Persistent" more accurate |
| **TermKeep** | Terminal keeper | Vague purpose |
| **ShellHold** | Shell that holds | Not clear enough |
| **AliveTTY** | Alive console | Literal but weak |
| **VTermal** | Virtual terminal alive | Unclear pronunciation |

**Why pTTY won:**
- ✅ Shortest, most memorable
- ✅ Clear Unix heritage (TTY)
- ✅ Explains core feature (Persistent)
- ✅ Works well for CLI (`ptty attach`)
- ✅ Scalable for daemon (`pttyd`)
- ✅ Professional yet approachable

---

## 💬 Usage Examples

### CLI Commands (v2+ Future)
```bash
ptty up         # Start persistent shell daemon
ptty attach     # Attach to your personal TTY
ptty attach 3   # Attach to console 3
ptty new web    # Create new named console
ptty restart 5  # Restart console 5
ptty status     # Show all console states
ptty gui        # Toggle status bar
```

### Configuration
```bash
# Config file
~/.ptty.conf

# Environment variables
PTTY_THEME=dark
PTTY_CONSOLES=10
PTTY_ICON_ACTIVE=""
```

### In Documentation
```markdown
# Getting Started with pTTY

pTTY (PersistentTTY) provides persistent tmux sessions...

## Install
git clone https://github.com/zentala/ptty

## Usage
Press F1-F10 to switch between consoles...
```

---

## 🌍 Localization

### English (Primary)
- pTTY - Persistent Terminal
- "Your shell that never dies"

### Polish
- pTTY - Trwały Terminal
- "Terminal, który nigdy nie umiera"

---

## 🔗 Related Documentation

- **[SPEC.md](../02-planning/SPEC.md)** - Complete product specification
- **[GLOSSARY.md](../02-planning/specs/GLOSSARY.md)** - Terminology reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical implementation

---

## 📝 Naming Guidelines for Contributors

### DO:
- ✅ Use "pTTY" in all user-facing docs
- ✅ Use "PersistentTTY" when explaining full name
- ✅ Use lowercase `ptty` for CLI commands
- ✅ Use `PTTY_*` prefix for env vars
- ✅ Be consistent with terminology (console, not "terminal slot")

### DON'T:
- ❌ Mix naming styles (PTTY, Ptty, PTty)
- ❌ Use old names (Permashell, PermaTTY)
- ❌ Invent new terminology (use GLOSSARY.md)
- ❌ Change core brand without discussion

---

**This naming is final for v1.x releases. Any changes require architectural decision record (ADR).**
