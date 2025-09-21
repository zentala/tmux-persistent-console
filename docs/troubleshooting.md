# 🚨 Troubleshooting Guide

> Solutions for common issues with Tmux Persistent Console

## 🔍 Quick Diagnostics

### Check System Status
```bash
# Verify tmux installation
tmux -V

# List all sessions
tmux ls

# Check if console sessions exist
tmux ls | grep console

# Verify tmux configuration
tmux show-options -g
```

## ❌ Installation Issues

### "tmux: command not found"

**Solution**: Install tmux
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install tmux

# CentOS/RHEL/Fedora
sudo yum install tmux
# or
sudo dnf install tmux

# macOS with Homebrew
brew install tmux

# macOS with MacPorts
sudo port install tmux
```

### "Permission denied" during installation

**Solution**: Check permissions and sudo access
```bash
# Check if you have sudo rights
sudo -l

# Alternative: Install to user directory
mkdir -p ~/bin
# Use local installation method from README
```

### Install script fails to download

**Solution**: Manual installation
```bash
# Clone repository instead
git clone https://github.com/YOUR_USERNAME/tmux-persistent-console.git
cd tmux-persistent-console
./install.sh
```

## 🔌 Session Issues

### "no sessions" when running tmux ls

**Solution**: Create console sessions
```bash
# Run setup script
setup-console-sessions

# Or manually
~/.tmux-persistent-console/setup.sh

# Or create manually
for i in {1..7}; do
    tmux new-session -d -s "console-$i"
done
```

### "sessions should be nested with care"

**Problem**: Trying to attach while already in tmux

**Solution**: Detach first
```bash
# Method 1: Detach and reattach
Ctrl+b, d  # Detach from current session
tmux attach -t console-1

# Method 2: Switch directly (if using persistent console config)
Ctrl+F1  # Switch to console-1

# Method 3: Kill current session
tmux kill-session -t current-session-name
```

### Sessions keep disappearing

**Solution**: Check for automatic cleanup
```bash
# Disable tmux server exit when no sessions
# Add to ~/.tmux.conf:
set -g exit-empty off

# Check for system scripts killing tmux
ps aux | grep tmux
sudo systemctl status tmux  # If using systemd service
```

## ⌨️ Function Key Issues

### Ctrl+F keys don't work

**Problem**: Terminal doesn't send function key sequences

**Diagnosis**:
```bash
# Test key detection
cat -v
# Press Ctrl+F1, should show: ^[[1;5P or similar

# Check terminal type
echo $TERM
```

**Solutions**:

#### For Windows Terminal
```json
// In settings.json, add to profile:
{
  "name": "Server Connection",
  "commandline": "ssh user@server",
  "experimental.input.forceVT": true
}
```

#### For PuTTY
1. Go to: Configuration → Terminal → Keyboard
2. Set "Function keys and keypad" to "ESC[n~"
3. Check "Disable application keypad mode"

#### For macOS Terminal
1. Terminal → Preferences → Profiles → Keyboard
2. Check "Use Option as Meta key"

#### For Linux Terminal Emulators
```bash
# For gnome-terminal
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ f1 'disabled'

# For xterm, add to ~/.Xresources:
XTerm*metaSendsEscape: true
```

### Alternative Key Bindings
If function keys don't work, use backup methods:

```bash
# Traditional tmux prefix method
Ctrl+b, 1  # Switch to console-1
Ctrl+b, 2  # Switch to console-2
# etc.

# Or session list
Ctrl+b, s  # Show session list (navigate with arrows)
```

## 🌐 SSH Connection Issues

### Connection drops frequently

**Solution**: Optimize SSH settings
```bash
# Add to ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

**Server-side** (add to `/etc/ssh/sshd_config`):
```bash
ClientAliveInterval 60
ClientAliveCountMax 3
```

### "Connection refused"

**Diagnosis**:
```bash
# Test basic SSH connection
ssh user@server "echo 'SSH works'"

# Check SSH service on server
sudo systemctl status ssh  # Ubuntu/Debian
sudo systemctl status sshd # CentOS/RHEL
```

### SSH key authentication fails

**Solution**:
```bash
# Generate new key pair
ssh-keygen -t ed25519 -C "console-access"

# Copy to server
ssh-copy-id user@server

# Test key authentication
ssh -o PreferredAuthentications=publickey user@server
```

## 🔧 Configuration Issues

### Tmux config not loading

**Diagnosis**:
```bash
# Check config file location
ls -la ~/.tmux.conf

# Test config syntax
tmux source-file ~/.tmux.conf
```

**Solution**:
```bash
# Reload tmux configuration
tmux source-file ~/.tmux.conf

# Or restart tmux server
tmux kill-server
tmux new-session
```

### Function key bindings not working

**Solution**: Verify tmux configuration
```bash
# Check if bindings are loaded
tmux list-keys | grep F1

# Should show: bind-key -T root C-F1 switch-client -t console-1

# If missing, reload config
tmux source-file ~/.tmux.conf
```

### Colors look wrong

