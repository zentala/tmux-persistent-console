#!/bin/bash
# pTTY - One-line installer
# curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash

set -e
umask 022
trap 'echo "[pTTY] Install failed at line $LINENO — nothing may be partially configured; re-run install.sh after fixing the error above." >&2' ERR

PTTY_VERSION="0.2.1"
MIN_TMUX_VERSION="3.2"

# Remote files are pinned to a tagged release by default (integrity-verified
# against SHA256SUMS below). Set PTTY_REF=main for a dev install that tracks
# the branch tip (unverified against the pinned MANIFEST_SHA256 — expect the
# manifest check to fail unless you also override MANIFEST_SHA256).
PTTY_REF="${PTTY_REF:-v$PTTY_VERSION}"

# sha256 of the SHA256SUMS manifest at $PTTY_REF, generated with
# tools/gen-sha256sums.sh. Every remote-downloaded file is verified against
# entries in that manifest before it is made executable.
MANIFEST_SHA256="3beda5d631b1b08446a14625930f2c324eddcedebc286314748eea15519f4dfd"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse flags
DRY_RUN=0
NO_SYSTEMD=0
UPDATE_MODE=0
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        --no-systemd) NO_SYSTEMD=1 ;;
        --update|-u) UPDATE_MODE=1 ;;
        --version|-V) echo "pTTY v$PTTY_VERSION"; exit 0 ;;
        --help|-h)
            cat <<EOF
Usage: install.sh [--dry-run] [--update] [--no-systemd] [--version] [--help]

  --dry-run     Show what would happen without changing anything
  --update      Refresh an existing install: skip dependency installs, replace
                installed files, remove files dropped from the release, reload
                the live tmux config (sessions keep running)
  --no-systemd  Skip systemd user service setup and create sessions directly
  --version     Print version and exit
  --help        This help

One-liner install:
  curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash
EOF
            exit 0
            ;;
    esac
done

# Configuration
INSTALL_DIR="$HOME/.tmux-persistent-console"
BIN_DIR="$HOME/bin"

echo -e "${BLUE}==================================="
echo -e "  pTTY INSTALLER v$PTTY_VERSION"
echo -e "===================================${NC}"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "${YELLOW}DRY-RUN MODE — would perform:${NC}"
    echo "  0. Request sudo up front if package installs are needed"
    echo "  1. Install missing deps:           tmux, fzf, gum (via apt/yum/pacman/brew)"
    echo "  2. Create directories:             $INSTALL_DIR, $BIN_DIR"
    echo "  3. Copy scripts:                   src/* → $INSTALL_DIR/"
    echo "  4. Install tmux.conf:              $INSTALL_DIR/tmux.conf → ~/.tmux.conf (backup made)"
    echo "  5. Add PATH + safe-exit hooks to:  ~/.bashrc, ~/.zshrc"
    echo "  6. Install systemd user service:   ~/.config/systemd/user/tmux-console.service"
    echo "  7. Enable user lingering:          loginctl enable-linger \$USER"
    echo "  8. Enable + start service:         systemctl --user enable --now tmux-console.service"
    echo "  9. Verify service is active and console-1..console-10 exist"
    echo ""
    echo "With --no-systemd: skip steps 6-8 and create sessions directly."
    echo ""
    echo "To actually install, re-run without --dry-run."
    exit 0
fi

# Warn if a legacy install layout is still around
if [ -d "$HOME/.vps/sessions" ]; then
    echo -e "${YELLOW}⚠️  Legacy install detected at ~/.vps/sessions${NC}"
    echo -e "${YELLOW}   You can safely remove it after this install finishes:${NC}"
    echo -e "${YELLOW}     rm -rf ~/.vps/sessions${NC}"
    echo ""
fi

# Detect container / CI environments.
CONTAINER_CI=0
SKIP_TUI_DEPS=0
if [ -f /.dockerenv ] || [ -n "${CI:-}" ] || [ -n "${CONTAINER:-}" ]; then
    CONTAINER_CI=1
    SKIP_TUI_DEPS=1
    echo -e "${YELLOW}📦 Container/CI environment detected — skipping optional TUI deps (gum, fzf)${NC}"
    echo -e "${YELLOW}   Set SKIP_TUI_DEPS=0 to force install them.${NC}"
