# Testing Droidz v0.0.7 in a New Project

## ✅ What Was Fixed and Pushed

**Commit:** `448a607` - feat: v0.0.7 - Fix parallel orchestration and add monitoring tools  
**Branch:** `factory-ai`  
**Remote:** https://github.com/korallis/Droidz

### Changes Pushed:
1. ✅ **New commands:**
   - `.factory/commands/watch.sh` - Live monitoring
   - `.factory/commands/gh-helper.sh` - GitHub PR helpers
   
2. ✅ **Fixed parallel execution:**
   - `.factory/droids/droidz-parallel.md` - Now spawns Task() calls
   
3. ✅ **Enhanced monitoring:**
   - `.factory/commands/status.sh` - Reads actual task progress
   
4. ✅ **Updated installer:**
   - `install.sh` - Version 0.0.7, downloads new commands
   
5. ✅ **Documentation:**
   - `README.md` - New commands, v0.0.7 features
   - `CHANGELOG.md` - Detailed change log
   - `UPDATE_INSTALLATION.md` - Upgrade guide
   - `package.json` - Version metadata

---

## 🧪 How to Test in Another Project

### Step 1: Create or Navigate to Test Project

```bash
# Option A: Create a new test project
mkdir ~/test-droidz-v007
cd ~/test-droidz-v007
git init

# Option B: Use an existing project
cd ~/path/to/existing/project
```

---

### Step 2: Install Droidz v0.0.7

```bash
# Run the installer (pulls from factory-ai branch)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

**What to expect:**
```
╔══════════════════════════════════════════════════╗
║   Droidz Framework Installer v0.0.7             ║
║   For Factory.ai Droid CLI                      ║
╚══════════════════════════════════════════════════╝

Detected: macos (package manager: brew)

Checking dependencies
✓ Git found
✓ jq found
✓ tmux found

Creating directories
✓ Directories created

Downloading Droidz framework
ℹ Downloading commands...
✓ Downloaded parallel command
✓ Downloaded summary command
✓ Downloaded attach command
✓ Downloaded status command
✓ Downloaded watch command        # ← NEW!
✓ Downloaded gh-helper command    # ← NEW!

ℹ Downloading helper droids...
✓ Downloaded droidz-parallel droid
✓ Downloaded droidz-orchestrator droid
...

╔══════════════════════════════════════════════════╗
║   🎉 Installation Complete!                      ║
╚══════════════════════════════════════════════════╝
```

---

### Step 3: Verify Installation

```bash
# Check that new commands exist
ls -lh .factory/commands/
# Should show:
#   - watch.sh (NEW)
#   - gh-helper.sh (NEW)
#   - status.sh (updated)

# Check droidz-parallel has the fix
grep -c "Step 5: Spawn Specialist Droids" .factory/droids/droidz-parallel.md
# Should return: 1

# Check version
grep VERSION= install.sh
# Should show: VERSION="0.0.7"
```

---

### Step 4: Start Droid and Enable Custom Features

```bash
# Start droid
droid
```

**In the droid chat:**

```
# Enable custom features
/settings

# Toggle these ON:
→ Custom Commands: ON
→ Custom Droids: ON

# Exit (Ctrl+C) and restart:
droid
```

---

### Step 5: Verify Commands Loaded

**In droid chat:**

```
# Check commands
/commands

# Should see:
- /parallel
- /status
- /summary
- /attach
- /watch          # ← NEW!
- /gh-helper      # ← NEW!

# Check droids
/droids

# Should see:
- droidz-parallel
- droidz-orchestrator
- droidz-codegen
- droidz-test
- ... (8 total)
```

---

### Step 6: Test Parallel Execution (The Main Fix!)

**In droid chat:**

```
/parallel "create a simple API with 3 endpoints: /health, /version, and /users"
```

**What you should see (NEW behavior!):**

```
✅ Orchestration started!

