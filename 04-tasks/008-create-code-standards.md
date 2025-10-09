**Purpose:** Create comprehensive CODE-STANDARDS.md to guide v0.2 refactoring with consistent naming and patterns

---

# Task 008: Create CODE-STANDARDS.md

**Phase:** v0.2 Documentation
**Priority:** 🔴 CRITICAL
**Estimated Time:** 2 days
**Dependencies:** Task 007 (dependency fixes)
**Assignee:** Unassigned

---

## Objective

Create comprehensive code standards document that defines:
- Naming conventions (functions, variables, files, directories)
- Function documentation format (docstrings)
- Error handling patterns (exit codes, error messages)
- Return code standards (0=success, non-zero=error)
- File structure conventions
- Comment style and best practices

**Source:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) - Priority 2

**Why Critical:** Tasks 001-003 (refactoring) CANNOT proceed without clear coding standards. Without this, each developer/AI will use different patterns → inconsistent codebase → technical debt.

---

## Problem Statement

Currently:
- ❌ No documented coding standards
- ❌ Existing code has mixed patterns
- ❌ No agreement on naming conventions
- ❌ Error handling inconsistent
- ❌ Function documentation varies

This blocks:
- Task 001: State management refactoring
- Task 002: UI components extraction
- Task 003: Actions layer creation
- Task 005: Code standards enforcement

---

## Acceptance Criteria

### Phase 1: Naming Conventions
- [ ] Function naming pattern defined (lowercase_with_underscores)
- [ ] Variable naming pattern defined (lowercase, UPPERCASE for constants)
- [ ] File naming pattern defined (kebab-case.sh)
- [ ] Directory structure conventions
- [ ] Examples for each pattern

### Phase 2: Documentation Standards
- [ ] Function docstring format (param types, return values, examples)
- [ ] Module header format (purpose, dependencies, version)
- [ ] Inline comment style (when/where to comment)
- [ ] TODO/FIXME/NOTE conventions

### Phase 3: Error Handling
- [ ] Exit code standards (0, 1, 2 meanings)
- [ ] Error message format (stderr with ERROR: prefix)
- [ ] Error logging strategy
- [ ] Graceful degradation patterns

### Phase 4: Code Structure
- [ ] Function length guidelines (max lines)
- [ ] Module organization (order: constants, helpers, main functions)
- [ ] Dependency management (sourcing other files)
- [ ] Global vs local variables

### Phase 5: Testing Standards
- [ ] Test file naming (*.bats)
- [ ] Test function naming (test_module_function_scenario)
- [ ] Assertion patterns
- [ ] Mock conventions

### Phase 6: Examples & References
- [ ] Good vs bad examples for each rule
- [ ] Reference existing code that follows standards
- [ ] Checklist for code reviews

---

## Implementation Details

### Document Structure

```markdown
# CODE-STANDARDS.md

**Purpose:** Coding standards for all pTTY bash code

## 1. Naming Conventions

### Functions
- Pattern: verb_noun_modifier()
- Example: get_console_state(), validate_user_input()
- NOT: GetConsoleState(), validateInput()

### Variables
- Local: lowercase_with_underscores
- Global: UPPERCASE_WITH_UNDERSCORES (avoid if possible)
- Readonly: readonly PREFIX (const-like)

### Files
- Scripts: kebab-case.sh
- Libraries: module-name.sh
- Tests: test-module-name.bats

## 2. Function Documentation

### Format
```bash
# Brief one-line description
#
# Longer description if needed (optional).
#
# Arguments:
#   $1 - description (type)
#   $2 - description (type)
#
# Returns:
#   0 - success
#   1 - error with message to stderr
#
# Example:
#   get_console_state "console-1"
#
function_name() {
    # implementation
}
```

## 3. Error Handling

### Exit Codes
- 0: Success
- 1: General error
- 2: Usage error (wrong arguments)
- 126: Command found but not executable
- 127: Command not found

### Error Messages
```bash
# Always to stderr
echo "ERROR: Description of what went wrong" >&2
return 1

# Include context
echo "ERROR: Console '$name' not found" >&2
```

## 4. Code Organization

### Module Structure
```bash
#!/usr/bin/env bash
# Module purpose one-liner
#
# Longer description
# Dependencies: core/state.sh, core/config.sh

set -euo pipefail  # Strict mode

# Constants
readonly MODULE_VERSION="0.2.0"
readonly CACHE_DIR="${HOME}/.cache/ptty"

# Helper functions (prefixed with _)
_private_helper() {
    # ...
}

