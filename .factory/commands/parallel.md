---
description: Execute tasks in parallel with automatic progress monitoring
argument-hint: "task description"
---

Orchestrate this task using parallel execution with live progress tracking:

**Task:** $ARGUMENTS

## Execution Plan

1. **Analyze & Break Down:**
   - Identify 3-5 independent, parallelizable components
   - Determine which specialist droid fits each component (codegen, test, refactor, integration, infra, generalist)
   - Map dependencies between tasks
   - If fewer than 2 parallel streams possible, fall back to sequential

2. **Create Task List:**
   - Use TodoWrite to show Phase 1 (parallel), Phase 2+ (dependent), and estimated times
   - List which droid handles each task

3. **Execute:**
   - Use Task tool to spawn specialist droids for Phase 1 simultaneously
   - Record task IDs in TodoWrite
   - Each droid reports progress every 60 seconds via TodoWrite

4. **Monitor:**
   - Display live progress updates from all droids
   - Show files created/modified, tests passing/failing
   - Report completion status for each component

## Progress Format

```
TODO LIST UPDATED

✅ Database schema (completed - 3 files)
⏳ API endpoints (creating routes...)  
⏸ Tests (pending Phase 2)
⏸ Documentation (pending Phase 2)
```

## Completion Criteria

- All tasks completed successfully
- Tests passing
- No merge conflicts
- Summary of changes ready for review

Begin analysis and execution now.
