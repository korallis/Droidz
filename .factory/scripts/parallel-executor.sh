#!/usr/bin/env bash
#
# Parallel Executor for Droidz Orchestrator
#
# Executes tasks in phases based on dependency resolution.
# All tasks in a phase run in parallel. Next phase starts when all tasks in current phase complete.
#

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependency resolver
# shellcheck source=dependency-resolver.sh
source "$SCRIPT_DIR/dependency-resolver.sh"

#
# Execute tasks in phases with dependency resolution
#
# Arguments:
#   $1 - tasks.json content
#   $2 - callback function for spawning task (receives task_key, task_json)
#   $3 - callback function for waiting on task (receives task_key)
#
execute_with_dependencies() {
    local tasks_json="$1"
    local spawn_callback="$2"
    local wait_callback="$3"
    
    echo -e "${CYAN}▶${NC} Analyzing dependencies..."
    
    # Validate dependencies
    if ! validate_dependencies "$tasks_json"; then
        echo -e "${YELLOW}⚠${NC} Continuing with warnings..."
    fi
    
    # Resolve dependencies
    local resolution
    resolution=$(resolve_dependencies "$tasks_json")
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗${NC} Failed to resolve dependencies"
        return 1
    fi
    
    # Print execution plan
    print_execution_plan "$resolution"
    
    # Get phase count
    local phase_count
    phase_count=$(get_phase_count "$resolution")
    
    echo -e "${BOLD}Executing $phase_count phases...${NC}"
    echo ""
    
    # Execute each phase
    for phase in $(seq 1 "$phase_count"); do
        echo ""
        echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}Phase $phase/${phase_count}${NC}"
        echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Get tasks in this phase
        local phase_tasks=()
        while IFS= read -r task_key; do
            phase_tasks+=("$task_key")
        done < <(get_phase_tasks "$resolution" "$phase")
        
        echo "Tasks in this phase: ${#phase_tasks[@]}"
        for task_key in "${phase_tasks[@]}"; do
            local deps=$(get_task_dependencies "$resolution" "$task_key")
            if [ -n "$deps" ]; then
                echo "  • $task_key ${YELLOW}(depends on: $deps)${NC}"
            else
                echo "  • $task_key ${GREEN}(no dependencies)${NC}"
            fi
        done
        echo ""
        
        # Spawn all tasks in parallel
        echo -e "${CYAN}▶${NC} Spawning tasks..."
        for task_key in "${phase_tasks[@]}"; do
            # Get task JSON from original tasks
            local task_index
            task_index=$(echo "$tasks_json" | jq --arg key "$task_key" \
                '.tasks | to_entries | .[] | select(.value.key == $key) | .key')
            
            local task_json
            task_json=$(echo "$tasks_json" | jq ".tasks[$task_index]")
            
            echo "  • Spawning $task_key..."
            
            # Call spawn callback
            if ! "$spawn_callback" "$task_key" "$task_json"; then
                echo -e "${RED}✗${NC} Failed to spawn $task_key"
            fi
        done
        
        echo ""
        echo -e "${YELLOW}⏳${NC} Waiting for phase $phase to complete..."
        echo ""
        
        # Wait for all tasks in phase to complete
        for task_key in "${phase_tasks[@]}"; do
            echo "  • Waiting for $task_key..."
            
            # Call wait callback
            if "$wait_callback" "$task_key"; then
                echo -e "    ${GREEN}✓${NC} $task_key complete"
            else
                echo -e "    ${RED}✗${NC} $task_key failed or timeout"
            fi
        done
        
        echo ""
        echo -e "${GREEN}✓${NC} Phase $phase complete"
    done
    
    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}All Phases Complete!${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#
# Example: Spawn task callback (for testing)
#
example_spawn_task() {
    local task_key="$1"
    local task_json="$2"
    
    # In real implementation, this would:
    # - Create worktree
    # - Start tmux session
    # - Spawn droid agent
    
    echo "    [SPAWN] $task_key"
    return 0
}

#
# Example: Wait for task callback (for testing)
#
example_wait_task() {
    local task_key="$1"
    
    # In real implementation, this would:
    # - Monitor tmux session
    # - Check for completion markers
    # - Timeout after X minutes
    
    # Simulate work
    sleep 1
    
    return 0
}

# If script is run directly (for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <tasks.json>"
        exit 1
    fi
    
    tasks_file="$1"
    
    if [ ! -f "$tasks_file" ]; then
        echo "Error: File not found: $tasks_file"
        exit 1
    fi
    
    tasks_json=$(cat "$tasks_file")
    
    echo "Testing parallel execution with dependency resolution..."
    echo ""
    
    execute_with_dependencies "$tasks_json" "example_spawn_task" "example_wait_task"
fi
