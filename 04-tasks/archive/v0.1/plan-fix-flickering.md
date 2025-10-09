# Action Plan: Fix Status Bar Flickering & Implement New Design

**Created:** 2025-10-07
**Tech Lead:** Claude Code
**For:** Mid-level developers
**Status:** 🔴 CRITICAL - Status bar flickers and disappears

---

## 🎯 Executive Summary

**Problem:** Status bar flickers/blinks every 5 seconds and disappears when scrolling content.

**Root Causes:**
1. `status-interval 5` = script runs every 5 seconds → causes blink
2. Script does 7× `tmux has-session` + 7× `tmux list-panes` = SLOW
3. Slow script execution = visible delay = flicker
4. Old design doesn't match TODO.md / ICONS.md requirements

**Solution:** Redesign status bar with:
- Static tmux format (no external script calls)
- New icon design from ICONS.md
- Only dynamic parts refresh (not entire bar)

**Timeline:** 3-4 hours
**Priority:** 🔴 CRITICAL (blocks user experience)

---

## 📋 Current vs Target Design

### Current (Broken)
```
🖥️ CONSOLE@contabo   F1  F2  F3 ... F7  󰒓 F11  F12
```
- Refreshes ENTIRE bar every 5 seconds
- External script with 14+ tmux commands
- Flickers visibly
- Not matching spec

### Target (Per ICONS.md + TODO.md)
```
[ pTTY ] [ user@host ]   F1  F2  F3 ... F7  [F8-10]  󰒓 F11 Manager   F12 Help
```
- App name: **pTTY** (PersistentTTY short form)
- User & hostname separated
- Tabs with shadows
- F8-10 suspended terminals (configurable)
- Static format = NO FLICKER

---

## 🔬 Root Cause Analysis

### Why Flickering Happens

1. **External Script Called Too Often**
   ```bash
   # tmux.conf
   set -g status-interval 5
   set -g status-left '#(~/.vps/sessions/src/status-bar.sh ...)'
   ```
   Every 5 seconds → script runs → bar rewrites → visible blink

2. **Script is Slow (14+ tmux commands)**
   ```bash
   # status-bar.sh does:
   for i in {1..7}; do
       tmux has-session -t console-$i        # 7 calls
       tmux list-panes -t console-$i         # 7 calls
   done
   ```
   Total: **14+ process spawns** every 5 seconds!

3. **Entire Bar Rebuilds (not just changed parts)**
   Old approach: regenerate full HTML-like string each time
   Better: use tmux conditionals (`#{}`) for dynamic parts only

### Performance Measurement

```bash
# Measure current script execution time
time ~/.vps/sessions/src/status-bar.sh "console-1" "150"

# Expected: 50-200ms (TOO SLOW for 5s interval)
# Target: <10ms OR static format
```

---

## 🛠️ Solution Architecture

### Strategy: Hybrid Static + Dynamic

**Static parts** (never change):
- App name: `pTTY`
- F-key labels: `F1`, `F2`, ..., `F12`
- Icons: ``, `󰒓`, ``

**Dynamic parts** (use tmux native conditionals):
- Which session is active: `#{==:#{session_name},console-1}`
- Session colors: cyan for active, gray for inactive
- User/hostname: `#{USER}@#{host_short}`

### New tmux.conf Format

```tmux
# Static header - no script!
set -g status-left "#[fg=colour39,bg=colour236,bold]  pTTY #[default] #[fg=colour244]#{USER}@#H#[default]  "

# Dynamic session tabs - native tmux conditionals
set -g status-left-length 300
set -g window-status-format "#[fg=colour244] #{?#{==:#{window_index},1}, F1,}#{?#{==:#{window_index},2}, F2,}... #[default]"
set -g window-status-current-format "#[fg=colour39,bg=colour236,bold] #{?#{==:#{window_index},1}, F1,}... #[default]"
```

**Key insight:** Use tmux's **NATIVE** conditional format `#{?condition,true,false}` instead of bash script!

---

## 📝 Implementation Plan

### Phase 1: Research & Prototyping (30 min)

**Task 1.1:** Study tmux format strings
```bash
man tmux | grep -A 50 "FORMATS"
# Understand: #{}, #{?}, #{==:}
```

**Task 1.2:** Create prototype static format
```bash
# Test in tmux directly
tmux set -g status-left "#[fg=colour39]  pTTY #[default] #[fg=colour244]#{USER}@#H"
```

