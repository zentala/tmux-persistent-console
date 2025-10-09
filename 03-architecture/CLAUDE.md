# 03-architecture - Technical Design

**Purpose:** Explain HOW pTTY is built

---

## 📁 Contents

### Main Documents
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Main technical design document
- **[ARCHITECTURE-ANALYSIS.md](ARCHITECTURE-ANALYSIS.md)** - Architecture analysis and recommendations
- **[NAMING.md](NAMING.md)** - Naming conventions and brand identity
- **[testing-strategy.md](testing-strategy.md)** - Testing strategy and coverage goals
- **[DOCUMENTATION-REVIEW.md](DOCUMENTATION-REVIEW.md)** - Documentation quality review (7.5/10)

### Architecture Decision Records ([decisions/](decisions/))
- **[001-folder-structure.md](decisions/001-folder-structure.md)** - Lifecycle-based folder organization

### Technical Deep Dives ([techdocs/](techdocs/))
- **[README.md](techdocs/README.md)** - Tech docs index
- **[lesson-01-status-bar-flickering.md](techdocs/lesson-01-status-bar-flickering.md)** - Anti-pattern: external scripts cause flicker

---

## 🎯 What Belongs Here

This folder answers "HOW do we build it?"

### Architecture = Technical Design + Decisions
- **Technical design:** Components, data flow, interactions
- **Decisions:** Why we chose this approach over alternatives
- **Lessons:** What we learned (anti-patterns, gotchas)

### Key Questions Answered
- **How does it work?** → ARCHITECTURE.md
- **Why this approach?** → decisions/
- **What NOT to do?** → techdocs/
- **What's it called?** → NAMING.md

---

## 🏗️ Current Architecture (v0.2)

### Overview
pTTY is built on **tmux** with bash scripts providing:
- Session management (create, attach, restart)
- Status bar (pure tmux format strings, no external scripts)
- Manager menu (F11) using `gum` TUI framework
- Safe exit wrapper (prevents accidental detach)

### Key Technologies
- **tmux** - Session persistence and multiplexing
- **bash** - Scripting language
- **gum** - TUI framework (optional, graceful fallback)
- **Nerd Fonts** - Icons (optional, fallback to text)

### Architecture Evolution

**v0.1 (Current):**
```
Monolithic scripts:
- src/status-bar-legacy.sh (all logic in one file)
- src/mission-control.sh (UI + logic mixed)
- src/help-reference.sh (static display)
```

**v0.2 (Target):**
```
Modular structure:
src/
├── core/          # State management, config
├── ui/
│   ├── components/  # Reusable dialogs, lists
│   ├── manager/     # F11 Manager
│   ├── help/        # F12 Help
│   └── status-bar/  # Status bar
├── actions/       # Attach, restart, detach
└── utils/         # Colors, icons, logging
```

**See:** [ARCHITECTURE-ANALYSIS.md](ARCHITECTURE-ANALYSIS.md) for complete refactoring plan

---

## 🔍 How to Use This Folder

### For Developers Implementing Features
1. Read **ARCHITECTURE.md** to understand overall design
2. Check **ARCHITECTURE-ANALYSIS.md** for refactoring plan
3. Review **decisions/** before making architectural changes
4. Check **techdocs/** for anti-patterns to avoid

### For Code Reviewers
1. Verify changes align with **ARCHITECTURE.md**
2. Check if new patterns should be documented in **decisions/**
3. Ensure anti-patterns from **techdocs/** are avoided

### For New Contributors
1. Start with **ARCHITECTURE.md** (30 min read)
2. Read **NAMING.md** to understand conventions
3. Skim **decisions/** to understand key choices
4. Read relevant **techdocs/** when touching those areas

### For AI Agents
1. Read **ARCHITECTURE.md** before technical changes
2. Check **decisions/** before proposing new patterns
3. Avoid anti-patterns documented in **techdocs/**
4. Use **NAMING.md** for correct terminology

---

## 📊 Architecture Maturity

### v0.1 Status
- ✅ Functional implementation
- ❌ Monolithic code (no modularity)
- ❌ Mixed concerns (UI + logic together)
- ❌ No automated tests
- ❌ No code standards

### v0.2 Goals
- ✅ Modular structure (core, ui, actions, utils)
- ✅ Single responsibility (each module does one thing)
- ✅ Testable (unit tests with mocked tmux)
- ✅ Documented (code standards, ADRs)

**See:** [../04-tasks/](../04-tasks/) for refactoring tasks

---

## 🎨 Key Architectural Decisions

### 1. Pure tmux format strings for status bar
**Decision:** Use native tmux `#{...}` format strings, not external scripts
**Why:** External scripts cause visible flicker with `status-interval > 0`
**See:** [techdocs/lesson-01-status-bar-flickering.md](techdocs/lesson-01-status-bar-flickering.md)

### 2. gum for TUI with graceful fallback
**Decision:** Use `gum` for Manager menu, fallback to bash `read` if missing
**Why:** gum provides better UX, but must work without it
**See:** To be documented in decisions/

### 3. Lifecycle-based folder structure
**Decision:** Organize by lifecycle (vision → planning → architecture → tasks)
**Why:** AI and developers navigate by phase, not by file type
**See:** [decisions/001-folder-structure.md](decisions/001-folder-structure.md)

### 4. Namespace pattern for functions
**Decision:** Use `module::function` pattern (e.g., `state::get_console_state`)
**Why:** Prevents naming collisions, clear module ownership
**See:** [../04-tasks/005-code-standards.md](../04-tasks/005-code-standards.md)

---

## 📝 Architecture Decision Records (ADRs)

**Format:**
```markdown
# ADR-NNN: [Decision Title]

## Context
[What problem are we solving?]

## Options Considered
1. Option A - [pros/cons]
2. Option B - [pros/cons]

## Decision
[What we chose and why]

## Consequences
[What this means for the codebase]
```

**Current ADRs:**
- [001-folder-structure.md](decisions/001-folder-structure.md) - Lifecycle organization

**To be created:**
- 002-state-management.md - Caching strategy
- 003-gum-ui-framework.md - TUI framework choice
- 004-theme-system.md - Shell variable themes

---

## 🔗 Related

- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - WHAT we're building
- **[../04-tasks/](../04-tasks/)** - Refactoring tasks
- **[../src/](../src/)** - Current implementation

---

**This folder defines HOW we build, not WHAT or WHEN.**
