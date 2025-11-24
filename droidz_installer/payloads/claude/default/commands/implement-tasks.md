# Spec Implementation Process

Now that we have a spec and tasks list ready for implementation, we will proceed with implementation of this spec by following this multi-phase process:

PHASE 1: Determine which task group(s) from tasks.md should be implemented
PHASE 2: Delegate implementation to the implementer subagent
PHASE 3: After ALL task groups have been implemented, delegate to implementation-verifier to produce the final verification report.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Determine which task group(s) to implement

First, check if the user has already provided instructions about which task group(s) to implement.

**If the user HAS provided instructions:** Proceed to PHASE 2 to delegate implementation of those specified task group(s) to the **implementer** subagent.

**If the user has NOT provided instructions:**

Read `droidz/specs/[this-spec]/tasks.md` to review the available task groups, then output the following message to the user and WAIT for their response:

```
Should we proceed with implementation of all task groups in tasks.md?

If not, then please specify which task(s) to implement.
```

### PHASE 2: Delegate implementation

Ask the user which execution mode they prefer:

```
How would you like to execute implementation?

A) Parallel Execution (FAST) - Using Droid Exec for concurrent processing
   └─ Runs all task groups simultaneously using headless mode
   └─ Best for: Multi-group implementations
   └─ Progress tracked in tasks.md

B) Interactive with Live Progress - Using Task tool with TodoWrite
   └─ Runs task groups one at a time with real-time updates
   └─ Best for: Following along, learning, debugging
   └─ Live progress visible in this session

C) Sequential Delegation (SIMPLE) - Standard subagent delegation
   └─ Delegates to implementer droid one task group at a time
   └─ Best for: Single task group, simple implementations

Enter A, B, or C:
```

#### OPTION A: Parallel Execution with Droid Exec

**Requirements**: Factory API key set as `FACTORY_API_KEY` environment variable

1. Create directory: `droidz/specs/[this-spec]/implementation/`

2. For EACH task group in `tasks.md`, create a prompt file:
   - Filename: `prompts/[number]-[task-group-name].md`
   - Content:
   ```markdown
   # Implementation: [Task Group Name]
   
   ## Task Assignment
   
   [Paste complete task group from tasks.md with parent task and all sub-tasks]
   
   ## Context Files
   
   Read these for requirements and patterns:
   - spec: droidz/specs/[this-spec]/spec.md
   - requirements: droidz/specs/[this-spec]/planning/requirements.md
   - visuals: droidz/specs/[this-spec]/planning/visuals/ (if exists)
   
   ## Instructions
   
   1. Read and analyze spec, requirements, visuals
   2. Study existing codebase patterns
   3. Implement the task group following project standards
   4. Run tests to verify implementation
   5. Mark tasks complete with [x] in droidz/specs/[this-spec]/tasks.md
   
   ## Standards
   
   [If orchestration.yml exists: List assigned specialist and standards]
   [Otherwise: Follow all standards in droidz/standards/]
   ```

3. Create execution script: `droidz/specs/[this-spec]/implementation/run-parallel.sh`
   ```bash
   #!/bin/bash
   # Parallel Implementation Execution
   # Uses Droid Exec with bounded concurrency
   
   set -e
   
   SPEC_DIR="droidz/specs/[this-spec]"
   PROMPTS_DIR="$SPEC_DIR/implementation/prompts"
   
   echo "🚀 Starting parallel implementation..."
   echo "📋 Processing [N] task groups concurrently"
   echo ""
   
   # Check for Factory API key
   if [ -z "$FACTORY_API_KEY" ]; then
     echo "❌ Error: FACTORY_API_KEY not set"
     echo "   Get your key: https://app.factory.ai/settings/api-keys"
     echo "   Then: export FACTORY_API_KEY=fk-..."
     exit 1
   fi
   
   # Run all prompts in parallel (max 4 concurrent)
   find "$PROMPTS_DIR" -name "*.md" -print0 | \
     xargs -0 -P 4 -I {} bash -c '
       echo "▶️  Starting: $(basename {})"
       droid exec --auto medium -f "{}" 2>&1 | \
         sed "s/^/[$(basename {})] /"
       echo "✅ Completed: $(basename {})"
     '
   
   echo ""
   echo "🎉 All task groups completed!"
   echo "📝 Check tasks.md for progress"
   ```

