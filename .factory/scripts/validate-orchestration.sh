#!/usr/bin/env bash
#
# Orchestration Validation Tests
#
# Tests core assumptions before building more features:
# 1. Tmux monitoring works (capture-pane)
# 2. End-to-end workflow with 2 test tasks
# 3. File-based status tracking
#
# Usage:
#   ./validate-orchestration.sh
#

set -uo pipefail  # Don't use -e so tests can fail without exiting script

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly TEST_DIR="$PROJECT_ROOT/.validation-test-$$"
readonly ORCHESTRATOR_SCRIPT="$SCRIPT_DIR/orchestrator.sh"
readonly MONITOR_SCRIPT="$SCRIPT_DIR/monitor-orchestration.sh"

# Test results
tests_passed=0
tests_failed=0
tests_skipped=0

# Cleanup on exit
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        echo ""
        echo "Cleaning up test environment..."
        
        # Kill test tmux sessions
        tmux list-sessions 2>/dev/null | grep "validation-test" | cut -d: -f1 | while read session; do
            tmux kill-session -t "$session" 2>/dev/null || true
        done
        
        # Remove test worktrees
        cd "$PROJECT_ROOT"
        git worktree list | grep "$TEST_DIR" | awk '{print $1}' | while read worktree; do
            git worktree remove "$worktree" --force 2>/dev/null || true
        done
        
        rm -rf "$TEST_DIR"
        echo "✓ Cleanup complete"
    fi
}

trap cleanup EXIT

# Test result functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((tests_passed++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((tests_failed++))
}

skip() {
    echo -e "${YELLOW}⊘${NC} $1"
    ((tests_skipped++))
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

section() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE} $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Test 1: Tmux availability and basic functionality
test_tmux_basic() {
    section "Test 1: Tmux Basic Functionality"
    
    info "Checking if tmux is installed..."
    if ! command -v tmux &> /dev/null; then
        fail "tmux is not installed"
        echo "   Install with: brew install tmux (macOS) or apt-get install tmux (Linux)"
        return 1
    fi
    pass "tmux is installed"
    
    local tmux_version=$(tmux -V)
    info "tmux version: $tmux_version"
    
    # Test creating a session
    info "Testing session creation..."
    local test_session="validation-test-basic-$$"
    
    if tmux new-session -d -s "$test_session" 2>/dev/null; then
        pass "Can create tmux session"
        
        # Test sending commands
        info "Testing command sending..."
        if tmux send-keys -t "$test_session" "echo 'Hello from tmux'" C-m 2>/dev/null; then
            pass "Can send commands to tmux session"
            
            # Give it a moment to execute
            sleep 1
            
            # Test capturing output
            info "Testing output capture..."
            local captured=$(tmux capture-pane -p -t "$test_session" 2>/dev/null)
            
            if [ -n "$captured" ]; then
                if echo "$captured" | grep -q "Hello from tmux"; then
                    pass "Can capture pane output with expected content"
                    echo "   Captured: $(echo "$captured" | grep "Hello from tmux")"
                else
                    fail "Captured output doesn't contain expected text"
                    echo "   Captured: $captured"
                fi
            else
                fail "capture-pane returned empty output"
            fi
            
            # Test capturing last N lines
            info "Testing capture with line limit..."
            tmux send-keys -t "$test_session" "echo 'Line 1'" C-m
            tmux send-keys -t "$test_session" "echo 'Line 2'" C-m
            tmux send-keys -t "$test_session" "echo 'Line 3'" C-m
            sleep 1
            
            local last_lines=$(tmux capture-pane -p -t "$test_session" -S -3 2>/dev/null)
            if echo "$last_lines" | grep -q "Line 3"; then
                pass "Can capture last N lines with -S flag"
            else
                fail "Cannot capture with -S flag"
                echo "   This is the flag we use in monitor-orchestration.sh"
            fi
            
        else
            fail "Cannot send commands to tmux session"
        fi
        
        # Cleanup
        tmux kill-session -t "$test_session" 2>/dev/null || true
    else
        fail "Cannot create tmux session"
    fi
}

