# Migration Guide: v2.x → v3.0

> **Upgrade to Droidz v3.0 with Factory.ai-native architecture**

This guide helps you migrate from Droidz v2.x to v3.0 with minimal disruption.

---

## What's Changed in v3.0?

### Major Changes

1. **✅ Native Factory.ai Skills** - Skills now use official Factory.ai format (v0.26.0)
2. **✅ Model Inheritance** - All droids use `model: inherit` (respects your model choice)
3. **✅ 100% `.factory/` Structure** - Eliminated `.droidz/` folder confusion
4. **✅ Validation System** - New `/validate-init` and `/validate` commands
5. **✅ Enhanced Hooks** - All 7 Factory.ai hook types supported
6. **✅ Simplified Installation** - < 30 second setup (no tmux, no git worktrees)

### Breaking Changes

| Change | v2.x | v3.0 | Impact |
|--------|------|------|--------|
| **Folder structure** | `.droidz/` + `.factory/` | 100% `.factory/` | Low (auto-migrated) |
| **Commands** | `/droidz-init`, `/droidz-build` | `/init`, `/build` | Low (aliases exist) |
| **Skills format** | "Auto-activates when" | "Use when" | None (auto-updated) |
| **Droid models** | Mixed (some explicit) | All `model: inherit` | None (improved) |
| **Hooks** | 4 hook types | 7 hook types | Low (opt-in) |

---

## Migration Methods

### Option 1: Automatic Migration (Recommended)

Run the migration script:

```bash
./.factory/scripts/migrate-v3.sh
```

**What it does:**
1. ✅ Moves `.droidz/specs/` → `.factory/specs/archived/`
2. ✅ Removes `.droidz/` folder
3. ✅ Updates skills format ("Auto-activates" → "Use when")
4. ✅ Verifies all droids use `model: inherit`
5. ✅ Runs `/validate-init` to generate validation workflow
6. ✅ Updates `.gitignore` with v3.0 patterns
7. ✅ Creates backup of old configuration

**Time**: ~2 minutes

### Option 2: Manual Migration

Follow these steps if automatic migration fails:

#### Step 1: Backup Current Setup

```bash
# Create backup
cp -r .factory .factory-v2-backup
cp -r .droidz .droidz-backup 2>/dev/null || true

# Commit current state
git add -A
git commit -m "backup: save v2.x state before migration"
```

#### Step 2: Update Droidz

```bash
# Pull latest v3.0
git pull origin main

# Or download fresh
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.4.2/install.sh | bash
```

#### Step 3: Migrate Specs

```bash
# Move specs to archived
mkdir -p .factory/specs/archived
mv .droidz/specs/* .factory/specs/archived/ 2>/dev/null || true

# Remove old .droidz folder
rm -rf .droidz/
```

#### Step 4: Update Skills

Skills are already updated to v3.0 format in the new version. No action needed.

#### Step 5: Verify Droids

All droids should now have `model: inherit`:

```bash
grep -r "model: inherit" .factory/droids/
```

Should show 14 matches (one per droid).

#### Step 6: Generate Validation

```bash
droid
/validate-init
```

#### Step 7: Update .gitignore

Add to `.gitignore`:

```gitignore
# Droidz v3.0
.factory/specs/active/
.factory/validation/.validation-cache/
.factory/commands/validate.md
```

#### Step 8: Test

```bash
# Test commands
droid
/init
/droids  # Should show 14 droids
/skills  # Should show 61 skills
```

---

## Detailed Changes

### 1. Skills Format Change

**Before (v2.x):**
```yaml
---
name: typescript
description: Auto-activates when user mentions TypeScript...
category: language
---
```

**After (v3.0):**
```yaml
---
name: typescript
description: Use when user mentions TypeScript, types, interfaces...
category: language
allowed-tools: ["Read", "Edit", "Create", "Grep", "Glob"]
---
```

**Impact**: Skills still auto-activate the same way. Just updated wording to match Factory.ai docs.

