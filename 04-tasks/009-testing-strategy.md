**Purpose:** Create testing strategy document defining test levels, mock patterns, and coverage goals

---

# Task 009: Create Testing Strategy Document

**Phase:** v0.2 Documentation
**Priority:** 🟡 HIGH
**Estimated Time:** 1 day
**Dependencies:** Task 008 (CODE-STANDARDS.md complete)
**Assignee:** Unassigned

---

## Objective

Create comprehensive testing strategy document (03-architecture/testing-strategy.md) that defines:
- Test levels (unit, integration, system, manual)
- Mock strategy for tmux and gum
- Coverage goals per version (v0.2: 60%, v1.0: 80%)
- Test naming conventions
- CI/CD integration approach

**Source:** [03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md) - Priority 3

**Why Important:** Task 004 (testing framework setup) lacks clear requirements. Without strategy, we risk incomplete test coverage and unclear testing standards.

---

## Problem Statement

Currently:
- ✅ 00-rules/testing-manual.md exists (manual testing)
- ✅ Task 004 mentions bats framework
- ❌ No overall testing strategy documented
- ❌ No mock strategy for tmux commands
- ❌ No coverage goals defined
- ❌ No CI/CD testing workflow
- ❌ tests/README.md missing

This creates:
- Unclear what/how to test
- No consensus on test coverage
- Task 004 implementation uncertainty
- Risk of incomplete testing

---

## Acceptance Criteria

### Phase 1: Test Levels Definition
- [ ] Unit tests scope defined (individual functions)
- [ ] Integration tests scope (module interactions)
- [ ] System tests scope (full pTTY workflows)
- [ ] Manual tests reference (link to testing-manual.md)

### Phase 2: Mock Strategy
- [ ] Mock tmux commands strategy (return fake data)
- [ ] Mock gum commands strategy (simulate input)
- [ ] Mock file system operations (cache, temp files)
- [ ] Test isolation patterns (clean state between tests)

### Phase 3: Coverage Goals
- [ ] v0.2 coverage target: 60% (refactored modules)
- [ ] v1.0 coverage target: 80% (all code)
- [ ] Critical path coverage: 100% (state management, safe exit)
- [ ] Tools for measuring coverage (kcov or simple line count)

### Phase 4: Test Organization
- [ ] Test file naming convention
- [ ] Test function naming pattern
- [ ] Directory structure (tests/ organization)
- [ ] Test data location (fixtures, mocks)

### Phase 5: CI/CD Integration
- [ ] GitHub Actions workflow for tests
- [ ] Test execution on push/PR
- [ ] Coverage reporting integration
- [ ] Failure notification strategy

### Phase 6: Testing Standards
- [ ] Assertion patterns (bats assertion style)
- [ ] Setup/teardown conventions
- [ ] Test documentation requirements
- [ ] Edge case identification process

---

## Implementation Details

### Document Structure

```markdown
# testing-strategy.md

**Purpose:** Overall testing strategy for pTTY v0.2+

## 1. Test Pyramid

```
       /\
      /  \  Manual (E2E)
     /----\
    / Sys  \ System Tests
   /--------\
  /   Int    \ Integration Tests
 /------------\
/    Unit      \ Unit Tests
----------------
```

## 2. Test Levels

### Unit Tests (tests/unit/)
**Scope:** Individual functions in isolation
**Target:** Core modules (state, config, validation)
**Coverage:** 80% of refactored code

**Example:**
```bash
# tests/unit/test-state-cache.bats
@test "get_console_state returns cached data within TTL" {
    # Setup: Create fake cache file
    # Execute: Call function
    # Assert: Returns cached data, no tmux call
}
```

### Integration Tests (tests/integration/)
**Scope:** Module interactions
**Target:** State + UI, Actions + State
**Coverage:** All public APIs

**Example:**
```bash
# tests/integration/test-manager-state.bats
@test "Manager displays correct console states" {
    # Setup: Mock tmux with specific state
    # Execute: Call manager list function
    # Assert: Output matches expected format
}
```

### System Tests (tests/system/)
**Scope:** Full pTTY workflows
**Target:** F11 attach, F12 help, safe exit
**Coverage:** Critical user journeys

**Example:**
```bash
# tests/system/test-console-attach.bats
@test "F11 attach workflow completes successfully" {
    # Setup: Start pTTY session
    # Execute: Simulate F11 + select console
    # Assert: Attached to correct console
}
```

### Manual Tests (00-rules/testing-manual.md)
**Scope:** Visual validation, UX testing
**When:** Before each release
**Reference:** [../../00-rules/testing-manual.md](../../00-rules/testing-manual.md)

## 3. Mock Strategy

### Tmux Mocking

**Approach:** Function override pattern
```bash
# tests/helpers/mock-tmux.sh

# Mock tmux list-sessions
tmux() {
    case "$1" in
        list-sessions)
            cat <<EOF
console-1: 1 windows (created Thu Oct  9 10:00:00 2025)
console-2: 1 windows (created Thu Oct  9 10:01:00 2025)
EOF
            ;;
        *)
            echo "ERROR: Unmocked tmux command: $*" >&2
            return 1
            ;;
    esac
}
export -f tmux
```

**Usage:**
```bash
# In test file
source tests/helpers/mock-tmux.sh
```

### Gum Mocking

**Approach:** Return pre-defined selections
```bash
# tests/helpers/mock-gum.sh

gum() {
    case "$1" in
        choose)
            # Return first option
            echo "$2"
            ;;
        confirm)
            # Always yes
            return 0
            ;;
    esac
}
export -f gum
```

### File System Mocking

**Approach:** Use temporary test directories
```bash
setup() {
    TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export CACHE_DIR="$TEST_HOME/.cache/ptty"
    mkdir -p "$CACHE_DIR"
}

