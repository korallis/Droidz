---
description: Orchestrate parallel task execution using git worktrees and specialist agents. Creates isolated workspaces, spawns tmux sessions, and coordinates multiple agents working simultaneously for 3-5x faster development.
argument-hint: [source] - linear:query | spec:file | file:tasks.json | list | cleanup:session-id
allowed-tools: Bash(*)
---

# /orchestrate - Parallel Task Execution Orchestrator

Transforms complex, multi-task work into parallel execution streams using git worktrees and specialist agents.

## Usage

```bash
# From Linear query
/orchestrate linear:sprint-current
/orchestrate linear:"label:auto-droidz AND status:Todo"

# From spec file
/orchestrate spec:.claude/specs/active/feature-auth.md

# From JSON file
/orchestrate file:tasks.json

# List active orchestrations
/orchestrate list

# Cleanup orchestration
/orchestrate cleanup:20250112-143022-12345

# Interactive mode (asks questions)
/orchestrate
```

## What It Does

1. **Analyzes** - Parses tasks from Linear, spec files, or JSON
2. **Decomposes** - Breaks work into parallelizable tasks
3. **Isolates** - Creates git worktrees for each task
4. **Coordinates** - Sets up tmux sessions with specialist agents
5. **Executes** - Runs tasks in parallel (true multi-workspace execution)
6. **Integrates** - Merges results when complete

## Arguments

**$ARGUMENTS** can be:

- `linear:QUERY` - Fetch issues from Linear matching query
- `spec:FILE` - Parse tasks from spec markdown file
- `file:FILE` - Load tasks from JSON file
- `list` - Show active orchestrations
- `cleanup:SESSION_ID` - Clean up an orchestration
- *(empty)* - Interactive mode with guided questions

## Task JSON Format

```json
{
  "tasks": [
    {
      "key": "DROIDZ-001",
      "title": "Implement authentication API",
      "description": "Build REST API for user authentication",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "DROIDZ-002",
      "title": "Create login UI",
      "description": "Build frontend login form",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "DROIDZ-003",
      "title": "Write integration tests",
      "description": "Test auth flow end-to-end",
      "specialist": "droidz-test",
      "priority": 2
    }
  ]
}
```

## Specialist Assignment

Automatically assigns the right specialist for each task type:

- `droidz-codegen` - Feature implementation, bug fixes
- `droidz-test` - Test writing, coverage
- `droidz-refactor` - Code cleanup, structural improvements
- `droidz-infra` - CI/CD, deployment, infrastructure
- `droidz-integration` - API integrations, external services
- `droidz-generalist` - Miscellaneous tasks

## Supervised Execution

Uses supervised mode with approval gates:

1. **Plan Approval** - Review task decomposition
2. **Worktree Approval** - Confirm workspace creation
3. **Execution** - Monitor progress in real-time
4. **Merge Approval** - Review changes before integration

## Output

Creates:
- **Worktrees**: `.runs/[TASK-KEY]/`
- **Tmux Sessions**: `droidz-[TASK-KEY]`
- **Coordination State**: `.runs/.coordination/orchestration-[SESSION-ID].json`
- **Logs**: `.runs/.coordination/orchestration.log`

## Example Session

```bash
# Start orchestration
/orchestrate linear:"sprint:current"

# Output shows:
# ✓ Created worktree: .runs/DROIDZ-001
# ✓ Created tmux session: droidz-DROIDZ-001
# ✓ Created worktree: .runs/DROIDZ-002
# ✓ Created tmux session: droidz-DROIDZ-002
# ✓ Created worktree: .runs/DROIDZ-003
# ✓ Created tmux session: droidz-DROIDZ-003
#
# Attach to sessions:
#   1. tmux attach -t droidz-DROIDZ-001
#   2. tmux attach -t droidz-DROIDZ-002
#   3. tmux attach -t droidz-DROIDZ-003
```

## Tmux Session Management

Each tmux session is configured with:
- Working directory set to worktree
- Specialist context loaded
- Task instructions in `.claude-context.md`
- Progress tracking in `.droidz-meta.json`

Switch between sessions:
```bash
# List sessions
tmux ls | grep droidz

# Attach to session
tmux attach -t droidz-DROIDZ-001

# Detach (inside tmux)
Ctrl+B, then D

# Switch between sessions (inside tmux)
Ctrl+B, then S
```

## Coordination Protocol

Tasks coordinate through shared files in `.runs/.coordination/`:

- `orchestration-[SESSION-ID].json` - Overall state
- `tasks.json` - Task registry
- `locks.json` - Resource locks
- `messages.json` - Inter-agent communication

## Progress Tracking

Monitor orchestration progress:

```bash
# List active orchestrations
/orchestrate list

# View logs
tail -f .runs/.coordination/orchestration.log

# Check task status
cat .runs/DROIDZ-001/.droidz-meta.json
```

## Cleanup

After tasks complete:

```bash
# Cleanup specific orchestration
/orchestrate cleanup:20250112-143022-12345

# Manual cleanup
git worktree remove .runs/DROIDZ-001
tmux kill-session -t droidz-DROIDZ-001
```

## Best Practices

1. **Task Independence** - Ensure tasks can run in parallel
2. **Clear Descriptions** - Provide detailed task descriptions
3. **Specialist Matching** - Assign appropriate specialist for each task
4. **Monitor Progress** - Check tmux sessions regularly
5. **Merge Carefully** - Review all changes before merging

## Limitations

- Requires tmux installed (`brew install tmux`)
- Each worktree needs disk space
- Dependent tasks should run sequentially, not in parallel
- Resource conflicts need manual resolution

## Troubleshooting

**Worktree creation failed:**
```bash
git worktree prune
/orchestrate cleanup:SESSION_ID
```

**Tmux session not responding:**
```bash
tmux kill-session -t droidz-TASK-KEY
# Recreate manually if needed
```

**Resource conflicts:**
- Check `.runs/.coordination/locks.json`
- Coordinate with other tasks manually

---

You are helping the user orchestrate parallel task execution. Parse the arguments ($ARGUMENTS) and perform the appropriate action:

**If no arguments:** Display an interactive menu asking the user what they'd like to orchestrate (Linear query, spec file, JSON file, or list active orchestrations).

**If arguments start with `linear:`** - Fetch tasks from Linear using the MCP integration, extract the query after the colon, convert the Linear issues to task JSON format, then proceed with orchestration.

**If arguments start with `spec:`** - Read the specified markdown spec file, parse the Implementation Plan section to extract tasks, convert them to task JSON format, then orchestrate.

**If arguments start with `file:`** - Load and parse the specified JSON task file, validate the format, then orchestrate.

**If argument is `list`** - Check the `.runs/.coordination/` directory for active orchestration state files and display a clean table showing Session ID, Status, Task count, and Start time for each.

**If arguments start with `cleanup:`** - Clean up the specified orchestration session by removing git worktrees, killing tmux sessions, and deleting coordination state files. Display a summary of what was cleaned up.

**For orchestration execution:**
Once you have tasks loaded from any source:
1. Display a clean summary of the orchestration plan showing task count, task details, estimated time, and parallelization factor
2. Create git worktrees in `.runs/[TASK-KEY]/` for each task
3. Spawn tmux sessions named `droidz-[TASK-KEY]` for each task
4. Initialize each task workspace with `.claude-context.md` and `.droidz-meta.json` files
5. Display next steps with session ID, tmux attach commands, and monitoring instructions

Use the clean formatting style shown in the examples above. If the orchestrator script is missing or arguments are invalid, show helpful error messages with instructions on how to fix the issue.
