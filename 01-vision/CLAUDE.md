# 01-vision - Purpose & Direction

**Purpose:** Understand WHY pTTY exists and WHERE it's going

---

## 📁 Contents

**Status:** 🚧 To be created

This folder will contain:
- **PURPOSE.md** - Core problem, solution, values, manifesto
- **ROADMAP.md** - Product vision (v0.x → v1.x → v2.x)
- **principles.md** - Design principles guiding all decisions

---

## 🎯 What Belongs Here

This folder answers the fundamental questions:

### WHY does pTTY exist?
→ **PURPOSE.md** - Problem: SSH disconnects lose work. Solution: Persistent tmux sessions.

### WHERE are we going?
→ **ROADMAP.md** - Version roadmap from prototype to production

### WHAT guides our decisions?
→ **principles.md** - DevEx, simplicity, "just works", low-code philosophy

---

## 💡 Core Vision (Summary)

**Problem:**
Remote development over SSH loses sessions on disconnect. Long-running jobs vanish. No quick session switching.

**Solution:**
Persistent tmux-based console with:
- 10 always-available sessions (F1-F10)
- Safe exit protection (prevents accidental detach)
- Visual status bar showing all consoles
- Instant F-key switching

**Values:**
- **DevEx first** - Tool should be invisible when working
- **Just works** - No configuration needed to start
- **Resilient** - Never lose work to disconnects
- **Fast** - Instant switching, no lag

---

## 🗺️ Product Roadmap (Quick Reference)

**v0.1** ✅ - Prototype (functional but monolithic)
**v0.2** 🔄 - Refactored architecture + tests
**v0.3-v0.9** ⏳ - Iterative improvements
**v1.0** 🎯 - Production release
**v2.0** 💡 - Advanced features (CLI, automation)

**See:** [../02-planning/VERSIONING.md](../02-planning/VERSIONING.md) for complete version plan

---

## 🎨 Design Principles (Preview)

1. **Developer Experience (DevEx) First**
   - Tool should be transparent when working well
   - No friction between thought and action

2. **Just Works Philosophy**
   - Sane defaults, no required configuration
   - Progressive disclosure (simple → advanced)

3. **Resilience Over Features**
   - Never lose user's work
   - Graceful degradation (status bar works even if gum missing)

4. **Low-Code, High-Impact**
   - Bash scripts over complex frameworks
   - Native tools (tmux) over reinventing wheels

---

## 🔗 Related

- **[../02-planning/SPEC.md](../02-planning/SPEC.md)** - Complete specification (WHAT)
- **[../03-architecture/NAMING.md](../03-architecture/NAMING.md)** - Brand identity
- **[../README.md](../README.md)** - User-facing overview

---

**Next Steps:**
1. Create PURPOSE.md from README.md "Why This Exists" section
2. Move FUTURE-VISION.md content to ROADMAP.md
3. Extract design principles to principles.md

---

**This folder explains the WHY behind pTTY.**
