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

## Implementation

<execute>
SPECS_DIR="$CLAUDE_PROJECT_DIR/.claude/specs"
TEMPLATES_DIR="$SPECS_DIR/templates"
ACTIVE_DIR="$SPECS_DIR/active"

# Ensure directories exist
mkdir -p "$ACTIVE_DIR"

# Parse arguments
if [ -z "$ARGUMENTS" ]; then
  echo "🎯 Create New Specification"
  echo ""
  echo "What type of spec do you want to create?"
  echo ""
  echo "  1. feature    - Single feature or enhancement (1-2 weeks)"
  echo "  2. epic       - Large initiative with multiple features (1-3 months)"
  echo "  3. refactor   - Code improvement without behavior change (1-4 weeks)"
  echo "  4. integration - Third-party service integration (3-7 days)"
  echo ""
  echo "Usage: /create-spec [type] [name]"
  echo "Example: /create-spec feature auth-system"
  exit 0
fi

# Split arguments
SPEC_TYPE=$(echo "$ARGUMENTS" | awk '{print $1}')
SPEC_NAME=$(echo "$ARGUMENTS" | awk '{print $2}')

if [ -z "$SPEC_NAME" ]; then
  echo "❌ Error: Missing spec name"
  echo ""
  echo "Usage: /create-spec [type] [name]"
  echo "Example: /create-spec feature auth-system"
  exit 1
fi

# Validate spec type
case "$SPEC_TYPE" in
  feature|epic|refactor|integration)
    TEMPLATE_FILE="$TEMPLATES_DIR/${SPEC_TYPE}-spec.md"
    ;;
  *)
    echo "❌ Error: Invalid spec type: $SPEC_TYPE"
    echo ""
    echo "Valid types: feature, epic, refactor, integration"
    exit 1
    ;;
esac

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Error: Template not found: $TEMPLATE_FILE"
  exit 1
fi

# Create spec file path
SPEC_FILE="$ACTIVE_DIR/${SPEC_NAME}.md"

# Check if spec already exists
if [ -f "$SPEC_FILE" ]; then
  echo "⚠️  Spec already exists: $SPEC_FILE"
  echo ""
  echo "Options:"
  echo "  1. Edit existing spec"
  echo "  2. Choose different name"
  echo "  3. Archive existing and create new"
  exit 1
fi

# Copy template to active directory
cp "$TEMPLATE_FILE" "$SPEC_FILE"

# Update metadata in the spec
TODAY=$(date +%Y-%m-%d)
sed -i.bak "s/YYYY-MM-DD/$TODAY/g" "$SPEC_FILE"
sed -i.bak "s/\\[Feature Name\\]/${SPEC_NAME}/g" "$SPEC_FILE"
sed -i.bak "s/FEAT-XXX/${SPEC_TYPE^^}-$(date +%Y%m%d)/g" "$SPEC_FILE"
rm -f "${SPEC_FILE}.bak"

# Display success message
echo "✅ Created: $SPEC_FILE"
echo "📝 Template: ${SPEC_TYPE}-spec"
echo "📅 Date: $TODAY"
echo ""
echo "🎯 Next steps:"
echo "   1. Edit the spec file and fill in all sections"
echo "   2. Run: /validate-spec $SPEC_FILE"
echo "   3. Run: /spec-to-tasks $SPEC_FILE"
echo "   4. Run: /orchestrate file:${SPEC_NAME}-tasks.json"
echo ""
echo "Opening spec file for editing..."
echo ""
echo "File: $SPEC_FILE"
</execute>
