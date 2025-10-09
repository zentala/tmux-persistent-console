**Purpose:** Pre-implementation UX review process for v0.2 refactoring - ensure documentation completeness and UX quality before coding

---

# Task 011: Pre-Implementation UX Review

**Priority:** 🔴 CRITICAL
**Phase:** v0.2 Documentation → Implementation Gate
**Dependencies:** Tasks 006-010 complete (documentation foundation ready)
**Blocks:** Tasks 001-004 (cannot start implementation without UX review approval)

---

## Goal

**Conduct comprehensive UX review of documentation before implementing v0.2 refactoring. Focus on user experience aspects and validate "how it should look in the end" before writing code.**

**Rationale:** Documentation describes desired UX. Code implements documentation. Therefore, UX must be perfect in documentation first, then implementation follows.

---

## Review Checklist

### 1. Status Bar UX Review

**Documentation:** [STATUS-BAR-SPEC.md](../02-planning/specs/STATUS-BAR-SPEC.md)

**UX Questions:**
- [ ] Is console state immediately obvious at a glance?
- [ ] Are active/inactive/crashed states visually distinct?
- [ ] Do icons convey meaning without reading text?
- [ ] Is current console clearly highlighted?
- [ ] Will ASCII fallback provide acceptable UX without Nerd Fonts?
- [ ] Is status bar readable on both dark and light terminals?
- [ ] Does theme provide good contrast (accessibility)?

**Visual Mock-up Validation:**
```
[F1:●web F2:●api F3:○log F4:●db F5:✖task F6:○ F7:○ F8:○ F9:○ F10:○] zentala@vps 14:23
```

**Questions:**
- Can user immediately see which consoles are active?
- Is crashed console (F5:✖) alarming enough?
- Is current console (F1 bold) obvious?
- Would a new user understand this without explanation?

**Related ADRs:**
- [ADR 002](../03-architecture/decisions/002-state-management-caching.md) - State caching (5s TTL)
- [ADR 004](../03-architecture/decisions/004-theme-shell-vars.md) - Theme customization
- [ADR 005](../03-architecture/decisions/005-no-external-scripts-statusbar.md) - ⚠️ No flicker rule

---

### 2. F11 Manager UX Review

**Documentation:** [MANAGER-SPEC.md](../02-planning/specs/MANAGER-SPEC.md)

**UX Questions:**
- [ ] Is main menu self-explanatory?
- [ ] Are keyboard shortcuts intuitive (1-9, R, K, A)?
- [ ] Is console list readable (name, state, uptime)?
- [ ] Does "restart" action provide sufficient warning?
- [ ] Does "kill" action prevent accidents?
- [ ] Is navigation between menu levels clear?
- [ ] Will gum fallback to bash provide acceptable UX?

**Visual Mock-up Validation:**
```
┌─────────────────────────────────────┐
│         Console Manager             │
├─────────────────────────────────────┤
│ 1. console-1 (web)      ● Active    │
│ 2. console-2 (api)      ● Active    │
│ 3. console-3 (logs)     ○ Inactive  │
│ 4. console-4 (db)       ● Active    │
│ 5. console-5 (tasks)    ✖ Crashed   │
│                                     │
│ [R] Restart  [K] Kill  [A] Activate│
│ [ESC] Back                          │
└─────────────────────────────────────┘
```

**Questions:**
- Can user perform all actions without reading docs?
- Are destructive actions (Kill) sufficiently protected?
- Is crashed console (console-5) obvious?
- Would first-time user know what to do?

**Related ADRs:**
- [ADR 003](../03-architecture/decisions/003-gum-ui-framework.md) - Gum TUI framework

---

### 3. F12 Help UX Review

**Documentation:** [HELP-SPEC.md](../02-planning/specs/HELP-SPEC.md)