# Test 2: Multiple tmux sessions
test_tmux_multiple() {
    section "Test 2: Multiple Tmux Sessions (Parallel Monitoring)"
    
    info "Creating 3 test sessions..."
    local sessions=()
    
    for i in 1 2 3; do
        local session="validation-test-multi-$i-$$"
        if tmux new-session -d -s "$session" 2>/dev/null; then
            sessions+=("$session")
            tmux send-keys -t "$session" "echo 'Session $i output'" C-m
        else
            fail "Cannot create session $i"
            return 1
        fi
    done
    
    pass "Created 3 tmux sessions"
    
    # Give commands time to execute
    sleep 1
    
    info "Testing capture from all sessions..."
    local all_captured=true
    
    for i in "${!sessions[@]}"; do
        local session="${sessions[$i]}"
        local expected_num=$((i + 1))
        local captured=$(tmux capture-pane -p -t "$session" 2>/dev/null)
        
        if echo "$captured" | grep -q "Session $expected_num output"; then
            pass "Captured output from session $expected_num"
        else
            fail "Failed to capture from session $expected_num"
            all_captured=false
        fi
    done
    
    if $all_captured; then
        pass "All sessions can be monitored independently"
        info "This validates parallel monitoring capability"
    else
        fail "Some sessions could not be monitored"
    fi
    
    # Cleanup
    for session in "${sessions[@]}"; do
        tmux kill-session -t "$session" 2>/dev/null || true
    done
}

# Test 3: Orchestrator script with test tasks
test_orchestrator_end_to_end() {
    section "Test 3: End-to-End Orchestrator with Test Tasks"
    
    # Check orchestrator exists
    if [ ! -f "$ORCHESTRATOR_SCRIPT" ]; then
        fail "orchestrator.sh not found at $ORCHESTRATOR_SCRIPT"
        return 1
    fi
    pass "orchestrator.sh exists"
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize git repo
    info "Setting up test git repository..."
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    pass "Test git repository initialized"
    
    # Create test tasks
    info "Creating test tasks..."
    cat > tasks.json <<'EOF'
{
  "tasks": [
    {
      "key": "VAL-001",
      "title": "Test task 1",
      "description": "Create test file hello.txt",
      "specialist": "droidz-generalist",
      "priority": 1
    },
    {
      "key": "VAL-002",
      "title": "Test task 2",
      "description": "Create test file world.txt",
      "specialist": "droidz-generalist",
      "priority": 1
    }
  ]
}
EOF
    pass "Test tasks created"
    
    # Create .factory directories
    mkdir -p .factory/scripts
    mkdir -p .runs/.coordination
    
    # Run orchestrator
    info "Running orchestrator script..."
    if "$ORCHESTRATOR_SCRIPT" --tasks tasks.json > orchestrator-output.log 2>&1; then
        pass "Orchestrator script executed successfully"
        
        # Check worktrees created
        info "Checking worktrees..."
        if [ -d ".runs/VAL-001" ]; then
            pass "Worktree .runs/VAL-001 created"
        else
            fail "Worktree .runs/VAL-001 not created"
        fi
        
        if [ -d ".runs/VAL-002" ]; then
            pass "Worktree .runs/VAL-002 created"
        else
            fail "Worktree .runs/VAL-002 not created"
        fi
        
        # Check context files
        info "Checking context files..."
        if [ -f ".runs/VAL-001/.factory-context.md" ]; then
            pass "Context file for VAL-001 created"
            
            # Verify content
            if grep -q "VAL-001" ".runs/VAL-001/.factory-context.md"; then
                pass "Context file contains task key"
            else
                fail "Context file missing task key"
            fi
        else
            fail "Context file for VAL-001 not created"
        fi
        
        # Check metadata files
        info "Checking metadata files..."
        if [ -f ".runs/VAL-001/.droidz-meta.json" ]; then
            pass "Metadata file for VAL-001 created"
            
            # Verify JSON is valid
            if jq -r '.taskKey' ".runs/VAL-001/.droidz-meta.json" 2>/dev/null | grep -q "VAL-001"; then
                pass "Metadata contains correct task key"
            else
                fail "Metadata JSON invalid or missing task key"
            fi
        else
            fail "Metadata file for VAL-001 not created"
        fi
        
        # Check tmux sessions
        info "Checking tmux sessions..."
        if tmux has-session -t "droidz-VAL-001" 2>/dev/null; then
            pass "Tmux session droidz-VAL-001 created"
            
            # Try to capture from session
            info "Testing capture from created session..."
            local captured=$(tmux capture-pane -p -t "droidz-VAL-001" 2>/dev/null)
            if [ -n "$captured" ]; then
                pass "Can capture output from droidz-VAL-001"
                if echo "$captured" | grep -q "VAL-001"; then
                    pass "Session shows task information"
                fi
            else
                fail "Cannot capture from droidz-VAL-001"
            fi
        else
            fail "Tmux session droidz-VAL-001 not created"
        fi
        
        if tmux has-session -t "droidz-VAL-002" 2>/dev/null; then
            pass "Tmux session droidz-VAL-002 created"
        else
            fail "Tmux session droidz-VAL-002 not created"
        fi
        
        # Check coordination files
        info "Checking coordination files..."
        local state_files=(.runs/.coordination/orchestration-*.json)
        if [ -f "${state_files[0]}" ]; then
            pass "Orchestration state file created"
            
            local session_id=$(jq -r '.sessionId' "${state_files[0]}" 2>/dev/null)
            if [ -n "$session_id" ]; then
                pass "State file contains session ID: $session_id"
                
                # Test monitor script if it exists
                if [ -f "$MONITOR_SCRIPT" ]; then
                    info "Testing monitor script..."
                    if "$MONITOR_SCRIPT" --snapshot --session "$session_id" > monitor-output.log 2>&1; then
                        pass "Monitor script runs successfully"
                        
                        if grep -q "VAL-001" monitor-output.log; then
                            pass "Monitor output contains task information"
                        fi
                    else
                        fail "Monitor script failed"
                        cat monitor-output.log
                    fi
                else
                    skip "Monitor script not found, skipping monitor test"
                fi
            else
                fail "State file missing session ID"
            fi
        else
            fail "Orchestration state file not created"
        fi
        
    else
        fail "Orchestrator script failed"
        cat orchestrator-output.log
        return 1
    fi
}

