---
description: Initialize Droidz in a new project. Interactive setup wizard that detects tech stack, configures standards, creates example specs, and validates the orchestration system.
argument-hint: [--quick for minimal setup] [--full for comprehensive setup]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob
---

# /droidz-init - Droidz Onboarding Wizard

Welcome to Droidz! This command sets up the ultimate Claude Code powerhouse in your project.

## Usage

```bash
# Interactive setup (recommended for first-time users)
/droidz-init

# Quick setup (minimal configuration)
/droidz-init --quick

# Full setup (all features)
/droidz-init --full

# Check current status
/droidz-init --status
```

## What Gets Set Up

### 1. Environment Check
- ✅ Verify Git repository
- ✅ Check dependencies (git, jq, tmux)
- ✅ Validate Claude Code installation
- ✅ Check disk space for worktrees

### 2. Tech Stack Detection
- 🔍 Analyze package.json, requirements.txt, go.mod, etc.
- 🔍 Detect frameworks (React, Vue, Next.js, etc.)
- 🔍 Identify build tools
- 🔍 Find test frameworks
- 💾 Save to `.claude/memory/org/tech-stack.json`

### 3. Standards Configuration
- 📚 Load appropriate standards templates
- 📚 Configure framework-specific patterns
- 📚 Set up linting and formatting standards
- 💾 Create `.claude/standards/active/`

### 4. Example Creation
- 📝 Create example feature spec
- 📝 Generate sample task breakdown
- 📝 Demonstrate orchestration workflow
- 💾 Save to `.claude/specs/examples/`

### 5. Preference Setup
- ⚙️ Configure orchestration preferences
- ⚙️ Set default specialists
- ⚙️ Configure approval gates
- 💾 Save to `.claude/memory/user/preferences.json`

### 6. Validation
- ✅ Test orchestrator script
- ✅ Verify tmux availability
- ✅ Check git worktree support
- ✅ Validate all skills and commands
- ✅ Run example orchestration (optional)

## Setup Modes

### Interactive (Default)
Asks questions and customizes setup to your needs.
- Best for: First-time users, custom configurations
- Time: 5-10 minutes
- Questions: ~10

### Quick (--quick)
Minimal setup with sensible defaults.
- Best for: Experienced users, getting started fast
- Time: 1-2 minutes
- Questions: 0-2

### Full (--full)
Comprehensive setup with all features enabled.
- Best for: Teams, production projects
- Time: 10-15 minutes
- Questions: ~15

## Interactive Setup Flow

### Step 1: Welcome
```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🚀 Welcome to Droidz Setup                     ║
║                                                   ║
║   Transform Claude Code into the ultimate        ║
║   development powerhouse with spec-driven,       ║
║   parallel execution.                             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

This wizard will:
  1. Detect your tech stack
  2. Configure standards
  3. Set up orchestration
  4. Create examples
  5. Validate setup

Estimated time: 5-10 minutes

Ready to begin? (yes/no)
```

### Step 2: Environment Check
```
📋 Checking Environment...

  ✅ Git repository detected
  ✅ git command available (v2.39.0)
  ✅ jq command available (v1.6)
  ✅ tmux command available (v3.3a)
  ✅ Disk space sufficient (50GB available)
  ✅ Claude Code detected

Environment: Ready ✨
```

### Step 3: Tech Stack Detection
```
🔍 Detecting Tech Stack...

Found package.json:
  ├─ Framework: Next.js 14.0.4
  ├─ Runtime: Node.js (detected from engines)
  ├─ Package Manager: bun (detected from bun.lockb)
  ├─ UI Library: React 18.2.0
  ├─ CSS: Tailwind CSS 3.4.0
  ├─ Components: shadcn/ui
  └─ Tests: Jest, Playwright

Is this correct? (yes/no)
```

### Step 4: Standards Selection
```
📚 Configuring Standards...

Available standards for your stack:
  [x] Next.js - Comprehensive Next.js patterns (11,385 lines)
  [x] React - React best practices (13,978 lines)
  [x] TypeScript - Type-safe patterns (11,855 lines)
  [x] Tailwind CSS - Utility-first CSS (10,116 lines)
  [ ] shadcn/ui - Component patterns (14,180 lines)

Select standards to activate (space to toggle, enter to confirm)
```

