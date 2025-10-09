**Purpose:** Overall testing strategy for pTTY - test levels, mocking, coverage goals, and CI/CD integration

---

# Testing Strategy - pTTY v0.2+

**Version:** v0.2
**Last Updated:** 2025-10-09
**Status:** Active

---

## 📋 Table of Contents

1. [Test Pyramid](#1-test-pyramid)
2. [Test Levels](#2-test-levels)
3. [Mock Strategy](#3-mock-strategy)
4. [Coverage Goals](#4-coverage-goals)
5. [Test Organization](#5-test-organization)
6. [CI/CD Integration](#6-cicd-integration)
7. [Testing Standards](#7-testing-standards)
8. [Edge Cases](#8-edge-cases)
9. [Tools & Requirements](#9-tools--requirements)
10. [References](#10-references)

---

## 1. Test Pyramid

```
         /\
        /  \  Manual (E2E)
       /----\  5% - Full workflows
      / Sys  \
     /--------\  15% - Critical paths
    /   Int    \
   /------------\  30% - Module interactions
  /    Unit      \
 /----------------\  50% - Individual functions
```

**Distribution:**
- **50% Unit tests:** Fast, isolated, many tests
- **30% Integration tests:** Module interactions
- **15% System tests:** Full workflows
- **5% Manual tests:** Visual validation, UX

**Rationale:** Follow industry best practices (Google Test Pyramid)

---

## 2. Test Levels

### 2.1 Unit Tests (tests/unit/)

**Scope:** Individual functions in isolation

**Target modules:**
- `src/core/state.sh` - State management functions
- `src/core/config.sh` - Configuration loading
- `src/utils/validation.sh` - Input validation
- `src/utils/formatting.sh` - String formatting

**Coverage goal:** 80% of refactored code

**Example test:**
```bash
# tests/unit/test-state-cache.bats

@test "state: get_console_state returns cached data within TTL" {
    # Given: Fresh cache file exists
    export CACHE_DIR="/tmp/test-cache-$$"
    mkdir -p "$CACHE_DIR"
    echo "console-1 active 12345" > "$CACHE_DIR/state.cache"
    touch "$CACHE_DIR/state.cache"  # Fresh timestamp

    # When: Get state within TTL
    run get_console_state "console-1"

    # Then: Returns cached value without tmux call
    [ "$status" -eq 0 ]
    [[ "$output" == "active" ]]

    # Cleanup
    rm -rf "$CACHE_DIR"
}

@test "state: get_console_state refreshes cache after TTL expires" {
    # Given: Stale cache file (modified >5 seconds ago)
    export CACHE_DIR="/tmp/test-cache-$$"
    mkdir -p "$CACHE_DIR"
    echo "console-1 inactive 12345" > "$CACHE_DIR/state.cache"
    touch -d "10 seconds ago" "$CACHE_DIR/state.cache"

    # Mock tmux to return new data
    source tests/helpers/mock-tmux.sh
    mock_tmux_list_sessions "console-1 active 67890"

    # When: Get state after TTL
    run get_console_state "console-1"

    # Then: Cache refreshed, returns new value
    [ "$status" -eq 0 ]
    [[ "$output" == "active" ]]

    # Cleanup
    rm -rf "$CACHE_DIR"
}
```

**What to test:**
- ✅ Happy path (normal input → expected output)
- ✅ Edge cases (empty input, invalid input)
- ✅ Error conditions (file missing, permission denied)
- ✅ Return codes (0=success, 1=error, 2=usage)

---

### 2.2 Integration Tests (tests/integration/)

**Scope:** Module interactions and data flow

**Target interactions:**
- State module + UI components (Manager reads state)
- State module + Actions (Actions update state)
- UI components + gum (Fallback to bash if gum missing)

**Coverage goal:** All public APIs between modules

**Example test:**
```bash
# tests/integration/test-manager-state.bats

@test "manager: displays correct console states from state module" {
    # Given: State module has cached data
    source src/core/state.sh
    source src/ui/manager/manager.sh

    # Mock state
    mock_console_state "console-1" "active"
    mock_console_state "console-2" "inactive"
    mock_console_state "console-3" "crashed"

    # When: Manager builds console list
    run build_console_list

    # Then: List contains all states with correct formatting
    [ "$status" -eq 0 ]
    [[ "$output" == *"● console-1 (active)"* ]]
    [[ "$output" == *"○ console-2 (inactive)"* ]]
    [[ "$output" == *"✖ console-3 (crashed)"* ]]
}

@test "actions: attach updates state cache" {
    # Given: Console inactive
    source src/core/state.sh
    source src/actions/attach.sh
    set_console_state "console-1" "inactive"

    # When: Attach to console
    run attach_to_console "console-1"

    # Then: State updated to active
    [ "$status" -eq 0 ]
    state=$(get_console_state "console-1")
    [[ "$state" == "active" ]]
}
```

**What to test:**
- ✅ Data flows correctly between modules
- ✅ APIs are used correctly
- ✅ Error propagation (module A error → module B handles it)
- ✅ Caching behavior (stale data doesn't propagate)

---

### 2.3 System Tests (tests/system/)

**Scope:** Full pTTY workflows end-to-end

**Target workflows:**
- F11 attach workflow (press F11 → select console → attached)
- F12 help display (press F12 → help shown → navigate → exit)
- Safe exit workflow (type exit → menu → detach)
- Console restart (F11 → restart → confirm → restarted)

**Coverage goal:** All critical user paths

**Example test:**
```bash
# tests/system/test-f11-attach.bats

@test "system: F11 attach workflow completes successfully" {
    # Given: pTTY running with multiple consoles
    setup_ptty_session
    create_console "console-1"
    create_console "console-2"
    create_console "console-3"

    # When: User presses F11 and selects console-2
    simulate_keypress "F11"
    simulate_selection "console-2"

    # Then: User is attached to console-2
    current_console=$(get_current_console)
    [[ "$current_console" == "console-2" ]]

    # Cleanup
    teardown_ptty_session
}

@test "system: safe exit shows menu and detaches" {
    # Given: User in console-1
    setup_ptty_session
    attach_to_console "console-1"

    # When: User types 'exit' and presses Enter
    simulate_input "exit\n"

    # Then: Menu shown, user can choose detach
    output=$(get_screen_output)
    [[ "$output" == *"Detach from session"* ]]
    [[ "$output" == *"Restart session"* ]]

    # When: User selects detach (Enter)
    simulate_keypress "Enter"

    # Then: User detached, console still running
    [[ $(tmux has-session -t "console-1") ]]

    # Cleanup
    teardown_ptty_session
}
```

**What to test:**
- ✅ Complete user workflows (start → middle → end)
- ✅ UI rendering (menus displayed correctly)
- ✅ Keyboard interactions (F-keys, navigation)
- ✅ Session persistence (survive disconnect)

---

### 2.4 Manual Tests (00-rules/testing-manual.md)

**Scope:** Visual validation and UX testing

**When to run:** Before each release (v0.2, v0.3, v1.0)

**What to test:**
- Visual appearance (status bar position, colors, icons)
- Feel/responsiveness (lag, flicker, smooth transitions)
- Edge cases hard to automate (network disconnect, terminal resize)
- Accessibility (screen readers, high contrast)

**See:** [../00-rules/testing-manual.md](../00-rules/testing-manual.md) for complete checklist

---

## 3. Mock Strategy

### 3.1 Tmux Mocking

**Problem:** Tests shouldn't rely on real tmux sessions (flaky, slow, state pollution)

**Solution:** Function override pattern

```bash
# tests/helpers/mock-tmux.sh

# Override tmux command with mock implementation
tmux() {
    local cmd="$1"
    shift

    case "$cmd" in
        list-sessions)
            # Return predefined session list
            cat <<EOF
console-1: 1 windows (created Thu Oct  9 10:00:00 2025)
console-2: 1 windows (created Thu Oct  9 10:01:00 2025)
console-3: 1 windows (created Thu Oct  9 10:02:00 2025)
EOF
            ;;
        has-session)
            local session="$1"
            # Check against mock session list
            if [[ "$session" =~ console-[1-3] ]]; then
                return 0
            else
                return 1
            fi
            ;;
        display-message)
            # Return mock session info
            echo "console-1"
            ;;
        *)
            echo "ERROR: Unmocked tmux command: $cmd $*" >&2
            return 1
            ;;
    esac
}

# Export for subshells
export -f tmux
```

**Usage in tests:**
```bash
@test "state: get_console_state queries tmux" {
    # Load mock
    source tests/helpers/mock-tmux.sh

    # Mock returns specific data
    run get_console_state "console-1"

    # Assertions...
}
```

**Advanced: Stateful mocking**
```bash
# tests/helpers/mock-tmux-stateful.sh

# Track mock state
declare -A MOCK_SESSIONS=(
    ["console-1"]="active"
    ["console-2"]="inactive"
)

tmux_has_session() {
    local session="$1"
    [[ -n "${MOCK_SESSIONS[$session]}" ]]
}

tmux_list_sessions() {
    for session in "${!MOCK_SESSIONS[@]}"; do
        echo "$session: 1 windows"
    done
}
```

---

### 3.2 Gum Mocking

**Problem:** Tests shouldn't require gum installed

**Solution:** Return predetermined selections

```bash
# tests/helpers/mock-gum.sh

gum() {
    local cmd="$1"
    shift

    case "$cmd" in
        choose)
            # Return first option by default
            # Or read from MOCK_GUM_CHOICE env var
            if [[ -n "$MOCK_GUM_CHOICE" ]]; then
                echo "$MOCK_GUM_CHOICE"
            else
                echo "$1"  # First option
            fi
            ;;
        confirm)
            # Return yes/no based on env var
            if [[ "$MOCK_GUM_CONFIRM" == "yes" ]]; then
                return 0
            else
                return 1
            fi
            ;;
        input)
            # Return mock input
            echo "${MOCK_GUM_INPUT:-default}"
            ;;
        *)
            echo "ERROR: Unmocked gum command: $cmd" >&2
            return 1
            ;;
    esac
}

export -f gum
```

**Usage:**
```bash
@test "manager: user selects console-2" {
    source tests/helpers/mock-gum.sh
    export MOCK_GUM_CHOICE="console-2"

    run show_manager_menu

    [[ "$output" == *"Attaching to console-2"* ]]
}
```

---

### 3.3 Filesystem Mocking

**Problem:** Tests shouldn't write to real ~/.cache/

**Solution:** Temporary test directories

```bash
# tests/helpers/test-helpers.sh

setup() {
    # Create isolated test environment
    export TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export CACHE_DIR="$TEST_HOME/.cache/ptty"
    export CONFIG_DIR="$TEST_HOME/.config/ptty"

    mkdir -p "$CACHE_DIR"
    mkdir -p "$CONFIG_DIR"
}

teardown() {
    # Clean up test environment
    rm -rf "$TEST_HOME"
}
```

**Usage in bats:**
```bash
# tests/unit/test-state-cache.bats

load 'helpers/test-helpers'

@test "state: creates cache directory if missing" {
    # setup() already created TEST_HOME

    run get_console_state "console-1"

    # Cache directory should be created
    [ -d "$CACHE_DIR" ]
}

# teardown() automatically called after test
```

---

## 4. Coverage Goals

### 4.1 Version-Specific Goals

**v0.2 (Current - Refactoring Focus):**
- **Unit tests:** 60% coverage of refactored modules
- **Integration:** Critical paths only (State ↔ UI, State ↔ Actions)
- **System:** F11, F12, safe exit workflows

**Rationale:** Focus on newly refactored code (Tasks 001-003)

**v1.0 (Production Release):**
- **Unit tests:** 80% coverage of all modules
- **Integration:** All module combinations tested
- **System:** All user workflows covered

**Rationale:** Production-quality requires comprehensive testing

---

### 4.2 Critical Path Coverage (Always 100%)

**Must be tested at 100% coverage:**
- State management (get/set/cache logic)
- Safe exit wrapper (prevents session loss)
- Session restart logic (critical for recovery)
- Console detection (basis for all operations)

**Why critical:** These features prevent **data loss** or **session corruption**

---

### 4.3 Coverage Measurement

**Simple approach (v0.2):**
```bash
# Count tested functions
total_functions=$(grep -r "^[a-z_]*() {$" src/ | wc -l)
tested_functions=$(grep -r "@test" tests/ | wc -l)
coverage=$((tested_functions * 100 / total_functions))
echo "Coverage: $coverage%"
```

**Advanced approach (v1.0):**
```bash
# Use kcov for line coverage
kcov --exclude-pattern=/usr/share coverage/ tests/
kcov --merge coverage-merged coverage/*
```

---

## 5. Test Organization

### 5.1 Directory Structure

```
tests/
├── unit/                           # Unit tests
│   ├── test-state-cache.bats
│   ├── test-config-loader.bats
│   ├── test-validation.bats
│   └── test-formatting.bats
├── integration/                    # Integration tests
│   ├── test-manager-state.bats
│   ├── test-statusbar-state.bats
│   └── test-actions-state.bats
├── system/                         # System tests
│   ├── test-f11-attach.bats
│   ├── test-f12-help.bats
│   └── test-safe-exit.bats
├── helpers/                        # Test utilities
│   ├── mock-tmux.sh
│   ├── mock-gum.sh
│   ├── test-helpers.sh
│   └── assertions.sh
└── fixtures/                       # Test data
    ├── sample-session.txt
    ├── sample-config.conf
    └── mock-state.cache
```

### 5.2 Naming Conventions

**Test files:**
```bash
test-{module-name}.bats             # Unit tests
test-{feature}-{integration}.bats   # Integration tests
test-{workflow}.bats                # System tests
```

**Test functions:**
```bash
@test "module: function_name scenario"
@test "state: get_console_state returns cached data"
@test "manager: show_menu displays all consoles"
@test "system: F11 attach workflow completes"
```

**Pattern:** `module/feature: action expected_result`

---

### 5.3 Test Data

**Fixtures location:** `tests/fixtures/`

**Example fixtures:**
```bash
# tests/fixtures/sample-session.txt
console-1: 1 windows (created Thu Oct  9 10:00:00 2025)
console-2: 1 windows (created Thu Oct  9 10:01:00 2025)

# tests/fixtures/sample-config.conf
MAX_CONSOLES=10
CACHE_TTL=5
THEME="dark"

# tests/fixtures/mock-state.cache
console-1 active 1696845600
console-2 inactive 1696845601
console-3 crashed 1696845602
```

**Loading fixtures:**
```bash
@test "config: loads valid config file" {
    local config_file="tests/fixtures/sample-config.conf"

    run load_config "$config_file"

    [ "$status" -eq 0 ]
    [[ "$MAX_CONSOLES" == "10" ]]
}
```

---

## 6. CI/CD Integration

### 6.1 GitHub Actions Workflow

**File:** `.github/workflows/test.yml`

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y bats tmux

      - name: Run unit tests
        run: bats tests/unit/

      - name: Run integration tests
        run: bats tests/integration/

      - name: Run system tests
        run: bats tests/system/

      - name: Check coverage
        run: |
          ./tools/coverage-report.sh
          if [ $COVERAGE -lt 60 ]; then
            echo "ERROR: Coverage $COVERAGE% below target 60%"
            exit 1
          fi

  shellcheck:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run ShellCheck
        run: |
          sudo apt-get install -y shellcheck
          find src/ -name "*.sh" -exec shellcheck {} \;
```

### 6.2 Test Execution Strategy

**On push to main:**
- Run all tests (unit + integration + system)
- Check coverage (fail if <60%)
- Run ShellCheck

**On pull request:**
- Run all tests
- Check coverage (fail if drops below current)
- Require passing tests before merge

**Nightly:**
- Run extended system tests
- Test with different tmux versions
- Generate coverage report

---

### 6.3 Failure Handling

**When tests fail:**
1. GitHub check fails (red X)
2. PR blocked from merging
3. Notification sent to author
4. Logs available in Actions tab

**Developer workflow:**
```bash
# Fix locally
bats tests/unit/test-state-cache.bats

# Push fix
git add tests/
git commit -m "fix(tests): Handle edge case in state cache"
git push

# GitHub Actions reruns automatically
```

---

## 7. Testing Standards

### 7.1 Assertion Style (bats)

**Exit code assertions:**
```bash
[ "$status" -eq 0 ]      # Success
[ "$status" -eq 1 ]      # General error
[ "$status" -eq 2 ]      # Usage error
```

**Output assertions:**
```bash
[ "$output" = "exact match" ]             # Exact match
[[ "$output" == *"substring"* ]]          # Contains
[[ "$output" =~ ^pattern$ ]]              # Regex match
[ -z "$output" ]                          # Empty
[ -n "$output" ]                          # Non-empty
```

**File assertions:**
```bash
[ -f "$file" ]           # File exists
[ -d "$dir" ]            # Directory exists
[ -r "$file" ]           # Readable
[ -w "$file" ]           # Writable
```

---

### 7.2 Setup/Teardown

**Pattern:**
```bash
# Load helpers
load 'helpers/test-helpers'
load 'helpers/mock-tmux'

setup() {
    # Create test environment (runs before each test)
    export TEST_HOME=$(mktemp -d)
    export CACHE_DIR="$TEST_HOME/.cache/ptty"
    mkdir -p "$CACHE_DIR"

    # Load modules under test
    source src/core/state.sh
}

teardown() {
    # Clean up (runs after each test)
    rm -rf "$TEST_HOME"
}

@test "example test" {
    # Test runs with fresh environment
}
```

---

### 7.3 Test Documentation

**Every test should have clear structure:**
```bash
@test "module: function_name scenario" {
    # Given: Initial state/preconditions
    export CACHE_DIR="/tmp/test"
    echo "console-1 active" > "$CACHE_DIR/state.cache"

    # When: Action/operation
    run get_console_state "console-1"

    # Then: Expected result
    [ "$status" -eq 0 ]
    [[ "$output" == "active" ]]
}
```

---

## 8. Edge Cases to Test

### 8.1 State Management
- ✅ Cache file missing (create new)
- ✅ Cache file corrupted (ignore and refresh)
- ✅ Cache expired (past TTL window)
- ✅ Tmux command fails (error handling)
- ✅ Empty session list (handle gracefully)
- ✅ Race condition (multiple processes updating cache)

### 8.2 Console Detection
- ✅ Console doesn't exist (error message)
- ✅ Console name has spaces (quote correctly)
- ✅ Console crashed (no process running)
- ✅ Multiple consoles same name (disambiguation)
- ✅ Invalid console name (reject with clear error)

### 8.3 Safe Exit
- ✅ User presses Ctrl+C during menu (cancel gracefully)
- ✅ Session restarts mid-operation (handle race)
- ✅ Invalid key input (show error, retry)
- ✅ Terminal disconnects during exit (session persists)
- ✅ Rapid repeated exit commands (debounce)

### 8.4 Tmux Integration
- ✅ Tmux not running (clear error message)
- ✅ Tmux version too old (warn or fail gracefully)
- ✅ Permission denied (explain and suggest fix)
- ✅ Socket path issues (check $TMUX_TMPDIR)

---

## 9. Tools & Requirements

### 9.1 Test Framework

**bats (Bash Automated Testing System)**

Install:
```bash
sudo apt-get install bats
```

Run tests:
```bash
# Single file
bats tests/unit/test-state-cache.bats

# Directory
bats tests/unit/

# All tests
bats tests/
```

**Documentation:** https://github.com/bats-core/bats-core

---

### 9.2 Coverage Tools

**Simple (v0.2):**
```bash
# tools/coverage-report.sh
total=$(grep -r "^[a-z_]*() {$" src/ | wc -l)
tested=$(grep -r "@test" tests/ | wc -l)
echo "Coverage: $((tested * 100 / total))%"
```

**Advanced (v1.0):**
```bash
# kcov for line coverage
sudo apt-get install kcov
kcov coverage/ tests/
```

---

### 9.3 Continuous Integration

**GitHub Actions** (included with repository)

**Workflow files:**
- `.github/workflows/test.yml` - Run tests on push/PR
- `.github/workflows/coverage.yml` - Nightly coverage report

---

## 10. References

### Internal Documentation
- **[CODE-STANDARDS.md](../00-rules/CODE-STANDARDS.md)** - Testing conventions
- **[testing-manual.md](../00-rules/testing-manual.md)** - Manual testing checklist
- **[Task 004](../04-tasks/004-testing-framework.md)** - Testing framework setup

### External Resources
- **bats-core:** https://github.com/bats-core/bats-core
- **ShellCheck:** https://www.shellcheck.net/
- **Google Test Pyramid:** https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html

---

**This testing strategy ensures comprehensive, maintainable test coverage for pTTY v0.2+.**