**UX Questions:**
- [ ] Are shortcuts organized logically?
- [ ] Is grouping (Console Switching, Navigation, Actions) clear?
- [ ] Are key combinations written consistently?
- [ ] Is help discoverable (Ctrl+H, Ctrl+?)?
- [ ] Does help stay on screen long enough to read?
- [ ] Is system info useful (version, config, crash dumps)?
- [ ] Can user close help easily (ESC, Ctrl+F12)?

**Content Structure Validation:**
```
CONSOLE SWITCHING
─────────────────
Ctrl+F1-F5     Switch to active console (F1-F5)
Ctrl+F6-F10    Activate/switch to console (F6-F10)
Ctrl+F11       Open Manager
Ctrl+F12       Show this help

NAVIGATION
──────────
Ctrl+Left      Previous console
Ctrl+Right     Next console
Ctrl+Esc       Detach safely
```

**Questions:**
- Can user find the shortcut they need quickly?
- Are descriptions clear and actionable?
- Is terminology consistent with other docs?
- Would user understand "active" vs "suspended"?

**Related ADRs:**
- [ADR 003](../03-architecture/decisions/003-gum-ui-framework.md) - Gum TUI framework

---

### 4. Safe Exit UX Review

**Documentation:** [SAFE-EXIT-SPEC.md](../02-planning/specs/SAFE-EXIT-SPEC.md)

**UX Questions:**
- [ ] Is menu message clear and reassuring?
- [ ] Are options (Enter, ESC, SHIFT+Y) intuitive?
- [ ] Does error message help user (lowercase 'y')?
- [ ] Is restart action sufficiently protected?
- [ ] Does detach message provide clear next steps?
- [ ] Is wrapper behavior predictable?

**Interaction Flow Validation:**
```bash
# User types: exit
You're in a persistent tmux session.
- Press ENTER to detach safely (session continues)
- Press ESC or Ctrl+C to stay in session
- Press SHIFT+Y to restart console (dangerous!)

Your choice: _
```

**Questions:**
- Does user understand "detach" vs "restart"?
- Is "dangerous" warning strong enough?
- Will user accidentally restart console?
- Is "session continues" reassuring?

**Related Specs:**
- [SAFE-EXIT-SPEC.md](../02-planning/specs/SAFE-EXIT-SPEC.md)

---

### 5. Keyboard Shortcuts UX Review

**Documentation:** [GLOSSARY.md](../02-planning/specs/GLOSSARY.md)

**UX Questions:**
- [ ] Are shortcuts consistent across features?
- [ ] Are Ctrl+F1-F12 easy to remember?
- [ ] Is Ctrl+H discoverable for quick help?
- [ ] Are arrow keys (Ctrl+Left/Right) intuitive?
- [ ] Is ESC consistently used for "cancel/back"?
- [ ] Are traditional tmux shortcuts preserved?

**Shortcut Consistency Check:**

| Action | Shortcut | Consistent? |
|--------|----------|-------------|
| Close/Cancel | ESC | ✅ (Manager, Help, Safe Exit) |
| Help | Ctrl+H, Ctrl+? | ✅ (Two aliases) |
| Switch Console | Ctrl+F1-F10 | ✅ (F-key pattern) |
| Navigation | Ctrl+Left/Right | ✅ (Arrow keys) |
| Restart | Ctrl+R | ✅ (R for Restart) |

**Questions:**
- Will user guess the right key?
- Are there conflicting shortcuts?
- Do shortcuts match user mental models?

---

### 6. Error Handling UX Review

**UX Questions:**
- [ ] Are error messages helpful (not just technical)?
- [ ] Do errors suggest next steps?
- [ ] Are destructive actions reversible or protected?
- [ ] Is crashed console state visually alarming?
- [ ] Does system recover gracefully from failures?

**Error Message Examples:**

**Bad:**
```
Error: Session not found
```

**Good:**
```
Console 'web' not found. Use Ctrl+F11 to see active consoles.
```

**Questions:**
- Do error messages help user fix the problem?
- Are errors scary or reassuring?
- Does system prevent user mistakes?

