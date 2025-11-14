# Simple Test for /parallel Command

## Quick Test (5 minutes)

Run this in Factory.ai droid:

```bash
/parallel "create a simple REST API for managing todo items with create, read, and list endpoints"
```

## What Should Happen

### 1. Immediate Response (0-10 sec)
```
⏳ Analyzing request...
```

### 2. Analysis Complete (10-30 sec)
```
✅ Analyzed: identified 3-4 tasks
⏳ Generating task breakdown...
```

### 3. Tasks Generated (30-60 sec)
```
✅ Generated tasks:
  - TODO-001: Database model
  - TODO-002: Create endpoint
  - TODO-003: Read endpoint
  - TODO-004: List endpoint
  - TODO-005: Tests

⏳ Starting orchestration...
```

### 4. Orchestration Running (1-15 min)
```
⏳ Phase 1/3: TODO-001 (database model)
✅ Phase 1 complete

⏳ Phase 2/3: TODO-002, TODO-003, TODO-004 (parallel)
  ⏳ TODO-002: Create endpoint
  ⏳ TODO-003: Read endpoint
  ⏳ TODO-004: List endpoint
...
```

### 5. Complete (15-20 min)
```
✅ Orchestration complete!
📊 Total: X files, Y tests
🔍 View details: /summary [session-id]
```

## After Orchestration

### Check Status
```bash
/status
```

Should show:
```
Active Orchestrations:

  • [session-id] (5 tasks) - ready/running
    Started: [timestamp]
```

### Check Progress
```bash
/summary
```

Should show:
```
Orchestration Summary: [session-id]

Progress: X/5 tasks complete

  ✅ Completed: X
  ⏳ In Progress: Y
  ⏸  Pending: Z

Recent Completions:
  ✓ TODO-001: Database model
  ...
```

### Attach to Task
```bash
/attach TODO-002
```

Should:
- Attach to tmux session
- Show agent working
- Detach with Ctrl+B then D

## Success Criteria

✅ `/parallel` command executes  
✅ droidz-orchestrator spawns  
✅ Tasks are generated  
✅ Orchestration starts  
✅ Multiple tasks run in parallel  
✅ Progress updates appear  
✅ Tasks complete  
✅ `/status` shows orchestration  
✅ `/summary` shows progress  

## If It Fails

1. **Command not found:**
   ```bash
   ls .factory/commands/parallel.md
   # If missing, the file wasn't created correctly
   ```

2. **Orchestrator doesn't spawn:**
   ```bash
   ls .factory/droids/droidz-orchestrator.md
   # Check if droid exists
   ```

3. **Orchestration doesn't start:**
   ```bash
   cat .runs/.coordination/orchestration.log
   # Check for errors
   ```

4. **Tasks don't run:**
   ```bash
   tmux list-sessions | grep droidz
   # Check if sessions were created
   ```

## Expected Timeline

- **Analysis:** 10-30 seconds
- **Task generation:** 30-60 seconds
- **Orchestration setup:** 30 seconds
- **Execution:** 10-20 minutes
- **Total:** ~15-20 minutes

## Ready to Test?

Just run:
```bash
/parallel "create a simple REST API for managing todo items with create, read, and list endpoints"
```

And watch the magic happen! ✨
