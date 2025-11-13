---
description: Create a new specification from template (feature, epic, refactor, or integration). Opens the spec file for editing with all sections pre-filled.
argument-hint: [type] [name] - e.g., "feature auth-system" or "epic mobile-app"
allowed-tools: Bash(mkdir:*), Bash(cp:*), Write, Read, Edit
---

# /create-spec - Create New Specification

Creates a new specification file from the appropriate template.

## Usage

```bash
# Create feature spec
/create-spec feature auth-system

# Create epic spec
/create-spec epic mobile-platform

# Create refactor spec
/create-spec refactor legacy-modernization

# Create integration spec
/create-spec integration stripe-payments

# Interactive mode (no arguments)
/create-spec
```

## Arguments

**$ARGUMENTS** format: `[type] [name]`

- **type**: `feature`, `epic`, `refactor`, or `integration`
- **name**: Kebab-case name for the spec (e.g., `auth-system`, `mobile-app`)

## Spec Types

### Feature
For single features or enhancements.
- Typical duration: 1-2 weeks
- Example: "Add user authentication"

### Epic
For large initiatives with multiple features.
- Typical duration: 1-3 months
- Example: "Build e-commerce platform"

### Refactor
For code improvements without behavior changes.
- Typical duration: 1-4 weeks
- Example: "Modernize authentication module"

### Integration
For third-party service integrations.
- Typical duration: 3-7 days
- Example: "Integrate Stripe payments"

## What Gets Created

Creates file: `.claude/specs/active/[name].md`

Pre-filled with:
- Template structure
- All required sections
- Helpful prompts and examples
- Timestamp and metadata

## Workflow

1. **Create spec**: `/create-spec feature auth-system`
2. **Fill in details**: Edit the created file
3. **Validate**: `/validate-spec .claude/specs/active/auth-system.md`
4. **Convert to tasks**: `/spec-to-tasks .claude/specs/active/auth-system.md`
5. **Orchestrate**: `/orchestrate file:auth-system-tasks.json`

## Example

```bash
# Create feature spec
/create-spec feature user-dashboard

# Output:
# ✅ Created: .claude/specs/active/user-dashboard.md
# 📝 Template: feature-spec
# 🎯 Next steps:
#    1. Edit the spec file and fill in all sections
#    2. Run /validate-spec .claude/specs/active/user-dashboard.md
#    3. Run /spec-to-tasks .claude/specs/active/user-dashboard.md
```

---

## Implementation Instructions

When this command is executed, perform the following based on $ARGUMENTS:

### Parse Arguments

Extract type and name from `$ARGUMENTS`:
- First word: `SPEC_TYPE` (feature, epic, refactor, integration)
- Second word: `SPEC_NAME` (e.g., auth-system)

If arguments missing, display usage:
```
🎯 Create New Specification

What type of spec do you want to create?

  1. feature    - Single feature or enhancement (1-2 weeks)
  2. epic       - Large initiative with multiple features (1-3 months)
  3. refactor   - Code improvement without behavior change (1-4 weeks)
  4. integration - Third-party service integration (3-7 days)

Usage: /create-spec [type] [name]
Example: /create-spec feature auth-system
```

### Validation

**Validate spec type:**
- Must be one of: `feature`, `epic`, `refactor`, `integration`
- If invalid, show error and valid types

**Check for duplicates:**
- Check if `.claude/specs/active/[name].md` already exists
- If exists, offer options:
  1. Edit existing spec
  2. Choose different name
  3. Archive existing and create new

### Create Spec

**Step 1: Ensure Directories**
Create if not exist:
- `.claude/specs/active/`
- `.claude/specs/templates/`

**Step 2: Load Template**
Read template file: `.claude/specs/templates/[type]-spec.md`

If template doesn't exist, show error:
```
❌ Error: Template not found: .claude/specs/templates/[type]-spec.md

Please ensure Droidz is properly initialized.
Run: /droidz-init
```

**Step 3: Customize Template**
Replace placeholders:
- `YYYY-MM-DD` → Current date
- `[Feature Name]` → Provided name
- `FEAT-XXX` → `[TYPE]-[YYYYMMDD]` (e.g., FEATURE-20250113)

**Step 4: Write Spec File**
Write to: `.claude/specs/active/[name].md`

**Step 5: Display Success**
```
✅ Created: .claude/specs/active/auth-system.md
📝 Template: feature-spec
📅 Date: 2025-01-13

🎯 Next steps:
   1. Edit the spec file and fill in all sections
   2. Run: /validate-spec .claude/specs/active/auth-system.md
   3. Run: /spec-to-tasks .claude/specs/active/auth-system.md
   4. Run: /orchestrate file:auth-system-tasks.json
```

Then open the created file for the user to review and edit.
