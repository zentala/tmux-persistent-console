# pTTY - Product Versioning & Release Plan

**Created:** 2025-10-09
**Purpose:** Define version numbering strategy and release scope for pTTY project
**Owner:** Product Management

---

## 🎯 Version Numbering Strategy ⚠️ CRITICAL RULE

### Format: `vMAJOR.MINOR`

**RULE: Version numbers increment by 0.1 ONLY - NEVER skip versions**

### Correct Version Progression

**Pre-production (v0.x):**
```
v0.1 → v0.2 → v0.3 → v0.4 → v0.5 → v0.6 → v0.7 → v0.8 → v0.9 → v1.0
```

**Production stable (v1.x):**
```
v1.0 → v1.1 → v1.2 → v1.3 → v1.4 → v1.5 → v1.6 → v1.7 → v1.8 → v1.9 → v2.0
```

**Examples:**
- ✅ CORRECT: v0.1 → v0.2 → v0.3
- ✅ CORRECT: v1.2 → v1.3 → v1.4
- ❌ WRONG: v1.2 → v2.0 (must go through v1.3, v1.4... v1.9)
- ❌ WRONG: v0.1 → v1.0 (must go through v0.2, v0.3... v0.9)

### Version Scope

- **v0.x** - Pre-production (alpha/beta), not stable
- **v1.x** - Production stable, backwards compatible
- **v2.x** - Major upgrade with breaking changes

### Special Suffixes (optional)

- **-alpha** - Early testing (e.g., v0.3-alpha)
- **-beta** - Public testing (e.g., v0.9-beta)
- **-rc.N** - Release candidate (e.g., v1.0-rc.1)

---

## 📂 Task Archival Rules

**When version is completed, archive its tasks:**

```
04-tasks/archive/
├── v0.1/                    # Completed tasks from v0.1
│   ├── f11-detach-fix.md
│   └── f12-issues-log.md
├── v0.2/                    # Completed tasks from v0.2
└── v1.0/                    # Completed tasks from v1.0
```

**Rules:**
1. When version released → move all tasks to `04-tasks/archive/v{VERSION}/`
2. Keep version folder structure (easy to browse history)
3. Task files preserve context (what was problem, how solved, why)
4. Helps understand evolution ("what did we fix in v0.1?")

**Current active tasks:** Only tasks for CURRENT version stay in `04-tasks/`

---

## 📦 Release History & Roadmap

### **v0.1 - Prototype** ✅ WDROŻONE (October 2025)

**Status:** Working but monolithic
**Code:** Functional implementation, all features work

**Features:**
- ✅ 7 persistent tmux sessions (F1-F7)
- ✅ Status bar with console indicators
- ✅ F11 Mission Control (Manager)
- ✅ F12 Help reference
- ✅ Safe exit wrapper (detach protection)
- ✅ Keyboard shortcuts (F1-F12, Ctrl+R, Ctrl+H)

**Technical Debt:**
- ❌ Monolithic code (all logic in single files)
- ❌ No modularization
- ❌ Mixed concerns (UI + logic together)
- ❌ No automated tests
- ❌ No code standards
- ⚠️ **F11 detaches instead of staying** (bug)

**Files:**
```
src/
├── status-bar-legacy.sh      # Status bar (monolithic)
├── mission-control.sh        # F11 Manager (monolithic)
├── help-reference.sh         # F12 Help
├── safe-exit.sh              # Safe exit wrapper
└── shortcuts-popup.sh        # Shortcuts helper
```

---

### **v1.0 - Production Release** 🎯 NEXT (Target: November 2025)

**Status:** In planning
**Goal:** Production-ready with modular architecture

**Scope:**

#### 1. **Bugfixes** (Critical)
- ✅ Fix F11 Manager detach issue
- ✅ Update status bar to match new spec (GLOSSARY icons)
- ✅ Fix any crash detection issues

#### 2. **Refactoring** (Architecture Improvements)
- ✅ State management module (`src/core/state.sh`)
  - Centralized console state tracking
  - 5-second cache to reduce tmux queries
  - Public API: `state::init()`, `state::get_console_state()`, `state::console_exists()`

- ✅ UI components (`src/ui/components/`)
  - Reusable dialog, list, header, footer
  - Used by Manager and Help

- ✅ Actions layer (`src/actions/`)
  - Encapsulated operations: attach, activate, restart, detach
  - Proper error handling

#### 3. **Testing Infrastructure**
- ✅ bats testing framework setup
- ✅ Unit tests for core modules (state, actions)
- ✅ Mock tmux for unit tests
- ✅ CI/CD integration (GitHub Actions)

#### 4. **Code Standards**
- ✅ Naming conventions (namespace::function pattern)
- ✅ Function documentation template
- ✅ Error handling patterns
- ✅ Shell compatibility guidelines

#### 5. **Documentation**
- ✅ User guides (getting started, configuration)
- ✅ API reference
- ✅ Troubleshooting guide

**New File Structure:**
```
src/
├── core/
│   ├── state.sh              # State management
│   ├── config.sh             # Config file parser
│   └── tmux-wrapper.sh       # Tmux command abstraction
├── ui/
│   ├── components/
│   │   ├── dialog.sh         # Reusable dialogs
│   │   ├── list.sh           # Selectable lists
│   │   ├── header.sh         # UI headers
│   │   └── footer.sh         # UI footers
│   ├── manager/
│   │   └── manager-main.sh   # F11 Manager (refactored)
│   ├── help/
│   │   └── help-main.sh      # F12 Help (refactored)
│   └── status-bar/
│       └── status-bar.sh     # Status bar (refactored)
├── actions/
│   ├── attach.sh             # Attach to console
│   ├── activate.sh           # Activate suspended console
│   ├── restart.sh            # Restart console
│   └── detach.sh             # Detach from session
└── utils/
    ├── colors.sh             # Color definitions
    ├── icons.sh              # Icon mappings
    └── logging.sh            # Logging utilities
```