**Solution**: Fix terminal colors
```bash
# Set proper TERM variable
export TERM=tmux-256color

# Or for SSH
ssh -o SendEnv=TERM user@server

# Add to ~/.bashrc or ~/.zshrc
echo 'export TERM=tmux-256color' >> ~/.bashrc
```

## 🖥️ Terminal Emulator Specific Issues

### Windows Terminal

#### Function keys send wrong codes
```json
// Add to Windows Terminal settings.json profile:
{
  "experimental.input.forceVT": true,
  "antialiasingMode": "cleartype"
}
```

#### Colors not displaying correctly
```json
{
  "colorScheme": "Campbell",
  "experimental.rendering.forceFullRepaint": true
}
```

### iTerm2 (macOS)

#### Function keys intercepted by system
1. iTerm2 → Preferences → Profiles → Keys
2. Click "+" to add key mapping
3. Map Ctrl+F1 to "Send Text" with value: `\033[1;5P`

### GNOME Terminal (Linux)

#### Function keys used by desktop environment
```bash
# Disable GNOME shortcuts that conflict
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['']"
# Continue for other F-keys
```

## 📱 Mobile Client Issues

### iOS/iPadOS

#### Blink Shell function keys
1. Settings → Keyboard → External Keyboard
2. Enable "Function Keys"
3. Map Ctrl+F1 through Ctrl+F7

#### Working Copy integration
```bash
# Use Working Copy's SSH terminal
# Configure server connection with:
tmux attach -t console-1
```

### Android

#### Termux setup
```bash
# Install packages
pkg install tmux openssh

# Configure external keyboard
mkdir -p ~/.termux
echo "extra-keys = [['Ctrl','F1','F2','F3','F4','F5','F6','F7']]" > ~/.termux/termux.properties
```

## 🔄 Performance Issues

### Slow session switching

**Solution**: Optimize tmux configuration
```bash
# Add to ~/.tmux.conf
set -g escape-time 0
set -g repeat-time 0
set -g focus-events on
```

### High CPU usage

**Diagnosis**:
```bash
# Check tmux processes
ps aux | grep tmux

# Monitor resource usage
htop
top -p $(pgrep tmux)
```

**Solution**:
```bash
# Reduce status bar updates
set -g status-interval 5

# Limit history
set -g history-limit 10000

# Disable mouse if not needed
set -g mouse off
```

### Memory issues

**Solution**:
```bash
# Clear session history
tmux clear-history -t console-1

# Reduce buffer size
set -g history-limit 5000

# Clean up dead sessions
tmux list-sessions | grep -v attached | cut -d: -f1 | xargs -t -n1 tmux kill-session -t
```

## 🔐 Security Issues

### Tmux sessions visible to other users

**Solution**: Check permissions
```bash
# Tmux socket permissions
ls -la /tmp/tmux-$(id -u)/

# Should show: drwx------ (700 permissions)

# Fix if needed
chmod 700 /tmp/tmux-$(id -u)/
```

### SSH agent forwarding not working

**Solution**:
```bash
# Enable agent forwarding
ssh -A user@server

# Or add to ~/.ssh/config
Host server
    ForwardAgent yes
```

## 🧹 Recovery Procedures

### Complete reset

```bash
# Kill all tmux sessions
tmux kill-server

# Remove tmux socket
rm -rf /tmp/tmux-*

# Restart console sessions
setup-console-sessions
```

### Backup and restore

```bash
# Backup tmux configuration
cp ~/.tmux.conf ~/.tmux.conf.backup

# Save session layouts
tmux list-sessions > ~/tmux-sessions-backup.txt

# Restore sessions (manual process)
# Review backup file and recreate important sessions
```

### Emergency access

```bash
# If console sessions are broken, create temporary session
tmux new-session -d -s emergency

# Or use screen as fallback
screen -S emergency
```

## 📞 Getting Help

### Generate diagnostic report

```bash
#!/bin/bash
# Create diagnostic report
{
    echo "=== Tmux Persistent Console Diagnostics ==="
    echo "Date: $(date)"
    echo "User: $(whoami)"
    echo "System: $(uname -a)"
    echo
    echo "=== Tmux Version ==="
    tmux -V
    echo
    echo "=== Sessions ==="
    tmux ls 2>&1
    echo
    echo "=== Configuration ==="
    cat ~/.tmux.conf 2>&1
    echo
    echo "=== Environment ==="
    env | grep -E "(TERM|SSH|TMUX)"
    echo
    echo "=== Process List ==="
    ps aux | grep tmux
} > ~/tmux-diagnostic-report.txt

echo "Diagnostic report saved to ~/tmux-diagnostic-report.txt"
```

### Common error patterns

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| `no sessions` | Sessions not created | Run `setup-console-sessions` |
| `can't find session` | Session name mismatch | Check with `tmux ls` |
| `sessions should be nested` | Already in tmux | Detach with `Ctrl+b, d` |
| `connection refused` | SSH/network issue | Check SSH configuration |
| `command not found` | Missing tmux/scripts | Install tmux, check PATH |

---

**💡 Pro Tip**: Keep a copy of this troubleshooting guide accessible offline in case you need to debug connection issues!