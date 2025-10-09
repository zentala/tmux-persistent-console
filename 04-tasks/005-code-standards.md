# Task 017: Code Standards Document

**Phase:** v1.5 Refactoring
**Priority:** High
**Estimated Time:** 1 day
**Dependencies:** 013, 014, 015, 016 (Refactoring complete)
**Assignee:** Unassigned

---

## Objective

Create comprehensive code standards document that defines coding principles, naming conventions, function documentation, error handling patterns, and best practices for all developers working on pTTY codebase.

---

## Acceptance Criteria

- [ ] Code standards document created at `docs/CODE-STANDARDS.md`
- [ ] Naming conventions defined (functions, variables, files)
- [ ] Function documentation template and examples
- [ ] Error handling patterns documented
- [ ] Shell compatibility guidelines (bash/zsh)
- [ ] Testing requirements defined
- [ ] Code review checklist created
- [ ] Examples for all patterns
- [ ] All existing code reviewed against standards
- [ ] Standards enforced in v1.5 refactoring

---

## Code Standards Document Structure

**`docs/CODE-STANDARDS.md`:**

```markdown
# pTTY Code Standards

**Version:** 1.0
**Last Updated:** 2025-10-09
**Applies To:** All pTTY shell scripts (v1.5+)

---

## Table of Contents

1. [General Principles](#general-principles)
2. [File Organization](#file-organization)
3. [Naming Conventions](#naming-conventions)
4. [Function Documentation](#function-documentation)
5. [Error Handling](#error-handling)
6. [Shell Compatibility](#shell-compatibility)
7. [Testing Requirements](#testing-requirements)
8. [Code Review Checklist](#code-review-checklist)

---

## 1. General Principles

### Single Responsibility Principle
- Each function does ONE thing
- Each module handles ONE concern
- If function > 50 lines, split it

### DRY (Don't Repeat Yourself)
- Extract duplicated code to functions
- Use shared utilities (utils/)
- Reuse UI components

### Fail Fast
- Validate inputs immediately
- Exit early on errors
- Don't silently ignore failures

### Explicit Over Implicit
- Use descriptive names
- Avoid magic numbers
- Document assumptions

---

## 2. File Organization

### Directory Structure
```
src/
├── core/          # Core logic (state, config, tmux wrapper)
├── ui/
│   ├── components/  # Reusable UI elements
│   ├── manager/     # Manager-specific modules
│   ├── help/        # Help-specific modules
│   └── status-bar/  # Status bar modules
├── actions/       # Console operations
└── utils/         # Shared utilities
```

### File Naming
- Use kebab-case: `state-management.sh`
- Descriptive names: `dialog-confirm.sh` not `dialog.sh`
- One module per file

### File Header Template
```bash
#!/bin/bash
# Module: [Module Name]
# Purpose: [What this module does]
# Dependencies: [Other modules required]
# Author: [Your name]
# Last Modified: [Date]

# Ensure script is sourced, not executed
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  echo "ERROR: This script must be sourced, not executed"
  exit 1
fi
```

---

## 3. Naming Conventions

### Functions

**Namespace pattern:**
```bash
# Public API - namespace::function_name
state::get_console_state()
dialog::confirm()
actions::attach()

# Private functions - namespace::_function_name
state::_ensure_fresh()
dialog::_render_frame()
actions::_validate_console_num()
```

**Naming rules:**
- Use snake_case: `get_console_state` not `getConsoleState`
- Verbs for actions: `restart_console`, `show_menu`
- Predicates return boolean: `is_active`, `has_crashed`
- Getters prefix with `get_`: `get_state`, `get_current`

### Variables

**Scope indicators:**
```bash
# Global constants (readonly, uppercase)
readonly CACHE_TTL=5
readonly MAX_CONSOLES=10

# Global variables (uppercase)
CONSOLE_STATE_CACHE=()
CACHE_TIMESTAMP=0

# Local variables (lowercase)
local session_name="console-1"
local state="active"

# Function parameters (lowercase, descriptive)
function restart_console() {
  local console_num="$1"
  local force_restart="${2:-false}"
}
```

**Naming rules:**
- Descriptive names: `session_name` not `sn`
- Avoid single letters except loop counters (`i`, `j`)
- Boolean flags use `is_`/`has_`/`should_` prefix

### Constants

**Location:**
```bash
# src/core/constants.sh

