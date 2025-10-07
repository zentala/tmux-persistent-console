#!/bin/bash
# Push to GitHub and watch CI/CD build status
# Usage: ./push-and-watch.sh [branch]

set -e

BRANCH="${1:-main}"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 Push & Watch CI/CD${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if on correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo -e "${YELLOW}⚠️  Current branch: $CURRENT_BRANCH${NC}"
    echo -e "${YELLOW}   Target branch: $BRANCH${NC}"
    echo ""
    read -p "Switch to $BRANCH? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout "$BRANCH"
    else
        echo "Aborted."
        exit 1
    fi
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    echo ""
    git status --short
    echo ""
    read -p "Commit them first? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Commit message: " commit_msg
        git add -A
        git commit -m "$commit_msg"
    else
        echo "Please commit or stash changes first."
        exit 1
    fi
fi

# Push to GitHub
echo ""
echo -e "${CYAN}📤 Pushing to origin/$BRANCH...${NC}"
git push origin "$BRANCH"

echo ""
echo -e "${GREEN}✅ Pushed successfully${NC}"
echo ""

# Check if gh CLI is available
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    echo -e "${CYAN}🔄 Watching CI/CD status...${NC}"
    echo ""
    sleep 3  # Give GitHub time to register the push

    # Watch for 2 minutes
    for i in {1..12}; do
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}🔄 Watching CI/CD (update $i/12)${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        bash "$(dirname "$0")/check-ci.sh" "$BRANCH"

        if [ $i -lt 12 ]; then
            echo ""
            echo -e "${YELLOW}Refreshing in 10 seconds... (Ctrl+C to stop)${NC}"
            sleep 10
        fi
    done

    echo ""
    echo -e "${GREEN}✅ Monitoring complete${NC}"
    echo ""
    echo "Continue watching with:"
    echo "  ./tools/watch-ci.sh"
else
    echo -e "${YELLOW}💡 Install GitHub CLI to watch CI/CD status:${NC}"
    echo "   • Debian/Ubuntu: sudo apt install gh"
    echo "   • macOS: brew install gh"
    echo "   • Then run: gh auth login"
    echo ""
    echo "Manual check:"
    echo "  https://github.com/zentala/tmux-persistent-console/actions"
fi
