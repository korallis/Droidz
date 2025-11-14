# TodoWrite Streaming Guide for Droidz Orchestration

**Purpose:** Enable real-time progress visibility during parallel orchestration

---

## Why TodoWrite?

Traditional orchestration is a "black box":
- User runs command
- Waits 10-30 minutes
- No visibility into progress
- Don't know what's happening

With TodoWrite streaming:
- ✅ Real-time task updates
- ✅ See which tasks are in progress
- ✅ Track completion percentage
- ✅ Identify blockers early
- ✅ Better UX

---

## How to Use TodoWrite in Orchestration

### 1. Initialize at Start

**As soon as `/parallel` command starts:**

```javascript
TodoWrite({
  todos: [
    {id: "analyze", content: "Analyze user request", status: "in_progress", priority: "high"},
    {id: "generate", content: "Generate task breakdown", status: "pending", priority: "high"},
    {id: "execute", content: "Execute orchestration", status: "pending", priority: "high"},
    {id: "report", content: "Report results", status: "pending", priority: "high"}
  ]
})
```

**User sees:**
```
⏳ Analyze user request
⏸  Generate task breakdown
⏸  Execute orchestration
⏸  Report results
```

---

### 2. Update During Analysis

**After analyzing request:**

```javascript
TodoWrite({
  todos: [
    {id: "analyze", content: "Analyzed: identified 5 tasks (AUTH system)", status: "completed", priority: "high"},
    {id: "generate", content: "Generating task breakdown...", status: "in_progress", priority: "high"},
    {id: "execute", content: "Execute orchestration", status: "pending", priority: "high"},
    {id: "report", content: "Report results", status: "pending", priority: "high"}
  ]
})
```

**User sees:**
```
✅ Analyzed: identified 5 tasks (AUTH system)
⏳ Generating task breakdown...
⏸  Execute orchestration
⏸  Report results
```

---

### 3. Update During Task Generation

**After generating tasks.json:**

```javascript
TodoWrite({
  todos: [
    {id: "analyze", content: "Analyzed: identified 5 tasks (AUTH system)", status: "completed", priority: "high"},
    {id: "generate", content: "Generated 5 tasks in 4 phases", status: "completed", priority: "high"},
    {id: "tasks-list", content: "Tasks: AUTH-001, AUTH-002, AUTH-003, AUTH-004, AUTH-005", status: "completed", priority: "medium"},
    {id: "deps", content: "Dependencies resolved (4 phases)", status: "completed", priority: "medium"},
    {id: "execute", content: "Starting orchestration...", status: "in_progress", priority: "high"},
    {id: "report", content: "Report results", status: "pending", priority: "high"}
  ]
})
```

**User sees:**
```
✅ Analyzed: identified 5 tasks (AUTH system)
✅ Generated 5 tasks in 4 phases
✅ Tasks: AUTH-001, AUTH-002, AUTH-003, AUTH-004, AUTH-005
✅ Dependencies resolved (4 phases)
⏳ Starting orchestration...
⏸  Report results
```

---

### 4. Update During Execution

**As phases execute, update in REAL-TIME:**

#### Phase 1 Starting

```javascript
TodoWrite({
  todos: [
    // ... previous completed items
    {id: "execute", content: "Orchestration: Phase 1/4", status: "in_progress", priority: "high"},
    {id: "phase1", content: "Phase 1: AUTH-001 (user model)", status: "in_progress", priority: "high"},
    {id: "phase2", content: "Phase 2: AUTH-002, AUTH-003 (parallel)", status: "pending", priority: "medium"},
    {id: "phase3", content: "Phase 3: AUTH-004 (middleware)", status: "pending", priority: "medium"},
    {id: "phase4", content: "Phase 4: AUTH-005 (tests)", status: "pending", priority: "medium"},
    {id: "report", content: "Report results", status: "pending", priority: "high"}
  ]
})
```

#### Phase 1 Complete, Phase 2 Starting

```javascript
TodoWrite({
  todos: [
    // ... previous completed items
    {id: "execute", content: "Orchestration: Phase 2/4", status: "in_progress", priority: "high"},
    {id: "phase1", content: "Phase 1: AUTH-001 (3 files created)", status: "completed", priority: "high"},
    {id: "phase2", content: "Phase 2: AUTH-002, AUTH-003 (running in parallel)", status: "in_progress", priority: "high"},
    {id: "AUTH-002", content: "AUTH-002: Registration endpoint", status: "in_progress", priority: "medium"},
    {id: "AUTH-003", content: "AUTH-003: Login endpoint", status: "in_progress", priority: "medium"},
    {id: "phase3", content: "Phase 3: AUTH-004 (middleware)", status: "pending", priority: "medium"},
    {id: "phase4", content: "Phase 4: AUTH-005 (tests)", status: "pending", priority: "medium"},
    {id: "report", content: "Report results", status: "pending", priority: "high"}
  ]
})
```

