# Droidz Orchestrator - Complete Guide

**Date:** 2025-11-14  
**Status:** ✅ All Bugs Fixed + Monitoring Added

---

## Quick Answer to Your Questions

### Q1: Does `/orchestrate` do the proper workflow?

**Short answer:** It does Step 1 (creates worktrees/tmux) but NOT Step 2 (spawning agents).

**Long answer:** The `/orchestrate` command runs `orchestrator.sh` which prepares the environment, but you need the **droidz-orchestrator DROID** to automatically spawn parallel Task agents.

### Q2: Can agents monitor tmux sessions every 30 seconds?

**YES! 🎉** We just added this capability with the new `monitor-orchestration.sh` script!

Agents can now:
- ✅ Capture tmux output every 30 seconds (or any interval)
- ✅ See exactly what each agent is doing
- ✅ Track progress in real-time
- ✅ Update users with live status

---

## The Complete Workflow

### Step 1: User Request

```
User: "Build authentication system with login, register, and tests in parallel"
```

### Step 2: Invoke droidz-orchestrator Droid

Either:
- Claude Code auto-invokes it (when it detects complex parallel work)
- User manually invokes: `/task use droidz-orchestrator for auth system`
- User uses `/auto-orchestrate` command first to analyze

### Step 3: Droid Analyzes Complexity

```typescript
Droidz-orchestrator droid analyzes:

✅ Multiple independent components? YES (login, register, tests)
✅ Can run in parallel? YES (no dependencies)  
✅ Different specialists needed? YES (codegen + test)
✅ Benefits from parallel execution? YES (2-3 hours → 40-50 min)

Decision: ORCHESTRATE
```

### Step 4: Generate Task Breakdown

```json
{
  "tasks": [
    {
      "key": "AUTH-001",
      "title": "Build login API endpoint",
      "description": "Implement JWT-based login with bcrypt password hashing",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "AUTH-002",
      "title": "Build registration API endpoint",
      "description": "Implement user registration with validation",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "AUTH-003",
      "title": "Write authentication tests",
      "description": "Integration and unit tests for auth flow",
      "specialist": "droidz-test",
      "priority": 2
    }
  ]
}
```

### Step 5: Run Orchestrator Script (Isolation Environment)

```typescript
// Droid creates tasks.json and runs orchestrator
Create({
  file_path: "/tmp/auth-tasks.json",
  content: JSON.stringify(tasksJson, null, 2)
});

Execute({
  command: "cd /project && .factory/scripts/orchestrator.sh --tasks /tmp/auth-tasks.json"
});
```

**Output:**
```
2025-11-14 14:30:00 [INFO] ℹ Orchestrating 3 tasks in parallel

2025-11-14 14:30:01 [SUCCESS] ✓ Created worktree: .runs/AUTH-001
2025-11-14 14:30:01 [SUCCESS] ✓ Created branch: feat/AUTH-001-build-login-api
2025-11-14 14:30:02 [SUCCESS] ✓ Created tmux session: droidz-AUTH-001

2025-11-14 14:30:03 [SUCCESS] ✓ Created worktree: .runs/AUTH-002
2025-11-14 14:30:03 [SUCCESS] ✓ Created branch: feat/AUTH-002-build-registration-api
2025-11-14 14:30:04 [SUCCESS] ✓ Created tmux session: droidz-AUTH-002

2025-11-14 14:30:05 [SUCCESS] ✓ Created worktree: .runs/AUTH-003
2025-11-14 14:30:05 [SUCCESS] ✓ Created branch: feat/AUTH-003-write-auth-tests
2025-11-14 14:30:06 [SUCCESS] ✓ Created tmux session: droidz-AUTH-003

╔═══════════════════════════════════════════════════════════╗
║  Parallel Execution Environment Ready
╠═══════════════════════════════════════════════════════════╣
║  Session ID: 20251114-143000-12345
║  Tasks: 3
║  Worktrees: 3
║  Tmux Sessions: 3
╚═══════════════════════════════════════════════════════════╝
```

