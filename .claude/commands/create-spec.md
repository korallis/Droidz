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
5. **Orchestrate**: `/orchestrate file:.claude/specs/active/tasks/auth-system-tasks.json`

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

You are helping the user create a new specification file. Parse the arguments ($ARGUMENTS) to extract the spec type and name:

**If no arguments:** Display a helpful menu showing the available spec types (feature, epic, refactor, integration) with descriptions and usage examples.

**If arguments provided:** Extract the first word as the spec type and the second word as the spec name.

Validate that:
- The spec type is one of: feature, epic, refactor, or integration
- A spec name was provided
- The spec doesn't already exist at `.claude/specs/active/[name].md`

If validation fails, show a clear error message explaining the issue.

**To create the spec:**
1. Ensure the necessary directories exist (`.claude/specs/active/` and `.claude/specs/templates/`)
2. Read the appropriate template from `.claude/specs/templates/[type]-spec.md`
3. Customize the template by replacing placeholders like `YYYY-MM-DD` with today's date, `[Feature Name]` with the provided name, and generating an appropriate spec ID
4. Write the customized spec to `.claude/specs/active/[name].md`
5. Display a success message showing the created file path, template used, date, and next steps (validate, convert to tasks, orchestrate)

Then open the created file so the user can review and edit it. Use clean formatting with checkmarks and appropriate emoji as shown in the examples above.
