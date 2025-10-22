# Network Icon Set - Allowed Icons for pTTY

**Version:** 1.0
**Date:** 2025-10-11
**Purpose:** Complete reference of allowed Nerd Fonts icons (network theme)

---

## 📋 Usage Rules

**NF Mode (Nerd Fonts installed):**
- Use icons from this list ONLY
- Each state/function has assigned icon (see `src/theme-config.sh`)

**Non-NF Mode (fallback):**
- Some icons replaced with ASCII symbols
- Some icons omitted (null)
- See `src/theme-config.sh` for fallback mappings

---

## 🌐 Complete Network Icon Set

### Basic Network Icons

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-network | f06f3 | U+F06F3 |
|  | nf-fa-network_wired | ef09 | U+EF09 |

### Account & User

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-account_network | f0011 | U+F0011 |

### Status Icons

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-check_network | f0c53 | U+F0C53 |
|  | nf-md-close_network | f015b | U+F015B |
|  | nf-md-minus_network | f0378 | U+F0378 |
|  | nf-md-network_off | f0c9b | U+F0C9B |
|  | nf-md-network_outline | f0c9d | U+F0C9D |
|  | nf-md-network_pos | f1acb | U+F1ACB |

### Console & Terminal

| Icon | Name | Code | Hex |
|------|------|------|-----|
| 󰢩 | nf-md-console_network | f08a9 | U+F08A9 |

### Data Transfer

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-download_network | f06f4 | U+F06F4 |
|  | nf-md-upload_network_outline | f0cd8 | U+F0CD8 |

### Folders & Files

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-folder_network | f0870 | U+F0870 |
|  | nf-md-folder_key_network_outline | f0c80 | U+F0C80 |

### Help & Info

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-help_network | f06f5 | U+F06F5 |

### Network Management

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-ip_network | f0a60 | U+F0A60 |
|  | nf-md-ip_network_outline | f0c90 | U+F0C90 |

### Network Strength (Signal)

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-network_strength_1 | f08f4 | U+F08F4 |
|  | nf-md-network_strength_2 | f08f6 | U+F08F6 |
|  | nf-md-network_strength_3 | f08f8 | U+F08F8 |
|  | nf-md-network_strength_4 | f08fa | U+F08FA |
|  | nf-md-network_strength_off | f08fc | U+F08FC |
|  | nf-md-network_strength_outline | f08fe | U+F08FE |

### Network Strength Alerts

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-network_strength_1_alert | f08f5 | U+F08F5 |
|  | nf-md-network_strength_2_alert | f08f7 | U+F08F7 |
|  | nf-md-network_strength_3_alert | f08f9 | U+F08F9 |
|  | nf-md-network_strength_4_alert | f08fb | U+F08FB |
|  | nf-md-network_strength_4_cog | f191a | U+F191A |
|  | nf-md-network_strength_off_outline | f08fd | U+F08FD |

### Outlined Variants

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-minus_network_outline | f0c9a | U+F0C9A |
|  | nf-md-network_off_outline | f0c9c | U+F0C9C |
|  | nf-md-play_network_outline | f0cb7 | U+F0CB7 |
|  | nf-md-plus_network_outline | f0cba | U+F0CBA |

### Server Icons

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-server_network_off | f048e | U+F048E |

### Access Point

| Icon | Name | Code | Hex |
|------|------|------|-----|
|  | nf-md-access_point_network_off | f0be1 | U+F0BE1 |

---

## 🎨 Icon Assignments (Current Usage)

**See `src/theme-config.sh` for actual variable mappings**

### Application Icons
- **pTTY Logo**: 󰢩 `nf-md-console_network` (f08a9)

### Terminal States
- **Active Session**: 󰢩 `nf-md-console_network` (f08a9)
- **Available/Idle**: 󰢩 `nf-md-console_network` (f08a9)
- **Suspended**:  `nf-md-network_outline` (f0c9d)
- **Crashed/Killed**:  `nf-md-close_network` (f015b)

### Special Functions
- **Manager (F11)**:  `nf-md-network_pos` (f1acb)
- **Help (F12)**:  `nf-md-help_network` (f06f5)

---

## 📝 Notes

- **Icon codes** are hex values without `0x` prefix
- **Unicode** representation: U+F followed by hex code
- **Usage in tmux**: Direct UTF-8 character (e.g., `󰢩`)
- **Usage in bash**: Use variable from `theme-config.sh`

---

## 🔗 References

- **Theme configuration**: `src/theme-config.sh`
- **Status bar spec**: `02-planning/SPEC.md`
- **Icon mapping**: `02-planning/specs/ICONS-SPEC.md`

---

**This is the ONLY allowed icon set for pTTY network theme.**
**Do not use icons outside this list without updating this document first.**