**Task 1.3:** Verify no flicker
```bash
# Watch for 30 seconds
watch -n 1 'tmux capture-pane -p | tail -1'
# Should be STABLE (no changes)
```

---

### Phase 2: Implement New Design (60 min)

**Task 2.1:** Create new `status-format-v3.tmux`
```tmux
# src/status-format-v3.tmux

# Disable external script
set -g status-interval 0  # Turn off auto-refresh

# Header: [ pTTY ] [ user@host ]
set -g status-left-length 300
set -g status-left '
#[fg=colour39,bg=colour236,bold]  pTTY #[fg=colour236,bg=colour234]#[default]
#[fg=colour244,bg=colour234] #{USER}@#H #[default]
'

# Console tabs F1-F7 (using window-status)
# Active session: cyan + shadow
# Inactive: gray

set -g window-status-format '#[fg=colour244,bg=colour234]  #{window_index} #[default]'
set -g window-status-current-format '#[fg=colour39,bg=colour236,bold]  #{window_index} #[fg=colour236,bg=colour234]#[default]'

# F11, F12 at right side
set -g status-right-length 100
set -g status-right '
#[fg=colour244,bg=colour234] 󰒓 F11 Manager #[default]
#[fg=colour244,bg=colour234]  F12 Help #[default]
'
```

**Task 2.2:** Test new format
```bash
# Backup current config
cp ~/.vps/sessions/src/tmux.conf ~/.vps/sessions/src/tmux.conf.backup

# Load v3 format
tmux source-file ~/.vps/sessions/src/status-format-v3.tmux

# Visual inspection
# - Should see: [ pTTY ] [ user@host ]  1  2  3 ...  󰒓 F11  F12
# - Should NOT flicker
```

**Task 2.3:** Measure stability
```bash
# Run for 1 minute, count changes
for i in {1..60}; do
    tmux capture-pane -p | tail -1 >> /tmp/status-log.txt
    sleep 1
done

# All lines should be IDENTICAL
uniq /tmp/status-log.txt | wc -l  # Should be 1 (no changes)
```

---

### Phase 3: Fix Session Indicator Logic (60 min)

**Challenge:** How to show F1-F7 without external script?

**Solution:** Use tmux windows as visual tabs

**Task 3.1:** Rethink architecture
```
Current: 7 tmux SESSIONS (console-1 ... console-7)
Problem: Can't enumerate all sessions in status-left

Proposal: Use WINDOWS within single session?
- Session: "console"
- Windows: 1=F1, 2=F2, ..., 7=F7
- Benefit: window-status-format works natively!
```

**Task 3.2:** Prototype window-based approach
```bash
# Create single session with 7 windows
tmux new-session -d -s console -n "F1"
tmux new-window -t console:2 -n "F2"
tmux new-window -t console:3 -n "F3"
...
tmux new-window -t console:7 -n "F7"

# Navigate with Ctrl+F1-F7
bind-key -n C-F1 select-window -t :1
bind-key -n C-F2 select-window -t :2
...
```

**Task 3.3:** Test window-status rendering
```tmux
# Should automatically highlight active window!
set -g window-status-format '#[fg=colour244]  F#{window_index} #[default]'
set -g window-status-current-format '#[fg=colour39,bg=colour236,bold]  F#{window_index} #[default]'
```

**Decision Point:**
🤔 **Should we migrate from 7 sessions to 7 windows?**

**Pros:**
- Native tmux highlighting (no script needed!)
- No flickering (pure tmux formats)
- Simpler keybindings

**Cons:**
- Major architecture change
- Users may have existing sessions

**Recommendation:** Start with static header + keep 7 sessions for now.
Future: Consider migration to windows in v4.0.

---

### Phase 4: Add Shadows & Polish (30 min)

**Task 4.1:** Implement tab shadows (per ICONS.md)
```tmux
# Shadow effect: lighter bg + border transition
set -g window-status-current-format '
#[fg=colour236,bg=colour234]#[default]
#[fg=colour39,bg=colour236,bold]  F#{window_index} #[default]
#[fg=colour236,bg=colour234]#[default]
'
```

**Task 4.2:** Add responsive width logic
```bash
# If terminal < 120 cols: hide names, show only numbers
# Use tmux conditionals:
#{?#{<:#{client_width},120},short,long}
```

