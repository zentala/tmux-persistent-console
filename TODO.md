# TODO - Tmux Persistent Console

## 🔴 HIGH Priority

### 1. Improve F12 Help Menu UI/UX
**Status**: WIP (Commit: 6b9837f)

**Current State**:
- ✅ Help window opens as dedicated tmux window
- ✅ Persistent (doesn't close immediately)
- ✅ Auto-closes when switching consoles
- ✅ Minimal bash environment (no profile loading)

**Improvements Needed**:
- [ ] Better interactive UI (menus, colors, navigation)
- [ ] Quick access to common tasks
- [ ] Session status overview
- [ ] Configuration options
- [ ] Better keyboard navigation

**Technical Notes**:
- Using `bash --noprofile --norc` to avoid loading overhead
- Window name: `🔧Help` (with emoji)
- See `F12-ISSUES-LOG.md` for past troubleshooting

---

### 2. Add Docker-based Testing Infrastructure
**Status**: Not started

**Goal**: Automated testing with real SSH connections

**Requirements**:
- [ ] Docker Compose setup with 2-3 containers
- [ ] Container 1: Main server with tmux sessions
- [ ] Container 2: SSH client for testing connections
- [ ] Optional Container 3: Additional client for multi-user testing
- [ ] Automated test suite for CLI commands
- [ ] CI/CD integration (GitHub Actions)

**Test Scenarios**:
- SSH connection and tmux attach
- Function key bindings (Ctrl+F1-F12)
- Session persistence across disconnects
- Multi-client scenarios
- Auto-start with systemd

**Files to Create**:
- `tests/docker-compose.yml`
- `tests/Dockerfile.server`
- `tests/Dockerfile.client`
- `tests/test-suite.sh`
- `.github/workflows/test.yml`

---

### 3. Create Convenient SSH Connection Command
**Status**: Not started

**Current Problem**:
```bash
# Current: Too long and complex
ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
```

**Desired Solution**:
```bash
# Option 1: Simple command
console1  # connects to console-1
console2  # connects to console-2

# Option 2: Unified command with args
remote console-1
remote console-2

# Option 3: SSH config alias
ssh vps-console1
ssh vps-console2
```

**Implementation Ideas**:

**A) Shell Script Commands** (recommended for portability):
```bash
# ~/bin/console1
#!/bin/bash
ssh zentala@164.68.104.13 -t "tmux attach -t console-1"

# Create console1-7 commands automatically
```

**B) SSH Config Aliases**:
```ssh-config
# ~/.ssh/config
Host vps-console1
    HostName 164.68.104.13
    User zentala
    RequestTTY yes
    RemoteCommand tmux attach -t console-1

Host vps-console2
    HostName 164.68.104.13
    User zentala
    RequestTTY yes
    RemoteCommand tmux attach -t console-2
```

**C) Shell Functions**:
```bash
# ~/.bashrc / ~/.zshrc
console() {
    local num="${1:-1}"
    ssh zentala@164.68.104.13 -t "tmux attach -t console-${num}"
}

# Usage: console 1, console 2, etc.
```

**Tasks**:
- [ ] Decide on approach (scripts vs config vs functions)
- [ ] Implement for console 1-7
- [ ] Add to install.sh
- [ ] Document in README.md
- [ ] Add Windows Terminal profiles

---

## 🟡 MEDIUM Priority

### 4. Enhanced Documentation
- [ ] Add animated GIFs/screenshots of F12 menu
- [ ] Video tutorial for setup
- [ ] Common workflow examples
- [ ] Troubleshooting guide expansion

### 5. Windows Terminal Integration
- [ ] Pre-made profiles JSON
- [ ] One-click profile import
- [ ] Icon customization guide

### 6. Session Customization
- [ ] Per-session custom commands on startup
- [ ] Session-specific color schemes
- [ ] Custom session names/labels

---

## 🟢 LOW Priority

### 7. Plugin System
- [ ] Support for tmux plugins (TPM)
- [ ] Custom key binding extensions
- [ ] Session templates

### 8. Monitoring Dashboard
- [ ] Show active sessions
- [ ] CPU/Memory usage per session
- [ ] Last activity timestamps

---

## 📝 Notes

**Repository Structure**:
```
~/.vps/sessions/
├── src/
│   ├── setup.sh              # Creates 7 sessions
│   ├── connect.sh            # Interactive menu
│   ├── console-help.sh       # Full help menu
│   ├── help-console.sh       # F12 minimal help window
│   ├── tmux.conf             # Tmux configuration
│   └── tmux-console.service  # Systemd auto-start
├── tests/                    # (to be created)
├── docs/                     # Existing documentation
├── F12-ISSUES-LOG.md         # F12 troubleshooting
├── README.md                 # Main documentation
└── TODO.md                   # This file
```

**Decision Log**:
- **Systemd service**: Implemented (commit b6bd1e3)
- **F12 Help Window**: Dedicated window approach chosen over inline help
- **Minimal Shell**: Using `bash --noprofile --norc` to avoid loading overhead
