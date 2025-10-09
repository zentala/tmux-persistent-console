**Purpose:** Document critical decision to avoid external scripts in tmux status bar due to flickering issues

---

# ADR 005: No External Scripts in tmux Status Bar

**Date:** 2025-10-09
**Status:** Accepted ⚠️ CRITICAL
**Decision Maker:** zentala + Claude Code (learned the hard way)

---

## Context

pTTY displays a persistent status bar showing 10 console states. Initial implementation used external bash scripts to generate status content.

**Problem Discovered:**
- Visible flicker every N seconds
- Status bar "blinks" on updates
- Poor user experience
- Root cause: External script execution + tmux status-interval

**Critical Lesson:**
> **External script + `status-interval > 0` = guaranteed flicker**

---

## Decision

**NEVER use external scripts in tmux status bar. Use ONLY native tmux format strings `#{}` with `status-interval 0`.**

**Correct Implementation:**
```tmux
# ✅ GOOD - No flicker
set -g status-interval 0
set -g status-left '#{USER}@#H'
set -g status-right '#{?client_prefix,PREFIX,} %H:%M'
```

**Wrong Implementation:**
```tmux
# ❌ BAD - Causes flicker
set -g status-interval 5
set -g status-left '#(~/.tmux/scripts/status-left.sh)'
set -g status-right '#(~/.tmux/scripts/status-right.sh)'
```

---

## Root Cause Analysis

**Why does it flicker?**

1. **tmux refresh cycle:**
   - Every `status-interval` seconds, tmux refreshes status bar
   - Runs external script: `#(script.sh)`
   - Waits for script output
   - Replaces status bar content

2. **Visual effect:**
   - During script execution: old content visible
   - After script completes: new content appears
   - Result: visible "blink" every N seconds

3. **Why `status-interval 0` doesn't help:**
   - `status-interval 0` means "refresh only on tmux events"
   - But external scripts still execute on events
   - Still causes flicker (just less frequent)

**The only solution: No external scripts at all.**

---

## Alternatives Considered

### 1. Longer status-interval
**Example:** `set -g status-interval 30`

**Pros:**
- Less frequent flicker

**Cons:**
- ❌ Still flickers (just every 30s instead of 5s)
- ❌ Stale data (console state out of date)
- ❌ Doesn't solve the problem

**Verdict:** Rejected - flicker still exists

---

### 2. Caching in External Script
**Example:** Cache status output for 5s

**Pros:**
- Faster script execution

**Cons:**
- ❌ Still causes flicker (script still runs)
- ❌ Doesn't address root cause
- ❌ Added complexity for no benefit

**Verdict:** Rejected - doesn't fix flicker

---

### 3. Pre-rendered Status Bar
**Example:** Generate static status bar at session start

**Pros:**
- No scripts during runtime

**Cons:**
- ❌ Static content (no updates)
- ❌ Defeats purpose (need live console state)
- ❌ Not acceptable for pTTY

**Verdict:** Rejected - not dynamic

---

### 4. Native tmux Formats ONLY
**Example:** Use `#{session_name}`, `#{window_name}`, etc.

**Pros:**
- ✅ Zero flicker (native tmux)
- ✅ Instant updates
- ✅ No external process overhead

**Cons:**
- ⚠️ Limited to tmux built-in info
- ⚠️ Can't compute custom state (crashed detection)

**Verdict:** ACCEPTED - only solution that works

---

## Rationale

**Why native tmux formats only?**

1. **User Experience:**
   - Zero flicker = professional feel
   - Status bar feels "solid" and stable
   - No visual distractions

2. **Performance:**
   - No external process spawning
   - No script execution overhead
   - Instant updates (tmux-native)

3. **Reliability:**
   - No script failures
   - No race conditions
   - Predictable behavior

4. **Simplicity:**
   - One less moving part
   - Easier to maintain
   - Less code to debug

---

## Consequences

### Positive
- ✅ Zero flicker (perfect UX)
- ✅ Instant updates
- ✅ No external dependencies
- ✅ Simpler implementation
- ✅ Better performance

### Negative
- ⚠️ Limited to tmux built-in variables
- ⚠️ Can't compute custom logic in status bar
- ⚠️ Crashed detection must be done outside status bar

### Workarounds

**For dynamic content (F11 Manager, F12 Help):**
- External scripts are ALLOWED (interactive, not status bar)
- Use gum or bash for rich UIs
- No flicker issue (full-screen takeover)

**For state computation:**
- Compute in background (cache file)
- Status bar reads from cache (not script)
- Example: `#(cat ~/.cache/tmux-console/state.txt)`
- Still causes flicker → use tmux vars instead

