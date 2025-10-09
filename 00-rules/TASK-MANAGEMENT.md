**Purpose:** Rules for creating, managing, and archiving tasks in the project

---

# Task Management Rules

## 📋 Task Creation Rules

### Where to Create Tasks
**Always in:** `04-tasks/`

**Structure:**
```
04-tasks/
├── 001-task-name.md
├── 002-task-name.md
├── 003-task-name.md
└── archive/
    └── v0.X/
```

### Task Numbering
- **Sequential:** 001, 002, 003, 004, 005...
- **Three digits:** Always use leading zeros (001 not 1)
- **No gaps:** If task 003 deleted, renumber 004→003, 005→004
- **Start from 001** for each version (not 013, 014, etc.)

### Task File Naming
**Format:** `NNN-short-description.md`

**Examples:**
- ✅ `001-refactor-state-management.md`
- ✅ `002-setup-testing-framework.md`
- ✅ `006-documentation-reorganization.md`
- ❌ `13-refactor.md` (no leading zero)
- ❌ `task-refactor.md` (no number)
- ❌ `001_refactor.md` (use dash not underscore)

---

## 📝 Task File Template

Every task file MUST follow this structure:

```markdown
# Task NNN: [Task Name]

**Purpose:** [One-line description of what this task achieves]

**Phase:** v0.X
**Priority:** Critical / High / Medium / Low
**Estimated Time:** X hours/days
**Dependencies:** [Other tasks that must complete first, or "None"]
**Assignee:** [Developer name or "Unassigned"]

---

## 🎯 Objective

[Clear description of what needs to be achieved and WHY]

---

## ✅ Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] ...

---

## 📋 Implementation Details

### Files to Create/Modify
- `path/to/file.ext` - Description of changes

### Code Structure
[Pseudocode or detailed structure if needed]

### Testing Requirements
- Unit tests: [What to test]
- Integration tests: [What to test]
- Manual tests: [How to verify]

---

## 🔗 Related Documentation

- [SPEC.md](../02-planning/SPEC.md) - Specification reference
- [Other relevant docs]

---

## 📝 Notes

[Any additional context, warnings, or tips]
```

---

## 🔄 Task Workflow

### 1. Create Task
```bash
# Create in 04-tasks/
touch 04-tasks/NNN-task-name.md

# Fill using template above
# Link to relevant specs in 02-planning/
```

### 2. Work on Task
- Update acceptance criteria as you complete them
- Mark `[x]` when done
- Update TODO.md with progress

### 3. Complete Task
When ALL acceptance criteria met:
- ✅ Mark task as done in TODO.md
- ✅ Keep file in `04-tasks/` until version released

### 4. Archive When Version Released
When version complete (e.g., v0.2 released):
```bash
# Create archive folder for version
mkdir -p 04-tasks/archive/v0.2/

# Move all completed tasks
mv 04-tasks/00*.md 04-tasks/archive/v0.2/

# Start fresh for next version (v0.3)
# New tasks will be 001, 002, 003...
```

---

## 📂 Task Archival Rules

### Archive Structure
```
04-tasks/archive/
├── v0.1/                    # All tasks from v0.1
│   ├── f11-detach-fix.md
│   └── ...
├── v0.2/                    # All tasks from v0.2 (when complete)
│   ├── 001-refactor-state-management.md
│   └── ...
└── v1.0/                    # All tasks from v1.0 (future)
```

### When to Archive
- **After version release:** Move all tasks to `archive/vX.Y/`
- **Keep history:** Never delete tasks, always archive
- **Preserve context:** Keep task files as-is (shows what was done)

### Why Archive by Version
- Easy to browse: "What did we do in v0.2?"
- Understand evolution: "Why did we make this change?"
- Reference for similar tasks: "How did we solve this before?"

---

## 🎯 Task States

### During Development
- **File in `04-tasks/`** - Task exists and is tracked
- **Checkboxes in file** - Track individual acceptance criteria
- **TODO.md** - Overall sprint status

### After Version Release
- **File in `archive/vX.Y/`** - Task completed and archived
- **History preserved** - Can review what was done

---

## ⚠️ Critical Rules

### Only Current Version in 04-tasks/
- `04-tasks/` contains ONLY tasks for current version
- Completed tasks stay until version released
- Future ideas go to `02-planning/backlog/`

### Always Use 04-tasks/ Folder
- Never create tasks in root or other folders
- Never scatter task files across project
- Single source for "what to do"

### Sequential Numbering
- Start from 001 for each version
- No gaps in sequence
- Renumber if task deleted

---

## 📊 Example: Version Lifecycle

### v0.2 Development
```
04-tasks/
├── 001-refactor-state-management.md
├── 002-refactor-ui-components.md
├── 003-refactor-actions.md
├── 004-testing-framework.md
├── 005-code-standards.md
└── 006-documentation-reorganization.md
```

### v0.2 Released → Archive
```bash
mv 04-tasks/00*.md 04-tasks/archive/v0.2/
```

### v0.3 Development (Start Fresh)
```
04-tasks/
├── 001-new-feature-x.md
├── 002-bugfix-y.md
└── 003-improvement-z.md
```

---

## 🔗 Related Rules

- **[VERSIONING.md](VERSIONING.md)** - Version numbering strategy
- **[FILE-ORGANIZATION.md](FILE-ORGANIZATION.md)** - Where files go
- **[../04-tasks/TODO.md](../04-tasks/TODO.md)** - Current sprint status

---

## 📝 Summary

**Key Principles:**
1. All tasks in `04-tasks/`
2. Sequential numbering (001, 002, 003...)
3. Follow template structure
4. Archive by version when released
5. Keep history, never delete

**This ensures:**
- ✅ Easy to find tasks
- ✅ Clear what's in progress
- ✅ History preserved
- ✅ Consistent format