fi

if [ "$UPDATE_MODE" -eq 1 ]; then
    SKIP_TUI_DEPS=1
    echo -e "${YELLOW}🔄 Update mode — refreshing installed files, dependencies untouched${NC}"
fi

# Request sudo up front (once) if a later step is going to need it, instead of
# prompting mid-install. Only ask when a package manager install is actually
# on the path: tmux missing, or TUI deps (fzf/gum, apt/snap) will be installed.
NEEDS_SUDO=0
if [[ "$OSTYPE" != "darwin"* ]]; then
    if ! command -v tmux &> /dev/null; then
        NEEDS_SUDO=1
    fi
    if [ "$SKIP_TUI_DEPS" -eq 0 ]; then
        NEEDS_SUDO=1
    fi
fi

if [ "$NEEDS_SUDO" -eq 1 ]; then
    # Files downloaded below (gum tarball, remote pTTY scripts) are sha256
    # verified before use — sudo only ever installs or moves checked bytes.
    echo -e "${YELLOW}🔑 This install needs sudo to install missing packages (tmux/fzf/gum) via your package manager.${NC}"
    if [ -t 0 ]; then
        sudo -v || { echo -e "${RED}❌ sudo access is required but was not granted.${NC}"; exit 1; }
    else
        echo -e "${YELLOW}⚠️  No TTY detected (e.g. curl | bash) — sudo may prompt and fail non-interactively.${NC}"
        echo -e "${YELLOW}   If a package install below fails, clone the repo and run ./install.sh directly:${NC}"
        echo -e "${YELLOW}     git clone https://github.com/zentala/pTTY.git && cd pTTY && ./install.sh${NC}"
    fi
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}📦 Installing tmux...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux || {
                echo -e "${RED}❌ apt-get install tmux failed. Fix apt (network/sources) and re-run, or: sudo apt-get install -y tmux${NC}"
                exit 1
            }
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux || {
                echo -e "${RED}❌ yum install tmux failed. Fix yum repos and re-run, or: sudo yum install -y tmux${NC}"
                exit 1
            }
        elif command -v pacman &> /dev/null; then
            sudo pacman -S tmux || {
                echo -e "${RED}❌ pacman install tmux failed. Fix pacman and re-run, or: sudo pacman -S tmux${NC}"
                exit 1
            }
        else
            echo -e "${RED}❌ Cannot install tmux automatically. Please install tmux manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux || {
                echo -e "${RED}❌ brew install tmux failed. Fix Homebrew and re-run, or: brew install tmux${NC}"
                exit 1
            }
        else
            echo -e "${RED}❌ Please install tmux using Homebrew: brew install tmux${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Tmux installed successfully${NC}"
fi

tmux_version_ge() {
    local actual="$1"
    local required="$2"
    local actual_major actual_minor required_major required_minor

    actual="${actual#tmux }"
    actual="${actual%%[!0-9.]*}"
    required="${required%%[!0-9.]*}"

    actual_major="${actual%%.*}"
    actual_minor="${actual#*.}"
    actual_minor="${actual_minor%%.*}"
    required_major="${required%%.*}"
    required_minor="${required#*.}"
    required_minor="${required_minor%%.*}"

    actual_minor="${actual_minor:-0}"
    required_minor="${required_minor:-0}"
    actual_major="${actual_major:-0}"
    required_major="${required_major:-0}"

    if [ "$actual_major" -gt "$required_major" ]; then
        return 0
    fi
    if [ "$actual_major" -eq "$required_major" ] && [ "$actual_minor" -ge "$required_minor" ]; then
        return 0
    fi
    return 1
}

TMUX_VERSION="$(tmux -V 2>/dev/null || true)"
if ! tmux_version_ge "$TMUX_VERSION" "$MIN_TMUX_VERSION"; then
    echo -e "${RED}❌ pTTY requires tmux ${MIN_TMUX_VERSION}+ for popup-based F11/F12 controls.${NC}"
    echo -e "${RED}   Detected: ${TMUX_VERSION:-unknown}${NC}"
    echo -e "${YELLOW}   Upgrade tmux with your OS package manager or install a newer tmux build.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ tmux version OK: $TMUX_VERSION${NC}"

