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

### 2. ~~Add Docker-based Testing Infrastructure~~ ✅ COMPLETED
**Status**: ✅ Completed (Commit: 85323cc)

**Goal**: Automated testing with real SSH connections

**Completed**:
- ✅ Docker Compose setup with 2-3 containers
- ✅ Container 1: Main server with tmux sessions
- ✅ Container 2: SSH client for testing connections
- ✅ Optional Container 3: Additional client for multi-user testing (multi-server profile)
- ✅ Automated test suite for CLI commands
- ✅ CI/CD integration (GitHub Actions - docker-test.yml)

**Test Scenarios Covered**:
- ✅ SSH connection and tmux attach
- ✅ Function key bindings (Ctrl+F1-F12)
- ✅ Session persistence across disconnects
- ✅ Multi-client scenarios
- ✅ Auto-start verification

**Files Created**:
- ✅ `tests/docker/docker-compose.yml`
- ✅ `tests/docker/Dockerfile.server`
- ✅ `tests/docker/Dockerfile.client`
- ✅ `tests/docker/test-local.sh`
- ✅ `.github/workflows/docker-test.yml`

**Usage**:
```bash
cd tests/docker
./test-local.sh test              # Run all tests
./test-local.sh interactive       # Interactive testing
./test-local.sh start             # Start environment
```

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

### 4. Cloud-based Testing Infrastructure (OCI)
**Status**: Deferred (Cloud testing disabled)

**Goal**: Automated testing on real cloud infrastructure (Oracle Cloud)

**Current State**:
- ✅ Terraform configuration ready (`tests/terraform/`)
- ✅ Cloud-init setup (`tests/configs/cloud-init.yaml`)
- ✅ Deployment scripts (`tests/scripts/deploy.sh`, `destroy.sh`)
- ⚠️ Workflow disabled (`.github/workflows/test-infrastructure.yml` - commented out)

**Why Deferred**:
- Docker-based testing covers most scenarios
- Cloud testing has permission issues with GitHub Actions (SARIF upload)
- Cloud resources cost money (even with free tier)
- Docker tests are faster and more reliable for CI/CD

**To Re-enable Later**:
1. Uncomment `cloud-testing` job in `test-infrastructure.yml`
2. Uncomment `cloud-test-pr` job in `pr-validation.yml`
3. Configure GitHub secrets for OCI credentials
4. Fix SARIF upload permissions or remove sarif output

**Use Cases for Cloud Testing**:
- Testing on ARM architecture (OCI free tier uses ARM)
- Testing systemd service integration
- Load testing with real network conditions
- Multi-region deployment validation

---

## 🟡 MEDIUM Priority

### 5. Enhanced Documentation
- [ ] Add animated GIFs/screenshots of F12 menu
- [ ] Video tutorial for setup
- [ ] Common workflow examples
- [ ] Troubleshooting guide expansion

### 6. Windows Terminal Integration
- [ ] Pre-made profiles JSON
- [ ] One-click profile import
- [ ] Icon customization guide

### 7. Session Customization
- [ ] Per-session custom commands on startup
- [ ] Session-specific color schemes
- [ ] Custom session names/labels

---

## 🟢 LOW Priority

### 8. Plugin System
- [ ] Support for tmux plugins (TPM)
- [ ] Custom key binding extensions
- [ ] Session templates

### 9. Monitoring Dashboard
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
