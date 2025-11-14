#!/usr/bin/env bash
set -euo pipefail

# /status - Show Active Droidz Orchestrations
# Usage: /status

# Find project root
PROJECT_ROOT="${DROID_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
COORDINATION_DIR="$PROJECT_ROOT/.runs/.coordination"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}Active Orchestrations:${NC}"
echo ""

if [ ! -d "$COORDINATION_DIR" ]; then
    echo "No orchestrations found."
    echo ""
    echo "Start one with: /parallel \"your task description\""
    exit 0
fi

# Find orchestration state files
STATE_FILES=("$COORDINATION_DIR"/orchestration-*.json)

if [ ! -f "${STATE_FILES[0]}" ]; then
    echo "No orchestrations found."
    echo ""
    echo "Start one with: /parallel \"your task description\""
    exit 0
fi

# Display each orchestration
for state_file in "${STATE_FILES[@]}"; do
    if [ ! -f "$state_file" ]; then
        continue
    fi
    
    # Parse state file with jq
    if ! command -v jq &> /dev/null; then
        echo "⚠️  jq not found - showing raw file"
        echo "File: $state_file"
        continue
    fi
    
    SESSION_ID=$(jq -r '.sessionId // "unknown"' "$state_file" 2>/dev/null)
    NUM_TASKS=$(jq '.tasks | length // 0' "$state_file" 2>/dev/null)
    STATUS=$(jq -r '.status // "unknown"' "$state_file" 2>/dev/null)
    STARTED_AT=$(jq -r '.startTime // .startedAt // "unknown"' "$state_file" 2>/dev/null)
    
    # Count tasks by status
    COMPLETED=$(jq '[.tasks[]? | select(.status == "completed")] | length' "$state_file" 2>/dev/null || echo "0")
    IN_PROGRESS=$(jq '[.tasks[]? | select(.status == "in_progress")] | length' "$state_file" 2>/dev/null || echo "0")
    PENDING=$(jq '[.tasks[]? | select(.status == "pending")] | length' "$state_file" 2>/dev/null || echo "0")
    
    # Display orchestration
    echo -e "  ${CYAN}●${NC} ${BOLD}$SESSION_ID${NC}"
    echo "    Status: $STATUS"
    echo "    Tasks: $NUM_TASKS total ($COMPLETED done, $IN_PROGRESS working, $PENDING waiting)"
    echo "    Started: $STARTED_AT"
    echo ""
done

# Show quick actions
echo -e "${BOLD}Monitor progress:${NC}"
echo "  /summary [session-id]  - Detailed view"
echo "  /attach [task-key]     - Watch a task"
echo ""