teardown() {
    rm -rf "$TEST_HOME"
}
```

## 4. Coverage Goals

### v0.2 (Current)
- **Unit tests:** 60% coverage
- **Integration:** Critical paths only
- **System:** F11, F12, safe exit

**Rationale:** Focus on refactored modules (Tasks 001-003)

### v1.0 (Production)
- **Unit tests:** 80% coverage
- **Integration:** All module combinations
- **System:** All user workflows

**Rationale:** Production-ready quality

### Critical Path (Always 100%)
- State management (cache, query)
- Safe exit wrapper
- Session restart logic
- Console detection

## 5. Test Organization

### Directory Structure
```
tests/
├── unit/
│   ├── test-state-cache.bats
│   ├── test-config.bats
│   └── test-validation.bats
├── integration/
│   ├── test-manager-state.bats
│   └── test-statusbar-state.bats
├── system/
│   ├── test-f11-attach.bats
│   └── test-safe-exit.bats
├── helpers/
│   ├── mock-tmux.sh
│   ├── mock-gum.sh
│   └── test-helpers.sh
└── fixtures/
    ├── sample-session.txt
    └── sample-config.conf
```

### Naming Conventions
- Test files: `test-{module-name}.bats`
- Test functions: `@test "module: action scenario"`
- Helper files: `{purpose}-{tool}.sh`

## 6. CI/CD Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install bats
        run: sudo apt-get install bats
      - name: Run tests
        run: bats tests/
      - name: Coverage report
        run: ./tools/coverage-report.sh
```

### Test Execution
- **On push:** Run all tests
- **On PR:** Run all tests + coverage check
- **Nightly:** Extended system tests

### Failure Handling
- Fail PR if tests fail
- Fail PR if coverage drops
- Notify via GitHub checks

## 7. Testing Standards

### Assertion Style (bats)
```bash
# Use bats assertion helpers
[ "$status" -eq 0 ]           # Exit code
[ "$output" = "expected" ]    # Output match
[[ "$output" =~ pattern ]]    # Regex match
```

### Setup/Teardown
```bash
setup() {
    # Create test environment
    load 'helpers/mock-tmux'
    load 'helpers/test-helpers'
}

teardown() {
    # Clean up
    rm -rf "$TEST_HOME"
}
```

### Test Documentation
```bash
@test "get_console_state: returns cached data within TTL" {
    # Given: Cache file exists with recent timestamp
    # When: Function called within TTL window
    # Then: Returns cached data without tmux call
}
```

## 8. Edge Cases to Test

### State Management
- Cache file missing
- Cache file corrupted
- Cache expired (past TTL)
- Tmux command fails
- Empty session list

### Console Detection
- Console doesn't exist
- Console name has spaces
- Console crashed (no process)
- Multiple consoles same name

### Safe Exit
- User presses Ctrl+C during menu
- Session restarts mid-operation
- Invalid key input
- Terminal disconnects

## 9. Tools & Requirements

### Test Framework
- **bats** (Bash Automated Testing System)
- Install: `sudo apt-get install bats`

### Coverage
- **kcov** (optional, for detailed coverage)
- Simple: Line count of tested vs total functions

### Continuous Integration
- GitHub Actions (included with repository)

## 10. References

- **Manual Testing:** [../../00-rules/testing-manual.md](../../00-rules/testing-manual.md)
- **Code Standards:** [../../00-rules/CODE-STANDARDS.md](../../00-rules/CODE-STANDARDS.md)
- **Task 004:** [../../04-tasks/004-testing-framework.md](../../04-tasks/004-testing-framework.md)
- **bats docs:** https://github.com/bats-core/bats-core
```

---

## Testing Requirements

### Self-Validation Checklist

After creating testing-strategy.md:

- [ ] All test levels clearly defined with examples
- [ ] Mock strategy includes code examples
- [ ] Coverage goals specific per version
- [ ] CI/CD workflow documented
- [ ] Cross-links to related docs work
- [ ] Task 004 can use this as input

### Review by Stakeholders

- [ ] Review by Task 004 assignee (testing framework implementer)
- [ ] Validate mock strategy is feasible
- [ ] Confirm coverage goals are realistic

---

## Related Documents

- **Review:** [../03-architecture/DOCUMENTATION-REVIEW.md](../03-architecture/DOCUMENTATION-REVIEW.md)
- **Manual Testing:** [../00-rules/testing-manual.md](../00-rules/testing-manual.md)
- **Task 004:** [004-testing-framework.md](004-testing-framework.md) - Will implement this strategy
- **CODE-STANDARDS:** [../00-rules/CODE-STANDARDS.md](../00-rules/CODE-STANDARDS.md) - Testing conventions

---

## Success Metrics

- [ ] Document created: 03-architecture/testing-strategy.md
- [ ] All 10 sections complete
- [ ] Mock strategy has working examples
- [ ] Coverage goals defined per version
- [ ] CI/CD workflow specified
- [ ] Task 004 can proceed with clear requirements

---

## Deliverables

1. **03-architecture/testing-strategy.md** (main document)
2. **Updated 03-architecture/CLAUDE.md** (add testing-strategy link)
3. **tests/README.md** (how to run tests - quick reference)

---

## Notes

**After this task:**
- Task 004 (testing framework) has clear requirements
- Mock patterns are standardized
- Coverage goals are agreed upon
- CI/CD integration path is clear

**Estimated Time Breakdown:**
- Test levels definition: 2 hours
- Mock strategy + examples: 2 hours
- Coverage goals + standards: 2 hours
- CI/CD workflow: 1 hour
- Polish + cross-links: 1 hour
- **Total: 8 hours (1 day)**
