# pTTY - Architecture Analysis & Recommendations

**Date:** 2025-10-08
**Author:** Software Architect (AI Team)
**Purpose:** Architecture review and recommendations for maintainability, modularity, extensibility

---

## Executive Summary

**Current state:** Good foundation, but needs modularization for future growth.

**Key concerns:**
1. **Monolithic scripts** - Help and Manager will grow, need component splitting
2. **No clear separation of concerns** - UI, logic, state mixed
3. **Testing difficult** - Hard to test components independently
4. **Documentation scattered** - Need centralized architecture docs
5. **Code standards undefined** - No style guide, no conventions

**Recommendations:**
1. ✅ **Modular architecture** - Split by responsibility
2. ✅ **Component-based UI** - Reusable UI elements
3. ✅ **State management layer** - Centralized console state
4. ✅ **Testing framework** - Unit + integration tests
5. ✅ **Code standards document** - Conventions + principles
6. ✅ **Architecture documentation** - Design patterns, diagrams

---

## Current Architecture Problems

### Problem 1: Monolithic Scripts

**Issue:**
```bash
# Current: src/manager-menu.sh (will grow to 500+ lines)
# - UI rendering
# - State detection
# - Action handling
# - Confirmation dialogs
# - Error handling
```

**Impact:**
- Hard to understand
- Hard to modify (change one thing, break another)
- Hard to test
- Hard to extend (v2/v3 features)

**Example of future growth:**
```bash
# v1: 200 lines
# v2: +process display, +custom names = 350 lines
# v3: +monitoring, +bulk actions, +clone = 600+ lines
```

### Problem 2: Mixed Concerns

**Issue:**
```bash
# In manager-menu.sh:
get_console_state()  # State logic
build_ui()           # UI rendering
handle_action()      # Action execution
show_confirmation()  # UI dialog

# All in one file, tightly coupled
```

**Impact:**
- Can't reuse components (e.g., confirmation dialog elsewhere)
- Can't test state logic without UI
- Changes to UI affect logic and vice versa

### Problem 3: No State Management

**Issue:**
- Console state scattered across multiple places
- Each script runs `tmux list-sessions` independently
- No caching, no consistency
- Race conditions possible

**Example:**
```bash
# manager-menu.sh
STATE=$(tmux list-sessions | grep console-3)

# status-bar.sh
STATE=$(tmux list-sessions | grep console-3)

# Same query, different scripts, no shared state
```

### Problem 4: Testing Impossible

**Issue:**
- No unit tests
- No integration tests
- Manual testing only
- Can't automate QA

**Impact:**
- Bugs slip through
- Regressions not caught
- Fear of refactoring (might break things)

### Problem 5: No Code Standards

**Issue:**
- No naming conventions
- No function documentation
- No error handling patterns
- Inconsistent style

**Example:**
```bash
# Current (inconsistent):
get_console_state()   # snake_case
getConsoleState()     # camelCase
GetConsoleState()     # PascalCase

# Which one? No standard defined.
```

---

## Recommended Architecture

### 1. Modular Directory Structure