**Task 4.3:** Icon consistency
```bash
# Verify all icons from ICONS.md
# Terminal:
# Manager: 󰒓
# Help:
# App:
```

---

### Phase 5: Testing (45 min)

**Task 5.1:** Create flicker detection test
```bash
# tests/test-no-flicker.sh

#!/bin/bash
echo "Monitoring status bar for 30 seconds..."
echo "Checking for unwanted changes..."

for i in {1..30}; do
    capture=$(tmux capture-pane -p | tail -1)
    echo "$capture" >> /tmp/flicker-test.log
    sleep 1
done

# Count unique lines
unique_count=$(sort /tmp/flicker-test.log | uniq | wc -l)

if [ "$unique_count" -eq 1 ]; then
    echo "✅ PASS: Status bar stable (no flicker)"
    exit 0
elif [ "$unique_count" -le 3 ]; then
    echo "⚠️  WARNING: Minor changes detected ($unique_count variants)"
    exit 0
else
    echo "❌ FAIL: Status bar flickering! ($unique_count changes)"
    echo "First variant:"
    head -1 /tmp/flicker-test.log
    echo "Last variant:"
    tail -1 /tmp/flicker-test.log
    exit 1
fi
```

**Task 5.2:** Run all existing tests
```bash
~/.vps/sessions/tests/run-all-tests.sh
# All must pass!
```

**Task 5.3:** User acceptance test
```bash
# SSH to server
ssh zentala@164.68.104.13

# Attach to console
tmux attach -t console-1

# Test scenarios:
# 1. Watch status bar for 1 minute - should NOT flicker
# 2. Scroll long output (generate 100 lines) - bar stays at bottom
# 3. Switch sessions F1→F2→F3 - active tab changes color
# 4. Verify icons render correctly
# 5. Resize terminal (80 cols, 200 cols) - responsive layout
```

---

## 🧪 Acceptance Criteria

### Must Have ✅

- [ ] Status bar does NOT flicker/blink during normal use
- [ ] Status bar stays pinned at bottom when scrolling
- [ ] Active session highlighted in cyan
- [ ] All icons from ICONS.md present and rendering
- [ ] Format matches: `[ pTTY ] [ user@host ]  F1 ... F7  󰒓 F11  F12`
- [ ] Responsive: <120 cols = compact mode
- [ ] All existing tests pass
- [ ] No external script calls in status-left

### Nice to Have 🎁

- [ ] Shadows under active tab (subtle depth effect)
- [ ] F8-F10 suspended terminals indicator
- [ ] Smooth color transitions
- [ ] Username icon ()
- [ ] Hostname icon ()

---

## 📊 Success Metrics

### Performance

- **Current:** 14+ tmux process spawns every 5 seconds
- **Target:** 0 external processes (pure tmux formats)

- **Current:** 50-200ms script execution time
- **Target:** <1ms (no script = instant)

### User Experience

- **Current:** Visible flicker every 5 seconds → user reports as "migający"
- **Target:** Completely stable, no visible changes unless user switches session

### Code Quality

- **Current:** 100+ line bash script with loops, conditionals, tmux calls
- **Target:** 20-30 lines of declarative tmux format strings

---

## 🚨 Risk Assessment

### High Risk

1. **Architecture change (sessions → windows)**
   - Mitigation: Phase 3 optional, keep current sessions
   - Fallback: Static header + existing 7 sessions

2. **Icon rendering on different terminals**
   - Mitigation: Require Nerd Fonts (document in README)
   - Fallback: ASCII-only mode (future feature)

### Medium Risk

1. **Tmux version compatibility**
   - Mitigation: Test on tmux 2.9, 3.0, 3.3
   - Fallback: Version detection + conditional formats

2. **Breaking existing user configs**
   - Mitigation: Keep old script as `status-bar-legacy.sh`
   - Migration guide in CHANGELOG

### Low Risk

1. **Color rendering on different terminals**
   - Mitigation: Use standard 256-color palette
   - Test on iTerm2, Terminal.app, xterm

---

## 📚 Technical References

### Tmux Format Strings

```bash
# Variables
#{session_name}         # Current session name
#{window_index}         # Window number
#{client_width}         # Terminal width
#{host_short}           # Hostname (short)
#{USER}                 # Current user

# Conditionals
#{?condition,true,false}             # If-then-else
#{==:#{var},value}                   # Equality check
#{<:#{client_width},120}             # Less than comparison

# Colors
#[fg=colour39]          # Foreground cyan
#[bg=colour236]         # Background dark gray
#[bold]                 # Bold text
#[default]              # Reset to default
```