**User sees:**
```
✅ Phase 1: AUTH-001 (3 files created)
⏳ Phase 2: AUTH-002, AUTH-003 (running in parallel)
  ⏳ AUTH-002: Registration endpoint
  ⏳ AUTH-003: Login endpoint
⏸  Phase 3: AUTH-004 (middleware)
⏸  Phase 4: AUTH-005 (tests)
```

#### Task Completes Within Phase

```javascript
TodoWrite({
  todos: [
    // ... previous
    {id: "phase2", content: "Phase 2: 1/2 tasks complete", status: "in_progress", priority: "high"},
    {id: "AUTH-002", content: "AUTH-002: Registration (2 files, 8 tests)", status: "completed", priority: "medium"},
    {id: "AUTH-003", content: "AUTH-003: Login endpoint", status: "in_progress", priority: "medium"},
    // ... rest
  ]
})
```

---

### 5. Final Report

**When all phases complete:**

```javascript
TodoWrite({
  todos: [
    {id: "analyze", content: "Analyzed: identified 5 tasks", status: "completed", priority: "high"},
    {id: "generate", content: "Generated 5 tasks in 4 phases", status: "completed", priority: "high"},
    {id: "execute", content: "Orchestration: 4/4 phases complete", status: "completed", priority: "high"},
    {id: "phase1", content: "Phase 1: AUTH-001 (3 files)", status: "completed", priority: "medium"},
    {id: "phase2", content: "Phase 2: AUTH-002 (2 files, 8 tests), AUTH-003 (2 files, 6 tests)", status: "completed", priority: "medium"},
    {id: "phase3", content: "Phase 3: AUTH-004 (1 file, 4 tests)", status: "completed", priority: "medium"},
    {id: "phase4", content: "Phase 4: AUTH-005 (1 file, 24 tests)", status: "completed", priority: "medium"},
    {id: "summary", content: "Total: 9 files, 42 tests, 15 minutes", status: "completed", priority: "high"},
    {id: "report", content: "Results ready - use /summary for details", status: "completed", priority: "high"}
  ]
})
```

**User sees:**
```
✅ Analyzed: identified 5 tasks
✅ Generated 5 tasks in 4 phases
✅ Orchestration: 4/4 phases complete
✅ Phase 1: AUTH-001 (3 files)
✅ Phase 2: AUTH-002 (2 files, 8 tests), AUTH-003 (2 files, 6 tests)
✅ Phase 3: AUTH-004 (1 file, 4 tests)
✅ Phase 4: AUTH-005 (1 file, 24 tests)
✅ Total: 9 files, 42 tests, 15 minutes
✅ Results ready - use /summary for details
```

---

## Best Practices

### 1. Update Frequently

**Bad:** Update once at start, once at end
```
⏳ Running orchestration...
(10 minutes later)
✅ Done!
```

**Good:** Update every 30-60 seconds or on state changes
```
⏳ Phase 1 starting...
⏳ AUTH-001 in progress...
✅ AUTH-001 complete (3 files)
⏳ Phase 2 starting...
⏳ AUTH-002 in progress...
⏳ AUTH-003 in progress...
✅ AUTH-002 complete (2 files, 8 tests)
✅ AUTH-003 complete (2 files, 6 tests)
...
```

---

### 2. Show Meaningful Progress

**Bad:** Vague status
```
⏳ Working on tasks...
```

**Good:** Specific details
```
⏳ Phase 2/4: AUTH-002, AUTH-003 (parallel)
  ✅ AUTH-002: Registration (2 files, 8 tests)
  ⏳ AUTH-003: Login endpoint
```

---

### 3. Use Hierarchical Structure

**Bad:** Flat list
```
✅ Task 1
✅ Task 2
✅ Task 3
✅ Task 4
✅ Task 5
```

**Good:** Grouped by phase
```
✅ Phase 1
  ✅ Task 1
✅ Phase 2 (parallel)
  ✅ Task 2
  ✅ Task 3
⏳ Phase 3
  ⏳ Task 4
⏸  Phase 4
  ⏸  Task 5
```

---

### 4. Include Actionable Information

**Bad:** Just status
```
✅ Done
```

**Good:** Next steps
```
✅ Orchestration complete
✅ 5/5 tasks successful
📊 View details: /summary [session-id]
🔍 Attach to task: /attach AUTH-003
```

---

## Update Timing

### Critical Updates (Immediate)

- Orchestration starts
- Phase starts
- Phase completes
- Task completes
- Task fails
- Orchestration completes

### Regular Updates (Every 30-60s)

- Task progress (if available)
- Phase progress (X/Y tasks)
- Time elapsed

### On-Demand Updates

- User requests status
- Error occurs
- Dependency blocks task

---

## Example: Full Orchestration Flow

### Minute 0: Start

```javascript
TodoWrite({
  todos: [
    {id: "1", content: "Analyze request", status: "in_progress", priority: "high"},
    {id: "2", content: "Generate tasks", status: "pending", priority: "high"},
    {id: "3", content: "Execute orchestration", status: "pending", priority: "high"}
  ]
})
```

### Minute 1: Analysis Complete

