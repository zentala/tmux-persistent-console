# Task 016: Testing Framework Setup

**Phase:** v1.5 Refactoring
**Priority:** High
**Estimated Time:** 2 days
**Dependencies:** 013, 014, 015 (Core modules refactored)
**Assignee:** Unassigned

---

## Objective

Setup automated testing framework using `bats` (Bash Automated Testing System). Create test infrastructure, helpers, and initial test suite for all refactored modules.

---

## Acceptance Criteria

- [ ] bats installed and configured
- [ ] Test directory structure created
- [ ] Test helpers created (mocking tmux, etc.)
- [ ] Unit tests for state management (10+ tests)
- [ ] Unit tests for UI components (5+ tests)
- [ ] Unit tests for actions (8+ tests)
- [ ] Integration tests for Manager (5+ tests)
- [ ] CI/CD integration (GitHub Actions)
- [ ] All tests passing
- [ ] Test coverage report

---

## Test Directory Structure

```
tests/
├── unit/                       # Unit tests
│   ├── test-state.sh          # State management tests
│   ├── test-dialog.sh         # Dialog component tests
│   ├── test-list.sh           # List component tests
│   ├── test-actions.sh        # Actions tests
│   └── ...
│
├── integration/                # Integration tests
│   ├── test-manager.sh        # Manager full workflow
│   ├── test-status-bar.sh     # Status bar rendering
│   ├── test-shortcuts.sh      # Keyboard shortcuts
│   └── ...
│
├── helpers/                    # Test utilities
│   ├── test-helper.sh         # Main helper (load in all tests)
│   ├── mock-tmux.sh           # Mock tmux commands
│   ├── fixtures.sh            # Test data/fixtures
│   └── assertions.sh          # Custom assertions
│
├── run-all-tests.sh           # Run entire test suite
└── run-unit-tests.sh          # Run only unit tests
```

---

## Installation

**Install bats:**
```bash
# macOS
brew install bats-core

# Debian/Ubuntu
sudo apt-get install bats

# Manual install
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

**Install bats plugins:**
```bash
# bats-support (better assertions)
git clone https://github.com/bats-core/bats-support.git tests/helpers/bats-support

# bats-assert (assert functions)
git clone https://github.com/bats-core/bats-assert.git tests/helpers/bats-assert

# bats-file (file assertions)
git clone https://github.com/bats-core/bats-file.git tests/helpers/bats-file
```

---

## Test Helper Implementation

**`tests/helpers/test-helper.sh`:**
```bash
#!/bin/bash
# Main test helper - load in all tests

# Load bats plugins
load bats-support/load
load bats-assert/load
load bats-file/load

# Source project modules
export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"

# Mock tmux functions
source "${PROJECT_ROOT}/tests/helpers/mock-tmux.sh"

# Test fixtures
source "${PROJECT_ROOT}/tests/helpers/fixtures.sh"

# Setup function (runs before each test)
setup() {
  # Create temp directory for test
  TEST_TEMP_DIR="$(mktemp -d)"
  export HOME="$TEST_TEMP_DIR"
  
  # Initialize mock tmux
  mock_tmux_init
}

# Teardown function (runs after each test)
teardown() {
  # Cleanup temp directory
  rm -rf "$TEST_TEMP_DIR"
  
  # Reset mock tmux
  mock_tmux_reset
}
```

**`tests/helpers/mock-tmux.sh`:**
```bash
#!/bin/bash
# Mock tmux commands for testing

# Mock tmux sessions list
MOCK_TMUX_SESSIONS=()

# Initialize mock
mock_tmux_init() {
  MOCK_TMUX_SESSIONS=()
}

# Reset mock
mock_tmux_reset() {
  MOCK_TMUX_SESSIONS=()
}

# Set mock sessions
mock_tmux_sessions() {
  local sessions="$1"
  MOCK_TMUX_SESSIONS=()
  
  while IFS= read -r session; do
    [ -n "$session" ] && MOCK_TMUX_SESSIONS+=("$session")
  done <<< "$sessions"
}

# Mock current session
mock_current_session() {
  export MOCK_CURRENT_SESSION="$1"
}

