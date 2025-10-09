**Purpose:** Fix task dependency confusion - update version references and task numbers to v0.2 standards

---

# Task 007: Fix Task Dependencies and Version References

**Phase:** v0.2 Documentation Fixes
**Priority:** 🔴 CRITICAL
**Estimated Time:** 4 hours
**Dependencies:** Task 006 complete
**Assignee:** Unassigned

---

## Objective

Fix critical inconsistencies in task files where:
- Phase says "v0.2" but dependencies reference "v1.0" or "v1.5"
- Old task numbers (013-017) referenced instead of new numbers (001-005)
- "v1.0 complete (001-012)" should be "v0.1 complete" or "no dependencies"

**Source:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) - Priority 1

---

## Problem Examples

**Task 001:**
```markdown
Phase: v0.2 Refactoring ✅
Dependencies: v1.0 complete (001-012) ❌ WRONG!
```
Should be: "Dependencies: v0.1 complete" or "None (fresh refactoring)"

**Task 002:**
```markdown
Dependencies: 013 (State management complete) ❌ WRONG!
```
Should be: "Dependencies: 001 (State management complete)"

**Task 004:**
```markdown
Dependencies: 013, 014, 015 (Core modules refactored) ❌ WRONG!
```
Should be: "Dependencies: 001, 002, 003 (Core modules refactored)"

---

## Acceptance Criteria

### Phase 1: Fix Version References
- [ ] Task 001: Change "v1.0 complete" → "v0.1 complete" or remove
- [ ] Task 002: Change "v1.5" → "v0.2" in all metadata
- [ ] Task 003: Change "v1.5" → "v0.2" in all metadata
- [ ] Task 004: Change "v1.5" → "v0.2" in all metadata
- [ ] Task 005: Change "v1.5" → "v0.2" in all metadata

### Phase 2: Fix Task Number References
- [ ] Task 002: Change "013" → "001"
- [ ] Task 003: Change "013, 014" → "001, 002"
- [ ] Task 004: Change "013, 014, 015" → "001, 002, 003"
- [ ] Task 005: Change "013, 014, 015, 016" → "001, 002, 003, 004"

### Phase 3: Validate Dependencies
- [ ] Task 001: Should have no dependencies (fresh refactoring)
- [ ] Task 002: Depends on 001
- [ ] Task 003: Depends on 001, 002
- [ ] Task 004: Depends on 001, 002, 003
- [ ] Task 005: Depends on 001, 002, 003, 004

### Phase 4: Verification
- [ ] All task files use v0.2 consistently
- [ ] No references to v1.0, v1.5, v2.0
- [ ] All task numbers are 001-007 (current tasks)
- [ ] Dependency chain is correct: 001 → 002 → 003 → 004 → 005

---

## Implementation Details

### Files to Edit

1. **04-tasks/001-refactor-state-management.md**
   - Remove "v1.0 complete (001-012)" from Dependencies
   - Change to: "Dependencies: None (fresh refactoring from v0.1 code)"

2. **04-tasks/002-refactor-ui-components.md**
   - Change Phase: "v1.5 Refactoring" → "v0.2 Refactoring"
   - Change Dependencies: "013" → "001 (State management complete)"

3. **04-tasks/003-refactor-actions.md**
   - Change Phase: "v1.5 Refactoring" → "v0.2 Refactoring"
   - Change Dependencies: "013, 014" → "001, 002 (State and UI refactored)"

4. **04-tasks/004-testing-framework.md**
   - Change Phase: "v1.5 Refactoring" → "v0.2 Refactoring"
   - Change Dependencies: "013, 014, 015" → "001, 002, 003 (Core modules refactored)"

5. **04-tasks/005-code-standards.md**
   - Change Phase: "v1.5 Refactoring" → "v0.2 Refactoring"
   - Change Dependencies: "013, 014, 015, 016" → "001, 002, 003, 004 (Refactoring complete)"

### Search-Replace Commands

```bash
# In 04-tasks/ directory
sed -i 's/v1\.5 Refactoring/v0.2 Refactoring/g' 00*.md
sed -i 's/v1\.0 Refactoring/v0.2 Refactoring/g' 00*.md
sed -i 's/Dependencies: v1\.0 complete (001-012)/Dependencies: None (fresh refactoring from v0.1 code)/g' 001-*.md
```

**Note:** Verify manually after sed to ensure context is correct.

---

## Testing Requirements

### Manual Verification

**Test 1: Version Consistency**
```bash
# Should return NO results
grep -n "v1\.[0-9]" 04-tasks/00*.md
grep -n "v2\.[0-9]" 04-tasks/00*.md
```

**Test 2: Task Number References**
```bash
# Should return NO results (no references to old task numbers)
grep -n "Dependencies.*01[3-9]" 04-tasks/00*.md
grep -n "Task 01[3-9]" 04-tasks/00*.md
```

**Test 3: Dependency Chain**
```bash
# Verify dependency chain makes sense
grep -n "Dependencies:" 04-tasks/00*.md
```

Expected output:
```
001: Dependencies: None
002: Dependencies: 001
003: Dependencies: 001, 002
004: Dependencies: 001, 002, 003
005: Dependencies: 001, 002, 003, 004
```

---

## Why This Matters

**Impact of NOT Fixing:**
1. Developer sees "v1.0" in v0.2 task → confusion about version
2. Developer looks for "Task 013" → doesn't exist → blocked
3. Unclear dependency chain → wrong execution order
4. Future AI agents get confused by contradicting metadata

**Impact of Fixing:**
1. ✅ Clear version progression (v0.1 → v0.2)
2. ✅ Correct task references (001-007)
3. ✅ Logical dependency chain
4. ✅ No confusion for humans or AI

---

## Related Issues

**From Documentation Review:**
- Priority 1: Task Dependency Confusion (5/10)
- Files Affected: All tasks 001-005
- Score Impact: Fixes consistency score from 7/10 → 9/10

---

## Success Metrics

- [ ] Zero references to v1.0, v1.5, v2.0 in task files
- [ ] All task numbers referenced are 001-007
- [ ] Dependency chain is linear and correct
- [ ] All metadata matches current version (v0.2)

---

## Completion Checklist

- [ ] All 5 task files updated
- [ ] Grep tests pass (no old version/task numbers)
- [ ] Dependency chain verified
- [ ] Commit with message: "fix(tasks): Correct version references and task numbers"
- [ ] Mark this task (007) complete in TODO.md

---

## Related Documents

- **Review:** [../03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)
- **Versioning Rules:** [../00-rules/VERSIONING.md](../00-rules/VERSIONING.md)
- **Task Management:** [../00-rules/TASK-MANAGEMENT.md](../00-rules/TASK-MANAGEMENT.md)

---

**Estimated Time Breakdown:**
- Phase 1 (version fixes): 1 hour
- Phase 2 (task number fixes): 1 hour
- Phase 3 (validate dependencies): 1 hour
- Phase 4 (testing): 1 hour
- **Total: 4 hours**

**This is the highest priority fix - blocks all other work until complete.**