# Test 4: File-based status tracking (fallback)
test_file_based_status() {
    section "Test 4: File-Based Status Tracking (Fallback)"
    
    info "This tests the fallback monitoring method if tmux fails"
    
    # Check if test worktrees exist from previous test
    if [ ! -d "$TEST_DIR/.runs/VAL-001" ]; then
        skip "Test worktrees not available (previous test may have failed)"
        return 0
    fi
    
    cd "$TEST_DIR"
    
    info "Testing metadata file reading..."
    if [ -f ".runs/VAL-001/.droidz-meta.json" ]; then
        local status=$(jq -r '.status' ".runs/VAL-001/.droidz-meta.json" 2>/dev/null)
        if [ -n "$status" ]; then
            pass "Can read status from metadata: $status"
        else
            fail "Cannot parse status from metadata"
        fi
    else
        fail "Metadata file not found"
    fi
    
    info "Testing status counting..."
    local total=$(find .runs -name ".droidz-meta.json" | wc -l | tr -d ' ')
    if [ "$total" -ge 2 ]; then
        pass "Can count total tasks: $total"
    else
        fail "Cannot count tasks correctly"
    fi
    
    info "Simulating status update..."
    if jq '.status = "completed"' ".runs/VAL-001/.droidz-meta.json" > ".runs/VAL-001/.droidz-meta.json.tmp" 2>/dev/null; then
        mv ".runs/VAL-001/.droidz-meta.json.tmp" ".runs/VAL-001/.droidz-meta.json"
        local new_status=$(jq -r '.status' ".runs/VAL-001/.droidz-meta.json" 2>/dev/null)
        if [ "$new_status" = "completed" ]; then
            pass "Can update status in metadata file"
        else
            fail "Status update didn't persist"
        fi
    else
        fail "Cannot update metadata file"
    fi
    
    info "Testing completion counting..."
    local completed=$(find .runs -name ".droidz-meta.json" -exec jq -r 'select(.status=="completed") | .taskKey' {} \; 2>/dev/null | wc -l | tr -d ' ')
    if [ "$completed" = "1" ]; then
        pass "Can count completed tasks: $completed"
    else
        fail "Cannot count completed tasks correctly (got $completed, expected 1)"
    fi
    
    pass "File-based status tracking is viable fallback"
}

# Main execution
main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                           ║${NC}"
    echo -e "${BOLD}${CYAN}║         Orchestration Validation Test Suite              ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                           ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    info "This will validate core assumptions before building new features"
    echo ""
    
    # Run tests
    test_tmux_basic
    test_tmux_multiple
    test_orchestrator_end_to_end
    test_file_based_status
    
    # Summary
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE} Test Results${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:${NC}  $tests_passed"
    echo -e "  ${RED}Failed:${NC}  $tests_failed"
    echo -e "  ${YELLOW}Skipped:${NC} $tests_skipped"
    echo ""
    
    # Verdict
    if [ $tests_failed -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓ ALL TESTS PASSED${NC}"
        echo ""
        echo "Core assumptions validated! You can proceed with:"
        echo "  1. Building quick win commands (/status, /attach, /summary)"
        echo "  2. Building one-command orchestration"
        echo "  3. Implementing smart dependency resolution"
        echo ""
        return 0
    else
        echo -e "${RED}${BOLD}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo "Issues found. Recommendations:"
        echo ""
        
        # Check which tests failed and give specific advice
        if tmux capture-pane -p -t "validation-test-basic-$$" 2>/dev/null | grep -q "tmux"; then
            echo "  ✓ Tmux monitoring works - proceed with monitoring features"
        else
            echo "  ⚠ Tmux monitoring issues detected"
            echo "    → Use file-based fallback (.droidz-meta.json)"
            echo "    → Consider tmux pipe-pane as alternative"
        fi
        
        echo ""
        echo "Review failures above and implement workarounds as needed."
        echo ""
        return 1
    fi
}

main "$@"