# Install TUI tools (gum, fzf)
echo -e "${YELLOW}🎨 Installing TUI enhancements...${NC}"

if [ "$SKIP_TUI_DEPS" -eq 1 ]; then
    echo -e "${YELLOW}  ⏭️  Skipping TUI deps (container/CI mode)${NC}"
else

# Install fzf (fuzzy finder)
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}  Installing fzf...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fzf
        elif command -v yum &> /dev/null; then
            sudo yum install -y fzf
        elif command -v pacman &> /dev/null; then
            sudo pacman -S fzf
        else
            echo -e "${YELLOW}  ⚠️  fzf not available in package manager, trying git install...${NC}"
            echo -e "${YELLOW}  ⚠️  unpinned: cloning fzf's default branch tip, not a tagged release${NC}"
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --bin
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install fzf
        fi
    fi
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    echo -e "${GREEN}  ✅ fzf installed${NC}"
else
    echo -e "${GREEN}  ✅ fzf already installed${NC}"
fi

# Install gum (modern TUI)
# Pinned to v0.14.0; sha256 taken from the release's own checksums.txt
# (https://github.com/charmbracelet/gum/releases/download/v0.14.0/checksums.txt).
GUM_VERSION="0.14.0"
GUM_TARBALL="gum_${GUM_VERSION}_Linux_x86_64.tar.gz"
GUM_SHA256="bf93c39d706fbb48883d983b3a71cd8b1617599a70204953573b66ed0c133630"

download_gum_tarball() {
    # Stage in a private, unpredictable directory (0700) instead of fixed /tmp
    # paths. This keeps the sha256-verified artifact and the extracted binary
    # out of reach of other local users: on a shared host, predictable /tmp
    # names let an attacker win a race between extraction and the privileged
    # `sudo mv`, substituting their own binary into /usr/local/bin (CWE-377).
    local staging
    staging="$(mktemp -d)" || return 1
    # shellcheck disable=SC2064
    trap "rm -rf '$staging'" RETURN

    local dest="$staging/gum.tar.gz"
    if ! wget -q "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/${GUM_TARBALL}" -O "$dest"; then
        echo -e "${RED}  ❌ Failed to download $GUM_TARBALL${NC}"
        return 1
    fi
    local actual_sha256
    actual_sha256="$(sha256sum "$dest" | awk '{print $1}')"
    if [ "$actual_sha256" != "$GUM_SHA256" ]; then
        echo -e "${RED}  ❌ sha256 mismatch for $GUM_TARBALL${NC}"
        echo -e "${RED}     expected: $GUM_SHA256${NC}"
        echo -e "${RED}     actual:   $actual_sha256${NC}"
        return 1
    fi
    tar -xzf "$dest" -C "$staging"
    sudo mv "$staging/gum" /usr/local/bin/
}

if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}  Installing gum...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Try snap first (most modern systems)
        if command -v snap &> /dev/null; then
            sudo snap install gum 2>/dev/null || {
                # Fallback to manual install
                echo -e "${YELLOW}  ⚠️  snap failed, trying manual install...${NC}"
                download_gum_tarball || echo -e "${YELLOW}  ⚠️  gum manual install failed, will use fallback TUI${NC}"
            }
        elif command -v apt-get &> /dev/null; then
            # Debian/Ubuntu - manual install
            download_gum_tarball || echo -e "${YELLOW}  ⚠️  gum manual install failed, will use fallback TUI${NC}"
        else
            echo -e "${YELLOW}  ⚠️  gum installation not available, will use fallback TUI${NC}"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install gum
        fi
    fi

    if command -v gum &> /dev/null; then
        echo -e "${GREEN}  ✅ gum installed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  gum not installed, TUI will fallback to fzf/whiptail${NC}"
    fi
else
    echo -e "${GREEN}  ✅ gum already installed${NC}"
