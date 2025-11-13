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

You are helping the user convert a specification into an orchestrable task list. Parse the arguments ($ARGUMENTS):

**If no spec file provided:** Show usage help with example.

**If spec file provided:**
1. Validate the file exists
2. Extract metadata from the spec (Spec ID, name, type)
3. Parse the Implementation Plan section to identify all tasks
4. For each task, intelligently determine the appropriate specialist based on the task type (codegen for APIs/UI, test for testing, refactor for cleanup, infra for CI/CD, integration for third-party services)
5. Assign priorities based on dependencies (tasks with no dependencies get priority 1 and can run in parallel)
6. Generate a JSON file with the complete task structure including keys, titles, descriptions, specialists, priorities, estimated hours, dependencies, and acceptance criteria
7. Calculate and include metrics like total estimated hours and parallelization factor

Display a clean summary showing the output file path, total tasks, estimated time, parallelization factor, task breakdown by priority, and specialist assignments. Then show next steps for running the orchestration.

If the `--preview` flag is present, display the tasks in a formatted table instead of writing to a file. Use the clean formatting style shown in the examples above with appropriate emoji and box-drawing characters.
