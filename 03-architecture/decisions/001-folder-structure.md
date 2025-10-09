# pTTY Project - Tree Structure Reorganization Plan

**Date**: 2025-10-09
**Purpose**: Complete documentation reorganization for product lifecycle management
**Target**: `~/.vps/sessions/` (pTTY application development)
**Audience**: AI agents working on this codebase

---

## 📋 Executive Summary

**Problem**: Documentation scattered across multiple files without clear lifecycle organization
**Solution**: Restructure to follow product management lifecycle (Vision → Planning → Architecture → Tasks → Code → Docs)
**Benefit**: AI and developers can navigate by **lifecycle phase** instead of searching by filename

---

## 🎯 User Requirements & Design Decisions

### Core Requirement
> "Documentation should cover **entire management cycle** - not just code docs but also project management docs. Track all thinking from vision/purpose through planning, architecture, tasks/sprints to implementation."

### Key Insights
1. **This is not just code repo** - it's documentation of complete thought process
2. **Lifecycle phases matter** - Vision (WHY) → Planning (WHAT) → Architecture (HOW) → Tasks (WHEN) → Implementation (DO)
3. **Workshops & discussions are valuable** - preserve team thinking process (SPEC-WORKSHOP.md, TEAM-DISCUSSION-V1.md)
4. **Specifications evolve** - detailed specs (ICONS-SPEC.md, MANAGER-SPEC.md) are part of planning phase
5. **Single source of truth** - SPEC.md is master specification, other docs elaborate details

### Design Principles
- **Progressive disclosure**: README → detailed docs → implementation
- **Lifecycle-first navigation**: AI finds info by phase (vision/planning/arch/tasks)
- **Preserve history**: Don't delete workshop files - they show how we got here
- **Self-documenting**: Each folder has README.md explaining its purpose

---

## 🌳 Proposed Tree Structure

