# Quick Wins Testing Plan

**Purpose:** Validate the 3 new commands work correctly before building Phase 2

---

## Test Environment Setup

### Option A: Test with Real Orchestration (Recommended)

If you already have an orchestration running or can start one:

```bash
# 1. Check if you have existing orchestrations
ls .runs/.coordination/orchestration-*.json

# 2. If not, create a simple test orchestration
# First, create test tasks:
cat > /tmp/test-tasks.json <<'EOF'
{
  "tasks": [
    {
      "key": "TEST-001",
      "title": "Test task 1",
      "description": "Simple test task",
      "specialist": "droidz-generalist",
      "priority": 1
    },
    {
      "key": "TEST-002",
      "title": "Test task 2",
      "description": "Simple test task",
      "specialist": "droidz-generalist",
      "priority": 1
    }
  ]
}
EOF

# 3. Run orchestrator
.factory/scripts/orchestrator.sh --tasks /tmp/test-tasks.json
```

### Option B: Test with Mock Data (Quick)

Create fake orchestration data for testing:

```bash
# Create mock orchestration state
mkdir -p .runs/.coordination
cat > .runs/.coordination/orchestration-20251114-150000-12345.json <<'EOF'
{
  "sessionId": "20251114-150000-12345",
  "status": "ready",
  "startedAt": "2025-11-14T15:00:00Z",
  "tasks": [
    {"key": "MOCK-001", "title": "Mock task 1"},
    {"key": "MOCK-002", "title": "Mock task 2"},
    {"key": "MOCK-003", "title": "Mock task 3"}
  ],
  "worktrees": [
    ".runs/MOCK-001",
    ".runs/MOCK-002",
    ".runs/MOCK-003"
  ],
  "sessions": [
    "droidz-MOCK-001",
    "droidz-MOCK-002",
    "droidz-MOCK-003"
  ]
}
EOF

# Create mock worktrees
mkdir -p .runs/MOCK-001 .runs/MOCK-002 .runs/MOCK-003

# Create mock metadata files
cat > .runs/MOCK-001/.droidz-meta.json <<'EOF'
{
  "taskKey": "MOCK-001",
  "branchName": "feat/MOCK-001-mock-task-1",
  "specialist": "droidz-generalist",
  "status": "completed",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOF

cat > .runs/MOCK-002/.droidz-meta.json <<'EOF'
{
  "taskKey": "MOCK-002",
  "branchName": "feat/MOCK-002-mock-task-2",
  "specialist": "droidz-generalist",
  "status": "in_progress",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOF

cat > .runs/MOCK-003/.droidz-meta.json <<'EOF'
{
  "taskKey": "MOCK-003",
  "branchName": "feat/MOCK-003-mock-task-3",
  "specialist": "droidz-generalist",
  "status": "pending",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOF

echo "✓ Mock data created!"
```

---

## Test 1: /status Command

### Test Cases

#### Test 1.1: Status with No Orchestrations
```bash
# Setup
rm -rf .runs/.coordination/*.json 2>/dev/null

# Test (in Factory.ai droid)
/status

# Expected Output:
# No orchestrations found.
# 
# Start one with: /orchestrate

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 1.2: Status with One Orchestration
```bash
# Setup: Use Option B (mock data) or Option A (real orchestration)

# Test
/status

# Expected Output:
# Active Orchestrations:
#
#   • 20251114-150000-12345 (3 tasks) - ready
#     Started: 2025-11-14T15:00:00Z
#
# Quick Actions:
#   Monitor live: ...
#   Attach to task: /attach [task-key]

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 1.3: Status with Multiple Orchestrations
```bash
# Setup: Create second mock orchestration
cat > .runs/.coordination/orchestration-20251113-120000-11111.json <<'EOF'
{
  "sessionId": "20251113-120000-11111",
  "status": "completed",
  "startedAt": "2025-11-13T12:00:00Z",
  "tasks": [{"key": "OLD-001"}],
  "worktrees": [".runs/OLD-001"],
  "sessions": ["droidz-OLD-001"]
}
EOF

# Test
/status

# Expected Output:
# Active Orchestrations:
#
#   • 20251114-150000-12345 (3 tasks) - ready
#   • 20251113-120000-11111 (1 tasks) - completed
#
# Quick Actions: ...

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 1.4: Status Verbose Mode
```bash
# Test
/status --verbose

