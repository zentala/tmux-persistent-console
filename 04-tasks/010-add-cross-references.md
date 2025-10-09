**Purpose:** Add cross-references between specs, ADRs, and tasks for better traceability

---

# Task 010: Add Cross-References to Documentation

**Phase:** v0.2 Documentation
**Priority:** 🟡 HIGH
**Estimated Time:** 1 day
**Dependencies:** Task 007, 008, 009 complete
**Assignee:** Unassigned

---

## Objective

Add systematic cross-references between documentation files to improve traceability:
- Specs → ADRs (which decisions apply)
- ADRs → Specs (where decision is used)
- Tasks → Specs (what requirements being implemented)
- Specs → Implementation (where code lives)

**Source:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) - Priority 4

**Why Important:** Currently hard to trace: "This spec uses which ADR?" or "This ADR affects which specs?" Cross-references make understanding decisions and impact much easier.

---

## Problem Examples

**Spec without ADR reference:**
```markdown
# 02-planning/specs/MANAGER-SPEC.md
## F11 Manager uses gum for TUI

[No mention of WHY gum was chosen]
```

Should have:
```markdown
## F11 Manager uses gum for TUI

**Decision:** ADR 003 (Gum UI Framework)
```

**ADR without usage reference:**
```markdown
# 03-architecture/decisions/003-gum-ui-framework.md
[No mention of WHERE gum is actually used]
```

Should have:
```markdown
## Used In
- 02-planning/specs/MANAGER-SPEC.md (F11 interface)
- 02-planning/specs/HELP-SPEC.md (F12 interface)
```

---

## Acceptance Criteria

### Phase 1: Specs → ADRs
- [ ] MANAGER-SPEC.md links to ADR 003 (Gum)
- [ ] MANAGER-SPEC.md links to ADR 005 (No external scripts exception)
- [ ] STATUS-BAR-SPEC.md links to ADR 005 (No external scripts)
- [ ] STATUS-BAR-SPEC.md links to ADR 004 (Theme variables)
- [ ] STATUS-BAR-SPEC.md links to ADR 002 (State caching)
- [ ] HELP-SPEC.md links to ADR 003 (Gum)
- [ ] All specs have "Related ADRs" section

### Phase 2: ADRs → Specs
- [ ] ADR 002 (State caching) lists: STATUS-BAR-SPEC, MANAGER-SPEC
- [ ] ADR 003 (Gum) lists: MANAGER-SPEC, HELP-SPEC
- [ ] ADR 004 (Theme) lists: STATUS-BAR-SPEC, ICONS-SPEC
- [ ] ADR 005 (No scripts) lists: STATUS-BAR-SPEC, MANAGER-SPEC (exception)
- [ ] All ADRs have "Used In" section

### Phase 3: Tasks → Specs
- [ ] Task 001 links to specs it implements
- [ ] Task 002 links to MANAGER-SPEC, HELP-SPEC, STATUS-BAR-SPEC
- [ ] Task 003 links to action-related specs
- [ ] Task 004 links to testing-strategy.md
- [ ] All tasks have "Related Specifications" section

### Phase 4: Specs → Implementation
- [ ] All specs have "Implementation Status" section
- [ ] Status shows v0.1 (current) and v0.2 (planned)
- [ ] Links to actual source files when implemented

Example:
```markdown
## Implementation Status
- [x] v0.1 - Prototype in `src/manager.sh`
- [ ] v0.2 - Refactored in `src/ui/manager/` (Task 002)
```

### Phase 5: Validation
- [ ] All relative links work (no 404s)
- [ ] Cross-reference graph is complete (can trace any connection)
- [ ] No dangling references (all mentioned docs exist)

---

## Implementation Details

### Template Sections to Add

**For Specs (02-planning/specs/):**
```markdown
## Related Architecture Decisions
- **ADR 003:** Gum UI Framework - Why gum for interactive menus
- **ADR 005:** No external scripts in status bar - Exception for F11/F12

## Implementation Status
- [x] v0.1 - Prototype in `src/manager.sh` (lines 45-120)
- [ ] v0.2 - Refactored in `src/ui/manager/` (Task 002)

## Related Tasks
- Task 002: UI components refactoring (implements this spec)
```

**For ADRs (03-architecture/decisions/):**
```markdown
## Used In
- **MANAGER-SPEC:** F11 Manager interface implementation
- **HELP-SPEC:** F12 Help system implementation

## Affects Tasks
- Task 002: UI components (must follow gum patterns)

## Related Specs
- [../../02-planning/specs/MANAGER-SPEC.md](../../02-planning/specs/MANAGER-SPEC.md)
```

**For Tasks (04-tasks/):**
```markdown
## Related Specifications
- **MANAGER-SPEC:** [../02-planning/specs/MANAGER-SPEC.md](../02-planning/specs/MANAGER-SPEC.md)
- **HELP-SPEC:** [../02-planning/specs/HELP-SPEC.md](../02-planning/specs/HELP-SPEC.md)

## Architecture Decisions to Follow
- **ADR 003:** Gum UI with bash fallback pattern
- **ADR 005:** Interactive UIs allowed (not status bar)

## Implementation Impact
- Creates: `src/ui/components/`
- Updates: ARCHITECTURE.md (add component layer)
```

