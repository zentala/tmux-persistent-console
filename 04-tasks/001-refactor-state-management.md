# Task 013: Refactor State Management Layer

**Phase:** v1.5 Refactoring
**Priority:** Critical
**Estimated Time:** 2-3 days
**Dependencies:** v1.0 complete (001-012)
**Assignee:** Unassigned

---

## Objective

Extract console state management into a dedicated, testable, reusable module. Create centralized state API that all components (Manager, Status Bar, Actions) will use.

**Why?** Currently state detection is scattered and duplicated. Each component queries tmux independently. This creates inconsistency, performance issues, and makes testing impossible.

---

## Acceptance Criteria

- [ ] State management module created at `src/core/state.sh`
- [ ] All state-related functions use namespace `state::`
- [ ] State caching implemented (avoid repeated tmux queries)
- [ ] Public API documented with function headers
- [ ] Manager uses new state API (no direct tmux calls)
- [ ] Status Bar uses new state API
- [ ] Unit tests written for all state functions
- [ ] All tests pass
- [ ] No regressions (v1.0 functionality still works)

---

## Implementation Details

### Files to Create

**`src/core/state.sh`** - State management module

**Structure:**
```bash
#!/bin/bash
# State Management Module
# Provides centralized console state tracking and caching

# ============================================================================
# CACHE
# ============================================================================

# Associative array for state cache
declare -g -A CONSOLE_STATE_CACHE

# Last cache refresh timestamp
declare -g CACHE_TIMESTAMP=0

# Cache TTL (seconds)
readonly CACHE_TTL=5

# ============================================================================
# PUBLIC API
# ============================================================================

##
# Initialize state management system
#
# Must be called before using any state functions
#
# Example:
#   state::init
#
state::init() {
  # Initialize cache
  CONSOLE_STATE_CACHE=()
  CACHE_TIMESTAMP=0

  # Perform initial refresh
  state::refresh
}

##
# Refresh state cache
#
# Queries tmux and updates internal cache
# Automatically called if cache is stale
#
# Example:
#   state::refresh
#
state::refresh() {
  local now=$(date +%s)

  # Check if cache is fresh
  if [ $((now - CACHE_TIMESTAMP)) -lt $CACHE_TTL ]; then
    return 0  # Cache still valid
  fi

  # Query tmux sessions
  local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null || echo "")

  # Update cache for each console
  for i in {1..10}; do
    if echo "$sessions" | grep -q "^console-${i}$"; then
      # Console exists - check if crashed
      if state::_check_crash $i; then
        CONSOLE_STATE_CACHE[$i]="crashed"
      else
        CONSOLE_STATE_CACHE[$i]="active"
      fi
    else
      CONSOLE_STATE_CACHE[$i]="suspended"
    fi
  done

  # Special consoles (Manager, Help)
  for name in manager help; do
    if echo "$sessions" | grep -q "^${name}$"; then
      CONSOLE_STATE_CACHE[$name]="active"
    else
      CONSOLE_STATE_CACHE[$name]="suspended"
    fi
  done

  # Update timestamp
  CACHE_TIMESTAMP=$now
}

##
# Get console state
#
# Arguments:
#   $1 - Console number (1-10) or name ("manager", "help")
#
# Returns:
#   "active", "suspended", or "crashed"
#
# Example:
#   state=$(state::get_console_state 3)
#
state::get_console_state() {
  local id="$1"

  # Refresh cache if stale
  state::_ensure_fresh

  # Return state from cache
  echo "${CONSOLE_STATE_CACHE[$id]:-suspended}"
}

##
# Check if console exists (is created)
#
# Arguments:
#   $1 - Console number (1-10) or name
#
# Returns:
#   0 if exists, 1 if not
#
# Example:
#   if state::console_exists 3; then
#     echo "Console 3 exists"
#   fi
#
state::console_exists() {
  local id="$1"
  local state=$(state::get_console_state "$id")

  [ "$state" != "suspended" ]
}

##
# Check if console is crashed
#
# Arguments:
#   $1 - Console number (1-10)
#
# Returns:
#   0 if crashed, 1 if not
#
# Example:
#   if state::is_crashed 3; then
#     echo "Console 3 crashed"
#   fi
#
state::is_crashed() {
  local num="$1"
  local state=$(state::get_console_state "$num")

  [ "$state" = "crashed" ]
}

##
# Get current console number
#
# Returns:
#   Console number (1-10) or name ("manager", "help")
#   or empty string if not in console
#
# Example:
#   current=$(state::get_current_console)
#
state::get_current_console() {
  local session=$(tmux display-message -p '#{session_name}' 2>/dev/null || echo "")

  # Extract console number
  if [[ "$session" =~ ^console-([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
  elif [[ "$session" =~ ^(manager|help)$ ]]; then
    echo "$session"
  else
    echo ""
  fi
}

##
# Get all console states as associative array
#
# Returns:
#   Prints "num:state" lines for all consoles
#
# Example:
#   while IFS=: read -r num state; do
#     echo "Console $num: $state"
#   done < <(state::get_all_states)
#
state::get_all_states() {
  state::_ensure_fresh

  for i in {1..10}; do
    echo "$i:${CONSOLE_STATE_CACHE[$i]}"
  done

  echo "manager:${CONSOLE_STATE_CACHE[manager]}"
  echo "help:${CONSOLE_STATE_CACHE[help]}"
}

##
# Invalidate cache (force refresh on next query)
#
# Call this after creating/destroying consoles
#
# Example:
#   tmux kill-session -t console-3
#   state::invalidate  # Force refresh
#
state::invalidate() {
  CACHE_TIMESTAMP=0
}

# ============================================================================
# PRIVATE FUNCTIONS
# ============================================================================

##
# Ensure cache is fresh (refresh if stale)
# Private function, don't call directly
#
state::_ensure_fresh() {
  local now=$(date +%s)

  if [ $((now - CACHE_TIMESTAMP)) -ge $CACHE_TTL ]; then
    state::refresh
  fi
}

##
# Check if console crashed (has crash dump)
# Private function, don't call directly
#
# Arguments:
#   $1 - Console number
#
# Returns:
#   0 if crashed, 1 if not
#
state::_check_crash() {
  local num="$1"
  local dump_file="$HOME/.ptty.crash.f${num}.dump"

  [ -f "$dump_file" ]
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f state::init
export -f state::refresh
export -f state::get_console_state
export -f state::console_exists
export -f state::is_crashed
export -f state::get_current_console
export -f state::get_all_states
export -f state::invalidate
```