```
~/.vps/sessions/                          # pTTY application root
│
├── CLAUDE.md                             # 🗺️ AI Navigation Hub (300 lines max)
├── README.md                             # 📖 User-facing project overview
├── LICENSE                               # MIT license
├── .gitignore                            # Git ignore patterns
│
├── 01-vision/                            # 🎯 WHY - Purpose & Direction
│   ├── README.md                         # Vision overview & navigation
│   ├── PURPOSE.md                        # Core purpose, values, manifesto
│   ├── ROADMAP.md                        # v1/v2/v3 vision (from FUTURE-VISION.md)
│   └── principles.md                     # Design principles (DevEx, simplicity, etc.)
│
├── 02-planning/                          # 📋 WHAT - Requirements & Specifications
│   ├── README.md                         # Planning phase overview
│   ├── SPEC.md                           # ⭐ Unified Specification (SSOT)
│   │
│   ├── workshops/                        # Team discussions & refinement process
│   │   ├── README.md                     # Workshop index
│   │   ├── SPEC-WORKSHOP.md              # Initial spec workshop with 25 questions
│   │   └── TEAM-DISCUSSION-V1.md         # Team discussion round 2
│   │
│   └── specs/                            # Detailed component specifications
│       ├── README.md                     # Spec index
│       ├── GLOSSARY.md                   # Unified terminology, shortcuts, icons
│       ├── ICONS-SPEC.md                 # Icon-to-state mapping, themes, colors
│       ├── MANAGER-SPEC.md               # F11 Manager complete specification
│       ├── STATUS-BAR-SPEC.md            # Status bar visual design & behavior
│       ├── HELP-SPEC.md                  # F12 Help reference specification
│       ├── CLI-ARCH.md                   # Future CLI commands architecture (v3)
│       └── FUTURE-VISION.md              # v2/v3 features & open questions
│
├── 03-architecture/                      # 🏗️ HOW - Solution & Technical Design
│   ├── README.md                         # Architecture overview
│   ├── ARCHITECTURE.md                   # Technical implementation design (v2.0)
│   ├── solution.md                       # High-level solution architecture
│   │
│   ├── decisions/                        # ADRs (Architecture Decision Records)
│   │   ├── README.md                     # ADR index
│   │   ├── 001-theme-system.md           # Theme system design decision
│   │   ├── 002-state-management.md       # State update strategy (polling vs hooks)
│   │   └── 003-gum-ui-framework.md       # Why gum for TUI
│   │
│   └── techdocs/                         # Technical deep dives & lessons learned
│       ├── README.md                     # Tech docs index
│       └── lesson-01-status-bar-flickering.md  # Anti-pattern: external scripts cause flicker
│
├── 04-tasks/                             # 📝 WHEN - Task Management (Scrum/Kanban)
│   ├── README.md                         # Current sprint overview
│   ├── TODO.md                           # Active sprint tasks (current work)
│   │
│   ├── active/                           # Tasks in progress
│   │   ├── 013-refactor-state-management.md
│   │   ├── 014-refactor-ui-components.md
│   │   ├── 015-refactor-actions.md
│   │   ├── 016-testing-framework.md
│   │   └── 017-code-standards.md
│   │
│   ├── backlog/                          # Future work (not started)
│   │   └── [future tasks]
│   │
│   └── completed/                        # Task history (for retrospectives)
│       └── [completed tasks - move here when done]
│
├── src/                                  # 💻 Implementation (source code)
│   ├── tmux.conf                         # tmux configuration
│   ├── setup.sh                          # Session setup script
│   ├── manager-menu.sh                   # F11 Manager implementation
│   ├── help-reference.sh                 # F12 Help implementation
│   ├── safe-exit.sh                      # Safe exit wrapper
│   ├── connect.sh                        # Interactive connection menu
│   │
│   ├── themes/                           # Theme system
│   │   ├── default.sh                    # Default theme (NF icons, blue accent)
│   │   ├── dark.sh                       # Dark theme variant
│   │   └── light.sh                      # Light theme variant
│   │
│   └── tui/                              # TUI library components
│       ├── tui-core.sh
│       ├── tui-menu.sh
│       └── [other TUI modules]
│
├── docs/                                 # 📚 User Documentation (Diátaxis framework)
│   ├── README.md                         # Documentation index
│   │
│   ├── tutorials/                        # 📚 Learning-oriented (getting started)
│   │   ├── getting-started.md            # First steps with pTTY
│   │   └── first-session.md              # Your first persistent session
│   │
│   ├── howto/                            # 🛠️ Problem-solving (task-oriented)
│   │   ├── fix-function-keys.md          # Troubleshoot F-keys not working
│   │   └── customize-status-bar.md       # Customize status bar appearance
│   │
│   ├── reference/                        # 📋 Information-oriented (technical specs)
│   │   ├── f-key-bindings.md             # Complete keyboard shortcuts reference
│   │   ├── configuration.md              # ~/.ptty.conf reference
│   │   └── api.md                        # CLI API reference (v3)
│   │
│   └── explanation/                      # 📖 Understanding-oriented (concepts)
│       ├── why-ptty.md                   # Why pTTY exists (problem/solution)
│       ├── design-philosophy.md          # DevEx principles, simplicity
│       └── persistence-model.md          # How tmux persistence works
│
├── tests/                                # 🧪 Testing Infrastructure
│   ├── README.md                         # Testing guide
│   ├── CICD.md                           # CI/CD documentation
│   │
│   ├── docker/                           # Docker-based tests
│   │   └── README.md
│   │
│   └── STATUS-BAR-TESTS.md               # Status bar test cases
│
├── tools/                                # 🔧 Development Tools
│   ├── README.md                         # Tools documentation
│   ├── push-and-watch.sh                 # Push + watch CI/CD builds
│   ├── check-ci.sh                       # Check CI/CD status
│   └── watch-ci.sh                       # Watch CI/CD in real-time
│
└── archive/                              # 🗄️ Historical Files (not in active use)
    ├── CHANGELOG-2025-10-07.md           # Old changelogs
    ├── CHANGELOG-V3-NO-FLICKER.md
    ├── PLAN-FIX-FLICKERING.md            # Old planning docs (superseded by 02-planning/)
    ├── TUI-UPGRADE.md                    # Old TUI design (superseded by specs/)
    └── F12-ISSUES-LOG.md                 # F12 implementation history
```

---

## 📂 Folder Purpose & Contents

### **01-vision/** - WHY does pTTY exist?

**Purpose**: Answer "Why are we building this?" and "What problem does it solve?"

**Target audience**: New contributors, stakeholders, future self

