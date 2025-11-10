# 🎯 Droidz → Factory-Native Multi-Agent Refactoring Spec

## Executive Summary

Transform Droidz from a **shell-based parallel orchestrator** into a **Factory-native multi-agent system** while preserving its core strengths: parallel execution, git worktrees, and Linear integration.

## Core Architecture Changes

### Current (Shell-Based)
```
orchestrator/run.ts → Direct droid exec spawn → Workers in parallel
```

### Target (Factory-Native)
```
Orchestrator Droid → Task tool delegation → Specialist Droids → Worktrees
```

## Key Principles (From Factory Docs)

1. **Task Tool is Primary Delegation**: Use `Task(subagent_type="specialist")` not direct exec
2. **Orchestrator Droid Coordinates**: Main droid fetches tickets, delegates, aggregates
3. **Specialist Droids Execute**: Each has limited tools, specific prompts
4. **TodoWrite for Progress**: Real-time task tracking visible to user
5. **Worktrees Stay**: Each Task invocation gets isolated workspace

## Implementation Plan

### Phase 1: Create Orchestrator Droid (Week 1)

**File**: `.factory/droids/droidz-orchestrator.md`

```markdown
---
name: droidz-orchestrator
description: Coordinates parallel Linear ticket execution with git worktrees
model: gpt-5-codex
tools: ["Execute", "Read", "TodoWrite", "FetchUrl"]
---

You are the Droidz Orchestrator. Execute this workflow:

## 1. Fetch Linear Tickets
- Use Execute to call: `bun orchestrator/linear-fetch.ts --project PROJECT --sprint SPRINT`
- Parse JSON output: `{issues: [{key, title, description, labels, deps}]}`

## 2. Plan Parallelization
- Analyze dependencies (blockedBy field)
- Create execution phases (sequential for deps, parallel within phase)
- Use TodoWrite to show plan

## 3. Delegate to Specialists
For each ticket, determine specialist from labels:
- `frontend`, `ui` → droidz-codegen-frontend
- `backend`, `api` → droidz-codegen-backend
- `test`, `qa` → droidz-test
- `infra`, `ci` → droidz-infra
- `refactor` → droidz-refactor
- `integration` → droidz-integration

Call Task tool:
```typescript
Task(
  subagent_type="droidz-codegen-frontend",
  description="Implement PROJ-123: Login Form",
  prompt=`
Linear Ticket: PROJ-123
Title: ${task.title}
Description: ${task.description}
Branch: ${task.branch}
Workspace: ${task.workspaceDir}

## Your Responsibilities:
1. Set Linear issue to "In Progress"
2. Work in the pre-configured git worktree at ${task.workspaceDir}
3. Implement feature following acceptance criteria
4. Run tests (bun test)
5. Commit changes
6. Push branch and create PR (gh pr create --fill)
7. Update Linear with PR link
8. Mark task complete in TodoWrite
  `
)
```

## 4. Monitor Progress
- Update TodoWrite as specialists complete tasks
- Track: pending → in_progress → completed
- Show PR links and Linear status

## 5. Report Summary
When all tasks complete:
- List completed tasks with PR URLs
- Highlight any failures
- Suggest next steps
```

### Phase 2: Update Specialist Droids (Week 1-2)

**Example**: `.factory/droids/droidz-codegen-frontend.md`

```markdown
---
name: droidz-codegen-frontend
description: Implements frontend features in pre-configured git worktree
model: gpt-5-codex
tools: ["Read", "Edit", "Create", "Execute", "Grep"]
---

You are the Frontend Codegen Specialist.

## Context
You receive: Linear ticket key, workspace directory (git worktree), branch name

## Workflow
1. **Verify workspace**: Check you're in the worktree directory
2. **Set Linear status**: 
   ```bash
   LINEAR_API_KEY=${LINEAR_API_KEY} bun orchestrator/linear-update.ts \
     --issue ${TICKET_KEY} --status "In Progress"
   ```
3. **Implement feature**: 
   - Use Read to understand codebase
   - Use Create/Edit for new/existing files
   - Follow React/TypeScript best practices
4. **Test**: `bun test` (must pass)
5. **Lint**: `bun run lint` (if available)
6. **Commit**: 
   ```bash
   git add -A
   git commit -m "${TICKET_KEY}: ${TITLE}"
   ```
7. **Push & PR**:
   ```bash
   git push -u origin ${BRANCH}
   gh pr create --fill --head ${BRANCH}
   ```
8. **Update Linear**: Post PR URL as comment
9. **Return JSON**:
   ```json
   {
     "status": "completed",
     "ticket": "PROJ-123",
     "branch": "feature/login",
     "prUrl": "https://github.com/org/repo/pull/45",
     "testsPass": true
   }
   ```

## Tool Restrictions
- NO direct Linear API calls (use helper scripts)
- NO modifying other worktrees
- MUST work in assigned workspace only
```

### Phase 3: Helper Scripts (Week 2)

**New Files**:

1. `orchestrator/linear-fetch.ts` - Fetch tickets as JSON
2. `orchestrator/linear-update.ts` - Update ticket status
3. `orchestrator/worktree-setup.ts` - Prepare workspace
4. `orchestrator/task-coordinator.ts` - NEW entry point

