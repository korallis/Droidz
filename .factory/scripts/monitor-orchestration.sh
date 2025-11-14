#!/usr/bin/env bash
#
# Droidz Orchestration Monitor
#
# Monitors active tmux sessions from an orchestration and streams their output
# Can be used by agents to track progress in real-time
#
# Usage:
#   monitor-orchestration.sh --session SESSION_ID [--interval SECONDS]
#   monitor-orchestration.sh --list
#

set -euo pipefail

# Colors
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly COORDINATION_DIR="$PROJECT_ROOT/.runs/.coordination"
readonly DEFAULT_INTERVAL=30  # seconds

# Parse arguments
SESSION_ID=""
INTERVAL=$DEFAULT_INTERVAL
MODE="monitor"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --session)
            SESSION_ID="$2"
            shift 2
            ;;
        --interval)
            INTERVAL="$2"
            shift 2
            ;;
        --list)
            MODE="list"
            shift
            ;;
        --snapshot)
            MODE="snapshot"
            shift
            ;;
        --help)
            cat <<EOF
${BOLD}Droidz Orchestration Monitor${NC}

${BOLD}USAGE:${NC}
  $0 --session SESSION_ID [--interval SECONDS]
  $0 --list
  $0 --snapshot --session SESSION_ID
  $0 --help

${BOLD}MODES:${NC}
  --session SESSION_ID    Monitor specific orchestration (default: poll every 30s)
  --list                  List active orchestrations
  --snapshot              Take single snapshot of all tmux sessions
  --help                  Show this help

${BOLD}OPTIONS:${NC}
  --interval SECONDS      Polling interval for monitor mode (default: 30)

${BOLD}EXAMPLES:${NC}
  # Monitor orchestration with default 30s interval
  $0 --session 20251114-143000-12345

  # Monitor with custom 10s interval
  $0 --session 20251114-143000-12345 --interval 10

  # Take single snapshot
  $0 --snapshot --session 20251114-143000-12345

  # List all active orchestrations
  $0 --list

EOF
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# List active orchestrations
list_orchestrations() {
    echo -e "${BOLD}Active Orchestrations${NC}"
    echo ""

    if [ ! -d "$COORDINATION_DIR" ]; then
        echo "No orchestrations found"
        return
    fi

    local state_files=("$COORDINATION_DIR"/orchestration-*.json)

    if [ ! -e "${state_files[0]}" ]; then
        echo "No orchestrations found"
        return
    fi

    for state_file in "${state_files[@]}"; do
        if [ ! -f "$state_file" ]; then
            continue
        fi

        local session_id=$(jq -r '.sessionId' "$state_file" 2>/dev/null || echo "unknown")
        local status=$(jq -r '.status' "$state_file" 2>/dev/null || echo "unknown")
        local num_tasks=$(jq '.tasks | length' "$state_file" 2>/dev/null || echo "0")
        local started_at=$(jq -r '.startedAt' "$state_file" 2>/dev/null || echo "unknown")

        echo -e "  ${CYAN}●${NC} Session: ${BOLD}$session_id${NC}"
        echo "    Status: $status"
        echo "    Tasks: $num_tasks"
        echo "    Started: $started_at"
        echo ""
    done
}

# Capture tmux pane content
capture_pane() {
    local session_name="$1"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "[Session $session_name not found or terminated]"
        return 1
    fi

    # Capture last 50 lines of the pane
    tmux capture-pane -p -t "$session_name:0" -S -50 2>/dev/null || echo "[Could not capture pane]"
}

# Get task status from metadata file
get_task_status() {
    local worktree_path="$1"
    local meta_file="$worktree_path/.droidz-meta.json"
    
    if [ -f "$meta_file" ]; then
        jq -r '.status' "$meta_file" 2>/dev/null || echo "unknown"
    else
        echo "pending"
    fi
}

# Take snapshot of all sessions in an orchestration
snapshot_orchestration() {
    local session_id="$1"
    local state_file="$COORDINATION_DIR/orchestration-$session_id.json"
    
    if [ ! -f "$state_file" ]; then
        echo -e "${RED}✗${NC} Orchestration not found: $session_id"
        exit 1
    fi

    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  Orchestration Snapshot: $session_id"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Get all tmux sessions for this orchestration
    local sessions=$(jq -r '.sessions[]' "$state_file" 2>/dev/null)
    local worktrees=$(jq -r '.worktrees[]' "$state_file" 2>/dev/null)

    # Convert to arrays
    local -a session_array=()
    local -a worktree_array=()
    
    while IFS= read -r line; do
        [ -n "$line" ] && session_array+=("$line")
    done <<< "$sessions"
    
    while IFS= read -r line; do
        [ -n "$line" ] && worktree_array+=("$line")
    done <<< "$worktrees"

    # Capture each session
    for i in "${!session_array[@]}"; do
        local session_name="${session_array[$i]}"
        local worktree_path="${worktree_array[$i]}"
        local task_key=$(basename "$worktree_path")
        local task_status=$(get_task_status "$worktree_path")
        
        echo -e "${BOLD}━━━ Task: $task_key ━━━${NC}"
        echo -e "Status: ${CYAN}$task_status${NC}"
        echo -e "Session: $session_name"
        echo ""
        
        echo -e "${YELLOW}[Tmux Output]${NC}"
        echo "───────────────────────────────────────────────────────────"
        capture_pane "$session_name"
        echo "───────────────────────────────────────────────────────────"
        echo ""
    done
}

