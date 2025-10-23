# v0.2 Enhanced Specification

**Version:** 0.2 Enhanced
**Date:** 2025-10-23
**Status:** Draft - Architecture review
**Type:** Refactoring + New Features (MERGE of v0.2 plan + user ideas)

---

## 📋 Executive Summary

**What changed from original v0.2 plan:**
- ✅ **State file** instead of in-memory cache (better for multi-process tmux)
- ✅ **Background observer** instead of on-demand polling (no flicker)
- ✅ **Per-tab customization** (colors, icons, backgrounds)
- ✅ **Grouping 3+ suspended** (visual optimization)
- ❌ **Removed SQLite** (overkill, JSON is enough)
- ❌ **Removed reactive libs** (not needed for bash)

---

## 🎯 Goals

### Primary Goals (from v0.2 original):
1. **Modular architecture** - Extract state, UI, actions into separate modules
2. **Testing framework** - Unit tests with bats
3. **Code standards** - Namespace pattern, function docs

### New Goals (user enhancements):
4. **Persistent state** - File-based state shared across all tmux processes
5. **Background observer** - Automatic state updates without manual refresh
6. **Per-tab customization** - Configure colors/icons/backgrounds per F-key
7. **Smart grouping** - Collapse 3+ consecutive suspended tabs (F6-F10 → 󰲝 F6-10)

---

## 🏗️ Architecture

### State Management - File-Based Approach

**File location:** `~/.ptty/state.json`

**Format:**
```json
{
  "sessions": {
    "1": "active",
    "2": "available",
    "3": "available",
    "4": "available",
    "5": "available",
    "6": "suspended",
    "7": "suspended",
    "8": "suspended",
    "9": "suspended",
    "10": "suspended"
  },
  "current": "1",
  "crashed": [],
  "last_update": 1729653600
}
```

**Why file instead of memory cache?**
- tmux spawns multiple bash processes (each session = separate process)
- In-memory cache = each process has its own copy = inconsistency
- File = single source of truth for ALL processes

---

### Background Observer Process

**File:** `src/core/observer.sh`

**Responsibility:** Watch tmux sessions and update state file automatically

**Implementation:**
```bash
#!/bin/bash
# Background observer - runs in detached tmux session

STATE_FILE="$HOME/.ptty/state.json"

while true; do
    # Get current tmux sessions
    current_sessions=$(tmux ls -F '#{session_name}' 2>/dev/null)

    # Compare with previous state
    if [[ "$current_sessions" != "$prev_sessions" ]]; then
        # Something changed - update state file
        update_state_file "$current_sessions"
        prev_sessions="$current_sessions"
    fi

    sleep 2  # Check every 2 seconds
done
```

**Startup:** Observer starts automatically with first tmux session

**Benefits:**
- Status bar NEVER queries tmux directly (just reads file)
- No flicker (file read is instant)
- Always up-to-date (observer runs continuously)

---

### How Status Bar Knows File Changed?

**Simple approach:** Read file on every status bar generation

**Why this works:**
- Status bar only regenerates on session switch (no auto-refresh)
- Reading JSON is fast (~2ms with jq)
- Max file reads = few times per minute (acceptable)

**Implementation:**
```bash
# Status bar generator
get_session_state() {
    local session_num=$1
    jq -r ".sessions.\"$session_num\"" "$STATE_FILE"
}
```

**No need for:**
- ❌ Timestamp checking (over-engineering)
- ❌ inotify (adds dependency)
- ❌ Polling (unnecessary complexity)

---

### Per-Tab Customization

**Config file:** `~/.ptty/tabs.json`

**Format:**
```json
{
  "defaults": {
    "active": {
      "icon": "󰢩",  // f08a9 console_network
      "fg": "colour39",
      "bg": "colour236"
    },
    "available": {
      "icon": "󰱠",  // f0c60 console_network_outline
      "fg": "colour255",
      "bg": ""
    },
    "suspended": {
      "icon": "󰲝",  // f0c9d network_outline
      "fg": "colour240",
      "bg": ""
    }
  },
  "tabs": {
    "1": {
      "label": "AI Dev",
      "active": { "fg": "colour39", "bg": "colour236" }
    },
    "10": {
      "label": "Stats",
      "active": { "icon": "󰄬", "fg": "colour46", "bg": "colour237" },
      "available": { "icon": "󰄬", "fg": "colour244", "bg": "" }
    }
  }
}
```

**Scope for v0.2:**
- ✅ Custom colors per tab (fg, bg)
- ✅ Custom icons per tab
- ✅ Custom labels per tab
- ❌ NO hover effects (not possible in tmux)
- ❌ NO animations (not in scope)

**Usage:**
```bash
# Status bar reads per-tab config
get_tab_config() {
    local tab=$1
    local state=$2

    # Try tab-specific config first
    local config=$(jq -r ".tabs.\"$tab\".$state // .defaults.$state" "$TABS_CONFIG")
    echo "$config"
}
```

---

### Smart Grouping (3+ Suspended)

**Rule:** If 3 or more consecutive tabs are suspended, group them

**Examples:**
- `F6 F7 F8` (3 suspended) → `󰲝 F6-8`
- `F6 F7` (2 suspended) → `󰲝 F6 󰲝 F7` (no grouping)
- `F6 F7 F8 F9 F10` (5 suspended) → `󰲝 F6-10`

