#!/bin/bash
# Check GitHub Actions CI/CD status for tmux-persistent-console
# Usage: ./check-ci.sh [branch]

set -e

BRANCH="${1:-main}"
REPO="zentala/tmux-persistent-console"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 GitHub Actions CI/CD Status${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Repository: $REPO"
echo "Branch: $BRANCH"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) not installed${NC}"
    echo ""
    echo "Install with:"
    echo "  • Debian/Ubuntu: sudo apt install gh"
    echo "  • macOS: brew install gh"
    echo "  • Manual: https://cli.github.com/"
    echo ""
    echo "Or check manually:"
    echo "  https://github.com/$REPO/actions"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not authenticated with GitHub${NC}"
    echo ""
    echo "Run: gh auth login"
    echo ""
    exit 1
fi

echo -e "${CYAN}📊 Latest Workflow Runs:${NC}"
echo ""

# Get latest workflow runs
gh run list \
    --repo "$REPO" \
    --branch "$BRANCH" \
    --limit 5 \
    --json status,conclusion,name,createdAt,url \
    --jq '.[] | "\(.status)\t\(.conclusion // "running")\t\(.name)\t\(.createdAt)\t\(.url)"' \
    | while IFS=$'\t' read -r status conclusion name created url; do

    # Format status icon
    if [ "$conclusion" = "success" ]; then
        icon="✅"
        color="$GREEN"
    elif [ "$conclusion" = "failure" ]; then
        icon="❌"
        color="$RED"
    elif [ "$conclusion" = "cancelled" ]; then
        icon="⏹️ "
        color="$YELLOW"
    elif [ "$status" = "in_progress" ]; then
        icon="🔄"
        color="$CYAN"
    else
        icon="⏳"
        color="$YELLOW"
    fi

    # Format date
    created_short=$(echo "$created" | cut -d'T' -f1)

    echo -e "${color}${icon} ${name}${NC}"
    echo "   Status: $status | Conclusion: $conclusion"
    echo "   Date: $created_short"
    echo "   URL: $url"
    echo ""
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check latest commit status
echo -e "${CYAN}📝 Latest Commit Status:${NC}"
echo ""

LATEST_COMMIT=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%s)

echo "Commit: $COMMIT_SHORT"
echo "Message: $COMMIT_MSG"
echo ""

# Get commit status from GitHub
gh api "repos/$REPO/commits/$LATEST_COMMIT/status" \
    --jq '.state' > /tmp/commit-status.txt 2>/dev/null || echo "unknown" > /tmp/commit-status.txt

COMMIT_STATUS=$(cat /tmp/commit-status.txt)

case "$COMMIT_STATUS" in
    "success")
        echo -e "${GREEN}✅ All checks passed${NC}"
        ;;
    "failure")
        echo -e "${RED}❌ Some checks failed${NC}"
        ;;
    "pending")
        echo -e "${YELLOW}⏳ Checks in progress${NC}"
        ;;
    *)
        echo -e "${YELLOW}❓ Status unknown${NC}"
        ;;
esac

echo ""
echo -e "${CYAN}🔗 Quick Links:${NC}"
echo "  • Actions: https://github.com/$REPO/actions"
echo "  • Latest: https://github.com/$REPO/actions/runs"
echo "  • Commit: https://github.com/$REPO/commit/$LATEST_COMMIT"
echo ""

# Cleanup
rm -f /tmp/commit-status.txt
