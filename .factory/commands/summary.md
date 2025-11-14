---
description: Show detailed summary of orchestration progress and status
argument-hint: [session-id]
allowed-tools: Bash(*)
---

# /summary - Orchestration Progress Summary

Displays a detailed summary of an orchestration session including task status, progress, and quick actions.

## Usage

```bash
# Show summary for specific session
/summary 20251114-143000

# Show summary for latest session
/summary

# Show with task details
/summary 20251114-143000 --verbose
```

## What It Shows

- Overall progress (completed/in-progress/pending)
- Individual task status
- Files changed
- Quick actions (attach, monitor, cleanup)
- Estimated time remaining (if applicable)

## Example Output

```
Orchestration Summary: 20251114-143000

Progress: 18/28 tasks complete (64%)
  ✅ Completed: 18
  ⏳ In Progress: 3
  ⏸  Pending: 7

Recent Completions:
  ✓ AUTH-001: Login API (5 files, 8 tests)
  ✓ AUTH-002: Register API (4 files, 12 tests)
  ✓ AUTH-003: Integration Tests (24 tests)

Currently Running:
  ⏳ AUTH-004: OAuth Integration
  ⏳ AUTH-005: Password Reset Flow
  ⏳ AUTH-006: Email Verification

Next Up:
  ⏸  AUTH-007: Session Management
  ⏸  AUTH-008: Rate Limiting

Quick Actions:
  Attach to task: /attach AUTH-004
  Monitor live: .factory/scripts/monitor-orchestration.sh --session 20251114-143000
```

## Implementation

<execute>
#!/bin/bash

SESSION_ARG="$ARGUMENTS"

# Find project root
PROJECT_ROOT="${DROID_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
COORDINATION_DIR="$PROJECT_ROOT/.runs/.coordination"
RUNS_DIR="$PROJECT_ROOT/.runs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Check if coordination directory exists
if [ ! -d "$COORDINATION_DIR" ]; then
    echo ""
    echo -e "${RED}✗${NC} No orchestrations found."
    echo ""
    echo "Start one with: /orchestrate"
    exit 1
fi

# Find session ID
SESSION_ID=""
if [ -z "$SESSION_ARG" ] || [[ "$SESSION_ARG" == "--verbose"* ]] || [[ "$SESSION_ARG" == "-v"* ]]; then
    # Use latest session
    latest=$(ls -t "$COORDINATION_DIR"/orchestration-*.json 2>/dev/null | head -1)
    if [ -n "$latest" ]; then
        SESSION_ID=$(jq -r '.sessionId' "$latest" 2>/dev/null)
    fi
else
    # Use provided session ID
    SESSION_ID=$(echo "$SESSION_ARG" | awk '{print $1}')
fi

if [ -z "$SESSION_ID" ]; then
    echo ""
    echo -e "${RED}✗${NC} No orchestration sessions found."
    echo ""
    echo "Check available sessions with: /status"
    exit 1
fi

STATE_FILE="$COORDINATION_DIR/orchestration-$SESSION_ID.json"

if [ ! -f "$STATE_FILE" ]; then
    echo ""
    echo -e "${RED}✗${NC} Session not found: $SESSION_ID"
    echo ""
    echo "Available sessions:"
    ls "$COORDINATION_DIR"/orchestration-*.json 2>/dev/null | while read -r file; do
        sid=$(jq -r '.sessionId' "$file" 2>/dev/null)
        echo "  • $sid"
    done
    echo ""
    exit 1
fi

# Parse state file
TOTAL_TASKS=$(jq '.tasks | length' "$STATE_FILE" 2>/dev/null)
STATUS=$(jq -r '.status' "$STATE_FILE" 2>/dev/null)
STARTED_AT=$(jq -r '.startedAt' "$STATE_FILE" 2>/dev/null)

# Count task statuses
COMPLETED=0
IN_PROGRESS=0
PENDING=0

