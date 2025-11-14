---
description: Show active orchestration sessions and their status
argument-hint: [optional]
allowed-tools: Bash(*)
---

# /status - Show Active Orchestrations

Displays all active orchestration sessions with their current status.

## Usage

```bash
# Show all orchestrations
/status

# Show with detailed information
/status --verbose
```

## What It Shows

- Session ID
- Number of tasks
- Current status (planning/ready/running/completed)
- Start time
- Location of worktrees and logs

## Example Output

```
Active Orchestrations:

  • 20251114-143000 (28 tasks) - ready
    Started: 2025-11-14 14:30:00
    Worktrees: .runs/
    Logs: .runs/.coordination/orchestration.log

  • 20251113-091500 (12 tasks) - completed  
    Started: 2025-11-13 09:15:00
    Completed: 2025-11-13 10:45:00

To monitor: /attach [task-key]
To summarize: /summary [session-id]
```

## Implementation

<execute>
#!/bin/bash

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
    echo "Start one with: /orchestrate"
    exit 0
fi

# Find orchestration state files
STATE_FILES=("$COORDINATION_DIR"/orchestration-*.json)

if [ ! -f "${STATE_FILES[0]}" ]; then
    echo "No orchestrations found."
    echo ""
    echo "Start one with: /orchestrate"
    exit 0
fi

# Display each orchestration
for state_file in "${STATE_FILES[@]}"; do
    if [ ! -f "$state_file" ]; then
        continue
    fi
    
    # Parse state file
    SESSION_ID=$(jq -r '.sessionId' "$state_file" 2>/dev/null || echo "unknown")
    NUM_TASKS=$(jq '.tasks | length' "$state_file" 2>/dev/null || echo "0")
    STATUS=$(jq -r '.status' "$state_file" 2>/dev/null || echo "unknown")
    STARTED_AT=$(jq -r '.startedAt' "$state_file" 2>/dev/null || echo "unknown")
    
    # Display orchestration
    echo -e "  ${CYAN}●${NC} ${BOLD}$SESSION_ID${NC} (${NUM_TASKS} tasks) - ${STATUS}"
    echo "    Started: $STARTED_AT"
    
    # Check if verbose mode
    if [[ "$ARGUMENTS" == *"--verbose"* ]] || [[ "$ARGUMENTS" == *"-v"* ]]; then
        echo "    Worktrees: $PROJECT_ROOT/.runs/"
        echo "    State: $state_file"
        echo "    Logs: $PROJECT_ROOT/.runs/.coordination/orchestration.log"
    fi
    
    echo ""
done

# Show quick actions
echo -e "${BOLD}Quick Actions:${NC}"
echo "  Monitor live:  .factory/scripts/monitor-orchestration.sh --session [session-id]"
echo "  Take snapshot: .factory/scripts/monitor-orchestration.sh --snapshot --session [session-id]"
echo "  Attach to task: /attach [task-key]"
echo "  Show summary: /summary [session-id]"
echo ""
</execute>
