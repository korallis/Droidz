#!/bin/bash
# Quick script to setup mock data for testing commands

echo "Setting up mock orchestration data for testing..."
echo ""

# Create directories
mkdir -p .runs/.coordination
mkdir -p .runs/MOCK-001 .runs/MOCK-002 .runs/MOCK-003

# Create orchestration state
cat > .runs/.coordination/orchestration-20251114-150000-12345.json <<'EOJSON'
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
EOJSON

# Create metadata files
cat > .runs/MOCK-001/.droidz-meta.json <<'EOJSON'
{
  "taskKey": "MOCK-001",
  "branchName": "feat/MOCK-001-mock-task-1",
  "specialist": "droidz-generalist",
  "status": "completed",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOJSON

cat > .runs/MOCK-002/.droidz-meta.json <<'EOJSON'
{
  "taskKey": "MOCK-002",
  "branchName": "feat/MOCK-002-mock-task-2",
  "specialist": "droidz-generalist",
  "status": "in_progress",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOJSON

cat > .runs/MOCK-003/.droidz-meta.json <<'EOJSON'
{
  "taskKey": "MOCK-003",
  "branchName": "feat/MOCK-003-mock-task-3",
  "specialist": "droidz-generalist",
  "status": "pending",
  "createdAt": "2025-11-14T15:00:00Z"
}
EOJSON

# Create test tmux sessions
echo "Creating test tmux sessions..."
tmux new-session -d -s droidz-MOCK-001 2>/dev/null || echo "  (session droidz-MOCK-001 already exists)"
tmux new-session -d -s droidz-MOCK-002 2>/dev/null || echo "  (session droidz-MOCK-002 already exists)"
tmux new-session -d -s droidz-MOCK-003 2>/dev/null || echo "  (session droidz-MOCK-003 already exists)"

tmux send-keys -t droidz-MOCK-001 "echo 'Mock session MOCK-001 - Task completed'" C-m
tmux send-keys -t droidz-MOCK-002 "echo 'Mock session MOCK-002 - Task in progress...'" C-m
tmux send-keys -t droidz-MOCK-003 "echo 'Mock session MOCK-003 - Task pending'" C-m

echo ""
echo "✅ Mock data created!"
echo ""
echo "Test the commands:"
echo "  /status"
echo "  /attach MOCK-001"
echo "  /attach --list"
echo "  /summary 20251114-150000-12345"
echo "  /summary"
echo ""
echo "Cleanup when done:"
echo "  rm -rf .runs"
echo "  tmux kill-session -t droidz-MOCK-001"
echo "  tmux kill-session -t droidz-MOCK-002"
echo "  tmux kill-session -t droidz-MOCK-003"
