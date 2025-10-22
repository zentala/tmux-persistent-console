# Lesson 02: Tmux Color Comma Bug in Conditionals

**Date**: 2025-10-12
**Severity**: High (Visual corruption)
**Category**: Tmux syntax, status bar
**Related**: [lesson-01-status-bar-flickering.md](lesson-01-status-bar-flickering.md)

---

## Problem

Status bar displays broken text fragments like:
- `colory236]` or `bg=colour236]`
- Partial color codes visible as text
- Icons and F-key labels corrupted
- Visual glitches after switching sessions

**Example broken output:**
```
[ pTTY ][ user@host ]  colory236] F1  bg=colour236] F2 ...
```

---

## Root Cause

**Tmux version**: 3.0a
**Bug location**: `src/status-format-v4.tmux` line 64

**The Issue**: Commas inside `#[...]` color codes conflict with tmux conditional syntax.

### Broken Syntax:
```tmux
#{?#{==:#{client_session},console-1},#[fg=colour39,bg=colour236] 󰢩 F1 #[default],#[fg=colour240]  F1 #[default]}
                                              ↑ COMMA HERE ↑
```

**Why it breaks:**
- Tmux conditionals use commas as separators: `#{?condition,true-branch,false-branch}`
- Comma inside `#[fg=X,bg=Y]` gets parsed as conditional separator
- Tmux splits incorrectly: `#[fg=colour39` vs `bg=colour236]`
- Result: Partial color codes rendered as visible text

---

## Solution

**Separate color attributes into individual blocks:**

### Before (BROKEN):
```tmux
#[fg=colour39,bg=colour236] 󰢩 F1 #[default]
```

### After (FIXED):
```tmux
#[fg=colour39]#[bg=colour236] 󰢩 F1 #[default]
```

**Rule**: Inside tmux conditionals `#{?...}`, NEVER use comma-separated attributes.

---

## Files Changed

1. **src/status-format-v4.tmux** (line 30, 64)
   - Fixed `status-left` colors
   - Fixed all F1-F10 session tabs in `status-right`

2. **CLAUDE.md** (new section)
   - Added testing instructions
   - Documented common bugs

---

## How to Test

```bash
# 1. Reload config
tmux source-file ~/.vps/sessions/src/tmux.conf

# 2. Check if colors parse correctly
tmux show-options -g status-right | head -c 200
# Should NOT contain "colory" or broken brackets

# 3. Visual check in clean session
tmux new-session -d -s test-visual
tmux attach -t test-visual
clear
# Look at bottom: should see "󰢩 F1  F2..." cleanly

# 4. Switch sessions to verify
# Ctrl+F2, Ctrl+F3, etc. - check for glitches
```

---

## Verification Checklist

- [ ] No "colory" text visible in status bar
- [ ] No broken `]` brackets showing as text
- [ ] F-key labels display cleanly (F1-F12)
- [ ] Icons render correctly (󰢩  )
- [ ] Switching sessions doesn't cause artifacts
- [ ] `tmux show-options -g status-right` shows clean syntax

---

## Prevention

**Before committing status bar changes:**

1. **Visual inspection**: Look for commas in `#[...]` blocks inside conditionals
2. **Syntax check**: `tmux show-options -g status-right | grep "colory"`
3. **Live test**: Create clean session and switch between consoles
4. **Reference**: See `CLAUDE.md` "Status Bar Testing (CRITICAL)" section

---

## Technical Details

### Tmux Conditional Parsing

```tmux
#{?condition,true-branch,false-branch}
          ↑          ↑
       comma 1   comma 2
```

If `true-branch` contains a comma, tmux sees THREE parts instead of two:
```tmux
#{?condition,#[fg=X,bg=Y],else}
                   ↑
            treated as separator!
```

### Solution Patterns

**Pattern 1: Separate blocks** (RECOMMENDED)
```tmux
#[fg=colour39]#[bg=colour236]#[bold]
```

**Pattern 2: Use bg= after conditional** (if possible)
```tmux
#{?condition,#[fg=colour39],#[fg=colour240]} #[bg=colour236]
```

**Pattern 3: Avoid conditionals** (least flexible)
```tmux
# Use static format where possible
```

---

## Related Issues

- **lesson-01-status-bar-flickering.md**: External scripts cause flicker
- **F12-ISSUES-LOG.md**: F12 help display problems
- **SPEC.md**: Status bar design specification

---

## Impact

**Before fix:**
- Users reported "strange characters" in status bar
- Professionalism impact: UI looks broken
- Harder to identify active session

**After fix:**
- Clean, professional status bar display
- Icons render correctly
- Active session clearly highlighted (cyan background)

---

## Lessons Learned

1. **Commas are dangerous** in tmux conditionals
2. **Always test** status bar changes in clean session
3. **Tmux version matters**: 3.0a parsing differs from 3.3+
4. **Visual inspection** catches syntax errors faster than manual testing
5. **Document the "why"** - this bug is non-obvious

---

**Status**: ✅ Fixed in v0.2 (2025-10-12)
**Committed**: src/status-format-v4.tmux, CLAUDE.md
**Tested**: Manual verification in console-1 through console-5