---

## Implementation Guidelines

### DO ✅
```tmux
# Native tmux format strings
set -g status-left '#{session_name} '
set -g status-right '#{USER}@#{host} %H:%M'

# Conditional formatting
set -g status-right '#{?client_prefix,#[bg=red],#[bg=green]} PREFIX '

# Session/window info
set -g window-status-format '#I:#W'
set -g window-status-current-format '#[bold]#I:#W'
```

### DON'T ❌
```tmux
# External scripts (causes flicker)
set -g status-left '#(~/.tmux/scripts/status.sh)'
set -g status-right '#(date +%H:%M)'

# Shell commands (same issue)
set -g status-left '#(whoami)@#(hostname)'

# Even with interval 0 (still flickers on events)
set -g status-interval 0
set -g status-left '#(script.sh)'
```

---

## Status Bar Architecture

**Final design for pTTY:**

```tmux
# Pure tmux format strings
set -g status-interval 0  # Only update on tmux events

# Status bar content (native tmux only)
set -g status-left '#{session_name} | '
set -g status-right ' %H:%M'

# Console states (window format)
set -g window-status-format '#I:#{window_name}'
set -g window-status-current-format '#[bold]#I:#{window_name}'
```

**Note:** Console state icons computed at session start, not dynamically.

---

## Exception: Interactive UI Scripts

**External scripts ARE allowed for:**
- ✅ F11 Manager (interactive menu, full-screen takeover)
- ✅ F12 Help (interactive help, full-screen)
- ✅ Safe exit wrapper (interactive prompt)

**Why no flicker?**
- These take over the entire terminal
- Not part of status bar
- User expects interaction (not background updates)

---

## Testing

**To verify no flicker:**
```bash
# 1. Start tmux session
tmux new-session -d -s test

# 2. Set status bar with external script
tmux set -g status-left '#(date +%H:%M:%S)'
tmux set -g status-interval 1

# 3. Attach and watch
tmux attach -t test
# → You WILL see flicker every second

# 4. Change to native format
tmux set -g status-left '%H:%M:%S'
tmux set -g status-interval 0
# → No more flicker!
```

---

## Related Lessons

**See:** [../techdocs/lesson-01-status-bar-flickering.md](../techdocs/lesson-01-status-bar-flickering.md) for complete investigation

**Key takeaway:**
> If you see flicker in tmux status bar, the solution is ALWAYS "remove external scripts", never "optimize the script".

---

## Future Considerations

**For v1.0:**
- Investigate tmux hooks (event-based updates)
- Consider tmux-powerline patterns (if no flicker)

**For v2.0:**
- Custom tmux plugin (C code, no external process)
- Native console state tracking (tmux API)

**But for v0.2:** Native format strings only, no exceptions.

---

## Related Decisions

- **ADR 002:** State caching (needed because status bar can't compute)
- **ADR 003:** Gum UI (allowed because not in status bar)
- **[../../01-vision/principles.md](../../01-vision/principles.md):** Respect User's Time (no flicker)
- **[../../02-planning/specs/STATUS-BAR-SPEC.md](../../02-planning/specs/STATUS-BAR-SPEC.md):** Status bar design

---

## References

- **Technical investigation:** [../techdocs/lesson-01-status-bar-flickering.md](../techdocs/lesson-01-status-bar-flickering.md)
- **tmux man page:** `man tmux` (search for FORMATS section)
- **tmux format strings:** https://man7.org/linux/man-pages/man1/tmux.1.html#FORMATS

---

**⚠️ CRITICAL RULE: External scripts in status bar = guaranteed flicker. Use native tmux formats ONLY.**

---

## Used In

- **[STATUS-BAR-SPEC](../../02-planning/specs/STATUS-BAR-SPEC.md):** Status bar uses ONLY native tmux formats (no scripts)
- **[MANAGER-SPEC](../../02-planning/specs/MANAGER-SPEC.md):** Exception - Manager can use external scripts (interactive UI)

## Affects Tasks

- **[Task 001](../../04-tasks/001-refactor-state-management.md):** State module cannot be called from status bar directly
- **[Task 002](../../04-tasks/002-refactor-ui-components.md):** UI components CAN use external scripts (not status bar)

## Related Specs

- [STATUS-BAR-SPEC.md](../../02-planning/specs/STATUS-BAR-SPEC.md) - Must follow this rule (no external scripts)
- [MANAGER-SPEC.md](../../02-planning/specs/MANAGER-SPEC.md) - Exception (interactive takeover, not status bar)
