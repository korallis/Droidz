# Quick Start - Droidz v0.0.7

**Get started with parallel orchestration in 3 steps!**

---

## ✅ Step 1: Check Installation

```bash
./status
```

You should see:
```
╔══════════════════════════════════════════════════════════════╗
║  ✅ DROIDZ v0.0.7 - INSTALLATION STATUS                      ║
╚══════════════════════════════════════════════════════════════╝

📦 INSTALLATION COMPLETE
  • All v0.0.7 features deployed
  • All documentation updated
  • All commands available
```

---

## ✅ Step 2: Run Auto-Parallel ⭐

Start droid:
```bash
droid
```

In the droid chat, type:
```
/auto-parallel "your task description here"
```

**Example:**
```
/auto-parallel "create a simple REST API with 3 endpoints"
```

**What happens:**
1. Droidz analyzes your request
2. Breaks it into tasks (3-7 tasks)
3. Creates git worktrees for parallel work
4. Spawns specialist droids for each task
5. **Shows you this prominent box:**

```
╔══════════════════════════════════════════════════════════════╗
║  🎯 NEXT STEP: Monitor Progress in Real-Time                 ║
╚══════════════════════════════════════════════════════════════╝

For live monitoring with visual progress bars, run:

  /watch
```

---

## ✅ Step 3: Watch Live Progress

When you see the box above, type:

```
/watch
```

**You'll see:**

```
╔══════════════════════════════════════════════════════════════════╗
║  Droidz Live Monitoring  16:45:23                                ║
╚══════════════════════════════════════════════════════════════════╝

Session: 20251114-164500-12345
Tasks Progress:
────────────────────────────────────────────────────────────────
  ✓ API-001: DONE - Create base structure
  ⏳ API-002: WORKING (droidz-codegen) - Add /health endpoint
  ⏳ API-003: WORKING (droidz-codegen) - Add /version endpoint
  ⏸ API-004: PENDING - Add tests

Progress: [████████░░░░] 25%

  ✓ Completed: 1
  ⏳ Working: 2
  ⏸ Pending: 1

Active Sessions: 4 tmux sessions running

Press Ctrl+C to exit | Updating every 2s...
```

---

## 🎯 That's It!

Three commands:
1. `./status` - Check installation
2. `/auto-parallel "task"` - Start orchestration
3. `/watch` - See live progress

---

## 📊 Other Useful Commands

```bash
# Quick status check
/status

# Detailed progress for specific session
/summary [session-id]

# Watch a specific task
/attach TASK-001

# GitHub PR helpers
/gh-helper pr-list
/gh-helper pr-checks 10
/gh-helper pr-status 10
```

---

## 💡 Pro Tips

1. **Use /auto-parallel instead of /parallel** - It gives you better guidance
2. **Always run /watch** - It's way better than /status for monitoring
3. **Let it run** - The droids work in parallel, saving you time
4. **Check logs if needed** - `.runs/.coordination/orchestration.log`

---

## 💡 Quick Status Check

To see installation status anytime:

```bash
./status
```

This shows:
- Installation status
- Available documentation
- Recommended workflow
- Command counts

Much cleaner than long terminal commands! ✨

---

**Ready to try?**

```bash
droid
/auto-parallel "create a simple hello world API endpoint"
/watch
```

🚀 Happy orchestrating!
