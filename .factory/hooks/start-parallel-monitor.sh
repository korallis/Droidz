#!/bin/bash
#
# Start Parallel Agent Monitor
# Triggered by PreToolUse:Task hook
#

set -e

# Read hook input from stdin
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)

# Only activate for Task tool
if [ "$tool_name" != "Task" ]; then
    exit 0
fi

# Get project directory
PROJECT_DIR=${DROID_PROJECT_DIR:-$(pwd)}
HOOKS_DIR="$PROJECT_DIR/.factory/hooks"
MONITOR_SCRIPT="$HOOKS_DIR/parallel-agent-monitor.sh"
PID_FILE="/tmp/droidz-parallel-monitor.pid"

# Check if monitor is already running
if [ -f "$PID_FILE" ]; then
    old_pid=$(cat "$PID_FILE" 2>/dev/null)
    if ps -p "$old_pid" > /dev/null 2>&1; then
        echo "⚠️  Parallel monitor already running (PID: $old_pid)" >&2
        exit 0
    fi
fi

# Start monitor in background
if [ -f "$MONITOR_SCRIPT" ]; then
    echo "" >&2
    echo "🔔 Starting automatic progress monitoring..." >&2
    echo "   Updates will appear every 30 seconds" >&2
    echo "" >&2
    
    # Start monitor and detach
    nohup "$MONITOR_SCRIPT" > /dev/null 2>&1 &
    monitor_pid=$!
    
    # Save PID for cleanup
    echo "$monitor_pid" > "$PID_FILE"
    
    # Disown the process so it continues after this hook exits
    disown
    
    echo "✅ Monitor started (PID: $monitor_pid)" >&2
else
    echo "⚠️  Monitor script not found: $MONITOR_SCRIPT" >&2
fi

exit 0