### Step 5: Orchestration Preferences
```
⚙️ Orchestration Configuration...

How many tasks should run in parallel? (default: 5)
> 5

Require approval before creating worktrees? (yes/no)
> yes

Require approval before merging? (yes/no)
> yes

Default notification level? (all/important/critical/none)
> important

Preferences saved ✅
```

### Step 6: Example Creation
```
📝 Creating Examples...

Would you like an example to demonstrate Droidz? (yes/no)
> yes

Creating example "todo-app":
  ✅ Created spec: .claude/specs/examples/todo-app.md
  ✅ Generated tasks: todo-app-tasks.json
  ✅ Example orchestration ready

You can review the example and run:
  /orchestrate file:todo-app-tasks.json
```

### Step 7: Validation
```
✅ Validating Setup...

Testing orchestration engine:
  ✅ Can create git worktrees
  ✅ Can spawn tmux sessions
  ✅ Can coordinate parallel tasks
  ✅ Can track progress
  ✅ Can cleanup resources

All systems operational! 🎉
```

### Step 8: Summary
```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   ✅ Droidz Setup Complete!                       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Configuration Summary:
  📍 Project: [Detected from package.json]
  🛠️  Tech Stack: Next.js + React + TypeScript
  📚 Standards: 4 templates loaded
  🎯 Mode: Supervised (approval gates enabled)
  💾 Memory: Initialized

Next Steps:
  1. Review example: .claude/specs/examples/todo-app.md
  2. Create your first spec: /create-spec feature [name]
  3. Try orchestration: /orchestrate file:todo-app-tasks.json
  4. Read docs: .claude/product/roadmap.md

Quick Reference:
  /create-spec [type] [name]  - Create new specification
  /validate-spec [file]       - Validate specification
  /spec-to-tasks [file]       - Convert spec to tasks
  /orchestrate [source]       - Start parallel execution
  /orchestrate list           - Show active orchestrations

Need help? Read .claude/product/use-cases.md for examples!

Happy building with Droidz! 🚀
```

---

## Implementation

<execute>
MODE="interactive"

if echo "$ARGUMENTS" | grep -q "\-\-quick"; then
  MODE="quick"
elif echo "$ARGUMENTS" | grep -q "\-\-full"; then
  MODE="full"
elif echo "$ARGUMENTS" | grep -q "\-\-status"; then
  MODE="status"
fi

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${BLUE}║${NC}                                                   ${BOLD}${BLUE}║${NC}"
  echo -e "${BOLD}${BLUE}║${NC}   ${BOLD}$1${NC}"
  echo -e "${BOLD}${BLUE}║${NC}                                                   ${BOLD}${BLUE}║${NC}"
  echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_success() {
  echo -e "  ${GREEN}✅${NC} $1"
}

print_info() {
  echo -e "  ${BLUE}ℹ${NC}  $1"
}

print_warning() {
  echo -e "  ${YELLOW}⚠${NC}  $1"
}

check_command() {
  if command -v "$1" &> /dev/null; then
    print_success "$1 command available"
    return 0
  else
    print_warning "$1 not found (required)"
    return 1
  fi
}

# Status mode
if [ "$MODE" = "status" ]; then
  echo "📊 Droidz Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Check if initialized
  if [ -f ".claude/memory/org/tech-stack.json" ]; then
    print_success "Droidz initialized"

    # Show tech stack
    if command -v jq &> /dev/null; then
      DETECTED=$(jq -r '.detected' .claude/memory/org/tech-stack.json 2>/dev/null || echo "false")
      FRAMEWORK=$(jq -r '.framework' .claude/memory/org/tech-stack.json 2>/dev/null || echo "unknown")

      echo ""
      echo "Tech Stack:"
      echo "  Framework: $FRAMEWORK"
      echo "  Detected: $DETECTED"
    fi

    # Show active orchestrations
    if [ -d ".runs/.coordination" ] && [ "$(ls -A .runs/.coordination/orchestration-*.json 2>/dev/null)" ]; then
      echo ""
      echo "Active Orchestrations:"
      for state_file in .runs/.coordination/orchestration-*.json; do
        if [ -f "$state_file" ]; then
          SESSION=$(jq -r '.sessionId' "$state_file" 2>/dev/null || basename "$state_file" .json)
          STATUS=$(jq -r '.status' "$state_file" 2>/dev/null || "unknown")
          echo "  - $SESSION ($STATUS)"
        fi
      done
    else
      echo ""
      echo "No active orchestrations"
    fi
  else
    print_warning "Droidz not initialized"
    echo ""
    echo "Run: /droidz-init"
  fi

  exit 0
