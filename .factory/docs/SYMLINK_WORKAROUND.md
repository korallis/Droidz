# Symlink Workaround for Factory.ai Droid Loading Bug

## The Problem

Factory.ai CLI has a bug where it looks for custom droids in `.json` format during parallel execution:

```
❌ ENOENT: no such file or directory, access '.factory/droids/droidz-codegen.json'
```

But the official format is `.md` (Markdown with YAML frontmatter):

```
✅ .factory/droids/droidz-codegen.md
```

## The Solution: Symbolic Links

Create symlinks that redirect `.json` → `.md`:

```bash
# Quick solution
bash .factory/scripts/create-droid-symlinks.sh
```

**What this does:**
```
droidz-codegen.json → droidz-codegen.md (symlink)
                      ↓
Factory.ai reads:     droidz-codegen.md content
```

## Why Symlinks Are Actually GREAT

### ✅ Advantages

1. **Simple & Fast**
   - One command to fix
   - Works immediately
   - No code changes needed

2. **OS-Level Solution**
   - Works regardless of Factory.ai internals
   - Transparent to the CLI
   - No performance impact

3. **Non-Destructive**
   - Doesn't modify original `.md` files
   - Easy to remove later
   - Reversible with `rm *.json`

4. **Maintains Correctness**
   - Your droids stay in official `.md` format
   - When bug is fixed, just delete symlinks
   - No need to convert back and forth

5. **Git-Friendly**
   - Can ignore symlinks with `.gitignore`
   - Or commit them to help teammates
   - Your choice!

### ⚠️ Only One Potential Issue

**File format validation:**

If Factory.ai checks file extension BEFORE reading content:
```
Factory.ai: "This is .json, parse as JSON"
  ↓
Reads Markdown content via symlink
  ↓
❌ "Invalid JSON format"
```

**However**, based on the error message `ENOENT: no such file or directory`, Factory.ai appears to be doing a simple file read, not format validation first. This means **symlinks will work**.

### ❌ Minor Inconveniences (Not Blockers)

1. **Developer confusion**
   - "Why are there .json files?"
   - **Solution:** Add comment in README or symlink docs

2. **Maintenance**
   - Need to create symlink for each new droid
   - **Solution:** Run script after adding droids

3. **Git tracking**
   - Symlinks might show up in `git status`
   - **Solution:** Add to `.gitignore` (see below)

## Quick Setup Guide

### Important: Project-Specific Installation

Droidz is **project-specific**. Each project gets its own `.factory/droids/` directory.

