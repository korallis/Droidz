#!/usr/bin/env bash
#
# Dependency Resolver for Droidz Orchestrator
#
# Analyzes task dependencies and groups them into execution phases
# for optimal parallel execution.
#

set -euo pipefail

# Colors (only set if not already defined)
if [ -z "${GREEN+x}" ]; then
    readonly GREEN='\033[0;32m'
    readonly CYAN='\033[0;36m'
    readonly YELLOW='\033[1;33m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
fi

#
# Resolve dependencies and group tasks into phases
#
# Input: tasks.json content
# Output: JSON with tasks grouped by phase
#
# Example output:
# {
#   "phases": [
#     {
#       "phase": 1,
#       "tasks": ["TASK-001", "TASK-002"]  // No dependencies
#     },
#     {
#       "phase": 2,
#       "tasks": ["TASK-003"]  // Depends on TASK-001
#     }
#   ],
#   "executionPlan": {
#     "TASK-001": { "phase": 1, "dependencies": [] },
#     "TASK-002": { "phase": 1, "dependencies": [] },
#     "TASK-003": { "phase": 2, "dependencies": ["TASK-001"] }
#   }
# }
#
resolve_dependencies() {
    local tasks_json="$1"
    
    # Extract task keys and dependencies
    local task_count=$(echo "$tasks_json" | jq '.tasks | length')
    
    if [ "$task_count" -eq 0 ]; then
        echo '{"phases":[],"executionPlan":{}}'
        return
    fi
    
    # Build dependency map
    local dep_map="{}"
    
    for i in $(seq 0 $((task_count - 1))); do
        local task_key=$(echo "$tasks_json" | jq -r ".tasks[$i].key")
        local deps=$(echo "$tasks_json" | jq -c ".tasks[$i].dependencies // []")
        
        dep_map=$(echo "$dep_map" | jq --arg key "$task_key" --argjson deps "$deps" \
            '. + {($key): {dependencies: $deps, phase: null}}')
    done
    
    # Assign phases using topological sort
    local assigned_tasks=""
    local current_phase=1
    local remaining_tasks=$(echo "$dep_map" | jq -r 'keys[]' | tr '\n' ' ')
    
    while [ -n "$(echo "$remaining_tasks" | xargs)" ]; do
        local phase_tasks=""
        local phase_changed=false
        
        # Find tasks whose dependencies are all satisfied
        for task_key in $remaining_tasks; do
            [ -z "$task_key" ] && continue
            
            local deps=$(echo "$dep_map" | jq -r --arg key "$task_key" '.[$key].dependencies[]' 2>/dev/null || echo "")
            local can_execute=true
            
            # Check if all dependencies are in assigned_tasks
            if [ -n "$deps" ]; then
                for dep in $deps; do
                    if [ -z "$assigned_tasks" ] || ! echo " $assigned_tasks " | grep -q " $dep "; then
                        can_execute=false
                        break
                    fi
                done
            fi
            
            if $can_execute; then
                phase_tasks="$phase_tasks $task_key"
                dep_map=$(echo "$dep_map" | jq --arg key "$task_key" --argjson phase "$current_phase" \
                    '.[$key].phase = $phase')
                phase_changed=true
            fi
        done
        
        if ! $phase_changed; then
            # Circular dependency or orphaned task
            echo "{\"error\": \"Circular dependency detected or unresolvable dependencies\"}" >&2
            return 1
        fi
        
        # Add phase tasks to assigned tasks
        assigned_tasks="$assigned_tasks $phase_tasks"
        
        # Remove assigned tasks from remaining
        local new_remaining=""
        for task_key in $remaining_tasks; do
            [ -z "$task_key" ] && continue
            if ! echo " $phase_tasks " | grep -q " $task_key "; then
                new_remaining="$new_remaining $task_key"
            fi
        done
        remaining_tasks="$new_remaining"
        
        ((current_phase++))
    done
    
    # Build phases array
    local phases_json="[]"
    for phase in $(seq 1 $((current_phase - 1))); do
        local phase_tasks_json=$(echo "$dep_map" | jq -r --argjson p "$phase" \
            'to_entries | map(select(.value.phase == $p) | .key) | @json')
        
        phases_json=$(echo "$phases_json" | jq --argjson phase "$phase" \
            --argjson tasks "$phase_tasks_json" \
            '. + [{phase: $phase, tasks: $tasks}]')
    done
    
    # Build final output
    jq -n --argjson phases "$phases_json" --argjson plan "$dep_map" \
        '{phases: $phases, executionPlan: $plan}'
}

#
# Get tasks for a specific phase
#
get_phase_tasks() {
    local resolution_json="$1"
    local phase="$2"
    
    echo "$resolution_json" | jq -r --argjson p "$phase" \
        '.phases[] | select(.phase == $p) | .tasks[]'
}

#
# Get total number of phases
#
get_phase_count() {
    local resolution_json="$1"
    echo "$resolution_json" | jq '.phases | length'
}

#
# Get task phase number
#
get_task_phase() {
    local resolution_json="$1"
    local task_key="$2"
    
    echo "$resolution_json" | jq -r --arg key "$task_key" \
        '.executionPlan[$key].phase // 0'
}

#
# Get task dependencies
#
get_task_dependencies() {
    local resolution_json="$1"
    local task_key="$2"
    
    echo "$resolution_json" | jq -r --arg key "$task_key" \
        '.executionPlan[$key].dependencies[]? // empty'
}

#
# Print execution plan (for debugging)
#
print_execution_plan() {
    local resolution_json="$1"
    
    echo ""
    echo -e "${BOLD}Execution Plan:${NC}"
    echo ""
    
    local phase_count=$(get_phase_count "$resolution_json")
    
    for phase in $(seq 1 "$phase_count"); do
        echo -e "${CYAN}Phase $phase:${NC} (parallel execution)"
        
        while IFS= read -r task_key; do
            local deps=$(get_task_dependencies "$resolution_json" "$task_key")
            if [ -n "$deps" ]; then
                echo "  • $task_key (depends on: $deps)"
            else
                echo "  • $task_key (no dependencies)"
            fi
        done < <(get_phase_tasks "$resolution_json" "$phase")
        
        echo ""
    done
}

#
# Validate dependencies (check for missing tasks)
#
validate_dependencies() {
    local tasks_json="$1"
    
    local all_task_keys=$(echo "$tasks_json" | jq -r '.tasks[].key')
    local errors=()
    
    local task_count=$(echo "$tasks_json" | jq '.tasks | length')
    for i in $(seq 0 $((task_count - 1))); do
        local task_key=$(echo "$tasks_json" | jq -r ".tasks[$i].key")
        local deps=$(echo "$tasks_json" | jq -r ".tasks[$i].dependencies[]?" 2>/dev/null || echo "")
        
        for dep in $deps; do
            if ! echo "$all_task_keys" | grep -q "^$dep$"; then
                errors+=("Task $task_key depends on non-existent task: $dep")
            fi
        done
    done
    
    if [ ${#errors[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠ Dependency validation warnings:${NC}" >&2
        for error in "${errors[@]}"; do
            echo "  • $error" >&2
        done
        return 1
    fi
    
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
    
    echo "Validating dependencies..."
    if validate_dependencies "$tasks_json"; then
        echo "✓ All dependencies valid"
    fi
    
    echo ""
    echo "Resolving dependencies..."
    resolution=$(resolve_dependencies "$tasks_json")
    
    if [ $? -eq 0 ]; then
        print_execution_plan "$resolution"
        
        echo "JSON Output:"
        echo "$resolution" | jq .
    else
        echo "❌ Failed to resolve dependencies"
        exit 1
    fi
fi