**Implementation:**
```bash
group_suspended() {
    local tabs=("$@")
    local grouped=()
    local range_start=""
    local range_end=""
    local count=0

    for tab in "${tabs[@]}"; do
        local state=$(get_session_state "$tab")

        if [[ "$state" == "suspended" ]]; then
            if [[ -z "$range_start" ]]; then
                range_start=$tab
            fi
            range_end=$tab
            ((count++))
        else
            if [[ $count -ge 3 ]]; then
                # Group the range
                grouped+=("󰲝 F${range_start}-${range_end}")
            else
                # Add individually
                for i in $(seq $range_start $range_end); do
                    grouped+=("󰲝 F$i")
                done
            fi
            # Reset and add current
            range_start=""
            count=0
            grouped+=("$(render_tab $tab)")
        fi
    done

    echo "${grouped[@]}"
}
```

---

## 📁 File Structure

```
~/.ptty/
├── state.json           # Session states (updated by observer)
├── tabs.json            # Per-tab customization config
└── observer.pid         # PID of background observer

src/
├── core/
│   ├── state.sh         # State API (read from state.json)
│   ├── observer.sh      # Background observer process
│   └── config.sh        # Config loader (tabs.json)
├── ui/
│   ├── status-bar.sh    # Status bar generator
│   ├── components/      # Reusable UI elements
│   └── theme.sh         # Theme/color management
├── actions/
│   └── session.sh       # Session actions (create, kill, restart)
└── utils/
    └── logging.sh       # Logging utilities
```

---

## 🔄 Workflow

### 1. Observer Updates State
```
tmux event → observer detects → update state.json
```

### 2. Status Bar Reads State
```
User switches session → tmux calls status-bar.sh → read state.json → render
```

### 3. No Flicker Because:
- ✅ No external script polling (`status-interval 0`)
- ✅ File read is instant (~2ms)
- ✅ Observer runs in background (doesn't block)

---

## 📋 Implementation Tasks

### Phase 1: State Management (Week 1)
- [ ] Create `src/core/state.sh` with file-based API
- [ ] Create state.json format
- [ ] Write state reading functions
- [ ] Unit tests for state module

### Phase 2: Observer (Week 1)
- [ ] Create `src/core/observer.sh`
- [ ] Implement tmux session monitoring
- [ ] Auto-start observer with first session
- [ ] Handle observer restart on crash

### Phase 3: Per-Tab Config (Week 2)
- [ ] Create `tabs.json` format
- [ ] Implement config loader
- [ ] Update status bar to use per-tab config
- [ ] Add default fallbacks

### Phase 4: Smart Grouping (Week 2)
- [ ] Implement grouping algorithm (3+ rule)
- [ ] Update status bar generator
- [ ] Test edge cases (F1 active, F2-10 suspended)

### Phase 5: UI Refactoring (Week 3)
- [ ] Extract status bar to `src/ui/status-bar.sh`
- [ ] Create reusable components
- [ ] Update Manager to use state API
- [ ] Update Help to use theme system

### Phase 6: Testing (Week 3)
- [ ] Unit tests (bats framework)
- [ ] Integration tests
- [ ] Docker environment test
- [ ] Manual QA checklist

---

## 🧪 Testing Strategy

### Unit Tests
- `tests/unit/test-state.sh` - State file reading/writing
- `tests/unit/test-observer.sh` - Observer monitoring logic
- `tests/unit/test-grouping.sh` - Grouping algorithm
- `tests/unit/test-config.sh` - Config loading

### Integration Tests
- Observer updates state file correctly
- Status bar reflects state changes
- Per-tab config applies correctly
- Grouping works with real sessions

### Manual Tests
- Create/destroy sessions, verify state updates
- Customize tab colors, verify rendering
- Test grouping with various suspended ranges

---

## 📊 Performance

**Before (v0.1):**
- Status bar: hardcoded tmux conditionals
- No state detection (all non-active = suspended)
- No flicker (good!) but limited functionality

**After (v0.2 Enhanced):**
- Status bar: reads state.json (~2ms)
- Observer: updates state every 2s (background)
- Per-tab config: reads tabs.json (~2ms)
- Total overhead: ~4ms per status bar render (acceptable!)

**No flicker because:**
- File reads are instant
- No external script polling
- Observer runs independently

---

## 🎯 Acceptance Criteria

### Core Features
- [ ] State file tracks all 10 sessions + manager + help
- [ ] Observer automatically updates state on session changes
- [ ] Status bar shows correct icons (active/available/suspended)
- [ ] Per-tab customization works (colors, icons, labels)
- [ ] Grouping works (3+ consecutive suspended)

### Non-Functional
- [ ] No visual flicker
- [ ] State updates within 2 seconds
- [ ] Modular code (namespace pattern)
- [ ] Unit tests pass (80%+ coverage)
- [ ] Documentation complete

---

## 🔗 Related Documents

- `04-tasks/001-refactor-state-management.md` - Original v0.2 state plan
- `02-planning/SPEC.md` - Overall specification
- `docs/ICONS-NETWORK-SET.md` - Icon reference

---

## ❓ Open Questions

1. **Observer startup:** Auto-start with tmux or manual `ptty observer start`?
   - Recommendation: Auto-start (user doesn't need to think about it)

2. **Config file location:** `~/.ptty/` or `~/.config/ptty/`?
   - Recommendation: `~/.ptty/` (simpler, already used by safe-exit)

3. **Error handling:** What if state.json is corrupted?
   - Recommendation: Fallback to defaults, log error

4. **Observer restart:** How to detect if observer crashed?
   - Recommendation: PID file + health check on status bar render

---

## 🚀 Migration from v0.1

### Breaking Changes
- None! v0.2 is backward compatible

### Upgrade Path
1. Install v0.2
2. Observer starts automatically
3. State file generated on first run
4. Tabs.json created with defaults (user can customize later)

---

**This spec combines best of v0.2 original plan + user enhancement ideas.**

**Next step:** Review and approve, then start implementation Phase 1.
