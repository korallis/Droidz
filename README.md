# 🤖 Droidz - Factory.ai Droid CLI Edition

> **Complete AI development framework with parallel execution, persistent memory, and intelligent automation for Factory.ai Droid CLI**

Transform complex projects into coordinated, parallel workflows using git worktrees, specialist droids, and automated task orchestration - now fully optimized for Factory.ai's Droid CLI.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.2.0--droid-blue.svg)](https://github.com/korallis/Droidz)
[![Status](https://img.shields.io/badge/status-production%20ready-green.svg)](https://github.com/korallis/Droidz)
[![Platform](https://img.shields.io/badge/platform-Factory.ai%20Droid%20CLI-orange.svg)](https://factory.ai)

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

- [What Is Droidz for Factory.ai?](#what-is-droidz-for-factoryai)
- [Droid CLI vs Claude Code Version](#-droid-cli-vs-claude-code-version)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Core Features](#core-features)
- [Complete Command Reference](#complete-command-reference)
- [Specialist Droids](#specialist-droids)
- [Complete Workflows](#complete-workflows)
- [Orchestration System](#orchestration-system)
- [Memory System](#memory-system)
- [Spec-Driven Development](#spec-driven-development)
- [Graphite Integration](#graphite-integration)
- [Architecture](#architecture)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Migration from Claude Code](#migration-from-claude-code)
- [Frequently Asked Questions](#frequently-asked-questions)

---

## What Is Droidz for Factory.ai?

Droidz is a **production-ready Factory.ai Droid CLI framework** that provides:

### 🎯 Core Capabilities

**Parallel Execution via Droid CLI**
- ✅ True parallel task execution using `droid exec` in git worktrees
- ✅ Autonomous droids with `--auto medium` autonomy levels
- ✅ Tmux session management for real-time monitoring
- ✅ 515-line orchestration engine with dependency tracking
- ✅ Realistic 1.5-2.5x speedup for parallelizable work

**Intelligent Automation**
- ✅ 7 specialist droids (codegen, test, refactor, infra, integration, orchestrator, generalist)
- ✅ 13 slash commands for complete workflow control
- ✅ Automatic task complexity analysis
- ✅ Spec-driven development with validation

**Persistent Intelligence**
- ✅ Organization memory (decisions, patterns, tech-stack)
- ✅ User memory (preferences, context, work-in-progress)
- ✅ Cross-session context persistence
- ✅ Automatic tech stack detection

**Developer Experience**
- ✅ Fuzzy idea → structured spec transformation
- ✅ Context window optimization (60-80% reduction)
- ✅ Standards enforcement with framework-specific rules
- ✅ Graphite stacked diffs workflow integration

### 🆚 Droid CLI vs Claude Code Version

This repository contains **TWO editions** of Droidz:

1. **`claude-code` branch** - For Claude Code CLI users
2. **`factory-ai` branch** - For Factory.ai Droid CLI users ⭐ **(You are here)**

Both editions now have **100% feature parity** with auto-activation!

#### Technical Differences

| Feature | Claude Code | Factory.ai Droid CLI |
|---------|-------------|---------------------|
| **CLI Command** | `claude` | `droid` |
| **Execution** | Direct tool calls | `droid exec` commands |
| **Auto-Skills** | ✅ 4 auto-activating | ✅ 4 auto-activating (via hooks) |
| **Autonomy** | Always available | `--auto` flags required |
| **Delegation** | Task tool | Direct `droid exec` |
| **Directory** | `.claude/` | `.factory/` |
| **Agents/Droids** | `.claude/agents/` | `.factory/droids/` |
| **Commands** | 10 slash commands | 13 slash commands |

#### User Experience Comparison

**✅ What's THE SAME:**
- Auto-activation of skills (spec-shaper, auto-orchestrator, graphite, memory-manager)
- Parallel orchestration with git worktrees
- Specialist agents/droids capabilities
- Memory system (org/user memory)
- Spec-driven development workflow
- All slash commands
- Context optimization

**🔄 What's DIFFERENT:**
- **CLI tool**: Use `claude` vs `droid` command
- **Implementation**: Native skills vs hooks-based auto-activation
- **Directory names**: `.claude/` vs `.factory/`

#### Which Edition Should You Use?

**Use Claude Code Edition** (`claude-code` branch) if:
- ✅ You're using Claude Code CLI in your workflow
- ✅ You prefer native skill system
- ✅ You want Claude's built-in tooling

**Use Factory.ai Edition** (`factory-ai` branch) if:
- ✅ You're using Factory.ai Droid CLI
- ✅ You want autonomy level controls (`--auto low/medium/high`)
- ✅ You need enterprise permission gates
- ✅ You prefer explicit control over droid capabilities

**Both editions provide identical user experience with 100% feature parity!**

**Switch Between Editions:**
```bash
# Use Factory.ai edition
git checkout factory-ai

# Use Claude Code edition
git checkout claude-code
```

---

## Quick Start

### Prerequisites

**Factory.ai Droid CLI** - Must be installed first:
```bash
# Install Droid CLI
npm install -g @factory-ai/droid-cli
# or
brew install factory-ai/tap/droid

# Verify installation
droid --version
```

**System Dependencies** (auto-installed by framework):
- Git (for worktrees)
- jq (for JSON processing)
- tmux (for session management)
- Node.js/Bun (for TypeScript coordinator)

### 30-Second Setup

```bash
# Clone the repository
git clone https://github.com/korallis/Droidz.git
cd Droidz

# Checkout the Factory.ai Droid CLI branch
git checkout factory-ai

# Run initialization
droid /droidz-init

# Start building!
droid /orchestrate
```

That's it! The framework is ready to use.

---

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Clone and setup in one go
git clone https://github.com/korallis/Droidz.git
cd Droidz
git checkout factory-ai
droid /droidz-init
```

### Option 2: Manual Setup

```bash
# 1. Clone repository
git clone https://github.com/korallis/Droidz.git
cd Droidz

# 2. Checkout Factory.ai branch
git checkout factory-ai

# 3. Verify directory structure
ls -la .factory/
# Should see: droids/, commands/, scripts/, orchestrator/, etc.

# 4. Install system dependencies (if needed)
brew install git jq tmux bun

# 5. Initialize framework
droid /droidz-init --full
```

### Verification

After installation, verify everything works:

```bash
# Check droids are available
ls .factory/droids/
# Should show: codegen.md, test.md, refactor.md, etc.

# Check commands are available
ls .factory/commands/
# Should show: orchestrate.md, spec-shaper.md, etc.

# Test a simple command
droid /droidz-init --status
```

---

## Core Features

### 🎯 1. Parallel Orchestration

Execute multiple tasks simultaneously in isolated git worktrees:

```bash
# From Linear query
droid /orchestrate linear:"sprint:current"

# From spec file
droid /orchestrate spec:.factory/specs/active/feature-auth.md

# From JSON file
droid /orchestrate file:tasks.json
```

**What happens:**
1. ✅ Creates isolated git worktrees (`.runs/TASK-001/`, `.runs/TASK-002/`, etc.)
2. ✅ Spawns tmux sessions for each task (`droidz-TASK-001`, `droidz-TASK-002`)
3. ✅ Automatically starts specialist droids via `droid exec --auto medium`
4. ✅ Runs tasks in true parallel (3-5x faster for independent work)
5. ✅ Coordinates completion and merge readiness

### 🧠 2. Persistent Memory

Remember decisions, patterns, and context across sessions:

```bash
# Save architectural decision
droid /save-decision architecture "Using event-driven architecture for scalability"

# Save code pattern
droid /save-decision patterns "Always validate user input at API boundary"

# Load memory in new session
droid /load-memory org

# Check what's remembered
cat .factory/memory/org/decisions.json
```

**Memory structure:**
```
.factory/memory/
├── org/                     # Team-wide knowledge
│   ├── decisions.json       # Architectural decisions
│   ├── patterns.json        # Code patterns
│   └── tech-stack.json      # Detected stack
└── user/                    # Personal preferences
    ├── preferences.json     # User preferences
    └── context.json         # Session context
```

### ⚡ 3. Auto-Activation Skills

**100% Feature Parity with Claude Code** - Skills automatically activate when needed using Factory.ai's hooks system:

```bash
# No explicit activation needed - skills activate automatically!
```

**Auto-Activating Skills:**

1. **🎯 Spec Shaper** - Auto-activates when detecting:
   - Fuzzy ideas or incomplete requirements
   - User mentions "build", "create", "add feature" without details
   - Requests lacking specific requirements
   - Ideas needing clarification before implementation

   ```bash
   # User: "I want to build a user dashboard"
   # → /spec-shaper AUTOMATICALLY activates
   # → Guides through specification creation
   # → Asks clarifying questions
   # → Creates structured spec file
   ```

2. **🔄 Auto Orchestrator** - Auto-activates when detecting:
   - Complex multi-task requests (3+ components)
   - Multiple independent areas (frontend + backend + tests + infra)
   - Requests mentioning parallel work
   - Tasks estimated >2 hours with parallelizable components

   ```bash
   # User: "Build auth system with OAuth, JWT, and user management"
   # → /auto-orchestrate AUTOMATICALLY activates
   # → Analyzes task complexity
   # → Recommends orchestration approach
   # → Generates tasks.json for parallel execution
   ```

3. **🥞 Graphite Workflow** - Auto-activates when detecting:
   - Mentions of "stacked diffs", "stacked PRs", "Graphite", or "gt"
   - Questions about managing dependent pull requests
   - Requests to break large work into reviewable chunks

   ```bash
   # User: "How do I create stacked PRs?"
   # → /graphite AUTOMATICALLY activates
   # → Provides Graphite workflow guidance
   # → Shows relevant gt commands
   # → Guides through stack management
   ```

4. **🧠 Memory Manager** - Auto-activates after subagent completion:
   - Saves architectural decisions to org memory
   - Captures code patterns to pattern library
   - Records user preferences to user memory
   - Automatically runs `/save-decision` when appropriate

   ```bash
   # After droid completes task:
   # → Memory Manager AUTOMATICALLY activates
   # → Detects: "Chose PostgreSQL for better JSON support"
   # → Saves to: .factory/memory/org/decisions.json
   ```

**How It Works:**

Auto-activation is powered by Factory.ai's **hooks system** (`.factory/settings.json`):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "name": "auto-activate-spec-shaper",
        "type": "prompt",
        "prompt": "PROACTIVELY detect if user has fuzzy ideas..."
      }
    ],
    "SubagentStop": [
      {
        "name": "auto-activate-memory-manager",
        "type": "prompt",
        "prompt": "PROACTIVELY detect and save important context..."
      }
    ]
  }
}
```

**Key Benefits:**

- ✅ **Zero Manual Work** - Skills activate automatically like Claude Code
- ✅ **Intelligent Detection** - Context-aware activation based on user intent
- ✅ **Seamless UX** - Works in the background without interruption
- ✅ **100% Feature Parity** - Exact same auto-activation as Claude Code version

### 📝 4. Spec-Driven Development

Transform fuzzy ideas into structured specifications:

```bash
# Interactive spec creation
droid /spec-shaper "user authentication system"

# Validate spec
droid /validate-spec .factory/specs/active/auth-system.md

# Generate orchestration tasks
droid /spec-to-tasks .factory/specs/active/auth-system.md

# Execute the spec
droid /orchestrate spec:.factory/specs/active/auth-system.md
```

**Spec types:**
- 📄 **Feature Spec** - Single feature (1-2 weeks)
- 📚 **Epic Spec** - Large initiative (multiple weeks)
- 🔧 **Refactor Spec** - Code improvements
- 🔌 **Integration Spec** - Third-party services

### 🔍 5. Orchestration Intelligence

Automatically analyze if work should be parallelized:

```bash
# Analyze task complexity
droid /auto-orchestrate "build dashboard with analytics, notifications, and settings"

# Output shows:
# ✅ Complexity: High
# ✅ Recommendation: Orchestrate (3x speedup)
# ✅ Task breakdown: 4 parallel tasks
# ✅ Specialists: 2x codegen, 1x test, 1x infra
```

### 🥞 6. Graphite Stacked Diffs

Complete Graphite CLI workflow integration:

```bash
# Initial setup
droid /graphite setup

# Create stacked PRs
droid /graphite create

# Modify and sync
droid /graphite modify
droid /graphite sync

# Get help
droid /graphite help
```

### 🎨 7. Framework-Specific Standards

Auto-generated standards for your tech stack:

```bash
# Analyze and generate standards
droid /analyze-tech-stack

# Generated standards in .factory/standards/:
# - react.md (React best practices)
# - typescript.md (TypeScript rules)
# - nextjs.md (Next.js patterns)
# - tailwind.md (Tailwind conventions)
# - testing.md (Test standards)

# Check code against standards
droid /check-standards src/components/Button.tsx
```

### ⚡ 7. Context Optimization

Reduce context window usage by 60-80%:

```bash
# Analyze current context
droid /optimize-context --analyze

# Apply optimizations
droid /optimize-context --aggressive

# Create checkpoint
droid /optimize-context --checkpoint
```

---

## Complete Command Reference

### Core Commands

#### `/droidz-init` - Initialize Framework
```bash
# Interactive setup
droid /droidz-init

# Quick minimal setup
droid /droidz-init --quick

# Full comprehensive setup
droid /droidz-init --full

# Check status
droid /droidz-init --status
```

**What it does:**
- ✅ Verifies Git repository
- ✅ Checks dependencies (git, jq, tmux, bun)
- ✅ Detects tech stack
- ✅ Configures standards
- ✅ Creates example specs
- ✅ Validates orchestration system

---

#### `/orchestrate` - Parallel Execution
```bash
# From Linear query
droid /orchestrate linear:"sprint:current"
droid /orchestrate linear:"label:auto-droidz AND status:Todo"

# From spec file
droid /orchestrate spec:.factory/specs/active/feature-auth.md

# From JSON file
droid /orchestrate file:tasks.json

# List active orchestrations
droid /orchestrate list

# Cleanup orchestration
droid /orchestrate cleanup:20250113-143022-12345

# Interactive mode
droid /orchestrate
```

**Task JSON format:**
```json
{
  "tasks": [
    {
      "key": "AUTH-001",
      "title": "Implement login API",
      "description": "Build REST API for user login",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "AUTH-002",
      "title": "Write integration tests",
      "description": "Test auth flow end-to-end",
      "specialist": "droidz-test",
      "priority": 2
    }
  ]
}
```

**Output:**
- Creates worktrees in `.runs/TASK-KEY/`
- Spawns tmux sessions `droidz-TASK-KEY`
- Starts droids automatically with `droid exec --auto medium`
- Logs to `.runs/.coordination/orchestration.log`

---

#### `/spec-shaper` - Transform Ideas to Specs
```bash
# Interactive mode
droid /spec-shaper

# With topic hint
droid /spec-shaper "authentication system"

# Complex feature
droid /spec-shaper "e-commerce checkout flow"
```

**Interactive questions:**
1. What are you trying to build?
2. Why do you need it?
3. Who is it for?
4. When is it needed?
5. How complex is it?

**Output:**
- Creates spec in `.factory/specs/active/`
- Includes functional requirements
- Defines acceptance criteria (SMART format)
- Breaks down implementation approach
- Generates task breakdown for orchestration

---

#### `/auto-orchestrate` - Analyze Complexity
```bash
# Analyze task
droid /auto-orchestrate "build user dashboard"

# Analyze spec file
droid /auto-orchestrate spec:.factory/specs/active/dashboard.md

# Interactive analysis
droid /auto-orchestrate
```

**Decision criteria:**
- ✅ Orchestrate if: 5+ files, multiple specialists, >2 hours work
- ❌ Don't orchestrate if: Single file, simple fix, <1 hour work

**Output:**
- Complexity level (Low/Medium/High)
- Recommendation (Orchestrate/Sequential/Hybrid)
- Task breakdown with specialists
- Estimated speedup (e.g., "3x faster")
- Coordination complexity assessment

---

#### `/create-spec` - Create Specification
```bash
# Create feature spec
droid /create-spec feature auth-system

# Create epic spec
droid /create-spec epic mobile-app

# Create refactor spec
droid /create-spec refactor api-modernization

# Create integration spec
droid /create-spec integration stripe-payments
```

**Templates:**
- `feature-spec.md` - Standard feature template
- `epic-spec.md` - Multi-feature initiative template

---

#### `/validate-spec` - Validate Specification
```bash
# Validate spec file
droid /validate-spec .factory/specs/active/auth-system.md
```

**Checks:**
- ✅ Required sections present
- ✅ Clear acceptance criteria
- ✅ Realistic implementation plan
- ✅ Dependencies identified
- ✅ SMART criteria compliance

---

#### `/spec-to-tasks` - Generate Tasks
```bash
# Generate tasks from spec
droid /spec-to-tasks .factory/specs/active/auth-system.md
```

**Output:**
- Generates `tasks.json` for orchestration
- Assigns appropriate specialists
- Identifies dependencies
- Sets priorities
- Ready for `/orchestrate file:tasks.json`

---

#### `/graphite` - Stacked Diffs Workflow
```bash
# Initial setup
droid /graphite setup

# Create new PR in stack
droid /graphite create

# Modify current PR
droid /graphite modify

# Submit to GitHub
droid /graphite submit

# Sync stack with trunk
droid /graphite sync

# Show all commands
droid /graphite help
```

**Complete workflow:**
1. `gt create -am "feat: Add feature"` - Create PR
2. `gt submit` - Submit to GitHub
3. `gt create -am "feat: Build on previous"` - Stack another PR
4. `gt submit` - Submit stacked PR
5. `gt upstack onto` - Sync changes upstack
6. `gt sync` - Sync with trunk after merges

---

#### `/save-decision` - Record Decision
```bash
# Save architectural decision
droid /save-decision architecture "Using microservices for scalability"

# Save pattern
droid /save-decision patterns "Always use dependency injection"

# Save tech choice
droid /save-decision tech-stack "Using PostgreSQL for relational data"
```

**Categories:**
- `architecture` - High-level system design
- `patterns` - Code patterns and practices
- `tech-stack` - Technology choices
- `security` - Security decisions
- `performance` - Performance optimizations

---

#### `/load-memory` - Load Memory
```bash
# Load organization memory
droid /load-memory org

# Load specific category
droid /load-memory org --category decisions

# Load user memory
droid /load-memory user
```

**Memory types:**
- **org** - Team-wide decisions, patterns, tech-stack
- **user** - Personal preferences, context, WIP

---

#### `/analyze-tech-stack` - Detect Stack
```bash
# Analyze and generate standards
droid /analyze-tech-stack

# Regenerate standards
droid /analyze-tech-stack --regenerate

# Analyze specific framework
droid /analyze-tech-stack --framework react
```

**Detects:**
- 📦 Package managers (npm, yarn, pnpm, bun)
- 🎨 Frameworks (React, Vue, Next.js, Nuxt, SvelteKit)
- 📝 Languages (TypeScript, JavaScript, Python, Go, Rust)
- 🧪 Test frameworks (Jest, Vitest, Pytest, Go test)
- 🏗️ Build tools (Webpack, Vite, esbuild, Rollup)

**Generates standards in:**
- `.factory/standards/react.md`
- `.factory/standards/typescript.md`
- `.factory/standards/nextjs.md`
- `.factory/standards/tailwind.md`
- etc.

---

#### `/check-standards` - Validate Code
```bash
# Check specific file
droid /check-standards src/components/Button.tsx

# Check with auto-fix
droid /check-standards src/components/Button.tsx --fix

# Check with severity filter
droid /check-standards src/api/ --severity error
```

**Validates:**
- ✅ Framework-specific patterns
- ✅ Naming conventions
- ✅ Code structure
- ✅ Best practices compliance
- ✅ Security patterns

---

#### `/optimize-context` - Reduce Context
```bash
# Analyze current usage
droid /optimize-context --analyze-only

# Apply aggressive optimization
droid /optimize-context --aggressive

# Create checkpoint
droid /optimize-context --checkpoint
```

**Optimizations:**
- 📉 Removes redundant information
- 🗜️ Compresses similar patterns
- 📊 Prioritizes recent/relevant context
- 💾 Creates checkpoints for recovery
- ⚡ Typical reduction: 60-80%

---

## Specialist Droids

Droidz includes 7 specialist droids, each optimized for specific tasks:

### 1. `droidz-orchestrator` - Coordination Specialist

**Purpose:** Plans and coordinates parallel execution

**When to use:**
- Complex multi-task requests
- 3+ distinct components
- Parallel-friendly work
- Sprint planning

**Capabilities:**
- ✅ Task decomposition
- ✅ Specialist assignment
- ✅ Dependency analysis
- ✅ Worktree creation
- ✅ Progress monitoring

**Invoked by:**
```bash
droid /orchestrate <source>
```

---

### 2. `droidz-codegen` - Feature Implementation

**Purpose:** Implements features and bugfixes with comprehensive tests

**When to use:**
- New feature development
- Bug fixes
- API implementation
- Component creation

**Capabilities:**
- ✅ Feature implementation
- ✅ Test writing
- ✅ Documentation
- ✅ Commit creation
- ✅ Standards compliance

**Automatically assigned to:**
- Feature implementation tasks
- Bug fix tasks
- General coding work

---

### 3. `droidz-test` - Testing Specialist

**Purpose:** Writes and fixes tests, ensures coverage

**When to use:**
- Writing new tests
- Fixing failing tests
- Increasing coverage
- Integration testing

**Capabilities:**
- ✅ Unit test creation
- ✅ Integration test writing
- ✅ E2E test setup
- ✅ Coverage analysis
- ✅ Test debugging

**Automatically assigned to:**
- Test implementation tasks
- Coverage improvement tasks
- Test debugging work

---

### 4. `droidz-refactor` - Code Cleanup

**Purpose:** Refactors code without behavior changes

**When to use:**
- Code cleanup
- Structural improvements
- Reducing duplication
- Modernizing patterns

**Capabilities:**
- ✅ Safe refactoring
- ✅ Duplication removal
- ✅ Pattern modernization
- ✅ Maintains behavior
- ✅ Comprehensive testing

**Automatically assigned to:**
- Refactoring tasks
- Code cleanup work
- Technical debt reduction

---

### 5. `droidz-infra` - Infrastructure Specialist

**Purpose:** Handles CI/CD, deployment, and infrastructure

**When to use:**
- CI/CD setup
- Deployment configuration
- Docker setup
- GitHub Actions
- Infrastructure as code

**Capabilities:**
- ✅ Pipeline configuration
- ✅ Docker setup
- ✅ Deployment automation
- ✅ Infrastructure code
- ✅ Environment management

**Automatically assigned to:**
- CI/CD tasks
- Deployment tasks
- Infrastructure work

---

### 6. `droidz-integration` - API Integration

**Purpose:** Integrates external services and APIs

**When to use:**
- Third-party API integration
- Webhook setup
- External service connection
- Data sync implementation

**Capabilities:**
- ✅ API client creation
- ✅ Webhook handling
- ✅ Auth integration
- ✅ Error handling
- ✅ Secret management

**Automatically assigned to:**
- API integration tasks
- External service work
- Webhook implementation

---

### 7. `droidz-generalist` - Fallback Specialist

**Purpose:** Handles miscellaneous tasks

**When to use:**
- Unclear task type
- Multi-domain work
- Exploratory tasks
- Edge cases

**Capabilities:**
- ✅ Conservative changes
- ✅ Incremental approach
- ✅ Multi-domain support
- ✅ Safe defaults

**Automatically assigned to:**
- Unspecified tasks
- Multi-domain tasks
- Exploratory work

---

## Complete Workflows

### Workflow 1: Feature Development from Idea

**Scenario:** You have a fuzzy idea for a feature

```bash
# Step 1: Shape the idea into a spec
droid /spec-shaper "user profile page with avatar upload"

# You'll be asked:
# - What should users be able to do?
# - What information needs to be displayed?
# - Performance requirements?
# - Timeline?

# Output: .factory/specs/active/user-profile.md

# Step 2: Validate the spec
droid /validate-spec .factory/specs/active/user-profile.md

# Output: ✅ All checks passed

# Step 3: Analyze if orchestration is beneficial
droid /auto-orchestrate spec:.factory/specs/active/user-profile.md

# Output: ✅ Recommendation: Orchestrate (3x speedup)
#         Task breakdown: 4 parallel tasks

# Step 4: Generate orchestration tasks
droid /spec-to-tasks .factory/specs/active/user-profile.md

# Output: tasks.json created

# Step 5: Execute in parallel
droid /orchestrate file:tasks.json

# Output: 4 tmux sessions created, droids working in parallel

# Step 6: Monitor progress
tmux attach -t droidz-PROFILE-001  # Frontend component
tmux attach -t droidz-PROFILE-002  # Backend API
tmux attach -t droidz-PROFILE-003  # File upload service
tmux attach -t droidz-PROFILE-004  # Integration tests

# Step 7: After completion, review and merge
# Each droid commits its changes in isolated worktree
# Review changes and merge when ready
```

**Result:** Feature implemented 3x faster with clear specs and parallel execution

---

### Workflow 2: Sprint Planning with Linear

**Scenario:** You have a sprint worth of Linear tickets

```bash
# Step 1: Fetch tickets from Linear
droid /orchestrate linear:"sprint:current AND status:Todo"

# Orchestrator:
# - Fetches tickets via Linear MCP
# - Analyzes complexity
# - Creates task breakdown
# - Assigns specialists

# Step 2: Review proposed plan
# (Orchestrator shows task breakdown for approval)

# Step 3: Approve and execute
# Orchestrator creates:
# - Worktree for each ticket
# - Tmux session for each task
# - Starts appropriate droid in each session

# Step 4: Droids work in parallel
# - droidz-codegen implements features
# - droidz-test writes tests
# - droidz-infra updates CI/CD
# - droidz-integration adds API integrations

# Step 5: Auto-update Linear tickets
# Droids update ticket status as they progress

# Step 6: Review and merge
# Each worktree has completed work
# Review, test, and merge sequentially
```

**Result:** Entire sprint completed in 1/3 the time

---

### Workflow 3: Large Refactoring

**Scenario:** Modernize legacy codebase

```bash
# Step 1: Create refactor spec
droid /create-spec refactor api-modernization

# Edit the spec to define:
# - What should NOT change (behavior preservation)
# - What should change (patterns, structure)
# - Success criteria

# Step 2: Validate spec
droid /validate-spec .factory/specs/active/api-modernization.md

# Step 3: Analyze complexity
droid /auto-orchestrate spec:.factory/specs/active/api-modernization.md

# Output: ⚠️ Recommendation: Sequential (tightly coupled)
#         Reason: Refactoring requires understanding full context

# Step 4: Execute sequentially
droid exec --auto medium --droid droidz-refactor "Read .factory/specs/active/api-modernization.md and refactor the API layer according to the spec. Ensure all tests pass and behavior is preserved."

# Step 5: Monitor progress
# Single droid works through refactoring systematically
# Runs tests after each change
# Commits incrementally

# Step 6: Review changes
git diff main...api-modernization
# Behavior-preserving refactoring with comprehensive tests
```

**Result:** Safe, systematic refactoring with confidence

---

### Workflow 4: Graphite Stacked PRs

**Scenario:** Large feature that needs incremental review

```bash
# Step 1: Setup Graphite (first time only)
droid /graphite setup

# Step 2: Start from main
gt checkout main

# Step 3: Implement database schema (PR #1)
# ... make changes ...
gt create -am "feat(db): Add user profiles table"
gt submit

# Step 4: Implement API (PR #2, builds on #1)
# ... make changes ...
gt create -am "feat(api): Add profile endpoints"
gt submit

# Step 5: Implement UI (PR #3, builds on #2)
# ... make changes ...
gt create -am "feat(ui): Add profile page component"
gt submit

# Step 6: Add tests (PR #4, builds on all)
# ... make changes ...
gt create -am "test: Add profile feature tests"
gt submit

# Now you have a stack:
# PR #4: Tests
# PR #3: UI
# PR #2: API
# PR #1: Database

# Step 7: Respond to review feedback on PR #2
gt checkout pr-2-branch
# ... make changes ...
gt modify -a
gt submit
gt upstack onto  # Update PRs #3 and #4

# Step 8: Merge from bottom up
# Merge PR #1 → #2 → #3 → #4
gt sync  # After each merge
```

**Result:** Large feature reviewed incrementally, faster approvals

---

### Workflow 5: Bug Triage to Fix

**Scenario:** Production bug needs immediate attention

```bash
# Step 1: Quick assessment
droid /auto-orchestrate "fix authentication timeout bug"

# Output: ❌ Don't orchestrate (simple bug fix)

# Step 2: Execute fix with appropriate droid
droid exec --auto medium --droid droidz-codegen "Fix authentication timeout bug in src/auth/session.ts. The session expires too quickly. Update timeout to 24 hours and add tests."

# Step 3: Monitor execution
# Droid:
# - Reads the file
# - Identifies the issue
# - Fixes the timeout value
# - Writes regression tests
# - Runs all tests
# - Commits with clear message

# Step 4: Review and deploy
git diff
# Clear fix with tests

# Step 5: Deploy
git push
```

**Result:** Bug fixed quickly with tests and clear commit

---

## Orchestration System

### How Orchestration Works

The orchestration system uses **git worktrees** and **tmux sessions** for true parallel execution:

```
Main Repository
├── .runs/
│   ├── TASK-001/              # Isolated worktree #1
│   │   ├── .git/              # Separate git directory
│   │   ├── .factory-context.md   # Task instructions
│   │   ├── .droidz-meta.json     # Progress tracking
│   │   └── src/               # Code changes
│   │
│   ├── TASK-002/              # Isolated worktree #2
│   │   ├── .git/
│   │   ├── .factory-context.md
│   │   └── src/
│   │
│   └── .coordination/         # Shared coordination
│       ├── orchestration-SESSION.json
│       ├── locks.json
│       └── messages.json
│
└── [main codebase]
```

### Tmux Session Structure

Each task runs in its own tmux session:

```bash
# List all droid sessions
tmux ls | grep droidz

# Output:
# droidz-TASK-001: 1 windows (created Mon Jan 13 14:30:22 2025)
# droidz-TASK-002: 1 windows (created Mon Jan 13 14:30:25 2025)
# droidz-TASK-003: 1 windows (created Mon Jan 13 14:30:28 2025)

# Attach to a session
tmux attach -t droidz-TASK-001

# Inside session, droid is executing:
# $ droid exec --auto medium --droid droidz-codegen "Read .factory-context.md..."
#
# [droidz-codegen] Reading task instructions...
# [droidz-codegen] Implementing authentication API...
# [droidz-codegen] Writing tests...
# [droidz-codegen] All tests passing ✓
# [droidz-codegen] Committing changes...
# [droidz-codegen] Task complete!

# Detach from session
# Press: Ctrl+B, then D

# Switch between sessions
# Press: Ctrl+B, then S
```

### Coordination Protocol

Droids coordinate through shared files:

**orchestration-SESSION.json:**
```json
{
  "sessionId": "20250113-143022-12345",
  "status": "in_progress",
  "tasks": [
    {
      "key": "TASK-001",
      "status": "in_progress",
      "specialist": "droidz-codegen",
      "progress": 60
    },
    {
      "key": "TASK-002",
      "status": "completed",
      "specialist": "droidz-test"
    }
  ],
  "worktrees": [
    "/path/to/.runs/TASK-001",
    "/path/to/.runs/TASK-002"
  ],
  "sessions": [
    "droidz-TASK-001",
    "droidz-TASK-002"
  ]
}
```

**locks.json:**
```json
{
  "package.json": {
    "lockedBy": "TASK-001",
    "lockedAt": "2025-01-13T14:35:22Z"
  }
}
```

**messages.json:**
```json
[
  {
    "from": "TASK-001",
    "to": "TASK-002",
    "message": "Completed API changes, you can proceed with integration tests",
    "timestamp": "2025-01-13T14:40:15Z"
  }
]
```

### Autonomy Levels

Droids execute with specific autonomy levels via `--auto` flags:

| Level | What It Allows | Use Case |
|-------|----------------|----------|
| *(default)* | Read-only (cat, ls, git status, git diff) | Safe reconnaissance |
| `--auto low` | File creation/editing, formatters | Documentation, code formatting |
| `--auto medium` | Package install, tests, local commits | **Development work (default)** |
| `--auto high` | Git push, deployments | CI/CD pipelines |
| `--skip-permissions-unsafe` | ALL operations (⚠️ dangerous) | Isolated containers only |

**Default for orchestration:** `--auto medium`
- ✅ Can modify files
- ✅ Can install packages
- ✅ Can run tests
- ✅ Can create local commits
- ❌ Cannot push to remote (requires manual approval)

---

## Memory System

### Organization Memory

Team-wide knowledge persisted across all sessions:

**`.factory/memory/org/decisions.json`**
```json
{
  "architecture": [
    {
      "decision": "Using microservices for scalability",
      "rationale": "Need independent deployment and scaling",
      "timestamp": "2025-01-13T14:30:00Z",
      "category": "architecture"
    }
  ],
  "patterns": [
    {
      "pattern": "Always validate user input at API boundary",
      "rationale": "Defense in depth security",
      "timestamp": "2025-01-13T14:35:00Z",
      "category": "security"
    }
  ]
}
```

**`.factory/memory/org/tech-stack.json`**
```json
{
  "detected": {
    "frameworks": ["Next.js", "React"],
    "languages": ["TypeScript", "JavaScript"],
    "buildTools": ["Vite"],
    "testFrameworks": ["Vitest"],
    "packageManager": "bun"
  },
  "standards": [
    "react.md",
    "typescript.md",
    "nextjs.md"
  ]
}
```

### User Memory

Personal preferences and context:

**`.factory/memory/user/preferences.json`**
```json
{
  "codeStyle": "functional",
  "preferredApproach": "test-driven",
  "commitStyle": "conventional",
  "reviewPreferences": {
    "autoApprove": false,
    "requireTests": true
  }
}
```

### Using Memory

```bash
# Save decision
droid /save-decision architecture "Event-driven for scalability"

# Load in new session
droid /load-memory org

# Memory is automatically injected into droid context
# Droids will follow saved patterns and decisions
```

---

## Spec-Driven Development

### Spec Templates

Located in `.factory/specs/templates/`:

**feature-spec.md:**
```markdown
# Feature: [Feature Name]

## Summary
[1-2 sentence description]

## Business Value
[Why we're building this]

## Requirements

### Functional
- [ ] Requirement 1
- [ ] Requirement 2

### Non-Functional
- Performance: [targets]
- Security: [requirements]

## Acceptance Criteria
1. **GIVEN** [context] **WHEN** [action] **THEN** [outcome]
2. **GIVEN** [context] **WHEN** [action] **THEN** [outcome]

## Implementation Approach
[Technical approach]

## Task Breakdown
1. [Task 1] - [specialist] - [effort]
2. [Task 2] - [specialist] - [effort]

## Dependencies
- [Dependency 1]
- [Dependency 2]

## Estimated Effort
[Time estimate]
```

### Creating Specs

```bash
# Method 1: From template
droid /create-spec feature user-notifications

# Method 2: From fuzzy idea
droid /spec-shaper "notification system"
# Interactive questions guide you to a complete spec

# Method 3: Manual creation
# Create .factory/specs/active/feature-name.md
# Follow template structure
```

### Validating Specs

```bash
droid /validate-spec .factory/specs/active/user-notifications.md

# Checks:
# ✅ Has summary
# ✅ Has business value
# ✅ Requirements defined
# ✅ Acceptance criteria (SMART)
# ✅ Implementation approach
# ✅ Task breakdown
# ✅ Effort estimated

# Output:
# ✓ All validation checks passed
# Ready for task generation
```

### Executing Specs

```bash
# Generate tasks
droid /spec-to-tasks .factory/specs/active/user-notifications.md

# Output: tasks.json created with:
# - Task breakdown
# - Specialist assignments
# - Dependencies
# - Priorities

# Execute
droid /orchestrate spec:.factory/specs/active/user-notifications.md

# Droids implement according to spec
```

---

## Graphite Integration

Complete workflow for stacked pull requests using Graphite CLI.

### Setup (First Time)

```bash
# Use the helper command
droid /graphite setup

# Or manually:
npm install -g @withgraphite/graphite-cli@stable
gt auth
gt init
```

### Creating Your First Stack

```bash
# Step 1: Start from main
gt checkout main

# Step 2: Create first PR
# ... make changes ...
gt create -am "feat(api): Add authentication endpoint"
gt submit

# Step 3: Build upstack
# ... make more changes ...
gt create -am "feat(api): Add JWT token generation"
gt submit

# Step 4: Continue stacking
# ... make more changes ...
gt create -am "feat(api): Add token validation middleware"
gt submit

# Now you have:
# ┌─────────────────────────────────────┐
# │  PR #3: Token validation middleware │
# ├─────────────────────────────────────┤
# │  PR #2: JWT token generation        │
# ├─────────────────────────────────────┤
# │  PR #1: Authentication endpoint     │
# ├─────────────────────────────────────┤
# │  main                               │
# └─────────────────────────────────────┘
```

### Managing Your Stack

```bash
# View stack
gt stack

# Navigate
gt up      # Move up one level
gt down    # Move down one level
gt top     # Jump to top
gt bottom  # Jump to bottom

# Make changes to middle PR
gt checkout pr-2-branch
# ... edit files ...
gt modify -a
gt submit

# Sync changes upstack
gt upstack onto

# Sync with trunk after merges
gt sync
```

### Helper Commands

All Graphite commands are available via `/graphite`:

```bash
droid /graphite create   # Guide for creating PRs
droid /graphite modify   # Guide for modifying PRs
droid /graphite submit   # Guide for submitting PRs
droid /graphite sync     # Guide for syncing stack
droid /graphite help     # Complete reference
```

---

## Architecture

### Directory Structure

```
.factory/
├── droids/                      # 7 specialist droids
│   ├── droidz-orchestrator.md
│   ├── droidz-codegen.md
│   ├── droidz-test.md
│   ├── droidz-refactor.md
│   ├── droidz-infra.md
│   ├── droidz-integration.md
│   └── droidz-generalist.md
│
├── commands/                    # 13 slash commands
│   ├── droidz-init.md
│   ├── orchestrate.md
│   ├── spec-shaper.md
│   ├── auto-orchestrate.md
│   ├── create-spec.md
│   ├── validate-spec.md
│   ├── spec-to-tasks.md
│   ├── graphite.md
│   ├── analyze-tech-stack.md
│   ├── check-standards.md
│   ├── save-decision.md
│   ├── load-memory.md
│   └── optimize-context.md
│
├── scripts/
│   └── orchestrator.sh          # 515-line orchestration engine
│
├── orchestrator/                # TypeScript coordinator
│   ├── task-coordinator.ts
│   ├── worktree-setup.ts
│   ├── types.ts
│   └── config.json
│
├── memory/
│   ├── org/                     # Team-wide memory
│   │   ├── decisions.json
│   │   ├── patterns.json
│   │   └── tech-stack.json
│   └── user/                    # Personal memory
│       ├── preferences.json
│       └── context.json
│
├── specs/
│   ├── templates/               # Spec templates
│   │   ├── feature-spec.md
│   │   └── epic-spec.md
│   ├── active/                  # Active specs
│   └── archive/                 # Completed specs
│
├── standards/
│   └── templates/               # Framework standards
│       ├── react.md
│       ├── typescript.md
│       ├── nextjs.md
│       ├── python.md
│       └── vue.md
│
├── hooks/                       # Lifecycle hooks
│   ├── auto-lint.sh
│   └── monitor-context.sh
│
├── skills/                      # Preserved for reference
│   ├── spec-shaper/
│   ├── auto-orchestrator/
│   ├── memory-manager/
│   └── graphite-stacked-diffs/
│
├── product/                     # Vision and roadmap
│   ├── vision.md
│   ├── roadmap.md
│   └── use-cases.md
│
└── settings.json                # Framework configuration
```

### Execution Flow

```
User Command
    │
    ├─→ /orchestrate
    │   │
    │   ├─→ orchestrator.sh
    │   │   │
    │   │   ├─→ Parse tasks (Linear/Spec/JSON)
    │   │   │
    │   │   ├─→ task-coordinator.ts
    │   │   │   ├─→ Create worktrees
    │   │   │   └─→ Setup metadata
    │   │   │
    │   │   ├─→ Create tmux sessions
    │   │   │
    │   │   └─→ start_droid_in_session()
    │   │       │
    │   │       └─→ droid exec --auto medium \
    │   │             --droid [specialist] \
    │   │             "[task prompt]"
    │   │
    │   └─→ Droids work in parallel
    │       ├─→ droidz-codegen (worktree 1)
    │       ├─→ droidz-test (worktree 2)
    │       └─→ droidz-infra (worktree 3)
    │
    ├─→ /spec-shaper
    │   │
    │   └─→ Interactive questions
    │       └─→ Generate spec file
    │
    ├─→ /auto-orchestrate
    │   │
    │   └─→ Analyze complexity
    │       └─→ Recommend approach
    │
    └─→ [other commands]
```

### Data Flow

```
Input Sources
    │
    ├─→ Linear API
    │   └─→ Fetch tickets
    │       └─→ Convert to tasks JSON
    │
    ├─→ Spec Files
    │   └─→ Parse markdown
    │       └─→ Extract task breakdown
    │           └─→ Generate tasks JSON
    │
    └─→ JSON Files
        └─→ Load directly
            │
            └─→ Orchestrator
                │
                ├─→ Create worktrees
                │   └─→ .runs/TASK-001/
                │       ├─→ .factory-context.md
                │       └─→ .droidz-meta.json
                │
                ├─→ Spawn droids
                │   └─→ droid exec --auto medium
                │       │
                │       └─→ Read context
                │           └─→ Execute task
                │               └─→ Update metadata
                │                   └─→ Commit changes
                │
                └─→ Coordinate
                    └─→ .runs/.coordination/
                        ├─→ orchestration.json
                        ├─→ locks.json
                        └─→ messages.json
```

---

## Best Practices

### 1. Orchestration

**DO:**
- ✅ Use orchestration for 3+ independent tasks
- ✅ Ensure tasks can run in parallel
- ✅ Assign appropriate specialists
- ✅ Monitor tmux sessions regularly
- ✅ Review each worktree before merging

**DON'T:**
- ❌ Orchestrate tightly coupled tasks
- ❌ Orchestrate simple single-file changes
- ❌ Ignore failed tasks in tmux sessions
- ❌ Merge without reviewing changes
- ❌ Skip dependency analysis

### 2. Spec Creation

**DO:**
- ✅ Use `/spec-shaper` for fuzzy ideas
- ✅ Define SMART acceptance criteria
- ✅ Break down implementation clearly
- ✅ Identify dependencies early
- ✅ Validate specs before execution

**DON'T:**
- ❌ Skip spec validation
- ❌ Use vague acceptance criteria
- ❌ Ignore dependencies
- ❌ Over-complicate simple features
- ❌ Skip business value section

### 3. Memory Usage

**DO:**
- ✅ Save important architectural decisions
- ✅ Document patterns as you discover them
- ✅ Load memory at session start
- ✅ Keep tech-stack.json updated
- ✅ Use categories consistently

**DON'T:**
- ❌ Save every small decision
- ❌ Duplicate decisions
- ❌ Ignore existing patterns
- ❌ Skip memory loading
- ❌ Mix categories

### 4. Graphite Stacking

**DO:**
- ✅ Keep PRs small and focused
- ✅ Build logical progression
- ✅ Sync after trunk changes
- ✅ Use `gt upstack onto` after middle PR changes
- ✅ Merge bottom-up

**DON'T:**
- ❌ Create massive PRs
- ❌ Stack unrelated changes
- ❌ Forget to sync
- ❌ Skip upstack sync
- ❌ Merge out of order

### 5. Autonomy Management

**DO:**
- ✅ Use `--auto medium` for development
- ✅ Review commits before pushing
- ✅ Monitor droid execution
- ✅ Understand permission levels
- ✅ Use appropriate autonomy for task

**DON'T:**
- ❌ Use `--skip-permissions-unsafe` in production
- ❌ Grant unnecessary permissions
- ❌ Skip review of automated commits
- ❌ Ignore autonomy warnings
- ❌ Use `--auto high` without understanding risks

---

## Troubleshooting

### Orchestration Issues

**Problem: Worktree creation failed**
```bash
# Solution: Prune stale worktrees
git worktree prune

# Then cleanup and retry
droid /orchestrate cleanup:SESSION_ID
droid /orchestrate [source]
```

**Problem: Tmux session not responding**
```bash
# Solution: Kill and recreate
tmux kill-session -t droidz-TASK-001

# Manually restart droid
cd .runs/TASK-001
droid exec --auto medium --droid droidz-codegen "Read .factory-context.md..."
```

**Problem: Droids not executing**
```bash
# Check Droid CLI is installed
droid --version

# Check autonomy level
# Ensure using --auto medium or higher for write operations

# Check droid logs
cat .runs/TASK-001/droid-execution.log
```

### Memory Issues

**Problem: Decisions not persisting**
```bash
# Check memory directory exists
ls -la .factory/memory/org/

# Verify JSON is valid
cat .factory/memory/org/decisions.json | jq .

# If corrupted, restore from backup
cp .factory/memory/org/decisions.json.backup .factory/memory/org/decisions.json
```

**Problem: Memory not loading**
```bash
# Manually load and verify
droid /load-memory org

# Check file permissions
ls -la .factory/memory/org/decisions.json

# Should be readable
```

### Spec Issues

**Problem: Spec validation failing**
```bash
# Check required sections
droid /validate-spec .factory/specs/active/feature.md

# Common issues:
# - Missing acceptance criteria
# - No implementation approach
# - Vague requirements
# - Missing effort estimate

# Fix and revalidate
```

**Problem: Task generation failing**
```bash
# Ensure spec is validated first
droid /validate-spec .factory/specs/active/feature.md

# Check spec has task breakdown section
grep -A 10 "Task Breakdown" .factory/specs/active/feature.md

# Regenerate
droid /spec-to-tasks .factory/specs/active/feature.md
```

### Graphite Issues

**Problem: Stack shows outdated**
```bash
# Sync with trunk
gt sync

# Fix stack inconsistencies
gt stack fix
```

**Problem: Conflicts after rebase**
```bash
# Resolve conflicts manually
# Edit files to resolve conflicts

# Continue rebase
git add .
gt continue
```

**Problem: Want to reorder stack**
```bash
# Use interactive rebase
git rebase -i main

# Then fix stack
gt stack fix
```

### Droid CLI Issues

**Problem: Droid command not found**
```bash
# Install Droid CLI
npm install -g @factory-ai/droid-cli

# Or via brew
brew install factory-ai/tap/droid

# Verify
droid --version
```

**Problem: Permission denied errors**
```bash
# Check autonomy level
# Ensure using appropriate --auto flag

# For development work, use:
droid exec --auto medium [command]

# NOT:
droid exec [command]  # Too restrictive (read-only)
```

**Problem: Droids timing out**
```bash
# Increase timeout (default: 8000ms)
droid exec --auto medium --timeout 30000 [command]

# Or split into smaller tasks
```

---

## Migration from Claude Code

If you're coming from the Claude Code version of Droidz:

### Key Differences

| Aspect | Claude Code | Factory.ai Droid CLI |
|--------|-------------|---------------------|
| **Directory** | `.claude/` | `.factory/` |
| **Agents** | `.claude/agents/` | `.factory/droids/` |
| **Execution** | Direct tool calls | `droid exec` commands |
| **Auto-Skills** | 4 auto-activating | ✅ **4 auto-activating via hooks** |
| **Commands** | 10 slash commands | 13 slash commands |
| **Autonomy** | Always available | `--auto` flags required |
| **Feature Parity** | N/A | ✅ **100% feature parity achieved** |

### Migration Steps

```bash
# 1. Checkout Factory.ai branch
git checkout factory-ai

# 2. Review changes
git diff claude-code...factory-ai

# 3. Test commands
droid /droidz-init --status
droid /orchestrate list

# 4. Enjoy auto-activation via hooks!
# Skills now auto-activate automatically (100% feature parity):
# - spec-shaper → Auto-activates on fuzzy ideas
# - auto-orchestrator → Auto-activates on complex requests
# - graphite → Auto-activates on stacked diffs mentions
# - memory-manager → Auto-activates after subagent completion

# 5. Verify orchestration
droid /orchestrate file:tasks.json
# Check tmux sessions spawn correctly
tmux ls | grep droidz
```

### What Stays the Same

- ✅ **Auto-activation of all 4 skills** (100% feature parity!)
- ✅ All specialist capabilities
- ✅ Parallel execution architecture
- ✅ Memory system (org/user memory)
- ✅ Spec-driven development workflow
- ✅ Worktree management
- ✅ Tmux coordination
- ✅ All slash commands functionality

### What Changed

- 🔄 **CLI tool**: Use `droid` instead of `claude` command
- 🔄 **Implementation**: Auto-activation via hooks instead of native skills
- 🔄 Orchestrator uses `droid exec` instead of Task tool
- 🔄 Autonomy levels required (`--auto medium`)
- 🔄 Path references use `.factory/` instead of `.claude/`

**User Experience Impact**: Minimal - same features, just different CLI tool!

### Compatibility

Commands work the same way:
```bash
# Claude Code version:
claude /orchestrate spec:.claude/specs/active/feature.md

# Factory.ai version:
droid /orchestrate spec:.factory/specs/active/feature.md
```

### Frequently Asked Questions

**Q: Do both editions work the same from a user perspective?**
A: Yes! With auto-activation implemented, both editions provide identical user experience. The only difference is which CLI tool you use (`claude` vs `droid`).

**Q: Is there any feature missing in Factory.ai edition?**
A: No! We've achieved 100% feature parity. All 4 skills auto-activate just like Claude Code edition.

**Q: Can I switch between editions?**
A: Yes! Just switch git branches:
```bash
git checkout factory-ai   # For Factory.ai Droid CLI
git checkout claude-code  # For Claude Code CLI
```

**Q: Which edition is better?**
A: Both are identical in functionality. Choose based on which CLI platform you're using:
- Using Claude Code CLI? → `claude-code` branch
- Using Factory.ai Droid CLI? → `factory-ai` branch

**Q: How does auto-activation work in Factory.ai edition?**
A: It uses Factory.ai's hooks system (`.factory/settings.json`) to detect conditions and automatically invoke commands, providing the same seamless experience as Claude Code's native skills.

---

## Contributing

We welcome contributions! Here's how:

### Reporting Issues

1. Check existing issues first
2. Use issue templates
3. Provide reproduction steps
4. Include system info (OS, Droid CLI version, etc.)

### Submitting PRs

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit PR with clear description

### Development Setup

```bash
# Clone repository
git clone https://github.com/korallis/Droidz.git
cd Droidz

# Checkout factory-ai branch
git checkout factory-ai

# Make changes
# Test changes

# Commit using conventional commits
git commit -m "feat: add new command"

# Push and create PR
git push origin feature-branch
```

---

## Support

### Get Help

- 💬 **Discord Community**: [Join here](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
- 🐛 **Issues**: [GitHub Issues](https://github.com/korallis/Droidz/issues)
- 📧 **Email**: [Support email]
- 📚 **Docs**: This README + inline command help

### Show Your Support

If this framework helps you:

- ⭐ Star the repository
- 💝 [Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)
- 🗣️ Share with your team
- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation

---

## License

MIT License - see [LICENSE](LICENSE) file for details

---

## Acknowledgments

- **Factory.ai** - For creating the Droid CLI platform
- **Anthropic** - For Claude and Claude Code
- **Community** - For feedback and contributions
- **Ray Fernando's Discord** - For inspiring this framework

---

## Quick Reference Card

```bash
# Initialize
droid /droidz-init

# Create spec from idea
droid /spec-shaper "feature idea"

# Validate spec
droid /validate-spec .factory/specs/active/feature.md

# Analyze if should orchestrate
droid /auto-orchestrate "task description"

# Generate tasks
droid /spec-to-tasks .factory/specs/active/feature.md

# Execute in parallel
droid /orchestrate spec:.factory/specs/active/feature.md

# Monitor sessions
tmux ls | grep droidz
tmux attach -t droidz-TASK-001

# Save decision
droid /save-decision architecture "decision text"

# Load memory
droid /load-memory org

# Analyze tech stack
droid /analyze-tech-stack

# Check standards
droid /check-standards src/file.ts

# Graphite setup
droid /graphite setup
droid /graphite create
droid /graphite submit

# Optimize context
droid /optimize-context --aggressive
```

---

**Built with ❤️ for the developer community**

**Powered by Factory.ai Droid CLI** 🤖