**Proposed structure:**
```
~/.vps/sessions/
├── src/
│   ├── core/                    # Core functionality
│   │   ├── state.sh            # Console state management
│   │   ├── tmux-wrapper.sh     # tmux command wrappers
│   │   └── config.sh           # Config loading/parsing
│   │
│   ├── ui/                      # UI components
│   │   ├── components/         # Reusable UI pieces
│   │   │   ├── dialog.sh       # Confirmation dialogs
│   │   │   ├── list.sh         # Selectable lists
│   │   │   ├── header.sh       # Headers/titles
│   │   │   └── footer.sh       # Navigation hints
│   │   │
│   │   ├── manager/            # Manager (F11) UI
│   │   │   ├── manager-main.sh # Entry point
│   │   │   ├── console-list.sh # Console list rendering
│   │   │   ├── actions.sh      # Action menu
│   │   │   └── confirmations.sh# Confirmation flows
│   │   │
│   │   ├── help/               # Help (F12) UI
│   │   │   ├── help-main.sh    # Entry point
│   │   │   ├── shortcuts.sh    # Shortcut sections
│   │   │   └── system-info.sh  # System info section
│   │   │
│   │   └── status-bar/         # Status bar
│   │       ├── status-main.sh  # Entry point
│   │       ├── tabs.sh         # Tab rendering
│   │       └── branding.sh     # Left section
│   │
│   ├── actions/                # Console actions
│   │   ├── attach.sh           # Attach to console
│   │   ├── activate.sh         # Activate suspended
│   │   ├── restart.sh          # Restart console
│   │   └── detach.sh           # Detach safely
│   │
│   ├── utils/                  # Utilities
│   │   ├── colors.sh           # Color constants
│   │   ├── icons.sh            # Icon loading
│   │   ├── logging.sh          # Debug logging
│   │   └── validation.sh       # Input validation
│   │
│   └── themes/                 # Themes (already good)
│       ├── default.sh
│       └── dark.sh
│
├── lib/                        # External libraries (v2/v3)
│   ├── gum                     # gum binary (if bundled)
│   └── ...
│
├── tests/                      # Test suite
│   ├── unit/                   # Unit tests
│   │   ├── test-state.sh
│   │   ├── test-actions.sh
│   │   └── ...
│   │
│   ├── integration/            # Integration tests
│   │   ├── test-manager.sh
│   │   ├── test-status-bar.sh
│   │   └── ...
│   │
│   └── helpers/                # Test utilities
│       └── mock-tmux.sh
│
├── docs/                       # Documentation
│   ├── architecture/           # Architecture docs
│   │   ├── README.md           # Overview
│   │   ├── state-management.md # State design
│   │   ├── ui-components.md    # UI patterns
│   │   └── testing.md          # Testing strategy
│   │
│   ├── code-standards.md       # Coding conventions
│   └── api/                    # API docs (function signatures)
│       ├── core-api.md
│       ├── ui-api.md
│       └── actions-api.md
│
└── specs/                      # Specifications (already exists)
    ├── GLOSSARY.md
    ├── MANAGER-SPEC.md
    └── ...
```

**Benefits:**
- ✅ Clear separation of concerns
- ✅ Easy to find code
- ✅ Easy to test components
- ✅ Easy to extend (add new actions, UI components)
- ✅ Easy to maintain (change one part without affecting others)

---

### 2. Core Layer: State Management

**Purpose:** Centralized console state tracking

**File:** `src/core/state.sh`

**API:**
```bash
# Get console state (active, suspended, crashed)
state::get_console_state <num>

# Check if console exists
state::console_exists <num>

# Get all console states (cached)
state::get_all_states

# Refresh state cache
state::refresh

# Get current console number
state::get_current_console

# Is console crashed?
state::is_crashed <num>
```

**Implementation pattern:**
```bash
#!/bin/bash
# src/core/state.sh

# Cache for console states (avoid repeated tmux queries)
declare -A CONSOLE_STATE_CACHE

# Refresh state cache
state::refresh() {
  local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  for i in {1..10}; do
    if echo "$sessions" | grep -q "^console-$i$"; then
      # Console exists - check if crashed
      if state::_is_crashed $i; then
        CONSOLE_STATE_CACHE[$i]="crashed"
      else
        CONSOLE_STATE_CACHE[$i]="active"
      fi
    else
      CONSOLE_STATE_CACHE[$i]="suspended"
    fi
  done
}

# Get console state (from cache)
state::get_console_state() {
  local num=$1
  echo "${CONSOLE_STATE_CACHE[$num]:-suspended}"
}

# Check if console crashed (implementation depends on crash detection)
state::_is_crashed() {
  local num=$1
  # Check if crash dump exists
  [ -f ~/.ptty.crash.f${num}.dump ]
}

# Export functions
export -f state::refresh
export -f state::get_console_state
```