### Key Tmux Options

```tmux
set -g status on                    # Enable status bar
set -g status-position bottom       # Pin to bottom
set -g status-interval 0            # Disable auto-refresh
set -g status-left-length 300       # Max length for left side
set -g status-left "format"         # Left side content
set -g status-right "format"        # Right side content
set -g window-status-format         # Inactive window/tab
set -g window-status-current-format # Active window/tab
```

### Color Palette (256-color)

```
colour234  # Very dark gray (background)
colour236  # Dark gray (raised tab background)
colour240  # Medium gray (disabled elements)
colour244  # Light gray (inactive text)
colour39   # Cyan (active/highlight)
colour255  # White (bright text)
```

---

## 📁 File Structure

### Files to Modify

```
src/
├── tmux.conf                  # MODIFY: status-interval, status-left
├── status-bar.sh              # DEPRECATE: move to status-bar-legacy.sh
└── status-format-v3.tmux      # CREATE: new static format

tests/
├── test-no-flicker.sh         # CREATE: flicker detection
├── test-status-bar.sh         # UPDATE: verify new format
└── run-all-tests.sh           # UPDATE: add flicker test

docs/
├── PLAN-FIX-FLICKERING.md     # THIS FILE
├── CHANGELOG-2025-10-07.md    # UPDATE: document changes
└── MIGRATION-V3.md            # CREATE: upgrade guide
```

### Backup Strategy

```bash
# Before starting
git checkout -b fix/status-bar-flickering
cp src/tmux.conf src/tmux.conf.v2-backup
git add . && git commit -m "WIP: status bar v3 - before changes"

# After each phase
git add . && git commit -m "feat: phase N complete - description"
```

---

## 🎓 Learning Resources for Developers

### Understanding Tmux Status Bar

- **Official docs:** `man tmux` (search for "FORMATS")
- **Examples:** `/usr/share/doc/tmux/examples/` (on Linux)
- **Interactive tool:** `tmux show-options -g` (see current config)

### Debugging Tmux Formats

```bash
# Test format string immediately
tmux set -g status-left "your format here"
tmux refresh-client

# See what variables are available
tmux list-keys -T root | grep status
tmux show-options -g | grep status
```

### Performance Profiling

```bash
# Measure script execution
time ~/.vps/sessions/src/status-bar.sh "console-1" "150"

# Monitor tmux process CPU
top -p $(pgrep tmux)

# Capture tmux internal messages
tmux show-messages
```

---

## 🚀 Deployment Checklist

- [ ] Phase 1 complete (research)
- [ ] Phase 2 complete (static header)
- [ ] Phase 3 decision made (sessions vs windows)
- [ ] Phase 4 complete (shadows + icons)
- [ ] Phase 5 complete (all tests pass)
- [ ] Documentation updated (README, CHANGELOG)
- [ ] User tested on production VPS
- [ ] Rollback plan ready (keep legacy script)
- [ ] Git tagged as `v3.0-no-flicker`

---

## 🤝 Contribution Guidelines

**For developers working on this:**

1. **Read this plan first** - understand the problem
2. **Test before commit** - run `./tests/run-all-tests.sh`
3. **No external scripts in status-left** - use native tmux formats
4. **Keep it simple** - fewer lines = better
5. **Measure performance** - time your changes
6. **Document decisions** - update this file with learnings

**Commit message format:**
```
fix(status-bar): Phase N - description

- What changed
- Why it's better
- Performance impact

Related: PLAN-FIX-FLICKERING.md phase N
```

---

## 📞 Questions & Blockers

**Q: What if we can't eliminate the script entirely?**
A: Make script faster (cache results, avoid tmux calls) or increase `status-interval` to 60s

**Q: How to handle F11/F12 dynamic state?**
A: Use `tmux has-session -t manager` in tmux conditional: `#{?#{==:#{s/manager//:session_name},},offline,online}`

**Q: Should we support ASCII-only mode (no Nerd Fonts)?**
A: V3.0 = Nerd Fonts required. V3.1 = add fallback mode

---

**Document Status:** 🟢 Ready for implementation
**Last Updated:** 2025-10-07
**Next Review:** After Phase 2 completion