Session ID: 20251114-180000-12345
Tasks: 3 tasks in 2 phases

Phase breakdown:
- Phase 1: API-001 (spawned now!)
- Phase 2: API-002, API-003 (will spawn after Phase 1)

Specialist droids spawned:        # ← THIS IS NEW!
- API-001: droidz-codegen (in progress)
- API-002: droidz-codegen (pending)
- API-003: droidz-test (pending)

Monitor progress:
  /status
  /summary 20251114-180000-12345
  /attach API-001

I'll monitor completion and spawn Phase 2 tasks automatically.
```

**Key difference from v0.0.6:**
- ❌ **Before:** Created worktrees, then nothing (tasks sat idle)
- ✅ **After:** Creates worktrees AND spawns specialist droids!

---

### Step 7: Test Live Monitoring

**In droid chat (while tasks are running):**

```
/watch
```

**What you should see:**

```
╔══════════════════════════════════════════════════════════════════╗
║  Droidz Live Monitoring  18:05:23                                ║
╚══════════════════════════════════════════════════════════════════╝

Session: 20251114-180000-12345
Status: running
Started: 2025-11-14 18:00:00

Tasks Progress:
────────────────────────────────────────────────────────────────
  ✓ API-001: DONE - Create API base structure
  ⏳ API-002: WORKING (droidz-codegen) - Add /health endpoint
  ⏳ API-003: WORKING (droidz-codegen) - Add /version endpoint

Progress: [████████░░░░] 33%

  ✓ Completed: 1
  ⏳ Working: 2
  ⏸ Pending: 0

Active Sessions: 3 tmux sessions running

Recent Activity:
────────────────────────────────────────────────────────────────
2025-11-14 18:04:12 [SUCCESS] ✓ API-001 completed
2025-11-14 18:04:23 [INFO] ℹ Starting API-002
2025-11-14 18:04:45 [INFO] ℹ Starting API-003

Press Ctrl+C to exit | Updating every 2s...
```

**Features to notice:**
- ✅ Updates automatically every 2 seconds
- ✅ Color-coded status (✓ done, ⏳ working, ⏸ pending)
- ✅ Progress bar visualization
- ✅ Shows which specialist is working on what
- ✅ Recent activity from logs

---

### Step 8: Test Enhanced Status

**In droid chat:**

```
/status
```

**What you should see (enhanced version):**

```
Active Orchestrations:

  ● 20251114-180000-12345
    Status: running
    Tasks: 3 total (1 done, 2 working, 0 waiting)
    Started: 2025-11-14 18:00:00
    Active sessions: 3 tmux sessions running  # ← NEW!

Monitor progress:
  /summary 20251114-180000-12345  - Detailed view
  /attach API-002                  - Watch a task
```

**Key improvements:**
- ✅ Shows actual task progress (reads from `.runs/TASK-KEY/.droidz-meta.json`)
- ✅ Displays active tmux sessions count
- ✅ Shows failed tasks if any exist

---

### Step 9: Test GitHub Helper (If You Have GitHub CLI)

**In droid chat:**

```
# List PRs
/gh-helper pr-list

# Check specific PR (replace 10 with your PR number)
/gh-helper pr-checks 10

# Get comprehensive status
/gh-helper pr-status 10
```

**What you should see:**

```
# No more "Unknown JSON field: status" errors!

[
  {
    "name": "CI / Build",
    "bucket": "pass",      # ← Correct field name!
    "conclusion": "success",
    "detailsUrl": "https://github.com/..."
  }
]
```

---

## ✅ Success Criteria

Your test is successful if:

1. ✅ **Installation completes** with version 0.0.7
2. ✅ **New commands exist:**
   - `/watch` command available
   - `/gh-helper` command available
3. ✅ **Parallel execution works:**
   - When you run `/parallel`, you see "Specialist droids spawned"
   - Tasks actually execute (not just sitting idle)
4. ✅ **Live monitoring works:**
   - `/watch` shows real-time updates every 2 seconds
   - Progress bar displays correctly
   - Color-coded status symbols appear
5. ✅ **Status is accurate:**
   - `/status` shows actual task progress
   - Active tmux sessions displayed
6. ✅ **GitHub helper works:**
   - `/gh-helper` commands execute without errors
   - No "Unknown JSON field" errors

---

## 🐛 If Something Doesn't Work

### Issue: Commands not found

**Check:**
```bash
# Verify files exist
ls -la .factory/commands/
```

**Fix:**
```bash
# Re-run installer
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

