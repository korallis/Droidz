---
description: Attach to a task's tmux session to watch or interact with agent
argument-hint: [task-key]
allowed-tools: Bash(*)
---

# /attach - Attach to Task Tmux Session

Attaches to a task's tmux session so you can watch the agent work in real-time or interact with the workspace.

## Usage

```bash
# Attach to a specific task
/attach AUTH-001

# List available sessions
/attach --list
```

## What It Does

- Attaches to the tmux session for the specified task
- Allows you to see what the agent is doing in real-time
- You can run commands in the workspace
- Detach with: Ctrl+B then D

## Example

```bash
/attach AUTH-001

# Now you're in the tmux session:
# - See agent commands being executed
# - View test output
# - Read files in the worktree
# - Run your own commands

# To detach: Ctrl+B then D
# To switch sessions: Ctrl+B then S
```

## Implementation

<execute>
#!/bin/bash

TASK_KEY="$ARGUMENTS"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Check if --list flag
if [ "$TASK_KEY" = "--list" ] || [ "$TASK_KEY" = "-l" ] || [ -z "$TASK_KEY" ]; then
    echo ""
    echo -e "${BOLD}Available Droidz Sessions:${NC}"
    echo ""
    
    # List all droidz sessions
    sessions=$(tmux list-sessions 2>/dev/null | grep "droidz-" || echo "")
    
    if [ -z "$sessions" ]; then
        echo "No active droidz sessions found."
        echo ""
        echo "Orchestrations may not have been started yet, or sessions may have terminated."
        echo ""
        echo "Check status with: /status"
        exit 0
    fi
    
    echo "$sessions" | while IFS= read -r line; do
        session_name=$(echo "$line" | cut -d: -f1)
        task_key=$(echo "$session_name" | sed 's/droidz-//')
        echo -e "  ${CYAN}●${NC} ${BOLD}$task_key${NC} → $session_name"
    done
    
    echo ""
    echo "Attach with: /attach [task-key]"
    echo ""
    exit 0
fi

# Construct session name
SESSION_NAME="droidz-$TASK_KEY"

echo ""
echo -e "${CYAN}ℹ${NC} Attempting to attach to session: ${BOLD}$SESSION_NAME${NC}"
echo ""

# Check if session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${RED}✗${NC} Session not found: $SESSION_NAME"
    echo ""
    echo "Available sessions:"
    
    sessions=$(tmux list-sessions 2>/dev/null | grep "droidz-" || echo "")
    
    if [ -z "$sessions" ]; then
        echo "  (none)"
    else
        echo "$sessions" | while IFS= read -r line; do
            session=$(echo "$line" | cut -d: -f1)
            key=$(echo "$session" | sed 's/droidz-//')
            echo "  • $key"
        done
    fi
    
    echo ""
    echo "List all with: /attach --list"
    echo ""
    exit 1
fi

# Attach to session
echo -e "${GREEN}✓${NC} Session found! Attaching..."
echo ""
echo -e "${YELLOW}TIP: Detach with Ctrl+B then D${NC}"
echo -e "${YELLOW}TIP: Switch sessions with Ctrl+B then S${NC}"
echo ""

sleep 1

# Attach
exec tmux attach -t "$SESSION_NAME"
</execute>
