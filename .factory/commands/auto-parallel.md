---
description: Orchestrate tasks in parallel with automatic live monitoring
argument-hint: "task description"
---

I will orchestrate this task using parallel execution with live progress tracking.

**Task:** $ARGUMENTS

## Preflight Guardrails (No Phantom Tasks)

- Verify tools available: `Task`, `TodoWrite`, and required droids; if missing, **do not claim background start**—fall back to sequential and say why.
- Confirm at least 2 independent components; otherwise run sequential and note the decision.
- Capture workspace cleanliness constraints; if blocked (e.g., read-only, missing deps), report and switch to sequential.
- Only announce “parallel execution started” after Task calls succeed and you have task ids recorded.

## Step 1: Analyze and Break Down

I'll analyze the request to identify 3-5 discrete, parallelizable components. For each component, I'll consider:
- What can be done independently vs. sequentially
- Which specialist droid is best (codegen, test, refactor, integration, infra)
- Dependencies between tasks

If fewer than 2 viable parallel streams remain, **run sequential with an explicit note** (include reason).

## Step 2: Create Execution Plan

Using TodoWrite, I'll create a task list showing:
- Phase 1 tasks (can start immediately)
- Phase 2+ tasks (depend on earlier phases)
- Estimated time for each

## Step 3: Execute in Parallel

I'll use the Task tool to spawn specialist droids for each Phase 1 task simultaneously.

- Record each Task id/description in a local registry; update TodoWrite with these ids.
- If any Task spawn fails, retry once with backoff; on second failure, mark that stream blocked, continue others, and surface the failure reason.
- Do not claim a stream is running unless the Task call succeeded.

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

  • Current step and next action
  • Files created/modified count
  • Commands/tests run with pass/fail status (include failing test names)
  • Runtime/heartbeat (detect stalled >10m and mark stalled with reason)
  • Test results as they complete

**Task Completion:**
```
TASK (codegen: 'Build API') ✅ Completed
- 5 files created
- All tests passing
- Ready for review

If validation commands fail, do NOT mark completed; attach failing logs/output and keep status as blocked.
```

All updates stream directly to this conversation - no separate monitoring needed!

**Expected Timeline:** Each droid updates every 60 seconds during long operations.

Let me begin the analysis now...

## Headless / CI Usage (factory CLI)

- Run via `droid exec --auto high -f <prompt-file>` when you need non-interactive orchestration.
- Uses the user's currently selected model—no model switching is performed by Droidz.
- Ensure required tools (Task, TodoWrite, specialist droids) remain enabled; if disabled, parallel execution will fall back or block per preflight guardrails.
