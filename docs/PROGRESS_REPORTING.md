# Live Progress Reporting

## The Problem

Previously, when using `/auto-parallel`, users would see:

```
Spawning 3 specialist agents in parallel...
```

Then **nothing** for several minutes while droids worked. This created a terrible UX - users didn't know:
- ❌ If the system was still working
- ❌ What each droid was doing
- ❌ How much progress had been made
- ❌ Whether to wait or restart

## The Solution (v0.1.4)

**All 7 specialist droids now report progress every 60 seconds using TodoWrite!**

### What You'll See

#### 1. Task Start (Immediate)
```
TODO LIST UPDATED

⏳ Analyze codebase structure (in_progress)
⏸ Implement feature logic (pending)
⏸ Write tests (pending)
⏸ Run tests and verify (pending)
```

#### 2. During Work (Every 60 seconds)
```
TODO LIST UPDATED

✅ Analyze codebase structure (completed)
⏳ Implement feature logic (creating API endpoints...) (in_progress)
⏸ Write tests (pending)
⏸ Run tests and verify (pending)
```

#### 3. As Tasks Complete
```
TODO LIST UPDATED

✅ Analyze codebase structure (completed)
✅ Implement feature logic (5 files created) (completed)
⏳ Write tests (writing unit tests...) (in_progress)
⏸ Run tests and verify (pending)
```

#### 4. Final Completion
```
TODO LIST UPDATED

✅ Analyze codebase structure (completed)
✅ Implement feature logic (5 files created) (completed)
✅ Write tests (24 tests written) (completed)
✅ Run tests and verify (all passing ✓) (completed)

TASK (droidz-codegen: 'Build authentication API') ✅ Task completed
```

### Progress Update Frequency

**Every 60 seconds OR after major milestones:**

| Event | Update Timing |
|-------|---------------|
| Task starts | Immediate (create todo list) |
| File reading/analysis | Every 60 seconds |
| Implementation work | Every 60 seconds + after each file |
| Test execution | When tests start + when complete |
| Build/compile | When starts + when completes |
| Final completion | Immediate with summary |

### What Progress Updates Include

#### 1. **Current Step**
- ✅ Completed steps (with checkmarks)
- ⏳ Currently working on (with details)
- ⏸ Pending steps

#### 2. **Live Status**
```
"Implement login endpoint (creating route handler...)"
"Write tests (12/24 tests written)"
"Run build (compiling TypeScript...)"
```

#### 3. **Metrics**
- Files created/modified count
- Test counts (written, passing, failing)
- Build status
- Error counts

#### 4. **Context**
What the droid is currently doing right now:
- "analyzing existing patterns..."
- "creating component files..."
- "running bun test..."
- "fixing TypeScript errors..."

## Droids with Progress Reporting

All 7 specialist droids now report progress:

| Droid | Progress Updates Include |
|-------|-------------------------|
| **droidz-codegen** | Files created, implementation steps, test status |
| **droidz-test** | Test counts, test results, coverage info |
| **droidz-refactor** | Code smells found, refactorings applied, tests status |
| **droidz-integration** | API research, SDK setup, integration tests |
| **droidz-infra** | Pipeline changes, build status, deployment steps |
| **droidz-generalist** | Analysis steps, changes made, verification |
| **droidz-orchestrator** | Phase tracking, agent spawning, synthesis |

## Technical Implementation

### For Droids (Internal)

Each droid's prompt now includes a **"Progress Reporting (CRITICAL UX)"** section:

```typescript
// At task start
TodoWrite({
  todos: [
    {id: "1", content: "Analyze codebase", status: "in_progress", priority: "high"},
    {id: "2", content: "Implement feature", status: "pending", priority: "high"},
    {id: "3", content: "Write tests", status: "pending", priority: "medium"}
  ]
});

// After 60 seconds
TodoWrite({
  todos: [
    {id: "1", content: "Analyze codebase ✅", status: "completed", priority: "high"},
    {id: "2", content: "Implement feature (creating endpoints...)", status: "in_progress", priority: "high"},
    {id: "3", content: "Write tests", status: "pending", priority: "medium"}
  ]
});
```

