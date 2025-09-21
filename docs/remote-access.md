# 🌐 Remote Access Guide

> Connect to your persistent console sessions from anywhere

## Quick Reference

### Direct Session Access
```bash
# Connect directly to specific console
ssh user@server -t "tmux attach -t console-1"
ssh user@server -t "tmux attach -t console-2"
# ... through console-7
```

### Interactive Menu Access
```bash
# Use the connect script for session selection
ssh user@server -t "connect-console"
# or full path if not in PATH
ssh user@server -t "/home/user/.tmux-persistent-console/connect.sh"
```

## 🖥️ Windows Terminal Integration

### Create Server Profiles
Add these profiles to your Windows Terminal `settings.json`:

```json
{
  "profiles": {
    "list": [
      {
        "name": "🖥️ Server Console Menu",
        "commandline": "ssh user@your-server.com -t \"connect-console\"",
        "icon": "📟",
        "colorScheme": "Campbell"
      },
      {
        "name": "🤖 Claude Code Console",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-1\"",
        "icon": "🤖",
        "colorScheme": "One Half Dark"
      },
      {
        "name": "🎪 Copilot Console",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-2\"",
        "icon": "🎪",
        "colorScheme": "Solarized Dark"
      },
      {
        "name": "💻 Development Console",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-3\"",
        "icon": "💻",
        "colorScheme": "Campbell Powershell"
      },
      {
        "name": "🧪 Testing Console",
        "commandline": "ssh user@your-server.com -t \"tmux attach -t console-4\"",
        "icon": "🧪",
        "colorScheme": "Vintage"
      }
    ]
  }
}
```

### Keyboard Shortcuts
Add to Windows Terminal `settings.json`:

```json
{
  "actions": [
    {
      "command": { "action": "newTab", "profile": "🤖 Claude Code Console" },
      "keys": "ctrl+alt+1"
    },
    {
      "command": { "action": "newTab", "profile": "🎪 Copilot Console" },
      "keys": "ctrl+alt+2"
    },
    {
      "command": { "action": "newTab", "profile": "💻 Development Console" },
      "keys": "ctrl+alt+3"
    }
  ]
}
```

## 🍎 macOS Terminal Integration

### iTerm2 Profiles
1. **Create New Profile**: iTerm2 → Preferences → Profiles → New
2. **Set Command**: `ssh user@server -t "tmux attach -t console-1"`
3. **Set Hotkey**: Preferences → Keys → Hotkey Window
4. **Repeat for each console**

### macOS Terminal App
Create `.command` files on Desktop:

```bash
# ~/Desktop/Claude-Code-Console.command
#!/bin/bash
ssh user@server -t "tmux attach -t console-1"
```

```bash
# ~/Desktop/Server-Console-Menu.command
#!/bin/bash
ssh user@server -t "connect-console"
```

Make executable: `chmod +x ~/Desktop/*.command`

## 📱 Mobile Access

### iOS (iPad/iPhone)

#### Blink Shell
```bash
# Add server configuration
blink> config

# Create session shortcuts
ssh server -t "tmux attach -t console-1"
```

#### Termius
1. **Add Host**: Settings → Hosts → Add
2. **Set Command**: `tmux attach -t console-1`
3. **Create Snippet**: For quick console switching

### Android

#### JuiceSSH
1. **Create Connection**: server details
2. **Set Post-login Command**: `tmux attach -t console-1`
3. **Create Shortcuts**: For each console

#### Termux
```bash
# Install SSH client
pkg install openssh

# Connect with session
ssh user@server -t "tmux attach -t console-1"
```

## 🔐 SSH Configuration

### Client SSH Config (`~/.ssh/config`)
```bash
# Server console access
Host server-console
    HostName your-server.com
    User your-username
    Port 22
    RequestTTY force
    RemoteCommand connect-console

# Direct console access
Host server-console-1
    HostName your-server.com
    User your-username
    RequestTTY force
    RemoteCommand tmux attach -t console-1

Host server-console-2
    HostName your-server.com
    User your-username
    RequestTTY force
    RemoteCommand tmux attach -t console-2

# Continue for console-3 through console-7
```

### Usage with SSH Config
```bash
# Interactive menu
ssh server-console

# Direct console access
ssh server-console-1
ssh server-console-2
# etc.
```

## 🔧 Advanced Remote Features

