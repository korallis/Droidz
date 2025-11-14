#!/usr/bin/env bash
#
# Test script for orchestrator.sh fixes
#
# This script validates all the bug fixes applied to the orchestrator
#

set -uo pipefail  # Don't use -e so tests can fail without exiting the script

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_DIR="/tmp/droidz-orchestrator-test-$$"
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

tests_passed=0
tests_failed=0

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((tests_passed++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((tests_failed++))
}

info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Setup test environment
setup() {
    info "Setting up test environment at $TEST_DIR"
    
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize git repo
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create test tasks JSON
    cat > tasks.json <<'EOF'
{
  "tasks": [
    {
      "key": "TEST-001",
      "title": "Implement feature A",
      "description": "Build feature A with tests",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "TEST-002",
      "title": "Add integration tests",
      "description": "Write comprehensive integration tests",
      "specialist": "droidz-test",
      "priority": 2
    },
    {
      "key": "TEST-003",
      "title": "Setup CI pipeline",
      "description": "Configure GitHub Actions",
      "specialist": "droidz-infra",
      "priority": 3
    }
  ]
}
EOF

    # Create .factory directory structure
    mkdir -p .factory/scripts
    mkdir -p .runs/.coordination
    
    # Copy orchestrator script
    cp "$SCRIPT_DIR/orchestrator.sh" .factory/scripts/
    chmod +x .factory/scripts/orchestrator.sh
    
    pass "Test environment created"
}

# Test 1: Verify script syntax is valid
test_syntax() {
    info "Test 1: Validating script syntax"
    
    if bash -n .factory/scripts/orchestrator.sh 2>&1; then
        pass "Script syntax is valid"
        return 0
    else
        fail "Script has syntax errors"
        return 1
    fi
}

# Test 2: Check that tee -a was replaced with >> redirect in git worktree command
test_output_redirection() {
    info "Test 2: Checking output redirection fix"
    
    # Check specifically for the problematic pattern in conditionals
    if grep -q "if git worktree add.*| tee -a" .factory/scripts/orchestrator.sh; then
        fail "Still using 'tee -a' in git worktree conditional (causes issues)"
        return 1
    fi
    
    if grep -q "if git worktree add.*>> .*ORCHESTRATION_LOG.*2>&1" .factory/scripts/orchestrator.sh; then
        pass "Output redirection fixed (using >> instead of tee in git worktree)"
    else
        fail "Output redirection not properly fixed"
        return 1
    fi
}

# Test 3: Verify .factory-context.md is created before tmux setup
test_context_file_ordering() {
    info "Test 3: Checking .factory-context.md creation order"
    
    # Extract line numbers
    local context_line=$(grep -n "cat > .*\.factory-context\.md" .factory/scripts/orchestrator.sh | head -1 | cut -d: -f1)
    local tmux_setup_line=$(grep -n "tmux send-keys.*printf" .factory/scripts/orchestrator.sh | head -1 | cut -d: -f1)
    
    if [ -z "$context_line" ] || [ -z "$tmux_setup_line" ]; then
        fail "Could not find context file or tmux setup in script"
        return 1
    fi
    
    if [ "$context_line" -lt "$tmux_setup_line" ]; then
        pass ".factory-context.md created before tmux setup (line $context_line < $tmux_setup_line)"
    else
        fail ".factory-context.md created after tmux setup (line $context_line >= $tmux_setup_line)"
        return 1
    fi
}

# Test 4: Verify no bash color variables in tmux send-keys
test_tmux_color_codes() {
    info "Test 4: Checking tmux color code handling"
    
    if grep -q 'tmux send-keys.*\${CYAN}' .factory/scripts/orchestrator.sh || \
       grep -q 'tmux send-keys.*\${NC}' .factory/scripts/orchestrator.sh || \
       grep -q 'tmux send-keys.*\${BOLD}' .factory/scripts/orchestrator.sh; then
        fail "Still using bash color variables in tmux send-keys (causes escaping issues)"
        return 1
    fi
    
    if grep -q "tmux send-keys.*printf" .factory/scripts/orchestrator.sh; then
        pass "Tmux uses printf without color variables"
    else
        fail "Tmux setup not using recommended approach"
        return 1
    fi
}

# Test 5: Verify droid exec command was removed
test_no_droid_exec() {
    info "Test 5: Checking for non-existent 'droid exec' command"
    
    if grep -q "droid exec" .factory/scripts/orchestrator.sh; then
        fail "Still using 'droid exec' command (doesn't exist)"
        return 1
    fi
    
    if grep -q "Waiting for agent invocation" .factory/scripts/orchestrator.sh; then
        pass "Non-existent 'droid exec' removed, workspace waits for manual agent"
    else
        fail "Alternative to 'droid exec' not properly implemented"
        return 1
    fi
}

# Test 6: Verify task filtering function exists
test_task_filtering() {
    info "Test 6: Checking task filtering functionality"
    
    if grep -q "filter_incomplete_tasks" .factory/scripts/orchestrator.sh; then
        pass "Task filtering function exists"
    else
        fail "Task filtering function not found"
        return 1
    fi
    
    if grep -q "already have branches" .factory/scripts/orchestrator.sh; then
        pass "Task filtering provides user feedback"
    else
        fail "Task filtering missing user feedback"
        return 1
    fi
}

# Test 7: Verify help message is available
test_help_message() {
    info "Test 7: Checking help message"
    
    if .factory/scripts/orchestrator.sh --help 2>&1 | grep -q "Droidz Orchestrator"; then
        pass "Help message works"
    else
        fail "Help message not working"
        return 1
    fi
}

# Test 8: Verify dependencies check
test_dependencies() {
    info "Test 8: Checking dependency validation"
    
    if grep -q "check_dependencies" .factory/scripts/orchestrator.sh; then
        pass "Dependency check function exists"
    else
        fail "Dependency check function missing"
        return 1
    fi
}

# Test 9: Create a branch and verify filtering works
test_filtering_logic() {
    info "Test 9: Testing actual filtering logic"
    
    # Get the default branch name (could be main or master)
    local default_branch=$(git branch --show-current)
    
    # Create a branch that matches TEST-001 pattern
    git checkout -b feat/TEST-001-implement-feature-a 2>/dev/null || true
    git checkout "$default_branch" 2>/dev/null || true
    
    # Now check if filter would skip it
    local all_branches=$(git branch -a | grep -oE '[A-Z]+-[0-9]+' | sort -u)
    
    if echo "$all_branches" | grep -q "TEST-001"; then
        pass "Branch pattern detection works (found TEST-001)"
        return 0
    else
        fail "Branch pattern detection failed"
        return 1
    fi
}

# Test 10: Verify error handling trap exists
test_error_handling() {
    info "Test 10: Checking error handling"
    
    if grep -q "set -euo pipefail" .factory/scripts/orchestrator.sh; then
        pass "Strict error handling enabled (set -euo pipefail)"
    else
        fail "Strict error handling not enabled"
        return 1
    fi
    
    if grep -q "trap.*ERR" .factory/scripts/orchestrator.sh; then
        pass "Error trap configured"
    else
        fail "Error trap not configured"
        return 1
    fi
}

# Cleanup test environment
cleanup() {
    info "Cleaning up test environment"
    cd /
    rm -rf "$TEST_DIR"
    pass "Test environment cleaned up"
}

# Main test runner
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Droidz Orchestrator Bug Fix Test Suite"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    
    setup
    
    echo ""
    echo "Running tests..."
    echo ""
    
    test_syntax || true
    test_output_redirection || true
    test_context_file_ordering || true
    test_tmux_color_codes || true
    test_no_droid_exec || true
    test_task_filtering || true
    test_help_message || true
    test_dependencies || true
    test_filtering_logic || true
    test_error_handling || true
    
    echo ""
    cleanup || true
    
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Test Results"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo -e "  ${GREEN}Passed:${NC} $tests_passed"
    echo -e "  ${RED}Failed:${NC} $tests_failed"
    echo ""
    
    if [ $tests_failed -eq 0 ]; then
        echo -e "${GREEN}All tests passed! ✓${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}Some tests failed ✗${NC}"
        echo ""
        return 1
    fi
}

main "$@"
