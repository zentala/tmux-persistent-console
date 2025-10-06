#!/bin/bash
# Restart tmux session - kill and recreate
# Used by Ctrl+R and F11 Manager Menu

SESSION_NAME="$1"

if [ -z "$SESSION_NAME" ]; then
    echo "Error: No session name provided"
    exit 1
fi

# Don't allow restarting special sessions
if [ "$SESSION_NAME" = "help" ] || [ "$SESSION_NAME" = "manager" ]; then
    echo "Error: Cannot restart special session '$SESSION_NAME'"
    exit 1
fi

# Create temp directory for restart scripts
TEMP_DIR="${HOME}/.cache/tmux-console"
mkdir -p "$TEMP_DIR" && chmod 700 "$TEMP_DIR"

# Create background restart script
RESTART_SCRIPT=$(mktemp "$TEMP_DIR/restart-XXXXXX.sh")
LOCK_FILE="$TEMP_DIR/restart-${SESSION_NAME}.lock"

cat > "$RESTART_SCRIPT" << 'RESTART_SCRIPT_CONTENT'
#!/bin/bash
SESSION_NAME="$1"
TEMP_SCRIPT="$2"
LOCK_FILE="$3"

# Create lock file
touch "$LOCK_FILE" 2>/dev/null

# Small delay
sleep 0.5

# Kill old session if exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null
fi

# Wait for session to fully terminate (max 5 seconds)
for i in {1..50}; do
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

# Small delay before creating new session
sleep 0.2

# Create new session
if ! tmux new-session -d -s "$SESSION_NAME" -n "main" 2>/dev/null; then
    echo "[ERROR] Failed to create new session '$SESSION_NAME'" >&2
    rm -f "$TEMP_SCRIPT" "$LOCK_FILE"
    exit 1
fi

# Cleanup
rm -f "$TEMP_SCRIPT" "$LOCK_FILE"
exit 0
RESTART_SCRIPT_CONTENT

chmod 700 "$RESTART_SCRIPT"

# Run restart in background
nohup "$RESTART_SCRIPT" "$SESSION_NAME" "$RESTART_SCRIPT" "$LOCK_FILE" > /dev/null 2>&1 &

# Wait a moment for restart to begin
sleep 0.8

# Switch to restarted session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux switch-client -t "$SESSION_NAME" 2>/dev/null
fi

exit 0