### SSH Multiplexing
Add to `~/.ssh/config` for faster connections:

```bash
Host *
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%h:%p
    ControlPersist 10m
```

### Port Forwarding with Consoles
```bash
# Forward web services while in console
ssh -L 8080:localhost:8080 user@server -t "tmux attach -t console-3"

# Access local:8080 for server's port 8080
```

### SSH Keys for Seamless Access
```bash
# Generate key pair
ssh-keygen -t ed25519 -C "console-access"

# Copy to server
ssh-copy-id user@server

# Now connect without password
ssh user@server -t "tmux attach -t console-1"
```

## 🌍 Multi-Server Setup

### Managing Multiple Servers
```bash
# ~/.ssh/config for multiple servers
Host dev-server-console
    HostName dev.example.com
    User dev-user
    RequestTTY force
    RemoteCommand connect-console

Host prod-server-console
    HostName prod.example.com
    User prod-user
    RequestTTY force
    RemoteCommand connect-console

Host staging-console-1
    HostName staging.example.com
    User staging-user
    RequestTTY force
    RemoteCommand tmux attach -t console-1
```

### Server Selector Script
Create `~/bin/console-selector`:

```bash
#!/bin/bash
echo "Select server:"
echo "1) Development"
echo "2) Staging"
echo "3) Production"
read -r choice

case $choice in
    1) ssh dev-server-console ;;
    2) ssh staging-server-console ;;
    3) ssh prod-server-console ;;
    *) echo "Invalid choice" ;;
esac
```

## 🔄 Session Recovery

### Automatic Reconnection
Create `~/bin/auto-console`:

```bash
#!/bin/bash
SERVER="user@your-server.com"
CONSOLE="console-1"

while true; do
    echo "Connecting to $CONSOLE on $SERVER..."
    ssh $SERVER -t "tmux attach -t $CONSOLE"

    echo "Connection lost. Reconnecting in 5 seconds..."
    sleep 5
done
```

### Health Check Script
```bash
#!/bin/bash
# Check if console sessions are running
ssh user@server "tmux ls | grep console || echo 'Sessions missing - run setup-console-sessions'"
```

## 🚨 Troubleshooting Remote Access

### Common Issues

#### "Session not found"
```bash
# Create sessions on server
ssh user@server "setup-console-sessions"
```

#### "Permission denied"
```bash
# Check SSH key authentication
ssh-add -l

# Test SSH connection
ssh user@server "echo 'SSH works'"
```

#### "tmux: command not found"
```bash
# Install tmux on server
ssh user@server "sudo apt install tmux"  # Ubuntu/Debian
ssh user@server "sudo yum install tmux"  # CentOS/RHEL
```

#### Function Keys Don't Work Remotely
```bash
# Check terminal type
echo $TERM

# Set proper terminal in SSH
ssh -o SendEnv=TERM user@server -t "tmux attach -t console-1"
```

### Network Issues

#### Unstable Connections
```bash
# Use autossh for persistent connection
autossh -M 20000 user@server -t "tmux attach -t console-1"
```

#### Connection Timeouts
Add to `~/.ssh/config`:

```bash
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## 📊 Performance Optimization

### Reducing Latency
```bash
# Use compression for slow connections
ssh -C user@server -t "tmux attach -t console-1"

# Disable unnecessary features
ssh -o Compression=yes -o TCPKeepAlive=yes user@server
```

### Bandwidth Optimization
```bash
# Reduce tmux status update frequency
# Add to server's ~/.tmux.conf:
set -g status-interval 5

# Limit history for remote connections
set -g history-limit 5000
```

## 🔗 Integration Examples

### VS Code Remote SSH
```bash
# Use tmux with VS Code Remote SSH
# In VS Code settings.json:
{
  "remote.SSH.defaultExtensions": ["ms-vscode-remote.remote-ssh"],
  "terminal.integrated.defaultProfile.linux": "tmux",
  "terminal.integrated.profiles.linux": {
    "tmux": {
      "path": "ssh",
      "args": ["user@server", "-t", "tmux attach -t console-3"]
    }
  }
}
```

### Browser-Based Access
```bash
# Use ttyd for web-based terminal
ssh user@server "tmux attach -t console-1 | ttyd --port 8080 bash"
# Access via browser at server:8080
```

---

**💡 Pro Tip**: Create a simple launcher script that tests connection and automatically falls back to session creation if sessions don't exist!