---

### 7. Theming & Accessibility UX Review

**Documentation:** [ADR 004](../03-architecture/decisions/004-theme-shell-vars.md)

**UX Questions:**
- [ ] Do default colors work on dark terminals?
- [ ] Do default colors work on light terminals?
- [ ] Is contrast sufficient (WCAG 2.1 AA)?
- [ ] Are icons distinguishable (●, ○, ✖)?
- [ ] Does ASCII fallback provide acceptable UX?
- [ ] Is customization process documented?

**Color Accessibility Check:**

| Element | Foreground | Background | Contrast Ratio | WCAG AA? |
|---------|------------|------------|----------------|----------|
| Active | colour15 | colour22 | ~8:1 | ✅ |
| Inactive | colour244 | colour235 | ~4.5:1 | ✅ |
| Crashed | colour196 | colour235 | ~7:1 | ✅ |

**Questions:**
- Can colorblind users distinguish states?
- Will theme work on various terminal emulators?
- Is customization easy enough?

---

### 8. Documentation Completeness Review

**UX Questions:**
- [ ] Can user understand system without external help?
- [ ] Are all features documented in specs?
- [ ] Do examples match actual behavior?
- [ ] Are edge cases covered (crashed, suspended)?
- [ ] Is terminology consistent across all docs?
- [ ] Are visual mock-ups accurate?

**Documentation Coverage:**

| Feature | Spec | ADR | Task | Example | Status |
|---------|------|-----|------|---------|--------|
| Status Bar | ✅ | ✅ (005) | ✅ (001) | ✅ | Complete |
| F11 Manager | ✅ | ✅ (003) | ✅ (002) | ✅ | Complete |
| F12 Help | ✅ | ✅ (003) | ✅ (002) | ✅ | Complete |
| Safe Exit | ✅ | - | ✅ (003) | ✅ | Complete |
| State Caching | ✅ | ✅ (002) | ✅ (001) | ✅ | Complete |
| Theming | ✅ | ✅ (004) | ✅ (002) | ✅ | Complete |

**Questions:**
- Is anything undocumented?
- Do specs match user expectations?
- Are examples realistic?

---

## Review Process

### Step 1: Individual Feature Review (30 minutes)

For each feature (Status Bar, Manager, Help, Safe Exit):

1. **Read specification** thoroughly
2. **Visualize user interaction** (mental walkthrough)
3. **Answer UX questions** in checklist
4. **Identify issues** (confusing, missing, inconsistent)
5. **Document findings** below

### Step 2: Cross-Feature Consistency Review (15 minutes)

Check consistency across features:

1. **Keyboard shortcuts** - any conflicts?
2. **Terminology** - consistent usage?
3. **Visual style** - cohesive look?
4. **Error messages** - similar tone?
5. **Navigation** - consistent patterns?

### Step 3: Documentation Quality Review (15 minutes)

Verify documentation completeness:

1. **Specs vs ADRs** - aligned?
2. **Examples** - accurate?
3. **Edge cases** - covered?
4. **Visuals** - clear?
5. **Cross-references** - complete?

### Step 4: User Persona Walkthrough (20 minutes)

Test with 3 personas:

**Persona 1: New User (never used tmux)**
- Can they understand pTTY without reading docs?
- Will they discover F11 Manager and F12 Help?
- Will they accidentally kill sessions?

**Persona 2: tmux Power User**
- Will traditional shortcuts still work?
- Will they be annoyed by safe-exit wrapper?
- Can they customize everything?

**Persona 3: Accessibility User**
- Can they use ASCII fallback?
- Are colors readable?
- Are shortcuts documented?

### Step 5: Final Decision (5 minutes)

**Go/No-Go Decision:**

- [ ] All critical UX issues resolved
- [ ] Documentation complete and accurate
- [ ] Consistency verified
- [ ] Accessibility acceptable
- [ ] User personas satisfied