# Monitor orchestration continuously
monitor_orchestration() {
    local session_id="$1"
    local interval="$2"
    local state_file="$COORDINATION_DIR/orchestration-$session_id.json"
    
    if [ ! -f "$state_file" ]; then
        echo -e "${RED}✗${NC} Orchestration not found: $session_id"
        exit 1
    fi

    echo -e "${BOLD}${GREEN}Monitoring orchestration: $session_id${NC}"
    echo -e "Polling interval: ${CYAN}${interval}s${NC}"
    echo -e "Press ${BOLD}Ctrl+C${NC} to stop"
    echo ""

    local iteration=0
    
    while true; do
        ((iteration++))
        
        clear
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║${NC}  Live Monitor - Orchestration: $session_id"
        echo -e "${BOLD}${CYAN}║${NC}  Iteration: $iteration | Interval: ${interval}s | $(date '+%Y-%m-%d %H:%M:%S')"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""

        # Get all sessions
        local sessions=$(jq -r '.sessions[]' "$state_file" 2>/dev/null)
        local worktrees=$(jq -r '.worktrees[]' "$state_file" 2>/dev/null)

        # Convert to arrays
        local -a session_array=()
        local -a worktree_array=()
        
        while IFS= read -r line; do
            [ -n "$line" ] && session_array+=("$line")
        done <<< "$sessions"
        
        while IFS= read -r line; do
            [ -n "$line" ] && worktree_array+=("$line")
        done <<< "$worktrees"

        # Show summary
        local total_tasks=${#session_array[@]}
        local completed=0
        local in_progress=0
        local pending=0
        
        for i in "${!worktree_array[@]}"; do
            local status=$(get_task_status "${worktree_array[$i]}")
            case "$status" in
                completed) ((completed++)) ;;
                in_progress) ((in_progress++)) ;;
                *) ((pending++)) ;;
            esac
        done

        echo -e "${BOLD}Progress Summary:${NC}"
        echo -e "  ${GREEN}✓${NC} Completed: $completed/$total_tasks"
        echo -e "  ${YELLOW}⏳${NC} In Progress: $in_progress/$total_tasks"
        echo -e "  ${CYAN}⏸${NC}  Pending: $pending/$total_tasks"
        echo ""

        # Show last few lines from each active session
        for i in "${!session_array[@]}"; do
            local session_name="${session_array[$i]}"
            local worktree_path="${worktree_array[$i]}"
            local task_key=$(basename "$worktree_path")
            local task_status=$(get_task_status "$worktree_path")
            
            # Status indicator
            local status_icon
            case "$task_status" in
                completed) status_icon="${GREEN}✓${NC}" ;;
                in_progress) status_icon="${YELLOW}⏳${NC}" ;;
                *) status_icon="${CYAN}⏸${NC}" ;;
            esac

            echo -e "${BOLD}$status_icon $task_key${NC} ($task_status)"
            
            # Show last 10 lines from tmux
            if tmux has-session -t "$session_name" 2>/dev/null; then
                local output=$(tmux capture-pane -p -t "$session_name:0" -S -10 2>/dev/null | tail -3)
                if [ -n "$output" ]; then
                    echo "$output" | sed 's/^/  │ /'
                else
                    echo "  │ (no recent output)"
                fi
            else
                echo "  │ [session terminated]"
            fi
            echo ""
        done

        echo -e "${CYAN}Next update in ${interval}s...${NC}"
        sleep "$interval"
    done
}

# Main execution
case "$MODE" in
    list)
        list_orchestrations
        ;;
    snapshot)
        if [ -z "$SESSION_ID" ]; then
            echo "Error: --session required for snapshot mode"
            echo "Use --help for usage information"
            exit 1
        fi
        snapshot_orchestration "$SESSION_ID"
        ;;
    monitor)
        if [ -z "$SESSION_ID" ]; then
            echo "Error: --session required for monitor mode"
            echo "Use --help for usage information"
            exit 1
        fi
        monitor_orchestration "$SESSION_ID" "$INTERVAL"
        ;;
esac