**Contents**:
- `README.md` - Navigation: what's in this folder, how to use it
- `PURPOSE.md` - Core problem (SSH disconnects), solution (persistent tmux), values (DevEx, simplicity, "just works")
- `ROADMAP.md` - Product vision across versions (v1: core, v2: DevEx, v3: advanced)
- `principles.md` - Design principles that guide all decisions (DevEx, low-code, intuitive, self-teaching)

**Why separate folder?**: Vision changes slowly. Isolating it prevents noise when working on implementation.

---

### **02-planning/** - WHAT are we building?

**Purpose**: Answer "What exactly should this do?" and "What are the requirements?"

**Target audience**: Developers implementing features, QA testing, AI agents

**Contents**:
- `README.md` - Planning phase navigation
- `SPEC.md` - ⭐ **SINGLE SOURCE OF TRUTH** - Unified specification (all F-keys, status bar, manager, help, icons)
- `workshops/` - **Preserve thinking process**:
  - Shows how requirements evolved
  - 25 questions asked to user → answers → decisions
  - Team discussions (Solution Architect, Tech Lead, UX Engineer, DevEx Engineer)
  - Valuable for understanding "why did we decide X?"
- `specs/` - **Detailed component specs**:
  - Each component gets dedicated spec (Manager, Status Bar, Icons, CLI)
  - More detail than SPEC.md, but SPEC.md is still master
  - FUTURE-VISION.md shows v2/v3 scope

**Why separate from architecture?**: Planning = WHAT to build. Architecture = HOW to build it.

---

### **03-architecture/** - HOW do we build it?

**Purpose**: Answer "How does this work technically?" and "Why did we choose this approach?"

**Target audience**: Developers implementing, debugging, reviewing code

**Contents**:
- `README.md` - Architecture navigation
- `ARCHITECTURE.md` - Technical design (tmux config, gum TUI, status bar implementation, F11/F12 binding)
- `solution.md` - High-level solution (components, data flow, interactions)
- `decisions/` - **Architecture Decision Records (ADRs)**:
  - Document key technical decisions with context
  - Format: Problem → Options → Decision → Consequences
  - Examples: "Why theme system with shell vars?", "Why polling not hooks in v1?"
- `techdocs/` - **Lessons learned & deep dives**:
  - Anti-patterns discovered (status bar flickering with external scripts)
  - Performance analysis
  - Security considerations

**Why ADRs?**: Future developers will ask "Why did they do it this way?" - ADRs answer that.

---

### **04-tasks/** - WHEN & WHO is working on what?

**Purpose**: Answer "What's the current status?" and "What's next?"

**Target audience**: Project manager (you), developers, AI agents picking up work

**Contents**:
- `README.md` - Sprint overview (current sprint goals, completed items)
- `TODO.md` - **Current sprint backlog** (active tasks being worked on now)
- `active/` - Task files in progress (013-refactor-state-management.md, etc.)
- `backlog/` - Tasks not started yet (future sprints)
- `completed/` - Finished tasks (move here when done - useful for retrospectives)

**Task file format**: Each task describes problem, solution approach, acceptance criteria, testing plan

**Why separate from code?**: Tasks are temporary (completed/archived). Code is permanent. Mixing them creates clutter.

---

### **src/** - Implementation (actual code)

**Purpose**: Working code that runs pTTY

**Target audience**: Developers, users installing pTTY

**Contents**: Shell scripts, tmux config, TUI library

**Why flat structure?**: Small project, deeply nested src/ would be over-engineering

---

### **docs/** - User Documentation

**Purpose**: Help users understand and use pTTY

**Target audience**: End users (developers using pTTY on their servers)

**Structure**: Diátaxis framework (Tutorials, How-To, Reference, Explanation)

**Why Diátaxis?**: Industry best practice - separates learning (tutorials), problem-solving (how-to), lookup (reference), understanding (explanation)

---

### **tests/** - Testing Infrastructure

**Purpose**: Ensure pTTY works correctly

**Target audience**: Developers, CI/CD pipeline

**Contents**: Test scripts, Docker test environments, CI/CD docs

---

### **tools/** - Development Tools

**Purpose**: Helper scripts for development workflow

**Target audience**: Developers

**Contents**: CI/CD monitoring (push-and-watch.sh, check-ci.sh)

---

### **archive/** - Historical Files

**Purpose**: Preserve history without cluttering active workspace

**Target audience**: Archaeologists, curious developers

