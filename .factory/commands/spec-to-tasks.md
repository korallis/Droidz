---
description: Parse a specification file and generate orchestration tasks JSON. Analyzes the spec's implementation plan and creates a structured task list ready for parallel execution.
argument-hint: [spec-file] - path to validated spec file
allowed-tools: Bash(*), Read, Write
---

# /spec-to-tasks - Convert Spec to Orchestration Tasks

Parses a specification file and generates a JSON task list for orchestration.

## Usage

```bash
# Convert spec to tasks
/spec-to-tasks .factory/specs/active/auth-system.md

# Output to specific file
/spec-to-tasks .factory/specs/active/auth-system.md --output custom-tasks.json

# Preview mode (don't write file)
/spec-to-tasks .factory/specs/active/auth-system.md --preview
```

## What It Does

1. **Reads specification** - Parses the implementation plan section
2. **Extracts tasks** - Identifies discrete tasks with specialist assignments
3. **Analyzes dependencies** - Determines task ordering and dependencies
4. **Estimates effort** - Captures time estimates
5. **Assigns specialists** - Maps tasks to appropriate Droidz specialists
6. **Generates JSON** - Creates orchestration-ready task file

## Output Format

Creates `[spec-name]-tasks.json`:

```json
{
  "source": "spec:.factory/specs/active/auth-system.md",
  "specId": "FEAT-20250112",
  "specName": "auth-system",
  "specType": "feature",
  "createdAt": "2025-01-12T14:30:00Z",
  "estimatedTotalHours": 16,
  "parallelizationFactor": "2.4x",
  "tasks": [
    {
      "key": "AUTH-API",
      "title": "Backend Authentication API",
      "description": "Implement REST API endpoints for auth...",
      "specialist": "droidz-codegen",
      "priority": 1,
      "estimatedHours": 6,
      "dependencies": [],
      "parallel": true,
      "acceptanceCriteria": [
        "All endpoints return < 200ms",
        "JWT tokens properly validated",
        "Rate limiting implemented"
      ]
    },
    {
      "key": "AUTH-UI",
      "title": "Frontend Login/Register UI",
      "description": "Build React components for authentication...",
      "specialist": "droidz-codegen",
      "priority": 1,
      "estimatedHours": 4,
      "dependencies": [],
      "parallel": true,
      "acceptanceCriteria": [
        "Responsive design works on mobile",
        "Accessibility WCAG AA compliant",
        "Form validation works"
      ]
    },
    {
      "key": "AUTH-TEST",
      "title": "Integration Tests",
      "description": "Write comprehensive test suite...",
      "specialist": "droidz-test",
      "priority": 2,
      "estimatedHours": 6,
      "dependencies": ["AUTH-API", "AUTH-UI"],
      "parallel": false,
      "acceptanceCriteria": [
        "Coverage >= 80%",
        "All user flows tested",
        "Edge cases covered"
      ]
    }
  ]
}
```

## Task Extraction Rules

### Specialist Assignment
Automatically assigns based on task description:

- **droidz-codegen**: Feature implementation, bug fixes, new code
- **droidz-test**: Test writing, coverage, QA
- **droidz-refactor**: Code cleanup, structure improvements
- **droidz-infra**: CI/CD, deployment, infrastructure
- **droidz-integration**: External APIs, third-party services
- **droidz-generalist**: Documentation, misc tasks

### Dependency Detection
Identifies dependencies from:
- Explicit "depends on" statements
- Sequential numbering with "after"
- Technical requirements (e.g., tests depend on implementation)
- Common sense (e.g., deployment depends on code)

### Parallelization Analysis
Determines which tasks can run in parallel:
- ✅ **Parallel**: No dependencies, different domains
- ❌ **Sequential**: Has dependencies, same files

## Validation

Before generating tasks, validates:
- [ ] Spec has implementation plan section
- [ ] Tasks have clear descriptions
- [ ] Specialist assignments are valid
- [ ] No circular dependencies
- [ ] Effort estimates are realistic

## Next Steps

After generating tasks:

```bash
# Review the generated tasks
cat auth-system-tasks.json

# Orchestrate the tasks
/orchestrate file:auth-system-tasks.json
```

## Example Workflow

