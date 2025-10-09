**Purpose:** Document decision to use gum as optional TUI framework for F11 Manager and F12 Help

---

# ADR 003: Gum TUI Framework for Interactive Menus

**Date:** 2025-10-09
**Status:** Accepted
**Decision Maker:** zentala + Claude Code

---

## Context

pTTY needs interactive user interfaces for:
- **F11 Manager:** Select console to attach/restart
- **F12 Help:** Browse keyboard shortcuts
- Future: Configuration menu, console templates

**Requirements:**
- Professional-looking TUI (not just `read` prompts)
- Keyboard navigation (arrow keys, Enter, ESC)
- Visual feedback (highlighting, colors)
- Optional dependency (graceful fallback)
- Lightweight (no Python/Node.js)

---

## Decision

**Use `gum` as the TUI framework with bash fallback.**

**Implementation:**
```bash
# Check if gum available
if command -v gum &>/dev/null; then
    # Professional TUI with gum
    choice=$(gum choose "Console 1" "Console 2" "Console 3")
else
    # Simple fallback with bash read
    echo "1) Console 1"
    echo "2) Console 2"
    echo "3) Console 3"
    read -p "Choice: " choice
fi
```

**Install:** `sudo apt install gum` (optional)

---

## What is Gum?

**Gum** is a CLI tool for glamorous shell scripts by Charm.

**Features:**
- `gum choose` - Interactive selection menu
- `gum input` - Text input with validation
- `gum confirm` - Yes/No prompts
- `gum style` - Text styling and colors
- `gum spin` - Loading spinners

**Example:**
```bash
gum choose \
    --header "Select console:" \
    --cursor "> " \
    --selected "▶ " \
    "Console 1 (active)" \
    "Console 2 (inactive)" \
    "Console 3 (crashed)"
```

**Website:** https://github.com/charmbracelet/gum

---

## Alternatives Considered

### 1. Pure Bash (read + echo)
**Pros:**
- No dependencies
- Works everywhere

**Cons:**
- ❌ Ugly interface (plain text)
- ❌ No arrow key navigation
- ❌ No visual feedback
- ❌ Poor UX

**Verdict:** Used as fallback, not primary

---

### 2. dialog / whiptail
**Pros:**
- Classic UNIX tool
- Well-known

**Cons:**
- ❌ Old-fashioned ncurses look
- ❌ Complex scripting
- ❌ Not modern aesthetics

**Verdict:** Rejected - dated UX

---

### 3. fzf (Fuzzy Finder)
**Pros:**
- Fast fuzzy search
- Popular tool

**Cons:**
- ❌ Overkill for simple menus
- ❌ Not designed for structured UIs
- ❌ Search not needed for 10 consoles

**Verdict:** Rejected - wrong tool for the job

---

### 4. Custom TUI in Go/Rust
**Pros:**
- Full control
- No external dependency

**Cons:**
- ❌ Requires compilation
- ❌ High maintenance burden
- ❌ Against "Low-Code" principle
- ❌ Months of development time

**Verdict:** Rejected - over-engineering

---

### 5. Bubble Tea (Go TUI Framework)
**Pros:**
- Powerful
- Modern

**Cons:**
- ❌ Requires Go runtime
- ❌ Custom code needed (not just CLI calls)
- ❌ Compile-time dependency

**Verdict:** Rejected - too complex

---

## Rationale

**Why gum?**

1. **Developer Experience:**
   - Beautiful UIs out of the box
   - Arrow key navigation
   - Visual highlighting
   - Professional look

2. **Low-Code Philosophy:**
   - CLI tool, not a library
   - Simple bash integration: `gum choose ...`
   - No compilation needed
   - Single binary (~10MB)

3. **Graceful Degradation:**
   - Optional dependency
   - Fallback to bash `read` works
   - User experience degrades but doesn't break

4. **Maintained & Popular:**
   - Active development (Charm team)
   - 16k+ GitHub stars
   - Used in many projects
   - Good documentation

5. **Proven in pTTY v0.1:**
   - F11 Manager already uses gum
   - Positive user feedback
   - No issues reported

---

## Consequences

### Positive
- ✅ Professional TUI with minimal code
- ✅ Great developer experience
- ✅ Fast implementation (hours, not weeks)
- ✅ Easy to maintain
- ✅ Active community support
- ✅ Matches "Low-Code, High-Impact" principle

### Negative
- ⚠️ External dependency (but optional)
- ⚠️ Requires installation (`apt install gum`)
- ⚠️ 10MB binary size

### Mitigations
- Gum is optional (fallback to bash)
- Installation docs in README.md
- Check `command -v gum` before using
- Fallback UI is functional (not broken)

---

## Usage Guidelines

### When to Use Gum
- ✅ F11 Manager (console selection)
- ✅ F12 Help (shortcut browser)
- ✅ Future: Configuration wizard
- ✅ Future: Console templates

### When NOT to Use Gum
- ❌ Status bar (must be pure tmux)
- ❌ Safe exit wrapper (must work without gum)
- ❌ Core functionality (breaks without gum)
- ❌ Background scripts (no interactive needed)

**Rule:** Gum only for interactive UI, never for core logic.

---

## Implementation Notes

**Detection:**
```bash
if command -v gum &>/dev/null; then
    USE_GUM=1
else
    USE_GUM=0
fi
```

**Fallback pattern:**
```bash
if [[ $USE_GUM -eq 1 ]]; then
    choice=$(gum choose "${options[@]}")
else
    echo "Select console:"
    select choice in "${options[@]}"; do
        [[ -n $choice ]] && break
    done
fi
```

**Installation check:**
- On first run, check for gum
- If missing, show: "Install gum for better UI: sudo apt install gum"
- Don't force installation (optional)

---

## Future Improvements

**For v1.0:**
- Custom gum styling (match pTTY theme)
- Consistent UI patterns across F11/F12
- Help text in gum menus

**For v2.0:**
- Advanced TUI features (gum filters, gum table)
- Configuration menu with gum forms
- Console templates with gum wizards

---

## Related Decisions

- **ADR 005:** No external scripts in status bar (why gum NOT used there)
- **[../01-vision/principles.md](../../01-vision/principles.md):** Low-Code, High-Impact principle
- **[../../02-planning/specs/MANAGER-SPEC.md](../../02-planning/specs/MANAGER-SPEC.md):** F11 Manager specification

---

## References

- **Gum GitHub:** https://github.com/charmbracelet/gum
- **Installation:** `sudo apt install gum` or download from releases
- **Implementation:** `src/ui/manager/manager.sh`, `src/ui/help/help.sh`
- **Testing:** Manual testing with/without gum installed

---

**Gum provides professional TUI with minimal code, aligning perfectly with pTTY's "Low-Code, High-Impact" philosophy.**
