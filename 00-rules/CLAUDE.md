**Purpose:** AI and developer instructions for project workflow and standards

---

# 00-rules - Workflow & Standards

This folder contains **HOW WE WORK** - process rules and standards that apply across the entire project.

---

## 📚 Rules & Standards

### **[VERSIONING.md](VERSIONING.md)** - Version Strategy
Version numbering (0.1 increment rule), task archival, release planning

**Key rule:** Versions increment by 0.1 ONLY (v0.1 → v0.2 → v0.3...)

---

### **[TASK-MANAGEMENT.md](TASK-MANAGEMENT.md)** - Task Workflow
How to create, manage, and archive tasks

**Key rules:**
- All tasks in `04-tasks/`
- Sequential numbering (001, 002, 003...)
- Archive by version when released

---

### **[FILE-ORGANIZATION.md](FILE-ORGANIZATION.md)** - Where Files Go
Lifecycle structure, where things belong, naming conventions

**Key rules:**
- Lifecycle folders: 00-rules → 01-vision → 02-planning → 03-architecture → 04-tasks → 05-implementation
- CLAUDE.md in lifecycle (not README.md)
- Purpose header in every doc

---

### **[testing-manual.md](testing-manual.md)** - Manual Testing
Manual testing protocol and checklist

**Key rules:**
- Test before release
- Status bar positioning
- All F-keys functionality

---

### **[CODE-STANDARDS.md](CODE-STANDARDS.md)** - Coding Conventions ✅ COMPLETE
Naming, documentation, error handling patterns

**Key rules:**
- Functions: verb_noun_modifier()
- Variables: lowercase_with_underscores
- Strict mode: `set -euo pipefail`
- All functions documented with docstrings
- Error messages to stderr with ERROR: prefix

---

## 🎯 What Belongs in 00-rules/

**DO include:**
- ✅ Process rules (how we version, test, organize)
- ✅ Workflow standards (task management, git)
- ✅ Code standards (naming, documentation)
- ✅ Testing protocols

**DON'T include:**
- ❌ Product features (goes to 02-planning/)
- ❌ Technical design (goes to 03-architecture/)
- ❌ Current tasks (goes to 04-tasks/)
- ❌ User documentation (goes to docs/)

---

## 🔍 How to Use This Folder

### For AI Agents
1. **Always** read relevant rule before action:
   - Creating task? → TASK-MANAGEMENT.md
   - Where to put file? → FILE-ORGANIZATION.md
   - Version planning? → VERSIONING.md
2. Follow rules exactly (they prevent mistakes)
3. Update rules if pattern discovered

### For Developers
1. Read rules when starting work
2. Reference rules when unsure
3. Propose rule changes via PR
4. Keep rules updated

### For Project Managers
1. Review rules for process consistency
2. Update rules when workflow changes
3. Ensure team follows rules

---

## 📝 Rules Summary

### Versioning
- Increment by 0.1 only
- Archive tasks by version
- See [VERSIONING.md](VERSIONING.md)

### Task Management
- Create in 04-tasks/
- Use 001-002-003 numbering
- See [TASK-MANAGEMENT.md](TASK-MANAGEMENT.md)

### File Organization
- Lifecycle structure (00-05)
- CLAUDE.md in lifecycle
- Purpose headers required
- See [FILE-ORGANIZATION.md](FILE-ORGANIZATION.md)

### Documentation
- Every doc starts with Purpose
- Use relative links
- SPEC.md is SSOT

### Testing
- Manual tests before release
- See [testing-manual.md](testing-manual.md)

---

## 🔗 Related

- **[../CLAUDE.md](../CLAUDE.md)** - Root navigation hub
- **[../01-vision/](../01-vision/)** - Why we build (purpose, roadmap)
- **[../02-planning/](../02-planning/)** - What we build (specs)
- **[../03-architecture/](../03-architecture/)** - How we build (design)
- **[../04-tasks/](../04-tasks/)** - When we work (current tasks)

---

**Rules serve the project, not the other way around. Update them as we learn.**