# Check each task's metadata
for worktree in "$RUNS_DIR"/*/; do
    if [ ! -d "$worktree" ]; then
        continue
    fi
    
    meta_file="${worktree}.droidz-meta.json"
    if [ -f "$meta_file" ]; then
        task_status=$(jq -r '.status' "$meta_file" 2>/dev/null || echo "unknown")
        case "$task_status" in
            completed)
                ((COMPLETED++))
                ;;
            in_progress)
                ((IN_PROGRESS++))
                ;;
            *)
                ((PENDING++))
                ;;
        esac
    else
        ((PENDING++))
    fi
done

# Calculate percentage
if [ "$TOTAL_TASKS" -gt 0 ]; then
    PERCENT=$((COMPLETED * 100 / TOTAL_TASKS))
else
    PERCENT=0
fi

# Display summary
echo ""
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}  Orchestration Summary: ${BOLD}$SESSION_ID${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Progress:${NC} $COMPLETED/$TOTAL_TASKS tasks complete (${PERCENT}%)"
echo ""
echo -e "  ${GREEN}✅ Completed:${NC}    $COMPLETED"
echo -e "  ${YELLOW}⏳ In Progress:${NC}  $IN_PROGRESS"
echo -e "  ${CYAN}⏸  Pending:${NC}      $PENDING"
echo ""

# Show recent completions
echo -e "${BOLD}Recent Completions:${NC}"
completed_count=0
for worktree in "$RUNS_DIR"/*/; do
    if [ ! -d "$worktree" ]; then
        continue
    fi
    
    meta_file="${worktree}.droidz-meta.json"
    if [ -f "$meta_file" ]; then
        task_status=$(jq -r '.status' "$meta_file" 2>/dev/null)
        if [ "$task_status" = "completed" ]; then
            task_key=$(jq -r '.taskKey' "$meta_file" 2>/dev/null)
            
            # Count files changed
            files_changed=$(git -C "$worktree" diff --name-only HEAD~1 2>/dev/null | wc -l | tr -d ' ')
            
            echo -e "  ${GREEN}✓${NC} $task_key (${files_changed} files changed)"
            
            ((completed_count++))
            if [ $completed_count -ge 3 ]; then
                break
            fi
        fi
    fi
done

if [ $completed_count -eq 0 ]; then
    echo "  (none yet)"
fi
echo ""

# Show currently running
if [ $IN_PROGRESS -gt 0 ]; then
    echo -e "${BOLD}Currently Running:${NC}"
    running_count=0
    for worktree in "$RUNS_DIR"/*/; do
        if [ ! -d "$worktree" ]; then
            continue
        fi
        
        meta_file="${worktree}.droidz-meta.json"
        if [ -f "$meta_file" ]; then
            task_status=$(jq -r '.status' "$meta_file" 2>/dev/null)
            if [ "$task_status" = "in_progress" ]; then
                task_key=$(jq -r '.taskKey' "$meta_file" 2>/dev/null)
                echo -e "  ${YELLOW}⏳${NC} $task_key"
                
                ((running_count++))
                if [ $running_count -ge 5 ]; then
                    break
                fi
            fi
        fi
    done
    echo ""
fi

# Show next pending
if [ $PENDING -gt 0 ]; then
    echo -e "${BOLD}Next Up:${NC}"
    pending_count=0
    for worktree in "$RUNS_DIR"/*/; do
        if [ ! -d "$worktree" ]; then
            continue
        fi
        
        meta_file="${worktree}.droidz-meta.json"
        if [ -f "$meta_file" ]; then
            task_status=$(jq -r '.status' "$meta_file" 2>/dev/null)
            if [ "$task_status" != "completed" ] && [ "$task_status" != "in_progress" ]; then
                task_key=$(jq -r '.taskKey' "$meta_file" 2>/dev/null)
                echo -e "  ${CYAN}⏸${NC}  $task_key"
                
                ((pending_count++))
                if [ $pending_count -ge 3 ]; then
                    break
                fi
            fi
        fi
    done
    echo ""
fi

# Quick actions
echo -e "${BOLD}Quick Actions:${NC}"
echo "  Monitor live:   .factory/scripts/monitor-orchestration.sh --session $SESSION_ID --interval 30"
echo "  Take snapshot:  .factory/scripts/monitor-orchestration.sh --snapshot --session $SESSION_ID"

# Show attach command for in-progress tasks
if [ $IN_PROGRESS -gt 0 ]; then
    first_running=""
    for worktree in "$RUNS_DIR"/*/; do
        if [ ! -d "$worktree" ]; then
            continue
        fi
        
        meta_file="${worktree}.droidz-meta.json"
        if [ -f "$meta_file" ]; then
            task_status=$(jq -r '.status' "$meta_file" 2>/dev/null)
            if [ "$task_status" = "in_progress" ]; then
                first_running=$(jq -r '.taskKey' "$meta_file" 2>/dev/null)
                break
            fi
        fi
    done
    
    if [ -n "$first_running" ]; then
        echo "  Attach to task: /attach $first_running"
    fi
fi

echo ""

# Show session info if verbose
if [[ "$SESSION_ARG" == *"--verbose"* ]] || [[ "$SESSION_ARG" == *"-v"* ]]; then
    echo -e "${BOLD}Session Info:${NC}"
    echo "  Session ID: $SESSION_ID"
    echo "  Status: $STATUS"
    echo "  Started: $STARTED_AT"
    echo "  Worktrees: $RUNS_DIR/"
    echo "  State file: $STATE_FILE"
    echo ""
fi
</execute>
