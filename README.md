# 🤖 Droidz - Claude Code Orchestration Framework

> **Complete AI development framework with parallel execution, persistent memory, and intelligent automation**

Transform complex projects into coordinated, parallel workflows using git worktrees, specialist agents, auto-activating skills, and persistent memory across sessions.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.1.1-blue.svg)](https://github.com/korallis/Droidz)
[![Status](https://img.shields.io/badge/status-production%20ready-green.svg)](https://github.com/korallis/Droidz)

---

## 💬 Join Our Discord Community

This framework was **built specifically for Ray Fernando's Discord members!** 🎯

Join our exclusive community to:
- 🚀 Get early access to new features
- 💡 Share tips and best practices with other developers
- 🤝 Connect with the framework creator and contributors
- 🆘 Get priority help and support
- 📢 Influence future development
- 🎓 Access exclusive tutorials and workflows

[![Join Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2.svg?style=for-the-badge&logo=discord&logoColor=white)](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)

**[Sign up here →](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

*This framework was created to supercharge coding workflows for our Discord community!*

---

## 💝 Support This Project

If this framework saves you time and makes your coding better, consider buying me a coffee! ☕

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue.svg?style=for-the-badge&logo=paypal)](https://www.paypal.com/paypalme/gideonapp)

**PayPal:** @gideonapp

Your support helps maintain and improve this framework for everyone! 🙏

---

## 📋 Table of Contents

- [What Is Droidz?](#what-is-droidz)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
- [Complete Command Reference](#complete-command-reference)
- [Auto-Activating Skills](#auto-activating-skills)
- [Specialist Agents](#specialist-agents)
- [Hooks System](#hooks-system)
- [Memory System](#memory-system)
- [How It Works](#how-it-works)
- [Complete Workflows](#complete-workflows)
- [Architecture](#architecture)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## What Is Droidz?

Droidz is a **production-ready Claude Code framework** that provides:

### 🎯 Core Capabilities

**Parallel Execution**
- ✅ True parallel task execution via git worktrees
- ✅ Tmux session management for real-time monitoring
- ✅ 515-line orchestration engine with dependency tracking
- ✅ Realistic 1.5-2.5x speedup for parallelizable work

**Intelligent Automation**
- ✅ 4 auto-activating skills (spec-shaper, auto-orchestrator, memory-manager, graphite-stacked-diffs)
- ✅ 7 specialist agents (codegen, test, refactor, infra, integration, orchestrator, generalist)
- ✅ 10 slash commands for complete workflow control
- ✅ 7 hook types for lifecycle automation

**Persistent Intelligence**
- ✅ Organization memory (decisions, patterns, tech-stack)
- ✅ User memory (preferences, context, work-in-progress)
- ✅ Cross-session context persistence
- ✅ Automatic tech stack detection

**Developer Experience**
- ✅ Spec-driven development with templates
- ✅ Context window optimization (60-80% reduction)
- ✅ Standards enforcement with auto-fix
- ✅ Smart update system preserves customizations

---

## Quick Start

### Prerequisites

**No manual installation required!** The installer automatically detects your OS and offers to install missing dependencies.

<details>
<summary>🔧 <strong>Optional: Manual Installation</strong> (if you prefer to install dependencies yourself)</summary>

**macOS**:
```bash
brew install git jq tmux
```

**Windows/WSL2**:
```bash
sudo apt update && sudo apt install -y git jq tmux
```

**Linux (Debian/Ubuntu)**:
```bash
sudo apt update && sudo apt install -y git jq tmux
```

**Linux (Fedora/RHEL)**:
```bash
sudo dnf install -y git jq tmux
```

**Linux (Arch)**:
```bash
sudo pacman -S git jq tmux
```

**Supported Package Managers**: apt, dnf, yum, pacman, zypper, apk, brew

</details>

### One-Line Installation

**Start from anywhere** - even an empty directory!

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/Claude-Code/install-claude-code.sh | bash
```

**What happens automatically**:
- 🔍 Detects your OS and package manager
- 📦 Offers to install missing dependencies (git, jq, tmux)
- 📁 Offers to initialize git repository if needed
- ✅ Installs framework to `.claude/`
- 💾 Initializes memory system (5 JSON files)
- 🔒 Creates secure .gitignore
- 🎯 Preserves custom files on updates

**Interactive prompts for**:
- Git installation (if missing)
- Git repository initialization (if not a repo)
- Optional dependencies (jq, tmux for orchestration)

**Setup time**: 1-2 minutes (fully automated with your permission)

**Supported Platforms**:
- ✅ macOS (Homebrew)
- ✅ Ubuntu/Debian (apt)
- ✅ Fedora (dnf)
- ✅ CentOS/RHEL (yum)
- ✅ Arch Linux (pacman)
- ✅ openSUSE (zypper)
- ✅ Alpine Linux (apk)
- ✅ WSL2

### First Time Setup

```bash
# Start Claude Code
claude

# Run initialization wizard
/droidz-init
```

The wizard will:
- ✅ Verify dependencies
- ✅ Create directory structure
- ✅ Initialize memory system
- ✅ Validate orchestration engine

### Example Installation Flow

**Starting from an empty directory:**

```bash
$ mkdir my-awesome-app && cd my-awesome-app
$ curl -fsSL https://raw.githubusercontent.com/.../install-claude-code.sh | bash

ℹ Detected OS: macos (Package manager: brew)
✓ Git found

⚠ Not in a git repository.
Would you like to initialize this directory as a git repository?
  [Y] Yes, initialize git repository (recommended)
  [N] No, I'll do it manually

Choice [Y/n]: Y
ℹ Initializing git repository...
✓ Git repository initialized
✓ Created .gitignore
✓ Created initial commit

✓ curl found

⚠ Missing optional dependencies: jq tmux
Would you like to automatically install these dependencies?
  [Y] Yes, install automatically (recommended)
  [N] No, I'll install manually

Choice [Y/n]: Y
✓ jq installed successfully
✓ tmux installed successfully

ℹ Installing Droidz Framework...
✓ Framework downloaded
✓ Framework files installed to .claude/
✓ Memory system initialized
✓ All required files present

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Droidz Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps:
  1. Initialize:  claude then /droidz-init
  2. Read guide:  cat README.md
  3. Quick start: cat QUICK_START.md

Happy building with Droidz! 🚀
```

**What just happened?**
1. ✅ Installer detected your OS and package manager
2. ✅ Created a new git repository automatically
3. ✅ Installed missing dependencies (jq, tmux)
4. ✅ Set up the complete Droidz framework
5. ✅ Ready to start coding in under 2 minutes!

---

## Core Features

### 🔧 10 Slash Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/droidz-init` | Initialize Droidz framework | `/droidz-init` |
| `/create-spec` | Create specification from template | `/create-spec feature auth-system` |
| `/validate-spec` | Validate spec completeness | `/validate-spec .claude/specs/active/auth.md` |
| `/spec-to-tasks` | Convert spec to orchestration tasks | `/spec-to-tasks .claude/specs/active/auth.md` |
| `/orchestrate` | Execute tasks in parallel | `/orchestrate file:tasks.json` |
| `/analyze-tech-stack` | Detect stack & generate standards | `/analyze-tech-stack --regenerate` |
| `/check-standards` | Validate code against standards | `/check-standards --fix` |
| `/save-decision` | Record architectural decision | `/save-decision architecture "Use PostgreSQL"` |
| `/load-memory` | Load persistent memory | `/load-memory org` |
| `/optimize-context` | Reduce context window usage | `/optimize-context --aggressive` |

### 🎨 4 Auto-Activating Skills

Skills automatically activate based on triggers - no manual invocation needed!

| Skill | Auto-Activates When | What It Does |
|-------|---------------------|--------------|
| **spec-shaper** | User has fuzzy/incomplete ideas | Transforms vague requests into structured specs |
| **auto-orchestrator** | Complex multi-task requests (3+ tasks) | Analyzes complexity, recommends parallel execution |
| **memory-manager** | Important decisions/patterns discovered | Persists context, decisions, patterns to memory |
| **graphite-stacked-diffs** | User mentions "stacked diffs", "Graphite", "gt" | Guides through complete Graphite workflow |

**Activation Examples**:
```
User: "I want to build a dashboard with charts and filters"
→ spec-shaper activates (fuzzy idea)

User: "Implement user auth, API endpoints, and tests"
→ auto-orchestrator activates (3+ tasks)

User: "We're using PostgreSQL for better type safety"
→ memory-manager activates (decision made)

User: "Create stacked PRs for this feature"
→ graphite-stacked-diffs activates (workflow guidance)
```

### 🤖 7 Specialist Agents

| Agent | Specialty | When Used |
|-------|-----------|-----------|
| **droidz-orchestrator** | Task coordination, dependency management | Orchestration planning |
| **droidz-codegen** | Feature implementation, bug fixes | Code generation tasks |
| **droidz-test** | Test writing, coverage, fixtures | Testing tasks |
| **droidz-refactor** | Code cleanup, performance, maintainability | Refactoring tasks |
| **droidz-infra** | CI/CD, Docker, deployment configs | Infrastructure tasks |
| **droidz-integration** | API integration, webhooks, external services | Integration tasks |
| **droidz-generalist** | Miscellaneous, multi-domain tasks | General-purpose work |

### 🪝 7 Hook Types

Hooks automate actions at key lifecycle points:

| Hook | Triggers | Use Cases |
|------|----------|-----------|
| **SessionStart** | Claude Code starts | Load project context, check tech stack |
| **UserPromptSubmit** | User submits message | Monitor context usage |
| **PreToolUse** | Before tool execution | Validate dangerous commands |
| **PostToolUse** | After tool execution | Auto-lint, check standards |
| **SubagentStop** | Specialist agent finishes | Update Linear tickets, save memory |
| **Notification** | Error/warning received | Analyze errors, suggest fixes |
| **Stop** | Session ending | Summarize work, save decisions |

### 🧠 Memory System

**Organization Memory** (Team-wide)
- `decisions.json` - Architectural & technical decisions
- `patterns.json` - Code patterns & conventions
- `tech-stack.json` - Detected frameworks, tools, libraries

**User Memory** (Personal)
- `preferences.json` - User-specific settings
- `context.json` - Session state, work-in-progress

**Features**:
- ✅ Persists across sessions
- ✅ Searchable by category
- ✅ Auto-saves important context
- ✅ Loads on-demand with `/load-memory`

### 📐 Spec Templates

Located in `.claude/specs/templates/`:

| Template | Use Case | Sections |
|----------|----------|----------|
| **feature-spec.md** | Single features | Overview, User Stories, Implementation Plan, Tests |
| **epic-spec.md** | Large initiatives | Vision, Features, Phases, Success Metrics |

**Workflow**:
```bash
# 1. Create spec
/create-spec feature user-dashboard

# 2. Fill in sections (auto-opens editor)
# 3. Validate
/validate-spec .claude/specs/active/user-dashboard.md

# 4. Generate tasks
/spec-to-tasks .claude/specs/active/user-dashboard.md

# 5. Execute
/orchestrate file:.claude/specs/active/tasks/user-dashboard-tasks.json
```

---

## Complete Command Reference

### `/droidz-init`

**Purpose**: Initialize or verify Droidz framework setup

**Usage**:
```bash
/droidz-init                    # Full interactive setup
/droidz-init --quick            # Minimal setup (skip optional)
/droidz-init --full             # Comprehensive validation
```

**What It Does**:
1. Checks dependencies (git, jq, tmux)
2. Creates directory structure
3. Initializes memory files
4. Validates orchestrator
5. Sets up .gitignore

**Output**: Verification report + setup recommendations

---

### `/create-spec`

**Purpose**: Create specification from template

**Usage**:
```bash
/create-spec feature <name>     # Feature spec
/create-spec epic <name>        # Epic spec
/create-spec refactor <name>    # Refactor spec
/create-spec integration <name> # Integration spec
```

**Examples**:
```bash
/create-spec feature auth-system
/create-spec epic mobile-app
/create-spec refactor legacy-api
```

**What It Does**:
1. Copies template to `.claude/specs/active/`
2. Fills in metadata (date, author, etc.)
3. Opens in editor for completion
4. Saves with proper naming

---

### `/validate-spec`

**Purpose**: Validate specification completeness and quality

**Usage**:
```bash
/validate-spec <spec-file>
/validate-spec <spec-file> --strict
```

**Example**:
```bash
/validate-spec .claude/specs/active/auth-system.md
```

**Checks**:
- ✅ Required sections present
- ✅ Clear acceptance criteria
- ✅ Realistic implementation plan
- ✅ Dependencies identified
- ✅ Test scenarios defined

**Output**: Validation report with pass/fail + recommendations

---

### `/spec-to-tasks`

**Purpose**: Convert specification to orchestration tasks JSON

**Usage**:
```bash
/spec-to-tasks <spec-file>
/spec-to-tasks <spec-file> --output custom-tasks.json
```

**Example**:
```bash
/spec-to-tasks .claude/specs/active/auth-system.md
```

**What It Does**:
1. Parses spec implementation plan
2. Identifies independent vs dependent tasks
3. Assigns specialist agents
4. Creates phased execution plan
5. Generates `.claude/specs/active/tasks/<name>-tasks.json`

**Output**: Structured tasks JSON ready for `/orchestrate`

---

### `/orchestrate`

**Purpose**: Execute tasks in parallel via git worktrees

**Usage**:
```bash
/orchestrate file:tasks.json              # From JSON file
/orchestrate spec:.claude/specs/active/   # From spec
/orchestrate linear:"sprint:current"      # From Linear query
/orchestrate list                         # List active sessions
/orchestrate cleanup:<session-id>         # Clean up session
```

**Examples**:
```bash
# Execute from tasks file
/orchestrate file:.claude/specs/active/tasks/auth-tasks.json

# Execute from spec directly
/orchestrate spec:.claude/specs/active/auth-system.md

# Execute Linear tickets
/orchestrate linear:"label:auto-droidz AND sprint:current"

# Check status
/orchestrate list

# Cleanup after merge
/orchestrate cleanup:20251112-143022
```

**What It Does**:
1. Creates `.runs/<session-id>/` directory
2. Sets up git worktrees for each task
3. Spawns tmux session per task
4. Launches specialist agents
5. Tracks progress & dependencies
6. Monitors completion

**Monitoring**:
```bash
# Attach to tmux session
tmux attach -t droidz-20251112-143022

# View orchestration log
tail -f .runs/.coordination/orchestration.log
```

---

### `/analyze-tech-stack`

**Purpose**: Detect project tech stack and generate framework-specific standards

**Usage**:
```bash
/analyze-tech-stack                      # Auto-detect everything
/analyze-tech-stack --regenerate         # Force regeneration
/analyze-tech-stack --framework react    # Specific framework
```

**What It Detects**:
- ✅ Package manager (bun, pnpm, yarn, npm)
- ✅ Runtime (Node, Bun, Deno)
- ✅ Frameworks (React, Next.js, Vue, etc.)
- ✅ Libraries (testing, state, routing)
- ✅ Build tools (Vite, webpack, etc.)
- ✅ Language (TypeScript, JavaScript)

**What It Generates**:
- `.claude/standards/react.md` - React best practices
- `.claude/standards/typescript.md` - TS conventions
- `.claude/standards/testing.md` - Test patterns
- `.claude/memory/org/tech-stack.json` - Detection results

**Example Output**:
```
✓ Detected: React 18.2.0
✓ Detected: TypeScript 5.3.2
✓ Detected: Vite 5.0.0
✓ Generated: .claude/standards/react.md
✓ Generated: .claude/standards/typescript.md
✓ Saved: .claude/memory/org/tech-stack.json
```

---

### `/check-standards`

**Purpose**: Validate code against project standards and best practices

**Usage**:
```bash
/check-standards                         # Check current file
/check-standards <file-path>             # Check specific file
/check-standards --fix                   # Auto-fix issues
/check-standards --severity critical     # Filter by severity
```

**Examples**:
```bash
/check-standards src/components/LoginForm.tsx
/check-standards --fix
/check-standards --severity high
```

**What It Checks**:
- 🔒 **Security**: SQL injection, XSS, secrets in code
- 📐 **Standards**: Framework conventions, patterns
- ⚡ **Performance**: N+1 queries, large bundles
- 🎨 **Style**: Formatting, naming conventions

**Severity Levels**:
- **Critical**: Security vulnerabilities, blocking issues
- **High**: Bad practices, performance problems
- **Medium**: Conventions, style issues
- **Low**: Suggestions, optimizations

**Output**:
```
Checking: src/components/LoginForm.tsx

[CRITICAL] Hardcoded API key on line 15
  → Move to environment variable
  → Fix: Use process.env.API_KEY

[HIGH] Missing error boundary on line 42
  → Wrap component with ErrorBoundary
  → Fix: <ErrorBoundary><LoginForm /></ErrorBoundary>

[MEDIUM] Non-semantic HTML on line 28
  → Use <button> instead of <div>
  → Fix: <button onClick={handleLogin}>

Summary: 1 critical, 1 high, 1 medium
```

---

### `/save-decision`

**Purpose**: Record architectural and technical decisions

**Usage**:
```bash
/save-decision <category> <decision> [rationale]
```

**Categories**:
- `architecture` - System design choices
- `security` - Security policies
- `performance` - Performance guidelines
- `testing` - Test strategies
- `deployment` - Deployment decisions
- `tooling` - Tool selections

**Examples**:
```bash
/save-decision architecture "Use PostgreSQL for database" "Strong typing, excellent migrations, ACID compliance"

/save-decision security "Require MFA for all users" "SOC2 compliance requirement"

/save-decision performance "API responses must be <200ms" "User experience target, P95 latency"

/save-decision testing "Maintain 80% code coverage" "Quality gate for CI/CD"
```

**What It Does**:
1. Appends to `.claude/memory/org/decisions.json`
2. Timestamps decision
3. Links to author (if available)
4. Makes searchable for future reference

**Retrieval**:
```bash
/load-memory org --category architecture
```

---

### `/load-memory`

**Purpose**: Load persistent memory into current context

**Usage**:
```bash
/load-memory org                          # Organization memory
/load-memory user                         # User memory
/load-memory all                          # Both
/load-memory org --category architecture  # Specific category
```

**Examples**:
```bash
# Load all team decisions
/load-memory org

# Load personal preferences
/load-memory user

# Load architecture decisions only
/load-memory org --category architecture
```

**Organization Memory**:
- Architectural decisions
- Code patterns & conventions
- Tech stack detection results

**User Memory**:
- Personal preferences
- Recent session context
- Work-in-progress state

**Output**:
```
Loaded Organization Memory:

📊 Tech Stack:
  - Runtime: Node.js 20.10.0
  - Framework: React 18.2.0
  - Package Manager: bun

📋 Decisions (5):
  - [Architecture] Use PostgreSQL for database
  - [Security] Require MFA for all users
  - [Performance] API responses <200ms
  - [Testing] 80% code coverage minimum
  - [Deployment] Use AWS ECS Fargate

🎨 Patterns (3):
  - Repository pattern for data access
  - Custom useApi hook for API calls
  - Functional components with TypeScript
```

---

### `/optimize-context`

**Purpose**: Reduce context window usage while preserving quality

**Usage**:
```bash
/optimize-context                         # Standard optimization
/optimize-context --analyze-only          # Show analysis only
/optimize-context --aggressive            # Aggressive optimization
/optimize-context --checkpoint            # Create backup first
```

**What It Does**:
1. **Analyzes Context**:
   - System prompt (CLAUDE.md + standards)
   - Conversation history (all turns)
   - Code context (loaded files)
   - Tool results (command outputs)

2. **Applies Optimization**:
   - Keep last 10 turns verbatim
   - Summarize older conversation (11-50 turns)
   - Ultra-compact ancient history (50+ turns)
   - Remove old file contents (can re-read)
   - Compress tool results

3. **Preserves**:
   - All CLAUDE.md standards
   - Current task context
   - Recent changes
   - Critical decisions

**Example Output**:
```
📊 Context Window Analysis

Current Usage: 142,847 / 200,000 tokens (71.4%) ⚠️

Breakdown:
├─ System Prompt: 8,234 tokens (5.8%)
├─ Conversation: 89,456 tokens (62.6%)
├─ Code Context: 38,291 tokens (26.8%)
└─ Tool Results: 6,866 tokens (4.8%)

Recommendations:
1. Compact conversation (turns 1-40) → Save 45k tokens
2. Remove old files (6 files, 20+ turns old) → Save 18k tokens
3. Compress tool results → Save 4k tokens

Total Savings: ~67k tokens (47% reduction)
New Usage: ~75k tokens (37.5%)

Apply? (y/n)
```

**Reduction Targets**:
- Standard: 60-70% reduction
- Aggressive: 70-80% reduction

---

## Auto-Activating Skills

### spec-shaper

**Auto-Activates**: When user has fuzzy ideas or incomplete requirements

**Triggers**:
- "I want to build..."
- "Can you help me create..."
- "Add a feature for..."
- Vague descriptions without clear requirements

**What It Does**:
1. Asks clarifying questions
2. Identifies missing requirements
3. Suggests structure
4. Guides spec creation
5. Validates completeness

**Example Interaction**:
```
User: "I want to build a dashboard"

[spec-shaper activates]