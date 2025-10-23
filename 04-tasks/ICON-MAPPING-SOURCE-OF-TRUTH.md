# ICON MAPPING - SOURCE OF TRUTH

**Date Updated**: 2025-10-12
**Authority**: User-defined in `docs/ICONS-NETWORK-SET.md`
**Status**: ✅ CANONICAL - All implementations MUST follow this

---

## 🎯 CRITICAL: This is the ONLY valid icon mapping

**Source**: `docs/ICONS-NETWORK-SET.md` (lines 130-141)

All other documents (SPEC.md, theme-config.sh, status-format-v4.tmux) MUST align with this.

---

## 📋 CANONICAL ICON MAPPING

### Application Icons
```
pTTY Logo: 󰢩 nf-md-console_network (f08a9)
```

### Terminal States
```
Active Session:    󰢩 nf-md-console_network         (f08a9)
Available/Idle:    󰱠 nf-md-console_network_outline (f0c60)  ← DIFFERENT from Active!
Suspended:         󰲝 nf-md-network_outline         (f0c9d)
Crashed/Killed:    󰱟 nf-md-close_network_outline   (f0c5f)
```

### Special Functions
```
Manager (F11):     󱫋 nf-md-network_pos              (f1acb)
Help (F12):        󰲊 nf-md-help_network_outline     (f0c8a)
```

---

## 🔍 KEY DIFFERENCES FROM PREVIOUS SPEC

### CHANGED: Available/Idle Icon
- **OLD (WRONG)**: 󰢩 `console_network` (f08a9) - same as Active
- **NEW (CORRECT)**: 󰱠 `console_network_outline` (f0c60) - different from Active

**Visual difference**: Active is FILLED (󰢩), Available is OUTLINED (󰱠)

### CHANGED: Crashed Icon
- **OLD (WRONG)**:  `close_network` (f015b)
- **NEW (CORRECT)**: 󰱟 `close_network_outline` (f0c5f)

### CHANGED: Help Icon
- **OLD (WRONG)**:  `help_network` (f06f5)
- **NEW (CORRECT)**: 󰲊 `help_network_outline` (f0c8a)

---

## 📝 IMPLEMENTATION REQUIREMENTS

### 1. theme-config.sh MUST have:
```bash
export ICON_SESSION_ACTIVE="󰢩"       # f08a9 - console_network
export ICON_SESSION_AVAILABLE="󰱠"   # f0c60 - console_network_outline ← CHANGED!
export ICON_SESSION_SUSPENDED="󰲝"   # f0c9d - network_outline
export ICON_SESSION_CRASHED="󰱟"     # f0c5f - close_network_outline ← CHANGED!
export ICON_MANAGER="󱫋"             # f1acb - network_pos
export ICON_HELP="󰲊"                # f0c8a - help_network_outline ← CHANGED!
```

### 2. status-format-v4.tmux MUST use:
```tmux
# Active session (current console):
󰢩 F1  (filled console icon)

# Available session (created but idle):
󰱠 F2  (outlined console icon)

# Suspended session (not created):
󰲝 F6  (network outline icon)

# Manager:
󱫋 F11

# Help:
󰲊 F12
```

### 3. SPEC.md MUST reflect these exact codes

---

## ✅ VALIDATION CHECKLIST

Before ANY icon implementation, verify:

- [ ] `docs/ICONS-NETWORK-SET.md` is the reference (lines 130-141)
- [ ] Available uses `󰱠` (f0c60) NOT `󰢩` (f08a9)
- [ ] Help uses `󰲊` (f0c8a) NOT `` (f06f5)
- [ ] Crashed uses `󰱟` (f0c5f) NOT `` (f015b)
- [ ] All hex codes match EXACTLY
- [ ] Visual distinction: Active (filled) vs Available (outlined)

---

## 🚨 ENFORCEMENT

**Any code that deviates from this mapping is WRONG and MUST be corrected.**

**Process:**
1. Read `docs/ICONS-NETWORK-SET.md` (lines 130-141)
2. Copy icons EXACTLY as specified
3. Verify hex codes match
4. Test visual appearance

**No exceptions. No interpretations. Follow the source.**

---

## 🔗 References

- **PRIMARY SOURCE**: `docs/ICONS-NETWORK-SET.md` (lines 130-141)
- **Implementation**: `src/theme-config.sh`
- **Usage**: `src/status-format-v4.tmux`
- **Specification**: `02-planning/SPEC.md` (must align)

---

**Last Updated**: 2025-10-12
**Authority**: User-defined canonical mapping
**Status**: ✅ ACTIVE - All implementations must comply