# Expected Output:
# Same as above but with additional:
#     Worktrees: /path/to/.runs/
#     State: .runs/.coordination/orchestration-*.json
#     Logs: .runs/.coordination/orchestration.log

# Result: [ ] PASS [ ] FAIL
# Notes:
```

---

## Test 2: /attach Command

### Test Cases

#### Test 2.1: Attach with No Sessions
```bash
# Setup
# Kill all droidz sessions:
tmux list-sessions 2>/dev/null | grep droidz | cut -d: -f1 | xargs -I {} tmux kill-session -t {}

# Test
/attach MOCK-001

# Expected Output:
# ✗ Session not found: droidz-MOCK-001
#
# Available sessions:
#   (none)
#
# List all with: /attach --list

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 2.2: Create Test Session and Attach
```bash
# Setup: Create test tmux session
tmux new-session -d -s droidz-MOCK-001
tmux send-keys -t droidz-MOCK-001 "echo 'Test session MOCK-001'" C-m

# Test
/attach MOCK-001

# Expected Behavior:
# - Should attach to tmux session
# - You see "Test session MOCK-001" output
# - Detach with: Ctrl+B then D

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 2.3: List Available Sessions
```bash
# Setup: Create multiple test sessions
tmux new-session -d -s droidz-MOCK-001
tmux new-session -d -s droidz-MOCK-002
tmux new-session -d -s droidz-MOCK-003

# Test
/attach --list

# Expected Output:
# Available Droidz Sessions:
#
#   ● MOCK-001 → droidz-MOCK-001
#   ● MOCK-002 → droidz-MOCK-002
#   ● MOCK-003 → droidz-MOCK-003
#
# Attach with: /attach [task-key]

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 2.4: Attach Without Argument
```bash
# Test
/attach

# Expected Output:
# Shows list of available sessions (same as --list)

# Result: [ ] PASS [ ] FAIL
# Notes:
```

---

## Test 3: /summary Command

### Test Cases

#### Test 3.1: Summary with No Orchestrations
```bash
# Setup
rm -rf .runs/.coordination/*.json 2>/dev/null

# Test
/summary

# Expected Output:
# ✗ No orchestrations found.
#
# Start one with: /orchestrate

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 3.2: Summary with Valid Session
```bash
# Setup: Use mock data from Option B

# Test
/summary 20251114-150000-12345

# Expected Output:
# Orchestration Summary: 20251114-150000-12345
#
# Progress: 1/3 tasks complete (33%)
#
#   ✅ Completed:    1
#   ⏳ In Progress:  1
#   ⏸  Pending:      1
#
# Recent Completions:
#   ✓ MOCK-001 (0 files changed)
#
# Currently Running:
#   ⏳ MOCK-002
#
# Next Up:
#   ⏸  MOCK-003
#
# Quick Actions:
#   Monitor live: ...
#   Attach to task: /attach MOCK-002

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 3.3: Summary Without Session ID (Latest)
```bash
# Test
/summary

# Expected Output:
# Uses latest session (same as above)

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 3.4: Summary with Invalid Session
```bash
# Test
/summary 99999999-999999-99999

# Expected Output:
# ✗ Session not found: 99999999-999999-99999
#
# Available sessions:
#   • 20251114-150000-12345

# Result: [ ] PASS [ ] FAIL
# Notes:
```

#### Test 3.5: Summary Verbose Mode
```bash
# Test
/summary 20251114-150000-12345 --verbose

# Expected Output:
# Same as Test 3.2 but with additional:
#
# Session Info:
#   Session ID: 20251114-150000-12345
#   Status: ready
#   Started: 2025-11-14T15:00:00Z
#   Worktrees: .runs/
#   State file: .runs/.coordination/orchestration-20251114-150000-12345.json

# Result: [ ] PASS [ ] FAIL
# Notes:
```

---

## Test 4: Integration Testing

### Test 4.1: Complete Workflow
```bash
# 1. Check status
/status
# Should list orchestrations

# 2. Get summary
/summary
# Should show progress

# 3. Attach to in-progress task
/attach MOCK-002
# Should attach to tmux

# 4. Detach and check summary again
# Ctrl+B then D
/summary
# Should show same status

# Result: [ ] PASS [ ] FAIL
# Notes:
```

### Test 4.2: Error Handling
```bash
# Test invalid inputs
/status foobar      # Should ignore extra args
/attach ""          # Should show list
/summary abc123     # Should show "not found"

