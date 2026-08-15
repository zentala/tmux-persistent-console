#!/bin/bash
# Local Docker testing for pTTY

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

echo -e "${BLUE}🐳 pTTY - Docker Testing${NC}"
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

        # Status bar suite: needs a real tmux client, so run it inside a
        # detached session on the server (testuser already has console-1..10
        # from the entrypoint). tmux wait-for blocks docker exec until the
        # suite finishes; the exit code is relayed through a file because
        # the suite runs detached, not as docker exec's own process.
        echo -n "Test: Status bar suite (non-interactive)... "
        STATUS_BAR_EXIT=$(docker exec -u testuser tmux-test-server bash -c '
            tmux new-session -d -s status-bar-test -n runner \
                "bash /tmp/ptty/tests/run-all-tests.sh --non-interactive; echo \$? > /tmp/status-bar-exit.txt; tmux wait-for -S status-bar-done"
            tmux wait-for status-bar-done
            cat /tmp/status-bar-exit.txt
        ' 2>/dev/null | tail -1)
        if [ "$STATUS_BAR_EXIT" = "0" ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
        else
            echo -e "${RED}❌ FAILED (exit $STATUS_BAR_EXIT)${NC}"
        fi

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

        # Test tmux sessions. Count via grep on session names, not
        # `tmux ls | wc -l` — the latter also counts non-console sessions
        # (e.g. `help`) and gives a false failure/pass.
        echo -n "Test: Tmux sessions exist... "
        SESSION_COUNT=$(sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -c '^console-'")
        if [ "$SESSION_COUNT" -eq 10 ]; then
            echo -e "${GREEN}✅ PASSED (10 sessions)${NC}"
        else
            echo -e "${RED}❌ FAILED (found $SESSION_COUNT sessions)${NC}"
            exit 1
        fi

        # Keybinding smoke test. `switch-client` needs an attached client,
        # which docker exec/ssh do not provide, so we assert the thing the
        # F-key bindings actually depend on: every target session exists.
        echo -n "Test: Console keybinding targets exist (console-1..10)... "
        BINDING_OK=true
        for i in $(seq 1 10); do
            if ! sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux has-session -t console-$i" > /dev/null 2>&1; then
                BINDING_OK=false
            fi
        done
        if [ "$BINDING_OK" = "true" ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
        else
            echo -e "${RED}❌ FAILED (a console-N session is missing)${NC}"
            exit 1
        fi

        # ExecStop-scoping test (T06). The server container has no systemd
        # (Ubuntu base image, sshd as PID 1's child via /docker-entrypoint.sh),
        # so we exercise the same command line as
        # src/tmux-console.service's ExecStop directly instead of going
        # through systemctl. Asserts it kills only console-1..10 and leaves
        # unrelated sessions (here: `mywork`) alone.
        echo -n "Test: ExecStop scoping leaves other sessions alone... "
        sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux new-session -d -s mywork" > /dev/null 2>&1
        sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost \
            "bash -c 'for i in \$(seq 1 10); do tmux kill-session -t =console-\$i 2>/dev/null; done; true'" > /dev/null 2>&1
        MYWORK_ALIVE=$(sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux has-session -t mywork" > /dev/null 2>&1 && echo yes || echo no)
        CONSOLES_LEFT=$(sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -c '^console-'" || true)
        if [ "$MYWORK_ALIVE" = "yes" ] && [ "$CONSOLES_LEFT" -eq 0 ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
        else
            echo -e "${RED}❌ FAILED (mywork=$MYWORK_ALIVE, consoles left=$CONSOLES_LEFT)${NC}"
            exit 1
        fi
        # Recreate consoles so any later test steps see the normal 10-session layout.
        sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux kill-session -t mywork; bash ~/.tmux-persistent-console/setup.sh" > /dev/null 2>&1

        # Upgrade path (T12): simulate the old "5 consoles" layout, re-run
        # setup.sh (idempotent: skips existing sessions, creates the rest),
        # assert all 10 exist afterward. This is a setup.sh-level check
        # only — the container has no systemd, so re-registering/restarting
        # the systemd unit on upgrade is NOT covered here.
        echo -n "Test: Upgrade from 5 to 10 consoles... "
        sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost \
            "bash -c 'for i in \$(seq 1 10); do tmux kill-session -t =console-\$i 2>/dev/null; done; for i in \$(seq 1 5); do tmux new-session -d -s console-\$i; done'" > /dev/null 2>&1
        sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "bash ~/.tmux-persistent-console/setup.sh" > /dev/null 2>&1
        UPGRADED_COUNT=$(sshpass -p testpassword ssh -p 2222 -o StrictHostKeyChecking=no testuser@localhost "tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -c '^console-'")
        if [ "$UPGRADED_COUNT" -eq 10 ]; then
            echo -e "${GREEN}✅ PASSED (10 sessions after upgrade)${NC}"
        else
            echo -e "${RED}❌ FAILED (found $UPGRADED_COUNT sessions after upgrade)${NC}"
            exit 1
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
