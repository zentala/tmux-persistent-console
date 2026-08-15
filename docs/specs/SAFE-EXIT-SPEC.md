**Purpose:** Safe exit wrapper specification to prevent accidental tmux session termination

---

# Safe Exit - protection against accidentally killing a tmux session

## Problem
Typing `exit` in a tmux session kills the shell → ends the tmux session → you lose:
- The full command history from that session
- Any running processes
- The scrollback buffer

## Solution: Safe Exit Wrapper

The wrapper guards two exit paths from an interactive shell: typing
`exit` (via an alias) and pressing Ctrl+D / EOF (via `IGNOREEOF` /
`IGNORE_EOF`). See [Technical details](#technical-details) and
[Honest limits](#honest-limits-what-is-not-protected) below.

### How it works
When you type `exit` in a tmux session, you get an interactive menu:

```
⚠️  WARNING: You are in a tmux session!

If you exit this shell, the tmux session will be DESTROYED and you will lose:
  • Command history from this session
  • Any running processes
  • Scrollback buffer

Options:
  [Enter] - Detach safely (recommended) - keeps session alive
  [Y]     - YES, kill this session permanently (Shift+Y required)
  [ESC]   - Cancel, stay in session

What do you want to do? [Enter/Y/ESC]:
```

### Options

1. **Enter** (default) - Detach safely
   - The session stays alive
   - History and processes are preserved
   - You can reattach later: `tmux attach -t console-1`

2. **Y** (Shift+Y) - Kill the session permanently
   - Only when you really want to remove the session
   - Requires **Shift+Y** (uppercase) - an extra safeguard
   - **WARNING**: you lose history and processes!

3. **ESC** - Cancel, stay in the session
   - Returns to normal work
   - The session is left unchanged

### Installation

#### Automatic (during pTTY install)
Safe exit is installed automatically by `install.sh`.

#### Manual installation
```bash
# Copy the file
cp ~/.vps/sessions/src/safe-exit.sh ~/.tmux-persistent-console/safe-exit.sh

# Add to ~/.bashrc
echo "" >> ~/.bashrc
echo "# Safe exit wrapper for tmux sessions" >> ~/.bashrc
echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> ~/.bashrc

# Reload bashrc
source ~/.bashrc
```

### Test
```bash
# Attach to a session
tmux attach -t console-1

# Type: exit
# You will see the choice menu

# Press Enter (detach safely)
# Or ESC (stay in the session)
# Or Shift+Y (kill the session - careful!)
```

### Safety notes
- **Default action (Enter)**: always safe - only detaches
- **Requires Shift+Y**: killing the session needs a deliberate **uppercase Y**
- **ESC cancels**: the natural "leave the menu" option keeps you in the session
- **Warns about consequences**: shows a warning before killing the session
- **Inactive outside tmux**: if you are not in a tmux session, `exit` behaves normally

### Alternatives to exit
- **Ctrl+B, d** - Standard tmux detach shortcut
- **Ctrl+F8** - Function-key detach shortcut (if configured)

### Technical details
- File: `~/.tmux-persistent-console/safe-exit.sh`
- Mechanism (typed `exit`): `exit` alias → `safe_exit()` function
- Mechanism (Ctrl+D / EOF): `IGNOREEOF=2` (bash) / `setopt IGNORE_EOF` (zsh),
  set only when `$TMUX` and `$PS1` are set (an interactive tmux session).
  The first Ctrl+D shows the shell's own message
  (`Use "exit" to leave the shell.`) instead of closing the shell; typing
  `exit` afterward hits the alias and goes through `safe_exit()`.
- tmux detection: checks the `$TMUX` variable
- Action: `tmux detach-client` instead of `builtin exit`

### Honest limits (what is NOT protected)
The protection covers only two specific exit paths from an interactive
login shell. It is not a sandbox or a tmux-level lock — it is
bypassable by design:

- **`\exit` or `command exit` or `builtin exit`** — skips the alias, calls
  the real builtin `exit`. An alias is a shell convention, not a lock.
- **Scripts and subshells** (`bash -c 'exit'`, `( exit )`, a script run
  as a file) — the alias only applies in the interactive shell that
  defined it; a new process does not inherit it.
- **`tmux kill-session` called externally** (another terminal, the F11
  manager menu, a scheduled task) — this is a direct tmux command and
  never goes through the shell at all.
- **`kill`/`kill -9` on the shell or tmux server process** — a signal
  kills the process regardless of shell aliases and traps.
- **A crash of the shell or the tmux server** — nothing on the shell
  side prevents that.
- **Ctrl+D pressed `IGNOREEOF+1` times in a row** — `IGNOREEOF=2`
  requires 3 consecutive EOFs before the shell actually closes (without
  going through `safe_exit()`); this is a deliberate trade-off of the
  standard shell mechanism, not a bug.

In other words: safe-exit protects against **accidentally** typing
`exit` or pressing Ctrl+D in an interactive session — not against a
deliberate or programmatic kill of the session from outside.

### What happens when:
| Action | Result |
|-------|----------|
| `exit` + Enter | Detach safely (session stays alive) |
| `exit` + ESC | Cancel, stay in the session |
| `exit` + Y (Shift+Y) | **KILLS THE SESSION** (history lost!) |
| `exit` + another key | Detach safely (default action) |
| `exit` outside tmux | Normal shell exit |

### Usage example
```bash
$ ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
zentala@vps:~$ exit

⚠️  WARNING: You are in a tmux session!
[...]
What do you want to do? [Enter/d/y/n]: ← press Enter

👋 Detaching safely from session...
Connection to 164.68.104.13 closed.

# Later you can come back:
$ ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
zentala@vps:~$ # History preserved!
```

## Restarting a session (after killing it)

If you accidentally killed a session, you can recreate it:

```bash
# On the server
setup-console-sessions  # Recreates all 7 sessions

# Or manually
tmux new-session -d -s console-1 -n "main"
```

## Summary
✅ **Safe default action** (Enter = detach)
✅ **Requires confirmation to kill a session** (y = kill)
✅ **Warns about consequences**
✅ **Does not get in the way outside tmux**
✅ **Intuitive choice menu**

**No more accidentally killed sessions.**
