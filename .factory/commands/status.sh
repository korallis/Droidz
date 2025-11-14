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
RED='\033[0;31m'
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

# Check for tmux sessions
TMUX_SESSIONS=$(tmux list-sessions 2>/dev/null | grep "^droidz-" | wc -l || echo "0")

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
    
    # Count tasks by checking worktree meta files
    COMPLETED=0
    IN_PROGRESS=0
    PENDING=0
    FAILED=0
    
    # Read tasks from orchestration file
    TASK_KEYS=$(jq -r '.tasks[]?.key // empty' "$state_file" 2>/dev/null)
    
    for task_key in $TASK_KEYS; do
        META_FILE="$PROJECT_ROOT/.runs/$task_key/.droidz-meta.json"
        if [ -f "$META_FILE" ]; then
            TASK_STATUS=$(jq -r '.status // "unknown"' "$META_FILE" 2>/dev/null)
            case "$TASK_STATUS" in
                completed) ((COMPLETED++)) || true ;;
                in_progress) ((IN_PROGRESS++)) || true ;;
                failed) ((FAILED++)) || true ;;
                *) ((PENDING++)) || true ;;
            esac
        else
            ((PENDING++)) || true
        fi
    done
    
    # Display orchestration
    echo -e "  ${CYAN}●${NC} ${BOLD}$SESSION_ID${NC}"
    echo "    Status: $STATUS"
    
    # Build task summary line
    TASK_SUMMARY="$NUM_TASKS total ($COMPLETED done, $IN_PROGRESS working, $PENDING waiting"
    if [ "$FAILED" -gt 0 ]; then
        TASK_SUMMARY="$TASK_SUMMARY, ${RED}$FAILED failed${NC}"
    fi
    TASK_SUMMARY="$TASK_SUMMARY)"
    
    echo -e "    Tasks: $TASK_SUMMARY"
    echo "    Started: $STARTED_AT"
    
    # Show active tmux sessions for this orchestration
    ACTIVE_SESSIONS=$(tmux list-sessions 2>/dev/null | grep "^droidz-" | wc -l || echo "0")
    if [ "$ACTIVE_SESSIONS" -gt 0 ]; then
        echo -e "    ${GREEN}Active sessions:${NC} $ACTIVE_SESSIONS tmux sessions running"
    fi
    echo ""
done

# Show quick actions
echo -e "${BOLD}Monitor progress:${NC}"
echo "  /summary [session-id]  - Detailed view"
echo "  /attach [task-key]     - Watch a task"
echo ""