**Contents**: Old changelogs, superseded planning docs, issue logs

**Why not delete?**: History is valuable. Archived files show evolution of thinking.

---

## 🔄 Migration Commands

**Execute these commands to reorganize existing files:**

```bash
cd ~/.vps/sessions

# Create new directory structure
mkdir -p 01-vision
mkdir -p 02-planning/workshops
mkdir -p 02-planning/specs
mkdir -p 03-architecture/decisions
mkdir -p 03-architecture/techdocs
mkdir -p 04-tasks/active
mkdir -p 04-tasks/backlog
mkdir -p 04-tasks/completed
mkdir -p archive

# Move VISION files (create PURPOSE.md from README.md "Why This Exists" section)
# Note: PURPOSE.md needs to be created manually
mv specs/FUTURE-VISION.md 01-vision/ROADMAP.md

# Move PLANNING files
mv SPEC.md 02-planning/SPEC.md
mv SPEC-WORKSHOP.md 02-planning/workshops/
mv TEAM-DISCUSSION-V1.md 02-planning/workshops/
mv specs/*.md 02-planning/specs/
rmdir specs/

# Move ARCHITECTURE files
mv ARCHITECTURE.md 03-architecture/ARCHITECTURE.md
mv techdocs/*.md 03-architecture/techdocs/
rmdir techdocs/

# Move TASKS files
mv TODO.md 04-tasks/TODO.md
mv tasks/*.md 04-tasks/active/
rmdir tasks/

# Move to ARCHIVE
mv CHANGELOG-2025-10-07.md archive/
mv CHANGELOG-V3-NO-FLICKER.md archive/
mv PLAN-FIX-FLICKERING.md archive/
mv TUI-UPGRADE.md archive/
mv F12-ISSUES-LOG.md archive/
mv TESTING.md archive/  # If exists

# Create README.md files for each phase
touch 01-vision/README.md
touch 02-planning/README.md
touch 02-planning/workshops/README.md
touch 02-planning/specs/README.md
touch 03-architecture/README.md
touch 03-architecture/decisions/README.md
touch 03-architecture/techdocs/README.md
touch 04-tasks/README.md
```

---

## 📝 README.md Templates

### **01-vision/README.md**

```markdown
# pTTY Vision

**Purpose**: Understand WHY pTTY exists and WHERE it's going

---

## 📁 Contents

- **[PURPOSE.md](PURPOSE.md)** - Core problem & solution, values, manifesto
- **[ROADMAP.md](ROADMAP.md)** - Product vision (v1/v2/v3)
- **[principles.md](principles.md)** - Design principles guiding all decisions

---

## 🎯 Key Questions Answered Here

- **Why does pTTY exist?** → PURPOSE.md
- **What problem does it solve?** → PURPOSE.md (SSH disconnects, lost sessions)
- **What are the long-term goals?** → ROADMAP.md
- **What principles guide development?** → principles.md

---

## 🔗 Related

- **Detailed specs**: [../02-planning/](../02-planning/)
- **Technical design**: [../03-architecture/](../03-architecture/)
```

### **02-planning/README.md**

```markdown
# pTTY Planning & Specifications

**Purpose**: Define WHAT pTTY should do

---

## ⭐ Start Here

**[SPEC.md](SPEC.md)** - Unified Specification (Single Source of Truth)

All features, F-keys, status bar, manager, help - everything in one place.

---

## 📁 Contents

### **Workshops** ([workshops/](workshops/))
- Team discussions showing how requirements evolved
- User Q&A sessions (25 questions → decisions)
- Solution Architect, Tech Lead, UX Engineer discussions

### **Detailed Specs** ([specs/](specs/))
- [GLOSSARY.md](specs/GLOSSARY.md) - Terminology, shortcuts, icons
- [ICONS-SPEC.md](specs/ICONS-SPEC.md) - Icon-to-state mapping, themes
- [MANAGER-SPEC.md](specs/MANAGER-SPEC.md) - F11 Manager complete spec
- [STATUS-BAR-SPEC.md](specs/STATUS-BAR-SPEC.md) - Status bar design
- [HELP-SPEC.md](specs/HELP-SPEC.md) - F12 Help reference
- [CLI-ARCH.md](specs/CLI-ARCH.md) - CLI commands (v3)
- [FUTURE-VISION.md](specs/FUTURE-VISION.md) - v2/v3 scope

---

## 🔗 Related

- **Vision & purpose**: [../01-vision/](../01-vision/)
- **Technical implementation**: [../03-architecture/](../03-architecture/)
```

