---
description: One-command orchestration - analyzes request and executes in parallel
argument-hint: "task description"
---

I need you to orchestrate this task using the Droidz parallel orchestration system:

**User Request:** $ARGUMENTS

Please use the `droidz-parallel` specialist droid to:

1. Analyze the request and break it into 3-7 discrete tasks
2. Generate a tasks.json file with dependencies
3. Use the dependency resolver to create an optimal execution plan
4. Execute tasks in parallel phases using the orchestrator

The droidz-parallel droid knows how to:
- Create proper task breakdowns with dependencies
- Assign the right specialist droids (codegen, test, refactor, integration, infra)
- Generate tasks.json in the correct format
- Execute `.factory/scripts/orchestrator.sh --tasks [file]`

Start the orchestration now and report progress.
