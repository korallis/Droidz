---
description: Orchestrate tasks in parallel with automatic live monitoring
argument-hint: "task description"
---

I will orchestrate this task using parallel execution with live progress tracking.

**Task:** $ARGUMENTS

## Step 1: Analyze and Break Down

I'll analyze the request to identify 3-5 discrete, parallelizable components. For each component, I'll consider:
- What can be done independently vs. sequentially
- Which specialist droid is best (droidz-codegen, droidz-test, droidz-refactor, droidz-integration, droidz-infra)
- Dependencies between tasks

## Step 2: Create Execution Plan

Using TodoWrite, I'll create a task list showing:
- Phase 1 tasks (can start immediately)
- Phase 2+ tasks (depend on earlier phases)
- Estimated time for each

## Step 3: Execute in Parallel

I'll use the Task tool to spawn specialist droids for each Phase 1 task simultaneously.

## Step 4: Monitor and Report

After spawning droids, progress will appear directly in this conversation:

╔══════════════════════════════════════════════════════════╗
║  ✅ Parallel Execution Started!                          ║
╚══════════════════════════════════════════════════════════╝

📊 LIVE PROGRESS TRACKING

Each droid reports progress every 60 seconds using TodoWrite:

**What You'll See:**
```
TODO LIST UPDATED

✅ Analyze codebase structure (completed)
⏳ Implement login API (creating endpoints...)
⏸ Write tests (pending)
⏸ Run test suite (pending)
```

**Progress Updates Include:**
  • Current step the droid is working on
  • What it's doing right now ("creating components...", "running tests...")
  • Files created/modified count
  • Test results as they complete

**Task Completion:**
```
TASK (droidz-codegen: 'Build API') ✅ Completed
- 5 files created
- All tests passing
- Ready for review
```

All updates stream directly to this conversation - no separate monitoring needed!

**Expected Timeline:** Each droid updates every 60 seconds during long operations.

Let me begin the analysis now...