**Action**: Already handled by update script.

---

### 2. Model Inheritance

**Before (v2.x):**
```yaml
# Some droids had explicit models
---
name: droidz-codegen
model: claude-sonnet-4  # ❌ Ignores user's choice
---
```

**After (v3.0):**
```yaml
# All droids inherit
---
name: droidz-codegen
model: inherit  # ✅ Respects user's choice
---
```

**Impact**: Your model choice now applies to ALL droids consistently.

**Action**: Already handled in v3.0 droids.

---

### 3. Folder Structure

**Before (v2.x):**
```
.droidz/
├── specs/           # Specs here
└── config/          # Some config here

.factory/
├── droids/          # Droids here
├── skills/          # Skills here
└── commands/        # Commands here
```

**After (v3.0):**
```
.factory/            # Everything here!
├── commands/
├── droids/
├── skills/
├── specs/
├── hooks/
├── validation/      # New!
└── memory/
```

**Impact**: Cleaner structure, no confusion about where files go.

**Action**: Migration script moves everything to `.factory/`.

---

### 4. Commands Renamed

**Before (v2.x):**
- `/droidz-init`
- `/droidz-build`
- `/auto-parallel`

**After (v3.0):**
- `/init` (primary)
- `/build` (primary)
- `/parallel` (primary)

**Aliases**: Old names still work for compatibility:
- `/droidz-init` → `/init`
- `/droidz-build` → `/build`
- `/auto-parallel` → `/parallel`

**Impact**: None if using old names. Recommended to update to new names.

**Action**: Update your workflows to use shorter names (optional).

---

### 5. New Validation System

**Before (v2.x):**
No built-in validation workflow.

**After (v3.0):**
```bash
# Generate validation
/validate-init

# Run validation
/validate
```

**Impact**: You can now validate all aspects of your project with one command.

**Action**: Run `/validate-init` after migration.

---

### 6. Enhanced Hooks System

**Before (v2.x):**
4 hook types partially supported:
- SessionStart
- PostToolUse
- PreToolUse
- Stop

**After (v3.0):**
All 7 Factory.ai hook types:
- SessionStart ✓
- SessionEnd ✓ (new)
- PreToolUse ✓
- PostToolUse ✓
- UserPromptSubmit ✓ (new)
- Stop ✓
- SubagentStop ✓ (new)

**Impact**: More granular control over automation.

**Action**: Opt-in by editing `.factory/hooks/settings.json` (already configured in v3.0).

---

## Post-Migration Checklist

After migrating, verify these:

### ✅ Functionality Check

```bash
# 1. Start Droid CLI
droid

# 2. Check droids are present
/droids
# Should show: 14 droids

# 3. Check skills are present
/skills
# Should show: 61 skills

# 4. Test init command
/init
# Should analyze project

# 5. Test validation generation
/validate-init
# Should generate validate.md

# 6. Test validation
/validate
# Should run 5 phases (or say tools not found)

# 7. Test spec generation
/build "add a feature"
# Should ask clarifying questions
```

### ✅ File Structure Check

```bash
# Verify folder structure
ls -la .factory/
# Should show: commands, droids, skills, specs, hooks, validation, memory

# Verify no old folder
ls -la .droidz/
# Should not exist

# Verify gitignore
cat .gitignore | grep "\.factory"
# Should show proper gitignore patterns
```

### ✅ Git Check

```bash
# Check git status
git status

# Should see:
# - Modified: .factory/ files
# - Deleted: .droidz/ (if existed)
# - Modified: .gitignore

# Commit migration
git add -A
git commit -m "feat: migrate to Droidz v3.0"
```

---

## Rollback Plan

If migration causes issues, rollback:

### Rollback Steps

```bash
# 1. Restore backup
rm -rf .factory
mv .factory-v2-backup .factory

# If .droidz existed
mv .droidz-backup .droidz

# 2. Restore gitignore
git checkout .gitignore

# 3. Verify
droid
/droids  # Should show v2.x droids

# 4. Re-attempt migration after fixing issues
```