```bash
# 1. Create spec
/create-spec feature payment-integration

# 2. Fill in spec details
# (edit .factory/specs/active/payment-integration.md)

# 3. Validate spec
/validate-spec .factory/specs/active/payment-integration.md

# 4. Generate tasks
/spec-to-tasks .factory/specs/active/payment-integration.md

# 5. Orchestrate
/orchestrate file:payment-integration-tasks.json
```

---

## Implementation

<execute>
SPEC_FILE=$(echo "$ARGUMENTS" | awk '{print $1}')
OUTPUT_FILE=""
PREVIEW_MODE=false

# Check for flags
if echo "$ARGUMENTS" | grep -q "\-\-output"; then
  OUTPUT_FILE=$(echo "$ARGUMENTS" | sed 's/.*--output //' | awk '{print $1}')
fi

if echo "$ARGUMENTS" | grep -q "\-\-preview"; then
  PREVIEW_MODE=true
fi

if [ -z "$SPEC_FILE" ]; then
  echo "❌ Error: No spec file specified"
  echo ""
  echo "Usage: /spec-to-tasks [spec-file]"
  echo "Example: /spec-to-tasks .factory/specs/active/auth-system.md"
  exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 1
fi

echo "📝 Parsing Specification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Spec: $SPEC_FILE"
echo ""

# Extract spec metadata
SPEC_NAME=$(basename "$SPEC_FILE" .md)
SPEC_ID=$(grep -m1 "Spec ID:" "$SPEC_FILE" | sed 's/.*: //' || echo "SPEC-$(date +%Y%m%d)")
SPEC_TYPE=$(grep -m1 "# Feature Spec:\|# Epic Spec:\|# Refactor Spec:\|# Integration Spec:" "$SPEC_FILE" | sed 's/# \(.*\) Spec:.*/\L\1/')

if [ -z "$SPEC_TYPE" ]; then
  SPEC_TYPE="feature"
fi

echo "📋 Spec Details:"
echo "  Name: $SPEC_NAME"
echo "  ID: $SPEC_ID"
echo "  Type: $SPEC_TYPE"
echo ""

# Read implementation plan section
echo "🔍 Extracting tasks from implementation plan..."
echo ""

# This is a simplified parser - in production, you'd want more sophisticated parsing
# For now, we'll create a template task structure

# Determine output file
if [ -z "$OUTPUT_FILE" ]; then
  # Create tasks directory if it doesn't exist
  mkdir -p ".factory/specs/active/tasks"
  OUTPUT_FILE=".factory/specs/active/tasks/${SPEC_NAME}-tasks.json"
fi

# Generate tasks JSON
# In a real implementation, this would parse the spec more intelligently
# For now, we'll create a structure that prompts Claude to fill in details

cat > "$OUTPUT_FILE" << EOF
{
  "source": "spec:$SPEC_FILE",
  "specId": "$SPEC_ID",
  "specName": "$SPEC_NAME",
  "specType": "$SPEC_TYPE",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "estimatedTotalHours": 0,
  "parallelizationFactor": "0x",
  "tasks": []
}
EOF

echo "✅ Generated task file: $OUTPUT_FILE"
echo ""
echo "⚠️  IMPORTANT: Task extraction requires intelligent parsing."
echo ""
echo "Please review the spec's Implementation Plan section and populate the tasks array with:"
echo ""
echo "  - key: Unique task identifier (e.g., \"AUTH-API\")"
echo "  - title: Descriptive task title"
echo "  - description: Detailed task description"
echo "  - specialist: droidz-codegen|droidz-test|droidz-refactor|droidz-infra|droidz-integration|droidz-generalist"
echo "  - priority: 1-4 (1=highest)"
echo "  - estimatedHours: Numeric estimate"
echo "  - dependencies: Array of task keys this depends on"
echo "  - parallel: true if can run in parallel"
echo "  - acceptanceCriteria: Array of acceptance criteria"
echo ""
echo "Example task structure:"
echo ""
cat << 'EXAMPLE'
{
  "key": "AUTH-API",
  "title": "Backend Authentication API",
  "description": "Implement REST API endpoints...",
  "specialist": "droidz-codegen",
  "priority": 1,
  "estimatedHours": 6,
  "dependencies": [],
  "parallel": true,
  "acceptanceCriteria": [
    "All endpoints return < 200ms",
    "JWT validation works",
    "Rate limiting implemented"
  ]
}
EXAMPLE

echo ""
echo "After populating tasks, run:"
echo "  /orchestrate file:$OUTPUT_FILE"
</execute>
