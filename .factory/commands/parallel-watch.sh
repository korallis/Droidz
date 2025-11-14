#!/usr/bin/env bash
set -euo pipefail

# /parallel-watch - Start parallel orchestration and show live monitoring
# Usage: /parallel-watch "task description"

# Get the task description from arguments
TASK_DESCRIPTION="$*"

if [ -z "$TASK_DESCRIPTION" ]; then
    echo "Usage: /parallel-watch \"task description\""
    echo ""
    echo "This command will:"
    echo "  1. Start parallel orchestration for your task"
    echo "  2. Automatically show live monitoring with /watch"
    echo ""
    echo "Example:"
    echo "  /parallel-watch \"create REST API with 3 endpoints\""
    exit 1
fi

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Parallel Orchestration with Auto-Monitoring                ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Explain what's happening
echo -e "${CYAN}Step 1: Starting Parallel Orchestration${NC}"
echo "Task: $TASK_DESCRIPTION"
echo ""
echo "I'll now ask the droid to:"
echo "  • Analyze and break down your task"
echo "  • Create optimal task breakdown with dependencies"
echo "  • Spawn specialist droids for parallel execution"
echo ""

# Step 2: Tell user this command needs to work with droid
echo -e "${YELLOW}⚠️  Note:${NC} This command will guide you through the process."
echo "    After this output, you'll need to:"
echo ""
echo "    1. Let the droid process the parallel orchestration request"
echo "    2. Then run: ${GREEN}/watch${NC} to see live progress"
echo ""
echo "Alternatively, you can use ${GREEN}/auto-parallel${NC} which integrates"
echo "with the droid to handle both steps seamlessly."
echo ""

# Step 3: Output the parallel command request
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Please process this request:"
echo ""
echo "/parallel $TASK_DESCRIPTION"
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✓${NC} Once orchestration starts, run: ${GREEN}/watch${NC}"
echo ""
