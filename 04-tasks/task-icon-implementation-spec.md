# Task Specification: Status Bar Icon Implementation

**Task ID**: PTTY-001
**Type**: Bug Fix + Feature Implementation
**Priority**: High
**Complexity**: Medium
**Estimated Time**: 2-3 hours

---

## 📋 EXECUTIVE SUMMARY

**Current State**: Status bar displays F-key labels correctly but missing icons for inactive/suspended terminals and special functions (F11, F12).

**Target State**: All F-key tabs display with proper icons according to their state (active/available/suspended/special).

**Business Impact**: Professional appearance, better visual feedback, clearer state indication.

---

## 1. BUSINESS REQUIREMENTS

### 1.1 Problem Statement

**What user sees NOW:**
```
[ 󰢩 pTTY ][ 󰀉 user@host ]  󰢩 F1   F2   F3  ...   F11   F12
                              ^     ^^   ^^       ^^     ^^
                           active  missing icons!
```

**What user SHOULD see:**
```
[ 󰢩 pTTY ][ 󰀉 user@host ]  󰢩 F1  󰢩 F2   F6   F7   F11   F12
                              ^     ^    ^    ^    ^      ^
                           active avail susp susp mgr   help
```

### 1.2 Requirements

**R1 - Icon Display**: All F1-F12 tabs MUST show icons
**R2 - Icon States**: Icons MUST reflect session state:
- Active session (e.g., F1 if you're on console-1): `󰢩` (console_network, f08a9) - CYAN
- Available session (created but idle): `󰱠` (console_network_outline, f0c60) - WHITE
- Suspended session (not created): `󰲝` (network_outline, f0c9d) - DARK GRAY
- Manager (F11): `󱫋` (network_pos, f1acb) - WHITE
- Help (F12): `󰲊` (help_network_outline, f0c8a) - WHITE

**R3 - Visual Consistency**: Icons MUST match SPEC.md section "Icon Reference" (lines 185-196)

**R4 - No Regression**: Fix MUST NOT break existing color parsing (no commas in conditionals)

---

## 2. TECHNICAL SPECIFICATION

### 2.1 Current Implementation Analysis

**File**: `src/status-format-v4.tmux` (line 64)

**Current code structure**:
```tmux
#{?#{==:#{client_session},console-1},
  #[fg=colour39]#[bg=colour236] 󰢩 F1 #[default],   ← ACTIVE: has icon
  #[fg=colour240]  F1 #[default]                    ← INACTIVE: NO ICON (2 spaces)
}
```

**Problem**: Inactive branch has `  F1` (two spaces) instead of ` F1` (icon + space)

### 2.2 Icon Source Data

**Icons defined in**: `src/theme-config.sh`

**Current variables** (lines 22-30):
```bash
export ICON_SESSION_ACTIVE="󰢩"      # f08a9 - console_network
export ICON_SESSION_AVAILABLE="󰢩"  # f08a9 - console_network
export ICON_SESSION_SUSPENDED=""   # f0c9d - network_outline
export ICON_SESSION_CRASHED=""     # f015b - close_network
export ICON_MANAGER=""             # f1acb - network_pos
export ICON_HELP=""                # f06f5 - help_network
```

**Issue**: Variables are EMPTY (no actual icons, just empty strings)

### 2.3 Root Cause

**Why icons are missing:**

1. `theme-config.sh` variables are EMPTY strings (not populated)
2. `status-format-v4.tmux` uses hardcoded spaces instead of icon variables
3. F11/F12 have no icons in status-right definition

### 2.4 Proposed Solution

**Step 1: Fix theme-config.sh icons**
- Copy actual icon glyphs from SPEC.md
- Populate all ICON_* variables with real Unicode characters

**Step 2: Update status-format-v4.tmux**
- Replace `  F1` with ` F1` (network_outline icon)
- Add icons to F11 `` and F12 ``
- Maintain separate `#[fg=X]#[bg=Y]` blocks (no commas!)

**Step 3: Verify Unicode rendering**
- Ensure terminal supports Nerd Fonts
- Test icon display in clean tmux session

---

## 3. ARCHITECTURE & IMPLEMENTATION PLAN

### 3.1 Architecture Decisions

**AD1 - Hardcode icons in tmux config** (not bash variables)
- **Rationale**: tmux.conf loaded once, no runtime overhead
- **Alternative rejected**: Sourcing bash variables causes flicker
- **Decision**: Copy icon glyphs directly into status-format-v4.tmux

**AD2 - Single source of truth: SPEC.md**
- **Rationale**: Icons defined in SPEC.md, copy from there
- **Alternative rejected**: Generating from theme-config.sh (unnecessary complexity)
- **Decision**: Manual copy-paste, verify with visual inspection

**AD3 - Separate color blocks** (already implemented)
- **Rationale**: Commas break tmux conditionals (lesson-02)
- **Implementation**: Use `#[fg=X]#[bg=Y]` not `#[fg=X,bg=Y]`

### 3.2 Implementation Steps

#### Phase 1: Populate theme-config.sh (OPTIONAL - for future scripts)
```bash
# Line 25: ICON_SESSION_SUSPENDED
export ICON_SESSION_SUSPENDED=""  # Unicode f0c9d

# Line 29: ICON_MANAGER
export ICON_MANAGER=""            # Unicode f1acb

# Line 30: ICON_HELP
export ICON_HELP=""               # Unicode f06f5
```

#### Phase 2: Update status-format-v4.tmux
**Line 64 changes**:

**BEFORE** (broken):
```tmux
,#[fg=colour240]  F1 #[default]
              ↑↑ two spaces
```

**AFTER** (fixed):
```tmux
,#[fg=colour240]  F1 #[default]
              ↑ network_outline icon
```

**Apply to**: All F1-F10 inactive branches

**F11 & F12 additions**:
```tmux
# Current (no icons):
 #[fg=colour255]  F11 #[default]  #[fg=colour255]  F12 #[default]

# Fixed (with icons):
 #[fg=colour255]  F11 #[default]  #[fg=colour255]  F12 #[default]
              ↑ network_pos           ↑ help_network
```

#### Phase 3: Test & Verify
1. Visual inspection in clean tmux session
2. Run `tests/test-status-bar.sh` (after updating expectations)
3. Docker test for clean environment
4. Document in runbook

---

## 4. TESTING STRATEGY

### 4.1 Update Test Expectations

**File**: `tests/test-status-bar.sh`

**Current expectations** (lines 58-88):
```bash
# Test 1: Status bar appears EXACTLY ONCE
if [ "$f1_count" -ne 1 ] || [ "$f7_count" -ne 1 ]; then
    # FAIL
fi
```

**New expectations**:
```bash
# Test 1: Icon count verification
# Expected: 10 console icons + 2 special (F11/F12) = 12 total

# Test 2: Icon type verification
# Active icons: 󰢩 (console_network) - expect 1 (current session)
# Suspended icons:  (network_outline) - expect 9 (other sessions)
# Special icons:  (manager) +  (help) - expect 2

# Test 3: No missing icons
# FAIL if any F-key has double-space instead of icon
```

### 4.2 Docker Test Plan

**Environment**: `tests/docker/`

**Test scenario**:
1. Deploy fresh pTTY in Docker container
2. Verify Nerd Fonts rendering
3. Switch between consoles (F1-F5)
4. Check suspended console display (F6-F10)
5. Verify F11/F12 icons

**Expected results**:
- All icons render correctly
- No broken UTF-8 characters
- No color parsing errors
- Status bar updates on session switch

### 4.3 Manual Test Checklist

- [ ] Icons visible in all F1-F10 tabs
- [ ] Active session has cyan `󰢩`
- [ ] Suspended sessions have gray ``
- [ ] F11 shows `` icon
- [ ] F12 shows `` icon
- [ ] No "colory" or broken brackets
- [ ] Switching sessions updates active icon correctly

---

## 5. ACCEPTANCE CRITERIA

### 5.1 Functional Requirements

**AC1**: All F1-F12 tabs display icons (no empty spaces)
**AC2**: Active session icon is `󰢩` in cyan color
**AC3**: Suspended session icons are `` in dark gray
**AC4**: F11 displays `` (manager icon)
**AC5**: F12 displays `` (help icon)

### 5.2 Non-Functional Requirements

**AC6**: No visual flicker when switching sessions
**AC7**: Icons render correctly in terminals with Nerd Fonts
**AC8**: Status bar updates within 100ms of session switch
**AC9**: No regression in color parsing (no "colory" errors)

### 5.3 Testing Requirements

**AC10**: Updated automated tests pass (`test-status-bar.sh`)
**AC11**: Docker test environment validates icon display
**AC12**: Runbook documents the solution (lesson-02 updated)

---

## 6. IMPLEMENTATION RISKS

### 6.1 Risk Assessment

**R1 - UTF-8 encoding issues**
- **Probability**: Low
- **Impact**: High (icons don't render)
- **Mitigation**: Test in Docker with clean UTF-8 locale

**R2 - Tmux version compatibility**
- **Probability**: Medium
- **Impact**: Medium (icons break in old tmux)
- **Mitigation**: Document required tmux >= 3.0a

**R3 - Terminal font missing**
- **Probability**: Low (user already has Nerd Fonts)
- **Impact**: High (boxes/question marks instead of icons)
- **Mitigation**: Add fallback mode (future task)

### 6.2 Rollback Plan

**If icons break:**

1. Revert to previous commit (before icon changes)
2. Status bar will show spaces but remain functional
3. Debug icon encoding issues separately
4. Re-apply fix with corrections

---

## 7. DEFINITION OF DONE

**Code**:
- [ ] `src/theme-config.sh` populated with icon glyphs
- [ ] `src/status-format-v4.tmux` updated with all icons (F1-F12)
- [ ] No commas in color definitions inside conditionals

**Testing**:
- [ ] `tests/test-status-bar.sh` updated and passing
- [ ] Docker test validates icon display
- [ ] Manual verification in clean tmux session

**Documentation**:
- [ ] `03-architecture/techdocs/lesson-02-tmux-color-comma-bug.md` updated (if needed)
- [ ] Git commit with clear description
- [ ] CLAUDE.md testing instructions verified

**Deployment**:
- [ ] Changes committed to main branch
- [ ] CI/CD checks pass (if applicable)
- [ ] Ready for server deployment

---

## 8. STAKEHOLDER APPROVAL REQUIRED

**Business Analyst confirms:**
- [ ] Icon mapping matches SPEC.md exactly
- [ ] All 12 icons accounted for (F1-F10 + F11 + F12)
- [ ] Visual design approved

**Architect confirms:**
- [ ] Solution follows lesson-02 guidelines (no commas)
- [ ] No performance impact (static tmux config)
- [ ] No external script dependencies

**Developer confirms:**
- [ ] Implementation plan is clear
- [ ] All files and line numbers identified
- [ ] Test updates documented

---

## 9. NEXT STEPS

**Upon approval:**

1. **BA/Architect**: Mark task as "approved for implementation"
2. **Developer**: Begin Phase 1 (populate theme-config.sh)
3. **Developer**: Proceed to Phase 2 (update status-format-v4.tmux)
4. **QA**: Update test expectations
5. **QA**: Run Docker tests
6. **DevOps**: Commit and document

---

**Prepared by**: Claude (Business Analyst + Architect)
**Review status**: ⏳ Awaiting stakeholder approval
**Target completion**: Upon approval + 1-2 hours implementation
