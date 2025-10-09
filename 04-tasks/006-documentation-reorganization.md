# Reorganization Plan - HIGH PRIORITY

**Created:** 2025-10-09
**Status:** ACTIVE - Implementation in Progress
**Priority:** HIGHEST

---

## 🎯 OBJECTIVE

Reorganize documentation structure with:
1. CLAUDE.md instead of README.md in lifecycle folders
2. Purpose header in every documentation file
3. Progressive disclosure (root CLAUDE.md → lifecycle CLAUDE.md → docs)
4. Unified rules in 00-rules/

---

## 📋 TASKS (Ordered by Priority)

### **PRIORITY 1: CLAUDE.md in Lifecycle Folders** ⭐ HIGHEST

**Action:** Replace README.md with CLAUDE.md in lifecycle folders

**Reason:**
- AI agents get instructions specific to that phase
- Humans also benefit from context
- Agent knows what to do when working in that folder

**Implementation:**
```bash
# Rename lifecycle READMEs to CLAUDE.md
mv 00-rules/README.md 00-rules/CLAUDE.md
mv 01-vision/README.md 01-vision/CLAUDE.md
mv 02-planning/README.md 02-planning/CLAUDE.md
mv 03-architecture/README.md 03-architecture/CLAUDE.md
mv 04-tasks/README.md 04-tasks/CLAUDE.md
```

**Update root CLAUDE.md:**
- Add rule: "Every lifecycle folder has CLAUDE.md with phase-specific instructions"
- Link to lifecycle CLAUDE.md files
- Progressive disclosure pattern

---

### **PRIORITY 2: Purpose Header in All Docs** ⭐ HIGH

**Action:** Add purpose header to EVERY documentation file

**Format:**
```markdown
**Purpose:** [One-line description of what this document contains]

---

[Rest of document]
```

**Rule for CLAUDE.md:**
> Every documentation file MUST start with **Purpose:** line.
> Agent creating new doc MUST write purpose at the top.

