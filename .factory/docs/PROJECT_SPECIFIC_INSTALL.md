# Project-Specific Droidz Installation

## Important: Droidz is Per-Project

**Droidz is NOT installed globally.** Each project gets its own copy of the droids.

```
❌ WRONG: ~/.factory/droids/  (personal/global)
✅ RIGHT: /your-project/.factory/droids/  (project-specific)
```

## How It Works

### 1. Install Droidz in YOUR Project

```bash
# Navigate to YOUR project (e.g., Leo Analytics)
cd /Users/you/Development/Leo-Analytics

# Run Droidz installer
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**What this does:**
- Creates `.factory/droids/` in YOUR project
- Copies all droid `.md` files to YOUR project
- Creates `.factory/hooks/`, `.factory/skills/`, etc. in YOUR project
- Configures YOUR project for Factory.ai

### 2. Result

```
/Users/you/Development/Leo-Analytics/
├── .factory/
│   ├── droids/
│   │   ├── droidz-codegen.md         ← Your project's copy
│   │   ├── droidz-orchestrator.md    ← Your project's copy
│   │   ├── droidz-test.md            ← Your project's copy
│   │   └── ...
│   ├── hooks/
│   ├── skills/
│   └── ...
├── src/
├── package.json
└── ...
```

### 3. Factory.ai Sees YOUR Project's Droids

```
Factory.ai CLI (in your project):
  ↓
Scans: /Users/you/Development/Leo-Analytics/.factory/droids/
  ↓
Loads: droidz-codegen.md, droidz-orchestrator.md, etc.
  ↓
Makes available via Task tool
```

## Why Project-Specific?

### ✅ Advantages

1. **Customization Per Project**
   - Each project can have different droids
   - Customize droid prompts for project needs
   - Add project-specific droids

2. **Team Sharing**
   - Commit `.factory/` to git
   - Whole team uses same droids
   - Consistent workflow across team

3. **Version Control**
   - Track droid changes in git history
   - Update droids per project
   - Roll back if needed

4. **Isolation**
   - Projects don't interfere
   - Safe to experiment
   - Clean separation

## Installing in Multiple Projects

If you have multiple projects, **install Droidz in each one:**

```bash
# Project 1
cd /Users/you/Development/Leo-Analytics
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# Project 2
cd /Users/you/Development/Another-Project
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# Project 3
cd /Users/you/Development/Third-Project
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

Each project gets its own `.factory/` directory with its own droids.

## Applying Symlink Workaround

**The symlink workaround is also project-specific:**

```bash
# In YOUR project (not Droidz repo)
cd /Users/you/Development/Leo-Analytics

# Apply workaround
bash .factory/scripts/create-droid-symlinks.sh
```

This creates symlinks **in your project's** `.factory/droids/` directory:

```
/Users/you/Development/Leo-Analytics/.factory/droids/
├── droidz-codegen.md                    ← Real file
├── droidz-codegen.json → droidz-codegen.md  ← Symlink
├── droidz-orchestrator.md               ← Real file
├── droidz-orchestrator.json → droidz-orchestrator.md  ← Symlink
└── ...
```

## Common Mistakes

### ❌ Mistake 1: Installing in Droidz Repo

```bash
# WRONG - This modifies the Droidz source repo
cd /Users/you/Development/Droidz
bash .factory/scripts/create-droid-symlinks.sh
```

**Fix:** Run in YOUR project directory instead.

### ❌ Mistake 2: Expecting Global Droids

```bash
# WRONG - Droids are not personal/global
~/.factory/droids/droidz-codegen.md
```

**Fix:** Droids live in YOUR project's `.factory/droids/`.

### ❌ Mistake 3: Using Droidz Repo Droids Directly

```bash
# WRONG - Factory.ai won't see these
/Users/you/Development/Droidz/.factory/droids/
```

**Fix:** Install Droidz in YOUR project to copy droids there.

## Checking Installation

### Verify Droids Are in YOUR Project

```bash
# In YOUR project
cd /Users/you/Development/Leo-Analytics

# Check droids exist
ls -la .factory/droids/

# Should show:
# droidz-codegen.md
# droidz-orchestrator.md
# droidz-test.md
# etc.
```

### Verify Factory.ai Sees Them

```bash
# In YOUR project
droid

# Then in Factory.ai CLI:
/droids

# Should list:
# - droidz-orchestrator
# - droidz-codegen
# - droidz-test
# - etc.
```

## Updating Droids

To update droids in YOUR project:

```bash
# Option 1: Re-run installer (updates everything)
cd /Users/you/Development/Leo-Analytics
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# Option 2: Manually copy from Droidz repo
cp /Users/you/Development/Droidz/.factory/droids/*.md \
   /Users/you/Development/Leo-Analytics/.factory/droids/

# Don't forget to recreate symlinks if you have the bug
bash .factory/scripts/create-droid-symlinks.sh
```

## Git Integration

### Commit Droids to Your Project Repo

```bash
# In YOUR project
git add .factory/
git commit -m "feat: add Droidz parallel execution framework"
git push
```

Now your teammates get the droids when they clone/pull!

### With Symlink Workaround

**Option A: Ignore symlinks** (recommended)
```bash
echo "*.json" >> .factory/droids/.gitignore
git add .factory/droids/.gitignore
git commit -m "chore: ignore symlink workaround"
```

**Option B: Commit symlinks** (helps teammates)
```bash
git add .factory/droids/*.json
git commit -m "fix: add symlink workaround for Factory.ai bug"
```

## Summary

| Aspect | Details |
|--------|---------|
| **Installation** | Per-project, not global |
| **Location** | `<your-project>/.factory/droids/` |
| **Command** | Run installer in YOUR project directory |
| **Symlinks** | Also created in YOUR project |
| **Git** | Commit `.factory/` to share with team |
| **Updates** | Re-run installer or copy files per project |

## Quick Reference

```bash
# In YOUR project (NOT Droidz repo)
cd /path/to/your/project

# 1. Install Droidz
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# 2. Apply symlink workaround (if prompted or if bug occurs)
bash .factory/scripts/create-droid-symlinks.sh

# 3. Verify
ls .factory/droids/  # Should show .md and .json files
droid                 # Start Factory.ai
/droids               # List droids - should see all 7

# 4. Test parallel execution
# Use droidz-orchestrator to build <your feature>
```

---

**Remember:** Every project gets its own Droidz installation. This is by design! 🎯
