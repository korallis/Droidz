#!/usr/bin/env bash
#
# Droidz Orchestrator - True Parallel Execution with Git Worktrees
#
# Creates isolated git worktrees for parallel task execution with specialist agents.
# Uses tmux for terminal multiplexing and coordination.
#
# Usage:
#   orchestrator.sh --tasks tasks.json
#   orchestrator.sh --linear-query "sprint:current AND label:auto-droidz"
#   orchestrator.sh --spec .factory/specs/active/feature-auth.md
#   orchestrator.sh --interactive
#

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly RUNS_DIR="$PROJECT_ROOT/.runs"
readonly COORDINATION_DIR="$RUNS_DIR/.coordination"
readonly ORCHESTRATION_LOG="$COORDINATION_DIR/orchestration.log"
readonly SESSION_ID="$(date +%Y%m%d-%H%M%S)-$$"

# Ensure coordination directory exists
mkdir -p "$COORDINATION_DIR"

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$ORCHESTRATION_LOG"
}

info() { log "INFO" "${BLUE}ℹ${NC} $*"; }
success() { log "SUCCESS" "${GREEN}✓${NC} $*"; }
warning() { log "WARNING" "${YELLOW}⚠${NC} $*"; }
error() { log "ERROR" "${RED}✗${NC} $*"; }
step() { log "STEP" "${CYAN}▶${NC} $*"; }

# Error handler
trap 'error "Script failed at line $LINENO. Exit code: $?"' ERR

# Check dependencies
check_dependencies() {
    local deps=("git" "jq" "tmux")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  brew install ${missing[*]}"
        exit 1
    fi
}

# Parse task list from various sources
parse_tasks() {
    local source="$1"
    local tasks_json=""

    case "$source" in
        linear:*)
            # Parse Linear query
            local query="${source#linear:}"
            info "Fetching tasks from Linear: $query"
            tasks_json=$(fetch_linear_tasks "$query")
            ;;
        spec:*)
            # Parse spec file
            local spec_file="${source#spec:}"
            info "Parsing tasks from spec: $spec_file"
            tasks_json=$(parse_spec_file "$spec_file")
            ;;
        file:*)
            # Load JSON file
            local tasks_file="${source#file:}"
            info "Loading tasks from: $tasks_file"
            tasks_json=$(cat "$tasks_file")
            ;;
        *)
            error "Unknown task source: $source"
            exit 1
            ;;
    esac

    echo "$tasks_json"
}

# Fetch tasks from Linear
fetch_linear_tasks() {
    local query="$1"

    # Use Linear MCP to fetch issues
    # This is a placeholder - actual implementation would use Linear API
    cat <<EOF
{
  "tasks": [
    {
      "key": "DROIDZ-001",
      "title": "Example task from Linear",
      "description": "This is an example task",
      "specialist": "droidz-codegen",
      "priority": 1
    }
  ]
}
EOF
}

# Parse tasks from spec file
parse_spec_file() {
    local spec_file="$1"

    if [ ! -f "$spec_file" ]; then
        error "Spec file not found: $spec_file"
        exit 1
    fi

    # Parse markdown spec and extract tasks
    # This is a simplified version - actual implementation would parse properly
    info "Parsing spec file: $spec_file"

    # Return example tasks for now
    cat <<EOF
{
  "tasks": [
    {
      "key": "TASK-001",
      "title": "Task from spec",
      "description": "Parsed from $spec_file",
      "specialist": "droidz-codegen",
      "priority": 1
    }
  ]
}
EOF
}

# Create worktree for a task
create_worktree() {
    local task_key="$1"
    local task_title="$2"
    local specialist="${3:-droidz-codegen}"

    # Sanitize branch name
    local slug="$(echo "$task_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)"
    local branch_name="feat/${task_key}-${slug}"
    local worktree_path="$RUNS_DIR/$task_key"

    step "Creating worktree for $task_key"

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        warning "Worktree already exists: $worktree_path"
        return 1
    fi

    # Create worktree
    cd "$PROJECT_ROOT"
    if git worktree add -b "$branch_name" "$worktree_path" >> "$ORCHESTRATION_LOG" 2>&1; then
        success "Created worktree: $worktree_path"
        success "Created branch: $branch_name"

        # Record worktree metadata
        cat > "$worktree_path/.droidz-meta.json" <<EOF
{
  "taskKey": "$task_key",
  "branchName": "$branch_name",
  "specialist": "$specialist",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sessionId": "$SESSION_ID",
  "status": "created"
}
EOF

        echo "$worktree_path"
        return 0
    else
        error "Failed to create worktree for $task_key"
        return 1
    fi
}

