# Droidz Installation Update Guide

## What's Fixed in This Update

### 1. **Parallel Orchestration Now Actually Works!** 🎉
   - **Before:** Orchestrator created worktrees but didn't spawn droids
   - **After:** `droidz-parallel` now spawns Task() calls for each specialist
   - **Impact:** Parallel tasks actually execute instead of sitting idle

### 2. **Better Visibility** 👀
   - **New `/watch` command:** Real-time monitoring with progress bars
   - **Enhanced `/status`:** Shows actual task progress from worktree meta files
   - **New `/gh-helper`:** GitHub PR operations with correct JSON fields

### 3. **GitHub PR Fixes** 🔧
   - **Fixed:** `gh pr checks` now uses correct `bucket` field (not `status`)
   - **Added:** Helper commands for common PR operations

## How to Update Your Installation

### Option 1: Quick Update (Recommended)

From your project directory (e.g., Viber):

```bash
# 1. Backup current installation
cp -r .factory .factory.backup

# 2. Copy updated files from Droidz repo
cp /Users/leebarry/Development/Droidz/.factory/droids/droidz-parallel.md .factory/droids/
cp /Users/leebarry/Development/Droidz/.factory/commands/status.sh .factory/commands/
cp /Users/leebarry/Development/Droidz/.factory/commands/gh-helper.sh .factory/commands/
cp /Users/leebarry/Development/Droidz/.factory/commands/watch.sh .factory/commands/

# 3. Make scripts executable
chmod +x .factory/commands/*.sh

# 4. Restart droid
# Exit current droid session and start a new one
```

### Option 2: Full Reinstall

```bash
# From your project directory
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

## What Changed

### File: `.factory/droids/droidz-parallel.md`

**Key Changes:**
- Added **Step 5: Spawn Specialist Droids** section
- Now includes Task() call template with proper worktree context
- Instructions to monitor completion and spawn dependent tasks
- Better reporting with spawned droid status

**Why:** The orchestrator was creating worktrees but the droidz-parallel agent wasn't spawning the actual specialist droids to work in them.

### File: `.factory/commands/status.sh`

**Key Changes:**
- Reads actual task status from `.runs/TASK-KEY/.droidz-meta.json` files
- Shows failed tasks count
- Displays active tmux sessions
- More accurate progress tracking

**Why:** Old version only read from orchestration JSON, not actual task progress.

### File: `.factory/commands/gh-helper.sh` (NEW)

**Features:**
- `/gh-helper pr-checks <number>` - Show PR checks with correct fields
- `/gh-helper pr-status <number>` - Comprehensive PR status
- `/gh-helper pr-list` - List all PRs

**Why:** GitHub CLI's `--json` flag uses `bucket` field, not `status` or `conclusion`.

### File: `.factory/commands/watch.sh` (NEW)

**Features:**
- Live monitoring with 2-second refresh
- Progress bar visualization
- Color-coded task status (✓ ✗ ⏳ ⏸)
- Shows recent activity from logs
- Displays active tmux sessions

**Why:** Users need real-time visibility into parallel task execution.

## Testing the Fixes

### Test 1: Basic Parallel Execution

```bash
# Start droid
droid

# In droid chat, run:
/parallel "add a simple hello world endpoint"

# You should see:
# ✅ Tasks generated
# ✅ Orchestration started
# ✅ Specialist droids spawned: [list of droids]
```

### Test 2: Live Monitoring

```bash
# In droid chat:
/watch

# You should see:
# - Real-time progress bar
# - Tasks updating from PENDING → WORKING → DONE
# - Active sessions count
# - Recent activity
```

### Test 3: Status Check

```bash
# In droid chat:
/status

# You should see:
# - Accurate task counts
# - Active tmux sessions
# - Failed tasks (if any)
```

### Test 4: GitHub Helper

```bash
# In droid chat:
/gh-helper pr-checks 10

# You should see:
# - PR check status with 'bucket' field
# - No JSON field errors
```

## Verifying the Update

### Check 1: Files Exist

```bash
ls -la .factory/commands/
# Should see:
#   - status.sh (updated timestamp)
#   - gh-helper.sh (new)
#   - watch.sh (new)

ls -la .factory/droids/
# Should see:
#   - droidz-parallel.md (updated timestamp)
```

### Check 2: droidz-parallel Has Task Spawning

```bash
grep -A5 "Step 5: Spawn Specialist Droids" .factory/droids/droidz-parallel.md
# Should show Task() call template
```

### Check 3: Commands Are Executable

```bash
file .factory/commands/status.sh
# Should show: executable

file .factory/commands/watch.sh
# Should show: executable

file .factory/commands/gh-helper.sh
# Should show: executable
```

## Troubleshooting

### Issue: "/watch command not found"

**Fix:**
```bash
# Restart droid to reload commands
# Exit current session and start new one
```

### Issue: "droidz-parallel still not spawning tasks"

**Check:**
```bash
# Verify the updated file
grep "CRITICAL.*spawn Task" .factory/droids/droidz-parallel.md

# Should show:
# **CRITICAL:** After the orchestrator completes, you MUST spawn Task() calls...
```

**Fix:** Re-copy the file:
```bash
cp /Users/leebarry/Development/Droidz/.factory/droids/droidz-parallel.md .factory/droids/
```

### Issue: "Permission denied executing watch.sh"

**Fix:**
```bash
chmod +x .factory/commands/*.sh
```

## Cleaning Up Old Sessions

If you have many stale tmux sessions from previous orchestrations:

```bash
# List all droidz sessions
tmux ls | grep droidz

# Kill all droidz sessions
tmux ls | grep "^droidz-" | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

## What to Expect After Update

### Before Update:
```
You: /parallel "build auth"
Droid: ✅ Created 7 tasks
       ✅ Orchestration started
       [then... nothing happens, tasks sit idle]
```

### After Update:
```
You: /parallel "build auth"
Droid: ✅ Created 7 tasks
       ✅ Orchestration started
       ✅ Spawned droids:
          - AUTH-001: droidz-codegen (in progress)
          - AUTH-002: droidz-codegen (in progress)
          - AUTH-003: droidz-test (in progress)
       
       [Then you can watch with /watch]
```

## New Workflow

1. **Start orchestration:**
   ```
   /parallel "your task description"
   ```

2. **Monitor in real-time:**
   ```
   /watch
   ```

3. **Check status anytime:**
   ```
   /status
   ```

4. **Get detailed summary:**
   ```
   /summary [session-id]
   ```

5. **Attach to specific task:**
   ```
   /attach TASK-001
   ```

## Need Help?

- **Discord:** [Join our community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
- **GitHub Issues:** https://github.com/korallis/Droidz/issues
- **Logs:** Check `.runs/.coordination/orchestration.log`

---

**Version:** 0.0.7 (includes parallel execution fixes)  
**Updated:** 2025-11-14  
**Breaking Changes:** None (backward compatible)