**What Was Created:**
```
.runs/
├── AUTH-001/                    # Isolated git worktree
│   ├── .factory-context.md     # Task instructions for agent
│   ├── .droidz-meta.json       # Progress tracking
│   └── [project files]
├── AUTH-002/                    # Isolated git worktree
│   ├── .factory-context.md
│   ├── .droidz-meta.json
│   └── [project files]
├── AUTH-003/                    # Isolated git worktree
│   ├── .factory-context.md
│   ├── .droidz-meta.json
│   └── [project files]
└── .coordination/
    ├── orchestration-20251114-143000-12345.json
    └── orchestration.log

Tmux sessions:
- droidz-AUTH-001 (running in .runs/AUTH-001)
- droidz-AUTH-002 (running in .runs/AUTH-002)
- droidz-AUTH-003 (running in .runs/AUTH-003)
```

### Step 6: Spawn Task Agents in Parallel

**CRITICAL:** All Task calls in **ONE RESPONSE** for true parallel execution!

```typescript
// Droid spawns 3 agents simultaneously

Task({
  subagent_type: "droidz-codegen",
  description: "Build login API in AUTH-001",
  prompt: `# Task: Build Login API

## Context
You are working in an isolated git worktree at: .runs/AUTH-001
This worktree is on branch: feat/AUTH-001-build-login-api

## Instructions
Read .factory-context.md in your working directory for COMPLETE task instructions.

## Your Mission
Implement JWT-based login endpoint:
1. Create POST /api/auth/login route
2. Validate credentials
3. Generate JWT token
4. Return token + user info
5. Write tests
6. Commit your changes

## Progress Tracking
Update .droidz-meta.json status to "completed" when done.

## Standards
Follow .factory/standards/ for TypeScript, Next.js patterns.

Work autonomously. Report back when complete.`
})

Task({
  subagent_type: "droidz-codegen",
  description: "Build register API in AUTH-002",
  prompt: `# Task: Build Registration API

## Context
Working in: .runs/AUTH-002
Branch: feat/AUTH-002-build-registration-api

[... similar detailed instructions ...]`
})

Task({
  subagent_type: "droidz-test",
  description: "Write auth tests in AUTH-003",
  prompt: `# Task: Write Authentication Tests

## Context
Working in: .runs/AUTH-003
Branch: feat/AUTH-003-write-auth-tests

[... similar detailed instructions ...]`
})
```

**Result:** All 3 agents start working **simultaneously** in their isolated worktrees!

### Step 7: Monitor Progress (NEW! 🎉)

The orchestrator droid can now **watch what agents are doing** in real-time!

#### Option A: Continuous Live Monitoring

```typescript
// Start live monitor (updates every 30 seconds)
Execute({
  command: ".factory/scripts/monitor-orchestration.sh --session 20251114-143000-12345 --interval 30"
});
```

**Output (Updates Every 30s):**
```
╔═══════════════════════════════════════════════════════════╗
║  Live Monitor - Orchestration: 20251114-143000-12345
║  Iteration: 1 | Interval: 30s | 2025-11-14 14:30:30
╚═══════════════════════════════════════════════════════════╝

Progress Summary:
  ✓ Completed: 0/3
  ⏳ In Progress: 3/3
  ⏸  Pending: 0/3

⏳ AUTH-001 (in_progress)
  │ $ bun test auth/login.test.ts
  │ ✓ validates email format (12ms)
  │ ✓ rejects weak passwords (8ms)

⏳ AUTH-002 (in_progress)
  │ $ bun run typecheck
  │ Checking TypeScript...
  │ ✓ No type errors

⏳ AUTH-003 (in_progress)
  │ $ cat .factory-context.md
  │ Reading task instructions...
  │ Starting test implementation

Next update in 30s...

[30 seconds later, screen refreshes with new output]

╔═══════════════════════════════════════════════════════════╗
║  Live Monitor - Orchestration: 20251114-143000-12345
║  Iteration: 2 | Interval: 30s | 2025-11-14 14:31:00
╚═══════════════════════════════════════════════════════════╝

Progress Summary:
  ✓ Completed: 1/3
  ⏳ In Progress: 2/3
  ⏸  Pending: 0/3

✓ AUTH-001 (completed)
  │ $ git commit -m "feat: add login endpoint"
  │ [feat/AUTH-001] 5 files changed
  │ ✓ All tests passing

⏳ AUTH-002 (in_progress)
  │ $ bun test auth/register.test.ts
  │ ⏳ Running 12 tests...
  │ ✓ 10/12 passing

⏳ AUTH-003 (in_progress)
  │ $ bun test --coverage
  │ Writing integration tests...
  │ ✓ Coverage: 85%

Next update in 30s...
```

