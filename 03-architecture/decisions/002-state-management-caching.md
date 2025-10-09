**Purpose:** Document decision to use 5-second TTL caching for tmux state management

---

# ADR 002: State Management with 5-Second TTL Caching

**Date:** 2025-10-09
**Status:** Accepted
**Decision Maker:** zentala + Claude Code

---

## Context

pTTY needs to display console state in the status bar (active, inactive, crashed). Querying tmux state has performance implications:

**Problem:**
- `tmux list-panes` is relatively expensive (20-50ms per call)
- Status bar updates frequently (every refresh)
- Multiple components need same state data (status bar, F11 manager, F12 help)
- No native caching in bash

**Requirements:**
- Fast status bar updates (<100ms perceived lag)
- Accurate state representation (not too stale)
- Minimal CPU usage
- Simple implementation (bash-compatible)

---

## Decision

**Implement 5-second TTL file-based caching for tmux state queries.**

**Implementation:**
```bash
# State cache file
STATE_CACHE="${HOME}/.cache/tmux-console/state.cache"
STATE_CACHE_TTL=5  # seconds

get_console_state() {
    local cache_age=$(( $(date +%s) - $(stat -c %Y "$STATE_CACHE" 2>/dev/null || echo 0) ))

    if [[ $cache_age -gt $STATE_CACHE_TTL ]]; then
        # Cache expired or missing - refresh
        tmux list-panes -a -F "#{session_name} #{pane_pid}" > "$STATE_CACHE"
    fi

    # Read from cache
    cat "$STATE_CACHE"
}
```

---

## Alternatives Considered

### 1. No Caching (Always Query)
**Pros:**
- Always accurate
- Simple implementation

**Cons:**
- ❌ High CPU usage (50+ tmux queries per minute)
- ❌ Visible lag in status bar updates
- ❌ Not scalable

**Verdict:** Rejected - performance unacceptable

---

### 2. Event-Based Invalidation
**Pros:**
- Most accurate
- Low CPU when idle

**Cons:**
- ❌ Complex implementation (tmux hooks)
- ❌ Race conditions possible
- ❌ Harder to debug

**Verdict:** Rejected - over-engineered for v0.2

---

### 3. 1-Second TTL
**Pros:**
- Very accurate
- Simple

**Cons:**
- ❌ Still many queries (60/minute)
- ❌ Not much better than no cache

**Verdict:** Rejected - insufficient performance gain

---

### 4. 10-Second TTL
**Pros:**
- Even better performance

**Cons:**
- ❌ Too stale (user may see wrong state)
- ❌ Bad UX if console crashes

**Verdict:** Rejected - accuracy trade-off not worth it

---

## Rationale

**Why 5 seconds?**

1. **Performance:**
   - Reduces queries from 60/min (1s) to 12/min (5s)
   - 80% reduction in tmux load
   - Status bar feels instant

2. **Accuracy:**
   - Console state rarely changes faster than 5s
   - Acceptable staleness for UX
   - Critical events (crash) detected within 5s max

3. **Simplicity:**
   - File-based cache (no external dependencies)
   - Simple TTL logic (bash-native)
   - Easy to debug (`cat ~/.cache/tmux-console/state.cache`)

4. **Proven Pattern:**
   - Similar to HTTP cache headers
   - Used in many CLI tools
   - Well-understood behavior

---

## Consequences

### Positive
- ✅ Fast status bar updates
- ✅ Low CPU usage
- ✅ Simple implementation
- ✅ Easy debugging (cache file inspection)
- ✅ No external dependencies

### Negative
- ⚠️ State may be up to 5 seconds stale
- ⚠️ Crash detection delayed up to 5s
- ⚠️ Cache file management needed (cleanup on startup)

### Mitigations
- Cache file in `~/.cache/` (standard location)
- Cleanup script removes old cache on session start
- Manual refresh available via F11 manager
- User can force refresh: `rm ~/.cache/tmux-console/state.cache`

---

## Implementation Notes

**Cache structure:**
```
console-1 12345
console-2 12346
console-3 12347
...
```

**Cache location:**
- `~/.cache/tmux-console/state.cache` (Linux standard)
- Auto-created on first query
- Cleaned up on logout (via trap)

**Edge cases handled:**
- Missing cache file → create on first query
- Stale cache (>5s) → refresh automatically
- Corrupted cache → fallback to direct query

---

## Future Improvements

**For v1.0:**
- Consider event-based invalidation for critical events (console restart)
- Add `--no-cache` flag for debugging
- Metrics on cache hit/miss rates

**For v2.0:**
- Configurable TTL in `~/.ptty.conf`
- Per-component cache (status bar vs F11 manager)
- Cache preloading on session start

---

## Related Decisions

- **ADR 001:** Folder structure (where cache lives)
- **ADR 005:** No external scripts in status bar (why caching matters)
- **[../techdocs/lesson-01-status-bar-flickering.md](../techdocs/lesson-01-status-bar-flickering.md):** Performance investigation

---

## References

- **Implementation:** `src/core/state.sh` (to be created in Task 001)
- **Testing:** `tests/state-caching.bats` (to be created in Task 004)
- **Documentation:** Status bar performance notes

---

**This decision balances performance and accuracy for v0.2. Future versions may optimize further based on real-world usage.**
