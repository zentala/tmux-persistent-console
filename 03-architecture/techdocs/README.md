# Technical Documentation

**Purpose:** Deep technical lessons learned during development, for developers only.

**Audience:** Developers working on this codebase (not end users).

---

## 📚 Lessons

### [Lesson #01: Status Bar Flickering in Tmux](lesson-01-status-bar-flickering.md)

**Problem:** Status bar visibly blinks/flickers every 5 seconds.

**Root Cause:** External script execution with periodic refresh (`status-interval 5`).

**Solution:** Replace with native tmux format strings (`status-interval 0`).

**Key Takeaway:**
> **Never use external scripts in tmux status bar with periodic refresh.**
> Always prefer native `#{}` variables.

**Quick Rule:**
```tmux
# ❌ Causes flicker
set -g status-interval 5
set -g status-left '#(script.sh)'

# ✅ No flicker
set -g status-interval 0
set -g status-left '#{USER}@#H'
```

---

## 🎯 How to Use This Documentation

### For Claude Code AI

These lessons are **preemptive knowledge** to prevent repeating mistakes:

1. **Before implementing status bar:** Read lesson-01
2. **Before adding periodic tasks:** Check performance implications
3. **When debugging flicker:** Reference lesson-01 checklist

### For Human Developers

1. Read lesson when encountering similar issue
2. Follow prevention checklist before adding features
3. Add new lessons when discovering new patterns

---

## 📝 Lesson Template

When adding new lessons, use this structure:

```markdown
# Technical Lesson #NN: [Title]

**Date:** YYYY-MM-DD
**Issue:** Brief description
**Severity:** 🔴/🟡/🟢
**Resolution:** Short solution

## 🐛 The Problem
[Detailed symptom description]

## 🔍 Root Cause
[Technical explanation with code examples]

## ✅ The Solution
[Working solution with code]

## 📊 Performance/Impact
[Measurements and improvements]

## 🎓 General Principles
[Reusable rules for future]

## 🔬 Detection & Testing
[How to detect and prevent]

## 🛠️ Debugging
[Step-by-step debugging guide]

## 📚 References
[Links to related docs]

## ✅ Checklist
[Prevention checklist]
```

---

## 🔗 Integration with CLAUDE.md

Each lesson should have:
1. **Short reference** in CLAUDE.md (what to avoid)
2. **Full explanation** in techdocs (why and how)

Example:
```markdown
# In CLAUDE.md
### ⚠️ Prevent Flickering
**Rule:** No external scripts in status bar
**Details:** See techdocs/lesson-01-status-bar-flickering.md

# In techdocs/lesson-01-...
[Full 500-line explanation with examples, tests, debugging]
```

---

## 📊 Lesson Categories

### Performance
- lesson-01: Status bar flickering (external scripts)

### Security
- (TODO: Add as discovered)

### Architecture
- (TODO: Add as discovered)

### Testing
- (TODO: Add as discovered)

---

## 🎓 Contribution Guidelines

### When to Add a Lesson

Add new lesson when:
- ✅ Issue took >2 hours to debug
- ✅ Root cause is non-obvious
- ✅ Mistake could easily be repeated
- ✅ General principle can be extracted

Don't add for:
- ❌ Simple typos or syntax errors
- ❌ One-off issues specific to environment
- ❌ Well-documented tmux/bash behavior

### Lesson Quality Standards

Each lesson must have:
- [ ] Clear problem statement (user-visible symptom)
- [ ] Technical root cause explanation
- [ ] Working solution with code examples
- [ ] Performance/impact measurements
- [ ] Prevention checklist
- [ ] Testing/detection method
- [ ] Links to related docs

---

## 🔍 Quick Reference

### Performance Rules

1. **No external scripts in periodic status updates**
   - Lesson: #01
   - Rule: Use native tmux `#{}` variables

2. **Measure before optimizing**
   - Tool: `time command`
   - Target: <10ms for UI updates

3. **Avoid loops calling tmux**
   - Alternative: Batch operations
   - Example: `tmux list-sessions` once, not in loop

---

**Location:** `/home/zentala/.vps/sessions/techdocs/`
**Audience:** Developers only
**Purpose:** Prevent repeating production issues
