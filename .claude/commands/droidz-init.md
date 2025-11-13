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

## Implementation Instructions

When this command is executed, perform the following steps based on $ARGUMENTS:

### Parse Mode
- If `$ARGUMENTS` contains `--quick`: Use quick mode (minimal setup)
- If `$ARGUMENTS` contains `--full`: Use full mode (comprehensive setup)
- If `$ARGUMENTS` contains `--status`: Show status only
- Otherwise: Use interactive mode

### Status Mode (--status)
Display current Droidz configuration:
1. Check if `.claude/memory/org/tech-stack.json` exists
2. Show detected framework and tech stack
3. List active orchestrations from `.runs/.coordination/`
4. Display initialization status

Output format:
```
📊 Droidz Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Droidz initialized
  Framework: [detected framework]

Active Orchestrations:
  - session-id (status)
```

### Setup Mode (default, --quick, --full)

**Step 1: Environment Check**
1. Verify git repository exists (`git rev-parse --git-dir`)
2. Check required commands: git, jq, tmux
3. If any missing, show installation instructions
4. Display results with ✅ or ⚠️

**Step 2: Create Directories**
Create if not exist:
- `.claude/memory/org/`
- `.claude/memory/user/`
- `.claude/specs/active/`
- `.claude/specs/archive/`
- `.claude/specs/examples/`
- `.claude/scripts/`
- `.runs/.coordination/`

**Step 3: Initialize Memory**
If `.claude/memory/org/tech-stack.json` doesn't exist, create it with:
```json
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
```

**Step 4: Display Summary**
Show completion message with next steps:

```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   ✅ Droidz Setup Complete!                       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

Next Steps:
  1. Create your first spec: /create-spec feature my-feature
  2. Validate the spec: /validate-spec .claude/specs/active/my-feature.md
  3. Convert to tasks: /spec-to-tasks .claude/specs/active/my-feature.md
  4. Start orchestration: /orchestrate file:my-feature-tasks.json

Quick Reference:
  /create-spec [type] [name]  - Create specification
  /validate-spec [file]       - Validate specification
  /spec-to-tasks [file]       - Convert to tasks
  /orchestrate [source]       - Parallel execution

Happy building with Droidz! 🚀
```