```javascript
TodoWrite({
  todos: [
    {id: "1", content: "Analyzed: 5 AUTH tasks identified", status: "completed", priority: "high"},
    {id: "2", content: "Generating task breakdown", status: "in_progress", priority: "high"},
    {id: "3", content: "Execute orchestration", status: "pending", priority: "high"}
  ]
})
```

### Minute 2: Tasks Generated

```javascript
TodoWrite({
  todos: [
    {id: "1", content: "Analyzed: 5 AUTH tasks", status: "completed", priority: "high"},
    {id: "2", content: "Generated 5 tasks, 4 phases", status: "completed", priority: "high"},
    {id: "3", content: "Phase 1/4: AUTH-001", status: "in_progress", priority: "high"},
    {id: "p1", content: "AUTH-001: User model", status: "in_progress", priority: "medium"}
  ]
})
```

### Minute 5: Phase 1 Done, Phase 2 Starting

```javascript
TodoWrite({
  todos: [
    {id: "1", content: "Analyzed: 5 AUTH tasks", status: "completed", priority: "high"},
    {id: "2", content: "Generated 5 tasks, 4 phases", status: "completed", priority: "high"},
    {id: "3", content: "Phase 2/4: AUTH-002, AUTH-003 (parallel)", status: "in_progress", priority: "high"},
    {id: "p1", content: "AUTH-001: User model (3 files)", status: "completed", priority: "medium"},
    {id: "p2a", content: "AUTH-002: Registration", status: "in_progress", priority: "medium"},
    {id: "p2b", content: "AUTH-003: Login", status: "in_progress", priority: "medium"}
  ]
})
```

### Minute 8: Phase 2 Complete

```javascript
TodoWrite({
  todos: [
    {id: "1", content: "Analyzed: 5 AUTH tasks", status: "completed", priority: "high"},
    {id: "2", content: "Generated 5 tasks, 4 phases", status: "completed", priority: "high"},
    {id: "3", content: "Phase 3/4: AUTH-004", status: "in_progress", priority: "high"},
    {id: "p1", content: "AUTH-001: User model (3 files)", status: "completed", priority: "medium"},
    {id: "p2a", content: "AUTH-002: Registration (2 files, 8 tests)", status: "completed", priority: "medium"},
    {id: "p2b", content: "AUTH-003: Login (2 files, 6 tests)", status: "completed", priority: "medium"},
    {id: "p3", content: "AUTH-004: Middleware", status: "in_progress", priority: "medium"}
  ]
})
```

### Minute 15: Complete!

```javascript
TodoWrite({
  todos: [
    {id: "summary", content: "✅ Orchestration Complete! 5/5 tasks", status: "completed", priority: "high"},
    {id: "p1", content: "Phase 1: AUTH-001 (3 files)", status: "completed", priority: "medium"},
    {id: "p2", content: "Phase 2: AUTH-002 (2 files, 8 tests), AUTH-003 (2 files, 6 tests)", status: "completed", priority: "medium"},
    {id: "p3", content: "Phase 3: AUTH-004 (1 file, 4 tests)", status: "completed", priority: "medium"},
    {id: "p4", content: "Phase 4: AUTH-005 (1 file, 24 tests)", status: "completed", priority: "medium"},
    {id: "total", content: "Total: 9 files, 42 tests in 15 min", status: "completed", priority: "high"},
    {id: "next", content: "View details: /summary 20251114-150000", status: "completed", priority: "medium"}
  ]
})
```

---

## Integration with Orchestrator

### In `/parallel` Command

The droidz-orchestrator should:

1. Initialize TodoWrite at start
2. Update after analysis
3. Update after task generation
4. Monitor orchestrator.sh output
5. Parse progress and update todos
6. Report final results

### Monitoring orchestrator.sh

Parse output for:
```bash
# Pattern: "Processing task X/Y"
→ Update: "Orchestration: X/Y tasks processed"

# Pattern: "Creating worktree for TASK-KEY"
→ Update: Add task to todos as "in_progress"

# Pattern: Phase completions
→ Update: Mark phase as "completed"

# Pattern: "Orchestration ready"
→ Update: Mark execution as "ready"
```

---

## TodoWrite Call Frequency

### Minimum

- At start
- After analysis
- After task generation
- Per phase (start and complete)
- At end

**Total:** ~10-15 updates for 4 phases

### Recommended

- Every state change
- Every 30-60 seconds during long phases
- On task completion within phase

**Total:** ~20-30 updates for 4 phases

---

## Status

**Phase 2.3:** ✅ Complete  
**Documentation:** ✅ This guide  
**Integration:** Ready for implementation in `/parallel` command  
**Next:** Test with real orchestration

---

## Usage in Droid Prompts

When creating droids or commands that use orchestration, include:

```
IMPORTANT: Use TodoWrite throughout execution to show progress.

Initialize at start:
TodoWrite({todos: [{id: "1", content: "Starting...", status: "in_progress", priority: "high"}]})

Update frequently:
- After each major step
- Every 30-60 seconds
- On state changes

Include in final report:
- Summary of work done
- Next steps for user
- Commands to view details
```

---

**Ready to use!** This guide provides the framework for real-time progress visibility in Droidz orchestration. 🚀