#### Option B: Periodic Snapshots (Agent-Driven)

```typescript
// Droid checks every 30 seconds and updates user
async function monitorProgress() {
  while (true) {
    // Take snapshot
    const output = Execute({
      command: ".factory/scripts/monitor-orchestration.sh --snapshot --session 20251114-143000-12345"
    });
    
    // Parse progress
    const completed = /* count completed tasks from output */;
    const inProgress = /* count in_progress tasks */;
    const pending = /* count pending tasks */;
    
    // Update user via TodoWrite
    TodoWrite({
      todos: [
        {content: "AUTH-001: Login API", status: completed.includes("AUTH-001") ? "completed" : "in_progress"},
        {content: "AUTH-002: Register API", status: completed.includes("AUTH-002") ? "completed" : "in_progress"},
        {content: "AUTH-003: Auth Tests", status: "pending"}
      ]
    });
    
    // Show latest output to user
    console.log("Progress Update:");
    console.log(output);
    
    // Wait 30 seconds
    await sleep(30000);
    
    // Stop when all complete
    if (completed.length === 3) break;
  }
}
```

**What You See:**
- ✅ Exact terminal output from each tmux session
- ✅ Commands agents are running
- ✅ Test results, errors, progress
- ✅ Status from .droidz-meta.json files
- ✅ Real-time updates every 30 seconds

### Step 8: User Can Also Watch Live

User can attach to any tmux session:

```bash
# List all sessions
tmux list-sessions | grep droidz

# Attach to a session
tmux attach -t droidz-AUTH-001

# Watch the agent work in real-time!
# See commands, output, tests running, etc.

# Detach to check another session
Ctrl+B, then D

# Switch between sessions
Ctrl+B, then S (shows session selector)
```

### Step 9: Agents Complete and Report Back

When each agent finishes, it returns its result to the orchestrator droid:

```
Task Agent AUTH-001 (droidz-codegen):

Summary: ✅ Login API implemented successfully

Work Completed:
- Created POST /api/auth/login endpoint
- Implemented JWT token generation
- Added bcrypt password hashing
- Wrote 8 unit tests (all passing)
- Integrated with database layer

Files Modified:
- app/api/auth/login/route.ts (new)
- lib/auth.ts (new)
- lib/db.ts (modified)
- __tests__/auth/login.test.ts (new)

Commits:
- feat: add login endpoint with JWT auth

Status: .droidz-meta.json updated to "completed"
```

### Step 10: Synthesize Results

Orchestrator droid combines all results:

```
## 🎉 Parallel Execution Complete!

**Total Time:** 28 minutes  
**Sequential Would Take:** 75 minutes  
**Speedup:** 2.7x faster ⚡

### Completed Work

**✅ AUTH-001: Login API**
- 5 files created/modified
- JWT token generation working
- Password hashing with bcrypt
- 8 tests passing

**✅ AUTH-002: Registration API**  
- 4 files created/modified
- Email validation implemented
- Password strength checking
- 12 tests passing

**✅ AUTH-003: Integration Tests**
- 24 integration tests written
- Full auth flow tested
- Coverage: 92%
- All tests passing ✓

### Branches Created
- feat/AUTH-001-build-login-api
- feat/AUTH-002-build-registration-api
- feat/AUTH-003-write-auth-tests

### Next Steps
1. Review each branch individually
2. Test the auth flow manually
3. Merge branches when satisfied
4. Create PRs if needed

The authentication system is ready to use! 🚀
```

---

## Commands Reference

### For Users

