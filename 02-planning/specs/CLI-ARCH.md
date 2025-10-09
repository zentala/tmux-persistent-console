# pTTY - CLI Architecture (v3)

**Date:** 2025-10-08
**Status:** Design only - implement in v3

---

## Command Structure

```bash
ptty <command> [target] [options]
```

## Core Commands

### Status & Info
```bash
ptty status              # Show all console states
ptty info f3             # Show console F3 details
ptty version             # Show pTTY version
```

### Navigation
```bash
ptty switch f3           # Switch to console F3
ptty attach f5           # Attach to console F5 (alias)
ptty list                # List all consoles
```

### Console Management
```bash
ptty activate f7         # Activate suspended console
ptty restart f2          # Restart console (with confirmation)
ptty kill f4 --force     # Kill console (skip confirmation)
```

### Configuration
```bash
ptty config edit         # Open config in $EDITOR
ptty config reload       # Reload config without restart
ptty config show         # Display current config
```

### Themes
```bash
ptty theme list          # Show available themes
ptty theme set dark      # Switch to theme
ptty theme show          # Show current theme
```

### Advanced (v3+)
```bash
ptty f3 exec "npm run dev"           # Execute command in F3
ptty create f10 --name="Logs"        # Create with custom name
ptty export f1 > backup.tar.gz       # Backup console
ptty import f1 < backup.tar.gz       # Restore console
```

## Implementation

**Main script:** `/usr/local/bin/ptty`
**Subcommands:** `~/.vps/sessions/cli/ptty-*.sh`

**Example dispatch:**
```bash
#!/bin/bash
# /usr/local/bin/ptty

COMMAND=$1
shift

case $COMMAND in
  status)   exec ~/.vps/sessions/cli/ptty-status.sh "$@" ;;
  switch)   exec ~/.vps/sessions/cli/ptty-switch.sh "$@" ;;
  config)   exec ~/.vps/sessions/cli/ptty-config.sh "$@" ;;
  *)        echo "Unknown command: $COMMAND" ;;
esac
```

---

**Complete design deferred to v3 implementation phase**
