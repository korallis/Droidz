#!/bin/bash
#
# Parallel Agent Progress Monitor
# Monitors file changes every 30 seconds while Task tool agents are running
#

set -e

# Read configuration from environment or use defaults
INTERVAL=${PARALLEL_MONITOR_INTERVAL:-30}
PROJECT_DIR=${DROID_PROJECT_DIR:-$(pwd)}
LOG_FILE="/tmp/droidz-parallel-monitor-$$.log"

# Initialize tracking
last_file_count=0
last_git_status=""
start_time=$(date +%s)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "🤖 Parallel Agent Monitor Started" | tee -a "$LOG_FILE"
echo "📁 Project: $PROJECT_DIR" | tee -a "$LOG_FILE"
echo "⏱️  Check Interval: ${INTERVAL}s" | tee -a "$LOG_FILE"
echo "🕐 Started: $(date '+%H:%M:%S')" | tee -a "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to display progress update
show_progress() {
    local elapsed=$(($(date +%s) - start_time))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    
    echo "" | tee -a "$LOG_FILE"
    echo "⏱️  Progress Update (${minutes}m ${seconds}s elapsed)" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    
    # Check git status for modified/new files
    cd "$PROJECT_DIR" 2>/dev/null || return
    
    local modified_files=$(git status --short 2>/dev/null | grep -E "^(M| M|A| A|\?\?)" | wc -l | tr -d ' ')
    local new_files=$(git status --short 2>/dev/null | grep "^??" | wc -l | tr -d ' ')
    local modified_tracked=$(git status --short 2>/dev/null | grep -E "^(M| M)" | wc -l | tr -d ' ')
    local staged_files=$(git status --short 2>/dev/null | grep -E "^(A|M)" | wc -l | tr -d ' ')
    
    # Display summary
    echo "📊 File Changes Detected:" | tee -a "$LOG_FILE"
    echo "   • Modified: $modified_tracked files" | tee -a "$LOG_FILE"
    echo "   • New:      $new_files files" | tee -a "$LOG_FILE"
    echo "   • Staged:   $staged_files files" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Show recent file changes (up to 10)
    if [ "$modified_files" -gt 0 ]; then
        echo "📝 Recently Changed Files:" | tee -a "$LOG_FILE"
        git status --short 2>/dev/null | head -10 | while read -r line; do
            echo "   $line" | tee -a "$LOG_FILE"
        done
        echo "" | tee -a "$LOG_FILE"
    fi
    
    # Show agent activity hints
    echo "🤖 Agent Activity Indicators:" | tee -a "$LOG_FILE"
    
    # Check for common patterns
    if git diff --name-only HEAD 2>/dev/null | grep -qE "\.(tsx?|jsx?)$"; then
        echo "   ✓ Frontend changes detected (React/TypeScript)" | tee -a "$LOG_FILE"
    fi
    
    if git diff --name-only HEAD 2>/dev/null | grep -qE "(api/|lib/|utils/)"; then
        echo "   ✓ Backend/API changes detected" | tee -a "$LOG_FILE"
    fi
    
    if git diff --name-only HEAD 2>/dev/null | grep -qE "(test|spec)\.(tsx?|jsx?)$"; then
        echo "   ✓ Test files being created/modified" | tee -a "$LOG_FILE"
    fi
    
    if git diff --name-only HEAD 2>/dev/null | grep -qE "\.(yml|yaml|json|md)$"; then
        echo "   ✓ Configuration/documentation updates" | tee -a "$LOG_FILE"
    fi
    
    if [ "$modified_files" -eq 0 ] && [ "$last_file_count" -eq 0 ]; then
        echo "   ⏳ Agents initializing... (no changes yet)" | tee -a "$LOG_FILE"
    elif [ "$modified_files" -eq "$last_file_count" ]; then
        echo "   ⏸️  Agents may be processing (no new changes)" | tee -a "$LOG_FILE"
    else
        echo "   🔄 Agents actively working (changes detected)" | tee -a "$LOG_FILE"
    fi
    
    echo "" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    
    # Update tracking
    last_file_count=$modified_files
}

# Cleanup function
cleanup() {
    echo "" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    echo "✅ Parallel Agent Monitor Stopped" | tee -a "$LOG_FILE"
    echo "🕐 Ended: $(date '+%H:%M:%S')" | tee -a "$LOG_FILE"
    echo "📋 Full log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    exit 0
}

# Trap signals for cleanup
trap cleanup SIGTERM SIGINT

# Show first progress update immediately
show_progress

# Main monitoring loop
while true; do
    sleep "$INTERVAL"
    show_progress
done
