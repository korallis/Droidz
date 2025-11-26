# Spec Implementation Process

Now that we have a spec and tasks list ready for implementation, we will proceed with implementation of this spec by following this multi-phase process:

PHASE 1: Determine which task group(s) from tasks.md should be implemented
PHASE 2: Delegate implementation to the implementer subagent
PHASE 3: After ALL task groups have been implemented, delegate to implementation-verifier to produce the final verification report.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Pre-Requisite: Detect Project Configuration

### Detect Package Manager

**IMPORTANT**: Before implementing any tasks, detect the project's package manager by checking for lockfiles. Use the detected package manager for ALL implementation commands.

**Detection Order** (first match wins):
1. `bun.lockb` → Use **bun** (`bun install`, `bun run`, `bunx`)
2. `pnpm-lock.yaml` → Use **pnpm** (`pnpm install`, `pnpm run`, `pnpm dlx`)
3. `yarn.lock` → Use **yarn** (`yarn install`, `yarn run`, `yarn dlx`)
4. `package-lock.json` → Use **npm** (`npm install`, `npm run`, `npx`)
5. No lockfile found → Default to **npm** but note that the user should verify their preferred package manager

**Command Mapping**:
| Action | npm | yarn | pnpm | bun |
|--------|-----|------|------|-----|
| Install deps | `npm install` | `yarn install` | `pnpm install` | `bun install` |
| Add package | `npm install <pkg>` | `yarn add <pkg>` | `pnpm add <pkg>` | `bun add <pkg>` |
| Run script | `npm run <script>` | `yarn <script>` | `pnpm <script>` | `bun run <script>` |
| Execute bin | `npx <cmd>` | `yarn dlx <cmd>` | `pnpm dlx <cmd>` | `bunx <cmd>` |

Store the detected package manager and use it when:
- Running tests, builds, or dev servers
- Installing new dependencies
- Executing CLI tools
- Generating any bash scripts

---

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

A) Parallel Execution (FAST) - Native Claude Code subagents
   └─ Spawns multiple Task tool agents simultaneously
   └─ Best for: Multi-group implementations
   └─ All agents work in parallel with isolated contexts
   └─ Progress tracked in tasks.md

B) Interactive with Live Progress - Using Task tool with TodoWrite
   └─ Runs task groups one at a time with real-time updates
   └─ Best for: Following along, learning, debugging
   └─ Live progress visible in this session

C) Sequential Delegation (SIMPLE) - Standard subagent delegation
   └─ Delegates to implementer agent one task group at a time
   └─ Best for: Single task group, simple implementations

Enter A, B, or C:
```

#### OPTION A: Parallel Execution with Claude Code Subagents

**How it works**: Uses Claude Code's native Task tool to spawn multiple parallel subagents. Each subagent operates in its own context and works on a separate task group simultaneously.

---

**Step 1: Determine Which Agent to Use**

Check for orchestration.yml and specialist availability:

1. **If `orchestration.yml` EXISTS**:
   - Read `assigned_specialist` for each task group
   - Check if each specialist exists in `.claude/agents/`
   - **If specialist exists** → Use that specialist
   - **If specialist MISSING** → Fall back to `implementer` agent

2. **If `orchestration.yml` does NOT exist**:
   - Use the `implementer` agent for all task groups
   - Or use `general-purpose` subagent type

**Fallback Behavior** (when specialists don't exist):
```
ℹ️ Specialist "[name]" not found in .claude/agents/
   Using "implementer" agent instead.
```

This is NOT an error - implementation proceeds with available agents.

---

**Step 2: Build prompts for each task group**

For EACH task group, prepare a prompt that includes:
- The specific task group content from tasks.md
- Path to spec: `droidz/specs/[this-spec]/spec.md`
- Path to requirements: `droidz/specs/[this-spec]/planning/requirements.md`
- Path to visuals: `droidz/specs/[this-spec]/planning/visuals/` (if exists)
- Standards resolved from orchestration.yml (see "Building the Standards File List" below)
- Instructions to mark tasks complete with `[x]` in tasks.md when done

---

**Step 3: CRITICAL - Spawn ALL agents in a SINGLE message**

Use the Task tool multiple times in ONE response to launch parallel subagents.

For EACH task group, use the agent determined in Step 2:

```
Task tool call for each task group:
- subagent_type: "general-purpose" (Claude Code's built-in agent type)
- description: "Implement [task-group-name]"
- prompt: Include the specialist context + full implementation prompt
```

**Example A** (with orchestration.yml and existing specialists):
```yaml
# orchestration.yml shows:
task_groups:
  - name: authentication-system
    assigned_specialist: backend-specialist  # exists in .claude/agents/
  - name: user-dashboard
    assigned_specialist: frontend-specialist  # exists in .claude/agents/
```

```
[Single message with 2 Task tool invocations:]

Task 1: description="Implement authentication-system"
        prompt="You are acting as the backend-specialist.
                [Include backend-specialist's system prompt from .claude/agents/backend-specialist.md]

                [Full implementation prompt for auth-system]"

Task 2: description="Implement user-dashboard"
        prompt="You are acting as the frontend-specialist.
                [Include frontend-specialist's system prompt from .claude/agents/frontend-specialist.md]

                [Full implementation prompt for user-dashboard]"
```

**Example B** (without orchestration.yml or missing specialists - using implementer):
```
[Single message with N Task tool invocations:]

Task 1: description="Implement task-group-1"
        prompt="You are the implementer agent.
                [Full implementation prompt for task-group-1]"

Task 2: description="Implement task-group-2"
        prompt="You are the implementer agent.
                [Full implementation prompt for task-group-2]"

Task N: description="Implement task-group-N"
        prompt="..."
```

---

**Step 4: Prompt Template for Each Agent**

Each prompt to a specialist should include:

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

## Standards Compliance

IMPORTANT: Follow these standards from orchestration.yml:

[resolved-standards-list]

## Completion

When done, report:
- Which tasks were completed
- Any issues encountered
- Tests that were run
```

---

**Building the Standards File List**

Resolve standards from orchestration.yml to actual file paths:

1. **"all"** → Include all files from `droidz/standards/global/`, `frontend/`, `backend/`, `infrastructure/`
2. **"global/*"** → Include all `.md` files from `droidz/standards/global/`
3. **"frontend/components.md"** → Include `droidz/standards/frontend/components.md`
4. **"none" or missing** → No standards for this task group

Format as:
```
- @droidz/standards/global/coding-principles.md
- @droidz/standards/frontend/components.md
```

---

**Step 5: Show completion summary**

After ALL parallel specialists complete, show:
```
✅ Parallel implementation complete!

SPECIALISTS INVOKED: [N]

RESULTS:
├── backend-specialist (authentication-system): [status/summary]
├── frontend-specialist (user-dashboard): [status/summary]
└── backend-specialist (api-endpoints): [status/summary]

📝 Check tasks.md for completed items
```

---

**KEY PRINCIPLE**: All Task tool calls MUST be in a single message to achieve true parallelism. If you call them in separate messages, they will run sequentially.

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