### Files to Modify

**`src/manager-menu.sh`** - Use state API instead of direct tmux
```bash
# OLD (direct tmux query):
if tmux has-session -t "console-3" 2>/dev/null; then
  state="active"
fi

# NEW (use state API):
source src/core/state.sh
state::init
state=$(state::get_console_state 3)
```

**`src/status-bar.sh`** - Use state API
```bash
# OLD:
sessions=$(tmux list-sessions | grep console)

# NEW:
source src/core/state.sh
state::init
while IFS=: read -r num state; do
  # Process state
done < <(state::get_all_states)
```

### Testing Requirements

**Unit tests:** `tests/unit/test-state.sh`

```bash
#!/usr/bin/env bats
# Unit tests for state management

load ../test-helper

setup() {
  # Initialize state module
  source src/core/state.sh
  state::init
}

@test "state::get_console_state returns 'active' for existing console" {
  # Mock tmux to return console-1
  mock_tmux_sessions "console-1"

  state::refresh

  result=$(state::get_console_state 1)
  [ "$result" = "active" ]
}

@test "state::get_console_state returns 'suspended' for non-existing console" {
  mock_tmux_sessions "console-1"

  state::refresh

  result=$(state::get_console_state 6)
  [ "$result" = "suspended" ]
}

@test "state::is_crashed returns true if crash dump exists" {
  touch ~/.ptty.crash.f3.dump

  state::refresh

  run state::is_crashed 3
  [ "$status" -eq 0 ]

  rm ~/.ptty.crash.f3.dump
}

@test "state::console_exists returns true for active console" {
  mock_tmux_sessions "console-1\nconsole-2"

  state::refresh

  run state::console_exists 1
  [ "$status" -eq 0 ]
}

@test "state::console_exists returns false for suspended console" {
  mock_tmux_sessions "console-1"

  state::refresh

  run state::console_exists 6
  [ "$status" -eq 1 ]
}

@test "state::get_current_console returns current console number" {
  mock_current_session "console-3"

  result=$(state::get_current_console)
  [ "$result" = "3" ]
}

@test "state::get_all_states returns all console states" {
  mock_tmux_sessions "console-1\nconsole-2\nconsole-3"

  state::refresh

  states=$(state::get_all_states)

  # Check some states
  echo "$states" | grep -q "1:active"
  echo "$states" | grep -q "2:active"
  echo "$states" | grep -q "3:active"
  echo "$states" | grep -q "6:suspended"
}

@test "state cache is reused within TTL" {
  mock_tmux_sessions "console-1"
  state::refresh

  first_time=$CACHE_TIMESTAMP

  # Query again immediately (should use cache)
  state::get_console_state 1

  [ "$CACHE_TIMESTAMP" -eq "$first_time" ]
}

@test "state cache refreshes after TTL" {
  mock_tmux_sessions "console-1"
  state::refresh

  # Fake old timestamp
  CACHE_TIMESTAMP=$(($(date +%s) - 10))

  # Query (should trigger refresh)
  state::get_console_state 1

  [ "$CACHE_TIMESTAMP" -gt "$(($(date +%s) - 2))" ]
}

@test "state::invalidate forces cache refresh" {
  state::refresh
  first_time=$CACHE_TIMESTAMP

  state::invalidate

  [ "$CACHE_TIMESTAMP" -eq 0 ]
}
```