**Benefits:**
- Single source of truth for state
- Caching reduces tmux queries
- Easy to mock for testing
- Consistent state across UI components

---

### 3. UI Layer: Reusable Components

**Purpose:** Modular, reusable UI elements

**Example: Confirmation Dialog**

**File:** `src/ui/components/dialog.sh`

**API:**
```bash
# Show confirmation dialog
# Returns: 0 (confirmed), 1 (cancelled)
dialog::confirm <title> <message> [default_yes]

# Show yes/no dialog
dialog::yes_no <title> <message>

# Show input dialog
dialog::input <title> <prompt> [default_value]
```

**Implementation:**
```bash
#!/bin/bash
# src/ui/components/dialog.sh

dialog::confirm() {
  local title="$1"
  local message="$2"
  local default_yes="${3:-false}"

  if command -v gum &>/dev/null; then
    gum confirm "$message" && return 0 || return 1
  else
    # Fallback: simple yes/no prompt
    local default_prompt="[y/N]"
    [ "$default_yes" = "true" ] && default_prompt="[Y/n]"

    read -p "$message $default_prompt " answer
    case "$answer" in
      [Yy]*) return 0 ;;
      *)     return 1 ;;
    esac
  fi
}

export -f dialog::confirm
```

**Usage:**
```bash
# In manager actions
source src/ui/components/dialog.sh

if dialog::confirm "Restart Console" "Are you sure you want to restart F3?"; then
  actions::restart 3
fi
```