**Files to update:**
- All lifecycle CLAUDE.md files
- All specs/*.md files
- All architecture docs
- All task files

**Reason:** Agent immediately knows what document is for

---

### **PRIORITY 3: Move VERSIONING.md to 00-rules/** ⭐ HIGH

**Action:**
```bash
mv 02-planning/VERSIONING.md 00-rules/VERSIONING.md
```

**Update references in:**
- Root CLAUDE.md
- 02-planning/CLAUDE.md
- 04-tasks/CLAUDE.md

**Reason:** Versioning is process rule, not release scope planning

---

### **PRIORITY 4: Create 05-implementation/ Folder** ⭐ HIGH

**Action:**
```bash
mkdir -p 05-implementation/completed/v0.1
mkdir -p 05-implementation/completed/v0.2
mkdir -p 05-implementation/changelog
```

**Create 05-implementation/CLAUDE.md**

**Move completed work:**
```bash
# Archive v0.1 completed implementation notes
# (will identify what goes here)
```

**Reason:** Separate TASK (to do) from IMPLEMENTATION (done)

---

### **PRIORITY 5: Fill 01-vision/ Content** ⭐ HIGH

**Issue #1 from Tech Lead review**

**Actions:**
```bash
# 1. Create PURPOSE.md (extract from main README.md)
touch 01-vision/PURPOSE.md

# 2. Move FUTURE-VISION.md to ROADMAP.md
mv 02-planning/specs/FUTURE-VISION.md 01-vision/ROADMAP.md

# 3. Create principles.md
touch 01-vision/principles.md
```

**Content for each:**
- **PURPOSE.md:** Problem (SSH disconnects), Solution (persistent tmux), Values
- **ROADMAP.md:** Version roadmap (v0.x → v1.x → v2.x)
- **principles.md:** DevEx, simplicity, "just works", resilience

---

### **PRIORITY 6: Create Missing ADRs** ⭐ MEDIUM

**Issue #3 from Tech Lead review**

**Create in 03-architecture/decisions/:**
- 002-state-management-caching.md (5s TTL strategy)
- 003-gum-ui-framework.md (why gum for F11/F12)
- 004-theme-shell-vars.md (why shell vars, not config)
- 005-no-external-scripts-statusbar.md (pure tmux format)

**Note:** Check if we DO use external scripts in F11/F12 (gum)
- Status bar = pure tmux (no scripts) ✓
- F11 Manager = uses gum (external TUI)
- F12 Help = static display

**Correct ADR:** "Why external scripts OK for F11/F12 but NOT status bar"

---

### **PRIORITY 7: Create FILE-ORGANIZATION.md** ⭐ MEDIUM

**Merge:**
- File organization rules
- Task workflow rules (from 04-tasks/)
- Documentation standards

**Location:** `00-rules/FILE-ORGANIZATION.md`

**Content:**
```markdown
# File Organization & Workflow Rules

## Lifecycle Structure
00-rules → 01-vision → 02-planning → 03-architecture → 04-tasks → 05-implementation

## CLAUDE.md Pattern
- Every lifecycle folder has CLAUDE.md
- Root CLAUDE.md links to lifecycle CLAUDE.md
- Progressive disclosure (summary → details)

## Purpose Header Rule
Every doc must start with:
**Purpose:** [description]

## Where Things Go
[Detailed rules]

## Task Workflow
[Extract from 04-tasks/]
```

---

### **PRIORITY 8: Update Git Workflow in CLAUDE.md** ⭐ MEDIUM

**Add to root CLAUDE.md:**

```markdown
## 🌿 Git Workflow & Branching Strategy

**Current Phase:** Alpha (v0.x)

### Branch Strategy by Stability Level

**Alpha (v0.x - Current):**
- Single branch: `main`
- All work directly on main
- Reason: Rapid prototyping, small team

**Beta (after v1.0-beta):**
- `main` - stable alpha
- `develop` - active development
- Merge develop → main for releases

**Stable (after v1.0):**
- `main` - production stable
- `develop` - active development
- `feature/*` - feature branches
- PR required for develop
- Release branches for production

### Commit Convention
Use conventional commits (always):
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `docs:` - Documentation
- `test:` - Tests
- `chore:` - Maintenance
```

---

### **PRIORITY 9: Fix 04-tasks/README.md References** ⭐ LOW

**Issue #4 from Tech Lead review**

**Check and fix:**
- Remove v1.0, v1.5, v2.0 references
- Update to v0.x versioning
- Verify all links work

---

### **PRIORITY 10: Update 00-rules/CLAUDE.md Structure** ⭐ LOW

**Change from README.md to CLAUDE.md with links:**

```markdown
# 00-rules - Workflow & Standards

**Purpose:** AI and developer instructions for project workflow and standards

---

## 📚 Rules & Standards

### Versioning
**[VERSIONING.md](VERSIONING.md)** - Version numbering (0.1 increment rule), task archival, release planning

### Testing
**[testing-manual.md](testing-manual.md)** - Manual testing protocol and checklist

### File Organization
**[FILE-ORGANIZATION.md](FILE-ORGANIZATION.md)** - Where files go, lifecycle structure, task workflow

### Code Standards
**[CODE-STANDARDS.md](CODE-STANDARDS.md)** - Naming, documentation, error handling (⏳ Task 005)

---

[Progressive disclosure - link to details in each file]
```

---

## 🔄 EXECUTION ORDER

### Phase 1: Structural Changes (Today)
1. ✅ Rename lifecycle README.md → CLAUDE.md
2. ✅ Move VERSIONING.md to 00-rules/
3. ✅ Create 05-implementation/ folder
4. ✅ Update root CLAUDE.md with rules

### Phase 2: Content Creation (Today/Tomorrow)
5. ✅ Fill 01-vision/ (PURPOSE, ROADMAP, principles)
6. ✅ Create FILE-ORGANIZATION.md
7. ✅ Update 00-rules/CLAUDE.md structure
8. ✅ Add purpose headers to all docs

### Phase 3: Polish & ADRs (This Week)
9. ✅ Create missing ADRs (002-005)
10. ✅ Fix 04-tasks references
11. ✅ Verify all links work

---

## 📝 RULES TO ADD TO ROOT CLAUDE.md

```markdown
## 📁 Documentation Structure Rules

### CLAUDE.md Pattern
- **Root CLAUDE.md** - AI navigation hub, links to lifecycle phases
- **Lifecycle folders** - Each has CLAUDE.md with phase-specific instructions
- **No README.md in lifecycle** - Use CLAUDE.md for consistency

### Purpose Header Rule
Every documentation file MUST start with:
**Purpose:** [One-line description]

Why: Agent immediately knows what document contains

### Progressive Disclosure
- Root CLAUDE.md - Summary + links
- Lifecycle CLAUDE.md - Phase details + file descriptions
- Individual docs - Complete information

### Where Things Go
- **00-rules/** - Process rules (versioning, workflow, standards)
- **01-vision/** - WHY (purpose, roadmap, principles)
- **02-planning/** - WHAT (specs, requirements)
- **03-architecture/** - HOW (technical design, decisions)
- **04-tasks/** - WHEN (current work only)
- **05-implementation/** - DONE (completed work archive)
```

---

## ✅ VALIDATION CHECKLIST

After implementation, verify:
- [ ] All lifecycle folders have CLAUDE.md (not README.md)
- [ ] Root CLAUDE.md links to lifecycle CLAUDE.md
- [ ] Every doc has **Purpose:** header
- [ ] VERSIONING.md in 00-rules/
- [ ] 01-vision/ has content (PURPOSE, ROADMAP, principles)
- [ ] 05-implementation/ folder exists
- [ ] FILE-ORGANIZATION.md created
- [ ] All links work (no broken references)
- [ ] Git workflow documented in CLAUDE.md
- [ ] ADRs created (002-005)

---

## 🎯 SUCCESS CRITERIA

**This reorganization is complete when:**
1. Agent opening any lifecycle folder knows exactly what to do (CLAUDE.md)
2. Every doc has clear purpose (Purpose header)
3. Rules are centralized (00-rules/)
4. Implementation is separated from planning (05-implementation/)
5. All links work
6. No confusion about where things go

---

**Estimated Time:** 2-3 hours
**Impact:** HIGH - Better AI navigation, clearer structure
**Risk:** LOW - Mostly file moves and documentation updates

---

**START IMPLEMENTATION NOW** ⚡
