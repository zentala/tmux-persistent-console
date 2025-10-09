**Purpose:** Current sprint backlog and task status for v0.2

---

# TODO - v0.2 Sprint Backlog

**Version:** v0.2 (in development)
**Phase:** Documentation Fixes → Refactoring
**Last Updated:** 2025-10-09

---

## 🎯 Current Sprint Goals

1. ✅ Complete folder reorganization
2. ✅ Define versioning strategy
3. ✅ Documentation reorganization (Task 006)
4. 🔴 **CRITICAL:** Fix documentation issues (Tasks 007-010)
5. ⏳ Refactor to modular architecture (Tasks 001-003)
6. ⏳ Setup testing framework (Task 004)

**Progress:** 50% (3/6 sprint goals complete)

---

## 📋 Active Tasks

### 🔴 CRITICAL (Must Fix Before Refactoring)

**[007-fix-task-dependencies.md](007-fix-task-dependencies.md)** - Fix version references
- **Priority:** 🔴 CRITICAL
- **Time:** 4 hours
- **Issue:** Tasks reference "v1.0" and old numbers (013-017)
- **Blocks:** All other work
- **Status:** ⏳ PENDING

**[008-create-code-standards.md](008-create-code-standards.md)** - Create CODE-STANDARDS.md
- **Priority:** 🔴 CRITICAL
- **Time:** 2 days
- **Issue:** No coding standards documented
- **Blocks:** Tasks 001-003 (refactoring)
- **Status:** ⏳ PENDING

---

### 🟡 HIGH (Fix During Sprint)

**[009-testing-strategy.md](009-testing-strategy.md)** - Testing strategy document
- **Priority:** 🟡 HIGH
- **Time:** 1 day
- **Deliverable:** 03-architecture/testing-strategy.md
- **Enables:** Task 004 (clear requirements)
- **Status:** ⏳ PENDING

**[010-add-cross-references.md](010-add-cross-references.md)** - Cross-reference docs
- **Priority:** 🟡 HIGH
- **Time:** 1 day
- **Benefit:** Better traceability, easier navigation
- **Status:** ⏳ PENDING

---

### ⏳ Refactoring Tasks (Blocked Until 007-008 Done)

**[001-refactor-state-management.md](001-refactor-state-management.md)** - State module
- **Blocked by:** Task 007, 008
- **Status:** ⏳ WAITING

**[002-refactor-ui-components.md](002-refactor-ui-components.md)** - UI components
- **Blocked by:** Task 001, 007, 008
- **Status:** ⏳ WAITING

**[003-refactor-actions.md](003-refactor-actions.md)** - Action layer
- **Blocked by:** Task 001, 002, 007, 008
- **Status:** ⏳ WAITING

**[004-testing-framework.md](004-testing-framework.md)** - bats testing
- **Blocked by:** Task 009 (needs strategy)
- **Status:** ⏳ WAITING

**[005-code-standards.md](005-code-standards.md)** - ⚠️ REPLACED BY TASK 008
- **Note:** This task number kept for historical tracking
- **Actual work:** Task 008 creates the document
- **Status:** ⏳ See Task 008

---

## ✅ Completed Tasks

### Documentation & Organization (Week 1)
- ✅ **Task 006:** Documentation reorganization
  - Lifecycle structure (00-05 folders)
  - CLAUDE.md pattern established
  - Purpose headers added
  - ADRs created (002-005)
  - Vision documents (PURPOSE, ROADMAP, principles)

### Foundation (Before Task 006)
- ✅ Lifecycle folder structure created
- ✅ Files moved to proper locations
- ✅ VERSIONING.md rules established
- ✅ Task numbering system defined

---

## 📊 Sprint Timeline

### Week 1: Foundation ✅ DONE
- [x] Folder reorganization
- [x] Versioning strategy
- [x] Documentation structure (Task 006)

### Week 2: Documentation Fixes 🔄 IN PROGRESS
- [ ] Task 007: Fix dependencies (Day 1)
- [ ] Task 008: CODE-STANDARDS.md (Day 2-3)
- [ ] Task 009: Testing strategy (Day 4)
- [ ] Task 010: Cross-references (Day 5)

### Week 3-4: Refactoring ⏳ PLANNED
- [ ] Task 001: State management
- [ ] Task 002: UI components
- [ ] Task 003: Actions layer

### Week 5: Testing ⏳ PLANNED
- [ ] Task 004: Testing framework
- [ ] Write tests for refactored code

---

## 🚦 Current Blockers

**🔴 CRITICAL BLOCKER:**
- Tasks 007-008 must complete before ANY refactoring starts
- Reason: Version confusion + no coding standards = chaos

**Impact:**
- Tasks 001-003 cannot start until 007-008 done
- Task 004 needs Task 009 for requirements
- Total delay: ~3-4 days to fix documentation issues

**Mitigation:**
- Prioritize 007-008 immediately
- Parallel work on 009-010 while 008 in progress
- Clear timeline prevents further delays

---

## 📝 Notes from Documentation Review

**Score:** 7.5/10 (Very Good)

**Strengths:**
- ⭐ Lifecycle structure excellent
- ⭐ ADR quality high
- ⭐ SSOT pattern clear

**Critical Issues Fixed by Tasks 007-010:**
1. Task dependencies confusion → Task 007
2. Missing CODE-STANDARDS → Task 008
3. Missing testing strategy → Task 009
4. Incomplete cross-references → Task 010

**See:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) for complete review

---

## 🎯 Next Actions

### Immediate (This Week)
1. 🔴 Start Task 007 (fix dependencies) - 4 hours
2. 🔴 Start Task 008 (code standards) - 2 days
3. 🟡 Start Task 009 (testing strategy) - 1 day
4. 🟡 Start Task 010 (cross-references) - 1 day

### After Documentation Fixes
5. ⏳ Start Task 001 (state refactoring)
6. ⏳ Start Task 002 (UI components)
7. ⏳ Start Task 003 (actions)

---

## 🔗 Related Documents

- **[TASK-MANAGEMENT.md](../00-rules/TASK-MANAGEMENT.md)** - How to create and manage tasks
- **[VERSIONING.md](../00-rules/VERSIONING.md)** - Version planning
- **[DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)** - Review that created tasks 007-010
- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - What we're building

---

## 📋 Future Tasks (v0.2+ Backlog)

**Moved to 02-planning/backlog/:**
- Status bar improvements (shadows, icons)
- Suspended terminals F8-F10 configuration
- Ctrl+Esc detach enhancement
- Ctrl+Del restart enhancement
- GitHub Pages (ptty.zentala.io)
- Contributions guide
- Website structure

---

**Current Focus:** Complete Tasks 007-010 (documentation fixes) before starting refactoring work.