# Override tmux command
tmux() {
  case "$1" in
    list-sessions)
      # Return mock sessions
      printf '%s\n' "${MOCK_TMUX_SESSIONS[@]}"
      ;;
    
    display-message)
      # Return mock current session
      echo "${MOCK_CURRENT_SESSION:-}"
      ;;
    
    has-session)
      # Check if session exists in mock
      local target="$3"
      for session in "${MOCK_TMUX_SESSIONS[@]}"; do
        [ "$session" = "$target" ] && return 0
      done
      return 1
      ;;
    
    *)
      # Unknown command - fail test
      echo "ERROR: Unmocked tmux command: $*" >&2
      return 1
      ;;
  esac
}

export -f tmux
```

---

## Example Test Suite

**`tests/unit/test-state.sh`:**
```bash
#!/usr/bin/env bats
# Unit tests for state management

load ../helpers/test-helper

@test "state::init initializes cache" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  state::init
  
  # Cache should be initialized
  [ "${#CONSOLE_STATE_CACHE[@]}" -gt 0 ]
}

@test "state::get_console_state returns 'active' for existing console" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  # Mock tmux
  mock_tmux_sessions "console-1"
  
  state::init
  
  result=$(state::get_console_state 1)
  assert_equal "$result" "active"
}

@test "state::get_console_state returns 'suspended' for non-existing" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  mock_tmux_sessions "console-1"
  
  state::init
  
  result=$(state::get_console_state 6)
  assert_equal "$result" "suspended"
}

@test "state::console_exists returns true for active console" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  mock_tmux_sessions "console-1\nconsole-2"
  
  state::init
  
  run state::console_exists 1
  assert_success
}

@test "state::console_exists returns false for suspended" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  mock_tmux_sessions "console-1"
  
  state::init
  
  run state::console_exists 6
  assert_failure
}

@test "state cache is reused within TTL" {
  source "${PROJECT_ROOT}/src/core/state.sh"
  
  mock_tmux_sessions "console-1"
  state::init
  
  first_time=$CACHE_TIMESTAMP
  
  # Query again immediately
  state::get_console_state 1
  
  # Timestamp should not change
  assert_equal "$CACHE_TIMESTAMP" "$first_time"
}
```

---

## Test Execution Scripts

**`tests/run-all-tests.sh`:**
```bash
#!/bin/bash
# Run entire test suite

set -e

echo "🧪 Running pTTY Test Suite"
echo "=========================="

# Run unit tests
echo ""
echo "📦 Unit Tests:"
bats tests/unit/*.sh

# Run integration tests
echo ""
echo "🔗 Integration Tests:"
bats tests/integration/*.sh

echo ""
echo "✅ All tests passed!"
```

**`tests/run-unit-tests.sh`:**
```bash
#!/bin/bash
# Run only unit tests

bats tests/unit/*.sh
```

---

## CI/CD Integration

**`.github/workflows/tests.yml`:**
```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      
      - name: Install bats plugins
        run: |
          git clone https://github.com/bats-core/bats-support.git tests/helpers/bats-support
          git clone https://github.com/bats-core/bats-assert.git tests/helpers/bats-assert
          git clone https://github.com/bats-core/bats-file.git tests/helpers/bats-file
      
      - name: Run tests
        run: ./tests/run-all-tests.sh
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: tests/results/
```

---

## Coverage Report

**Generate coverage (optional, v2):**
```bash
# Install kcov for bash coverage
sudo apt-get install kcov

# Run tests with coverage
kcov --include-path=src tests/coverage ./tests/run-all-tests.sh

# View report
open tests/coverage/index.html
```

---

## Testing Best Practices

**DO:**
- ✅ Test one thing per test
- ✅ Use descriptive test names
- ✅ Mock external dependencies (tmux)
- ✅ Use setup/teardown for cleanup
- ✅ Test both success and failure cases
- ✅ Test edge cases (empty input, invalid numbers, etc.)

**DON'T:**
- ❌ Test implementation details
- ❌ Make tests depend on each other
- ❌ Leave test artifacts (files, processes)
- ❌ Skip error cases
- ❌ Write slow tests (keep unit tests fast)

---

## Related Documentation

- [ARCHITECTURE-ANALYSIS.md](../docs/ARCHITECTURE-ANALYSIS.md) - Testing strategy
- bats documentation: https://bats-core.readthedocs.io/

---

## Notes

- Run tests before every commit
- Add tests for every new feature
- Keep test coverage above 80%
- Fast feedback loop (unit tests < 1s total)
- Integration tests can be slower (but < 10s)
- Mock tmux for unit tests, use real tmux for integration
