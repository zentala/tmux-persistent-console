# Task 015: Refactor Action Layer

**Phase:** v1.5 Refactoring
**Priority:** High
**Estimated Time:** 1-2 days
**Dependencies:** 013 (State), 014 (UI Components)
**Assignee:** Unassigned

---

## Objective

Extract console actions (attach, activate, restart, detach) into dedicated, testable action modules. Centralize action logic so it can be called from Manager, keyboard shortcuts, and future CLI.

---

## Acceptance Criteria

- [ ] Actions directory created at `src/actions/`
- [ ] Attach action (`attach.sh`)
- [ ] Activate action (`activate.sh`)
- [ ] Restart action (`restart.sh`)
- [ ] Detach action (`detach.sh`)
- [ ] Manager uses action modules
- [ ] Keyboard shortcuts use action modules
- [ ] Unit tests for all actions
- [ ] Integration tests
- [ ] No regressions

---

## Actions to Create

### 1. Attach Action (`src/actions/attach.sh`)

**Purpose:** Switch to existing active console

**API:**
```bash
# Attach to console
# Arguments: $1 = console number (1-10)
# Returns: 0 on success, 1 on error
actions::attach <num>
```

**Implementation:**
```bash
source src/core/state.sh
source src/core/tmux-wrapper.sh
source src/utils/logging.sh

actions::attach() {
  local num=$1

  # Validate
  if ! state::console_exists $num; then
    logging::error "Console F${num} does not exist"
    return 1
  fi

  # Execute
  tmux_wrapper::switch_client "console-${num}"
  
  logging::info "Attached to console F${num}"
  return 0
}
```

### 2. Activate Action (`src/actions/activate.sh`)

**Purpose:** Create and attach to suspended console

**API:**
```bash
# Activate suspended console (create + attach)
# Arguments: $1 = console number (1-10)
# Returns: 0 on success, 1 on error
actions::activate <num> [--no-confirm]
```

### 3. Restart Action (`src/actions/restart.sh`)

**Purpose:** Kill and recreate console

**API:**
```bash
# Restart console (kill + create)
# Arguments: $1 = console number (1-10)
# Options: --force (skip confirmation)
# Returns: 0 on success, 1 on error
actions::restart <num> [--force]
```

### 4. Detach Action (`src/actions/detach.sh`)

**Purpose:** Safely leave console

**API:**
```bash
# Detach from current console
# Returns: 0 on success
actions::detach
```

---

## Files to Modify

**Manager (`src/ui/manager/manager-main.sh`):**
```bash
# OLD:
tmux switch-client -t "console-${num}"

# NEW:
source src/actions/attach.sh
actions::attach $num
```

**Keyboard shortcuts (`src/tmux.conf`):**
```tmux
# OLD:
bind-key -n C-F1 switch-client -t console-1

# NEW:
bind-key -n C-F1 run-shell "bash ~/.vps/sessions/src/actions/attach.sh 1"
```

---

## Testing Requirements

**Unit tests:** `tests/unit/test-actions.sh`
- Test attach with valid/invalid console
- Test activate with confirmation/force
- Test restart with confirmation/force
- Test detach from console
- Mock tmux and state

**Integration tests:** `tests/integration/test-actions.sh`
- Create real console, attach, verify
- Activate suspended, verify created
- Restart active, verify recreated

---

## Related Documentation

- [GLOSSARY.md](../specs/GLOSSARY.md) - Action definitions
- [MANAGER-SPEC.md](../specs/MANAGER-SPEC.md) - Action requirements

---

## Notes

- Actions should be pure operations (no UI)
- Use dialog component for confirmations
- Always log actions for debugging
- Validate inputs (console number 1-10)
- Handle errors gracefully
- Make actions idempotent where possible
