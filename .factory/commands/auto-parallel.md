---
description: Orchestrate tasks in parallel with automatic live monitoring
argument-hint: "task description"
---

I'll orchestrate this task using Droidz parallel orchestration with automatic live monitoring:

**User Request:** $ARGUMENTS

Please use the `droidz-parallel` specialist droid to:

1. Analyze the request and break it into 3-7 discrete tasks
2. Generate a tasks.json file with dependencies
3. Execute the orchestrator to create worktrees and spawn specialist droids
4. **After spawning droids, automatically start live monitoring**

The droidz-parallel droid will:
- Create optimal task breakdown
- Spawn Task() calls for each specialist
- Set up parallel execution infrastructure
- **Then use Execute to run the /watch command for real-time monitoring**

Start the orchestration now and show live progress updates.

**Important:** After spawning all Phase 1 droids, execute:
```bash
# Run watch in the background with output to user
.factory/commands/watch.sh
```

This will show real-time progress with:
- ✓ Completed tasks
- ⏳ Tasks in progress  
- ⏸ Pending tasks
- Progress bar visualization
- Active tmux sessions