**Benefits:**
- DRY (Don't Repeat Yourself)
- Consistent UX across all dialogs
- Easy to change dialog style globally
- Easy to test

---

### 4. Action Layer: Console Operations

**Purpose:** Encapsulate console operations

**File:** `src/actions/restart.sh`

**API:**
```bash
# Restart console (with confirmation)
actions::restart <num> [--force]

# Restart console (no confirmation)
actions::restart_forced <num>
```

**Implementation:**
```bash
#!/bin/bash
# src/actions/restart.sh

source src/core/state.sh
source src/core/tmux-wrapper.sh
source src/ui/components/dialog.sh
source src/utils/logging.sh

actions::restart() {
  local num=$1
  local force="${2:-false}"

  logging::debug "Restarting console F${num}"

  # Validation
  if ! state::console_exists $num; then
    logging::error "Console F${num} does not exist"
    return 1
  fi

  # Confirmation (unless --force)
  if [ "$force" != "--force" ]; then
    if ! dialog::confirm "Restart Console" "Restart console F${num}?"; then
      logging::info "Restart cancelled by user"
      return 1
    fi
  fi

  # Execute restart
  tmux_wrapper::kill_session "console-${num}" || return 1
  tmux_wrapper::create_session "console-${num}" || return 1

  # Refresh state
  state::refresh

  logging::info "Console F${num} restarted successfully"
  return 0
}

export -f actions::restart
```

**Benefits:**
- Single place for restart logic
- Easy to add logging, metrics
- Easy to test (mock tmux_wrapper)
- Reusable from Manager, CLI, shortcuts

---

### 5. Testing Framework

**Purpose:** Automated testing for reliability

**File:** `tests/unit/test-state.sh`

**Framework:** Use `bats` (Bash Automated Testing System) or custom

**Example test:**
```bash
#!/usr/bin/env bats
# tests/unit/test-state.sh

load ../test-helper

@test "state::get_console_state returns 'active' for existing console" {
  # Mock tmux list-sessions
  mock_tmux_sessions "console-1\nconsole-2\nconsole-3"

  # Refresh state
  state::refresh

  # Assert
  result=$(state::get_console_state 1)
  [ "$result" = "active" ]
}

@test "state::get_console_state returns 'suspended' for non-existing console" {
  mock_tmux_sessions "console-1\nconsole-2"

  state::refresh

  result=$(state::get_console_state 6)
  [ "$result" = "suspended" ]
}

@test "state::is_crashed returns true if crash dump exists" {
  # Create mock crash dump
  touch ~/.ptty.crash.f3.dump

  run state::is_crashed 3
  [ "$status" -eq 0 ]

  # Cleanup
  rm ~/.ptty.crash.f3.dump
}
```

**Run tests:**
```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific test suite
bats tests/unit/test-state.sh

# Run integration tests
bats tests/integration/test-manager.sh
```

**Benefits:**
- Catch bugs early
- Prevent regressions
- Confidence in refactoring
- Documentation (tests show how to use APIs)

---

### 6. Code Standards Document

**Purpose:** Consistent, readable, maintainable code

**File:** `docs/code-standards.md`

**Key standards:**

#### Naming Conventions
```bash
# Functions: namespace::function_name (snake_case)
state::get_console_state()
ui::render_list()
actions::restart()

# Variables: UPPER_CASE for constants, lower_case for locals
readonly CONFIG_FILE="~/.ptty.conf"
local console_num=3

# Private functions: underscore prefix
state::_is_crashed()  # Internal, don't use outside state.sh
```

#### Function Documentation
```bash
# Every public function MUST have documentation

##
# Get the state of a console
#
# Arguments:
#   $1 - Console number (1-10)
#
# Returns:
#   "active", "suspended", or "crashed"
#
# Example:
#   state=$(state::get_console_state 3)
#
state::get_console_state() {
  # Implementation
}
```

#### Error Handling
```bash
# Always check exit codes
if ! tmux has-session -t "console-3" 2>/dev/null; then
  logging::error "Console 3 does not exist"
  return 1
fi

# Use 'set -euo pipefail' in scripts
set -euo pipefail  # Exit on error, undefined var, pipe failure

# Validate inputs
actions::restart() {
  local num=$1

  # Validate input
  if [[ ! "$num" =~ ^[1-9]$|^10$ ]]; then
    logging::error "Invalid console number: $num"
    return 1
  fi

  # ... rest of function
}
```

#### Logging
```bash
# Use logging utility instead of echo
logging::debug "Starting restart process"
logging::info "Console F3 restarted"
logging::warn "Config file not found, using defaults"
logging::error "Failed to kill session"
```

#### Dependencies
```bash
# Check dependencies at script start
check_dependencies() {
  local missing=()

  command -v tmux >/dev/null || missing+=("tmux")
  command -v gum >/dev/null || missing+=("gum")

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing dependencies: ${missing[*]}"
    exit 1
  fi
}
```

---

### 7. Architecture Documentation

**Purpose:** Design decisions, patterns, diagrams

**File:** `docs/architecture/README.md`

**Contents:**
```markdown
# pTTY Architecture

## Overview
- Component diagram
- Data flow diagram
- State machine diagram

## Design Patterns
- State management pattern
- UI component pattern
- Action handler pattern

## Core Principles
1. Separation of concerns
2. Single responsibility
3. DRY (Don't Repeat Yourself)
4. KISS (Keep It Simple, Stupid)
5. Testability first

## Component Communication
- How Manager calls Actions
- How Actions update State
- How State triggers UI updates

## Extension Points
- Adding new UI components
- Adding new actions
- Adding new console states
```

---

## Migration Plan (v1 → v2)

### Phase 1: Refactor Core (No user-visible changes)
1. Extract state management → `src/core/state.sh`
2. Extract tmux wrapper → `src/core/tmux-wrapper.sh`
3. Add logging utility → `src/utils/logging.sh`
4. Write unit tests for core

### Phase 2: Refactor UI Components
1. Extract dialog → `src/ui/components/dialog.sh`
2. Extract list → `src/ui/components/list.sh`
3. Refactor Manager to use components
4. Write integration tests for Manager

### Phase 3: Refactor Actions
1. Extract actions → `src/actions/*.sh`
2. Update Manager to call actions
3. Update shortcuts to call actions
4. Write tests for actions

### Phase 4: Documentation
1. Write `docs/code-standards.md`
2. Write `docs/architecture/README.md`
3. Document all public APIs
4. Update CLAUDE.md with new structure

---

## Specific Recommendations

### 1. Help (F12) Modularization

**Current problem:** help-reference.sh will grow with v2/v3 features

**Solution:**
```bash
src/ui/help/
├── help-main.sh          # Entry point, layout
├── sections/
│   ├── shortcuts.sh      # Keyboard shortcuts section
│   ├── system-info.sh    # System info section
│   ├── config.sh         # Config file info (v2)
│   └── troubleshooting.sh# Troubleshooting (v3)
└── components/
    ├── section-header.sh # Reusable section header
    └── key-binding.sh    # Format key bindings
```

**Usage:**
```bash
# help-main.sh
source ui/help/sections/shortcuts.sh
source ui/help/sections/system-info.sh

clear
echo "┌─── Help ───┐"
shortcuts::render
system_info::render
echo "└────────────┘"
```

### 2. Manager (F11) Modularization

**Current problem:** manager-menu.sh will be 600+ lines in v3

**Solution:**
```bash
src/ui/manager/
├── manager-main.sh       # Entry point, main loop
├── console-list.sh       # Render console list
├── actions-menu.sh       # Render action menu
├── confirmations.sh      # Confirmation flows
└── details/              # v2/v3 features
    ├── process-info.sh   # Show process info
    ├── resource-usage.sh # Show CPU/RAM
    └── history.sh        # Show console history
```

### 3. Status Bar Modularization

**Current problem:** status-bar.sh generates entire bar, hard to customize

**Solution:**
```bash
src/ui/status-bar/
├── status-main.sh        # Entry point
├── branding.sh           # Left section (pTTY logo, user@host)
├── tabs.sh               # Center section (console tabs)
├── special-tabs.sh       # Right section (F11, F12)
└── responsive.sh         # Responsive logic (collapse, hide)
```

### 4. Testing Strategy

**Unit tests:**
- Test each function in isolation
- Mock external dependencies (tmux)
- Fast, run on every commit

**Integration tests:**
- Test components working together
- Use real tmux in Docker container
- Run before releases

**E2E tests:**
- Test complete user workflows
- Simulate user interactions
- Run weekly or before major releases

**Test pyramid:**
```
      /\
     /  \    E2E (few, slow, expensive)
    /____\
   /      \  Integration (some, medium)
  /________\
 /          \ Unit (many, fast, cheap)
/__________
```

---

## Conclusion

**Current state:** Functional but monolithic, will become unmaintainable in v2/v3.

**Recommended changes:**
1. ✅ **Modular architecture** - Split by responsibility (core, ui, actions, utils)
2. ✅ **State management layer** - Centralized console state
3. ✅ **Reusable UI components** - DRY principle
4. ✅ **Action encapsulation** - Single responsibility per action
5. ✅ **Testing framework** - Unit + integration tests
6. ✅ **Code standards** - Consistent naming, documentation, error handling
7. ✅ **Architecture docs** - Design patterns, diagrams, extension points

**Priority:**
- **v1 completion:** Finish current specs, don't refactor yet
- **v1.5 (before v2):** Refactor core + tests (no new features)
- **v2:** Add features on top of clean architecture
- **v3:** Extend easily with new components

**Effort:**
- Core refactor: 2-3 days
- UI refactor: 2-3 days
- Action refactor: 1 day
- Tests: 2-3 days
- Documentation: 1-2 days

**Total:** ~2 weeks one-time investment for long-term maintainability.

---

**Questions for user:**
1. Should we refactor before v2, or ship v1 as-is and refactor later?
2. Which testing framework to use? (bats, shunit2, custom?)
3. Do you want architecture diagrams? (flowcharts, component diagrams?)
4. Should CLAUDE.md include these architecture principles?

---

**END OF ARCHITECTURE ANALYSIS**