4. Make script executable and show instructions:
   ```
   ✅ Created parallel execution setup:
   
   PROMPTS:
   droidz/specs/[this-spec]/implementation/prompts/
   ├── 1-[name].md
   ├── 2-[name].md
   ├── 3-[name].md
   └── 4-[name].md
   
   SCRIPT:
   droidz/specs/[this-spec]/implementation/run-parallel.sh
   
   TO EXECUTE:
   1. Ensure Factory API key is set:
      export FACTORY_API_KEY=fk-...
   
   2. Run the script:
      bash droidz/specs/[this-spec]/implementation/run-parallel.sh
   
   3. Watch progress in real-time as all task groups execute concurrently!
   
   FEATURES:
   ✅ Bounded concurrency (max 4 simultaneous)
   ✅ All update same tasks.md file
   ✅ Robust error handling (if one fails, others continue)
   ✅ Real-time output from all executions
   ```

#### OPTION B: Interactive with Live Progress

Create a coordinator that uses TodoWrite for real-time progress tracking:

1. Create `droidz/specs/[this-spec]/implementation/coordinator-prompt.md`:
   ```markdown
   # Implementation Coordinator
   
   You are coordinating implementation of multiple task groups with live progress tracking.
   
   ## Task Groups
   
   [List all task groups from tasks.md]
   
   ## Your Workflow
   
   1. Use TodoWrite to create a todo list with all task groups
   2. For EACH task group:
      a. Update TodoWrite: mark task group as "in_progress"
      b. Read spec, requirements, visuals for context
      c. Analyze codebase patterns
      d. Implement the task group following standards
      e. Run tests to verify
      f. Update TodoWrite: mark task group as "completed"
      g. Mark tasks in droidz/specs/[this-spec]/tasks.md with [x]
   3. After ALL task groups: Report completion summary
   
   ## Context Files
   
   - spec: droidz/specs/[this-spec]/spec.md
   - requirements: droidz/specs/[this-spec]/planning/requirements.md
   - visuals: droidz/specs/[this-spec]/planning/visuals/
   - tasks: droidz/specs/[this-spec]/tasks.md
   
   ## Standards
   
   [List standards from orchestration.yml or droidz/standards/]
   
   ## Important
   
   Keep TodoWrite updated so user sees real-time progress!
   ```

2. Delegate to a custom droid with TodoWrite enabled:
   - Use Task tool to spawn a coordinator droid
   - Droid has access to: Read, Edit, Execute, TodoWrite, Grep, Glob
   - User sees live TodoWrite updates in this session

3. Show status:
   ```
   🎯 Starting interactive implementation with live progress...
   
   You'll see real-time updates as each task group progresses:
   - Task group marked "in_progress" when starting
   - Tool calls and results shown as they happen
   - Task group marked "completed" when done
   - tasks.md updated with [x] for completed tasks
   
   Watch below for live progress! ⬇️
   ```

#### OPTION C: Sequential Delegation

Standard sequential execution (existing behavior):

For EACH task group specified:

1. Delegate to the **implementer** subagent with:
   - The specific task group from `droidz/specs/[this-spec]/tasks.md`
   - Path to spec: `droidz/specs/[this-spec]/spec.md`
   - Path to requirements: `droidz/specs/[this-spec]/planning/requirements.md`
   - Path to visuals: `droidz/specs/[this-spec]/planning/visuals`

2. Instruct the subagent to:
   - Analyze spec, requirements, visuals
   - Study codebase patterns
   - Implement task group per standards
   - Update `tasks.md` marking completed tasks with `[x]`

3. Wait for completion, then proceed to next task group

### PHASE 3: Produce the final verification report

IF ALL task groups in tasks.md are marked complete with `- [x]`, then proceed with this step.  Otherwise, return to PHASE 1.

Assuming all tasks are marked complete, then delegate to the **implementation-verifier** subagent to do its implementation verification and produce its final verification report.

Provide to the subagent the following:
- The path to this spec: `droidz/specs/[this-spec]`
Instruct the subagent to do the following:
  1. Run all of its final verifications according to its built-in workflow
  2. Produce the final verification report in `droidz/specs/[this-spec]/verifications/final-verification.md`.