fi

# Main setup flow
print_header "🚀 Welcome to Droidz Setup"

if [ "$MODE" = "interactive" ]; then
  echo "This wizard will transform your project into a Claude Code powerhouse!"
  echo ""
  echo "Features:"
  echo "  • Spec-driven development workflow"
  echo "  • Parallel execution with git worktrees"
  echo "  • 7 specialist agents for different tasks"
  echo "  • Auto-activating skills and memory persistence"
  echo "  • Supervised execution with approval gates"
  echo ""
  echo "Estimated time: 5-10 minutes"
  echo ""
fi

# Step 1: Environment Check
echo ""
echo "📋 Checking Environment..."
echo ""

CHECKS_PASSED=true

# Check git
if git rev-parse --git-dir > /dev/null 2>&1; then
  print_success "Git repository detected"
else
  print_warning "Not a git repository (git init required)"
  CHECKS_PASSED=false
fi

# Check commands
check_command "git" || CHECKS_PASSED=false
check_command "jq" || CHECKS_PASSED=false
check_command "tmux" || CHECKS_PASSED=false

if [ "$CHECKS_PASSED" = false ]; then
  echo ""
  echo "❌ Environment check failed"
  echo ""
  echo "Install missing dependencies:"
  echo "  brew install git jq tmux"
  echo ""
  exit 1
fi

print_success "All dependencies available"

# Step 2: Create directories
echo ""
echo "📁 Creating Directory Structure..."
echo ""

mkdir -p .claude/memory/org
mkdir -p .claude/memory/user
mkdir -p .claude/specs/active
mkdir -p .claude/specs/archive
mkdir -p .claude/specs/examples
mkdir -p .claude/scripts
mkdir -p .runs/.coordination

print_success "Directories created"

# Step 3: Initialize memory files (if not exist)
echo ""
echo "💾 Initializing Memory System..."
echo ""

if [ ! -f ".claude/memory/org/tech-stack.json" ]; then
  cat > .claude/memory/org/tech-stack.json << 'EOF'
{
  "version": "1.0.0",
  "lastUpdated": null,
  "detected": false,
  "framework": null,
  "stack": {
    "runtime": null,
    "packageManager": null,
    "frameworks": [],
    "libraries": [],
    "buildTools": [],
    "testFrameworks": []
  }
}
EOF
  print_success "Tech stack memory initialized"
fi

# Step 4: Summary
echo ""
print_header "✅ Droidz Setup Complete!"

echo "Next Steps:"
echo ""
echo "  1. Create your first spec:"
echo "     ${CYAN}/create-spec feature my-feature${NC}"
echo ""
echo "  2. Validate the spec:"
echo "     ${CYAN}/validate-spec .claude/specs/active/my-feature.md${NC}"
echo ""
echo "  3. Convert to tasks:"
echo "     ${CYAN}/spec-to-tasks .claude/specs/active/my-feature.md${NC}"
echo ""
echo "  4. Start orchestration:"
echo "     ${CYAN}/orchestrate file:my-feature-tasks.json${NC}"
echo ""
echo "Quick Reference:"
echo "  ${CYAN}/create-spec${NC} [type] [name]  - Create specification"
echo "  ${CYAN}/validate-spec${NC} [file]       - Validate specification"
echo "  ${CYAN}/spec-to-tasks${NC} [file]       - Convert to tasks"
echo "  ${CYAN}/orchestrate${NC} [source]       - Parallel execution"
echo ""
echo "Documentation:"
echo "  Product Vision: ${CYAN}.claude/product/vision.md${NC}"
echo "  Roadmap: ${CYAN}.claude/product/roadmap.md${NC}"
echo "  Use Cases: ${CYAN}.claude/product/use-cases.md${NC}"
echo ""
echo "Happy building with Droidz! 🚀"
echo ""
</execute>
