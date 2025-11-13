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

## Implementation Instructions

When this command is executed, perform the following based on $ARGUMENTS:

### Parse Arguments

If `$ARGUMENTS` is empty:
- Display interactive mode menu asking user to specify: linear query, spec file, JSON file, or list
- Wait for user response

If `$ARGUMENTS` starts with prefix, handle accordingly:

**`linear:QUERY`** - Fetch from Linear
1. Extract query after `linear:`
2. Use MCP Linear integration to fetch issues matching query
3. Convert Linear issues to task JSON format
4. Proceed to orchestration

**`spec:FILE`** - Parse spec file
1. Extract file path after `spec:`
2. Read the markdown spec file
3. Parse "Implementation Plan" section for tasks
4. Convert to task JSON format
5. Proceed to orchestration

**`file:FILE`** - Load JSON file
1. Extract file path after `file:`
2. Read and parse JSON file
3. Validate task format
4. Proceed to orchestration

**`list`** - List active orchestrations
1. Check `.runs/.coordination/` directory
2. Read all `orchestration-*.json` files
3. Display table with:
   - Session ID
   - Status (running/paused/completed)
   - Task count
   - Start time

**`cleanup:SESSION_ID`** - Cleanup orchestration
1. Extract session ID after `cleanup:`
2. Remove git worktrees in `.runs/[TASK-KEY]/`
3. Kill tmux sessions `droidz-[TASK-KEY]`
4. Delete coordination state files
5. Display cleanup summary

### Orchestration Process

Once tasks are loaded:

**Step 1: Display Task Summary**
```
📋 Orchestration Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tasks: 3
├─ DROIDZ-001: Implement authentication API (droidz-codegen)
├─ DROIDZ-002: Create login UI (droidz-codegen)
└─ DROIDZ-003: Write integration tests (droidz-test)

Estimated time: 15-20 minutes
Parallelization: 3 concurrent tasks
```

**Step 2: Create Worktrees**
For each task:
1. Create git worktree: `.runs/[TASK-KEY]/`
2. Display: `✓ Created worktree: .runs/DROIDZ-001`

**Step 3: Spawn Tmux Sessions**
For each task:
1. Create tmux session: `droidz-[TASK-KEY]`
2. Set working directory to worktree
3. Display: `✓ Created tmux session: droidz-DROIDZ-001`

**Step 4: Initialize Tasks**
In each worktree:
1. Create `.claude-context.md` with task details
2. Create `.droidz-meta.json` with task metadata
3. Load specialist agent configuration

**Step 5: Display Next Steps**
```
✅ Orchestration Started

Session ID: 20250113-143022-12345

Active Tasks:
  1. DROIDZ-001 in tmux session: droidz-DROIDZ-001
  2. DROIDZ-002 in tmux session: droidz-DROIDZ-002
  3. DROIDZ-003 in tmux session: droidz-DROIDZ-003

Attach to sessions:
  tmux attach -t droidz-DROIDZ-001
  tmux attach -t droidz-DROIDZ-002
  tmux attach -t droidz-DROIDZ-003

Monitor progress:
  /orchestrate list

Cleanup when done:
  /orchestrate cleanup:20250113-143022-12345
```

### Error Handling

If orchestrator script missing:
```
❌ Orchestrator script not found: .claude/scripts/orchestrator.sh

Please ensure Droidz is properly initialized.
Run: /droidz-init
```

If unknown argument format:
```
❌ Unknown orchestration source: [argument]

Valid formats:
  linear:QUERY       - Fetch from Linear
  spec:FILE          - Parse spec markdown
  file:FILE          - Load JSON tasks
  list               - Show active orchestrations
  cleanup:SESSION_ID - Clean up orchestration
```
