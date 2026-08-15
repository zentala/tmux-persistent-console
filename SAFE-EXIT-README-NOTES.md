# README notes — safe-exit Ctrl+D coverage

**Status:** not applied to `README.md` yet — that file is out of scope for
this task (later wave). This is the wording to fold in when that wave runs.

Source of truth for the mechanism: `02-planning/specs/SAFE-EXIT-SPEC.md`.

## What changed

Safe exit used to only intercept typed `exit` (via a shell alias). Ctrl+D
(EOF) bypassed it completely and killed the shell — and the tmux session
with it — immediately. It now also covers Ctrl+D, using the shell's own
`IGNOREEOF` (bash) / `setopt IGNORE_EOF` (zsh) setting, scoped to
interactive tmux sessions only.

## Suggested README wording

Add near wherever README currently documents the `exit` protection
(search for "safe exit" / "accidental exit"):

> pTTY also guards against Ctrl+D (EOF). Inside a pTTY tmux session, the
> first Ctrl+D shows `Use "exit" to leave the shell.` instead of closing
> the terminal; typing `exit` then goes through the same safe-exit prompt
> as normal. This only applies inside tmux sessions — your regular local
> shell outside pTTY is unaffected.

## Honest limits to keep in the README (do not overstate)

Safe exit is a convenience against **accidental** exits, not a lock:

- `\exit`, `command exit`, `builtin exit`, or exit from inside a script or
  subshell all bypass the alias by design.
- `tmux kill-session` (from another terminal, the F11 manager menu, or an
  external script), or `kill`/`kill -9` on the shell or tmux server, are
  not shell-level events and are not caught here.
- A crash of the shell or the tmux server is not caught here either.

Keep this list next to the feature description so the promise stays
accurate — do not word it as "protects against session loss" without
qualification.
