# Updating Droidz in Your Project

## Safe Update Process

### Step 1: Backup Your Current Setup

Before updating, save your current configuration:

```bash
# From your project root
cp .factory/droids/orchestrator.droid.json .factory/droids/orchestrator.droid.json.backup
cp config.yml config.yml.backup
cp orchestrator/config.json orchestrator/config.json.backup 2>/dev/null || true
```

### Step 2: Pull Latest Droidz Files

**Option A: If you cloned Droidz directly into your project**

```bash
cd /path/to/your/Droidz/clone
git pull origin main
```

**Option B: If you installed via script (recommended)**

```bash
# Download and run the install script again
# It will UPDATE existing files safely
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

**Option C: Manual update (if you want control)**

```bash
# From your project root
# Update the orchestrator droid (CRITICAL for parallel execution fix)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/orchestrator.droid.json -o .factory/droids/orchestrator.droid.json

# Update config.yml (only if you haven't customized it)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/config.yml -o config.yml

# Download new troubleshooting guide
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/PARALLEL_EXECUTION_GUIDE.md -o PARALLEL_EXECUTION_GUIDE.md

# Optional: Update README
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/README.md -o README.md
```

### Step 3: Merge Your Custom Settings

If you had custom settings in `config.yml`, merge them back:

```bash
# Compare your backup with the new version
diff config.yml.backup config.yml

# Edit config.yml to restore your custom values while keeping new documentation
vim config.yml  # or your preferred editor
```

**Key settings to preserve:**
- Your custom `max_concurrent_tasks` value
- Any custom workspace settings
- Your standards enforcement preferences

**New settings to adopt:**
- Enhanced comments explaining parallel execution
- Recommended `workspace_mode: worktree` (if you had something else, consider switching)

### Step 4: Reload Droids in Droid CLI

**This is the MOST IMPORTANT step!**

The orchestrator droid runs inside Droid CLI, so you need to reload it:

```bash
# 1. Open Droid CLI
droid

# 2. In Droid CLI, type:
/droids

# 3. Select "Reload Custom Droids" or "Import from Directory"

# 4. Verify the update worked
```

**Verification:**
```bash
# Check that the orchestrator has the new prompt
cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
```

You should see: `"Droidz's PRIMARY VALUE is PARALLEL EXECUTION"`

If you don't see this, the droid wasn't reloaded properly.

### Step 5: Verify Your Configuration

Run these checks to ensure everything is configured optimally:

```bash
# 1. Check parallel execution is enabled
cat config.yml | grep -A 10 "parallel:"
```

**Should show:**
```yaml
parallel:
  enabled: true  # ✅
  max_concurrent_tasks: 5  # ✅ (or your preferred value 2-10)
  workspace_mode: worktree  # ✅ IMPORTANT!
```

```bash
# 2. Check orchestrator config (if using orchestrator scripts)
cat orchestrator/config.json | grep -A 3 "workspace"
```

**Should show:**
```json
"workspace": {
  "mode": "worktree",  // ✅
  "baseDir": ".runs",
  "branchPattern": "{type}/{issueKey}-{slug}"
}
```

```bash
# 3. Check Git version supports worktrees
git --version  # Should be 2.5 or higher
```

### Step 6: Test the Update

Test that parallel execution works:

```bash
# In Droid CLI, ask the orchestrator:
@droidz-orchestrator

# Then type something like:
I have an existing project. Can you analyze it and show me your parallel execution strategy?
```

**What you should see:**
```
✅ Using git worktrees - this allows 5 workers to build simultaneously in isolated environments
✅ Analyzing your project...
✅ Config validated: workspace.mode='worktree' ✓
✅ Ready for parallel execution with 5 workers
```

---

## What If You Customized Files?

### If You Customized `config.yml`

**Safe approach:**
1. Keep your backup: `config.yml.backup`
2. Download the new version to a different name:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/config.yml -o config.yml.new
   ```
3. Compare them:
   ```bash
   diff config.yml.backup config.yml.new
   ```
4. Manually merge:
   - Keep your custom values (concurrency, workspace settings, etc.)
   - Add the new documentation comments
   - Ensure `workspace_mode: worktree` unless you have a good reason not to

### If You Customized `.factory/droids/orchestrator.droid.json`

**⚠️ Warning:** This file contains the core fix for parallel execution. Customizations will be overwritten.

**Recommended approach:**
1. Save your customizations separately
2. Update to the new orchestrator droid
3. If you need custom behavior, create a NEW custom droid instead:
   ```bash
   cp .factory/droids/orchestrator.droid.json .factory/droids/my-custom-orchestrator.droid.json
   # Then edit my-custom-orchestrator.droid.json with your customizations
   ```

### If You Customized `orchestrator/setup.ts`

This file now includes validation warnings. If you customized it:

1. Download the new version:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/setup.ts -o orchestrator/setup.ts.new
   ```
2. Compare with your version:
   ```bash
   diff orchestrator/setup.ts orchestrator/setup.ts.new
   ```
3. Merge the new validation logic while keeping your customizations

---

## Troubleshooting After Update

### "I updated but still not seeing parallel execution messages"

**Cause:** Droid CLI hasn't reloaded the updated droid.

**Fix:**
```bash
# Force reload
droid

# In Droid CLI:
/droids
# Select "Reload Custom Droids"

# Verify:
cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
```

### "Git worktrees are failing after update"

**Cause:** Old worktrees may be orphaned.

**Fix:**
```bash
# Clean up old worktrees
git worktree prune

# Remove old .runs directory if needed
rm -rf .runs

# Check git version
git --version  # Must be 2.5+
```

### "My custom settings were overwritten"

**Cause:** The update script replaced customized files.

**Fix:**
```bash
# Restore from backup
cp config.yml.backup config.yml

# Then manually add the new features:
# 1. Enhanced parallel execution comments
# 2. Validation in setup.ts
# 3. Keep workspace_mode: worktree
```

### "Orchestrator is asking about workspace mode"

**This is normal!** The new orchestrator validates your settings.

**What to do:**
- If it suggests `worktree`, accept it (fastest mode)
- If worktrees fail, it will offer `clone` as fallback
- Only use `branch` mode if you have a specific reason

---

## What's New After Update

### 1. **Orchestrator Behavior Changes**

**Before:**
```
Workspace mode: Confirm with the user (worktree|clone|branch). 
If not set, suggest 'worktree'.
```

**After:**
```
✅ Using git worktrees - this allows 5 workers to build simultaneously
✅ Planning to run 8 tasks with 5 parallel workers
💡 TIP: You have 8 independent tasks. Consider increasing concurrency to 8.

Execution Plan:
  Phase 1: Foundation (sequential) - 1 task
  Phase 2: Core Features (parallel) - 6 tasks with 5 workers  
  Phase 3: Integration (sequential) - 1 task
```

### 2. **Setup Wizard Validation**

When you run `bun orchestrator/setup.ts`, you'll now see:

```
⚠️  WARNING: You selected workspace mode 'branch'
   Droidz's core feature is PARALLEL EXECUTION using git worktrees.
   Without worktrees, parallel workers may conflict or run slower.
   RECOMMENDED: Use 'worktree' mode for best performance (3-5x faster).
   
   Continue with 'branch' mode anyway? (y/N):
```

### 3. **New Documentation**

- `PARALLEL_EXECUTION_GUIDE.md` - Comprehensive troubleshooting
- Enhanced `README.md` with recent improvements section
- Better comments in `config.yml`

---

## Minimal Update (Just the Critical Fix)

If you just want the parallel execution fix without touching anything else:

```bash
# Update ONLY the orchestrator droid
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/orchestrator.droid.json -o .factory/droids/orchestrator.droid.json

# Reload in Droid CLI
droid
/droids
# Select "Reload Custom Droids"
```

**That's it!** You'll now get:
- ✅ Automatic worktree enforcement
- ✅ Concurrency optimization
- ✅ Clear execution plans

---

## Full Update (Recommended)

For the complete experience:

```bash
# 1. Backup
cp .factory/droids/orchestrator.droid.json .factory/droids/orchestrator.droid.json.backup
cp config.yml config.yml.backup

# 2. Update all files
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/orchestrator.droid.json -o .factory/droids/orchestrator.droid.json
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/config.yml -o config.yml
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/setup.ts -o orchestrator/setup.ts
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/PARALLEL_EXECUTION_GUIDE.md -o PARALLEL_EXECUTION_GUIDE.md
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/README.md -o README.md

# 3. Restore custom settings if needed
# (Compare config.yml.backup with config.yml and merge)

# 4. Reload droids
droid
# /droids → Reload Custom Droids

# 5. Verify
cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
```

---

## Questions?

### Q: Will this break my existing setup?
**A:** No. The update is backward compatible. Your existing configs will work, but you'll get better defaults.

### Q: Do I need to reinstall from scratch?
**A:** No. Just update the files and reload the droids.

### Q: What if I don't want to use worktrees?
**A:** You can still use `clone` or `branch` mode, but you'll get a warning explaining why worktrees are recommended. The orchestrator won't force you, but it will encourage the best practice.

### Q: Will my Linear integrations still work?
**A:** Yes. All existing integrations remain unchanged.

### Q: How do I know the update worked?
**A:** Run `@droidz-orchestrator` and you should see messages about git worktrees and parallel execution strategy. If you don't see these, reload your droids.

---

## Need Help?

- 📖 [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md) - Troubleshooting
- 🐛 [GitHub Issues](https://github.com/korallis/Droidz/issues) - Report problems
- 💬 Community support channels

---

**Last updated:** 2025-01-10 (Parallel Execution Enforcement Update)
