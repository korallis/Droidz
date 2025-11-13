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
/spec-to-tasks .claude/specs/active/auth-system.md

# Output to specific file
/spec-to-tasks .claude/specs/active/auth-system.md --output custom-tasks.json

# Preview mode (don't write file)
/spec-to-tasks .claude/specs/active/auth-system.md --preview
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
  "source": "spec:.claude/specs/active/auth-system.md",
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
# (edit .claude/specs/active/payment-integration.md)

# 3. Validate spec
/validate-spec .claude/specs/active/payment-integration.md

# 4. Generate tasks
/spec-to-tasks .claude/specs/active/payment-integration.md

# 5. Orchestrate
/orchestrate file:payment-integration-tasks.json
```

---

## Implementation Instructions

When this command is executed, perform the following based on $ARGUMENTS:

### Parse Arguments

Extract from `$ARGUMENTS`:
- Spec file path (first argument)
- Optional: `--output [path]` for custom output location
- Optional: `--preview` for dry-run mode

If no spec file provided:
```
❌ Error: No spec file specified

Usage: /spec-to-tasks [spec-file] [--output path] [--preview]
Example: /spec-to-tasks .claude/specs/active/auth-system.md
```

### Validation

**Check file exists:**
If spec file not found:
```
❌ Error: Spec file not found: [path]
```

### Parse Specification

**Step 1: Extract Metadata**
From the spec file, extract:
- **Spec ID**: Look for "Spec ID:" line
- **Spec Name**: Derive from filename
- **Spec Type**: Detect from header (Feature/Epic/Refactor/Integration)
- **Creation Date**: Current timestamp

Display:
```
📝 Parsing Specification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Spec: .claude/specs/active/auth-system.md

📋 Spec Details:
  Name: auth-system
  ID: FEATURE-20250113
  Type: feature
```

**Step 2: Parse Implementation Plan**
Read the "## Implementation Plan" section and extract:
1. Each task/subtask listed
2. Task descriptions
3. Dependencies mentioned
4. Acceptance criteria

Intelligently determine for each task:
- **Specialist**: Based on task type
  - API/backend/database → `droidz-codegen`
  - UI/components/frontend → `droidz-codegen`
  - Tests/coverage → `droidz-test`
  - Refactoring/cleanup → `droidz-refactor`
  - CI/CD/deployment → `droidz-infra`
  - Third-party integration → `droidz-integration`
  - Other → `droidz-generalist`

- **Priority**: Based on dependencies
  - No dependencies → Priority 1 (can start immediately)
  - Has dependencies → Priority 2+ (sequential)

- **Parallelization**: Tasks with same priority can run in parallel

**Step 3: Generate Tasks JSON**

Create output file at `.claude/specs/active/tasks/[spec-name]-tasks.json` (or custom path if specified):

```json
{
  "source": "spec:.claude/specs/active/auth-system.md",
  "specId": "FEATURE-20250113",
  "specName": "auth-system",
  "specType": "feature",
  "createdAt": "2025-01-13T12:00:00Z",
  "estimatedTotalHours": 24,
  "parallelizationFactor": "3x",
  "tasks": [
    {
      "key": "AUTH-001",
      "title": "Backend Authentication API",
      "description": "Implement REST API endpoints for user authentication",
      "specialist": "droidz-codegen",
      "priority": 1,
      "estimatedHours": 8,
      "dependencies": [],
      "parallel": true,
      "acceptanceCriteria": [
        "All endpoints return < 200ms",
        "JWT validation works",
        "Rate limiting implemented"
      ]
    }
  ]
}
```

**Step 4: Calculate Metrics**
- `estimatedTotalHours`: Sum of all task hours
- `parallelizationFactor`: `[count of priority-1 tasks]x` (e.g., "3x" means 3 tasks can run simultaneously)

**Step 5: Display Summary**

```
✅ Task Extraction Complete

Output: .claude/specs/active/tasks/auth-system-tasks.json

📊 Summary:
  Total Tasks: 5
  Estimated Hours: 24
  Parallelization: 3x (3 tasks can run simultaneously)

Task Breakdown:
  Priority 1: 3 tasks (can run in parallel)
  Priority 2: 2 tasks (depend on priority 1)

Specialists:
  droidz-codegen: 3 tasks
  droidz-test: 1 task
  droidz-infra: 1 task

🎯 Next Steps:
  1. Review the generated tasks
  2. Run: /orchestrate file:.claude/specs/active/tasks/auth-system-tasks.json
```

### Preview Mode

If `--preview` flag is present, don't write file. Instead, display tasks in formatted output for user review.