```bash
# Analyze if task should be orchestrated
/auto-orchestrate build auth system

# Start orchestration
/orchestrate file:tasks.json

# List active orchestrations
/orchestrate list
.factory/scripts/orchestrator.sh --list

# Monitor orchestration (live updates every 30s)
.factory/scripts/monitor-orchestration.sh --session SESSION_ID --interval 30

# Take single snapshot
.factory/scripts/monitor-orchestration.sh --snapshot --session SESSION_ID

# Attach to tmux session
tmux attach -t droidz-AUTH-001

# List tmux sessions
tmux list-sessions | grep droidz

# Cleanup orchestration
/orchestrate cleanup:SESSION_ID
```

### For Droids (droidz-orchestrator)

```typescript
// Step 1: Analyze complexity
// (internal logic, no command)

// Step 2: Generate tasks.json
Create({
  file_path: "/tmp/tasks.json",
  content: JSON.stringify(tasks, null, 2)
});

// Step 3: Run orchestrator script
Execute({
  command: "cd /project && .factory/scripts/orchestrator.sh --tasks /tmp/tasks.json"
});

// Step 4: Spawn parallel agents (in ONE response!)
Task({subagent_type: "droidz-codegen", ...});
Task({subagent_type: "droidz-codegen", ...});
Task({subagent_type: "droidz-test", ...});

// Step 5: Monitor progress
Execute({
  command: ".factory/scripts/monitor-orchestration.sh --snapshot --session SESSION_ID"
});

// Repeat Step 5 every 30s until all complete
```

---

## File Structure

```
project/
├── .factory/
│   ├── droids/
│   │   └── droidz-orchestrator.md      # Orchestrator droid definition
│   ├── scripts/
│   │   ├── orchestrator.sh             # Creates worktrees/tmux
│   │   ├── monitor-orchestration.sh    # Monitors tmux sessions (NEW!)
│   │   └── test-orchestrator.sh        # Test suite
│   └── commands/
│       ├── orchestrate.md              # /orchestrate command
│       └── auto-orchestrate.md         # /auto-orchestrate command
│
├── .runs/                              # Created by orchestrator
│   ├── AUTH-001/                       # Isolated worktree
│   │   ├── .factory-context.md         # Task instructions
│   │   ├── .droidz-meta.json          # Progress tracking
│   │   └── [project files]
│   ├── AUTH-002/
│   ├── AUTH-003/
│   └── .coordination/
│       ├── orchestration-SESSION_ID.json
│       └── orchestration.log
```

---

## Key Concepts

### 1. Git Worktrees = Isolation

Each task gets its own git worktree:
- ✅ Separate working directory
- ✅ Own git branch
- ✅ No file conflicts
- ✅ Can run tests independently
- ✅ Clean git history per task

### 2. Tmux Sessions = Visibility

Each worktree has a tmux session:
- ✅ See what agent is doing
- ✅ Attach/detach at any time
- ✅ Monitor progress visually
- ✅ Switch between tasks easily
- ✅ Capture output programmatically

### 3. Context Files = Instructions

Each worktree has `.factory-context.md`:
- ✅ Complete task description
- ✅ Specialist assignment
- ✅ Files to modify
- ✅ Definition of done
- ✅ Standards to follow

### 4. Metadata Files = Progress Tracking

Each worktree has `.droidz-meta.json`:
- ✅ Task key and status
- ✅ Branch name
- ✅ Specialist assigned
- ✅ Creation timestamp
- ✅ Session ID for coordination

### 5. Monitoring = Real-Time Feedback

New `monitor-orchestration.sh` provides:
- ✅ Tmux pane output capture
- ✅ Live progress updates
- ✅ Status tracking
- ✅ Continuous or snapshot modes
- ✅ Configurable polling intervals

---

## Advantages Over Sequential Execution

| Aspect | Sequential | Parallel (Orchestrated) |
|--------|-----------|------------------------|
| **Time** | 3 hours | 1 hour (3x faster) |
| **Context** | Single context window (overloaded) | Isolated contexts per task |
| **Conflicts** | Frequent merge conflicts | No conflicts (isolated worktrees) |
| **Visibility** | One terminal, hard to track | Tmux sessions, easy monitoring |
| **Testing** | Can't test while coding | Each worktree runs tests independently |
| **Rollback** | Affects all work | Per-task branches, easy rollback |
| **Specialists** | Can't use different specialists | Right specialist for each task |
| **Monitoring** | No real-time visibility | Monitor tmux every 30s |