**Integration tests:** Manual verification
1. Start tmux with some consoles
2. Source state.sh and call state::init
3. Query states and verify correctness
4. Create/destroy consoles, verify cache updates
5. Check Manager and Status Bar still work

---

## Migration Steps

### Step 1: Create state.sh module
- Write src/core/state.sh
- Add all functions with documentation
- Test independently

### Step 2: Write unit tests
- Create tests/unit/test-state.sh
- Add test helper for mocking tmux
- Run tests, fix bugs

### Step 3: Update Manager
- Source state.sh in manager-menu.sh
- Replace all direct tmux queries with state:: calls
- Test Manager functionality

### Step 4: Update Status Bar
- Source state.sh in status-bar.sh
- Replace tmux queries with state:: calls
- Test status bar rendering

### Step 5: Update other components
- Check all scripts for direct tmux queries
- Replace with state API
- Verify no regressions

### Step 6: Document changes
- Update CLAUDE.md with state API usage
- Add state API docs to docs/api/core-api.md
- Update ARCHITECTURE-ANALYSIS.md

---

## Performance Considerations

**Before refactoring:**
- Manager queries tmux 3 times per render (inefficient)
- Status bar queries tmux every update
- Total: ~10+ tmux queries per user action

**After refactoring:**
- Single tmux query cached for 5 seconds
- All components share cache
- Total: ~1 tmux query per 5 seconds

**Improvement:** ~90% reduction in tmux queries

---

## Related Documentation

- [ARCHITECTURE-ANALYSIS.md](../docs/ARCHITECTURE-ANALYSIS.md) - State management pattern
- [GLOSSARY.md](../specs/GLOSSARY.md) - Console states defined
- [SPEC.md](../SPEC.md) - Overall architecture

---

## Notes

**Important:**
- Keep functions pure (no side effects except cache update)
- Always export functions so they're available in subshells
- Use `state::` namespace consistently
- Document all public functions
- Private functions use `state::_` prefix

**Testing tip:**
- Use bats for unit tests
- Mock tmux with test helper
- Test cache behavior thoroughly

**After completion:**
- This becomes foundation for all state-related code
- v2/v3 features build on this (process monitoring, etc.)
- Clean, testable, maintainable
