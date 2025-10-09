**Purpose:** Product roadmap showing version evolution from v0.1 to v2.0+

---

# pTTY - Product Roadmap

**Last Updated:** 2025-10-09

---

## 🎯 Version Strategy

**Incremental improvement:** v0.1 → v0.2 → v0.3 → ... → v0.9 → v1.0

**Rule:** Versions increment by 0.1 only (never skip versions)

**See:** [../00-rules/VERSIONING.md](../00-rules/VERSIONING.md) for complete version rules

---

## 📦 Release History

### v0.1 - Prototype ✅ COMPLETE (October 2025)

**Status:** Functional but monolithic

**What We Built:**
- ✅ 10 persistent tmux sessions (F1-F10)
- ✅ Status bar with console indicators
- ✅ F11 Manager (interactive menu)
- ✅ F12 Help reference
- ✅ Safe exit wrapper
- ✅ Keyboard shortcuts (F1-F12, Ctrl+R, Ctrl+H)

**Technical Debt:**
- ❌ Monolithic code (all in single files)
- ❌ No modularization
- ❌ Mixed concerns (UI + logic)
- ❌ No automated tests
- ❌ No code standards

**Lessons Learned:**
- Concept works! Users understand F-key navigation
- Status bar flicker issue (external scripts + refresh interval)
- gum provides great UX for Manager

---

## 🔄 Active Development

### v0.2 - Refactored Architecture 🔄 IN PROGRESS (Target: November 2025)

**Goal:** Production-ready with modular code

**Scope:**

**1. Architecture Refactoring**
- Modular structure (core, ui, actions, utils)
- State management module with caching
- Reusable UI components
- Separated action layer

**2. Testing Infrastructure**
- bats testing framework
- Unit tests for core modules
- Mock tmux for tests
- CI/CD integration

**3. Documentation**
- Code standards
- Developer guidelines
- Architecture Decision Records (ADRs)
- Complete user documentation

**4. Polish**
- Bug fixes (F11 detach issue - if exists)
- Status bar updates to spec
- Consistent naming

**See:** [../04-tasks/](../04-tasks/) for current tasks

---

## 🔮 Future Versions

### v0.3-v0.9 - Iterative Improvements ⏳ PLANNED

**Incremental enhancements:**
- Performance optimizations
- Bug fixes discovered in v0.2
- Minor UX improvements
- Documentation refinements

**Each version adds small, focused improvements**

---

### v1.0 - Stable Production Release 🎯 TARGET (Q1 2026)

**Milestone:** First production-ready version

**What v1.0 Means:**
- ✅ All core features working reliably
- ✅ Comprehensive tests (>80% coverage)
- ✅ Complete documentation
- ✅ No known critical bugs
- ✅ Stable API for external tools
- ✅ Ready for public release

**Features:**
- All v0.x features polished
- MOTD on first login
- Process name detection in Manager
- Custom console names (optional)
- Config reload without restart
- Improved help system (Ctrl+H)
- Auto-detection of Nerd Fonts

**Breaking Changes from v0.x:**
- Config file format may change
- Some keyboard shortcuts may change
- Status bar format finalized

---

### v1.1-v1.9 - Feature Additions ⏳ FUTURE

**Incremental feature releases:**
- Enhanced process monitoring
- Custom themes
- Console templates
- More customization options

**Stability maintained, backward compatible**

---

### v2.0 - CLI & Automation 💡 VISION (Q2 2026)

**Milestone:** Scriptable interface

**New Features:**

**CLI Commands:**
```bash
ptty status              # Show all console states
ptty attach 3            # Attach to console 3
ptty restart all         # Restart all consoles
ptty create backend      # Create named console
```

**Process Monitoring:**
- CPU/RAM usage per console
- Process count
- Uptime tracking
- Last activity timestamp

**Advanced Features:**
- Console state persistence (survive reboot)
- Bulk actions (with confirmation)
- Notifications (crashed console alerts)
- Clone console feature
- Mouse support (optional)

**Breaking Changes:**
- CLI becomes primary interface
- Config file format changes (YAML?)
- Some F-key bindings may change

