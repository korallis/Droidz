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

**NOTE**: Factory AI runs droids sequentially. For parallel execution, use `/orchestrate-tasks` to generate prompts that you can queue together.

Check if `orchestration.yml` exists in `droidz/specs/[this-spec]/`:

**IF orchestration.yml EXISTS** (user ran /orchestrate-tasks):

Ask the user:
```
I found orchestration.yml with assigned specialists for each task group.

Would you like me to:
A) Generate all implementation prompts so you can queue them for parallel execution
B) Delegate to each specialist sequentially (one at a time)

Enter A or B:
```

- **If user chooses A**: Go to "Generate Implementation Prompts" section below
- **If user chooses B**: Continue with sequential delegation below

**IF orchestration.yml DOES NOT EXIST**:

Delegate to the **implementer** droid to implement the specified task group(s) **one at a time**:

For EACH task group specified:

1. Delegate to the **implementer** droid with:
   - The specific task group from `droidz/specs/[this-spec]/tasks.md` including parent task, all sub-tasks, and sub-bullet points
   - The path to this spec's documentation: `droidz/specs/[this-spec]/spec.md`
   - The path to this spec's requirements: `droidz/specs/[this-spec]/planning/requirements.md`
   - The path to this spec's visuals (if any): `droidz/specs/[this-spec]/planning/visuals`

2. Instruct the droid to:
   - Analyze the provided spec.md, requirements.md, and visuals (if any)
   - Analyze patterns in the codebase
   - Implement the assigned task group according to requirements and standards
   - Update `droidz/specs/[this-spec]/tasks.md` to mark completed tasks with `- [x]`

3. Wait for completion before moving to next task group

**Generate Implementation Prompts** (for parallel execution):

If user chose option A or wants parallel execution:

1. Create directory: `droidz/specs/[this-spec]/implementation/prompts/`

2. For EACH task group in `tasks.md`, create a prompt file:
   - Filename: `[number]-[task-group-name].md`
   - Content:
   ```markdown
   # Implementation: [Task Group Name]
   
   ## Task Group from tasks.md
   
   [Paste the complete task group including parent task and all sub-tasks]
   
   ## Context
   
   Read these files for context:
   - @droidz/specs/[this-spec]/spec.md
   - @droidz/specs/[this-spec]/planning/requirements.md
   - @droidz/specs/[this-spec]/planning/visuals (if exists)
   
   ## Instructions
   
   1. Analyze the spec, requirements, and visuals
   2. Analyze existing codebase patterns
   3. Implement the task group following project standards
   4. Mark tasks complete with `- [x]` in @droidz/specs/[this-spec]/tasks.md
   
   ## Standards
   
   Follow these standards:
   [List standards from orchestration.yml if available, otherwise: @droidz/standards/*]
   ```

3. Output to user:
   ```
   ✅ Created [N] implementation prompts in:
   droidz/specs/[this-spec]/implementation/prompts/
   
   FILES:
   - 1-[name].md
   - 2-[name].md
   - 3-[name].md
   ...
   
   To execute in parallel:
   1. Copy each prompt file contents
   2. Start [N] separate droid sessions
   3. Paste one prompt into each session
   4. All task groups will implement simultaneously!
   
   Progress tracking: All droids update the same tasks.md file
   ```

### PHASE 3: Produce the final verification report

IF ALL task groups in tasks.md are marked complete with `- [x]`, then proceed with this step.  Otherwise, return to PHASE 1.

Assuming all tasks are marked complete, then delegate to the **implementation-verifier** subagent to do its implementation verification and produce its final verification report.

Provide to the subagent the following:
- The path to this spec: `droidz/specs/[this-spec]`
Instruct the subagent to do the following:
  1. Run all of its final verifications according to its built-in workflow
  2. Produce the final verification report in `droidz/specs/[this-spec]/verifications/final-verification.md`.