# Public API functions
public_function() {
    # ...
}
```

## 5. Best Practices

### DO ✅
- Use `local` for function variables
- Quote all variables: "$var"
- Check command existence: `command -v cmd`
- Validate inputs early
- Return meaningful exit codes

### DON'T ❌
- Use global variables (except readonly)
- Ignore errors (use `set -e` or check $?)
- Write functions >50 lines (split them)
- Use backticks (use $() instead)
- Hard-code paths (use variables)

## 6. Testing Standards

[Test conventions...]

## 7. Code Review Checklist

[Checklist for reviewing PRs...]
```

---

## Content to Include

### 1. Analyze Existing Code Patterns

**Good patterns to document:**
```bash
# From src/ (extract current good practices)
grep -r "^[a-z_]*() {" src/ | head -20  # Find function patterns
grep -r "readonly" src/                # Find constant patterns
grep -r "return [0-9]" src/            # Find exit code patterns
```

### 2. Reference External Standards

- Google Shell Style Guide (adapt for pTTY)
- ShellCheck rules (document which we follow)
- Bash best practices from community

### 3. pTTY-Specific Conventions

From [03-architecture/NAMING.md](../03-architecture/NAMING.md):
- Console (not terminal, not session)
- Manager (F11 interface)
- Status bar (not statusbar)
- Use terminology from GLOSSARY.md

### 4. Error Handling from ADRs

Reference:
- ADR 002: Caching strategy (how to handle cache errors)
- ADR 005: Fallback patterns (gum → bash fallback)

---

## Testing Requirements

### Validation Checklist

After creating CODE-STANDARDS.md:

- [ ] All naming patterns have 3+ examples each
- [ ] Error handling has complete example functions
- [ ] Document references NAMING.md terminology
- [ ] Cross-links to relevant ADRs
- [ ] Checklist section for code reviews
- [ ] Good vs Bad examples for each rule

### Review by Stakeholders

- [ ] Review by task 001 assignee (will use for state refactoring)
- [ ] Review by task 002 assignee (will use for UI refactoring)
- [ ] Check against existing src/ code (can we apply retroactively?)

---

## Why This Matters

**Without CODE-STANDARDS.md:**
```bash
# Developer A writes:
function GetConsoleState() {
    ConsoleState=$(tmux list-sessions)
    echo $ConsoleState  # No quotes, global var
}

# Developer B writes:
get_console_state() {
    local state
    state=$(tmux list-sessions) || return 1
    echo "$state"
}

# Result: Inconsistent codebase ❌
```

**With CODE-STANDARDS.md:**
```bash
# Both developers write:
get_console_state() {
    local state
    state=$(tmux list-sessions) || {
        echo "ERROR: Failed to get console state" >&2
        return 1
    }
    echo "$state"
}

# Result: Consistent codebase ✅
```

---

## Implementation Plan

### Day 1: Core Standards (8 hours)

**Morning (4h):**
- Analyze existing src/ code patterns
- Extract common conventions
- Document naming patterns (functions, vars, files)

**Afternoon (4h):**
- Write function documentation format
- Create error handling standards
- Add code organization rules

### Day 2: Examples & Polish (8 hours)

**Morning (4h):**
- Write good vs bad examples for each rule
- Create testing standards section
- Add code review checklist

**Afternoon (4h):**
- Cross-link to NAMING.md, ADRs
- Add references to external style guides
- Review and validate completeness

---

## Success Metrics

- [ ] Document created: 00-rules/CODE-STANDARDS.md
- [ ] All 7 sections complete (naming, docs, errors, structure, best practices, testing, review)
- [ ] Minimum 3 examples per pattern
- [ ] Cross-links to NAMING.md and ADRs work
- [ ] Reviewed by at least 2 people
- [ ] Tasks 001-003 can proceed with clear standards

---

## Deliverables

1. **00-rules/CODE-STANDARDS.md** (main document)
2. **Updated 00-rules/CLAUDE.md** (add CODE-STANDARDS link)
3. **Updated 04-tasks/TODO.md** (mark Task 008 complete)

---

## Related Documents

- **Review:** [../03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)
- **Naming:** [../03-architecture/NAMING.md](../03-architecture/NAMING.md) - Terminology standards
- **Task 001:** [001-refactor-state-management.md](001-refactor-state-management.md) - First user of standards
- **Task 005:** [005-code-standards.md](005-code-standards.md) - Original task (now being executed as 008)

---

## Notes

**This task replaces the original Task 005 content** but is numbered 008 to maintain chronological order. Task 005 file can be updated to reference this task.

**Blockers:**
- This task blocks all refactoring work (001-003)
- Must be completed before any code changes begin
- Priority: 🔴 CRITICAL

---

**Estimated Time Breakdown:**
- Analyze existing code: 3 hours
- Write core standards: 5 hours
- Create examples: 4 hours
- Cross-references and polish: 4 hours
- **Total: 16 hours (2 days)**
