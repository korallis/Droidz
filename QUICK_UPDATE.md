# Quick Update Guide

## 🚀 Update Droidz in 3 Steps (2 minutes)

### Step 1: Update Files (30 seconds)

```bash
# From your project root, run:
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/orchestrator.droid.json -o .factory/droids/orchestrator.droid.json
```

### Step 2: Reload Droids (1 minute)

```bash
# Open Droid CLI
droid

# Inside Droid CLI, type:
/droids

# Select: "Reload Custom Droids"
```

### Step 3: Verify (30 seconds)

```bash
# Check the update worked:
cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
```

**Expected output:**
```
"Droidz's PRIMARY VALUE is PARALLEL EXECUTION"
```

**✅ Done! You now have automatic parallel execution enforcement.**

---

## What You'll Notice

Next time you run `@droidz-orchestrator`:

```
✅ Using git worktrees - this allows 5 workers to build simultaneously
✅ Planning to run 8 tasks with 5 parallel workers
💡 TIP: You have 8 independent tasks. Consider increasing concurrency to 8.
```

---

## Optional: Get All Updates

Want the full update including enhanced docs and validation?

```bash
# Download the full update script
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash

# Then reload droids:
droid
/droids → Reload Custom Droids
```

---

## Troubleshooting

**Not seeing the new messages?**
- Make sure you reloaded droids in Droid CLI (`/droids` → Reload)

**Git worktrees failing?**
- Run: `git worktree prune`
- Check: `git --version` (need 2.5+)

**Need more help?**
- See: [UPDATING.md](UPDATING.md) for detailed instructions
- See: [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md) for troubleshooting

---

**That's it! Enjoy 3-5x faster builds!** 🎉
