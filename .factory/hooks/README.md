# Droidz Automatic Progress Monitoring

## Overview

Automatic 30-second progress monitoring for parallel agent execution. When you spawn parallel agents with the Task tool, this system automatically:

1. **Starts monitoring** when Task tool is invoked
2. **Updates every 30 seconds** with file change progress
3. **Stops monitoring** when agents complete

## How It Works

### Architecture

```
PreToolUse:Task
    ↓
start-parallel-monitor.sh
    ↓
parallel-agent-monitor.sh (background process)
    ↓
[monitors every 30s]
    ↓
PostToolUse:Task
    ↓
stop-parallel-monitor.sh
```

### Components

#### 1. `parallel-agent-monitor.sh`
**Main monitoring script** that runs in the background and reports progress every 30 seconds.

**What it monitors:**
- Modified files (git status)
- New files created
- Staged changes
- Agent activity patterns (frontend, backend, tests, config)

**Output format:**
```
⏱️  Progress Update (2m 30s elapsed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 File Changes Detected:
   • Modified: 5 files
   • New:      3 files
   • Staged:   0 files

📝 Recently Changed Files:
   M  app/api/auth/route.ts
   M  components/LoginForm.tsx
   ?? components/RegisterForm.tsx

🤖 Agent Activity Indicators:
   ✓ Frontend changes detected (React/TypeScript)
   ✓ Backend/API changes detected
   🔄 Agents actively working (changes detected)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 2. `start-parallel-monitor.sh`
**PreToolUse:Task hook** that starts the monitor when Task tool is invoked.

- Checks if Task tool is being used
- Starts monitor in background
- Saves PID for cleanup
- Detaches process so it continues

#### 3. `stop-parallel-monitor.sh`
**PostToolUse:Task hook** that stops the monitor when agents complete.

- Reads PID from file
- Sends SIGTERM for graceful shutdown
- Cleans up PID file
- Force kills if necessary

## Configuration

### Settings (.factory/settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "name": "start-parallel-monitor",
            "type": "command",
            "command": "$DROID_PROJECT_DIR/.factory/hooks/start-parallel-monitor.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "name": "stop-parallel-monitor",
            "type": "command",
            "command": "$DROID_PROJECT_DIR/.factory/hooks/stop-parallel-monitor.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Environment Variables

- `PARALLEL_MONITOR_INTERVAL` - Update interval in seconds (default: 30)
- `DROID_PROJECT_DIR` - Project root directory (auto-detected)

## Usage

### Automatic (Default)

The monitoring system activates **automatically** when you spawn parallel agents:

```bash
# In droid CLI:
Use the Task tool with subagent_type "droidz-codegen" to build the authentication API
```

**You'll see:**
```
🔔 Starting automatic progress monitoring...
   Updates will appear every 30 seconds

✅ Monitor started (PID: 12345)
```

**Then every 30 seconds:**
```
⏱️  Progress Update (0m 30s elapsed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 File Changes Detected:
   • Modified: 2 files
   ...
```

**When agents complete:**
```
🛑 Stopping automatic progress monitoring...
✅ Monitor stopped
```

### Manual Control

If needed, you can control the monitor manually:

```bash
# Start manually
./.factory/hooks/parallel-agent-monitor.sh &
echo $! > /tmp/droidz-parallel-monitor.pid

# Stop manually
kill $(cat /tmp/droidz-parallel-monitor.pid)
rm /tmp/droidz-parallel-monitor.pid
```

### Custom Interval

```bash
# Check every 10 seconds instead of 30
export PARALLEL_MONITOR_INTERVAL=10
# Then spawn agents normally
```

## What Gets Monitored

### File Changes
- **Modified files** - Tracked files with changes
- **New files** - Untracked files created by agents
- **Staged files** - Files ready to commit

### Agent Activity Patterns
The monitor detects common patterns to indicate which agents are working:

| Pattern | Detection | Agent Hint |
|---------|-----------|------------|
| `*.tsx`, `*.jsx` | Frontend files | React/TypeScript agent |
| `api/`, `lib/` | Backend files | API/server agent |
| `*.test.*`, `*.spec.*` | Test files | Test agent |
| `*.yml`, `*.json` | Config files | Infrastructure agent |

### Progress Indicators
- ⏳ **Initializing** - No changes yet
- 🔄 **Actively working** - New changes detected
- ⏸️  **Processing** - No new changes (may be thinking/compiling)

## Logs

Full logs are saved to `/tmp/droidz-parallel-monitor-<PID>.log`

**View logs:**
```bash
tail -f /tmp/droidz-parallel-monitor-*.log
```

**Clean up old logs:**
```bash
rm /tmp/droidz-parallel-monitor-*.log
```

## Troubleshooting

### Monitor doesn't start

**Check if hooks are enabled:**
```bash
cat .factory/settings.json | jq '.hooks.PreToolUse'
```

**Check if script is executable:**
```bash
ls -la .factory/hooks/*.sh
# Should show: -rwxr-xr-x
```

**Fix permissions:**
```bash
chmod +x .factory/hooks/*.sh
```

### Monitor doesn't stop

**Manually kill it:**
```bash
pkill -f parallel-agent-monitor
rm /tmp/droidz-parallel-monitor.pid
```

### No updates showing

**Check if monitor is running:**
```bash
ps aux | grep parallel-agent-monitor
```

**Check logs:**
```bash
tail -f /tmp/droidz-parallel-monitor-*.log
```

### False positives

The monitor may show "no changes" if:
- Agents are still analyzing/planning
- Agents are waiting for dependencies
- Agents are running tests (no file changes)

This is normal! Agents don't always change files immediately.

## Benefits

### ✅ **Automatic** - No manual intervention needed
- Starts when you spawn agents
- Stops when agents complete
- No user action required

### ⏱️ **Real-time Updates** - Know what's happening
- File changes every 30 seconds
- Activity indicators per agent type
- Elapsed time tracking

### 📊 **Clear Progress** - Understand agent work
- Modified vs new files
- Frontend vs backend vs tests
- Active vs idle agents

### 🎯 **UX Friendly** - Clean, readable output
- Emoji indicators
- Formatted sections
- Not overwhelming

## Comparison: Manual vs Automatic

### Before (Manual Checks)
```
USER: "How's it going?"
YOU: [Check git status, report]

USER: "Check on the agents"
YOU: [Check again]

USER: "Are they done yet?"
YOU: [Check again]
```

### After (Automatic Monitoring)
```
[Agents spawn]
🔔 Starting automatic progress monitoring...

[30 seconds later]
⏱️  Progress Update (0m 30s elapsed)
   • Modified: 2 files
   ✓ Frontend changes detected

[30 seconds later]
⏱️  Progress Update (1m 0s elapsed)
   • Modified: 5 files
   ✓ Backend/API changes detected

[Agents complete]
🛑 Stopping automatic progress monitoring...
```

**Result:** User stays informed without asking!

## Future Enhancements

Possible improvements:
- [ ] Estimate completion based on file change velocity
- [ ] Send desktop notifications on major milestones
- [ ] Integrate with Linear to update ticket status
- [ ] Show memory/CPU usage of agent processes
- [ ] Detect and report errors in real-time
- [ ] Create progress visualization/dashboard

## Credits

Built for Droidz v2.6.2+ to provide automatic progress monitoring for parallel agent execution.

**Author:** Droidz Team  
**License:** Same as Droidz (MIT)