# Filesystem
readonly PTTY_CONFIG="${HOME}/.ptty.conf"
readonly PTTY_CRASH_DIR="${HOME}/.ptty/crashes"

# Timing
readonly CACHE_TTL=5
readonly DETACH_DELAY=0.8
readonly RESTART_DELAY=1

# Limits
readonly MAX_CONSOLES=10
readonly MIN_CONSOLE_NUM=1
```

---

## 4. Function Documentation

### Documentation Template

```bash
##
# Brief one-line description
#
# Detailed description of what function does.
# Explain any complex logic or edge cases.
#
# Arguments:
#   $1 - console_num (integer 1-10) - Console number to operate on
#   $2 - force (boolean, optional, default: false) - Skip confirmation
#
# Returns:
#   0 - Success
#   1 - Invalid console number
#   2 - Console not found
#
# Outputs:
#   stdout - Success/error message
#   stderr - Error details
#
# Example:
#   if actions::restart 3 true; then
#     echo "Console restarted"
#   fi
#
actions::restart() {
  local console_num="$1"
  local force="${2:-false}"

  # Function implementation
}
```

### Required Documentation
- **Public functions**: MUST be fully documented
- **Private functions**: Brief comment explaining purpose
- **Complex logic**: Inline comments for non-obvious code

### Comment Style
```bash
# Good: Explain WHY, not WHAT
# Cache state to avoid expensive tmux queries
state::refresh

# Bad: Repeat code
# Call state refresh function
state::refresh
```

---

## 5. Error Handling

### Check Exit Codes
```bash
# Good: Check exit code
if ! tmux has-session -t "$session_name" 2>/dev/null; then
  echo "ERROR: Session not found: $session_name" >&2
  return 1
fi

# Bad: Ignore errors
tmux has-session -t "$session_name"
```

### Validate Inputs
```bash
actions::restart() {
  local console_num="$1"

  # Validate required arguments
  if [ -z "$console_num" ]; then
    echo "ERROR: Console number required" >&2
    return 1
  fi

  # Validate range
  if [ "$console_num" -lt 1 ] || [ "$console_num" -gt 10 ]; then
    echo "ERROR: Console number must be 1-10" >&2
    return 1
  fi

  # Rest of function
}
```

### Error Messages
```bash
# Format: ERROR: [Context] - [What went wrong]
echo "ERROR: Console 3 - Session not found" >&2

# Include helpful info
echo "ERROR: Invalid console number: $num (must be 1-10)" >&2
```

### Exit Codes
```bash
# 0   - Success
# 1   - General error (invalid input, not found)
# 2   - Missing dependency (tmux, gum)
# 3   - Permission denied
# 4   - Timeout
# 5-9 - Reserved for specific modules
```

---

## 6. Shell Compatibility

### Target Shells
- **Primary**: bash 4.0+
- **Secondary**: zsh 5.0+

### Compatibility Rules

**Use POSIX where possible:**
```bash
# Good (POSIX)
if [ -f "$file" ]; then

# Bad (bash-only)
if [[ -f $file ]]; then
```

**When bash features needed, document:**
```bash
# Requires bash 4.0+ for associative arrays
declare -A CONSOLE_STATE_CACHE
```

**Avoid zsh-isms:**
```bash
# Bad (zsh-only)
if [[ -n ${array[(r)$item]} ]]; then

# Good (compatible)
if printf '%s\n' "${array[@]}" | grep -q "^${item}$"; then
```

---

## 7. Testing Requirements

### Unit Tests Required For
- All public API functions
- State management logic
- Input validation
- Error handling

### Test Coverage Targets
- Core modules: 90%+
- Actions: 80%+
- UI components: 70%+
- Utilities: 80%+

### Test Naming
```bash
# tests/unit/test-state.sh