fi
fi # end SKIP_TUI_DEPS block

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Resolve source location: if we are running from inside a cloned repo with src/,
# treat THAT as the source. If $PWD already IS $INSTALL_DIR (common: user cloned to
# ~/.tmux-persistent-console then ran ./install.sh), skip the copy step entirely —
# copying src/* over the repo root just creates phantom "modified" duplicates.
REPO_ROOT="$(pwd)"

if [ -d "$REPO_ROOT/src" ]; then
    if [ "$REPO_ROOT" = "$INSTALL_DIR" ]; then
        # The clone doubles as the runtime dir: tmux.conf references flat
        # files at the repo root, so src/ must be copied over them or the
        # runtime silently keeps running the previous version. The root
        # copies show up as untracked files in the clone — expected.
        echo -e "${YELLOW}📋 Install dir is a git clone — refreshing flat runtime files from src/${NC}"
        cp -r "$REPO_ROOT/src/"* "$INSTALL_DIR/"
        if [ -f "$REPO_ROOT/scripts/doctor.sh" ]; then
            cp "$REPO_ROOT/scripts/doctor.sh" "$INSTALL_DIR/doctor.sh"
        fi
    else
        echo -e "${YELLOW}📋 Copying local files from $REPO_ROOT/src to $INSTALL_DIR${NC}"
        cp -r "$REPO_ROOT/src/"* "$INSTALL_DIR/"
        if [ -d "$REPO_ROOT/src/tui" ]; then
            mkdir -p "$INSTALL_DIR/tui"
            cp -r "$REPO_ROOT/src/tui/"* "$INSTALL_DIR/tui/"
        fi
        if [ -d "$REPO_ROOT/src/lib" ]; then
            mkdir -p "$INSTALL_DIR/lib"
            cp -r "$REPO_ROOT/src/lib/"* "$INSTALL_DIR/lib/"
        fi
        if [ -f "$REPO_ROOT/scripts/doctor.sh" ]; then
            cp "$REPO_ROOT/scripts/doctor.sh" "$INSTALL_DIR/doctor.sh"
        fi
    fi
