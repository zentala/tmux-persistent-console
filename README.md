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
| Key | Action |
|-----|--------|
| `Ctrl+F1` | Switch to console-1 |
| `Ctrl+F2` | Switch to console-2 |
| `Ctrl+F3` | Switch to console-3 |
| `Ctrl+F4` | Switch to console-4 |
| `Ctrl+F5` | Switch to console-5 |
| `Ctrl+F6` | Switch to console-6 |
| `Ctrl+F7` | Switch to console-7 |
| `Ctrl+F8` | Disconnect (detach) |
| `Ctrl+F9` | Toggle last session |
| `Ctrl+F10` | Previous session |
| `Ctrl+F11` | Next session |
| `Ctrl+F12` | Show all sessions list |

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

## 🚨 Troubleshooting

### Sessions Don't Exist
```bash
# Run setup script
setup-console-sessions
# or
~/tmux-persistent-console/src/setup.sh
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

## 🔗 Related Projects

- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) - Session manager with preview
- [Claude Code](https://claude.ai/code) - AI-powered coding assistant

---

**⭐ Star this repo if it saved your work from an SSH crash!**

Made with ❤️ for remote workers, sysadmins, and AI CLI enthusiasts.