# Result: [ ] PASS [ ] FAIL
# Notes:
```

---

## Test 5: Real Orchestration (If Available)

### If you have a real project with orchestrations:

```bash
# 1. Navigate to project
cd /path/to/your/project

# 2. Test status
/status
# Should show real orchestrations

# 3. Test summary  
/summary [real-session-id]
# Should show real progress

# 4. Test attach
/attach [real-task-key]
# Should attach to real agent session

# Result: [ ] PASS [ ] FAIL
# Notes:
```

---

## Quick Test Script

Use this bash script to run automated tests:

```bash
#!/bin/bash
# save as: test-quick-wins.sh

echo "Setting up mock data..."
source TEST_QUICK_WINS.md  # Run Option B setup

echo ""
echo "Testing /status..."
cd /path/to/Droidz
# You'll need to test these in Factory.ai droid CLI
echo "Run in droid: /status"

echo ""
echo "Testing /attach --list..."
echo "Run in droid: /attach --list"

echo ""
echo "Testing /summary..."
echo "Run in droid: /summary 20251114-150000-12345"

echo ""
echo "See TEST_QUICK_WINS.md for full test cases"
```

---

## Test Results Summary

| Test | Expected | Actual | Status | Notes |
|------|----------|--------|--------|-------|
| 1.1 - No orchestrations | Error message | | [ ] | |
| 1.2 - One orchestration | Lists session | | [ ] | |
| 1.3 - Multiple | Lists all | | [ ] | |
| 1.4 - Verbose | Extra details | | [ ] | |
| 2.1 - No sessions | Error + list | | [ ] | |
| 2.2 - Attach | Attaches | | [ ] | |
| 2.3 - List | Shows all | | [ ] | |
| 2.4 - No arg | Shows list | | [ ] | |
| 3.1 - No orchestrations | Error message | | [ ] | |
| 3.2 - Valid session | Progress | | [ ] | |
| 3.3 - Latest | Uses latest | | [ ] | |
| 3.4 - Invalid | Error + list | | [ ] | |
| 3.5 - Verbose | Extra details | | [ ] | |
| 4.1 - Workflow | All work | | [ ] | |
| 4.2 - Error handling | Graceful | | [ ] | |

---

## Known Limitations to Test

1. **Custom commands in Factory.ai**
   - Commands should appear after `/` in autocomplete
   - May need to restart droid to see new commands

2. **Path detection**
   - Uses `DROID_PROJECT_DIR` or `CLAUDE_PROJECT_DIR` or `pwd`
   - Should work from any directory

3. **jq requirement**
   - Commands need `jq` installed
   - Should error gracefully if missing

4. **tmux requirement**
   - /attach needs tmux
   - Should error gracefully if not found

---

## Troubleshooting

### Commands not found in Factory.ai
```bash
# Check if files exist
ls -la .factory/commands/status.md
ls -la .factory/commands/attach.md
ls -la .factory/commands/summary.md

# Restart droid CLI
# Exit and run: droid
```

### Commands execute but show errors
```bash
# Check jq installed
which jq

# Check paths
echo $DROID_PROJECT_DIR
echo $CLAUDE_PROJECT_DIR
pwd

# Manually test the bash code
bash .factory/commands/status.md  # Will error on frontmatter but shows if bash works
```

### No orchestration data
```bash
# Use Option B to create mock data
# Or run a real orchestration first
```

---

## Post-Testing Actions

### If All Tests Pass ✅
1. Document any edge cases found
2. Consider additional error handling
3. Proceed to Phase 2 (one-command orchestration)

### If Tests Fail ❌
1. Document which tests failed
2. Note error messages
3. Check prerequisites (jq, tmux, paths)
4. Fix issues before Phase 2

---

## Testing Checklist

- [ ] Option B mock data created
- [ ] /status tested with no data
- [ ] /status tested with data
- [ ] /attach tested with no sessions
- [ ] /attach tested with sessions
- [ ] /attach --list works
- [ ] /summary tested with valid session
- [ ] /summary tested without session ID
- [ ] /summary tested with invalid session
- [ ] All commands handle errors gracefully
- [ ] Commands work in Factory.ai droid CLI
- [ ] Ready for Phase 2

---

## Notes Section

Use this space to record observations, issues, or improvements:

```
Date: 2025-11-14
Tester: 

Observations:
-
-
-

Issues Found:
-
-
-

Suggested Improvements:
-
-
-
```