else
    # Remote installation (curl-piped install with no local checkout)
    REPO_URL_BASE="https://raw.githubusercontent.com/zentala/pTTY/$PTTY_REF"
    echo -e "${YELLOW}⬇️  Downloading files from ${REPO_URL_BASE}${NC}"

    # Fetch and pin-verify the manifest itself before trusting any entry in it.
    MANIFEST_FILE="$(mktemp)"
    if ! curl -fsSL "$REPO_URL_BASE/SHA256SUMS" -o "$MANIFEST_FILE"; then
        echo -e "${RED}❌ Failed to download SHA256SUMS from $REPO_URL_BASE/SHA256SUMS${NC}"
        echo -e "${RED}   Most likely the release ref '$PTTY_REF' does not exist on GitHub or${NC}"
        echo -e "${RED}   does not contain SHA256SUMS. Please report this at:${NC}"
        echo -e "${RED}     https://github.com/zentala/pTTY/issues${NC}"
        echo -e "${YELLOW}   Workaround (dev install, tracks branch tip):${NC}"
        echo -e "${YELLOW}     curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | PTTY_REF=main bash${NC}"
        exit 1
    fi
    ACTUAL_MANIFEST_SHA256="$(sha256sum "$MANIFEST_FILE" | awk '{print $1}')"
    if [ "$ACTUAL_MANIFEST_SHA256" != "$MANIFEST_SHA256" ]; then
        echo -e "${RED}❌ SHA256SUMS manifest sha256 mismatch — refusing to trust remote files${NC}"
        echo -e "${RED}   expected: $MANIFEST_SHA256${NC}"
        echo -e "${RED}   actual:   $ACTUAL_MANIFEST_SHA256${NC}"
        exit 1
    fi

    # Verifies $file's sha256 against the entry for $relpath in $manifest.
    # Aborts the install on any mismatch or missing entry.
    verify_sha256() {
        local file="$1" relpath="$2" manifest="$3"
        local expected actual
        expected="$(awk -v p="$relpath" '$2 == p { print $1 }' "$manifest")"
        if [ -z "$expected" ]; then
            echo -e "${RED}❌ No manifest entry for $relpath${NC}"
            return 1
        fi
        actual="$(sha256sum "$file" | awk '{print $1}')"
        if [ "$actual" != "$expected" ]; then
            echo -e "${RED}❌ sha256 mismatch for $relpath${NC}"
            echo -e "${RED}   expected: $expected${NC}"
            echo -e "${RED}   actual:   $actual${NC}"
            return 1
        fi
        return 0
    }

    for f in \
        setup.sh connect.sh tmux.conf tmux-console.service uninstall.sh \
        safe-exit.sh console-help.sh help-reference.sh \
        status-format-v4.tmux \
        theme-config.sh mission-control.sh shortcuts-popup.sh \
        click-session.sh restart-confirm.sh restart-session.sh; do
        if ! curl -fsSL "$REPO_URL_BASE/src/$f" -o "$INSTALL_DIR/$f"; then
            echo -e "${RED}❌ Failed to download $f from $REPO_URL_BASE/src/$f${NC}"
            exit 1
        fi
        verify_sha256 "$INSTALL_DIR/$f" "src/$f" "$MANIFEST_FILE" || exit 1
    done

    mkdir -p "$INSTALL_DIR/tui"
    for f in tui-core.sh tui-menu.sh tui-dialogs.sh tui-list.sh tui-status.sh; do
        if ! curl -fsSL "$REPO_URL_BASE/src/tui/$f" -o "$INSTALL_DIR/tui/$f"; then
            echo -e "${RED}❌ Failed to download tui/$f${NC}"
            exit 1
        fi
        verify_sha256 "$INSTALL_DIR/tui/$f" "src/tui/$f" "$MANIFEST_FILE" || exit 1
    done

    mkdir -p "$INSTALL_DIR/lib"
    for f in session-list.sh; do
        if ! curl -fsSL "$REPO_URL_BASE/src/lib/$f" -o "$INSTALL_DIR/lib/$f"; then
            echo -e "${RED}❌ Failed to download lib/$f${NC}"
            exit 1
        fi
        verify_sha256 "$INSTALL_DIR/lib/$f" "src/lib/$f" "$MANIFEST_FILE" || exit 1
    done

    if ! curl -fsSL "$REPO_URL_BASE/scripts/doctor.sh" -o "$INSTALL_DIR/doctor.sh"; then
        echo -e "${RED}❌ Failed to download scripts/doctor.sh${NC}"
        exit 1
    fi
    verify_sha256 "$INSTALL_DIR/doctor.sh" "scripts/doctor.sh" "$MANIFEST_FILE" || exit 1

    rm -f "$MANIFEST_FILE"
fi

# Source location used by the rest of the installer (systemd service etc.)
SRC_DIR="$INSTALL_DIR"
if [ "$REPO_ROOT" != "$INSTALL_DIR" ] && [ -d "$REPO_ROOT/src" ]; then
    SRC_DIR="$INSTALL_DIR"   # already copied above
fi

