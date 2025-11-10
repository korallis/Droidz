# Parallel Execution Guide

## Why This Matters

**Droidz's core value proposition is PARALLEL EXECUTION with GIT WORKTREES.**

This is what makes Droidz 3-5x faster than sequential AI development:
- ❌ **Without parallel execution**: 1 AI builds 5 features sequentially (5 × 20min = 100min)
- ✅ **With parallel execution**: 5 AIs build 5 features simultaneously (1 × 20min = 20min)

**Result: 80 minutes saved = 5x faster!**

---

## The Two Critical Settings

### 1. Git Worktrees (Isolation)

**What it does:** Creates separate working directories for each parallel worker.

**Why you need it:** Without worktrees, parallel workers would fight over the same files, causing:
- Git conflicts
- File corruption
- Race conditions
- Slower execution (workers blocking each other)

**Configuration:**
```yaml
# config.yml
parallel:
  workspace_mode: worktree  # ALWAYS use this!
```

**Alternatives (NOT RECOMMENDED):**
- `clone` - Full repo copies (slower, uses more disk space)
- `branch` - Shadow copies without git isolation (UNSAFE for parallel work)

### 2. Concurrency (How Many Workers)

**What it does:** Controls how many AI workers run simultaneously.

**Default:** 5 workers (good for most features)

**Configuration:**
```yaml
# config.yml
parallel:
  max_concurrent_tasks: 5  # Range: 2-10
```

**When to adjust:**

| Scenario | Recommended Setting | Why |
|----------|-------------------|-----|
| Typical feature (4-6 tasks) | 5 workers | Balanced performance |
| Large feature (8+ tasks) | 8-10 workers | Maximize parallelization |
| Tightly coupled tasks | 2-3 workers | Reduce coordination overhead |
| Limited API quota | 2-3 workers | Conserve resources |

---

## How the Orchestrator Should Behave

### ✅ CORRECT BEHAVIOR (What should always happen)

When you run `@droidz-orchestrator`, it should:

1. **Always default to worktree mode**
   ```
   ✅ Using git worktrees - this allows 5 workers to build simultaneously in isolated environments
   ```

2. **Check and optimize concurrency**
   ```
   ✅ Planning to run 8 tasks with 5 parallel workers
   💡 TIP: You have 8 independent tasks. Consider increasing concurrency to 8 for faster completion.
   ```

3. **Show parallelization strategy**
   ```
   ✅ Execution Plan:
      Phase 1: Foundation (sequential) - 1 task
      Phase 2: Core Features (parallel) - 6 tasks with 5 workers
      Phase 3: Integration (sequential) - 1 task
      
      Estimated: 25 minutes (vs 90 minutes sequential) = 3.6x faster!
   ```

4. **Enforce worktrees before execution**
   ```
   ✅ Config validated: workspace.mode='worktree' ✓
   ✅ Git worktree support verified ✓
   ✅ Ready for parallel execution with 5 workers
   ```

### ❌ INCORRECT BEHAVIOR (What was happening before the fix)

Problems users reported:

1. **Not using worktrees**
   ```
   ❌ Workspace mode: branch
   ❌ WARNING: Multiple workers may conflict!
   ```
   **Impact:** Workers conflict, execution fails or becomes sequential

2. **Not maximizing parallelization**
   ```
   ❌ Running 8 tasks with 2 workers
   ```
   **Impact:** Slow execution, not utilizing Droidz's main benefit

3. **No explanation of parallel execution**
   ```
   ❌ Executing tasks...
   ```
   **Impact:** User doesn't understand what's happening or why it's fast

---

## Troubleshooting

### Problem: "Orchestrator isn't using worktrees"

**Check:**
```bash
cat orchestrator/config.json | grep -A 3 workspace
```

**Should show:**
```json
"workspace": {
  "mode": "worktree",
  "baseDir": ".runs",
  "branchPattern": "{type}/{issueKey}-{slug}"
}
```

**Fix:**
```bash
# Re-run setup and select 'worktree' when prompted
bun orchestrator/setup.ts
```

### Problem: "Tasks are running sequentially, not in parallel"

**Check concurrency:**
```bash
cat orchestrator/config.json | grep concurrency
```

**Should show:**
```json
"concurrency": 5  // or higher
```

**Fix:**
```bash
# Edit config directly
vim orchestrator/config.json
# Change "concurrency": 1 → "concurrency": 5
```

### Problem: "Git worktree command failed"

**Possible causes:**
1. **Old Git version** - Update to Git 2.5+
   ```bash
   git --version  # Should be 2.5 or higher
   ```

2. **Existing worktrees** - Clean up orphaned worktrees
   ```bash
   git worktree prune
   ```

3. **Detached HEAD** - Ensure you're on a branch
   ```bash
   git checkout main  # or your default branch
   ```

**Fallback:** Use `clone` mode (slower but works)
```yaml
parallel:
  workspace_mode: clone
```

### Problem: "Orchestrator doesn't mention parallel execution"

**This means:** You're using the OLD orchestrator droid prompt.

**Fix:** Update the orchestrator droid:
```bash
# The fix is already in .factory/droids/orchestrator.droid.json
# Reload droids in Droid CLI:
# 1. Open Droid CLI
# 2. Type /droids
# 3. Select "Reload Custom Droids"
```

---

## Verification Checklist

Before starting a project, verify these settings:

- [ ] **config.yml**: `workspace_mode: worktree`
- [ ] **config.yml**: `max_concurrent_tasks: 5` (or higher)
- [ ] **config.yml**: `enabled: true` for parallel execution
- [ ] **Git version**: 2.5 or higher (`git --version`)
- [ ] **Orchestrator droid**: Updated with parallel execution emphasis
- [ ] **Test run**: `bun orchestrator/run.ts --plan` shows parallel strategy

---

## How to Manually Verify Parallel Execution

### 1. Check the Execution Plan

```bash
bun orchestrator/run.ts --project "Your Project" --sprint "Sprint 1" --plan
```

**Look for:**
```json
{
  "project": "Your Project",
  "total": 8,
  "plan": [
    {"key": "ABC-1", "specialist": "codegen", "deps": []},
    {"key": "ABC-2", "specialist": "codegen", "deps": []},
    {"key": "ABC-3", "specialist": "codegen", "deps": []},
    ...
  ]
}
```

Tasks with no dependencies should run in parallel.

### 2. Watch the Execution

```bash
# Start execution
bun orchestrator/launch.ts
```

**You should see:**
- Multiple git worktrees being created
- Multiple droid workers launching simultaneously
- Progress updates from different workers at the same time

**Example output:**
```
✅ Created worktree: .runs/ABC-1
✅ Created worktree: .runs/ABC-2
✅ Created worktree: .runs/ABC-3
🤖 Worker 1 (ABC-1): Starting implementation...
🤖 Worker 2 (ABC-2): Starting implementation...
🤖 Worker 3 (ABC-3): Starting implementation...
```

### 3. Monitor Worktrees

```bash
# In another terminal, watch worktrees being created
watch -n 1 'git worktree list'
```

**You should see:**
```
/path/to/project          abc123 [main]
/path/to/project/.runs/ABC-1  def456 [feature/ABC-1-login]
/path/to/project/.runs/ABC-2  ghi789 [feature/ABC-2-auth]
/path/to/project/.runs/ABC-3  jkl012 [feature/ABC-3-profile]
```

Multiple worktrees = parallel execution is working!

---

## Performance Examples

### Small Feature (3 Tasks)

**Without Droidz:**
- Task 1: 15min
- Task 2: 15min  
- Task 3: 15min
- **Total: 45 minutes**

**With Droidz (3 parallel workers):**
- All tasks: 15min simultaneously
- **Total: 15 minutes**
- **Speedup: 3x faster**

### Medium Feature (6 Tasks)

**Without Droidz:**
- 6 tasks × 20min each = **120 minutes**

**With Droidz (5 parallel workers):**
- Batch 1: 5 tasks simultaneously (20min)
- Batch 2: 1 task (20min)
- **Total: 40 minutes**
- **Speedup: 3x faster**

### Large Feature (10 Tasks)

**Without Droidz:**
- 10 tasks × 25min each = **250 minutes (4+ hours)**

**With Droidz (10 parallel workers):**
- All tasks simultaneously (25min)
- **Total: 25 minutes**
- **Speedup: 10x faster**

---

## The Fix (What Changed)

### Before (Old Orchestrator Prompt)
```
4) Workspace mode: Confirm with the user (worktree|clone|branch). 
   If not set, suggest 'worktree'.
```
- ❌ Passive language ("suggest")
- ❌ Gives equal weight to all options
- ❌ No emphasis on parallel execution

### After (New Orchestrator Prompt)
```
4) WORKSPACE MODE (CRITICAL - THIS ENABLES PARALLEL EXECUTION):
   - DEFAULT: Always use 'worktree' mode unless user explicitly requests otherwise
   - ENFORCE: Set workspace.mode='worktree' in config before execution
   - EXPLAIN: Tell user "Using git worktrees - this allows [N] workers to build simultaneously"
```
- ✅ Strong emphasis (CRITICAL, ENFORCE)
- ✅ Clear default behavior
- ✅ Educational (explains WHY it matters)

### Additional Improvements
```
5) CONCURRENCY SETTINGS (MAXIMIZE PARALLELIZATION):
   - CHECK: Read config and identify concurrency value
   - OPTIMIZE: Suggest increasing concurrency for many independent tasks
   - INFORM: "Planning to run [N] tasks with [M] parallel workers"
   - EXPLAIN: "5 workers means ~5x faster than sequential"
```

---

## Summary

**The Problem:**
- Orchestrator wasn't consistently enforcing worktrees
- Orchestrator wasn't maximizing parallelization
- Users didn't understand the core value proposition

**The Solution:**
1. ✅ Updated orchestrator droid prompt to ENFORCE worktrees by default
2. ✅ Added concurrency optimization guidance
3. ✅ Made parallel execution the PRIMARY focus
4. ✅ Added validation warnings in setup.ts
5. ✅ Enhanced config.yml with clear documentation

**The Result:**
- Orchestrator ALWAYS uses worktrees unless explicitly told otherwise
- Orchestrator ALWAYS analyzes for maximum parallelization
- Users understand WHY Droidz is faster

---

## Questions?

If you're still experiencing issues:

1. **Verify your orchestrator droid is updated:**
   ```bash
   cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
   ```
   Should contain: `"Droidz's PRIMARY VALUE is PARALLEL EXECUTION"`

2. **Check your config:**
   ```bash
   cat config.yml | grep -A 8 "parallel:"
   ```
   Should show `workspace_mode: worktree` and `enabled: true`

3. **Test with a plan:**
   ```bash
   bun orchestrator/run.ts --plan
   ```
   Should show parallel execution strategy

4. **Report issues:**
   https://github.com/korallis/Droidz/issues

---

**Remember: Parallel execution with worktrees is what makes Droidz special. Don't disable it!** 🚀
