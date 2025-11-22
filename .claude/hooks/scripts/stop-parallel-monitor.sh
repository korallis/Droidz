#!/bin/bash
#
# Stop Parallel Agent Monitor
# Triggered by PostToolUse:Task hook
#

set -e

# Read hook input from stdin
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)

# Only activate for Task tool
if [ "$tool_name" != "Task" ]; then
    exit 0
fi

PID_FILE="/tmp/droidz-parallel-monitor.pid"

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    exit 0
fi

# Read PID and kill monitor
monitor_pid=$(cat "$PID_FILE" 2>/dev/null)

if [ -n "$monitor_pid" ] && ps -p "$monitor_pid" > /dev/null 2>&1; then
    echo "" >&2
    echo "🛑 Stopping automatic progress monitoring..." >&2
    
    # Send SIGTERM for graceful shutdown
    kill -TERM "$monitor_pid" 2>/dev/null || true
    
    # Wait a moment for cleanup
    sleep 1
    
    # Force kill if still running
    if ps -p "$monitor_pid" > /dev/null 2>&1; then
        kill -9 "$monitor_pid" 2>/dev/null || true
    fi
    
    echo "✅ Monitor stopped" >&2
fi

# Clean up PID file
rm -f "$PID_FILE"

exit 0
