**Purpose:** Document decision to use shell variables for theme configuration instead of config files

---

# ADR 004: Theme Configuration via Shell Variables

**Date:** 2025-10-09
**Status:** Accepted
**Decision Maker:** zentala + Claude Code

---

## Context

pTTY needs configurable theming for:
- Status bar colors (active, inactive, crashed states)
- Console highlighting (current console vs others)
- Icons (Nerd Fonts or ASCII fallback)
- UI elements (F11 Manager, F12 Help)

**Requirements:**
- Easy customization for users
- No configuration required for defaults
- Support for multiple themes
- Simple implementation
- Fast loading (no parsing overhead)

---

## Decision

**Use shell variables defined at the top of scripts, NOT external config files.**

**Implementation:**
```bash
# src/ui/status-bar/theme.sh
# Theme Variables - Edit these to customize appearance

# Console States
readonly THEME_ACTIVE_FG="colour15"      # White
readonly THEME_ACTIVE_BG="colour22"      # Dark green
readonly THEME_INACTIVE_FG="colour244"   # Gray
readonly THEME_INACTIVE_BG="colour235"   # Dark gray
readonly THEME_CRASHED_FG="colour196"    # Red
readonly THEME_CRASHED_BG="colour235"    # Dark gray

# Icons (Nerd Fonts)
readonly ICON_ACTIVE="●"
readonly ICON_INACTIVE="○"
readonly ICON_CRASHED="✖"

# ASCII Fallback (no Nerd Fonts)
readonly ICON_ACTIVE_ASCII="*"
readonly ICON_INACTIVE_ASCII="o"
readonly ICON_CRASHED_ASCII="X"
```

**Usage:**
```bash
# User wants to customize? Edit the file directly.
vim src/ui/status-bar/theme.sh
```

---

## Alternatives Considered

### 1. External Config File (~/.ptty.conf)
**Pros:**
- User doesn't touch code
- Standard pattern (like `.vimrc`, `.tmux.conf`)

**Cons:**
- ❌ Requires parsing (bash, YAML, TOML?)
- ❌ More complexity (error handling)
- ❌ Slower startup (file read + parse)
- ❌ Two places to look (code + config)
- ❌ Config schema versioning issues

**Verdict:** Rejected for v0.2 - over-engineered

---

### 2. Environment Variables
**Example:** `export PTTY_ACTIVE_COLOR="green"`

**Pros:**
- No file needed
- Shell-native

**Cons:**
- ❌ Clutter in shell profile
- ❌ Lost on logout (not persistent)
- ❌ No validation
- ❌ Hard to manage (many vars)

**Verdict:** Rejected - poor UX

---

### 3. tmux Options (set-option)
**Example:** `tmux set-option @ptty-active-color "green"`

**Pros:**
- Native to tmux
- Per-session config possible

**Cons:**
- ❌ Tmux-specific (not portable)
- ❌ Requires tmux running to configure
- ❌ Not obvious where to edit
- ❌ Lost on server restart

**Verdict:** Rejected - not portable

---

### 4. Hardcoded Values
**Pros:**
- Simplest possible
- No configuration at all

**Cons:**
- ❌ Not customizable
- ❌ One-size-fits-all (bad for accessibility)
- ❌ Light/dark terminal issues

**Verdict:** Rejected - too inflexible

---

## Rationale

**Why shell variables in code?**

1. **Simplicity:**
   - No parsing logic needed
   - No file I/O on startup
   - Bash-native (no external tools)

2. **Performance:**
   - Zero overhead (variables declared at script start)
   - No config file reads
   - No parsing delays

3. **Transparency:**
   - One place to look (theme.sh)
   - Self-documenting (comments in code)
   - Easy to understand (just variables)

4. **"Just Works" Philosophy:**
   - Default theme works out of the box
   - No config file required
   - Advanced users can edit if wanted

5. **Progressive Disclosure:**
   - Beginners: Use defaults (never see theme.sh)
   - Intermediate: Edit theme.sh directly
   - Advanced: Swap entire theme files

---

## Consequences

### Positive
- ✅ Fast startup (no file parsing)
- ✅ Simple implementation (just variables)
- ✅ Easy debugging (grep for variable name)
- ✅ Self-documenting (comments in code)
- ✅ No config schema versioning issues

### Negative
- ⚠️ User must edit code (not "config file")
- ⚠️ No validation (typos cause errors)
- ⚠️ Git conflicts if user customizes

### Mitigations
- Clear comments in theme.sh
- Template themes (copy and modify)
- Validation in future (v1.0)
- Document "how to customize" in README

---

## Usage Guidelines

### For Users (Customization)

**Simple customization:**
```bash
# Edit theme file
vim src/ui/status-bar/theme.sh

# Change colors
readonly THEME_ACTIVE_BG="colour28"  # Brighter green

# Reload pTTY to see changes
```

**Advanced customization (v1.0+):**
```bash
# Create custom theme
cp src/ui/status-bar/theme.sh src/ui/status-bar/theme-custom.sh

# Edit custom theme
vim src/ui/status-bar/theme-custom.sh

# Switch theme (future feature)
export PTTY_THEME="custom"
```

### For Developers

**Adding new theme variable:**
1. Add to `theme.sh` with comment
2. Use in code: `echo "$THEME_ACTIVE_FG"`
3. Document in README.md

**Color testing:**
```bash
# See all tmux colors
for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
done
```

---

## Future Improvements

**For v1.0:**
- Theme presets (dark, light, solarized, dracula)
- Theme switcher: `ptty theme list`, `ptty theme set dark`
- Validation on startup (check color values)

**For v2.0:**
- External config file support (optional)
- Per-console theming
- Dynamic theme switching (no restart)
- Theme marketplace (community themes)

---

## Theme Structure

**Current organization:**
```
src/ui/status-bar/
├── theme.sh              # Default theme (dark)
├── theme-light.sh        # Future: Light theme
├── theme-solarized.sh    # Future: Solarized
└── theme-custom.sh       # User's custom theme (gitignored)
```

**Color scheme:**
- **Active:** Green (colour22 bg, colour15 fg)
- **Inactive:** Gray (colour235 bg, colour244 fg)
- **Crashed:** Red (colour235 bg, colour196 fg)
- **Current:** Bold + brighter

---

## Related Decisions

- **ADR 002:** State caching (theme vars used in status bar)
- **ADR 005:** No external scripts in status bar (theme vars compiled into tmux config)
- **[../../02-planning/specs/STATUS-BAR-SPEC.md](../../02-planning/specs/STATUS-BAR-SPEC.md):** Status bar specification
- **[../../02-planning/specs/ICONS-SPEC.md](../../02-planning/specs/ICONS-SPEC.md):** Icon specification

---

## References

- **Implementation:** `src/ui/status-bar/theme.sh`
- **Documentation:** README.md "Customization" section
- **tmux colors:** https://www.ditig.com/256-colors-cheat-sheet

---

**Shell variables provide the simplest theming solution for v0.2. External config files may come in v1.0+ if user demand exists.**

---

## Used In

- **[STATUS-BAR-SPEC](../../02-planning/specs/STATUS-BAR-SPEC.md):** Status bar colors and icons use theme variables
- **[ICONS-SPEC](../../02-planning/specs/ICONS-SPEC.md):** Icon definitions stored as theme variables

## Affects Tasks

- **[Task 001](../../04-tasks/001-refactor-state-management.md):** State module may use theme constants
- **[Task 002](../../04-tasks/002-refactor-ui-components.md):** UI components use theme variables for display
