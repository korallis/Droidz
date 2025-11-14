# Phase 2 Testing Guide

**Purpose:** Test all Phase 2 features end-to-end before production deployment

---

## 🧪 Testing Overview

| Feature | Test Type | Duration | Priority |
|---------|-----------|----------|----------|
| `/parallel` command | End-to-end | 30-60 min | ⚠️ Critical |
| Dependency resolution | Unit | 5 min | ⚠️ Critical |
| Parallel execution | Integration | 10 min | High |
| TodoWrite streaming | Manual | 15 min | High |

---

## Test 1: Dependency Resolution (Unit Test) ✅

**Already tested and passing!**

```bash
cd /Users/leebarry/Development/Droidz
./.factory/scripts/dependency-resolver.sh test-deps-tasks.json
```

**Expected Output:**
```
✓ All dependencies valid

Execution Plan:

Phase 1: (parallel execution)
  • AUTH-001 (no dependencies)

Phase 2: (parallel execution)
  • AUTH-002 (depends on: AUTH-001)
  • AUTH-003 (depends on: AUTH-001)

Phase 3: (parallel execution)
  • AUTH-004 (depends on: AUTH-003)

Phase 4: (parallel execution)
  • AUTH-005 (depends on: AUTH-002 AUTH-003 AUTH-004)
```

✅ **Status:** PASSED

---

## Test 2: Parallel Executor (Integration Test) ✅

**Already tested and passing!**

```bash
cd /Users/leebarry/Development/Droidz
./.factory/scripts/parallel-executor.sh test-deps-tasks.json
```

**Expected Output:**
```
Phase 1/4
Tasks in this phase: 1
  • AUTH-001 (no dependencies)

▶ Spawning tasks...
  • Spawning AUTH-001...
    [SPAWN] AUTH-001

⏳ Waiting for phase 1 to complete...
  • Waiting for AUTH-001...
    ✓ AUTH-001 complete

✓ Phase 1 complete

Phase 2/4
Tasks in this phase: 2
  • AUTH-002 (depends on: AUTH-001)
  • AUTH-003 (depends on: AUTH-001)

▶ Spawning tasks...
  • Spawning AUTH-002...
    [SPAWN] AUTH-002
  • Spawning AUTH-003...
    [SPAWN] AUTH-003
...
```

**Key Validation:**
- ✅ Both AUTH-002 and AUTH-003 spawn BEFORE waiting
- ✅ True parallel execution confirmed

✅ **Status:** PASSED

---

## Test 3: `/parallel` Command (End-to-End Test) ⏸️

**This is the critical test!**

### Option A: Simple Test (Recommended First)

**Test case:** Simple CRUD API (3-5 tasks)

```bash
# In Factory.ai droid:
/parallel "create a simple REST API for managing todo items with create, read, update, and delete endpoints"
```

**Expected behavior:**

1. **Analysis Phase (30-60 sec):**
   ```
   ⏳ Analyzing request...
   ✅ Analyzed: identified 4-5 tasks
   ```

2. **Task Generation (30 sec):**
   ```
   ⏳ Generating task breakdown...
   ✅ Generated tasks:
     - TODO-001: Database model
     - TODO-002: Create endpoint
     - TODO-003: Read endpoint
     - TODO-004: Update endpoint
     - TODO-005: Delete endpoint
     - TODO-006: Tests
   ```

3. **Orchestration (10-20 min):**
   ```
   ⏳ Phase 1/3: TODO-001 (database model)
   ✅ Phase 1 complete
   ⏳ Phase 2/3: TODO-002, TODO-003, TODO-004, TODO-005 (parallel)
   ✅ Phase 2 complete
   ⏳ Phase 3/3: TODO-006 (tests)
   ✅ Phase 3 complete
   ```

4. **Results:**
   ```
   ✅ Orchestration complete!
   📊 View details: /summary [session-id]
   ```

**What to check:**
- [ ] droidz-orchestrator spawns successfully
- [ ] Agent analyzes request and identifies tasks
- [ ] tasks.json is created with dependencies
- [ ] orchestrator.sh executes
- [ ] Multiple tasks run in parallel
- [ ] All tasks complete
- [ ] Results are reported

**Potential issues:**
- Orchestrator might not spawn → Check droidz-orchestrator droid exists
- Task generation fails → Description might be too vague
- Orchestration doesn't start → Check orchestrator.sh path
- Tasks don't run in parallel → Check dependency resolution

---

### Option B: Medium Complexity Test

**Test case:** Authentication system (5-7 tasks with dependencies)

```bash
/parallel "build user authentication with registration, login, JWT tokens, and password reset"
```

**Expected tasks:**
```
AUTH-001: User model and database schema
AUTH-002: Registration endpoint (depends on 001)
AUTH-003: Login endpoint (depends on 001)
AUTH-004: JWT middleware (depends on 003)
AUTH-005: Password reset (depends on 001)
AUTH-006: Integration tests (depends on all)
```

