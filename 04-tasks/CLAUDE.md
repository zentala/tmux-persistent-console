# 04-tasks - Current Work

**Purpose:** Track WHAT we're working on NOW

---

## 📁 Contents

### Active Work
- **[TODO.md](TODO.md)** - Current sprint backlog
- **[001-refactor-state-management.md](001-refactor-state-management.md)** - State management module
- **[002-refactor-ui-components.md](002-refactor-ui-components.md)** - UI components extraction
- **[003-refactor-actions.md](003-refactor-actions.md)** - Action layer
- **[004-testing-framework.md](004-testing-framework.md)** - bats testing setup
- **[005-code-standards.md](005-code-standards.md)** - Code standards document

### Archive ([archive/v0.1/](archive/v0.1/))
Completed tasks from v0.1:
- **[f12-issues-log.md](archive/v0.1/f12-issues-log.md)** - F12 implementation issues
- **[changelog-2025-10-07.md](archive/v0.1/changelog-2025-10-07.md)** - Release notes
- **[changelog-v3-no-flicker.md](archive/v0.1/changelog-v3-no-flicker.md)** - Status bar fix
- **[plan-fix-flickering.md](archive/v0.1/plan-fix-flickering.md)** - Flickering fix plan
- **[tui-upgrade.md](archive/v0.1/tui-upgrade.md)** - TUI improvements

---

## 🎯 Current Sprint: v0.2 Refactoring

**Version:** v0.2 (in development)
**Phase:** 00-rules (Workflow Planning & Organization)

**Sprint Goals:**
1. ✅ Complete folder reorganization
2. ✅ Define versioning strategy
3. 🔄 Refactor to modular architecture (tasks 001-003)
4. 🔄 Setup testing framework (task 004)
5. 🔄 Document code standards (task 005)

**Progress:** 40% complete (2/5 tasks done - organization & versioning)

---

## 📋 Task Status

### ✅ Completed (2)
- Documentation reorganization
- Versioning rules established

### 🔄 In Progress (0)
- None (starting soon)

### ⏳ Pending (5)
- 001 - State management refactoring
- 002 - UI components extraction
- 003 - Actions layer
- 004 - Testing framework
- 005 - Code standards

---

## 🎯 What Belongs Here

This folder contains **only active tasks** for the current version:

### DO Include:
- ✅ Tasks for current version (v0.2)
- ✅ TODO.md with current sprint backlog
- ✅ Task files with implementation plans

### DON'T Include:
- ❌ Completed tasks (move to `archive/vX.Y/`)
- ❌ Future ideas (goes to `../02-planning/backlog/`)
- ❌ General documentation (goes to lifecycle folders)

---

## 📝 Task File Format

Each task follows this structure:

```markdown
# Task NNN: [Task Name]

**Phase:** v0.x
**Priority:** Critical / High / Medium / Low
**Estimated Time:** X days/hours
**Dependencies:** [Other tasks]
**Assignee:** [Developer or "Unassigned"]

## Objective
[What needs to be achieved]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Implementation Details
[How to do it]

## Testing Requirements
[How to verify]
```

---

## 🔄 Task Workflow

### 1. Create Task
- Write task file in this folder
- Update TODO.md with task summary
- Link to relevant specs in `../02-planning/`

### 2. Work on Task
- Check off acceptance criteria as you complete them
- Update TODO.md with progress

### 3. Complete Task
- Verify all acceptance criteria met
- Update TODO.md (mark as done)
- **Move to archive:** `mv 00N-task-name.md archive/v0.2/`

### 4. Archive Old Version
When version released (e.g., v0.2 complete):
```bash
# Move all v0.2 tasks to archive
mv 00*.md archive/v0.2/
```

---

## 📊 Task Archival Rules

**When version is completed, archive its tasks:**

```
04-tasks/archive/
├── v0.1/                    # v0.1 completed tasks
│   ├── f12-issues-log.md
│   ├── changelog-*.md
│   └── ...
├── v0.2/                    # v0.2 completed tasks (future)
│   ├── 001-refactor-state-management.md
│   └── ...
└── v1.0/                    # v1.0 completed tasks (future)
```

**See:** [../02-planning/VERSIONING.md](../02-planning/VERSIONING.md) for archival rules

---

## 🔍 How to Use This Folder

### For Developers
1. Check **TODO.md** for current sprint priorities
2. Pick a task (001-005)
3. Read task file for requirements
4. Implement following acceptance criteria
5. Update TODO.md with progress

### For Project Managers
1. Review **TODO.md** for sprint status
2. Check task files for completion %
3. Assign tasks by updating "Assignee" field
4. Track dependencies between tasks

### For AI Agents
1. **Always** read task file completely before starting
2. Check dependencies (don't start 002 before 001 done)
3. Read related specs in `../02-planning/`
4. Follow architecture in `../03-architecture/`
5. Update TODO.md as you progress

---

## 🔗 Related

- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - What to implement
- **[../03-architecture/](../03-architecture/)** - How to implement
- **[../00-rules/](../00-rules/)** - Standards to follow
- **[TODO.md](TODO.md)** - Current work status

---

## ⚠️ Critical Rules

### Only Current Version Tasks Here
- This folder contains **only** tasks for current version (v0.2)
- Completed tasks → `archive/vX.Y/`
- Future ideas → `../02-planning/backlog/`

### One Version at a Time
- Don't mix v0.2 and v0.3 tasks
- Complete current version before planning next

### Archive After Release
- When v0.2 released → move all tasks to `archive/v0.2/`
- Keeps folder clean and focused

---

**This folder tracks WHEN we're doing the work, not WHAT or HOW.**
