#!/bin/bash
# Watch GitHub Actions CI/CD in real-time
# Usage: ./watch-ci.sh [refresh_seconds]

REFRESH="${1:-10}"
REPO="zentala/tmux-persistent-console"

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}🔄 Watching CI/CD (refresh every ${REFRESH}s)${NC}"
echo "Press Ctrl+C to exit"
echo ""

while true; do
    # Move cursor to top
    tput cup 3 0

    # Run check-ci.sh
    bash "$(dirname "$0")/check-ci.sh" 2>/dev/null || {
        echo "Error running check-ci.sh"
        echo "Make sure gh CLI is installed and authenticated"
        exit 1
    }

    # Wait
    sleep "$REFRESH"
done