---

## Cross-Reference Matrix

### Specs ↔ ADRs

| Spec | ADRs Referenced |
|------|----------------|
| MANAGER-SPEC | ADR 003 (Gum), ADR 005 (Scripts exception) |
| STATUS-BAR-SPEC | ADR 002 (Caching), ADR 004 (Theme), ADR 005 (No scripts) |
| HELP-SPEC | ADR 003 (Gum) |
| ICONS-SPEC | ADR 004 (Theme variables) |
| SAFE-EXIT-SPEC | ADR 005 (Scripts allowed in interactive) |

### ADRs ↔ Specs

| ADR | Specs Affected |
|-----|---------------|
| ADR 002 (Caching) | STATUS-BAR-SPEC, MANAGER-SPEC |
| ADR 003 (Gum) | MANAGER-SPEC, HELP-SPEC |
| ADR 004 (Theme) | STATUS-BAR-SPEC, ICONS-SPEC |
| ADR 005 (Scripts) | STATUS-BAR-SPEC (rule), MANAGER-SPEC (exception) |

### Tasks ↔ Specs

| Task | Specs Implemented |
|------|-------------------|
| Task 001 | (State management - cross-cutting) |
| Task 002 | MANAGER-SPEC, HELP-SPEC, STATUS-BAR-SPEC (UI) |
| Task 003 | (Actions - cross-cutting) |
| Task 004 | testing-strategy.md |

---

## Implementation Plan

### Hour 1-2: Specs → ADRs
- Edit each spec in 02-planning/specs/
- Add "Related Architecture Decisions" section
- Link to relevant ADRs with brief why

### Hour 3-4: ADRs → Specs
- Edit each ADR in 03-architecture/decisions/
- Add "Used In" section
- List specs and tasks affected

### Hour 5-6: Tasks → Specs
- Edit each task in 04-tasks/001-010.md
- Add "Related Specifications" section
- Add "Architecture Decisions to Follow" section

### Hour 7: Implementation Status
- Add "Implementation Status" to each spec
- Show v0.1 (done) and v0.2 (planned)
- Link to actual source files

### Hour 8: Validation
- Test all relative links
- Build cross-reference graph
- Verify completeness

---

## Testing Requirements

### Link Validation

**Automated check:**
```bash
# Install markdown-link-check (optional)
npm install -g markdown-link-check

# Check all markdown files
find . -name "*.md" -exec markdown-link-check {} \;
```

**Manual check:**
```bash
# Find all markdown links
grep -r "\[.*\](.*\.md)" 02-planning/ 03-architecture/ 04-tasks/

# Verify each link exists
```

### Cross-Reference Completeness

**Verify matrix:**
1. Open MANAGER-SPEC → should link to ADR 003
2. Open ADR 003 → should link back to MANAGER-SPEC
3. Open Task 002 → should link to MANAGER-SPEC
4. Complete loop verification

---

## Success Metrics

- [ ] All 7 specs have "Related ADRs" section
- [ ] All 5 ADRs (including new 001) have "Used In" section
- [ ] All 10 tasks have "Related Specifications" section
- [ ] All specs have "Implementation Status" section
- [ ] Zero broken links in documentation
- [ ] Can trace any spec → ADR → task → code path

---

## Benefits After Completion

**Before:**
```
Developer: "Why do we use gum for F11?"
→ Grep through docs
→ Maybe find ADR 003
→ Maybe find MANAGER-SPEC
→ Total time: 10 minutes
```

**After:**
```
Developer: "Why do we use gum for F11?"
→ Open MANAGER-SPEC
→ See "Related ADRs: ADR 003"
→ Click link, read rationale
→ Total time: 1 minute
```

**Impact:**
- 90% faster documentation navigation
- Clear decision traceability
- Easy impact analysis for changes
- Better onboarding for new contributors

---

## Related Documents

- **Review:** [../03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)
- **All Specs:** [../02-planning/specs/](../02-planning/specs/)
- **All ADRs:** [../03-architecture/decisions/](../03-architecture/decisions/)
- **All Tasks:** [../04-tasks/](../04-tasks/)

---

## Deliverables

1. All specs updated with cross-references
2. All ADRs updated with usage info
3. All tasks updated with spec links
4. Link validation report (all links work)
5. Cross-reference matrix document (this file serves as template)

---

## Notes

**Best Practice:**
When creating new documents in future, always add cross-references immediately. This task fixes existing docs; prevention is cheaper than cure.

**Estimated Time Breakdown:**
- Specs → ADRs: 2 hours
- ADRs → Specs: 2 hours
- Tasks → Specs: 2 hours
- Implementation Status: 1 hour
- Validation: 1 hour
- **Total: 8 hours (1 day)**