**Expected phases:**
```
Phase 1: AUTH-001
Phase 2: AUTH-002, AUTH-003, AUTH-005 (3 parallel!)
Phase 3: AUTH-004
Phase 4: AUTH-006
```

**What to check:**
- [ ] Complex dependencies resolved correctly
- [ ] Maximum parallelization (3 tasks in Phase 2)
- [ ] Specialist selection is appropriate
- [ ] All tasks complete successfully

---

### Option C: Stress Test (Optional)

**Test case:** Full application (10+ tasks)

```bash
/parallel "build a blog platform with user auth, post creation, comments, likes, and an admin dashboard"
```

**Expected:**
- 10-15 tasks generated
- Multiple phases with parallel execution
- Different specialists used (codegen, test, integration)
- Longer execution time (30-45 min)

**What to check:**
- [ ] System handles large number of tasks
- [ ] Dependency resolution scales
- [ ] Progress tracking remains clear
- [ ] All tasks complete or fail gracefully

---

## Test 4: TodoWrite Streaming (Manual Test)

**Objective:** Verify real-time progress updates work as expected

**Test case:** Run any `/parallel` command and observe TodoWrite updates

**Expected behavior:**

### Initial State (T+0 sec)
```
⏳ Analyze user request
⏸  Generate task breakdown
⏸  Execute orchestration
⏸  Report results
```

### After Analysis (T+30 sec)
```
✅ Analyze user request
⏳ Generate task breakdown
⏸  Execute orchestration
⏸  Report results
```

### After Task Generation (T+60 sec)
```
✅ Analyze user request
✅ Generate task breakdown (5 tasks, 4 phases)
⏳ Execute orchestration
⏸  Report results
```

### During Execution (T+5 min)
```
✅ Analyze user request
✅ Generate task breakdown
⏳ Execute orchestration (Phase 2/4)
  ✅ Phase 1: AUTH-001
  ⏳ Phase 2: AUTH-002, AUTH-003 (parallel)
    ✅ AUTH-002 complete
    ⏳ AUTH-003 in progress
  ⏸  Phase 3: AUTH-004
  ⏸  Phase 4: AUTH-005
⏸  Report results
```

### Complete (T+15 min)
```
✅ Analyze user request
✅ Generate task breakdown
✅ Execute orchestration (4/4 phases)
✅ Report results
📊 Total: 9 files, 42 tests in 15 min
```

**What to check:**
- [ ] Updates appear in real-time (not all at once at end)
- [ ] Progress is clear and understandable
- [ ] Phase status updates correctly
- [ ] Individual task status visible
- [ ] Final summary includes metrics

**Frequency check:**
- [ ] Updates every 30-60 seconds minimum
- [ ] Updates on every major state change
- [ ] Not too many updates (avoid spam)

---

## Test 5: Error Handling

### Test 5.1: Invalid Description

```bash
/parallel "do some stuff"
```

**Expected:**
- Agent should ask for clarification
- OR generate very generic tasks
- Should not crash

### Test 5.2: Circular Dependencies

Create a test file with circular deps:
```json
{
  "tasks": [
    {"key": "A", "dependencies": ["B"]},
    {"key": "B", "dependencies": ["A"]}
  ]
}
```

```bash
./.factory/scripts/dependency-resolver.sh circular-test.json
```

**Expected:**
```
❌ Circular dependency detected or unresolvable dependencies
```

### Test 5.3: Missing Dependencies

```json
{
  "tasks": [
    {"key": "A", "dependencies": ["Z"]}
  ]
}
```

**Expected:**
```
⚠ Dependency validation warnings:
  • Task A depends on non-existent task: Z
```

---

## Test 6: Integration with Existing Commands

### Test 6.1: `/status` After `/parallel`

```bash
# Run parallel orchestration
/parallel "create simple API"

# Wait for it to start (30 sec)

# Check status
/status
```

**Expected:**
- Should list the new orchestration session
- Show number of tasks
- Show status (planning/ready/running)

### Test 6.2: `/summary` After `/parallel`

```bash
# After orchestration starts
/summary

# Or with session ID
/summary [session-id]
```

**Expected:**
- Show progress (X/Y tasks complete)
- List completed tasks
- Show in-progress tasks
- Show pending tasks

### Test 6.3: `/attach` to Running Task

```bash
# After Phase 2 starts (tasks running in parallel)
/attach AUTH-002
```

**Expected:**
- Attach to tmux session
- See agent working in real-time
- Can detach with Ctrl+B then D

---

## Test Checklist

### Pre-Testing Setup
- [ ] All Phase 2 code committed and pushed
- [ ] Factory.ai droid CLI available
- [ ] droidz-orchestrator droid configured
- [ ] Git working directory clean
- [ ] Enough time for full test (30-60 min)

