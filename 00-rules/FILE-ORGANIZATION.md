**Purpose:** Rules for where files go, lifecycle structure, and workflow organization

---

# File Organization & Workflow Rules

## 📁 Lifecycle Structure

**pTTY uses lifecycle-based organization:**

```
~/.vps/sessions/
├── 00-rules/              # HOW WE WORK - Process rules
├── 01-vision/             # WHY - Purpose & direction
├── 02-planning/           # WHAT - Requirements & specs
├── 03-architecture/       # HOW TO BUILD - Technical design
├── 04-tasks/              # WHEN - Current work
├── 05-implementation/     # DONE - Completed work
├── src/                   # CODE - Implementation
├── docs/                  # USER DOCS - End-user documentation
├── tests/                 # TESTING - Test infrastructure
└── tools/                 # DEV TOOLS - Development utilities
```

---

## 🎯 What Goes Where

### 00-rules/ - Process Rules
**Purpose:** How we work (versioning, standards, workflow)

**Contains:**
- VERSIONING.md - Version numbering strategy
- TASK-MANAGEMENT.md - How to create/manage tasks
- FILE-ORGANIZATION.md - This file
- testing-manual.md - Manual testing protocol
- CODE-STANDARDS.md - Coding conventions (future)

**Does NOT contain:**
- Product features (goes to 02-planning/)
- Technical design (goes to 03-architecture/)
- Tasks (goes to 04-tasks/)

---

### 01-vision/ - WHY We Build
**Purpose:** Problem, solution, values, direction

**Contains:**
- PURPOSE.md - Why pTTY exists
- ROADMAP.md - Version roadmap (v0.x → v1.x → v2.x)
- principles.md - Design principles

**Does NOT contain:**
- Detailed specifications (goes to 02-planning/)
- Implementation plans (goes to 03-architecture/)

---

### 02-planning/ - WHAT We Build
**Purpose:** Requirements, specifications, scope

**Structure:**
```
02-planning/
├── SPEC.md                    # ⭐ Single Source of Truth
├── workshops/                 # Team discussions
│   ├── SPEC-WORKSHOP.md
│   └── TEAM-DISCUSSION-V1.md
├── specs/                     # Detailed component specs
│   ├── GLOSSARY.md
│   ├── ICONS-SPEC.md
│   ├── MANAGER-SPEC.md
│   ├── STATUS-BAR-SPEC.md
│   ├── HELP-SPEC.md
│   ├── SAFE-EXIT-SPEC.md
│   └── CLI-ARCH.md
├── backlog/                   # Future ideas (not scheduled)
│   └── ai-cli-workflow.md
└── archive/v0.X/              # Historical planning docs
```

**SPEC.md is Single Source of Truth:**
- All specs elaborate on SPEC.md
- Conflicts resolved by updating SPEC.md
- Always check SPEC.md before changes

**Does NOT contain:**
- Implementation details (goes to 03-architecture/)
- Current work (goes to 04-tasks/)

---

### 03-architecture/ - HOW We Build
**Purpose:** Technical design, decisions, lessons

**Structure:**
```
03-architecture/
├── ARCHITECTURE.md            # Main technical design
├── ARCHITECTURE-ANALYSIS.md   # Architecture review
├── NAMING.md                  # Naming conventions
├── decisions/                 # Architecture Decision Records
│   ├── 001-folder-structure.md
│   ├── 002-state-caching.md
│   └── ...
└── techdocs/                  # Technical lessons learned
    ├── README.md
    └── lesson-01-status-bar-flickering.md
```

**ADRs (Architecture Decision Records):**
- Document WHY we chose this approach
- Format: Context → Options → Decision → Consequences
- Numbered sequentially (001, 002, 003...)

**Does NOT contain:**
- User-facing specs (goes to 02-planning/)
- Current tasks (goes to 04-tasks/)

---

