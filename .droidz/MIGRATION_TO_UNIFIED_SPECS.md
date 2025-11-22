# Migration: Unified Specs Location

## What Changed?

In **Droidz v3.4.0**, specifications are now stored in a **unified location** that works for both:
- **Droid CLI** (standalone CLI tool)
- **Claude Code Edition** (Factory.ai integration)

### Old Structure (v3.0-v3.3)
```
.factory/specs/
├── active/     # Claude Code only
├── archive/    # Claude Code only
└── templates/
```

### New Structure (v3.4.0+)
```
.droidz/specs/
├── active/     # ✅ Shared between both editions
├── archive/    # ✅ Shared between both editions
├── templates/  # ✅ Shared between both editions
└── examples/   # ✅ NEW: Reference examples
    └── 000-realtime-notifications.md
```

---

## Why This Change?

1. **Dual Installation Support**: Users can have both CLI and Claude Code installed
2. **Consistency**: One source of truth for all specs
3. **Portability**: Switch between modes without losing work
4. **Team Collaboration**: Share specs across team members using different modes

---

## Migration Steps

### If You Have Existing Specs in `.factory/specs/active/`

Run this command to migrate:

```bash
# Move active specs to unified location
mv .factory/specs/active/*.md .droidz/specs/active/ 2>/dev/null

# Move archived specs
mv .factory/specs/archive/*.md .droidz/specs/archive/ 2>/dev/null

# Verify migration
ls -la .droidz/specs/active/
```

### If You're Starting Fresh

No action needed! The installer creates `.droidz/specs/` automatically.

---

## Backward Compatibility

### Legacy Support
- `.factory/specs/` still exists for backward compatibility
- Older commands referencing `.factory/specs/` will continue to work
- Gradually migrate to `.droidz/specs/` for consistency

### Updated Commands
All commands now default to `.droidz/specs/`:

**Claude Code:**
```
/build "feature name"
# → Saves to .droidz/specs/active/NNN-feature.md

/parallel .droidz/specs/active/NNN-feature.md
# → Executes from unified location
```

**Droid CLI:**
```bash
droidz build "feature name"
# → Saves to .droidz/specs/active/NNN-feature.md

droidz parallel .droidz/specs/active/NNN-feature.md
# → Executes from unified location
```

---

## Git Strategy

The `.gitignore` has been updated:

```gitignore
# Unified specs directory (shared between CLI and Claude Code)
.droidz/specs/active/*.md
.droidz/specs/active/*.json
.droidz/specs/archive/*.md
.droidz/specs/archive/*.json

# Legacy: Factory-specific specs (deprecated)
.factory/specs/active/*.md
.factory/specs/active/*.json
```

**By default, active and archived specs are NOT committed to git.**

To commit a specific spec (e.g., for team reference):
```bash
git add -f .droidz/specs/examples/001-my-example.md
git commit -m "docs: add example spec for authentication"
```

---

## What's Included

### Templates
- `feature-spec.md` - For new features
- `epic-spec.md` - For large initiatives

### Examples (NEW!)
- `000-realtime-notifications.md` - Complete reference implementation
  - Full architecture documentation
  - 9 parallelizable tasks
  - Comprehensive acceptance criteria
  - Testing strategy
  - Deployment plan

### README
- Complete guide to unified specs
- Usage instructions for both editions
- Best practices
- Troubleshooting

---

## Verification

Check that everything is set up correctly:

```bash
# Verify directory structure
ls -la .droidz/specs/

# Should see:
# - active/
# - archive/
# - templates/
# - examples/
# - README.md

# Check templates exist
ls -la .droidz/specs/templates/

# Should see:
# - feature-spec.md
# - epic-spec.md

# Check examples exist
ls -la .droidz/specs/examples/

# Should see:
# - 000-realtime-notifications.md
```

---

## Troubleshooting

### "Directory doesn't exist"
```bash
mkdir -p .droidz/specs/{active,archive,templates,examples}
```

### "Missing templates"
```bash
# Copy from .factory if they exist there
cp .factory/specs/templates/*.md .droidz/specs/templates/

# Or re-run installer
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### "Can't find my specs"
Check both locations:
```bash
ls -la .droidz/specs/active/
ls -la .factory/specs/active/
```

If they're in `.factory/specs/`, run the migration command above.

---

## Benefits

### ✅ Consistency
Both CLI and Claude Code reference the same specs.

### ✅ Portability
Switch between modes without losing your work.

### ✅ Team Collaboration
Share specs across team members using different modes.

### ✅ Better Examples
New example specs provide reference implementations.

### ✅ Cleaner Structure
Unified location reduces confusion about where specs live.

---

## Need Help?

- **Documentation**: See `.droidz/specs/README.md`
- **Example Spec**: See `.droidz/specs/examples/000-realtime-notifications.md`
- **Discord**: [Join our community](https://discord.gg/droidz)
- **GitHub Issues**: [Report problems](https://github.com/korallis/Droidz/issues)

---

**Version**: 3.4.0
**Last Updated**: 2025-11-22
