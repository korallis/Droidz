---
description: Orchestrate parallel task execution from a single description
argument-hint: "description of what to build"
allowed-tools: Task(droidz-orchestrator)
---

# /parallel - One-Command Orchestration

Analyzes your request, generates tasks, and orchestrates parallel execution - all in one command.

## Usage

```bash
# Build a complete feature
/parallel "build authentication system with login, register, and OAuth"

# Implement multiple related features
/parallel "add dark mode support across the application"

# Fix multiple issues
/parallel "fix all TypeScript errors in the codebase"
```

## What It Does

1. **Analyzes** your description to understand scope
2. **Generates** optimal task breakdown
3. **Orchestrates** parallel execution with specialists
4. **Monitors** progress in real-time
5. **Reports** results when complete

## Features

- ✅ **Automatic task breakdown** - No manual task creation
- ✅ **Smart dependency resolution** - Tasks execute in optimal order
- ✅ **Parallel execution** - Multiple specialists work simultaneously
- ✅ **Real-time monitoring** - Live progress updates
- ✅ **Intelligent routing** - Right specialist for each task

## Example Workflow

```bash
# You run:
/parallel "build REST API for user management with CRUD operations"

# What happens:
# 1. Orchestrator analyzes request (30 sec)
# 2. Generates tasks:
#    - USER-001: Create user model and schema
#    - USER-002: Implement POST /users (create)
#    - USER-003: Implement GET /users (read)
#    - USER-004: Implement PUT /users/:id (update)
#    - USER-005: Implement DELETE /users/:id (delete)
#    - USER-006: Add validation middleware
#    - USER-007: Write integration tests
#
# 3. Spawns specialists in parallel (tasks with no dependencies)
# 4. Waits for dependencies, spawns next wave
# 5. Monitors and reports progress
# 6. Returns when all tasks complete

# You see:
# ✅ USER-001 complete (3 files, 5 tests)
# ✅ USER-002 complete (2 files, 8 tests)
# ⏳ USER-003 in progress...
# ⏳ USER-004 in progress...
# ⏸  USER-005 waiting for USER-004
```

## Quick Actions After Orchestration

```bash
# Check status
/status

# View progress
/summary

# Attach to watch a task
/attach USER-003

# Monitor all tasks
.factory/scripts/monitor-orchestration.sh --session [session-id]
```

## Advanced Usage

### With Custom Specialist

```bash
# Use specific specialist for all tasks
/parallel "refactor authentication module" --specialist droidz-refactor
```

### With Priority

```bash
# High priority orchestration
/parallel "fix critical security vulnerabilities" --priority critical
```

### With Constraints

```bash
# Limit parallel execution
/parallel "migrate database schema" --max-parallel 2
```

## How It Works

### Architecture

```
User Request
    ↓
/parallel command
    ↓
droidz-orchestrator (analysis mode)
    ↓
Task Breakdown (tasks.json)
    ↓
orchestrator.sh (execution)
    ↓
Parallel Specialist Agents
    ↓
Results & Integration
```

### Task Analysis

The orchestrator analyzes your description to:
- Identify discrete units of work
- Determine dependencies between tasks
- Select optimal specialist for each task
- Set priority and execution order
- Estimate complexity

### Dependency Resolution

Tasks are grouped into phases:
- **Phase 1:** No dependencies (parallel)
- **Phase 2:** Depends on Phase 1 (parallel within phase)
- **Phase 3:** Depends on Phase 2 (parallel within phase)
- ... and so on

### Specialist Selection

Automatically chooses the right specialist:
- `droidz-codegen` - Feature implementation
- `droidz-refactor` - Code restructuring
- `droidz-test` - Test writing
- `droidz-integration` - API/service integration
- `droidz-infra` - CI/CD, deployment
- `droidz-generalist` - Miscellaneous tasks

## Tips

### Good Descriptions

✅ **Specific:** "Build REST API for user management"  
✅ **Scoped:** "Add dark mode to dashboard and settings pages"  
✅ **Clear:** "Fix TypeScript errors in auth module"

### Avoid

❌ **Too vague:** "Make the app better"  
❌ **Too broad:** "Build entire application"  
❌ **Unclear:** "Do some stuff with the database"

### Best Practices

1. **Be specific** - Clear descriptions = better task breakdown
2. **Start small** - Test with 3-5 tasks before larger orchestrations
3. **Monitor progress** - Use `/status` and `/summary` to track
4. **Review results** - Check task outputs before merging

## Troubleshooting

### "Task breakdown failed"
- Description may be too vague
- Try being more specific
- Break into smaller requests

### "Too many tasks generated"
- Scope may be too broad
- Split into multiple `/parallel` calls
- Use `--max-tasks 10` flag

### "No specialists available"
- Check that custom droids are configured
- Ensure `.factory/droids/` has specialist configs
- Fall back to `droidz-generalist`

## Examples

### Authentication System
```bash
/parallel "implement authentication system with JWT tokens, refresh tokens, and password reset flow"
```

### UI Components
```bash
/parallel "create reusable button, input, and modal components with TypeScript and Storybook"
```

### API Integration
```bash
/parallel "integrate Stripe payment API with checkout flow and webhook handling"
```

### Testing
```bash
/parallel "add comprehensive unit and integration tests for user service"
```

### Refactoring
```bash
/parallel "refactor legacy authentication code to use modern async/await patterns"
```

### Bug Fixes
```bash
/parallel "fix all ESLint errors and warnings in src/components"
```

## Implementation

<invoke>
<parameter name="subagent_type">droidz-orchestrator
