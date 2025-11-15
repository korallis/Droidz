---
description: Orchestrate tasks in parallel with automatic live monitoring
argument-hint: "task description"
---

Please invoke the droidz-parallel specialist droid to orchestrate this task in parallel.

**Task:** $ARGUMENTS

Use the Task tool to call droidz-parallel:
```
subagent_type: droidz-parallel
description: Parallel orchestration
prompt: Orchestrate this task in parallel: $ARGUMENTS

Break down the task into 3-7 discrete components, generate tasks.json with 
dependencies, and execute the orchestrator to spawn specialist droids.

After orchestration starts, remind the user to run `/watch` for live monitoring.
```

The droidz-parallel droid will:
- Analyze the request and create optimal task breakdown
- Generate tasks.json with dependencies
- Execute `.factory/scripts/orchestrator.sh` to spawn parallel droids
- Set up worktrees and tmux sessions

After the droid completes, display:

╔══════════════════════════════════════════════════════════╗
║  ✅ Orchestration Started!                               ║
╚══════════════════════════════════════════════════════════╝

📊 NEXT STEP: Monitor live progress

Run this command to see real-time updates:

    /watch

This will show:
  • ✓ Completed tasks
  • ⏳ Tasks in progress
  • ⏸ Pending tasks
  • Live progress bars
