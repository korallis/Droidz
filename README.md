# 🤖 Droidz - Spec-Driven Development for AI

**Transform how you build software with AI agents**. Droidz is a complete framework that brings structure, standards, and systematic workflows to AI-assisted development.

Instead of ad-hoc prompting and context loss, Droidz gives you:
- 📋 **Spec-driven workflow** - Plan → Spec → Tasks → Implementation
- 🚀 **Parallel execution** - Run multiple task groups simultaneously (NEW!)
- 🤖 **8 specialized agents** - Each expert in their domain
- 📚 **50+ production skills** - From TDD to Next.js to security patterns
- 📏 **Team standards** - Consistent code across all features
- 🔄 **Repeatable process** - Same quality, every time

**Stop reinventing workflows. Start shipping faster.**

---

## 💬 Join Our Discord Community

**Built specifically for Ray Fernando's Discord members!** 🎯

Get early access, share tips, connect with contributors, and influence future development.

**[→ Join Discord Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

---

## 💝 Support This Project

If Droidz saves you time, consider supporting its development!

**[→ Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

Your support helps maintain and improve this framework! 🙏

### With Gratitude
We're deeply thankful for the generosity of friends who keep this framework alive:

- **Sorennza**
- **Ray Fernando**
- **Douwe de Vries**

Every contribution—large or small—directly fuels new features, improvements, and continued open distribution. Thank you for believing in Droidz.

---

## Quick Start

```bash
# 1. Navigate to your project
cd /path/to/your/project

# 2. Install Droidz (one command!)
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)

# 3. Follow the interactive menu to choose your AI platform
# (Factory AI, Claude Code, Cursor, etc.)

# 4. Restart your AI tool

# 5. Start using workflows!
> /standards-shaper  # Set up your project standards
> /plan-product      # Plan your product
> /shape-spec        # Design a feature
```

---

## Table of Contents

- [Why Droidz?](#why-droidz)
- [The Droidz Workflow](#the-droidz-workflow)
- [Installation](#installation)
- [Commands Reference](#commands-reference)
- [Specialized Agents](#specialized-agents)
- [Best Practices](#best-practices)
- [Customization](#customization)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Why Droidz?

### The Problem with AI Development

Without structure, AI-assisted development leads to:
- ❌ Inconsistent code quality
- ❌ Lost context between sessions
- ❌ Vague requirements → Rework
- ❌ No team alignment
- ❌ Hard to onboard new devs

### The Droidz Solution

Droidz brings **systematic workflows** to AI development:

```
Planning → Specification → Task Breakdown → Implementation
   ↓            ↓               ↓                ↓
Product      Detailed       Actionable     Guided execution
 docs         spec.md        tasks.md      with standards
```

**Result**: Predictable, high-quality output every time.

---

## The Droidz Workflow

Droidz follows a proven 8-phase cycle for building features:

```
┌─────────────────────────────────────────────────────────────┐
│                    DROIDZ WORKFLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 0: Setup Standards        → /standards-shaper       │
│           ↓                                                 │
│  Phase 1: Product Planning       → /plan-product           │
│           ↓                                                 │
│  Phase 2: Spec Shaping           → /shape-spec             │
│           ↓                                                 │
│  Phase 3: Spec Writing           → /write-spec             │
│           ↓                                                 │
│  Phase 4: Task Creation          → /create-tasks           │
│           ↓                                                 │
│  Phase 5: Task Orchestration     → /orchestrate-tasks      │
│           ↓                                                 │
│  Phase 6: Implementation         → /implement-tasks  🚀     │
│           │                        (3 MODES!)               │
│           │                                                 │
│           ├─→ A) Parallel (FAST) - All tasks run together  │
│           ├─→ B) Interactive - Live progress updates       │
│           └─→ C) Sequential - One at a time                │
│           ↓                                                 │
│  Phase 7: Continuous Improvement → iterate & refine        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why This Works

1. **Context Persists** - Specs and standards live in your repo
2. **Clear Handoffs** - Each phase produces artifacts for the next
3. **Parallel Execution** - Implement multiple task groups simultaneously (NEW!)
4. **Progress Tracking** - See real-time updates as tasks complete
5. **Team Alignment** - Everyone works from the same spec
6. **Quality Gates** - Standards enforced automatically
7. **Scalable** - Same process for small features or large systems

---

## 🚀 NEW: Parallel Execution

**Speed up implementation by 4x!** Droidz now supports parallel execution using Factory AI's Droid Exec.

### Three Execution Modes

When you run `/implement-tasks`, choose how to execute:

**A) Parallel Execution (FAST)** ⚡
- All task groups run simultaneously
- Uses Factory's headless Droid Exec mode
- Auto-loads API key from `droidz/config.yml`
- Bounded concurrency (configurable, default: 4)
- Robust error handling
- Best for: Multi-group implementations

```bash
# Just run the script - API key loads from droidz/config.yml
$ bash droidz/specs/[spec]/implementation/run-parallel.sh

🚀 Starting parallel implementation...
📄 Loading configuration from droidz/config.yml
✅ Using API key from config.yml
⚙️  Autonomy level: medium
🔢 Max parallel: 4

▶️  Starting: 1-database-setup.md
▶️  Starting: 2-api-endpoints.md
▶️  Starting: 3-frontend-ui.md
▶️  Starting: 4-testing.md
✅ Completed: 1-database-setup.md
✅ Completed: 2-api-endpoints.md
✅ Completed: 3-frontend-ui.md
✅ Completed: 4-testing.md

🎉 All task groups completed!
```

**B) Interactive with Live Progress** 📊
- Sequential execution with real-time TodoWrite updates
- See tool calls and results as they happen
- Best for: Learning, debugging, following along

**C) Sequential Delegation** 🔄
- Traditional one-at-a-time execution
- Simple and reliable
- Best for: Single task groups

### Requirements for Parallel Mode

**One-Time Setup:**

```bash
# 1. Copy the config template
cp droidz/config.yml.template droidz/config.yml

# 2. Get your Factory API key
# Visit: https://app.factory.ai/settings/api-keys

# 3. Edit droidz/config.yml and add your key:
factory_api_key: "fk-your-key-here"

# That's it! The script will auto-load your key from config.yml
# ⚠️  config.yml is in .gitignore - your key won't be committed
```

**Optional Configuration:**

You can also configure in `droidz/config.yml`:
- `default_autonomy_level`: "low", "medium", or "high" (default: "medium")
- `max_parallel_executions`: 1-10 (default: 4)

**Running Parallel Execution:**

```bash
# Just run the script - API key loads automatically
bash droidz/specs/[your-spec]/implementation/run-parallel.sh
```

---

## Installation

### Prerequisites

- One of these AI tools:
  - Factory AI
  - Claude Code
  - Cursor
  - Cline
  - Codex CLI
  - VS Code with AI extension

### Install Command

```bash
# Navigate to your project first!
cd /path/to/your/project

# Run the installer
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)
```

### What Gets Installed

The installer creates these directories in your project:

```
your-project/
├── .factory/          # Factory AI droids & commands (if selected)
│   ├── droids/        # 8 specialized droids
│   └── commands/      # 20+ workflow commands
├── .claude/           # Claude Code agents & commands (if selected)
│   ├── agents/        # 8 specialized agents
│   └── commands/      # 20+ workflow commands
└── droidz/            # Shared across all platforms
    ├── standards/     # Your team's coding standards
    │   ├── global/    # Global conventions
    │   ├── backend/   # API, database patterns
    │   ├── frontend/  # Components, styling
    │   └── testing/   # Test patterns
    ├── product/       # Product documentation
    │   ├── mission.md
    │   ├── roadmap.md
    │   └── tech-stack.md
    └── specs/         # Feature specifications
        └── [feature]/
            ├── spec.md
            ├── tasks.md
            └── planning/
```

Everything is **checked into git** and **shared with your team**.

### Post-Installation

1. **Restart your AI tool** - Required for new commands/agents to load
2. **Verify installation**:
   ```
   > /commands     # See available commands
   > /droids       # See available droids (Factory AI)
   > /agents       # See available agents (Claude Code)
   ```

---

## Commands Reference

Droidz provides 20+ commands organized by phase. Here are the essential ones:

### Setup & Planning Commands

#### `/standards-shaper` ⭐ START HERE

**Purpose**: Create project-wide coding standards

**When to use**: Once per project, before any development

**What it does**:
- Detects your tech stack (React, Next.js, TypeScript, etc.)
- Creates standards for global, backend, frontend, testing
- Generates dos/don'ts for consistency

**Output**:
```
droidz/standards/
├── global/
│   ├── coding-principles.md
│   ├── error-handling.md
│   └── security.md
├── backend/
│   ├── api-design.md
│   └── database.md
├── frontend/
│   ├── components.md
│   └── styling.md
└── testing/
    └── testing-patterns.md
```

**Example**:
```
> /standards-shaper

AI: I'll analyze your project and create standards...
AI: Detected: Next.js 14, TypeScript, Tailwind, Prisma
AI: Creating standards with framework-specific examples...

✅ Created 12 standards files
✅ All standards include your actual tech stack
```

---

#### `/plan-product`

**Purpose**: Define product vision and roadmap

**When to use**: Starting new products, major milestones, team onboarding

**What it does**:
- Asks questions about your product
- Creates mission statement
- Builds phased roadmap
- Documents tech stack decisions

**Output**:
```
droidz/product/
├── mission.md        # Vision, goals, success metrics
├── roadmap.md        # Phases, features, timeline
└── tech-stack.md     # Technologies and rationale
```

**Example**:
```
> /plan-product

AI: What problem does your product solve?
You: Task management for remote teams

AI: Who are your target users?
You: Remote engineering teams of 5-50 people

[More questions...]

✅ Created mission.md
✅ Created roadmap.md (4 phases)
✅ Created tech-stack.md
```

---

### Specification Commands

#### `/shape-spec`

**Purpose**: Shape requirements for a new feature

**When to use**: Before building anything new

**What it does**:
- Asks clarifying questions
- Researches similar implementations (if Exa/Ref available)
- Saves requirements and decisions
- Creates spec folder structure

**Output**:
```
droidz/specs/2024-11-24-user-authentication/
├── planning/
│   ├── requirements.md   # What you need
│   ├── decisions.md      # Key choices made
│   └── visuals/          # Wireframes, screenshots
└── README.md             # Overview
```

**Example**:
```
> /shape-spec

AI: What feature are you planning?
You: User authentication with OAuth

AI: Which OAuth providers?
You: Google and GitHub

AI: What user data do you need to store?
You: Email, name, profile picture

[More questions...]

✅ Saved requirements.md
✅ Saved decisions.md
✅ Created spec folder
```

---

#### `/write-spec`

**Purpose**: Create detailed specification from shaped requirements

**When to use**: After shaping (Phase 2 complete)

**What it does**:
- Reads shaped requirements
- Generates comprehensive spec document
- Includes architecture, APIs, data models, UI, security, testing

**Output**:
```
droidz/specs/2024-11-24-user-authentication/
├── spec.md              # ⭐ THE SPEC
├── planning/
│   └── requirements.md
└── README.md
```

**spec.md structure**:
```markdown
# User Authentication Specification

## 1. Overview
## 2. User Stories
## 3. Technical Architecture
## 4. Data Models
## 5. API Endpoints
## 6. UI/UX Flow
## 7. Security Considerations
## 8. Testing Strategy
## 9. Success Metrics
```

**Example**:
```
> /write-spec

AI: Reading shaped requirements...
AI: Generating specification...

✅ Created spec.md (2,400 lines)
✅ Includes:
   - 5 user stories
   - Database schema
   - 8 API endpoints
   - Security checklist
   - 12 test scenarios
```

---

### Implementation Commands

#### `/create-tasks`

**Purpose**: Break spec into implementable tasks

**When to use**: After spec is written

**What it does**:
- Reads spec.md
- Breaks into logical task groups
- Creates tasks with dependencies
- Adds acceptance criteria

**Output**:
```
droidz/specs/2024-11-24-user-authentication/
├── spec.md
├── tasks.md             # ⭐ IMPLEMENTATION TASKS
└── planning/
```

**tasks.md structure**:
```markdown
# Implementation Tasks

## Task Group 1: Database Setup
- [ ] 1.1: Create users table
- [ ] 1.2: Create oauth_tokens table
- [ ] 1.3: Add database indexes

## Task Group 2: OAuth Integration
- [ ] 2.1: Set up OAuth configs
- [ ] 2.2: Create callback endpoints
- [ ] 2.3: Handle token exchange

## Task Group 3: Frontend
- [ ] 3.1: Create login page
- [ ] 3.2: Add OAuth buttons
- [ ] 3.3: Handle redirects

## Task Group 4: Testing
- [ ] 4.1: Unit tests for OAuth
- [ ] 4.2: E2E login flow test
- [ ] 4.3: Security tests
```

**Example**:
```
> /create-tasks

AI: Reading spec.md...
AI: Identifying task groups...
AI: Creating tasks with dependencies...

✅ Created tasks.md
✅ Found 4 task groups
✅ Total: 23 tasks
```

---

#### `/orchestrate-tasks`

**Purpose**: Plan multi-agent implementation

**When to use**: Before implementing (optional but recommended)

**What it does**:
- Shows task groups
- Lets you assign specialists (if using subagents)
- Maps relevant standards to each group
- Generates implementation prompts

**Output**:
```
droidz/specs/2024-11-24-user-authentication/
├── spec.md
├── tasks.md
├── orchestration.yml    # ⭐ COORDINATION PLAN
└── implementation/
    └── prompts/
        ├── 1-database-setup.md
        ├── 2-oauth-integration.md
        ├── 3-frontend.md
        └── 4-testing.md
```

**Example**:
```
> /orchestrate-tasks

AI: Found 4 task groups. Assign specialists:

1. Database Setup → ?
2. OAuth Integration → ?
3. Frontend → ?
4. Testing → ?

You:
1. backend-specialist
2. backend-specialist
3. frontend-specialist
4. test-specialist

AI: Map standards for each group:

You:
1. backend/*, global/security.md
2. backend/*, global/error-handling.md
3. frontend/*, global/
4. testing/*

✅ Created orchestration.yml
✅ Generated 4 implementation prompts
```

---

#### `/implement-tasks`

**Purpose**: Execute implementation with **parallel execution support**

**When to use**: After tasks are created

**Three Execution Modes**:

**A) Parallel Execution (FAST)** 🚀
- Uses Factory's **Droid Exec** (headless mode) for true concurrent processing
- Runs all task groups simultaneously
- Best for: Multi-group implementations
- Requirements: Factory API key in `droidz/config.yml` (one-time setup)
- Features:
  - Auto-loads API key from config file
  - Bounded concurrency (configurable, default: 4)
  - Configurable autonomy level (low/medium/high)
  - Robust error handling (if one fails, others continue)
  - All droids update same tasks.md file
  - Real-time output from all executions

**B) Interactive with Live Progress** 📊
- Uses Task tool + TodoWrite for real-time updates
- Sequential execution with live progress tracking visible in session
- Best for: Following along, learning, debugging
- Features:
  - Live TodoWrite updates
  - See tool calls and results as they happen
  - Track progress as each task group completes

**C) Sequential Delegation (SIMPLE)** 🔄
- Traditional one-at-a-time implementation
- Best for: Single task group, simple implementations

**Example (Parallel Mode)**:
```bash
> /implement-tasks

How would you like to execute implementation?
A) Parallel Execution (FAST) - Using Droid Exec
B) Interactive with Live Progress - Using TodoWrite
C) Sequential Delegation (SIMPLE)

Enter A, B, or C: A

✅ Created parallel execution setup

PROMPTS: droidz/specs/2024-11-24/implementation/prompts/
├── 1-database-setup.md
├── 2-api-endpoints.md
├── 3-frontend-ui.md
└── 4-testing.md

SCRIPT: run-parallel.sh

TO EXECUTE:
$ bash droidz/specs/2024-11-24/implementation/run-parallel.sh

🚀 Starting parallel implementation...
📄 Loading configuration from droidz/config.yml
✅ Using API key from config.yml
⚙️  Autonomy level: medium
🔢 Max parallel: 4

▶️  Starting: 1-database-setup.md
▶️  Starting: 2-api-endpoints.md
▶️  Starting: 3-frontend-ui.md
▶️  Starting: 4-testing.md
✅ Completed: 1-database-setup.md
✅ Completed: 2-api-endpoints.md
✅ Completed: 3-frontend-ui.md
✅ Completed: 4-testing.md

🎉 All task groups completed!
```

---

### Utility Commands

#### `/improve-skills`

**Purpose**: Enhance AI agent skills

**When to use**: Customizing agent capabilities

**What it does**:
- Shows current skills
- Lets you improve descriptions
- Adds examples
- Makes skills more discoverable

---

## Specialized Agents

Droidz includes 8 specialized agents, each expert in their domain:

### 1. product-planner

**Expertise**: Product strategy, roadmaps, vision

**Use when**:
- Starting new products
- Planning major features
- Creating product documentation

**What it creates**:
- mission.md - Product vision and goals
- roadmap.md - Phased development plan
- tech-stack.md - Technology decisions

**Best for**: Product managers, founders, tech leads

---

### 2. spec-shaper

**Expertise**: Requirements gathering, research

**Use when**:
- Feature requirements are unclear
- Need to research implementations
- Validating technical approach

**What it does**:
- Asks clarifying questions
- Researches patterns (with Exa/Ref)
- Documents decisions
- Shapes clear requirements

**Best for**: Early-stage feature design

---

### 3. spec-writer

**Expertise**: Writing detailed specifications

**Use when**:
- Have shaped requirements
- Need implementable spec
- Building complex features

**What it creates**:
- Comprehensive spec.md with:
  - Architecture
  - Data models
  - API contracts
  - UI flows
  - Security considerations
  - Testing strategy

**Best for**: Detailed feature planning

---

### 4. spec-verifier

**Expertise**: Specification review

**Use when**:
- Validating specs before implementation
- Checking completeness
- Finding gaps

**What it checks**:
- Completeness
- Clarity
- Implementability
- Security considerations
- Test coverage

**Best for**: Quality assurance, pre-implementation review

---

### 5. tasks-list-creator

**Expertise**: Breaking specs into tasks

**Use when**:
- Have completed spec
- Ready to start implementation
- Need task breakdown

**What it creates**:
- tasks.md with:
  - Logical task groups
  - Clear dependencies
  - Acceptance criteria
  - Size estimates

**Best for**: Implementation planning

---

### 6. implementer

**Expertise**: Feature implementation

**Use when**:
- Have tasks defined
- Ready to code
- Following spec and standards

**What it does**:
- Reads spec and tasks
- Implements features
- Follows project standards
- Writes tests
- Updates progress

**Best for**: Actual development work

---

### 7. implementation-verifier

**Expertise**: Testing and verification

**Use when**:
- Implementation complete
- Need to verify against spec
- Running test suite

**What it does**:
- Verifies against acceptance criteria
- Runs all tests
- Checks standards compliance
- Creates verification report

**Best for**: Quality assurance, pre-merge checks

---

### 8. spec-initializer

**Expertise**: Spec folder setup

**Use when**:
- Starting new spec
- Need folder structure

**What it creates**:
- Spec folder with proper structure
- README.md template
- planning/ directory

**Best for**: Quick spec initialization

---

## Best Practices

### ✅ DO:

#### 1. Start with Standards
```
First feature? Run this FIRST:
> /standards-shaper
```
**Why**: Standards ensure consistency from day one

#### 2. Always Shape Before Writing
```
> /shape-spec     # Ask questions, clarify
> /write-spec     # Write detailed spec
```
**Why**: Shaping prevents vague specs and rework

#### 3. Break Down Complex Tasks
```
Don't:
- [ ] Build entire auth system

Do:
- [ ] Create database tables
- [ ] Implement OAuth flow
- [ ] Add login UI
- [ ] Write tests
```
**Why**: Small tasks are easier to implement and track

#### 4. Use Orchestration for Big Features
```
> /orchestrate-tasks   # Plan before implementing
```
**Why**: Coordination prevents conflicts and missed requirements

#### 5. Reference Specs in Code
```typescript
// See droidz/specs/2024-11-24-user-authentication/spec.md
// Section 4.2: OAuth Token Storage
export const saveOAuthToken = async (userId, token) => {
  // ...
}
```
**Why**: Links code to requirements

#### 6. Update Standards as You Learn
```
Found a better pattern? Add to:
droidz/standards/[category]/[pattern].md
```
**Why**: Standards evolve with your team

#### 7. Keep Specs Updated
```
Feature changed during implementation?
Update spec.md to match reality.
```
**Why**: Specs are documentation, keep them accurate

#### 8. Use Task Groups
```
Group 1: Database
Group 2: Backend
Group 3: Frontend
Group 4: Testing
```
**Why**: Logical organization, easier to delegate

---

### ❌ DON'T:

#### 1. Skip Planning
```
❌ Jump straight to code
✅ Plan → Spec → Tasks → Implement
```

#### 2. Write Vague Specs
```
❌ "Add user authentication"
✅ "Implement OAuth 2.0 with Google/GitHub, 
    JWT tokens, refresh token rotation,
    secure storage per spec section 5.3"
```

#### 3. Ignore Standards
```
❌ Implement however you want
✅ Follow droidz/standards/ patterns
```

#### 4. Mix Concerns in Tasks
```
❌ - [ ] Build frontend and backend
✅ - [ ] Build backend API
    - [ ] Build frontend UI
```

#### 5. Lose Context
```
❌ "What were we building again?"
✅ Read droidz/specs/[feature]/spec.md
```

#### 6. Skip Testing
```
❌ Implement without tests
✅ Tests are part of implementation (Task Group 4)
```

#### 7. Work in Isolation
```
❌ Solo development without docs
✅ Use workflow so team can collaborate
```

#### 8. Forget to Commit Droidz Files
```
❌ .gitignore droidz/
✅ Commit specs, standards, product docs
```

---

## Examples

### Example 1: Building a New Feature

**Scenario**: Add real-time notifications to your app

```bash
# Phase 0: Standards exist (one-time setup)
> /standards-shaper
✅ Standards created

# Phase 1: Product context
> /plan-product
✅ Product docs created

# Phase 2: Shape the feature
> /shape-spec

AI: What feature are you planning?
You: Real-time notifications with WebSockets

AI: What types of notifications?
You: New messages, mentions, system alerts

AI: How should they be delivered?
You: Browser push + in-app toast

[More questions...]

✅ requirements.md created

# Phase 3: Write detailed spec
> /write-spec

✅ spec.md created (1,800 lines)
   Includes: WebSocket architecture, message schema,
   push notification setup, UI components

# Phase 4: Break into tasks
> /create-tasks

✅ tasks.md created
   Found 5 task groups, 28 tasks

# Phase 5: Orchestrate (optional)
> /orchestrate-tasks

You assign:
1. WebSocket Server → backend-specialist
2. Message Schema → backend-specialist
3. Push Notifications → backend-specialist
4. UI Components → frontend-specialist
5. E2E Tests → test-specialist

✅ Implementation prompts generated

# Phase 6: Implement
[Use subagents or implement manually with prompts]

✅ All 28 tasks completed
✅ Tests passing
✅ Feature ready to ship! 🚀
```

---

### Example 2: Onboarding New Team Member

```bash
# New dev joins your team

# 1. They clone the repo
git clone your-repo
cd your-repo

# 2. They install Droidz
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)

# 3. They read your docs
cat droidz/product/mission.md      # Understand the product
cat droidz/product/tech-stack.md   # See tech choices
ls droidz/standards/                # Review coding standards

# 4. They explore past features
ls droidz/specs/                    # See all features built
cat droidz/specs/2024-11-20-*/spec.md  # Read a spec

# 5. They start their first feature
> /shape-spec                       # Learn the workflow
> /write-spec
> /create-tasks
> /implement-tasks

# Result: New dev is productive day 1, following same patterns as team
```

---

### Example 3: Mid-Project Standards Creation

**Scenario**: You have a codebase but no standards yet

```bash
# Run standards-shaper
> /standards-shaper

AI: I'll analyze your codebase...
AI: Detected:
   - React 18 with hooks
   - TypeScript (strict mode)
   - Tailwind CSS
   - tRPC API
   - Prisma ORM
   - Vitest tests

AI: Creating standards with your patterns...

✅ Created 15 standards files
✅ Examples use YOUR tech stack
✅ Patterns match YOUR code style

# Now all future features follow these standards automatically
```

---

## Customization

### Modifying Standards

Standards are just markdown files. Edit them to match your team:

```bash
# Edit any standard
code droidz/standards/frontend/components.md

# Add your own patterns
echo "## Our Custom Button Pattern" >> droidz/standards/frontend/components.md
echo "..." >> droidz/standards/frontend/components.md

# Standards are preserved during Droidz updates
```

### Creating Custom Agents

Add your own specialized agents:

```bash
# Factory AI
create .factory/droids/database-expert.md

# Claude Code
create .claude/agents/database-expert.md
```

Format:
```markdown
---
name: database-expert
description: PostgreSQL and Prisma expert for database design
color: blue
model: inherit
---

You are a database design expert...
```

### Adding Custom Commands

```bash
# Factory AI
create .factory/commands/optimize-queries.md

# Claude Code
create .claude/commands/optimize-queries.md
```

---

## Troubleshooting

### Commands Not Showing Up

**Problem**: Installed Droidz but commands don't work

**Solutions**:
1. **Restart your AI tool** (required after installation)
2. Verify installation:
   ```
   > /commands     # Should show 20+ commands
   ```
3. Check file locations:
   ```bash
   ls .factory/commands/  # Factory AI
   ls .claude/commands/   # Claude Code
   ```

---

### Agents Not Activating

**Problem**: Agents don't respond or aren't found

**Solutions**:
1. **Restart your AI tool**
2. Check file structure (must be flat, not nested):
   ```bash
   # ✅ Correct
   .factory/droids/implementer.md
   
   # ❌ Wrong
   .factory/droids/implementation/implementer.md
   ```
3. Verify with:
   ```
   > /droids      # Factory AI
   > /agents      # Claude Code
   ```

---

### Standards Not Being Followed

**Problem**: AI ignores your standards

**Solutions**:
1. **Reference standards explicitly**:
   ```
   > Use the implementer agent and follow droidz/standards/backend/api-design.md
   ```
2. Check standards exist:
   ```bash
   ls droidz/standards/
   ```
3. Make standards more specific (add examples)

---

### Lost Customizations After Update

**Problem**: Your standards got overwritten

**Solutions**:
1. Check backup folder:
   ```bash
   ls /tmp/*droidz*backup*/
   ```
2. Restore from backup:
   ```bash
   cp /tmp/droidz-backup-*/standards/* droidz/standards/
   ```
3. **Prevent in future**: Commit droidz/ to git

---

### Spec Not Loading

**Problem**: Agents can't find your spec

**Solutions**:
1. Use correct path:
   ```
   > Read droidz/specs/2024-11-24-feature-name/spec.md
   ```
2. Check file exists:
   ```bash
   ls droidz/specs/*/spec.md
   ```
3. Verify spec is committed to git

---

## Platform Support

| Platform | Install Location | Content |
|----------|-----------------|---------|
| **Factory AI** | `.factory/` | droids/, commands/ |
| **Claude Code** | `.claude/` | agents/, commands/ |
| **Cursor** | `.cursor/` | workflows/ |
| **Cline** | `.cline/` | prompts/ |
| **Codex CLI** | `.codex/` | playbooks/ |
| **VS Code** | `.vscode/droidz/` | snippets/ |
| **All Platforms** | `droidz/` | standards/, product/, specs/ |

---

## What's Included

### 8 Specialized Agents
- product-planner
- spec-shaper
- spec-writer
- spec-verifier
- spec-initializer
- tasks-list-creator
- implementer
- implementation-verifier

### 20+ Commands
- /standards-shaper
- /plan-product
- /shape-spec
- /write-spec
- /create-tasks
- /orchestrate-tasks
- /implement-tasks
- /improve-skills
- ...and more

### 50+ Production Skills
- **Core Development**: TDD, debugging, security, APIs
- **Modern Frameworks**: Next.js 14, Convex, NeonDB, Tailwind
- **Tools**: Playwright, MCP builder, document processing
- **Productivity**: File organization, continuous improvement

### Complete Standards Library
- Global conventions
- Backend patterns (API, database)
- Frontend patterns (components, styling)
- Testing strategies

---

## Support & Community

### Getting Help

1. **Documentation**: Read `droidz/standards/RECOMMENDED_WORKFLOW.md` after installation
2. **Discord**: Join Ray Fernando's community (link at top)
3. **Issues**: [GitHub Issues](https://github.com/korallis/Droidz/issues)

### Contributing

Droidz is open source! Contributions welcome:
- Improve documentation
- Add new skills
- Create example workflows
- Report bugs

---

## License

MIT License - see LICENSE file for details

---

## Credits

Created by the Droidz community with special thanks to:
- Ray Fernando
- All our supporters and contributors

Built on principles of spec-driven development adapted for modern AI coding agents.

---

**Ready to transform your AI development workflow?**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)
```

**Questions? Join the Discord!** 💬