### How Factory.ai Streams This

Factory.ai's Task tool automatically streams TodoWrite updates to the conversation in real-time. No polling needed!

```
User sees updates appear as droids call TodoWrite
  ↓
Factory.ai Task tool streams the update
  ↓
Appears in conversation immediately
  ↓
User knows exactly what's happening
```

## Benefits

### Before (v0.1.3)
```
User: /auto-parallel "Build auth system"

System: Spawning 3 agents...

[5 minutes of silence]

System: All tasks complete!
```
**User experience:** 😰 "Is it working? Should I wait? Should I restart?"

### After (v0.1.4)
```
User: /auto-parallel "Build auth system"

System: Spawning 3 agents...

[15 seconds later]
TODO: Analyze codebase ✅ (completed)
TODO: Create login API (creating endpoints...) (in_progress)

[60 seconds later]
TODO: Create login API ✅ (3 files created) (completed)
TODO: Create UI components (building forms...) (in_progress)

[60 seconds later]
TODO: Create UI components ✅ (2 components) (completed)
TODO: Write tests (12/24 tests written) (in_progress)

[final]
All tasks complete! ✅
```
**User experience:** 😊 "I can see exactly what's happening!"

## User Expectations

When you run `/auto-parallel`, expect:

1. **Immediate feedback** - Todo list created within 5 seconds
2. **Regular updates** - Every 60 seconds minimum
3. **Milestone updates** - After each major step completes
4. **Detailed status** - Know what's happening, not just "working..."
5. **Final summary** - Complete overview when done

## Example: Real-World Progress Timeline

Building an authentication system with 3 parallel droids:

```
00:00 - User: /auto-parallel "Build complete auth system"
00:05 - System: Created execution plan with 3 parallel streams
00:10 - Droid A: "Analyzing backend structure..."
00:10 - Droid B: "Analyzing frontend structure..."
00:10 - Droid C: "Analyzing test patterns..."

01:10 - Droid A: "Creating login API endpoint..."
01:10 - Droid B: "Creating LoginForm component..."
01:10 - Droid C: "Writing API tests (4/12 written)..."

02:10 - Droid A: "Creating registration endpoint..."
02:10 - Droid B: "Creating RegisterForm component..."
02:10 - Droid C: "Writing component tests (16/24 written)..."

03:30 - Droid A: ✅ Completed (5 files, all passing)
04:00 - Droid B: ✅ Completed (3 components, styled)
04:15 - Droid C: ✅ Completed (24 tests, 100% passing)

04:20 - System: All tasks complete! 🎉
```

**Total time:** 4 minutes 20 seconds (would be 12+ minutes sequential)  
**Updates received:** ~20 progress updates  
**User confidence:** High (saw constant progress)

## Research & Implementation

This feature was researched using:
- **exa-code**: Searched for Factory.ai TodoWrite streaming patterns
- **ref MCP**: Read Factory.ai documentation on progress reporting
- **Best practices**: Studied agent progress reporting in other systems

Key findings:
- ✅ Factory.ai Task tool DOES stream TodoWrite updates
- ✅ Updates appear in real-time in conversation
- ✅ 60-second intervals provide good balance (not too spammy, not too quiet)
- ✅ Users prefer frequent small updates over one big update at the end

## Version History

| Version | Changes |
|---------|---------|
| v0.1.3 | No progress reporting (users complained) |
| v0.1.4 | Added 60-second progress updates to all droids |

## Related Files

- `.factory/droids/droidz-*.md` - All droids updated with progress sections
- `.factory/commands/auto-parallel.md` - User-facing documentation updated
- `docs/PROGRESS_REPORTING.md` - This file

---

**Bottom Line:** You now get live updates every 60 seconds instead of staring at a blank screen! 🎉
