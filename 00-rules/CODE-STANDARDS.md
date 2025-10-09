**Purpose:** Coding standards for all pTTY bash code - naming, documentation, error handling, and best practices

---

# CODE-STANDARDS.md - pTTY Coding Standards

**Version:** v0.2
**Last Updated:** 2025-10-09
**Applies To:** All bash code in src/, tests/, tools/

---

## 📋 Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Function Documentation](#2-function-documentation)
3. [Error Handling](#3-error-handling)
4. [Code Organization](#4-code-organization)
5. [Best Practices](#5-best-practices)
6. [Testing Standards](#6-testing-standards)
7. [Code Review Checklist](#7-code-review-checklist)

---

## 1. Naming Conventions

### 1.1 Functions

**Pattern:** `verb_noun_modifier()`

```bash
# ✅ GOOD - Clear action + target
get_console_state() { }
validate_user_input() { }
show_help_menu() { }
reset_session_state() { }

# ❌ BAD - Wrong case, unclear
GetConsoleState() { }      # Wrong: CamelCase
validateInput() { }        # Wrong: camelCase
console_get_state() { }    # Wrong: Noun first
show() { }                 # Wrong: Too vague
```

**Rules:**
- All lowercase with underscores
- Start with verb (get, set, show, validate, reset, create, etc.)
- Descriptive but not overly long (3-4 words max)
- Private helpers prefixed with `_` (underscore)

**Examples by Category:**
```bash
# State operations
get_console_state()
set_console_active()
check_session_exists()

# UI operations
show_help_menu()
display_error_message()
render_status_bar()

# Validation
validate_console_name()
check_dependencies()
verify_tmux_running()

# Private helpers (internal use only)
_parse_tmux_output()
_format_time_string()
_sanitize_input()
```

---

### 1.2 Variables

**Local variables:** lowercase_with_underscores
```bash
local console_name="console-1"
local session_count=0
local is_active=true
```

**Global constants:** UPPERCASE_WITH_UNDERSCORES (avoid globals when possible)
```bash
readonly CACHE_DIR="${HOME}/.cache/ptty"
readonly STATE_CACHE_TTL=5
readonly MAX_CONSOLES=10
```

**Environment variables:** PTTY_ prefix
```bash
export PTTY_CONFIG_DIR="${HOME}/.config/ptty"
export PTTY_DEBUG=0
```

**Rules:**
- Always use `local` for function variables
- Always use `readonly` for constants
- Quote all variable expansions: `"$var"`
- Use `${var}` for clarity in strings

---

### 1.3 Files and Directories

**Script files:** kebab-case.sh
```bash
src/state-management.sh       # ✅ GOOD
src/ui-components.sh          # ✅ GOOD
src/StateManagement.sh        # ❌ BAD - CamelCase
src/state_management.sh       # ❌ BAD - Underscore
```

**Test files:** test-module-name.bats
```bash
tests/unit/test-state-cache.bats
tests/integration/test-manager-state.bats
```

**Directories:** kebab-case (no .sh extension)
```bash
src/ui-components/
src/core-modules/
```

---

### 1.4 Terminology (Use GLOSSARY.md)

**Consistent terms** (from [../02-planning/specs/GLOSSARY.md](../02-planning/specs/GLOSSARY.md)):
```bash
# ✅ CORRECT terminology
console         # Not: terminal, session, workspace
manager         # Not: navigator, switcher
status_bar      # Not: statusbar, info_bar
```

**See:** [../03-architecture/NAMING.md](../03-architecture/NAMING.md) for brand naming (pTTY, PersistentTTY)

---

## 2. Function Documentation

### 2.1 Docstring Format

**Every public function MUST have documentation:**

```bash
# Brief one-line description of what function does
#
# Longer description if needed (optional).
# Can span multiple lines.
#
# Arguments:
#   $1 - console name (string, e.g., "console-1")
#   $2 - target state (string: "active" | "inactive")
#   $3 - force flag (optional, boolean: true/false)
#
# Returns:
#   0 - success
#   1 - console not found
#   2 - invalid state provided
#
# Outputs:
#   Writes error message to stderr on failure
#
# Example:
#   set_console_state "console-1" "active"
#   set_console_state "console-2" "inactive" true
#
set_console_state() {
    local console_name="$1"
    local target_state="$2"
    local force="${3:-false}"

    # Implementation...
}
```

### 2.2 Module Headers

**Every .sh file MUST start with:**

```bash
#!/usr/bin/env bash
# Brief module description
#
# Longer description of module purpose and responsibilities.
#
# Dependencies:
#   - core/config.sh (configuration management)
#   - core/state.sh (state caching)
#
# Provides:
#   - get_console_state() - Get current console state
#   - set_console_state() - Update console state
#
# Version: 0.2.0

set -euo pipefail  # Strict mode (see Best Practices)

# Module constants
readonly MODULE_NAME="state-management"
readonly CACHE_DIR="${HOME}/.cache/ptty"
```

### 2.3 Inline Comments

**When to comment:**
```bash
# ✅ GOOD - Explains WHY, not WHAT
# Use short TTL to balance performance and accuracy
readonly CACHE_TTL=5

# Check cache age because tmux queries are expensive
if [[ $cache_age -gt $CACHE_TTL ]]; then
    refresh_cache
fi

# ❌ BAD - States the obvious
# Set variable to 5
readonly CACHE_TTL=5

# Loop through consoles
for console in "${consoles[@]}"; do
```

**Comment markers:**
```bash
# TODO: Implement feature X (with GitHub issue #123)
# FIXME: Bug in edge case (describe issue)
# NOTE: Important context about this code
# HACK: Temporary workaround (explain why)
```

---

## 3. Error Handling

### 3.1 Exit Codes

**Standard exit codes:**
```bash
0   # Success
1   # General error
2   # Usage error (wrong arguments)
```

**Examples:**
```bash
function validate_console_name() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "ERROR: Console name required" >&2
        return 2  # Usage error
    fi

    if ! tmux has-session -t "$name" 2>/dev/null; then
        echo "ERROR: Console '$name' not found" >&2
        return 1  # General error
    fi

    return 0  # Success
}
```

### 3.2 Error Messages

**Format:** Always to stderr with ERROR: prefix

```bash
# ✅ GOOD
echo "ERROR: Console '$name' not found" >&2
echo "ERROR: Invalid state: '$state'. Must be 'active' or 'inactive'" >&2

# ❌ BAD
echo "Console not found"                    # No ERROR: prefix
echo "ERROR: Console not found" >&1        # Wrong: stdout instead of stderr
echo "ERROR: Console $name not found" >&2  # Missing quotes around variable
```

**Include context:**
- What went wrong
- What was expected
- What value caused the error
- How to fix (if obvious)

```bash
# ✅ EXCELLENT error message
echo "ERROR: Console '$console_name' not found" >&2
echo "       Available consoles: $(list_consoles)" >&2
echo "       Use 'ptty list' to see all consoles" >&2
return 1
```

### 3.3 Error Handling Patterns

**Pattern 1: Check and return**
```bash
function get_console_state() {
    local console_name="$1"

    # Validate input
    if [[ -z "$console_name" ]]; then
        echo "ERROR: Console name required" >&2
        return 2
    fi

    # Attempt operation
    local state
    state=$(tmux display-message -p "#{session_name}" 2>/dev/null) || {
        echo "ERROR: Failed to query tmux" >&2
        return 1
    }

    echo "$state"
    return 0
}
```

**Pattern 2: Graceful degradation**
```bash
# Try gum, fallback to bash
if command -v gum &>/dev/null; then
    choice=$(gum choose "${options[@]}")
else
    # Fallback: bash select
    select choice in "${options[@]}"; do
        [[ -n $choice ]] && break
    done
fi
```

**Pattern 3: Cleanup on error**
```bash
function create_temp_cache() {
    local temp_file
    temp_file=$(mktemp) || {
        echo "ERROR: Failed to create temp file" >&2
        return 1
    }

    # Ensure cleanup on exit
    trap "rm -f '$temp_file'" EXIT

    # ... rest of function
}
```

---

## 4. Code Organization

### 4.1 Module Structure

**Standard order:**
```bash
#!/usr/bin/env bash
# Module header with description

set -euo pipefail

# 1. Constants (readonly)
readonly MODULE_VERSION="0.2.0"
readonly CACHE_DIR="${HOME}/.cache/ptty"

# 2. Global variables (minimize!)
declare -a CACHED_CONSOLES=()

# 3. Private helper functions (_prefixed)
_validate_input() {
    # Internal validation
}

_parse_output() {
    # Internal parsing
}

# 4. Public API functions
get_console_state() {
    # Public interface
}

set_console_state() {
    # Public interface
}

# 5. Main/initialization (if script is executable)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script executed directly
    main "$@"
fi
```

### 4.2 Sourcing Dependencies

```bash
# At top of file, after set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies with error checking
source "${SCRIPT_DIR}/core/config.sh" || {
    echo "ERROR: Failed to load config.sh" >&2
    exit 1
}

source "${SCRIPT_DIR}/core/state.sh" || {
    echo "ERROR: Failed to load state.sh" >&2
    exit 1
}
```

### 4.3 Function Length

**Guidelines:**
- **Max 50 lines** per function (guideline, not strict rule)
- If function >50 lines, consider splitting into helpers
- Extract complex logic into private functions

```bash
# ❌ BAD - Too long, doing too much
show_manager_menu() {
    # 100 lines of mixed logic
    # - Get console list
    # - Format output
    # - Show menu
    # - Handle selection
    # - Perform action
}

# ✅ GOOD - Split into focused functions
show_manager_menu() {
    local consoles
    consoles=$(_get_console_list) || return 1

    local formatted
    formatted=$(_format_console_list "$consoles")

    local choice
    choice=$(_show_selection_menu "$formatted") || return 1

    _perform_console_action "$choice"
}
```

---

## 5. Best Practices

### 5.1 Strict Mode (MANDATORY)

**Every script MUST start with:**
```bash
set -euo pipefail

# Explanation:
# -e : Exit on error
# -u : Exit on undefined variable
# -o pipefail : Exit on pipe failure
```

**Why:** Catches bugs early, prevents silent failures

### 5.2 Variable Quoting

```bash
# ✅ ALWAYS quote variable expansions
echo "$variable"
echo "${variable}"
path="$HOME/.config/ptty"

# ❌ NEVER unquoted (causes word splitting)
echo $variable
path=$HOME/.config/ptty
```

**Exception:** Arrays
```bash
# Arrays: Don't quote the array expansion
command "${array[@]}"  # ✅ GOOD
command ${array[@]}    # ❌ BAD (but works for most cases)
```

### 5.3 Command Substitution

```bash
# ✅ GOOD - Use $()
result=$(command arg)
count=$(echo "$list" | wc -l)

# ❌ BAD - Don't use backticks
result=`command arg`
count=`echo "$list" | wc -l`
```

### 5.4 Test Commands

```bash
# ✅ GOOD - Use [[ ]] for conditionals
if [[ -f "$file" ]]; then
if [[ "$var" == "value" ]]; then
if [[ -n "$var" ]]; then

# ❌ AVOID - Don't use [ ] (less features)
if [ -f "$file" ]; then
```

### 5.5 Arrays

```bash
# Declaration
declare -a consoles=("console-1" "console-2" "console-3")

# Iteration
for console in "${consoles[@]}"; do
    echo "$console"
done

# Length
echo "${#consoles[@]}"

# Add element
consoles+=("console-4")
```

### 5.6 ShellCheck Integration

**Use ShellCheck** (https://www.shellcheck.net/)

```bash
# Check script
shellcheck src/state-management.sh

# Suppress specific warning (with reason)
# shellcheck disable=SC2034  # Variable unused (false positive)
readonly CACHE_DIR="${HOME}/.cache/ptty"
```

**Ignored warnings** (project-wide):
- SC2034: Unused variable (many false positives with readonly)

### 5.7 Performance

**Minimize external commands:**
```bash
# ✅ GOOD - Bash built-in
if [[ "$string" == *"substring"* ]]; then

# ❌ SLOW - External command
if echo "$string" | grep -q "substring"; then
```

**Cache expensive operations:**
```bash
# ✅ GOOD - Cache tmux query
readonly CONSOLES=$(tmux list-sessions)
for session in $CONSOLES; do
    # Process cached data
done

# ❌ BAD - Query tmux in loop
for i in {1..10}; do
    tmux list-sessions  # Called 10 times!
done
```

**See:** [ADR 002](../03-architecture/decisions/002-state-management-caching.md) for caching strategy

---

## 6. Testing Standards

### 6.1 Test File Naming

```bash
tests/unit/test-state-cache.bats
tests/integration/test-manager-state.bats
tests/system/test-f11-workflow.bats
```

### 6.2 Test Function Naming

**Pattern:** `@test "module: action scenario"`

```bash
@test "state: get_console_state returns cached data within TTL" {
@test "state: get_console_state refreshes cache after TTL expires" {
@test "manager: show_menu displays all active consoles" {
@test "validation: validate_console_name rejects empty string" {
```

### 6.3 Test Structure

```bash
@test "state: function_name handles edge_case" {
    # Given: Setup initial state
    export CACHE_DIR="/tmp/test-cache"
    mkdir -p "$CACHE_DIR"

    # When: Execute action
    run get_console_state "console-1"

    # Then: Verify result
    [ "$status" -eq 0 ]
    [[ "$output" == "active" ]]
}
```

**See:** [Task 009](../04-tasks/009-testing-strategy.md) for complete testing strategy

---

## 7. Code Review Checklist

### 7.1 Before Submitting PR

- [ ] All functions have docstring headers
- [ ] All variables are quoted
- [ ] Strict mode enabled (`set -euo pipefail`)
- [ ] Error messages go to stderr with ERROR: prefix
- [ ] Return codes are meaningful (0=success, 1=error, 2=usage)
- [ ] ShellCheck passes with no errors
- [ ] Function names follow verb_noun pattern
- [ ] Variables follow naming conventions
- [ ] No hardcoded paths (use variables)
- [ ] Private functions prefixed with `_`

### 7.2 Code Quality

- [ ] Functions <50 lines
- [ ] No global variables (except readonly)
- [ ] Complex logic extracted to helpers
- [ ] Consistent with existing code style
- [ ] Comments explain WHY, not WHAT
- [ ] Terminology matches GLOSSARY.md

### 7.3 Testing

- [ ] Unit tests written for new functions
- [ ] Edge cases covered
- [ ] Tests follow naming conventions
- [ ] All tests pass locally

### 7.4 Documentation

- [ ] Module header updated if needed
- [ ] Function docstrings complete
- [ ] Related specs updated (if feature change)
- [ ] TODO/FIXME added if incomplete

---

## 8. Examples

### 8.1 Complete Module Example

```bash
#!/usr/bin/env bash
# Console state management module
#
# Provides centralized API for querying and updating console states.
# Implements 5-second TTL caching to minimize tmux queries.
#
# Dependencies:
#   - core/config.sh
#
# Provides:
#   - get_console_state() - Query console state with caching
#   - invalidate_cache() - Force cache refresh
#
# Version: 0.2.0

set -euo pipefail

# Constants
readonly STATE_CACHE_FILE="${HOME}/.cache/ptty/state.cache"
readonly STATE_CACHE_TTL=5

# Get current timestamp (seconds since epoch)
#
# Returns:
#   0 - success
#
# Outputs:
#   Current timestamp to stdout
#
_get_timestamp() {
    date +%s
}

# Check if cache file is fresh (within TTL)
#
# Returns:
#   0 - cache is fresh
#   1 - cache is stale or missing
#
_is_cache_fresh() {
    [[ -f "$STATE_CACHE_FILE" ]] || return 1

    local cache_age
    local cache_mtime
    cache_mtime=$(stat -c %Y "$STATE_CACHE_FILE" 2>/dev/null || echo 0)
    cache_age=$(( $(_get_timestamp) - cache_mtime ))

    [[ $cache_age -le $STATE_CACHE_TTL ]]
}

# Get console state (active/inactive/crashed)
#
# Arguments:
#   $1 - console name (string)
#
# Returns:
#   0 - success
#   1 - console not found
#   2 - invalid console name
#
# Outputs:
#   Console state to stdout ("active" | "inactive" | "crashed")
#
# Example:
#   state=$(get_console_state "console-1")
#
get_console_state() {
    local console_name="$1"

    # Validate input
    if [[ -z "$console_name" ]]; then
        echo "ERROR: Console name required" >&2
        return 2
    fi

    # Refresh cache if stale
    if ! _is_cache_fresh; then
        _refresh_cache || {
            echo "ERROR: Failed to refresh cache" >&2
            return 1
        }
    fi

    # Read from cache
    local state
    state=$(grep "^$console_name " "$STATE_CACHE_FILE" | awk '{print $2}') || {
        echo "ERROR: Console '$console_name' not found" >&2
        return 1
    }

    echo "$state"
    return 0
}

# Refresh state cache from tmux
#
# Returns:
#   0 - success
#   1 - tmux query failed
#
_refresh_cache() {
    local temp_cache
    temp_cache=$(mktemp) || return 1

    # Query tmux
    tmux list-sessions -F "#{session_name} #{session_activity}" > "$temp_cache" || {
        rm -f "$temp_cache"
        return 1
    }

    # Atomic replace
    mkdir -p "$(dirname "$STATE_CACHE_FILE")"
    mv "$temp_cache" "$STATE_CACHE_FILE"

    return 0
}
```

### 8.2 Function Example with Error Handling

```bash
# Attach to console by name
#
# Arguments:
#   $1 - console name (string)
#
# Returns:
#   0 - successfully attached
#   1 - console not found
#   2 - invalid console name
#   3 - tmux attach failed
#
# Example:
#   attach_to_console "console-1"
#
attach_to_console() {
    local console_name="$1"

    # Validate input
    if [[ -z "$console_name" ]]; then
        echo "ERROR: Console name required" >&2
        return 2
    fi

    # Check console exists
    if ! tmux has-session -t "$console_name" 2>/dev/null; then
        echo "ERROR: Console '$console_name' not found" >&2
        echo "       Use 'ptty list' to see available consoles" >&2
        return 1
    fi

    # Attempt to attach
    tmux attach-session -t "$console_name" || {
        echo "ERROR: Failed to attach to '$console_name'" >&2
        return 3
    }

    return 0
}
```

---

## 9. Migration Guide

### 9.1 Updating Existing Code

**When refactoring v0.1 → v0.2:**

1. Add Purpose header to file
2. Add `set -euo pipefail`
3. Add function docstrings
4. Quote all variables
5. Rename functions to follow standards
6. Add error handling
7. Run ShellCheck

**Example transformation:**
```bash
# v0.1 - Old code
function GetState() {
    tmux list-sessions | grep $1
}

# v0.2 - Standards compliant
# Get console state with caching
#
# Arguments:
#   $1 - console name (string)
#
# Returns:
#   0 - success
#   1 - console not found
#
get_console_state() {
    local console_name="$1"

    if [[ -z "$console_name" ]]; then
        echo "ERROR: Console name required" >&2
        return 2
    fi

    tmux list-sessions | grep "^$console_name " || {
        echo "ERROR: Console '$console_name' not found" >&2
        return 1
    }
}
```

---

## 10. References

### External Style Guides
- **Google Shell Style Guide:** https://google.github.io/styleguide/shellguide.html
- **ShellCheck:** https://www.shellcheck.net/
- **Bash Guide:** https://mywiki.wooledge.org/BashGuide

### Internal Documentation
- **[NAMING.md](../03-architecture/NAMING.md)** - Terminology and brand naming
- **[GLOSSARY.md](../02-planning/specs/GLOSSARY.md)** - Project vocabulary
- **[ADR 002](../03-architecture/decisions/002-state-management-caching.md)** - Caching patterns
- **[testing-strategy.md](../03-architecture/testing-strategy.md)** - Testing approach

---

## 11. Tooling

### ShellCheck Integration

```bash
# Check single file
shellcheck src/state-management.sh

# Check all scripts
find src/ -name "*.sh" -exec shellcheck {} \;

# CI integration (in .github/workflows/test.yml)
- name: ShellCheck
  run: shellcheck src/**/*.sh
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run ShellCheck on staged .sh files
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$'); do
    if ! shellcheck "$file"; then
        echo "ERROR: ShellCheck failed for $file"
        exit 1
    fi
done
```

---

## 12. Enforcement

### Code Review Requirements
- All PRs must pass ShellCheck
- All functions must have docstrings
- All new code follows these standards
- Existing code updated when touched

### Gradual Migration
- v0.2: New code MUST follow standards
- v0.2: Touched code SHOULD be updated
- v1.0: All code MUST follow standards

---

**These standards ensure consistent, maintainable, and high-quality bash code throughout pTTY.**

**Questions?** Ask in PR or create GitHub discussion.