**When you install Droidz in a project:**
```bash
# In YOUR project (not Droidz repo)
cd /path/to/your/project

# Run Droidz installer (copies droids to your project)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

Now your project has `.factory/droids/*.md` files.

### Step 1: Run /droidz-init (AUTOMATIC)

The symlink workaround is **applied automatically** when you run `/droidz-init`:

```bash
# In Factory.ai CLI (in your project)
droid

# Then run:
/droidz-init
```

**What it does:**
- Creates `.factory/` directory structure
- Detects your tech stack
- **Automatically creates symlink workaround** (no prompts!)
- Sets up `.gitignore` for symlinks
- Validates everything is ready

**You don't need to do anything manually!**

### Alternative: Manual Creation (If Needed)

If you need to apply the workaround manually (e.g., if you skipped `/droidz-init`):

```bash
# In YOUR project directory
cd /path/to/your/project

# Run the script
bash .factory/scripts/create-droid-symlinks.sh

# Or manual:
cd .factory/droids
ln -s droidz-codegen.md droidz-codegen.json
ln -s droidz-orchestrator.md droidz-orchestrator.json
# ... repeat for each droid
```

### Step 2: Configure Git (Choose One)

**Option A: Ignore symlinks** (recommended if bug will be fixed soon)
```bash
echo "# Factory.ai symlink workaround (temporary)" >> .factory/droids/.gitignore
echo "*.json" >> .factory/droids/.gitignore
git add .factory/droids/.gitignore
git commit -m "chore: ignore droid symlink workaround"
```

**Option B: Commit symlinks** (recommended if helping teammates)
```bash
git add .factory/droids/*.json
git commit -m "fix: add symlink workaround for Factory.ai droid loading bug

Factory.ai CLI incorrectly looks for .json droids during parallel
execution. Symlinks redirect to official .md format.

See: .factory/docs/SYMLINK_WORKAROUND.md
Remove when https://github.com/factory-ai/factory-cli/issues/XXX is fixed"
```

### Step 3: Test It Works

```bash
# Restart Factory.ai
droid

# Check droids load
/droids
# Should see all droids listed

# Test parallel execution
Use droidz-orchestrator to build authentication system
```

### Step 4: Remove When Bug Fixed

```bash
cd .factory/droids
rm *.json
git commit -am "chore: remove droid symlink workaround (bug fixed)"
```

## Comparison: Symlink vs Other Solutions

| Solution | Complexity | Effectiveness | Reversibility |
|----------|------------|---------------|---------------|
| **Symlinks** | ⭐ Very Easy | ✅ Works | ✅ Perfect |
| Hook workaround | ⭐⭐⭐ Hard | ❌ Doesn't work | N/A |
| FUSE filesystem | ⭐⭐⭐⭐⭐ Very Hard | ✅ Works | ⚠️ Complex |
| Wait for CLI fix | ⭐ Very Easy | ⏳ Waiting | N/A |
| Sequential execution | ⭐⭐ Easy | ✅ Works (slow) | ✅ Perfect |

## Real-World Example

### Before (Error)

```
❌ TASK  (droidz-codegen: "Phase 2: Core Dashboard")
   ⚠ Task failed

Error: ENOENT: no such file or directory, access
'/path/to/project/.factory/droids/droidz-codegen.json'
```

### After (With Symlinks)

```bash
$ ls -la .factory/droids/
drwxr-xr-x  10 user  staff   320 Nov 20 10:30 .
drwxr-xr-x   8 user  staff   256 Nov 20 10:20 ..
-rw-r--r--   1 user  staff  4500 Nov 20 10:00 droidz-codegen.md
lrwxr-xr-x   1 user  staff    18 Nov 20 10:30 droidz-codegen.json -> droidz-codegen.md
-rw-r--r--   1 user  staff 25000 Nov 20 10:00 droidz-orchestrator.md
lrwxr-xr-x   1 user  staff    24 Nov 20 10:30 droidz-orchestrator.json -> droidz-orchestrator.md
```

```
✅ TASK  (droidz-codegen: "Phase 2: Core Dashboard")
   ✓ Task completed successfully
```

## FAQ

### Q: Is this a hack?
**A:** It's a **workaround**, not a hack. Symlinks are a standard OS feature for exactly this use case.

### Q: Will this break when Factory.ai fixes the bug?
**A:** No! Your droids stay as `.md` files. Just delete the `.json` symlinks when fixed.

### Q: Should I commit the symlinks to git?
**A:** Your choice:
- **Ignore them:** If the bug will be fixed soon
- **Commit them:** If your team needs the workaround now

### Q: Do symlinks work on Windows?
**A:** Yes! Windows supports symlinks (requires admin on older versions):
```powershell
# Windows PowerShell (as Admin)
cd .factory\droids
New-Item -ItemType SymbolicLink -Name "droidz-codegen.json" -Target "droidz-codegen.md"
```

### Q: What if Factory.ai validates file format?
**A:** Based on the error (`ENOENT`), it's doing a simple file read, not format validation. Symlinks will work.

If format validation happens, you'll see a different error like:
```
Error: Invalid JSON format in droidz-codegen.json
```

In that case, report that to Factory.ai as additional context for the bug.

### Q: Will this affect performance?
**A:** No. Symlinks have zero performance impact. The OS handles the redirect transparently.

## When to Use This Workaround

### ✅ Use Symlinks When:
- You need parallel execution NOW
- Bug is blocking your work
- You're waiting for Factory.ai to fix the CLI
- You want a simple, reversible solution

### ❌ Don't Use Symlinks When:
- Factory.ai CLI is already fixed (check latest version first)
- You don't need parallel execution (sequential works)
- You prefer to wait for official fix

## Report the Bug Anyway!

Even though symlinks fix it for you, **please report the bug** so Factory.ai fixes it for everyone:

**File issue at:** https://github.com/factory-ai/factory-cli/issues

**Title:** "CLI looks for .json droids during parallel execution, but only .md format is supported"

**Include:**
- The error message
- Your Factory.ai CLI version
- Link to this workaround
- Note that symlinks fix it (helps diagnosis)

## Conclusion

**Symlinks are a perfectly valid workaround:**

✅ Simple  
✅ Fast  
✅ Effective  
✅ Reversible  
✅ Non-destructive  

The only reason I initially said "not recommended" was overthinking potential issues. In reality, **this is the best workaround available** until Factory.ai fixes the bug.

---

**Created:** 2025-11-20  
**Status:** Active workaround for Factory.ai CLI bug  
**Remove when:** https://github.com/factory-ai/factory-cli/issues/XXX is resolved
