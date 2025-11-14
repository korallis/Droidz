#!/usr/bin/env bash
set -euo pipefail

# /watch - Live monitoring of Droidz orchestration progress
# Usage: /watch [session-id]
# Press Ctrl+C to exit

SESSION_ID="${1:-}"

# Find project root
PROJECT_ROOT="${DROID_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
COORDINATION_DIR="$PROJECT_ROOT/.runs/.coordination"
RUNS_DIR="$PROJECT_ROOT/.runs"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Clear screen function
clear_screen() {
    echo -ne "\033[2J\033[H"
}

# Display header
show_header() {
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Droidz Live Monitoring  $(date '+%H:%M:%S')${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Find latest session if not specified
if [ -z "$SESSION_ID" ]; then
    LATEST_STATE=$(ls -t "$COORDINATION_DIR"/orchestration-*.json 2>/dev/null | head -1 || echo "")
    if [ -n "$LATEST_STATE" ]; then
        SESSION_ID=$(jq -r '.sessionId // "unknown"' "$LATEST_STATE" 2>/dev/null || echo "unknown")
    fi
fi

if [ -z "$SESSION_ID" ] || [ "$SESSION_ID" = "unknown" ]; then
    echo "No active orchestration found."
    echo ""
    echo "Usage: /watch [session-id]"
    echo ""
    echo "Start an orchestration with: /parallel \"task description\""
    exit 1
fi

# Main watch loop
while true; do
    clear_screen
    show_header
    
    # Find state file for this session
    STATE_FILE=""
    for file in "$COORDINATION_DIR"/orchestration-*.json; do
        if [ -f "$file" ]; then
            SID=$(jq -r '.sessionId // ""' "$file" 2>/dev/null || echo "")
            if [ "$SID" = "$SESSION_ID" ]; then
                STATE_FILE="$file"
                break
            fi
        fi
    done
    
    if [ -z "$STATE_FILE" ] || [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}Session not found: $SESSION_ID${NC}"
        sleep 2
        continue
    fi
    
    # Parse orchestration info
    NUM_TASKS=$(jq '.tasks | length // 0' "$STATE_FILE" 2>/dev/null)
    STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null)
    STARTED_AT=$(jq -r '.startTime // .startedAt // "unknown"' "$STATE_FILE" 2>/dev/null)
    
    echo -e "${CYAN}Session:${NC} $SESSION_ID"
    echo -e "${CYAN}Status:${NC} $STATUS"
    echo -e "${CYAN}Started:${NC} $STARTED_AT"
    echo ""
    
    # Count and display tasks
    COMPLETED=0
    IN_PROGRESS=0
    PENDING=0
    FAILED=0
    
    # Read tasks from orchestration file
    TASK_KEYS=$(jq -r '.tasks[]?.key // empty' "$STATE_FILE" 2>/dev/null)
    TASK_TITLES=$(jq -r '.tasks[]? | "\(.key):\(.title)"' "$STATE_FILE" 2>/dev/null)
    
    echo -e "${BOLD}Tasks Progress:${NC}"
    echo "────────────────────────────────────────────────────────────────"
    
    for task_key in $TASK_KEYS; do
        META_FILE="$RUNS_DIR/$task_key/.droidz-meta.json"
        TASK_TITLE=$(echo "$TASK_TITLES" | grep "^$task_key:" | cut -d: -f2- || echo "Unknown")
        
        if [ -f "$META_FILE" ]; then
            TASK_STATUS=$(jq -r '.status // "created"' "$META_FILE" 2>/dev/null)
            SPECIALIST=$(jq -r '.specialist // "unknown"' "$META_FILE" 2>/dev/null)
            
            case "$TASK_STATUS" in
                completed)
                    echo -e "  ${GREEN}✓${NC} $task_key: ${GREEN}DONE${NC} - $TASK_TITLE"
                    ((COMPLETED++)) || true
                    ;;
                in_progress)
                    echo -e "  ${BLUE}⏳${NC} $task_key: ${BLUE}WORKING${NC} ($specialist) - $TASK_TITLE"
                    ((IN_PROGRESS++)) || true
                    ;;
                failed)
                    echo -e "  ${RED}✗${NC} $task_key: ${RED}FAILED${NC} - $TASK_TITLE"
                    ((FAILED++)) || true
                    ;;
                *)
                    echo -e "  ${YELLOW}⏸${NC} $task_key: ${YELLOW}PENDING${NC} - $TASK_TITLE"
                    ((PENDING++)) || true
                    ;;
            esac
        else
            echo -e "  ${YELLOW}⏸${NC} $task_key: ${YELLOW}PENDING${NC} - $TASK_TITLE"
            ((PENDING++)) || true
        fi
    done
    
    echo ""
    echo "────────────────────────────────────────────────────────────────"
    
    # Progress bar
    TOTAL=$NUM_TASKS
    if [ "$TOTAL" -gt 0 ]; then
        PERCENT=$((COMPLETED * 100 / TOTAL))
        BARS=$((COMPLETED * 30 / TOTAL))
        SPACES=$((30 - BARS))
        
        echo -n "Progress: ["
        for ((i=0; i<BARS; i++)); do echo -n "█"; done
        for ((i=0; i<SPACES; i++)); do echo -n " "; done
        echo -e "] ${PERCENT}%"
    fi
    
    echo ""
    echo -e "  ${GREEN}✓${NC} Completed: $COMPLETED"
    echo -e "  ${BLUE}⏳${NC} Working: $IN_PROGRESS"
    echo -e "  ${YELLOW}⏸${NC} Pending: $PENDING"
    [ "$FAILED" -gt 0 ] && echo -e "  ${RED}✗${NC} Failed: $FAILED"
    
    # Show active tmux sessions
    echo ""
    ACTIVE_SESSIONS=$(tmux list-sessions 2>/dev/null | grep "^droidz-" | wc -l || echo "0")
    echo -e "${CYAN}Active Sessions:${NC} $ACTIVE_SESSIONS tmux sessions running"
    
    # Show some recent log lines
    if [ -f "$COORDINATION_DIR/orchestration.log" ]; then
        echo ""
        echo -e "${BOLD}Recent Activity:${NC}"
        echo "────────────────────────────────────────────────────────────────"
        tail -5 "$COORDINATION_DIR/orchestration.log" | sed 's/\x1b\[[0-9;]*m//g' | cut -c1-66
    fi
    
    echo ""
    echo -e "${CYAN}Press Ctrl+C to exit${NC} | ${CYAN}Updating every 2s...${NC}"
    
    # Wait 2 seconds
    sleep 2
done