**Migration Plan:**
1. **Phase 1** - Extract state management (Task 013)
2. **Phase 2** - Extract UI components (Task 014)
3. **Phase 3** - Extract actions (Task 015)
4. **Phase 4** - Setup testing (Task 016)
5. **Phase 5** - Document standards (Task 017)
6. **Phase 6** - Fix F11 bug + update status bar
7. **Phase 7** - Documentation + deployment

**Target Date:** v1.0-rc.1 by November 15, 2025

---

### **v1.1 - DevEx Improvements** 📅 FUTURE (Target: December 2025)

**Status:** Backlog
**Goal:** Better developer experience and usability

**Features:**
- Process name detection (show "vim", "node app.js" instead of just "Active")
- Custom console names (rename "F3" to "Backend")
- Quick restart (Ctrl+Shift+R in console)
- Console templates (predefined setups)

**Technical:**
- Process monitoring module
- Config file extensions (console names, templates)

---

### **v1.2 - Advanced Features** 📅 FUTURE (Target: January 2026)

**Status:** Ideas
**Goal:** Power user features

**Features:**
- Bulk operations (restart all active consoles)
- Console groups (group consoles by project)
- Session snapshots (save/restore console state)
- Remote console management (manage from another machine)

---

### **v2.0 - CLI & Automation** 📅 FUTURE (Target: Q1 2026)

**Status:** Vision
**Goal:** Full CLI interface for automation

**Features:**
- `ptty attach 3` - Attach to console 3
- `ptty restart all` - Restart all consoles
- `ptty status` - Show console states
- `ptty create backend --cmd "npm run dev"` - Create named console

**Breaking Changes:**
- CLI becomes primary interface (TUI is secondary)
- Config file format changes (YAML instead of shell vars)
- API changes for state management

---

## 🗓️ Version Release Checklist

**Before releasing any version:**

### Code Quality
- [ ] All tests passing (unit + integration)
- [ ] Code review completed
- [ ] No critical bugs
- [ ] Performance acceptable (< 100ms for status bar update)

### Documentation
- [ ] CHANGELOG.md updated
- [ ] User documentation updated
- [ ] API reference updated (if API changed)
- [ ] Migration guide (for breaking changes)

### Testing
- [ ] Manual testing on fresh install
- [ ] Tested on Ubuntu + macOS
- [ ] Tested with bash + zsh
- [ ] Tested with different terminal emulators

### Release
- [ ] Git tag created (`git tag v1.0.0`)
- [ ] GitHub release with notes
- [ ] Installation script updated (if needed)

---

## 📊 Version Feature Matrix

| Feature | v0.1 | v1.0 | v1.1 | v1.2 | v2.0 |
|---------|------|------|------|------|------|
| Persistent sessions | ✅ | ✅ | ✅ | ✅ | ✅ |
| Status bar | ✅ | ✅ | ✅ | ✅ | ✅ |
| F11 Manager | ✅ | ✅ | ✅ | ✅ | ✅ |
| F12 Help | ✅ | ✅ | ✅ | ✅ | ✅ |
| Safe exit | ✅ | ✅ | ✅ | ✅ | ✅ |
| Modular code | ❌ | ✅ | ✅ | ✅ | ✅ |
| Automated tests | ❌ | ✅ | ✅ | ✅ | ✅ |
| Process names | ❌ | ❌ | ✅ | ✅ | ✅ |
| Custom names | ❌ | ❌ | ✅ | ✅ | ✅ |
| Bulk operations | ❌ | ❌ | ❌ | ✅ | ✅ |
| Console groups | ❌ | ❌ | ❌ | ✅ | ✅ |
| CLI interface | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 🎯 Current Status: v0.1 → v1.0 Migration

**Where we are:**
- v0.1 code works but has technical debt
- Specifications complete (GLOSSARY, ICONS-SPEC, MANAGER-SPEC, etc.)
- Architecture analysis done (modular structure designed)
- Refactoring tasks defined (013-017)

**What's next:**
1. ✅ Fix critical bugs (F11 detach)
2. ✅ Refactor to modular architecture (tasks 013-015)
3. ✅ Add testing framework (task 016)
4. ✅ Document code standards (task 017)
5. ✅ Update documentation
6. ✅ Release v1.0-rc.1
7. ✅ User testing + bugfixes
8. ✅ Release v1.0.0

**Timeline:**
- **Now - Week 2**: Refactoring (013-015)
- **Week 3**: Testing + Standards (016-017)
- **Week 4**: Bugfixes + Documentation
- **Week 5**: RC testing
- **Week 6**: v1.0.0 Release

---

## 🔗 Related Documentation

- **[SPEC.md](../SPEC.md)** - Complete product specification
- **[ROADMAP.md](../01-vision/ROADMAP.md)** - Long-term product vision
- **[CHANGELOG.md](../CHANGELOG.md)** - Detailed version history
- **[tasks/README.md](../tasks/README.md)** - Current sprint tasks

---

## ✅ Version Approval Process

**Major versions (v1.0, v2.0):**
1. Product owner approval
2. Architecture review
3. Security review (if applicable)
4. User testing

**Minor versions (v1.1, v1.2):**
1. Product owner approval
2. Code review

**Patches (v1.0.1, v1.0.2):**
1. Code review + merge

---

**This versioning strategy ensures:**
- ✅ Clear scope for each release
- ✅ Predictable upgrade path for users
- ✅ Manageable development cycles
- ✅ Traceability of features across versions
