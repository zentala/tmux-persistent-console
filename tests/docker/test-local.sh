#!/bin/bash
# Local Docker testing for tmux-persistent-console

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🐳 Tmux Persistent Console - Docker Testing${NC}"
echo "=============================================="

# Function to cleanup containers
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up Docker containers...${NC}"
    cd "$SCRIPT_DIR"
    docker-compose down -v 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Trap cleanup on exit
trap cleanup EXIT

# Parse arguments
ACTION="${1:-test}"
PROFILE="${2:-default}"

case "$ACTION" in
    build)
        echo -e "${YELLOW}🔨 Building Docker images...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose build --no-cache
        echo -e "${GREEN}✅ Build complete${NC}"
        ;;

    start)
        echo -e "${YELLOW}🚀 Starting test environment...${NC}"
        cd "$SCRIPT_DIR"

        # Start containers
        if [ "$PROFILE" = "multi" ]; then
            echo -e "${CYAN}Starting multi-server configuration...${NC}"
            docker-compose --profile multi-server up -d
        else
            docker-compose up -d
        fi

        echo -e "${GREEN}✅ Test environment is running${NC}"
        echo ""
        echo -e "${BLUE}📋 Connection Information:${NC}"
        echo "  From host machine:"
        echo "    ssh -p 2222 testuser@localhost  # Password: testpassword"
        echo "    ssh -p 2222 devuser@localhost   # Password: devpassword"

        if [ "$PROFILE" = "multi" ]; then
            echo "    ssh -p 2223 testuser@localhost  # Server 2"
        fi

        echo ""
        echo "  Enter client container:"
        echo "    docker exec -it tmux-test-client bash"
        echo ""
        echo "  Inside client, use shortcuts:"
        echo "    ssh c1     # Console 1"
        echo "    ssh menu   # Interactive menu"
        echo ""
        ;;

    test)
        echo -e "${YELLOW}🧪 Running Docker-based tests...${NC}"
        cd "$SCRIPT_DIR"

        # Build if needed
        echo -e "${CYAN}Building images...${NC}"
        docker-compose build

        # Start containers
        echo -e "${CYAN}Starting containers...${NC}"
        docker-compose up -d

        # Wait for services
        echo -e "${CYAN}Waiting for services to be ready...${NC}"
        sleep 10

        # Run automated tests in client container
        echo -e "${CYAN}Running automated tests...${NC}"
        docker exec tmux-test-client run-tests.sh

        # Additional host-based tests
        echo ""
        echo -e "${CYAN}Running host-based tests...${NC}"

        # Test SSH from host
        echo -n "Test: SSH from host... "
        if sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "echo ok" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PASSED${NC}"
        else
            echo -e "${RED}❌ FAILED${NC}"
        fi

        # Test tmux sessions
        echo -n "Test: Tmux sessions exist... "
        SESSION_COUNT=$(sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux ls 2>/dev/null | wc -l")
        if [ "$SESSION_COUNT" -eq 7 ]; then
            echo -e "${GREEN}✅ PASSED (7 sessions)${NC}"
        else
            echo -e "${RED}❌ FAILED (found $SESSION_COUNT sessions)${NC}"
        fi

        echo ""
        echo -e "${GREEN}📊 Test Summary Complete${NC}"
        ;;

    interactive)
        echo -e "${YELLOW}🎮 Starting interactive test mode...${NC}"
        cd "$SCRIPT_DIR"

        # Build and start
        docker-compose build
        docker-compose up -d

        echo -e "${GREEN}✅ Environment ready${NC}"
        echo ""
        echo -e "${CYAN}Entering client container...${NC}"
        echo -e "${YELLOW}💡 Try these commands:${NC}"
        echo "  test-connections.sh  # Test connectivity"
        echo "  ssh c1              # Connect to console-1"
        echo "  ssh menu            # Interactive menu"
        echo "  run-tests.sh        # Automated tests"
        echo ""

        # Enter interactive shell
        docker exec -it tmux-test-client bash
        ;;

    shell)
        # Quick access to client shell
        docker exec -it tmux-test-client bash
        ;;

    server-shell)
        # Quick access to server shell
        docker exec -it tmux-test-server bash
        ;;

    logs)
        echo -e "${CYAN}📋 Container logs:${NC}"
        cd "$SCRIPT_DIR"
        docker-compose logs -f
        ;;

    stop)
        echo -e "${YELLOW}🛑 Stopping test environment...${NC}"
        cd "$SCRIPT_DIR"
        docker-compose stop
        echo -e "${GREEN}✅ Stopped${NC}"
        ;;

    clean)
        cleanup
        ;;

    status)
        echo -e "${CYAN}📊 Container status:${NC}"
        docker-compose ps
        echo ""
        echo -e "${CYAN}🌐 Network status:${NC}"
        docker network inspect docker_tmux-test-net 2>/dev/null | grep -E "(Name|IPv4Address)" || echo "Network not found"
        ;;

    *)
        echo -e "${BLUE}Usage: $0 [command] [options]${NC}"
        echo ""
        echo "Commands:"
        echo "  build         - Build Docker images"
        echo "  start [multi] - Start test environment"
        echo "  test          - Run automated tests (default)"
        echo "  interactive   - Interactive testing mode"
        echo "  shell         - Enter client container"
        echo "  server-shell  - Enter server container"
        echo "  logs          - Show container logs"
        echo "  stop          - Stop containers"
        echo "  clean         - Clean up everything"
        echo "  status        - Show container status"
        echo ""
        echo "Examples:"
        echo "  $0 test              # Run all tests"
        echo "  $0 start             # Start environment"
        echo "  $0 start multi       # Start multi-server setup"
        echo "  $0 interactive       # Interactive testing"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}🎯 Docker testing complete!${NC}"