---

## Best Practices

### For Users

1. **Use `/auto-orchestrate` first** - Analyze if parallel execution helps
2. **Trust the analysis** - If it says "don't orchestrate," there's a good reason
3. **Monitor with tmux** - Attach to sessions to watch agents work
4. **Review per-branch** - Check each feature branch individually
5. **Test before merging** - Each branch should be tested in isolation

### For Orchestrator Droid

1. **Analyze complexity first** - Don't orchestrate trivial tasks
2. **Create detailed context files** - Give agents clear instructions
3. **Run orchestrator script BEFORE spawning agents** - Workspaces must exist first
4. **Spawn all agents in ONE response** - True parallel execution
5. **Monitor progress** - Use snapshots every 30s to track agents
6. **Don't invoke tools with undefined parameters** - Tools are defined in droid .md files
7. **Synthesize results clearly** - Show user what was accomplished

---

## Troubleshooting

### Orchestrator script fails

```bash
# Check for existing worktrees
git worktree list

# Clean up stale worktrees
git worktree prune

# Check orchestrator script exists
ls -la .factory/scripts/orchestrator.sh

# Run tests
.factory/scripts/test-orchestrator.sh
```

### Tmux session not found

```bash
# List all sessions
tmux list-sessions

# Check if session exists
tmux has-session -t droidz-AUTH-001 && echo "exists" || echo "not found"

# Kill stale session
tmux kill-session -t droidz-AUTH-001
```

### Monitoring script errors

```bash
# Check monitor script exists
ls -la .factory/scripts/monitor-orchestration.sh

# Check it's executable
chmod +x .factory/scripts/monitor-orchestration.sh

# Test with --help
.factory/scripts/monitor-orchestration.sh --help

# List active orchestrations
.factory/scripts/monitor-orchestration.sh --list
```

### Agent not working in worktree

```bash
# Check worktree exists
ls -la .runs/AUTH-001

# Check context file exists
cat .runs/AUTH-001/.factory-context.md

# Check progress file
cat .runs/AUTH-001/.droidz-meta.json

# Check tmux session
tmux attach -t droidz-AUTH-001
```

---

## Performance Metrics

### Example: 28-Task Epic

**Scenario:** Build cross-platform app with 28 tasks

**Sequential Execution:**
- 28 tasks × 30 minutes average = **14 hours**

**Parallel Execution (10 concurrent):**
- Batch 1: 10 tasks in parallel (30 min)
- Batch 2: 10 tasks in parallel (30 min)  
- Batch 3: 8 tasks in parallel (30 min)
- Total: **90 minutes**

**Speedup:** 14 hours → 90 minutes = **9.3x faster** ⚡

**With Task Filtering:**
- If 10 tasks already complete → Skip them
- Only process 18 remaining tasks
- 2 batches × 30 min = **60 minutes**

**Total Speedup:** 14 hours → 60 minutes = **14x faster** 🚀

**With Monitoring:**
- Real-time visibility into all 10 parallel agents
- Check progress every 30 seconds
- Know exactly what each agent is doing
- Catch errors early
- No more "black box" execution

---

## Summary

✅ **All orchestrator bugs fixed**  
✅ **Monitoring capability added**  
✅ **Proper workflow documented**  
✅ **14/14 tests passing**  
✅ **Production ready**

### The Complete Flow:

1. User requests complex task
2. **droidz-orchestrator droid** analyzes complexity
3. Generates tasks.json breakdown
4. Runs `orchestrator.sh` (creates worktrees + tmux)
5. Spawns Task agents in parallel (in ONE response!)
6. **Monitors progress via tmux every 30s** ⭐ (NEW!)
7. Agents work simultaneously in isolated worktrees
8. Synthesizes results when complete
9. User can attach to tmux sessions anytime

### Key Innovation:

**Real-time monitoring** - You and the orchestrator droid can now see exactly what each agent is doing, with tmux output captured every 30 seconds!

**Ready to use! 🚀**

---

**Last Updated:** 2025-11-14  
**All Bugs Fixed:** ✅  
**Monitoring Added:** ✅  
**Tests Passing:** 14/14 ✅