### Core Tests
- [x] Dependency resolver (unit) - ✅ PASSED
- [x] Parallel executor (integration) - ✅ PASSED
- [ ] `/parallel` simple test (end-to-end)
- [ ] TodoWrite streaming (manual observation)
- [ ] Error handling (circular deps, invalid input)

### Integration Tests
- [ ] `/status` shows new orchestration
- [ ] `/summary` shows progress
- [ ] `/attach` works with running tasks

### Optional Tests
- [ ] Medium complexity orchestration
- [ ] Stress test (10+ tasks)
- [ ] Different specialists used correctly
- [ ] Complex dependency graphs resolved

---

## Success Criteria

### Must Pass ⚠️
- [x] Dependency resolver handles all test cases
- [x] Parallel executor spawns tasks in parallel
- [ ] `/parallel` command completes successfully
- [ ] Tasks execute in correct phase order
- [ ] TodoWrite shows progress updates

### Should Pass ✅
- [ ] Complex dependencies resolved correctly
- [ ] Error handling is graceful
- [ ] Integration with Phase 1 commands works
- [ ] Real-time streaming is smooth

### Nice to Have 💡
- [ ] Stress test completes successfully
- [ ] All specialist types used appropriately
- [ ] Performance is good (< 30 min for 5 tasks)

---

## Test Results Template

### Test Run: [Date/Time]

**Environment:**
- Factory.ai version: ___
- Droidz version: ___
- Git branch: factory-ai

**Test 1: Dependency Resolution**
- Status: ✅ PASS
- Notes: Works perfectly

**Test 2: Parallel Executor**
- Status: ✅ PASS
- Notes: Confirmed parallel spawning

**Test 3: `/parallel` End-to-End**
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Test case: ___
- Duration: ___ min
- Tasks generated: ___
- Phases: ___
- Issues found: ___
- Notes: ___

**Test 4: TodoWrite Streaming**
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Update frequency: ___
- Clarity: ___/10
- Issues: ___

**Test 5: Error Handling**
- Invalid description: [ ] PASS [ ] FAIL
- Circular dependencies: [ ] PASS [ ] FAIL
- Missing dependencies: [ ] PASS [ ] FAIL

**Test 6: Integration**
- `/status`: [ ] PASS [ ] FAIL
- `/summary`: [ ] PASS [ ] FAIL
- `/attach`: [ ] PASS [ ] FAIL

**Overall Result:** [ ] READY FOR PRODUCTION [ ] NEEDS FIXES

**Issues Found:**
1. ___
2. ___
3. ___

**Recommendations:**
1. ___
2. ___

---

## Quick Start: Minimal Test

**If you have limited time, run this minimal test:**

```bash
# 1. Test dependency resolution (2 min)
./.factory/scripts/dependency-resolver.sh test-deps-tasks.json
# ✅ Should show 4 phases with correct grouping

# 2. Test parallel executor (2 min)
./.factory/scripts/parallel-executor.sh test-deps-tasks.json
# ✅ Should spawn tasks in parallel

# 3. Test /parallel command (15 min)
/parallel "create simple REST API for managing tasks"
# ✅ Should complete successfully

# 4. Check results (2 min)
/status
/summary
# ✅ Should show orchestration and progress
```

**Total time:** ~20 minutes

---

## Troubleshooting

### Issue: `/parallel` command not found

**Solution:**
```bash
# Check file exists
ls .factory/commands/parallel.md

# Restart Factory.ai droid
exit
droid
```

### Issue: droidz-orchestrator not found

**Solution:**
```bash
# Check droid exists
ls .factory/droids/droidz-orchestrator.md

# Or check project droids
cat .factory/droids/*.md | grep orchestrator
```

### Issue: Orchestration doesn't start

**Solution:**
```bash
# Check orchestrator.sh is executable
ls -la .factory/scripts/orchestrator.sh

# Check for errors
cat .runs/.coordination/orchestration.log
```

### Issue: Tasks don't run in parallel

**Solution:**
```bash
# Check dependency resolution
cat .runs/orchestration-tasks-*.json | jq '.tasks[] | {key, dependencies}'

# Verify phases
./.factory/scripts/dependency-resolver.sh .runs/orchestration-tasks-*.json
```

### Issue: No TodoWrite updates

**Solution:**
- Check that droidz-orchestrator is using TodoWrite
- Verify updates are being called frequently
- Check Factory.ai UI is showing todo list

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Document any observations
2. Update README with Phase 2 features
3. Create user guide for `/parallel` command
4. Consider Phase 3 (polish & production)
5. Deploy to production!

### If Tests Fail ❌
1. Document all failures
2. Prioritize critical issues
3. Fix issues one by one
4. Re-test after fixes
5. Iterate until all pass

---

## Ready to Test!

**Recommended order:**
1. ✅ Dependency resolver (already done)
2. ✅ Parallel executor (already done)
3. `/parallel` simple test (20 min)
4. Check integration (5 min)
5. (Optional) Complex test

**Total time:** 25-60 minutes depending on depth

Let's test! 🧪