**If GO:** Approve Tasks 001-004 for implementation
**If NO-GO:** Document issues, create fix tasks, repeat review

---

## Review Findings Template

### Issue ID: UX-001
**Feature:** [Status Bar / Manager / Help / Safe Exit / Other]
**Severity:** [Critical / High / Medium / Low]
**Description:** [What's wrong or confusing]
**User Impact:** [How this affects user experience]
**Suggested Fix:** [How to improve]
**Related Docs:** [Links to specs/ADRs]

---

## Acceptance Criteria

**Documentation Quality:**
- [ ] All specs have clear visual mock-ups
- [ ] All UX questions answered satisfactorily
- [ ] All keyboard shortcuts documented
- [ ] All error messages reviewed
- [ ] All edge cases covered

**UX Quality:**
- [ ] New user can use system without reading docs
- [ ] Power user not annoyed by changes
- [ ] Accessibility requirements met
- [ ] Consistency across all features
- [ ] No confusing or ambiguous behavior

**Implementation Readiness:**
- [ ] Clear "how it should look in the end"
- [ ] No open UX questions
- [ ] No blocking issues
- [ ] Tasks 001-004 ready to start

---

## Next Steps After Review

### If Review PASSES:
1. Document approval in this task (date, reviewer)
2. Update TODO.md - mark Task 011 complete
3. Begin Task 001 (State Management refactoring)
4. Proceed with confidence (UX validated)

### If Review FAILS:
1. Create fix tasks for identified issues
2. Update specs/ADRs as needed
3. Schedule follow-up review
4. Block Tasks 001-004 until issues resolved

---

## Related Documentation

**Specifications:**
- [STATUS-BAR-SPEC.md](../02-planning/specs/STATUS-BAR-SPEC.md) - Status bar visual design
- [MANAGER-SPEC.md](../02-planning/specs/MANAGER-SPEC.md) - F11 Manager interface
- [HELP-SPEC.md](../02-planning/specs/HELP-SPEC.md) - F12 Help content
- [SAFE-EXIT-SPEC.md](../02-planning/specs/SAFE-EXIT-SPEC.md) - Safe exit behavior
- [GLOSSARY.md](../02-planning/specs/GLOSSARY.md) - Keyboard shortcuts

**Architecture Decisions:**
- [ADR 002](../03-architecture/decisions/002-state-management-caching.md) - State caching strategy
- [ADR 003](../03-architecture/decisions/003-gum-ui-framework.md) - Gum TUI framework
- [ADR 004](../03-architecture/decisions/004-theme-shell-vars.md) - Theme configuration
- [ADR 005](../03-architecture/decisions/005-no-external-scripts-statusbar.md) - ⚠️ No flicker rule

**Implementation Tasks (Blocked by this review):**
- [Task 001](001-refactor-state-management.md) - State Management
- [Task 002](002-refactor-ui-components.md) - UI Components
- [Task 003](003-refactor-actions.md) - Actions layer
- [Task 004](004-testing-framework.md) - Testing framework

---

## Review History

### Review #1: [Date]
**Reviewer:** [Name]
**Status:** [In Progress / Complete]
**Issues Found:** [Count]
**Decision:** [GO / NO-GO]
**Notes:** [Summary of findings]

---

**This review is the quality gate between documentation and implementation. Do not proceed to coding without completing this review and achieving GO decision.**

---

## Workflow

```
Documentation (Tasks 006-010) ✅
           ↓
UX Review (Task 011) ⏳ ← YOU ARE HERE
           ↓
    [GO Decision?]
      ↙         ↘
    YES          NO
     ↓            ↓
Implementation   Fix Issues
(Tasks 001-004)  (New tasks)
                    ↓
              Repeat Review
```

**Current Status:** Ready for review - Documentation foundation complete (9.0/10)

**Estimated Time:** 90 minutes total review time

**Next Session Command:** "Zróbmy UX review zgodnie z Task 011" (Let's do UX review according to Task 011)
