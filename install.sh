#!/bin/bash
# Tmux Persistent Console - One-line installer
# curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/.tmux-persistent-console"
BIN_DIR="$HOME/bin"

echo -e "${BLUE}==================================="
echo -e "  TMUX PERSISTENT CONSOLE INSTALLER"
echo -e "===================================${NC}"
echo ""

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}📦 Installing tmux...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v pacman &> /dev/null; then
            sudo pacman -S tmux
        else
            echo -e "${RED}❌ Cannot install tmux automatically. Please install tmux manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            echo -e "${RED}❌ Please install tmux using Homebrew: brew install tmux${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Tmux installed successfully${NC}"
fi

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Download or copy source files
if [ -d "./src" ]; then
    # Local installation
    echo -e "${YELLOW}📋 Copying local files...${NC}"
    cp src/* "$INSTALL_DIR/"
else
    # Remote installation
    echo -e "${YELLOW}⬇️  Downloading files...${NC}"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/setup.sh" -o "$INSTALL_DIR/setup.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/connect.sh" -o "$INSTALL_DIR/connect.sh"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/tmux.conf" -o "$INSTALL_DIR/tmux.conf"
    curl -sSL "https://raw.githubusercontent.com/YOUR_USERNAME/tmux-persistent-console/main/src/uninstall.sh" -o "$INSTALL_DIR/uninstall.sh"
fi

# Make scripts executable
chmod +x "$INSTALL_DIR"/*.sh

# Backup existing tmux config
if [ -f "$HOME/.tmux.conf" ]; then
    echo -e "${YELLOW}💾 Backing up existing tmux config...${NC}"
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Install tmux configuration
echo -e "${YELLOW}⚙️  Installing tmux configuration...${NC}"
echo "# tmux-persistent-console config" > "$HOME/.tmux.conf"
cat "$INSTALL_DIR/tmux.conf" >> "$HOME/.tmux.conf"

# Create convenient commands
echo -e "${YELLOW}🔗 Creating command aliases...${NC}"

# Create setup command
cat > "$BIN_DIR/setup-console-sessions" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/setup.sh "$@"
EOF

# Create connect command
cat > "$BIN_DIR/connect-console" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/connect.sh "$@"
EOF

# Create console help command
cat > "$BIN_DIR/console-help" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/console-help.sh "$@"
EOF

# Create uninstall command
cat > "$BIN_DIR/uninstall-console" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/uninstall.sh "$@"
EOF

chmod +x "$BIN_DIR"/*

# Add to PATH and safe-exit if needed
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}🛤️  Adding $BIN_DIR to PATH...${NC}"

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ]; then
        echo "" >> "$HOME/.bashrc"
        echo "# tmux-persistent-console" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
        echo "" >> "$HOME/.bashrc"
        echo "# Safe exit wrapper for tmux sessions" >> "$HOME/.bashrc"
        echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> "$HOME/.bashrc"
    fi

    # Add to zshrc
    if [ -f "$HOME/.zshrc" ]; then
        echo "" >> "$HOME/.zshrc"
        echo "# tmux-persistent-console" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.zshrc"
        echo "" >> "$HOME/.zshrc"
        echo "# Safe exit wrapper for tmux sessions" >> "$HOME/.zshrc"
        echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh" >> "$HOME/.zshrc"
    fi

    # Add to current session
    export PATH="$BIN_DIR:$PATH"
fi

# Create initial sessions
echo -e "${YELLOW}🚀 Creating console sessions...${NC}"
"$INSTALL_DIR/setup.sh"

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo -e "   ${YELLOW}connect-console${NC}           # Interactive session menu"
echo -e "   ${YELLOW}tmux attach -t console-1${NC}  # Direct to console-1"
echo ""
echo -e "${BLUE}🔥 Function Keys (from within tmux):${NC}"
echo -e "   ${YELLOW}Ctrl+F1-F7${NC}  Jump to console 1-7"
echo -e "   ${YELLOW}Ctrl+F8${NC}     Disconnect"
echo -e "   ${YELLOW}Ctrl+F12${NC}    Show all sessions"
echo ""
echo -e "${BLUE}🌐 Remote SSH Access:${NC}"
echo -e "   ${YELLOW}ssh user@server -t \"tmux attach -t console-1\"${NC}"
echo ""
echo -e "${BLUE}🗑️  Uninstall:${NC}"
echo -e "   ${YELLOW}uninstall-console${NC}"
echo ""
echo -e "${GREEN}🎉 Your work is now crash-resistant! Enjoy coding with AI CLI tools!${NC}"
echo ""