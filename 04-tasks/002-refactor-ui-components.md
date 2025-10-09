**Purpose:** Extract reusable UI components from monolithic Manager and Help scripts

---

# Task 002: Refactor UI Components

**Phase:** v0.2 Refactoring
**Priority:** High
**Estimated Time:** 2-3 days
**Dependencies:** Task 001 (State management complete), Task 008 (CODE-STANDARDS)
**Assignee:** Unassigned

---

## Objective

Extract reusable UI components from monolithic Manager and Help scripts. Create modular, testable UI pieces that can be reused across different interfaces.

---

## Acceptance Criteria

- [ ] UI components directory created at `src/ui/components/`
- [ ] Dialog component created (`dialog.sh`)
- [ ] List component created (`list.sh`)
- [ ] Header component created (`header.sh`)
- [ ] Footer component created (`footer.sh`)
- [ ] Manager refactored to use components
- [ ] Help refactored to use components
- [ ] Unit tests for components
- [ ] No regressions in UI functionality

---

## Components to Create

### 1. Dialog Component (`src/ui/components/dialog.sh`)

**API:**
```bash
# Show confirmation dialog (Yes/No)
dialog::confirm "Title" "Message" [default_yes]

# Show input dialog
dialog::input "Title" "Prompt" [default_value]

# Show alert dialog
dialog::alert "Title" "Message"
```

**Implementation:**
```bash
dialog::confirm() {
  local title="$1"
  local message="$2"
  local default_yes="${3:-false}"

  if command -v gum &>/dev/null; then
    gum confirm "$message"
  else
    # Fallback
    read -p "$message [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]]
  fi
}
```

### 2. List Component (`src/ui/components/list.sh`)

**API:**
```bash
# Show selectable list
# Returns selected item
list::choose "Title" items[@]

# Show filterable list
list::filter "Title" items[@]
```

### 3. Header Component (`src/ui/components/header.sh`)

**API:**
```bash
# Render header with title and icon
header::render "󰓉" "PersistentTTY Manager"
```

### 4. Footer Component (`src/ui/components/footer.sh`)

**API:**
```bash
# Render navigation hints
footer::render_hints "↑↓ Select" "Enter Execute" "Esc Exit"
```

---

## Manager Refactoring

**Before:**
```bash
# manager-menu.sh (monolithic - 300+ lines)
# - All UI rendering inline
# - No reusable parts
```

**After:**
```bash
# src/ui/manager/manager-main.sh (clean - 100 lines)
source ui/components/dialog.sh
source ui/components/list.sh
source ui/components/header.sh

header::render "󰓉" "PersistentTTY Manager"
selected=$(list::choose "Select console" consoles[@])
if dialog::confirm "Restart" "Restart console F${num}?"; then
  actions::restart "$num"
fi
```

---

## Testing Requirements

**Unit tests:** Test components independently
- `tests/unit/test-dialog.sh`
- `tests/unit/test-list.sh`
- `tests/unit/test-header.sh`

**Integration tests:** Test Manager with components
- Verify UI renders correctly
- Verify interactions work
- No visual regressions

---

## Related Documentation

- [ARCHITECTURE-ANALYSIS.md](../docs/ARCHITECTURE-ANALYSIS.md) - UI component pattern
- [MANAGER-SPEC.md](../specs/MANAGER-SPEC.md) - Manager requirements

---

## Notes

- Keep components simple and focused (SRP)
- Use gum when available, fallback to bash read
- Document all component APIs
- Make components theme-aware (colors, icons)
