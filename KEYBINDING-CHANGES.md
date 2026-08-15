# Keybinding changes pending doc update (README.md / SPEC.md)

T03 (E004-W1B) moved two global (`-n`, no-prefix) tmux bindings to prefix
bindings, because the global forms hijacked keys every pane and shell relies
on:

- `-n C-r` (restart console) hijacked readline reverse-i-search in every
  shell in every pane. Now `bind-key R` — press prefix (`Ctrl+B`) then
  `Shift+R`.
- `-n C-h` (shortcuts popup) collided with backspace semantics in some
  terminals. Now `bind-key H` — press prefix (`Ctrl+B`) then `Shift+H`.

`src/tmux.conf`, `src/help-reference.sh`, `src/shortcuts-popup.sh`,
`src/restart-confirm.sh`, `src/restart-session.sh`, and
`src/mission-control.sh` were already updated in this task. **README.md and
02-planning/SPEC.md were intentionally left untouched** (out of scope for
this task, restructured by a later wave). Update these exact lines when that
wave runs:

## README.md

- Line 238: `| \`Ctrl+H\` | 📋 Shortcuts Popup | Quick reference popup |`
  → key becomes `Ctrl+B H` (prefix + H).
- Line 239: `| \`Ctrl+R\` | 🔄 Restart Console | Restart current console (with confirmation) |`
  → key becomes `Ctrl+B R` (prefix + R).

## 02-planning/SPEC.md

- Line 89: `| **Ctrl+H** | Shortcuts Popup | Quick reference popup |`
  → key becomes `Ctrl+B H` (prefix + H).
- Line 90: `| **Ctrl+R** | Restart Console | Restart current console (with confirmation) |`
  → key becomes `Ctrl+B R` (prefix + R).
- Line 93: `| **Ctrl+Del** | Restart Terminal | Same popup as Ctrl+R (future) |`
  → cross-reference becomes "same popup as Ctrl+B R".
- Line 291: `- Show additional shortcuts (Ctrl+H, Ctrl+R, etc.)`
  → becomes "Ctrl+B H, Ctrl+B R, etc.".
- Line 350: `` - `Ctrl+Del` = Restart terminal (same popup as Ctrl+R) ``
  → cross-reference becomes "same popup as Ctrl+B R".

## Not touched, no doc change needed

- `Ctrl+Alt+R` (`bind-key -n C-M-r`, reset terminal) is untouched — no
  common shell binding collides with it. Verified still present in
  `src/tmux.conf` line ~64 unchanged.
- `preview-ux.sh` (repo root, a manual UX mockup script, not shipped by
  installer) still shows the old `Ctrl+R` / `Ctrl+H` / `Ctrl+Del` labels in
  its ASCII previews (lines ~106-113, ~164-174). It already documented
  aspirational/inaccurate bindings before this task (e.g. `Ctrl+Del` restart
  and a `Ctrl+?` shortcuts key that were never wired in `tmux.conf`). Left
  as-is; flag for cleanup alongside the README/SPEC wave.