# Retire files that are no longer part of the release. Anything *.sh/*.tmux
# at the install root that this installer did not just put there is a
# leftover from an older version (e.g. status-bar-legacy.sh) — stale copies
# confuse debugging and keep dead code executable. Moved to a .trash dir
# rather than deleted, in case the user parked something of their own here.
# Skipped when the install dir is a git clone (dev setup — git manages it).
if [ ! -d "$INSTALL_DIR/.git" ]; then
    KNOWN_ROOT_FILES=" setup.sh connect.sh tmux.conf tmux-console.service uninstall.sh \
safe-exit.sh console-help.sh help-reference.sh status-format-v4.tmux \
theme-config.sh mission-control.sh shortcuts-popup.sh click-session.sh \
restart-confirm.sh restart-session.sh doctor.sh install.sh "
    TRASH_DIR="$INSTALL_DIR/.trash-$(date +%Y%m%d_%H%M%S)"
    for f in "$INSTALL_DIR"/*.sh "$INSTALL_DIR"/*.tmux; do
        [ -f "$f" ] || continue
        base="$(basename "$f")"
        case "$KNOWN_ROOT_FILES" in
            *" $base "*) ;;
            *)
                mkdir -p "$TRASH_DIR"
                mv "$f" "$TRASH_DIR/$base"
                echo -e "${YELLOW}🧹 Retired stale file: $base → ${TRASH_DIR#"$HOME"/}/${NC}"
                ;;
        esac
    done
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

# Create doctor command
cat > "$BIN_DIR/ptty-doctor" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/doctor.sh "$@"
EOF

# Create uninstall command
cat > "$BIN_DIR/uninstall-console" << 'EOF'
#!/bin/bash
exec ~/.tmux-persistent-console/uninstall.sh "$@"
EOF

chmod +x "$BIN_DIR"/*

# Add PATH + safe-exit hooks to an rc file, idempotently. Guards on a marker
# comment in the FILE (not the current process's $PATH) so a fresh curl|bash
# re-run never duplicates the block. Also migrates the old unmarked block
# (pre-marker installs), identified by its distinctive first comment line.
RC_MARKER_START="# >>> pTTY >>>"
RC_MARKER_END="# <<< pTTY <<<"

append_rc_block() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if grep -qF "$RC_MARKER_START" "$rc_file"; then
        return 0
    fi

    # Migrate the old unmarked block left by installs before the marker existed.
    if grep -qF "# tmux-persistent-console" "$rc_file"; then
        sed -i '/^# tmux-persistent-console$/,+2d' "$rc_file"
        sed -i '/^# Safe exit wrapper for tmux sessions$/,+1d' "$rc_file"
    fi

    {
        echo ""
        echo "$RC_MARKER_START"
        echo "export PATH=\"\$HOME/bin:\$PATH\""
        echo "[ -f ~/.tmux-persistent-console/safe-exit.sh ] && source ~/.tmux-persistent-console/safe-exit.sh"
        echo "$RC_MARKER_END"
    } >> "$rc_file"
}

echo -e "${YELLOW}🛤️  Ensuring $BIN_DIR is on PATH...${NC}"
append_rc_block "$HOME/.bashrc"
append_rc_block "$HOME/.zshrc"

# Add to current session
export PATH="$BIN_DIR:$PATH"

rm -f "$INSTALL_DIR/.no-systemd"
if [ "$NO_SYSTEMD" -eq 1 ]; then
    touch "$INSTALL_DIR/.no-systemd"
fi

# Install systemd user service so empty sessions are recreated after boot.
if [ "$CONTAINER_CI" -eq 1 ] || [ "$NO_SYSTEMD" -eq 1 ]; then
    if [ "$CONTAINER_CI" -eq 1 ]; then
        touch "$INSTALL_DIR/.no-systemd"
    fi
    echo -e "${YELLOW}📦 Skipping systemd user service setup${NC}"
    echo -e "${YELLOW}   Creating console sessions directly for verification.${NC}"
    bash "$INSTALL_DIR/setup.sh"

    if ! tmux ls 2>/dev/null | grep -q "^console-1:"; then
        echo -e "${RED}❌ setup.sh completed but no console-* sessions found${NC}"
        echo -e "${RED}   Check setup.sh:  bash -x $INSTALL_DIR/setup.sh${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Container/CI sessions verified${NC}"
elif ! command -v systemctl &> /dev/null; then
    echo -e "${YELLOW}⚠️  systemctl not found — skipping autostart setup${NC}"
    echo -e "${YELLOW}   You will need to start sessions manually with: bash $INSTALL_DIR/setup.sh${NC}"
else
    echo -e "${YELLOW}🔧 Installing systemd autostart service...${NC}"

    # Prefer src/ as canonical source, fall back to INSTALL_DIR
    SERVICE_SRC="$INSTALL_DIR/tmux-console.service"
    if [ -f "$REPO_ROOT/src/tmux-console.service" ]; then
        SERVICE_SRC="$REPO_ROOT/src/tmux-console.service"
    fi
    if [ ! -f "$SERVICE_SRC" ]; then
        echo -e "${RED}❌ Missing tmux-console.service — cannot install autostart${NC}"
        exit 1
    fi

    mkdir -p "$HOME/.config/systemd/user"
    cp "$SERVICE_SRC" "$HOME/.config/systemd/user/tmux-console.service"
    systemctl --user daemon-reload

    # Enable lingering so user services run without an active login after boot.
    if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        echo -e "${YELLOW}   Enabling user lingering...${NC}"
        if loginctl enable-linger "$USER" 2>/dev/null; then
            echo -e "${GREEN}   ✓ Lingering enabled${NC}"
        elif sudo loginctl enable-linger "$USER" 2>/dev/null; then
            echo -e "${GREEN}   ✓ Lingering enabled (via sudo)${NC}"
        else
            echo -e "${YELLOW}   ⚠ Could not enable lingering — empty sessions will not auto-create after boot until you run:${NC}"
            echo -e "${YELLOW}     sudo loginctl enable-linger $USER${NC}"
        fi
    fi

    # Enable + start the service
    if ! systemctl --user enable --now tmux-console.service 2>&1; then
        echo -e "${RED}❌ systemctl enable --now failed${NC}"
        systemctl --user status tmux-console.service --no-pager || true
        exit 1
    fi

    # Verify the service actually came up — don't trust enable's return code alone
    sleep 1
    if ! systemctl --user is-active --quiet tmux-console.service; then
        echo -e "${RED}❌ tmux-console.service is not active after start${NC}"
        echo -e "${RED}   Run:  systemctl --user status tmux-console.service${NC}"
        echo -e "${RED}   And:  journalctl --user -u tmux-console.service -n 30${NC}"
        exit 1
    fi

    # And verify the sessions it claims to manage actually exist.
    # Run setup.sh idempotently first: on upgrades from the old 5-session
    # layout the service is already active but console-6..10 are missing.
    bash "$INSTALL_DIR/setup.sh" >/dev/null 2>&1 || true
    SESSION_COUNT=$(tmux ls 2>/dev/null | grep -c "^console-")
    if [ "$SESSION_COUNT" -ne 10 ]; then
        echo -e "${RED}❌ Service active but found $SESSION_COUNT/10 console sessions${NC}"
        echo -e "${RED}   Check setup.sh:  bash -x $INSTALL_DIR/setup.sh${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Service active, 10 sessions verified${NC}"
fi

# A live tmux server keeps serving the old key bindings and status bar until
# the config is re-sourced — reload it so the update is visible immediately.
# Safe for running sessions: source-file only re-applies configuration.
# (`tmux ls`, not `tmux info` — info exits 1 without an attached client.)
if tmux ls >/dev/null 2>&1; then
    if tmux source-file "$HOME/.tmux.conf" 2>/dev/null; then
        echo -e "${GREEN}🔁 Reloaded config in the running tmux server (sessions untouched)${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not reload the running tmux server — apply manually:${NC}"
        echo -e "${YELLOW}     tmux source-file ~/.tmux.conf${NC}"
    fi
fi

echo ""
if [ "$UPDATE_MODE" -eq 1 ]; then
    echo -e "${GREEN}✅ Update complete — pTTY v$PTTY_VERSION${NC}"
else
    echo -e "${GREEN}✅ Installation complete!${NC}"
fi
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo -e "   ${YELLOW}connect-console${NC}           # Interactive session menu"
echo -e "   ${YELLOW}tmux attach -t console-1${NC}  # Direct to console-1"
echo -e "   ${YELLOW}ptty-doctor${NC}              # Health check for bug reports"
echo ""
echo -e "${BLUE}🔥 Function Keys (from within tmux):${NC}"
echo -e "   ${YELLOW}Ctrl+F1-F10${NC} Jump to console 1-10"
echo -e "   ${YELLOW}Ctrl+F11${NC}    Open manager menu"
echo -e "   ${YELLOW}Ctrl+F12${NC}    Show keyboard help"
echo ""
echo -e "${BLUE}🌐 Remote SSH Access:${NC}"
echo -e "   ${YELLOW}ssh user@server -t \"tmux attach -t console-1\"${NC}"
echo ""
echo -e "${BLUE}🗑️  Uninstall:${NC}"
echo -e "   ${YELLOW}uninstall-console${NC}"
echo ""
echo -e "${GREEN}🎉 Your sessions are protected from SSH/client disconnects. Enjoy coding with AI CLI tools!${NC}"
echo ""
