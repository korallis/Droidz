# Unified Droidz Specs Directory

> **Shared specification storage for both Droid CLI and Claude Code editions**

This directory provides a unified location for storing Droidz specifications that works across both installation modes.

---

## Why Unified Storage?

Droidz supports two installation modes:

1. **Droid CLI** - Standalone CLI tool for multi-agent orchestration
2. **Claude Code Edition** - Integrated with Factory.ai Claude Code

Both modes need access to the same specifications. This `.droidz/specs/` directory serves as the shared storage location.

---

## Directory Structure

```
.droidz/specs/
├── README.md                  # This file
├── templates/                 # Spec templates
│   ├── feature-spec.md       # Template for feature specifications
│   └── epic-spec.md          # Template for epic specifications
├── active/                    # Current work specifications
│   └── .gitkeep              # (Active specs not committed to git)
└── archive/                   # Completed specifications
    └── .gitkeep              # (Archives typically not committed)
```

---

## Spec Types

### Feature Spec
For new features or enhancements.
- **Use when**: Adding new functionality
- **Template**: `templates/feature-spec.md`
- **Command**: `/build` (Claude Code) or `droidz build` (CLI)

### Epic Spec
For large initiatives spanning multiple features.
- **Use when**: Complex projects with multiple components
- **Template**: `templates/epic-spec.md`

---

## Usage

### Claude Code Edition

Use slash commands:

```
/build "user authentication system"
# Generates: .droidz/specs/active/001-user-authentication.md

/parallel .droidz/specs/active/001-user-authentication.md
# Executes spec with parallel agent orchestration
```

### Droid CLI

Use CLI commands:

```bash
droidz build "user authentication system"
# Generates: .droidz/specs/active/001-user-authentication.md

droidz parallel .droidz/specs/active/001-user-authentication.md
# Executes spec with parallel agent orchestration
```

---

## Git Strategy

### Not Committed (Default)
- `active/*.md` - Work in progress specs
- `active/*.json` - Generated task breakdowns
- `archive/*.md` - Completed specs

**Rationale**: Specs are typically project-specific and change frequently. Keeping them out of git reduces noise in commits.

### Committed (Optional)
You may choose to commit:
- Example specs for team onboarding
- Reference architectures
- Reusable feature patterns

To commit a specific spec:
```bash
git add -f .droidz/specs/active/001-example.md
git commit -m "docs: add example auth spec"
```

---

## Migration from Legacy Locations

### From `.factory/specs/` (Claude Code only)
If you have existing specs in `.factory/specs/active/`:

```bash
# Move to unified location
mv .factory/specs/active/*.md .droidz/specs/active/ 2>/dev/null || true
mv .factory/specs/archive/*.md .droidz/specs/archive/ 2>/dev/null || true

# Both editions will now use .droidz/specs/
```

### From v2.x `.droidz/specs/`
v2.x already used `.droidz/specs/`, so no migration needed! Just ensure your templates are up to date:

```bash
# Copy latest templates
cp .factory/specs/templates/*.md .droidz/specs/templates/
```

---

## Benefits

### ✅ Consistency
Both CLI and Claude Code reference the same specs.

### ✅ Portability
Switch between modes without losing your work.

### ✅ Team Collaboration
Share specs across team members using different modes.

### ✅ Version Control Flexibility
Choose what to commit based on your workflow.

---

## Backward Compatibility

### Legacy Support
- `.factory/specs/active/` still works in Claude Code
- Gradually migrate to `.droidz/specs/` for consistency

### Commands Updated
All commands now default to `.droidz/specs/`:
- `/build` → `.droidz/specs/active/NNN-feature.md`
- `/parallel` → Accepts `.droidz/specs/active/*.md`
- CLI equivalents → Same behavior

---

## Troubleshooting

### "Can't find my specs!"
Check both locations:
```bash
ls -la .droidz/specs/active/
ls -la .factory/specs/active/
```

### "Templates missing"
Copy from factory:
```bash
cp .factory/specs/templates/*.md .droidz/specs/templates/
```

### "Permission denied"
Ensure directory exists:
```bash
mkdir -p .droidz/specs/{active,archive,templates}
```

---

## Best Practices

### 1. Use Descriptive Names
```
✅ .droidz/specs/active/042-user-authentication-oauth.md
❌ .droidz/specs/active/auth.md
```

### 2. Archive When Complete
```bash
mv .droidz/specs/active/042-*.md .droidz/specs/archive/
```

### 3. Keep Templates Updated
```bash
# Periodically refresh templates
cp .factory/specs/templates/*.md .droidz/specs/templates/
```

### 4. Document Decisions
Add context to specs about why architectural choices were made.

### 5. Review Before Executing
Always review generated specs before running `/parallel`.

---

## Integration with Orchestrator

The orchestrator reads specs from `.droidz/specs/active/` to:
- **Decompose** - Break into parallel tasks
- **Assign** - Match tasks to specialist agents
- **Coordinate** - Handle dependencies
- **Validate** - Check against acceptance criteria
- **Report** - Track progress against spec

---

## Version History

- **v3.4.0** (2025-11-22) - Introduced unified `.droidz/specs/` for dual-mode support
- **v3.0.0** (2025-11-22) - Migrated to `.factory/specs/` (Claude Code only)
- **v2.x** (2025-11-15) - Used `.droidz/specs/` (CLI only)

---

*For more information, see:*
- `COMMANDS.md` - Full command reference
- `DROIDS.md` - Agent documentation
- `VALIDATION.md` - Validation pipeline details