---

## 🌍 Beyond v2.0

### v3.0+ - Integration & Ecosystem 🚀 FUTURE

**Possible Directions:**
- Web UI (browser-based console manager)
- Remote management (manage pTTY from another machine)
- Team features (shared consoles?)
- Plugin system
- Integration with popular tools (VS Code, etc.)

**Note:** These are ideas, not commitments. Community feedback will guide direction.

---

## 📊 Feature Comparison Matrix

| Feature | v0.1 | v0.2 | v1.0 | v2.0 |
|---------|------|------|------|------|
| Persistent sessions | ✅ | ✅ | ✅ | ✅ |
| F-key navigation | ✅ | ✅ | ✅ | ✅ |
| Status bar | ✅ | ✅ | ✅ | ✅ |
| Manager (F11) | ✅ | ✅ | ✅ | ✅ |
| Help (F12) | ✅ | ✅ | ✅ | ✅ |
| Safe exit | ✅ | ✅ | ✅ | ✅ |
| **Architecture** |
| Modular code | ❌ | ✅ | ✅ | ✅ |
| Automated tests | ❌ | ✅ | ✅ | ✅ |
| Code standards | ❌ | ✅ | ✅ | ✅ |
| **Features** |
| Process names | ❌ | ❌ | ✅ | ✅ |
| Custom names | ❌ | ❌ | ✅ | ✅ |
| CLI interface | ❌ | ❌ | ❌ | ✅ |
| Process monitoring | ❌ | ❌ | ❌ | ✅ |
| Bulk actions | ❌ | ❌ | ❌ | ✅ |

---

## ❓ Open Questions (for Future)

**From community feedback, we need to decide:**

### v1.0 Decisions:
- **Q: Process monitoring granularity?**
  - Option A: Just process count
  - Option B: Full CPU/RAM stats
  - Decision: TBD based on performance impact

- **Q: Custom names stored where?**
  - Option A: Config file
  - Option B: Session metadata
  - Decision: TBD based on implementation

### v2.0 Decisions:
- **Q: Which notifications?**
  - Console crashed?
  - High CPU usage?
  - Long-running job finished?
  - Decision: TBD based on user research

- **Q: Auto-restart crashed consoles?**
  - Option A: Always auto-restart
  - Option B: Ask user
  - Option C: Configurable
  - Decision: TBD (safety vs. convenience)

- **Q: Bulk actions - which are safe?**
  - Restart all? (dangerous)
  - Detach from all? (safe)
  - Kill all processes? (very dangerous)
  - Decision: Only safe operations by default

---

## 🎯 Guiding Principles

**All versions must maintain:**
1. **Simplicity** - Don't add complexity without clear benefit
2. **Reliability** - Never lose user's work
3. **DevEx** - Tool should be invisible when working
4. **Backward compatibility** - Within major version (v1.x, v2.x)

**We prioritize:**
- ✅ User needs over feature count
- ✅ Stability over new features
- ✅ Documentation over code
- ✅ Real use cases over hypotheticals

---

## 📅 Timeline (Tentative)

```
Oct 2025:  v0.1 complete ✅
Nov 2025:  v0.2 (refactoring) 🔄
Dec 2025:  v0.3-v0.5 (iterations)
Jan 2026:  v0.6-v0.9 (polish)
Feb 2026:  v1.0-rc.1 (release candidate)
Mar 2026:  v1.0 RELEASE 🎉
Q2 2026:   v1.x feature additions
Q3 2026:   v2.0 (CLI & automation)
```

**Note:** Dates are estimates and will shift based on quality, not deadlines.

---

## 🔗 Related

- **[PURPOSE.md](PURPOSE.md)** - Why pTTY exists
- **[principles.md](principles.md)** - Design principles
- **[../00-rules/VERSIONING.md](../00-rules/VERSIONING.md)** - Version numbering rules
- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - Current specification
- **[../04-tasks/](../04-tasks/)** - Current work

---

**This roadmap evolves based on user feedback and real-world usage.**
