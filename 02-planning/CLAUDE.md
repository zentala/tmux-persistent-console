# 02-planning - Requirements & Specifications

**Purpose:** Define WHAT pTTY should do

---

## ⭐ Start Here

**[SPEC.md](SPEC.md)** - Unified Specification (Single Source of Truth)

All features, F-keys, status bar, manager, help - everything in one place.

---

## 📁 Contents

### Core Documents
- **[SPEC.md](SPEC.md)** - ⭐ Complete unified specification
- **[VERSIONING.md](VERSIONING.md)** - Version numbering and release plan

### Workshops ([workshops/](workshops/))
Team discussions showing how requirements evolved:
- **[SPEC-WORKSHOP.md](workshops/SPEC-WORKSHOP.md)** - 25 questions → user answers → decisions
- **[TEAM-DISCUSSION-V1.md](workshops/TEAM-DISCUSSION-V1.md)** - Team discussion round 2

### Detailed Specs ([specs/](specs/))
Component-specific specifications:
- **[GLOSSARY.md](specs/GLOSSARY.md)** - Terminology, shortcuts, icons, colors
- **[ICONS-SPEC.md](specs/ICONS-SPEC.md)** - Icon-to-state mapping, themes
- **[MANAGER-SPEC.md](specs/MANAGER-SPEC.md)** - F11 Manager complete spec
- **[STATUS-BAR-SPEC.md](specs/STATUS-BAR-SPEC.md)** - Status bar visual design
- **[HELP-SPEC.md](specs/HELP-SPEC.md)** - F12 Help reference
- **[SAFE-EXIT-SPEC.md](specs/SAFE-EXIT-SPEC.md)** - Safe exit wrapper behavior
- **[CLI-ARCH.md](specs/CLI-ARCH.md)** - CLI commands (v2+ future)
- **[FUTURE-VISION.md](specs/FUTURE-VISION.md)** - v2/v3 scope

### Backlog ([backlog/](backlog/))
Future ideas not yet scheduled:
- **[ai-cli-workflow.md](backlog/ai-cli-workflow.md)** - AI CLI workflow vision

### Archive ([archive/v0.1/](archive/v0.1/))
Historical notes from v0.1 development:
- **[icons-early-notes.md](archive/v0.1/icons-early-notes.md)** - Early icon exploration

---

## 🎯 What Belongs Here

This folder answers "WHAT should pTTY do?"

### Planning = Requirements + Specifications
- **Requirements:** User needs, problems to solve
- **Specifications:** Exact behavior, UI design, feature scope

### Key Questions Answered
- **What features?** → SPEC.md
- **What versions?** → VERSIONING.md
- **Why these decisions?** → workshops/
- **How should it look?** → specs/

---

## 🔍 How to Use This Folder

### For Developers
1. Read **SPEC.md** first (Single Source of Truth)
2. Check **GLOSSARY.md** for terminology
3. Read component spec for your feature (MANAGER-SPEC.md, etc.)
4. Check **VERSIONING.md** for scope of current version

### For Designers
1. Read **STATUS-BAR-SPEC.md** for visual design
2. Check **ICONS-SPEC.md** for icon usage
3. See **GLOSSARY.md** for colors and themes

### For Project Managers
1. Check **VERSIONING.md** for release scope
2. Read **workshops/** to understand decision history
3. Review **SPEC.md** for feature completeness

### For AI Agents
1. **Always** read SPEC.md before making changes
2. Use GLOSSARY.md for correct terminology
3. Check component specs for implementation details
4. Verify changes align with SPEC.md (SSOT)

---

## 📊 Specification Status

### v0.2 Scope (Current)
- ✅ All F-key specifications complete
- ✅ Status bar design finalized
- ✅ Manager (F11) behavior defined
- ✅ Help (F12) content structured
- ✅ Icon mapping complete
- ✅ Safe exit behavior specified
- 🔄 Glossary (complete but needs review)

### Future Versions
- ⏳ v1.0 - CLI commands (CLI-ARCH.md)
- ⏳ v2.0 - Advanced features (FUTURE-VISION.md)

---

## 🔗 Related

- **[../01-vision/](../01-vision/)** - WHY we're building this
- **[../03-architecture/](../03-architecture/)** - HOW we're building it
- **[../04-tasks/](../04-tasks/)** - WHEN we're doing the work
- **[../CLAUDE.md](../CLAUDE.md)** - Always check SPEC.md first

---

## ✅ Specification-Driven Development

**CRITICAL RULE:**
> Before making ANY changes, read [SPEC.md](SPEC.md).
> All conflicts MUST be resolved by updating SPEC.md first.

SPEC.md is the Single Source of Truth (SSOT).
All other docs elaborate on it, but SPEC.md is authoritative.

---

**This folder defines WHAT we build, not HOW or WHEN.**