---

## Troubleshooting Migration

### Issue: Migration Script Not Found

**Problem**: `.factory/scripts/migrate-v3.sh` doesn't exist

**Solution**:
```bash
# Download migration script
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/.factory/scripts/migrate-v3.sh -o migrate-v3.sh
chmod +x migrate-v3.sh
./migrate-v3.sh
```

### Issue: Skills Not Showing

**Problem**: `/skills` shows 0 skills

**Solution**:
```bash
# Check skills directory
ls .factory/skills/

# If empty, re-clone skills
git pull origin main
# Or re-run installer
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.4.2/install.sh | bash
```

### Issue: Droids Using Wrong Model

**Problem**: Droids still use explicit models instead of inheriting

**Solution**:
```bash
# Check droid models
grep "^model:" .factory/droids/*.md

# If any don't show "model: inherit", update them
# Open each file and change:
# model: claude-sonnet-4
# to:
# model: inherit
```

### Issue: Validation Fails

**Problem**: `/validate` fails immediately

**Solution**:
```bash
# Re-generate validation
/validate-init

# Check generated file
cat .factory/commands/validate.md

# If tools not installed, install them:
npm install  # or yarn, pnpm, bun

# Try again
/validate
```

---

## FAQ

### Q: Do I need to update immediately?

**A**: No, but recommended. v2.x still works, but v3.0 offers:
- Better Factory.ai integration
- Validation system
- Improved model consistency
- Cleaner architecture

### Q: Will my existing specs work?

**A**: Yes. Migration moves them to `.factory/specs/archived/` where they're still accessible.

### Q: Do I need to re-train my team?

**A**: Minimal. Commands are mostly the same (just shorter). New features (validation) are opt-in.

### Q: What if I customized droids/skills?

**A**: Custom droids/skills are preserved. Just verify they use `model: inherit`.

### Q: Can I use v2.x and v3.0 in different projects?

**A**: Yes. Each project has its own `.factory/` folder. No conflicts.

### Q: Will v2.x be supported?

**A**: Security fixes only. New features will be v3.0+.

---

## Benefits After Migration

### ✅ Immediate Benefits

1. **Model Consistency** - All droids respect your model choice
2. **Cleaner Structure** - 100% `.factory/`, no confusion
3. **Official Skills Format** - Matches Factory.ai docs exactly
4. **Validation System** - One command to validate everything

### ✅ Long-Term Benefits

1. **Future-Proof** - Aligned with Factory.ai's roadmap
2. **Better Team Collaboration** - Standard structure
3. **Easier Onboarding** - Simpler architecture
4. **Active Development** - All new features in v3.0+

---

## Getting Help

### Documentation

- [README.md](./README.md) - Overview and quick start
- [VALIDATION.md](./VALIDATION.md) - Validation system guide
- [SKILLS.md](./SKILLS.md) - Skills system guide
- [DROIDS.md](./DROIDS.md) - Custom droids guide
- [COMMANDS.md](./COMMANDS.md) - All commands reference

### Community

- **Discord**: [Join Ray Fernando's Discord](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
- **GitHub Issues**: [Report bugs](https://github.com/korallis/Droidz/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/korallis/Droidz/discussions)

### Support Development

If Droidz v3.0 saves you time:
- **[Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

---

## Migration Timeline Recommendation

### Immediate (Week 1)
- [ ] Backup current setup
- [ ] Run migration script
- [ ] Test all functionality
- [ ] Commit migrated state

### Short-Term (Week 2-3)
- [ ] Update team documentation
- [ ] Train team on new commands
- [ ] Set up validation workflow
- [ ] Update CI/CD to use `/validate`

### Long-Term (Month 1-2)
- [ ] Create custom skills for your stack
- [ ] Optimize validation workflow
- [ ] Explore new v3.0 features
- [ ] Share learnings with team

---

**Migrate to v3.0 and unlock Factory.ai's full potential** ✨