# Create tmux session for a task
create_tmux_session() {
    local task_key="$1"
    local worktree_path="$2"
    local specialist="$3"
    local task_description="$4"

    local session_name="droidz-$task_key"

    step "Creating tmux session: $session_name"

    # Check if session already exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        warning "Tmux session already exists: $session_name"
        return 1
    fi

    # Create detached tmux session
    tmux new-session -d -s "$session_name" -c "$worktree_path"

    # Create instruction file for Claude FIRST (before tmux setup references it)
    cat > "$worktree_path/.factory-context.md" <<EOF
# Task: $task_key

## Workspace Information
- **Worktree**: $worktree_path
- **Branch**: $(git -C "$worktree_path" branch --show-current)
- **Specialist**: $specialist
- **Session**: $session_name

## Task Description
$task_description

## Your Objective
Implement this task following Droidz standards:
1. Read and understand the requirements
2. Implement the feature/fix
3. Write comprehensive tests
4. Ensure all tests pass
5. Commit your changes
6. Update progress in .droidz-meta.json

## Coordination
- Progress file: $worktree_path/.droidz-meta.json
- Coordination dir: $COORDINATION_DIR
- Lock files before modifying shared resources
- Report completion to coordination system

## Commands Available
- Run tests: \`bun test\`
- Lint: \`bun run lint\`
- Build: \`bun run build\`

When complete, update status in .droidz-meta.json to "completed".
EOF

    # Now set up tmux panes with welcome message (after context file exists)
    tmux send-keys -t "$session_name:0" "clear" C-m
    tmux send-keys -t "$session_name:0" "printf '╔════════════════════════════════════════════════╗\\n'" C-m
    tmux send-keys -t "$session_name:0" "printf '║  Droidz Workspace: $task_key\\n'" C-m
    tmux send-keys -t "$session_name:0" "printf '║  Specialist: $specialist\\n'" C-m
    tmux send-keys -t "$session_name:0" "printf '╚════════════════════════════════════════════════╝\\n'" C-m
    tmux send-keys -t "$session_name:0" "echo ''" C-m
    tmux send-keys -t "$session_name:0" "echo 'Context file: .factory-context.md'" C-m
    tmux send-keys -t "$session_name:0" "echo 'Progress file: .droidz-meta.json'" C-m
    tmux send-keys -t "$session_name:0" "echo ''" C-m

    success "Created tmux session: $session_name"
    echo "$session_name"
    return 0
}

# Start Droid in a tmux session
start_droid_in_session() {
    local session_name="$1"
    local specialist="$2"
    local worktree_path="$3"

    step "Preparing workspace for $specialist in $session_name"

    # Display ready message (agent will be invoked manually)
    tmux send-keys -t "$session_name:0" "echo ''" C-m
    tmux send-keys -t "$session_name:0" "echo '═══════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$session_name:0" "echo 'Workspace ready for: $specialist'" C-m
    tmux send-keys -t "$session_name:0" "echo ''" C-m
    tmux send-keys -t "$session_name:0" "echo 'Task instructions: .factory-context.md'" C-m
    tmux send-keys -t "$session_name:0" "echo 'Progress tracking: .droidz-meta.json'" C-m
    tmux send-keys -t "$session_name:0" "echo ''" C-m
    tmux send-keys -t "$session_name:0" "echo 'Attach to this session and invoke your agent:'" C-m
    tmux send-keys -t "$session_name:0" "echo '  tmux attach -t $session_name'" C-m
    tmux send-keys -t "$session_name:0" "echo ''" C-m
    tmux send-keys -t "$session_name:0" "echo 'Waiting for agent invocation...'" C-m
    tmux send-keys -t "$session_name:0" "echo '═══════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$session_name:0" "echo ''"

    success "Workspace prepared in session: $session_name"
    info "Attach with: tmux attach -t $session_name"
    info "Context file: $worktree_path/.factory-context.md"
}

# Filter out already completed tasks based on existing branches
filter_incomplete_tasks() {
    local tasks_json="$1"
    
    # Get list of already completed task keys from git branches (format: feat/TASK-001-*)
    local completed_tasks=$(git branch -a 2>/dev/null | grep -oE '[A-Z]+-[0-9]+' | sort -u || echo "")
    
    if [ -z "$completed_tasks" ]; then
        # No completed tasks found, return original JSON
        echo "$tasks_json"
        return 0
    fi
    
    # Convert completed tasks to jq-compatible format for filtering
    local completed_pattern=$(echo "$completed_tasks" | tr '\n' '|' | sed 's/|$//')
    
    # Filter tasks: keep only those whose key is NOT in the completed list
    local filtered_json=$(echo "$tasks_json" | jq --arg pattern "$completed_pattern" '
        .tasks = [.tasks[] | select(
            (.key | test("^(" + $pattern + ")$")) | not
        )]
    ')
    
    echo "$filtered_json"
}

# Orchestrate multiple tasks in parallel
orchestrate_tasks() {
    local tasks_json="$1"
    local total_tasks=$(echo "$tasks_json" | jq '.tasks | length')
    
    # Filter out already completed tasks
    tasks_json=$(filter_incomplete_tasks "$tasks_json")
    local num_tasks=$(echo "$tasks_json" | jq '.tasks | length')
    local completed_count=$((total_tasks - num_tasks))
    
    if [ $completed_count -gt 0 ]; then
        info "Found $total_tasks total tasks"
        success "$completed_count tasks already have branches (skipping)"
        info "Orchestrating $num_tasks remaining tasks in parallel"
    else
        info "Orchestrating $num_tasks tasks in parallel"
    fi
    
    if [ $num_tasks -eq 0 ]; then
        warning "All tasks already have branches. Nothing to orchestrate."
        echo ""
        echo "To force re-orchestration, delete the existing branches first:"
        echo "  git branch -D feat/TASK-XXX-*"
        echo ""
        return 0
    fi

    # Create orchestration state file
    local state_file="$COORDINATION_DIR/orchestration-$SESSION_ID.json"
    echo "$tasks_json" | jq --arg session "$SESSION_ID" '. + {sessionId: $session, status: "planning", startedAt: now|todate}' > "$state_file"

    # Create worktrees and tmux sessions for each task
    local worktrees=()
    local sessions=()

    for i in $(seq 0 $((num_tasks - 1))); do
        local task=$(echo "$tasks_json" | jq -r ".tasks[$i]")
        local task_key=$(echo "$task" | jq -r '.key')
        local task_title=$(echo "$task" | jq -r '.title')
        local task_desc=$(echo "$task" | jq -r '.description')
        local specialist=$(echo "$task" | jq -r '.specialist // "droidz-codegen"')

        info "Processing task $((i + 1))/$num_tasks: $task_key"

        # Create worktree
        if worktree_path=$(create_worktree "$task_key" "$task_title" "$specialist"); then
            worktrees+=("$worktree_path")

            # Create tmux session
            if session_name=$(create_tmux_session "$task_key" "$worktree_path" "$specialist" "$task_desc"); then
                sessions+=("$session_name")

                # Start Droid in session automatically
                start_droid_in_session "$session_name" "$specialist" "$worktree_path"
            fi
        fi
    done

    # Update state file with created resources
    jq --argjson worktrees "$(printf '%s\n' "${worktrees[@]}" | jq -R . | jq -s .)" \
       --argjson sessions "$(printf '%s\n' "${sessions[@]}" | jq -R . | jq -s .)" \
       '.worktrees = $worktrees | .sessions = $sessions | .status = "ready"' \
       "$state_file" > "$state_file.tmp" && mv "$state_file.tmp" "$state_file"

    success "Orchestration ready!"
    echo ""
    echo "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo "${BOLD}${GREEN}║${NC}  ${BOLD}Parallel Execution Environment Ready${NC}"
    echo "${BOLD}${GREEN}╠═══════════════════════════════════════════════════════════╣${NC}"
    echo "${BOLD}${GREEN}║${NC}  Session ID: ${CYAN}$SESSION_ID${NC}"
    echo "${BOLD}${GREEN}║${NC}  Tasks: ${CYAN}$num_tasks${NC}"
    echo "${BOLD}${GREEN}║${NC}  Worktrees: ${CYAN}${#worktrees[@]}${NC}"
    echo "${BOLD}${GREEN}║${NC}  Tmux Sessions: ${CYAN}${#sessions[@]}${NC}"
    echo "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${BOLD}Next Steps:${NC}"
    echo ""

    for i in "${!sessions[@]}"; do
        echo "  ${CYAN}$((i + 1)).${NC} tmux attach -t ${sessions[$i]}"
    done

    echo ""
    echo "${BOLD}Coordination:${NC}"
    echo "  State file: ${CYAN}$state_file${NC}"
    echo "  Logs: ${CYAN}$ORCHESTRATION_LOG${NC}"
    echo ""
    echo "${BOLD}To monitor all sessions:${NC}"
    echo "  tmux list-sessions | grep droidz"
    echo ""
}

# List active orchestrations
list_orchestrations() {
    step "Active Orchestrations"

    if [ ! -d "$COORDINATION_DIR" ]; then
        info "No orchestrations found"
        return
    fi

    local state_files=("$COORDINATION_DIR"/orchestration-*.json)

    if [ ! -e "${state_files[0]}" ]; then
        info "No orchestrations found"
        return
    fi

    for state_file in "${state_files[@]}"; do
        local session_id=$(jq -r '.sessionId' "$state_file")
        local status=$(jq -r '.status' "$state_file")
        local num_tasks=$(jq '.tasks | length' "$state_file")
        local started_at=$(jq -r '.startedAt' "$state_file")

        echo ""
        echo "  ${BOLD}Session:${NC} $session_id"
        echo "  ${BOLD}Status:${NC} $status"
        echo "  ${BOLD}Tasks:${NC} $num_tasks"
        echo "  ${BOLD}Started:${NC} $started_at"
    done
    echo ""
}

# Cleanup orchestration
cleanup_orchestration() {
    local session_id="$1"

    warning "Cleaning up orchestration: $session_id"

    local state_file="$COORDINATION_DIR/orchestration-$session_id.json"

    if [ ! -f "$state_file" ]; then
        error "Orchestration not found: $session_id"
        return 1
    fi

    # Get worktrees and sessions
    local worktrees=$(jq -r '.worktrees[]' "$state_file")
    local sessions=$(jq -r '.sessions[]' "$state_file")

    # Kill tmux sessions
    for session in $sessions; do
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux kill-session -t "$session"
            success "Killed tmux session: $session"
        fi
    done

    # Remove worktrees
    cd "$PROJECT_ROOT"
    for worktree in $worktrees; do
        if [ -d "$worktree" ]; then
            git worktree remove "$worktree" --force
            success "Removed worktree: $worktree"
        fi
    done

    # Archive state file
    mv "$state_file" "$state_file.archived"
    success "Archived orchestration: $session_id"
}

# Main function
main() {
    check_dependencies

    local mode="${1:---help}"

    case "$mode" in
        --tasks)
            local tasks_file="$2"
            if [ ! -f "$tasks_file" ]; then
                error "Tasks file not found: $tasks_file"
                exit 1
            fi
            local tasks_json=$(cat "$tasks_file")
            orchestrate_tasks "$tasks_json"
            ;;
        --linear-query)
            local query="$2"
            local tasks_json=$(parse_tasks "linear:$query")
            orchestrate_tasks "$tasks_json"
            ;;
        --spec)
            local spec_file="$2"
            local tasks_json=$(parse_tasks "spec:$spec_file")
            orchestrate_tasks "$tasks_json"
            ;;
        --list)
            list_orchestrations
            ;;
        --cleanup)
            local session_id="$2"
            cleanup_orchestration "$session_id"
            ;;
        --help|*)
            cat <<EOF
${BOLD}Droidz Orchestrator - True Parallel Execution${NC}

${BOLD}USAGE:${NC}
  $0 [MODE] [OPTIONS]

${BOLD}MODES:${NC}
  --tasks FILE              Orchestrate tasks from JSON file
  --linear-query QUERY      Fetch and orchestrate tasks from Linear
  --spec FILE               Parse and orchestrate tasks from spec file
  --list                    List active orchestrations
  --cleanup SESSION_ID      Clean up an orchestration
  --help                    Show this help message

${BOLD}EXAMPLES:${NC}
  # From JSON file
  $0 --tasks tasks.json

  # From Linear query
  $0 --linear-query "sprint:current AND label:auto-droidz"

  # From spec file
  $0 --spec .factory/specs/active/feature-auth.md

  # List active orchestrations
  $0 --list

  # Cleanup orchestration
  $0 --cleanup 20250112-143022-12345

${BOLD}OUTPUT:${NC}
  Logs: $ORCHESTRATION_LOG
  State: $COORDINATION_DIR/orchestration-*.json
  Worktrees: $RUNS_DIR/

${BOLD}REQUIREMENTS:${NC}
  - git
  - jq
  - tmux

EOF
            ;;
    esac
}

main "$@"