### **03-architecture/README.md**

```markdown
# pTTY Architecture

**Purpose**: Explain HOW pTTY is built

---

## 📁 Contents

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Main technical design document
- **[solution.md](solution.md)** - High-level solution architecture
- **[decisions/](decisions/)** - Architecture Decision Records (ADRs)
- **[techdocs/](techdocs/)** - Technical deep dives & lessons learned

---

## 🎯 Key Questions Answered Here

- **How does status bar work?** → ARCHITECTURE.md
- **Why did we choose gum for TUI?** → decisions/003-gum-ui-framework.md
- **Why theme system with shell variables?** → decisions/001-theme-system.md
- **What causes status bar flicker?** → techdocs/lesson-01-status-bar-flickering.md

---

## 🔗 Related

- **Requirements**: [../02-planning/](../02-planning/)
- **Implementation**: [../src/](../src/)
```

### **04-tasks/README.md**

```markdown
# pTTY Tasks & Sprint Management

**Purpose**: Track WHAT we're working on NOW

---

## 🎯 Current Sprint

**Active tasks**: [TODO.md](TODO.md)

**In progress**: [active/](active/)
- [013-refactor-state-management.md](active/013-refactor-state-management.md)
- [014-refactor-ui-components.md](active/014-refactor-ui-components.md)
- [015-refactor-actions.md](active/015-refactor-actions.md)
- [016-testing-framework.md](active/016-testing-framework.md)
- [017-code-standards.md](active/017-code-standards.md)

**Backlog**: [backlog/](backlog/)

**Completed**: [completed/](completed/)

---

## 📋 Task Workflow

1. Create task in `backlog/`
2. Move to `active/` when starting work
3. Update [TODO.md](TODO.md) with progress
4. Move to `completed/` when done
5. Retrospective review at end of sprint

---

## 🔗 Related

- **Specifications**: [../02-planning/](../02-planning/)
- **Implementation**: [../src/](../src/)
```

---

## 🔑 Key Benefits of This Structure

### **For AI Agents**
✅ **Lifecycle-aware navigation** - AI knows where to look for vision vs spec vs implementation
✅ **Progressive disclosure** - Start with README → drill down to details
✅ **Context preservation** - Workshops show how we got to current decisions
✅ **Clear boundaries** - Vision (why) vs Planning (what) vs Architecture (how) vs Tasks (when)

### **For Human Developers**
✅ **Onboarding friendly** - New dev reads 01-vision → 02-planning → 03-architecture → starts coding
✅ **Decision traceability** - ADRs explain why technical choices were made
✅ **Sprint management** - Tasks organized by status (active/backlog/completed)
✅ **Historical context** - Archive preserves evolution without cluttering workspace

### **For Product Management**
✅ **Complete lifecycle** - Vision → Planning → Architecture → Execution all documented
✅ **Roadmap clarity** - ROADMAP.md shows v1/v2/v3 scope
✅ **Requirements traceability** - Workshops show how user needs → specs → implementation

---

## 🚀 Next Steps

1. **Execute migration commands** (see "Migration Commands" section above)
2. **Create README.md files** for each phase (templates provided)
3. **Create PURPOSE.md** in `01-vision/` (extract "Why This Exists" from current README.md)
4. **Update CLAUDE.md** to reflect new structure (navigation by lifecycle phase)
5. **Archive superseded docs** (move to archive/)

---

## ✅ Validation Checklist

After reorganization, verify:
- [ ] All files migrated to new locations
- [ ] No broken links (update references in CLAUDE.md, README.md)
- [ ] Each phase folder has README.md
- [ ] SPEC.md is in 02-planning/ (SSOT)
- [ ] Workshops preserved in 02-planning/workshops/
- [ ] ADRs created in 03-architecture/decisions/ (create placeholders if needed)
- [ ] Tasks organized in 04-tasks/ (active/backlog/completed)
- [ ] Old files archived (not deleted)
- [ ] Git commit with message: "refactor(docs): Reorganize to lifecycle structure"

---

**Ready to execute!** 🎉

This structure will make pTTY development more organized, discoverable, and maintainable.
