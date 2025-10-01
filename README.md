# 🖥️ Tmux Persistent Console

> **Never lose your work when SSH crashes again!**
> 7 persistent tmux sessions with instant Ctrl+F switching - perfect for Claude Code, AI CLI tools, and remote server management.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![Tmux](https://img.shields.io/badge/Tmux-Compatible-green.svg)](https://github.com/tmux/tmux)

## 🚨 The Problem

Working on remote servers with AI CLI tools (Claude Code, GitHub Copilot CLI) or during system updates, and your SSH connection crashes? **You lose everything!**

- Long-running operations interrupted
- AI-assisted coding sessions lost
- System updates leave you disconnected
- No easy way to return to your exact workspace

## ✅ The Solution

**Tmux Persistent Console** gives you 7 persistent tmux sessions that survive anything:

- ✅ SSH connection drops
- ✅ Network issues during updates
- ✅ Server reboots
- ✅ Long-running AI CLI operations
- ✅ Unstable WiFi connections

## ✨ Features

### 🚀 Instant Session Switching
- **Ctrl+F1-F7**: Jump directly to console-1 through console-7
- **Ctrl+F8**: Disconnect safely
- **Ctrl+F9**: Toggle last session
- **Ctrl+F10/F11**: Previous/Next session
- **Ctrl+F12**: Show all sessions

### 🛡️ Crash-Resistant Design
- Sessions persist across SSH disconnects
- Survives server reboots (with proper setup)
- Auto-recovery from network issues
- Work continues exactly where you left off

### 🤖 AI CLI Optimized
Perfect companion for:
- **Claude Code** remote development sessions
- **GitHub Copilot CLI** workflows
- Long AI-assisted coding sessions
- Remote server maintenance with AI tools

### 🖥️ Windows Terminal Friendly
- Function keys work perfectly in Windows Terminal
- No complex key combinations to remember
- Visual session indicators
- Easy remote access setup

## 🚀 Quick Start

### One-Line Installation
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/install.sh | bash
```

### Instant Usage
```bash
# Connect interactively
connect-console

# Or directly to specific console
tmux attach -t console-1

# From remote (SSH)
ssh user@server -t "tmux attach -t console-1"
```

## 🎯 Perfect For

### 👨‍💻 AI CLI Users
- **Claude Code** sessions that survive disconnects
- **GitHub Copilot CLI** long conversations
- AI-assisted debugging and development
- Remote pair programming with AI

### 🔧 System Administrators
- Server updates and maintenance
- Monitoring multiple services
- Long-running deployment scripts
- Emergency troubleshooting

### 🌐 Remote Workers
- Unstable internet connections
- Working across multiple time zones
- Switching between different client servers
- Mobile/travel development

## 📖 Key Bindings Reference

### 🚀 Function Keys (Instant Access)
| Key | Action | Purpose |
|-----|--------|---------|
| `Ctrl+F1` | 🤖 Console-1 | Claude Code / AI Development |
| `Ctrl+F2` | 🎪 Console-2 | GitHub Copilot CLI |
| `Ctrl+F3` | 💻 Console-3 | General Development |
| `Ctrl+F4` | 🧪 Console-4 | Testing & QA |
| `Ctrl+F5` | 📊 Console-5 | Monitoring & Logs |
| `Ctrl+F6` | 🌐 Console-6 | Git & Deployment |
| `Ctrl+F7` | 🔧 Console-7 | System Administration |
| `Ctrl+F8` | 🚪 Disconnect | Safely detach session |
| `Ctrl+F9` | 🔄 Toggle last | Switch to previous session |
| `Ctrl+F10` | ⬅️ Previous | Navigate sessions |
| `Ctrl+F11` | ➡️ Next | Navigate sessions |
| `Ctrl+F12` | 📋 **Help Menu** | **First-time user guide!** |

### ⚡ Additional Features
| Key | Action | Purpose |
|-----|--------|---------|
| `Ctrl+Alt+R` | 🔄 Reset Terminal | Clear & refresh current terminal |
| `console-help` | 📖 Help Menu | Access advanced help anytime |

### 🔄 Backup Method (Traditional)
| Key | Action |
|-----|--------|
| `Ctrl+b, s` | Visual session list |
| `Ctrl+b, 1-7` | Switch to console 1-7 |
| `Ctrl+b, (` | Previous session |
| `Ctrl+b, )` | Next session |
| `Ctrl+b, L` | Last used session |

## 🔧 Advanced Usage

### Remote SSH Access
```bash
# Direct connection to specific console
ssh user@server -t "tmux attach -t console-1"

# Interactive menu connection
ssh user@server -t "/path/to/connect-console"

# Windows Terminal profile
{
  "name": "Server Console 1",
  "commandline": "ssh user@server -t 'tmux attach -t console-1'",
  "icon": "📟"
}
```

### Session Management
```bash
# List all sessions
tmux ls

# Kill specific session
tmux kill-session -t console-1

# Reset all sessions
tmux kill-server && setup-console-sessions

# Create additional sessions
tmux new-session -d -s "project-work"
```

## 🤖 AI CLI Workflow Examples

### Claude Code Remote Development
```bash
# Console-1: Main Claude Code session
ssh server -t "tmux attach -t console-1"
# Run: claude-code

# Console-2: File monitoring
ssh server -t "tmux attach -t console-2"
# Run: tail -f logs/app.log

# Console-3: Git operations
ssh server -t "tmux attach -t console-3"
# Ready for git commands

# Switch instantly with Ctrl+F1, Ctrl+F2, Ctrl+F3
```

### GitHub Copilot CLI Workflow
```bash
# Console-1: Copilot chat sessions
gh copilot explain "complex function"

# Console-2: Testing and execution
npm test

# Console-3: Git and deployment
git status && git push

# All sessions survive if SSH drops!
```

## 📁 Project Structure

```
tmux-persistent-console/
├── install.sh              # One-liner installer
├── src/
│   ├── setup.sh            # Creates 7 persistent sessions
│   ├── connect.sh          # Interactive connection menu
│   ├── tmux.conf           # Optimized tmux configuration
│   └── uninstall.sh        # Clean removal script
├── docs/
│   ├── ai-cli-workflow.md  # AI CLI integration guide
│   ├── remote-access.md    # SSH and remote setup
│   ├── windows-terminal.md # Windows Terminal configuration
│   └── troubleshooting.md  # Common issues and solutions
└── README.md               # This file
```

## 🛠️ Installation Details

### What It Does
1. Installs tmux configuration with function key bindings
2. Creates 7 persistent sessions (console-1 to console-7)
3. Sets up `connect-console` command alias
4. Configures optimal tmux settings for remote work

### System Requirements
- Linux/macOS with bash
- tmux 2.0+ (will install if missing)
- SSH access to remote servers

### Manual Installation
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/tmux-persistent-console.git
cd tmux-persistent-console

# Install
./install.sh

# Or copy files manually
cp src/tmux.conf ~/.tmux.conf
cp src/setup.sh ~/bin/setup-console-sessions
cp src/connect.sh ~/bin/connect-console
chmod +x ~/bin/*
```

### Auto-Start on System Boot (Systemd)
```bash
# Copy systemd service file
mkdir -p ~/.config/systemd/user
cp src/tmux-console.service ~/.config/systemd/user/

# Enable and start service
systemctl --user daemon-reload
systemctl --user enable tmux-console.service
systemctl --user start tmux-console.service

# Enable user lingering (sessions persist after logout)
sudo loginctl enable-linger $USER

# Check status
systemctl --user status tmux-console.service
```

## 🚨 Troubleshooting

### Sessions Don't Exist After Reboot
```bash
# Option 1: Run setup script manually
setup-console-sessions
# or
~/.vps/sessions/src/setup.sh

# Option 2: Setup auto-start with systemd (recommended)
# See "Auto-Start on System Boot" section above
```

### Function Keys Don't Work
- Check terminal emulator settings
- Verify TERM environment variable: `echo $TERM`
- See [troubleshooting guide](docs/troubleshooting.md)

### "Sessions Should Be Nested With Care"
```bash
# You're already in tmux, detach first
Ctrl+b, d
# Then connect to desired session
```

### SSH Connection Issues
- Verify SSH key authentication
- Check network connectivity
- See [remote access guide](docs/remote-access.md)

## 🤝 Contributing

Contributions welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

### Ideas for Contributions
- Additional key bindings
- Integration with other terminal multiplexers
- Docker/container support
- More AI CLI tool integrations
- Windows WSL optimization

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🌟 Why This Exists

Created out of frustration with losing hours of work when SSH connections crashed during:
- Remote server updates with Claude Code
- Long AI CLI sessions that took time to rebuild context
- System maintenance that couldn't be interrupted
- Collaborative debugging sessions

**This tool makes remote server work with AI CLI tools much simpler and safer!**

## 🧪 Testing Infrastructure

Want to test tmux-persistent-console on a real server? We provide automated testing infrastructure using **Oracle Cloud Free Tier**!

### Quick Test Deployment
```bash
# 1. Clone repository
git clone https://github.com/zentala/tmux-persistent-console.git
cd tmux-persistent-console

# 2. Setup Oracle Cloud credentials
cp tests/terraform/terraform.tfvars.example tests/terraform/terraform.tfvars
# Edit with your Oracle Cloud details

# 3. Deploy test server (FREE!)
cd tests/scripts
./deploy.sh

# 4. Run comprehensive tests
./test-remote.sh

# 5. Interactive testing
./interactive-test.sh

# 6. Cleanup when done
./destroy.sh
```

### What You Get
- **Free ARM server** (4 cores, 24GB RAM) on Oracle Cloud
- **Automated installation** and configuration
- **Comprehensive test suite** with 10+ test scenarios
- **Interactive testing menu** for manual validation
- **One-click deployment/cleanup**

See [`tests/README.md`](tests/README.md) for detailed testing documentation.

**🎉 Test your tmux-persistent-console setup risk-free on real cloud infrastructure!**

## 🔗 Related Projects

- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) - Session manager with preview
- [Claude Code](https://claude.ai/code) - AI-powered coding assistant

---

**⭐ Star this repo if it saved your work from an SSH crash!**

Made with ❤️ for remote workers, sysadmins, and AI CLI enthusiasts.