**Example**: `orchestrator/task-coordinator.ts`

```typescript
#!/usr/bin/env bun
/**
 * NEW: Task Tool Coordinator
 * Bridges orchestrator droid → Task tool → specialist droids → worktrees
 */

import { prepareWorkspace } from "./worktree-setup";
import { loadConfig } from "./config-loader";

interface TaskRequest {
  ticket: LinearTicket;
  specialist: string;
  config: OrchestratorConfig;
}

async function main() {
  const request: TaskRequest = JSON.parse(process.argv[2]);
  const { ticket, specialist, config } = request;
  
  // Prepare isolated workspace (git worktree)
  const workspace = await prepareWorkspace(
    config.workspace.baseDir,
    ticket.branch,
    ticket.key,
    config.workspace.mode || "worktree"
  );
  
  // Output for orchestrator droid
  const result = {
    workspace: workspace.workDir,
    branch: ticket.branch,
    specialist: `droidz-${specialist}`,
    ticket: ticket.key,
    title: ticket.title,
    description: ticket.description,
    ready: true
  };
  
  console.log(JSON.stringify(result, null, 2));
}

main();
```

### Phase 4: Migration Path (Week 2-3)

**Backward Compatibility**:

1. Keep existing `orchestrator/run.ts` (old system)
2. Add new `orchestrator/run-v2.ts` (Factory native)
3. Add flag to `launch.ts`: `--mode=v1|v2`

**Usage**:

```bash
# Old way (still works)
bun orchestrator/launch.ts

# New way (Factory native)
bun orchestrator/launch.ts --mode=v2

# Or invoke orchestrator droid directly
droid --auto high
> "Use droidz-orchestrator to process project MyProject sprint Sprint-1"
```

### Phase 5: Real-Time Progress (Week 3)

**TodoWrite Integration**:

Orchestrator droid creates todos:

```typescript
TodoWrite({
  todos: [
    {id: "PROJ-1", content: "Login Form (frontend)", status: "in_progress", priority: "high"},
    {id: "PROJ-2", content: "Auth API (backend)", status: "in_progress", priority: "high"},
    {id: "PROJ-3", content: "Login Tests (test)", status: "pending", priority: "medium"},
    {id: "PROJ-4", content: "CI Pipeline (infra)", status: "pending", priority: "low"}
  ]
});
```

Specialists update on completion.

## File Structure

```
.factory/droids/
├── droidz-orchestrator.md          # NEW: Main coordinator
├── droidz-codegen-frontend.md       # UPDATED: Frontend specialist
├── droidz-codegen-backend.md        # UPDATED: Backend specialist  
├── droidz-test.md                   # UPDATED: Test specialist
├── droidz-infra.md                  # UPDATED: Infra specialist
├── droidz-refactor.md               # UPDATED: Refactor specialist
└── droidz-integration.md            # UPDATED: Integration specialist

orchestrator/
├── run.ts                           # KEEP: v1 (shell-based)
├── run-v2.ts                        # NEW: v2 (Factory native)
├── task-coordinator.ts              # NEW: Bridge script
├── linear-fetch.ts                  # NEW: Linear helper
├── linear-update.ts                 # NEW: Linear helper  
├── worktree-setup.ts                # REFACTOR: Extract from workers.ts
├── config-loader.ts                 # NEW: Shared config
└── [existing files remain]
```

## Benefits

✅ **Factory-Native**: Uses Task tool, custom droids, TodoWrite  
✅ **Parallel Execution**: Task tool can spawn multiple specialists  
✅ **Git Worktrees**: Each specialist gets isolated workspace  
✅ **LLM-Driven**: Orchestrator decides routing (can override labels)  
✅ **Real-Time Progress**: TodoWrite shows active workers  
✅ **Tool Restrictions**: Specialists can't access wrong workspaces  
✅ **Context Isolation**: Each specialist has fresh context  
✅ **Linear Integration**: Maintained via helper scripts  
✅ **Backward Compatible**: v1 still works during migration

## Testing Strategy

1. **Unit**: Test helper scripts independently
2. **Integration**: Test orchestrator droid with 1 ticket
3. **Parallel**: Test orchestrator with 5 tickets (different specialists)
4. **Stress**: Test with 10+ tickets in parallel
5. **Comparison**: Run same sprint with v1 and v2, compare results

## Rollout Plan

**Week 1**: Orchestrator droid + helper scripts  
**Week 2**: Update all specialist droids  
**Week 3**: Integration testing + TodoWrite  
**Week 4**: Production testing with v2 flag  
**Week 5**: Deprecate v1, v2 becomes default

## Success Metrics

- ✅ Orchestrator can fetch 20+ Linear tickets
- ✅ Task tool delegates to correct specialist 100% accuracy
- ✅ Git worktrees created/cleaned properly
- ✅ PRs created with correct Linear references
- ✅ TodoWrite updates visible in real-time
- ✅ v2 performance ≥ v1 speed (parallel execution maintained)

---

**Ready to implement?** This spec maintains everything that works (worktrees, parallelization, Linear) while becoming Factory-native (Task tool, custom droids, LLM decisions).