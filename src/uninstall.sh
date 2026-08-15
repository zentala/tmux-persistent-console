#!/bin/bash
# pTTY uninstaller

echo "==================================="
echo "          pTTY REMOVAL             "
echo "==================================="
echo ""

# Stop + remove systemd autostart so sessions don't get re-created on next boot
if command -v systemctl &> /dev/null; then
    if [ -f "$HOME/.config/systemd/user/tmux-console.service" ]; then
        echo "🛑 Disabling systemd autostart..."
        systemctl --user disable --now tmux-console.service 2>/dev/null || true
        rm -f "$HOME/.config/systemd/user/tmux-console.service"
        systemctl --user daemon-reload 2>/dev/null || true
        echo "   ✓ Removed tmux-console.service"
    fi

    # Drop linger only if no other user services rely on it.
    if loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        other_user_units=$(systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null | wc -l)
        if [ "$other_user_units" -eq 0 ]; then
            echo "🧹 Disabling user lingering (no other user services need it)..."
            loginctl disable-linger "$USER" 2>/dev/null || sudo loginctl disable-linger "$USER" 2>/dev/null || \
                echo "   ⚠ Could not disable lingering — run manually: sudo loginctl disable-linger $USER"
        else
            echo "ℹ️  Keeping linger=yes ($other_user_units other user services still enabled)"
        fi
    fi
fi

# Kill all console sessions
echo "🔄 Stopping console sessions..."
for i in {1..10}; do
    if tmux has-session -t "console-$i" 2>/dev/null; then
        tmux kill-session -t "console-$i"
        echo "   ✓ Stopped console-$i"
    fi
done

# Remove tmux config if it was installed by us
if [ -f ~/.tmux.conf ] && grep -q "# tmux-persistent-console config" ~/.tmux.conf 2>/dev/null; then
    echo "🗑️  Removing tmux configuration..."
    rm ~/.tmux.conf
    echo "   ✓ Removed ~/.tmux.conf"
fi

# Remove the PATH + safe-exit block install.sh appends to rc files. Matches
# both the current marker format and the legacy unmarked block (installs from
# before the marker existed), so old installs uninstall cleanly too.
RC_MARKER_START="# >>> pTTY >>>"
RC_MARKER_END="# <<< pTTY <<<"

remove_rc_block() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if grep -qF "$RC_MARKER_START" "$rc_file"; then
        sed -i "/$RC_MARKER_START/,/$RC_MARKER_END/d" "$rc_file"
        echo "   ✓ Removed pTTY block from $rc_file"
    fi

    if grep -qF "# tmux-persistent-console" "$rc_file"; then
        sed -i '/^# tmux-persistent-console$/,+2d' "$rc_file"
        sed -i '/^# Safe exit wrapper for tmux sessions$/,+1d' "$rc_file"
        echo "   ✓ Removed legacy pTTY block from $rc_file"
    fi
}

echo "🗑️  Removing PATH/safe-exit hooks..."
remove_rc_block ~/.bashrc
remove_rc_block ~/.zshrc

rm -f ~/bin/setup-console-sessions ~/bin/connect-console ~/bin/console-help ~/bin/ptty-doctor ~/bin/uninstall-console

echo ""
echo "✅ pTTY has been removed!"
echo "   Sessions stopped, config cleaned up."
echo ""
echo "💡 Tip: You can reinstall anytime with:"
echo "   curl -sSL https://raw.githubusercontent.com/zentala/pTTY/main/install.sh | bash"
echo ""
