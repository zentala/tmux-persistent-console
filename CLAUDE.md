# CLAUDE.md - AI Assistant Guidelines

This file provides guidance to Claude Code when working with this codebase.

## Project Overview

**Tmux Persistent Console** - 7 persistent tmux sessions with safe-exit protection and instant switching for remote development.

## Code Quality Standards

### Current Priority: Safe Exit Wrapper Refactoring

**Status**: Working prototype (6.5/10) - needs production hardening
**See**: [TODO.md - Task #0](TODO.md) for detailed improvement plan

**When working on safe-exit.sh**:
1. ✅ Always test changes in actual tmux session
2. ✅ Verify both bash and zsh compatibility
3. ✅ Check all key combinations (Enter, ESC, Y, y, Ctrl+C)
4. ✅ Ensure no race conditions in session restart
5. ✅ Validate temp file security

### Code Review Checklist

Before completing any changes to `src/safe-exit.sh`:

- [ ] Error handling added for all external commands
- [ ] No hardcoded magic numbers (use constants)
- [ ] Trap cleanup guaranteed (use proper error handling)
- [ ] Temp files use `mktemp` with secure permissions
- [ ] Functions are small and single-purpose
- [ ] All user input is sanitized
- [ ] Debug logging available (if `DEBUG_SAFE_EXIT=1`)
- [ ] Tested in both bash and zsh

## Architecture Principles

### Safe Exit Wrapper Design

**Current Issues** (from code review 2025-10-05):
- Mixed responsibilities (UI + logic in one function)
- Lack of error handling
- Security issues with temp files
- No tests

**Target Architecture**:
```bash
safe_exit()
  ├── _is_tmux_session()
  ├── _show_menu()
  ├── _read_user_choice()
  ├── _handle_choice()
  │   ├── _detach_safely()
  │   ├── _restart_session()
  │   └── _stay_in_session()
  └── _cleanup()
```

**Constants** (to be added):
```bash
readonly DETACH_DELAY=0.8
readonly RESTART_DELAY=1
readonly ERROR_DISPLAY_TIME=2
readonly TEMP_DIR="${HOME}/.cache/tmux-console"
```

## Testing Requirements

### Manual Testing Protocol

Before committing changes to safe-exit.sh:

1. **Test in fresh tmux session**:
   ```bash
   tmux new-session -d -s test-safe-exit
   tmux attach -t test-safe-exit
   source ~/.tmux-persistent-console/safe-exit.sh
   ```

2. **Test all key combinations**:
   - Type `exit` → Press `Enter` → Verify detach message
   - Type `exit` → Press `ESC` → Verify stays in session
   - Type `exit` → Press `Ctrl+C` → Verify stays in session
   - Type `exit` → Press `y` → Verify error message
   - Type `exit` → Press `Y` (SHIFT+Y) → Verify restart
   - Type `exit` → Press `2` → Verify invalid choice message

3. **Test shell compatibility**:
   - Run in bash: `bash` → test all keys
   - Run in zsh: `zsh` → test all keys

4. **Cleanup**:
   ```bash
   tmux kill-session -t test-safe-exit
   ```

### Automated Testing (TODO)

**Priority**: HIGH (see TODO.md #0, Phase 3, task #10)

Create `tests/safe-exit-unit-tests.sh`:
```bash
test_enter_detaches() { ... }
test_esc_stays() { ... }
test_ctrl_c_stays() { ... }
test_shift_y_restarts() { ... }
test_lowercase_y_shows_error() { ... }
test_invalid_key_loops() { ... }
```

## Security Guidelines

### Temp File Handling

**Current (INSECURE)**:
```bash
local restart_script="/tmp/tmux-restart-$session_name.sh"
```

**Required (SECURE)**:
```bash
umask 077  # Only owner can read/write
local restart_script=$(mktemp "${HOME}/.cache/tmux-console/restart-XXXXXX.sh")
trap "rm -f '$restart_script'" EXIT
```

### Input Sanitization

**Always sanitize user-controlled variables**:
```bash
# BAD - potential command injection
echo "Session: $session_name"

# GOOD - sanitized
local safe_name=$(printf '%q' "$session_name")
echo "Session: $safe_name"
```

## Development Workflow

### Making Changes to Safe Exit

1. **Read current implementation**: `src/safe-exit.sh`
2. **Check TODO**: Review TODO.md task #0 for context
3. **Make changes**: Follow architecture principles
4. **Test manually**: Run testing protocol above
5. **Update SAFE-EXIT.md**: Document user-facing changes
6. **Update TODO.md**: Check off completed items
7. **Commit**: Use descriptive commit message

### Commit Message Format

```
refactor(safe-exit): Add error handling for tmux commands

- Check exit codes for all tmux operations
- Show user-friendly error messages
- Gracefully handle missing sessions
- Fixes TODO.md #0, Phase 1, task #5

Related: SAFE-EXIT.md, src/safe-exit.sh
```

## Known Issues & Workarounds

### Race Condition in Session Restart

**Issue**: Background restart script may not complete before user reconnects

**Current workaround**: 1 second sleep (unreliable)

**Proper fix** (TODO #3):
```bash
# Use lock file for synchronization
local lock_file="${HOME}/.cache/tmux-console/restart-${session_name}.lock"
touch "$lock_file"

# In restart script:
sleep 1
tmux new-session -d -s "$session_name" -n "main"
rm -f "$lock_file"

# User can check lock before reconnecting
```

### Trap Cleanup Not Guaranteed

**Issue**: If function exits unexpectedly, trap may stay active

**Current**: Manual cleanup in specific places

**Proper fix** (TODO #2):
```bash
safe_exit() {
    # Set trap at start
    trap '_cleanup; trap - INT' EXIT INT TERM

    # ... function body ...
}

_cleanup() {
    # Always executed before function exits
    trap - INT
}
```

## References

- **Main docs**: [README.md](README.md)
- **User guide**: [SAFE-EXIT.md](SAFE-EXIT.md)
- **TODO list**: [TODO.md](TODO.md)
- **Code review**: Session history 2025-10-05

## Quick Commands

```bash
# Update safe-exit on server
scp src/safe-exit.sh zentala@164.68.104.13:~/.tmux-persistent-console/

# Test in remote session
ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
source ~/.tmux-persistent-console/safe-exit.sh
exit  # Test the wrapper

# Check for issues
grep -n "TODO\|FIXME\|XXX\|HACK" src/safe-exit.sh
```

## AI Assistant Notes

When asked to improve safe-exit.sh:
1. **Start with Phase 1** tasks (critical security/reliability)
2. **One task at a time** - don't try to fix everything
3. **Always test** before marking complete
4. **Update TODO.md** to track progress
5. **Ask user** before major architectural changes

**Remember**: This is production code protecting user sessions. Bugs can cause data loss. Be careful and thorough.