### 04-tasks/ - WHEN We Work
**Purpose:** Current work for active version ONLY

**Structure:**
```
04-tasks/
├── CLAUDE.md                  # Task workflow instructions
├── TODO.md                    # Sprint backlog
├── 001-task-name.md           # Active tasks
├── 002-task-name.md
├── ...
└── archive/                   # Completed tasks by version
    ├── v0.1/
    ├── v0.2/
    └── v1.0/
```

**Rules:**
- Only current version tasks here
- Sequential numbering (001, 002, 003...)
- Archive entire version when released
- See [TASK-MANAGEMENT.md](TASK-MANAGEMENT.md) for details

**Does NOT contain:**
- Future ideas (goes to 02-planning/backlog/)
- Completed implementation (goes to 05-implementation/)

---

### 05-implementation/ - DONE Work
**Purpose:** Archive of completed implementation

**Structure:**
```
05-implementation/
├── completed/
│   ├── v0.1/                  # What was built in v0.1
│   ├── v0.2/                  # What was built in v0.2
│   └── v1.0/
└── changelog/
    └── CHANGELOG.md           # Unified changelog
```

**What goes here:**
- Implementation notes
- Release notes
- What changed in each version
- Technical details of what was built

**Does NOT contain:**
- Active tasks (stays in 04-tasks/ until version released)
- Source code (stays in src/)

---

### src/ - Source Code
**Purpose:** Actual implementation code

**Structure:**
```
src/
├── core/                      # State, config, utilities
├── ui/                        # User interface
│   ├── components/
│   ├── manager/
│   ├── help/
│   └── status-bar/
├── actions/                   # Console operations
└── utils/                     # Shared utilities
```

**Does NOT contain:**
- Documentation (goes to docs/)
- Tests (goes to tests/)

---

### docs/ - User Documentation
**Purpose:** End-user facing documentation

**Structure:**
```
docs/
├── tutorials/                 # Learning-oriented (future)
├── howto/                     # Problem-solving (future)
├── reference/                 # Information (future)
├── explanation/               # Understanding (future)
├── remote-access.md
├── troubleshooting.md
└── windows-terminal.md
```

**Diátaxis framework** (future):
- Tutorials - Getting started guides
- How-to - Solve specific problems
- Reference - Technical specifications
- Explanation - Conceptual understanding

**Does NOT contain:**
- Developer docs (goes to 03-architecture/)
- Specifications (goes to 02-planning/)

---

### tests/ - Testing Infrastructure
**Purpose:** Automated and manual tests

**Does NOT contain:**
- Testing rules (goes to 00-rules/testing-manual.md)

---

### tools/ - Development Tools
**Purpose:** Scripts for development workflow

**Contains:**
- CI/CD monitoring (push-and-watch.sh, check-ci.sh)
- Build tools
- Development utilities

---

## 📝 CLAUDE.md Pattern

**Every lifecycle folder has CLAUDE.md (not README.md)**

### Structure:
```markdown
# [Folder Name] - [Purpose]

**Purpose:** [One-line description]

---

## 📁 Contents
[List of files with brief descriptions]

## 🎯 What Belongs Here
[Rules for what goes in this folder]

## 🔍 How to Use This Folder
[Instructions for developers/AI]

## 🔗 Related
[Links to related folders/docs]
```

### Why CLAUDE.md?
- AI agents get instructions specific to that phase
- Humans also benefit from context
- Agent knows what to do when working in folder
- Progressive disclosure (root → lifecycle → docs)

---

## 📄 Purpose Header Rule

**Every documentation file MUST start with:**

```markdown
**Purpose:** [One-line description of what this document contains]

---

[Rest of document]
```

**Why:**
- Agent immediately knows what document is for
- Human readers understand context quickly
- Consistency across all docs

**Examples:**
```markdown
**Purpose:** Explain WHY pTTY exists and what problem it solves
**Purpose:** Rules for creating, managing, and archiving tasks
**Purpose:** Complete specification of F11 Manager behavior
```