@test "state::get_console_state returns 'active' for existing console" {
  # Arrange
  mock_tmux_sessions "console-1"
  state::init

  # Act
  result=$(state::get_console_state 1)

  # Assert
  assert_equal "$result" "active"
}
```

---

## 8. Code Review Checklist

### Before Submitting PR

**Code Quality:**
- [ ] Functions < 50 lines
- [ ] No duplicated code
- [ ] Descriptive names used
- [ ] No magic numbers (use constants)

**Documentation:**
- [ ] Public functions documented
- [ ] Complex logic has comments
- [ ] README updated if needed

**Error Handling:**
- [ ] All inputs validated
- [ ] Exit codes checked
- [ ] Error messages clear

**Testing:**
- [ ] Unit tests written
- [ ] All tests pass
- [ ] Manual testing done

**Compatibility:**
- [ ] Works in bash
- [ ] Works in zsh
- [ ] No shell-specific features without docs

**Security:**
- [ ] No hardcoded credentials
- [ ] Temp files use mktemp
- [ ] Input sanitized

---

## Examples

### Example 1: Well-Written Function

```bash
##
# Restart a console session
#
# Kills the existing tmux session and creates a new one.
# Preserves session configuration and working directory.
#
# Arguments:
#   $1 - console_num (integer 1-10) - Console to restart
#   $2 - force (boolean, optional) - Skip confirmation dialog
#
# Returns:
#   0 - Session restarted successfully
#   1 - Invalid console number
#   2 - Session not found
#   3 - User cancelled
#
# Example:
#   actions::restart 3 true  # Force restart console 3
#
actions::restart() {
  local console_num="$1"
  local force="${2:-false}"

  # Validate console number
  if ! _validate_console_num "$console_num"; then
    return 1
  fi

  local session_name="console-${console_num}"

  # Check session exists
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo "ERROR: Console $console_num not found" >&2
    return 2
  fi

  # Confirm unless forced
  if [ "$force" != "true" ]; then
    if ! dialog::confirm "Restart Console" "Restart console F${console_num}?"; then
      return 3
    fi
  fi

  # Kill and recreate
  tmux kill-session -t "$session_name"
  tmux new-session -d -s "$session_name" -n "main"

  # Invalidate state cache
  state::invalidate

  return 0
}
```

### Example 2: Module Structure

```bash
#!/bin/bash
# Module: Dialog Components
# Purpose: Reusable confirmation and input dialogs
# Dependencies: gum (optional), core/constants.sh

# ============================================================================
# IMPORTS
# ============================================================================

source "${PTTY_ROOT}/src/core/constants.sh"

# ============================================================================
# PUBLIC API
# ============================================================================

##
# Show yes/no confirmation dialog
#
dialog::confirm() {
  # ... implementation ...
}

##
# Show input dialog
#
dialog::input() {
  # ... implementation ...
}

# ============================================================================
# PRIVATE FUNCTIONS
# ============================================================================

##
# Render dialog frame (private helper)
#
dialog::_render_frame() {
  # ... implementation ...
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f dialog::confirm
export -f dialog::input
```

---

## Enforcement

### Pre-Commit Checks
```bash
# Run before committing
./tools/lint-code.sh      # Check style
./tests/run-all-tests.sh  # Run tests
```

### Code Review
- All changes require review
- Reviewer checks against this document
- Violations block merge

---

## Updates

This document is living and should be updated as patterns emerge.

**To propose changes:**
1. Create issue describing change
2. Discuss with team
3. Update document
4. Increment version number
```

---

## Implementation Steps

### Step 1: Create Base Document
- Write `docs/CODE-STANDARDS.md` with all sections
- Add examples for each pattern
- Include checklist for reviews

### Step 2: Create Enforcement Tools
- `tools/lint-code.sh` - Check naming, style
- `tools/check-docs.sh` - Verify function docs
- Pre-commit hook template

### Step 3: Review Existing Code
- Audit all `src/` files against standards
- Create issues for violations
- Fix critical violations immediately

### Step 4: Update Contributing Guide
- Reference CODE-STANDARDS.md in README
- Add to onboarding documentation
- Include in PR template

---

## Related Documentation

- [ARCHITECTURE-ANALYSIS.md](../docs/ARCHITECTURE-ANALYSIS.md) - Architecture patterns
- [016-testing-framework.md](016-testing-framework.md) - Testing standards
- [SPEC.md](../SPEC.md) - Overall specification

---

## Notes

**Important:**
- Standards should be enforced from v1.5 onward
- Legacy code (v1.0) should be refactored gradually
- Standards document is living - update as needed

**Benefits:**
- Consistent codebase
- Easier onboarding
- Faster code reviews
- Better maintainability
- Fewer bugs

**Remember:**
- Standards serve the code, not the other way around
- Pragmatism over perfectionism
- Focus on readability and maintainability
