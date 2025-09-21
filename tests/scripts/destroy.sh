#!/bin/bash
# Destroy test infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo -e "${BLUE}🗑️  Destroying tmux-persistent-console test infrastructure${NC}"
echo "====================================================="

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed.${NC}"
    exit 1
fi

# Check if terraform state exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠️  No terraform state found. Nothing to destroy.${NC}"
    exit 0
fi

cd "$TERRAFORM_DIR"

echo -e "${YELLOW}📋 Planning destruction...${NC}"
terraform plan -destroy

echo ""
echo -e "${RED}❓ Are you sure you want to destroy the test infrastructure? (y/N)${NC}"
echo -e "${YELLOW}   This will permanently delete the test server and all data!${NC}"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Destruction cancelled."
    exit 0
fi

echo -e "${YELLOW}💥 Destroying infrastructure...${NC}"
if terraform destroy -auto-approve; then
    echo ""
    echo -e "${GREEN}✅ Infrastructure destroyed successfully!${NC}"

    # Clean up connection info
    if [ -f "$SCRIPT_DIR/connection-info.txt" ]; then
        rm "$SCRIPT_DIR/connection-info.txt"
        echo -e "${GREEN}🧹 Cleaned up connection info${NC}"
    fi

else
    echo -e "${RED}❌ Destruction failed!${NC}"
    echo "   You may need to manually clean up resources in OCI console."
    exit 1
fi

echo ""
echo -e "${BLUE}💡 Infrastructure destroyed. You can deploy again anytime with:${NC}"
echo "   ./deploy.sh"