---

### Issue: "/parallel creates worktrees but nothing happens"

**Check:**
```bash
# Look for the fix in droidz-parallel
grep "CRITICAL.*spawn Task" .factory/droids/droidz-parallel.md
```

**Should show:**
```
**CRITICAL:** After the orchestrator completes, you MUST spawn Task() calls...
```

**If not found:**
```bash
# Download the fixed version
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/.factory/droids/droidz-parallel.md \
  -o .factory/droids/droidz-parallel.md
```

---

### Issue: "/watch command not found"

**Check:**
```bash
# Verify watch.sh exists and is executable
ls -lh .factory/commands/watch.sh
```

**Fix:**
```bash
# Download watch command
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/.factory/commands/watch.sh \
  -o .factory/commands/watch.sh
chmod +x .factory/commands/watch.sh

# Restart droid
```

---

### Issue: Still seeing old version

**Check installer version:**
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | grep VERSION=
# Should show: VERSION="0.0.7"
```

**If showing old version:**
- Clear browser cache (if you visited the raw URL before)
- Wait a few minutes for GitHub CDN to update
- Try direct download instead of installer

---

## 📊 Expected vs Previous Behavior

### v0.0.6 (Before):
```
You: /parallel "build auth"
Droid: ✅ Created tasks.json
       ✅ Created worktrees
       ✅ Created tmux sessions
       ❌ [Tasks sit idle forever]
       ❌ [No way to see what's wrong]
```

### v0.0.7 (After):
```
You: /parallel "build auth"
Droid: ✅ Created tasks.json
       ✅ Created worktrees
       ✅ Created tmux sessions
       ✅ Spawned specialist droids     # NEW!
       ⏳ Tasks actually executing       # NEW!

You: /watch
Droid: [Shows live progress bar]       # NEW!
       ✓ AUTH-001: DONE
       ⏳ AUTH-002: WORKING
       ⏳ AUTH-003: WORKING
```

---

## 🎯 Quick Smoke Test

**Minimal test to verify it's working:**

```bash
# 1. Install
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash

# 2. Start droid
droid

# In droid chat:
# 3. Enable features
/settings  # Toggle Custom Commands and Custom Droids ON, restart

# 4. Test parallel execution
/parallel "add a simple hello world endpoint"

# 5. Watch it work
/watch

# Success if you see:
# - "Specialist droids spawned" message
# - /watch shows live updates
# - Tasks actually complete (not stuck)
```

---

## 📝 Report Results

After testing, please report:

✅ **What worked:**
- Installation completed?
- Commands loaded?
- Parallel execution worked?
- /watch showed live progress?
- Tasks actually completed?

❌ **What didn't work:**
- Any errors during installation?
- Missing commands?
- Tasks sitting idle?
- /watch not updating?

📸 **Screenshots helpful:**
- Output of `/watch` command
- Output of `/status` command
- Any error messages

---

## 🔗 Resources

- **Repository:** https://github.com/korallis/Droidz
- **Branch:** factory-ai
- **Commit:** 448a607
- **Documentation:**
  - `README.md` - Full user guide
  - `UPDATE_INSTALLATION.md` - Upgrade guide
  - `CHANGELOG.md` - Version history

---

**Happy testing! 🚀**

If everything works, you should see **actual parallel task execution** with **real-time monitoring**!