---

## 🔄 Task Workflow

### Creating Tasks
1. Create in `04-tasks/NNN-task-name.md`
2. Use task template (see TASK-MANAGEMENT.md)
3. Update TODO.md with summary
4. Link to relevant specs in 02-planning/

### Working on Tasks
1. Update acceptance criteria as complete
2. Mark `[x]` when done
3. Update TODO.md with progress

### Completing Tasks
1. Verify all criteria met
2. Mark in TODO.md as done
3. **Keep in 04-tasks/** until version released

### Archiving Tasks
When version released:
```bash
mkdir -p 04-tasks/archive/v0.X/
mv 04-tasks/00*.md 04-tasks/archive/v0.X/
```

**See:** [TASK-MANAGEMENT.md](TASK-MANAGEMENT.md) for complete rules

---

## 📛 Naming Conventions

### Folders
- **Lifecycle:** `00-prefix-name/` (numbered, lowercase)
- **Other:** `lowercase-with-dashes/`

### Files
- **Important docs:** `UPPERCASE.md` (SPEC.md, README.md, CLAUDE.md)
- **Regular docs:** `lowercase-with-dashes.md`
- **Tasks:** `NNN-task-name.md` (three digits)
- **ADRs:** `NNN-decision-name.md` (three digits)

### Examples:
- ✅ `02-planning/SPEC.md`
- ✅ `00-rules/testing-manual.md`
- ✅ `04-tasks/006-documentation-reorganization.md`
- ✅ `03-architecture/decisions/001-folder-structure.md`
- ❌ `Planning/spec.md` (wrong case)
- ❌ `task-refactor.md` (no number)

---

## 🔗 Linking Strategy

### Use Relative Links
```markdown
**Good:**
[SPEC.md](../02-planning/SPEC.md)
[VERSIONING.md](../00-rules/VERSIONING.md)

**Bad:**
[SPEC.md](/home/user/project/02-planning/SPEC.md)
[VERSIONING.md](https://github.com/user/repo/blob/main/00-rules/VERSIONING.md)
```

### Link from Specific to General
- Task → Spec → Vision
- Implementation → Architecture → Planning
- Always link up the hierarchy

---

## ⚠️ Critical Rules

### Only Current Version in 04-tasks/
- `04-tasks/` contains ONLY tasks for current version
- Completed tasks stay until version released
- Future ideas go to `02-planning/backlog/`

### SPEC.md is Single Source of Truth
- All other specs elaborate on SPEC.md
- Conflicts resolved by updating SPEC.md
- Always check SPEC.md before making changes

### Purpose Headers Required
- Every doc starts with `**Purpose:**` line
- One-line description
- Agent/reader knows context immediately

### CLAUDE.md not README.md in Lifecycle
- Lifecycle folders use CLAUDE.md
- Root uses both (CLAUDE.md + README.md)
- Other folders can use README.md

---

## 📊 Decision Matrix

**Where does this go?**

| Content Type | Location |
|--------------|----------|
| Version numbering rules | 00-rules/VERSIONING.md |
| Why pTTY exists | 01-vision/PURPOSE.md |
| Feature specification | 02-planning/SPEC.md or specs/ |
| Technical design | 03-architecture/ARCHITECTURE.md |
| Implementation task | 04-tasks/NNN-task-name.md |
| Completed work notes | 05-implementation/completed/ |
| Source code | src/ |
| User guide | docs/ |
| Test cases | tests/ |

---

## 🔗 Related Rules

- **[VERSIONING.md](VERSIONING.md)** - Version numbering
- **[TASK-MANAGEMENT.md](TASK-MANAGEMENT.md)** - Task workflow
- **[../CLAUDE.md](../CLAUDE.md)** - Root navigation

---

**This structure ensures AI and humans can navigate by lifecycle phase, not by guessing filenames.**
