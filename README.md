# 🤖 Droidz - Simple Task Automation for Factory.ai

**Droidz helps Factory.ai break big coding tasks into smaller pieces and work on them in parallel.**

Think of it like having a team of specialized helpers instead of doing everything yourself one step at a time.

---

## 📚 Table of Contents

- [First - What is Factory.ai?](#first---what-is-factoryai)
- [What Does Droidz Add?](#what-does-droidz-add)
- [Key Concepts Explained](#key-concepts-explained)
- [Installation](#installation)
- [Your First Task](#your-first-task)
- [Simple Examples (Start Here!)](#simple-examples-start-here)
- [How It Works Behind the Scenes](#how-it-works-behind-the-scenes)
- [All the Commands Explained](#all-the-commands-explained)
- [All the Helper Droids Explained](#all-the-helper-droids-explained)
- [Skills System - Teach Droidz Your Standards](#-skills-system---teach-droidz-your-standards)
- [Advanced Examples](#advanced-examples)
- [Troubleshooting](#troubleshooting)

---

## 🎯 First - What is Factory.ai?

**Factory.ai** is a service where you chat with an AI assistant called **"droid"** (like ChatGPT, but for coding).

You type `droid` in your terminal, and it opens a chat where you can ask it to help with code.

```bash
# In your regular terminal, type this:
droid

# Now you're INSIDE the droid chat! It looks like this:
> _
```

Everything we talk about in this guide happens **INSIDE** that `droid` chat session.

---

## 🚀 What Does Droidz Add?

**Droidz** is a framework (a set of tools) that teaches the main droid how to:

1. **Break big tasks into smaller tasks** automatically
2. **Work on multiple tasks at the same time** (in parallel)
3. **Use specialized helper droids** for different types of work
4. **Track progress** so you can see what's happening

### Without Droidz:
```
You: "Build an authentication system"
Droid: *tries to do everything at once, takes 3 hours*
```

### With Droidz:
```
You: "Build an authentication system"
Droidz: *breaks it into 7 tasks, works on 3 at once, finishes in 2 hours*
        
        ✓ Task 1: Create user database (done)
        ⏳ Task 2: Login endpoint (working...)
        ⏳ Task 3: Registration endpoint (working...)
        ⏳ Task 4: Password reset (working...)
        ⏸ Task 5: Tests (waiting for tasks 2,3,4)
```

**You save time** and **see what's happening** as it works!

---

## 📖 Key Concepts Explained

Let's explain the confusing words:

### "droid" (lowercase)
The **main AI assistant** from Factory.ai. You chat with it.
- You start it by typing `droid` in terminal
- It opens a chat interface
- You type messages or commands

### "droids" (plural, lowercase)
**Helper AI assistants** that the main droid can call for help.
- Like specialists on a team
- Each one is good at specific things
- They're just files ending in `.md` in the `.factory/droids/` folder

### "Droidz" (capital D, with a Z)
**This framework** - the system we built that teaches droid how to use helper droids and work in parallel.

### Slash Commands (like `/status`)
**Shortcuts** you type in the droid chat to do specific things.
- They always start with `/` (slash)
- Like `/status` shows what's happening
- You type them WHERE you chat with droid

### Example to clarify:

```bash
# IN YOUR REGULAR TERMINAL:
cd my-project
droid                    # ← This starts the Factory.ai chat

# NOW YOU'RE IN THE DROID CHAT - you'll see:
> _                      # ← The cursor waiting for you

# TYPE THESE IN THE DROID CHAT:
/status                  # ← Slash command (shows orchestrations)
Build user login         # ← Regular message to droid
droid-parallel "add API" # ← This is WRONG! Don't type "droid" here!

# THE RIGHT WAY:
/parallel "add API"      # ← Slash command that uses the helper droid
```

**Important**: When you're inside the droid chat, you don't type `droid` again. You just type your message or slash commands.

---

## 📦 Installation

### One Command - Installs Everything!

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

**That's it!** The installer will:
- ✅ Check for dependencies (git, jq, tmux)
- ✅ Ask permission before installing anything
- ✅ Download all Droidz files
- ✅ Set up the framework
- ✅ Create configuration files

**After installation:**

```bash
# 1. Check installation status:
./status

# 2. Start droid:
droid

# 3. In droid chat - Enable custom features:
/settings
# Toggle "Custom Commands" ON (for /parallel, /status, etc.)
# Toggle "Custom Droids" ON (for droidz-parallel, etc.)
# Exit and restart droid

# 4. Verify commands loaded:
/commands
# Should see: auto-parallel, parallel, watch, gh-helper, status, summary, attach

# 5. Verify droids loaded:
/droids
# Should see: droidz-parallel, droidz-codegen, etc.
```

**Done!** You're ready to use Droidz. 🎉

**Quick Status Check:**
```bash
./status  # See installation status anytime
```

**Important:** Factory.ai requires "Custom Commands" to be enabled in `/settings` for slash commands to work!

---

## 🎈 Your First Task

Let's try using Droidz for a simple task.

### Quick Status Check

First, verify everything is installed:

```bash
./status
```

You should see:
```
╔══════════════════════════════════════════════════════════════╗
║  ✅ DROIDZ v0.0.7 - INSTALLATION STATUS                      ║
╚══════════════════════════════════════════════════════════════╝

📦 INSTALLATION COMPLETE
  • All v0.0.7 features deployed
  • All documentation updated
  • All commands available
```

### Example: Add a new API endpoint

**Step 1:** Start droid in your project:

```bash
# Terminal:
cd my-project
droid
```

**Step 2:** Ask Droidz to help (inside droid chat):

```
# In droid chat, type this:
/parallel "add a GET /api/users/:id endpoint with validation"
```

**What happens:**

1. Droidz analyzes what you asked for
2. It breaks it into small tasks (usually 3-5)
3. Shows you the plan
4. Starts working on tasks
5. You can watch progress!

**Step 3:** Watch it work:

```
# In droid chat, type:
/status

# You'll see something like:
✅ Phase 1: Create user model (done)
⏳ Phase 2: Build endpoint (working...)
⏸ Phase 3: Write tests (waiting)
```

**Step 4:** Check detailed progress:

```
# In droid chat:
/summary

# Shows:
Progress: 67% complete (2 of 3 tasks done)
✅ USER-001: User model created
⏳ USER-002: Endpoint implementation (in progress)
⏸ USER-003: Tests (pending)
```

That's it! You just used Droidz. 🎉

---

## 🌟 Simple Examples (Start Here!)

### Example 1: Fix a Bug

**What you want:** Fix a bug where users get logged out too quickly.

```bash
# Terminal: Start droid
droid

# Droid chat: Ask for help
/parallel "fix JWT token expiration - should be 7 days not 1 hour"
```

**What Droidz does:**
```
Analyzing... Done! I'll do 3 tasks:

Task 1: Update JWT config from 1h to 7d
Task 2: Add token refresh endpoint  
Task 3: Update tests

Starting Phase 1...
✅ Task 1 complete (config updated)

Starting Phase 2 (parallel)...
⏳ Task 2: Adding refresh endpoint
⏳ Task 3: Updating tests

All done! 🎉
```

**Time saved:** Would take 55 minutes doing one at a time. Droidz does it in 35 minutes!

---

### Example 2: Add Test Coverage

**What you want:** Your user module only has 40% test coverage. Need 80%.

```bash
# Terminal:
droid

# Droid chat:
/parallel "add unit tests for user module to reach 80% coverage"
```

**What Droidz does:**
```
I'll create 4 tasks:

Task 1: Run coverage analysis (10 min)
  └─ Find what's not tested

Task 2: Test user creation (20 min)
Task 3: Test user validation (20 min)  
Task 4: Test user updates (20 min)

Phase 1: Task 1 (10 min)
Phase 2: Tasks 2, 3, 4 in PARALLEL (20 min)

Total time: 30 minutes vs 70 minutes sequential!
```

---

### Example 3: Add a Simple Feature

**What you want:** Add user profile page with avatar upload.

```bash
# Terminal:
droid

# Droid chat:
/parallel "create user profile page with avatar upload"
```

**What Droidz does:**
```
Breaking into 5 tasks...

1. Create profile page component
2. Add avatar upload widget
3. Create API endpoint for avatar
4. Connect frontend to backend
5. Add tests

Estimated: 90 minutes
(Sequential would be 150 minutes - saving 60 minutes!)

Starting work...
```

**Watch progress:**
```
# Type in droid chat:
/status

Active: profile-feature-20251114
Status: 60% complete
  ✅ Profile page
  ✅ Upload widget
  ⏳ API endpoint (in progress)
  ⏸ Integration (waiting)
  ⏸ Tests (waiting)
```

---

## 🔧 How It Works Behind the Scenes

Here's what happens when you use `/parallel`:

### Step 1: You Ask for Help
```
You (in droid chat): /parallel "build authentication"
```

### Step 2: Droidz Analyzes Your Request

A special helper droid called `droidz-parallel` reads your request and thinks:
- "What smaller tasks make up authentication?"
- "Which tasks can happen at the same time?"
- "Which tasks need others to finish first?"

### Step 3: Creates a Task List

It makes a file called `tasks.json`:

```json
{
  "tasks": [
    {
      "key": "AUTH-001",
      "title": "Create user model",
      "dependencies": []
    },
    {
      "key": "AUTH-002", 
      "title": "Login endpoint",
      "dependencies": ["AUTH-001"]
    },
    {
      "key": "AUTH-003",
      "title": "Register endpoint",
      "dependencies": ["AUTH-001"]
    }
  ]
}
```

### Step 4: Figures Out the Order

The `dependency-resolver` script looks at dependencies:

```
AUTH-001 has no dependencies → Phase 1
AUTH-002 depends on AUTH-001 → Phase 2
AUTH-003 depends on AUTH-001 → Phase 2 (can run with AUTH-002!)
```

### Step 5: Works on Tasks in Phases

**Phase 1:** Do AUTH-001 (30 minutes)
```
✅ User model created
```

**Phase 2:** Do AUTH-002 AND AUTH-003 at the same time! (30 minutes)
```
⏳ Working on login endpoint...
⏳ Working on register endpoint...
(Both happening in parallel!)
```

**Result:** 60 minutes instead of 90 minutes sequential!

### Step 6: You Can Watch It All

```bash
# In droid chat, type:
/status          # See what's running
/summary         # See detailed progress
/attach AUTH-002 # Watch AUTH-002's work live
```

---

## 📋 All the Commands Explained

Droidz has **7 simple commands**. Here they are!

### The Main Commands

#### `/auto-parallel "what you want"` ⭐ **Recommended!**

**New in v0.0.7** - The easiest way to use parallel orchestration!

```
# In droid chat:
/auto-parallel "build authentication system"
```

**What it does:**
- Breaks your request into tasks automatically
- Figures out what can run in parallel
- Spawns specialist droids
- **Automatically guides you to use /watch for live monitoring**

**Examples:**
```
/auto-parallel "create REST API for todos"
/auto-parallel "fix all failing tests"
/auto-parallel "add user profile page with avatar upload"
```

**That's it!** Just describe what you want and get guided monitoring.

---

#### `/parallel "what you want"`

The original orchestration command (still works great!).

```
# In droid chat:
/parallel "add user login feature"
```

**What it does:**
- Breaks your request into tasks automatically
- Figures out what can run in parallel
- Starts working
- Shows progress

**Examples:**
```
/parallel "create REST API for todos"
/parallel "fix the JWT token bug"
/parallel "add test coverage for auth"
/parallel "build a user profile page"
```

**That's it!** Just describe what you want in plain English.

---

### Monitoring Commands (Check Progress)

#### `/status`

See all your running orchestrations.

```
# In droid chat:
/status
```

Shows:
```
Active Orchestrations:

📍 Session: auth-system-20251114
   Status: running
   Tasks: 7 total (3 done, 2 working, 2 waiting)
   Started: 1 hour ago
```

---

#### `/summary [session-id]`

See detailed progress for one orchestration.

```
# In droid chat:
/summary auth-system-20251114
```

Shows:
```
Progress: ████████░░░░ 67% (4/6 tasks)

✅ Done:
  - AUTH-001: User model
  - AUTH-002: Login endpoint
  
⏳ Working:
  - AUTH-003: Register endpoint
  
⏸ Waiting:
  - AUTH-004: Tests
  - AUTH-005: Integration
```

---

#### `/attach TASK-001`

Watch a specific task work in real-time.

```
# In droid chat:
/attach AUTH-003
```

Opens a live view where you can see the helper droid working.

**Exit:** Press `Ctrl+B` then `D`

---

#### `/watch [session-id]`

**Live monitoring** with real-time updates and progress visualization.

```
# In droid chat:
/watch
```

Shows:
```
╔══════════════════════════════════════════════════════════════════╗
║  Droidz Live Monitoring  16:45:23                                ║
╚══════════════════════════════════════════════════════════════════╝

Session: 20251114-164500-12345
Tasks Progress:
────────────────────────────────────────────────────────────────
  ✓ AUTH-001: DONE - User model created
  ⏳ AUTH-002: WORKING (droidz-codegen) - Login endpoint
  ⏳ AUTH-003: WORKING (droidz-codegen) - Register endpoint
  ⏸ AUTH-004: PENDING - Tests

Progress: [███████░░░░░] 25%

  ✓ Completed: 1
  ⏳ Working: 2
  ⏸ Pending: 1

Active Sessions: 4 tmux sessions running

Press Ctrl+C to exit | Updating every 2s...
```

**Features:**
- Updates every 2 seconds automatically
- Color-coded status (✓ done, ⏳ working, ⏸ pending, ✗ failed)
- Progress bar visualization
- Shows recent activity from logs
- Displays active tmux sessions

**Exit:** Press `Ctrl+C`

---

#### `/gh-helper <command>`

**GitHub CLI helper** with correct JSON field usage.

```
# In droid chat:

# Check PR status
/gh-helper pr-checks 10

# Comprehensive PR info
/gh-helper pr-status 10

# List all PRs
/gh-helper pr-list
```

**Why this exists:** The regular `gh pr checks` command uses different JSON field names (`bucket` instead of `status`). This helper uses the correct fields so you don't get errors.

**Available commands:**
- `pr-checks <number>` - Show CI/CD check status
- `pr-status <number>` - Full PR details and checks
- `pr-list` - List all open PRs

---

### Advanced Command (For Manual Control)

**Note:** There is no `/orchestrate` command anymore. The `/parallel` command handles orchestration automatically by spawning the droidz-parallel specialist droid, which generates tasks and runs the orchestrator script for you.

---

## 🤖 All the Helper Droids Explained

Helper droids are **specialists** that are good at specific things. The main droid calls them when needed.

### droidz-parallel
**The task breaker-upper**

What it does:
- Takes your big request
- Breaks it into small tasks
- Figures out what can run in parallel
- Starts the work

When the main droid uses it:
- When you type `/parallel "something"`
- When you ask for complex features

Think of it as: The project manager

---

### droidz-codegen
**The code writer**

What it does:
- Writes new code
- Fixes bugs
- Adds features
- Creates endpoints

When the main droid uses it:
- Most coding tasks
- "Implement X"
- "Create Y"
- "Fix Z"

Think of it as: The programmer

---

### droidz-test
**The test writer**

What it does:
- Writes unit tests
- Writes integration tests
- Improves test coverage
- Fixes failing tests

When the main droid uses it:
- When tests are needed
- "Add tests for X"
- "Improve coverage"

Think of it as: The QA engineer

---

### droidz-refactor
**The code cleaner**

What it does:
- Cleans up messy code
- Improves code structure
- Applies design patterns
- Removes duplication

When the main droid uses it:
- "Refactor X"
- "Clean up Y"
- "Improve Z"

Think of it as: The code janitor (in a good way!)

---

### droidz-integration
**The API connector**

What it does:
- Connects to external APIs
- Sets up webhooks
- Integrates third-party services
- Handles OAuth

When the main droid uses it:
- "Integrate Stripe"
- "Add Slack notifications"
- "Connect to X API"

Think of it as: The integration specialist

---

### droidz-infra
**The DevOps helper**

What it does:
- Sets up CI/CD
- Writes Docker configs
- Creates deployment scripts
- Manages infrastructure

When the main droid uses it:
- "Set up GitHub Actions"
- "Create Dockerfile"
- "Add deployment"

Think of it as: The DevOps engineer

---

### droidz-orchestrator
**The big project coordinator**

What it does:
- Handles really complex projects
- Coordinates multiple systems
- Manages big migrations
- Oversees multi-phase work

When the main droid uses it:
- Very large features
- System migrations
- Multi-component updates

Think of it as: The senior architect

---

### droidz-generalist
**The flexible helper**

What it does:
- Handles tasks that don't fit others
- Research and analysis
- Documentation
- Miscellaneous work

When the main droid uses it:
- When task is unclear
- Documentation needs
- Research tasks

Think of it as: The jack-of-all-trades

---

## 📖 Skills System - Teach Droidz Your Standards

**Skills** are like cheat sheets that automatically teach droids how to write code YOUR way!

### What Are Skills?

Skills are markdown files containing:
- ✅ Coding standards (TypeScript rules, React patterns)
- ✅ Framework best practices (Tailwind classes, Convex patterns)
- ✅ Security guidelines (never commit secrets, sanitize inputs)
- ✅ Project-specific patterns (how YOU want code written)

### How Skills Work

**Automatic injection** - No need to repeat yourself in every prompt!

```bash
# WITHOUT Skills:
You: "Create a React component with TypeScript and Tailwind"
You: "Remember to use explicit types, function components, and Tailwind utilities"
You: "Also follow accessibility best practices"
You: "And don't forget proper error handling..."

# WITH Skills:
You: "Create a React component"
Droidz: *automatically applies TypeScript, React, Tailwind, and security skills*
        *writes perfect code following all your standards*
```

### Pre-Built Skills

Droidz comes with professional skills ready to use:

| Skill | What It Teaches |
|-------|----------------|
| `typescript.md` | Explicit types, strict mode, no `any`, utility types |
| `tailwind-4.md` | Utility-first, responsive design, dark mode, accessibility |
| `convex.md` | Queries, mutations, validators, authentication patterns |
| `react.md` | Function components, hooks, TypeScript integration |
| `security.md` | Never commit secrets, sanitize inputs, use HTTPS |
| `testing.md` | Test structure, coverage, mocking, best practices |

### Creating Your Own Skills

**Step 1**: Create a file in `.factory/skills/`

```bash
# Example: Create a Python Django skill
.factory/skills/django.md
```

**Step 2**: Write your standards using this structure:

```markdown
# Django Best Practices

## Core Principles

1. **Fat Models, Thin Views** - Business logic in models
2. **Use Class-Based Views** - For reusability
3. **Security First** - Always use Django's security features

## Model Definitions

### ✅ Good
\`\`\`python
class Product(models.Model):
    name = models.CharField(max_length=200, db_index=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    
    class Meta:
        ordering = ['-created_at']
\`\`\`

### ❌ Bad
\`\`\`python
class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.FloatField()  # ❌ Use DecimalField for money!
\`\`\`

**ALWAYS follow these Django patterns.**
```

**Step 3**: Skills load automatically!

When you type prompts or edit files, relevant skills are injected:

```bash
# Editing a .tsx file:
Auto-loads: typescript.md + react.md

# Prompt mentions "Tailwind":
Auto-loads: tailwind-4.md

# Working in convex/ directory:
Auto-loads: convex.md
```

### Skill Best Practices

#### ✅ DO:
- **Use concrete examples** (not pseudocode)
- **Show good ✅ and bad ❌ patterns**
- **Explain WHY** (not just what)
- **Include specific versions** ("React 18+", "Python 3.11+")
- **Add comments** in code examples

#### ❌ DON'T:
- Write vague advice ("write clean code")
- Use placeholders (`// your code here`)
- Forget language in code blocks
- Include outdated patterns

### Complete Guide

For detailed documentation on creating skills:

```bash
# Read the comprehensive skills guide
cat SKILLS.md

# Or browse online:
https://github.com/korallis/Droidz/blob/factory-ai/SKILLS.md
```

**📚 Topics covered in SKILLS.md:**
- How skills injection works (hooks system)
- Step-by-step skill creation guide
- Skill template (copy-paste ready)
- Real-world examples (Django, Docker, Vue, etc.)
- Detection patterns (how to trigger your skills)
- Troubleshooting common issues

### Example: Using Skills in Practice

```bash
# Terminal:
droid

# In droid chat:
> Create a user authentication component with login form

# Droidz automatically:
1. Detects: "component", "form" → React skill
2. Detects: Project has TypeScript → TypeScript skill
3. Detects: Project has Tailwind → Tailwind skill
4. Loads: Security skill (always loaded)

# Result: Perfect component with:
✓ TypeScript types
✓ React best practices
✓ Tailwind styling
✓ Accessibility (ARIA labels)
✓ Security (input validation)
✓ Error handling
```

### Skills vs. CLAUDE.md

**Skills** and **CLAUDE.md** work together:

| File | Purpose | Scope |
|------|---------|-------|
| `CLAUDE.md` | Project context, architecture, commands | Project-specific |
| `skills/typescript.md` | TypeScript coding standards | Language/framework |
| `skills/security.md` | Security best practices | Universal guidelines |

**Use both together** for maximum AI effectiveness!

---

## 🏗️ Advanced Examples

Now that you understand the basics, here are more complex examples.

### Example 1: Complete Authentication System

**What you want:** Full auth system with registration, login, JWT, password reset, and email verification.

```bash
# Terminal:
droid

# Droid chat:
/parallel "build complete authentication system with registration, login, JWT, password reset, and email verification"
```

**What Droidz creates:**

```
7 tasks in 4 phases:

Phase 1: (30 min)
  └─ AUTH-001: User database model

Phase 2: (30 min - all parallel!)
  ├─ AUTH-002: Registration endpoint
  ├─ AUTH-003: Login endpoint
  └─ AUTH-004: JWT middleware

Phase 3: (30 min - parallel!)
  ├─ AUTH-005: Password reset
  └─ AUTH-006: Email verification

Phase 4: (30 min)
  └─ AUTH-007: Integration tests

Total: 120 minutes
Sequential: 210 minutes
You save: 90 minutes (43%)!
```

**Watching it work:**

```
# In droid chat:

# Every few minutes, check:
/status

# You'll see progress:
✅ Phase 1 complete (30 min)
✅ Phase 2 complete (60 min total)
⏳ Phase 3: 50% done (AUTH-005 done, AUTH-006 working)
⏸ Phase 4: Waiting
```

**When it's done:**

```
All tasks complete! ✅

✅ AUTH-001: User model with password hashing
✅ AUTH-002: POST /auth/register endpoint
✅ AUTH-003: POST /auth/login endpoint
✅ AUTH-004: JWT token middleware
✅ AUTH-005: Password reset flow
✅ AUTH-006: Email verification
✅ AUTH-007: Full integration tests

Ready to test! 🎉
```

---

### Example 2: Database Migration (Zero Downtime)

**What you want:** Migrate from MySQL to PostgreSQL without downtime.

```bash
# Terminal:
droid

# Droid chat:
/parallel "migrate database from MySQL to PostgreSQL with zero downtime using dual-write strategy"
```

**What Droidz creates:**

```
8 tasks in 6 phases:

Phase 1: Analysis
  └─ DB-001: Analyze MySQL schema (30 min)

Phase 2: Setup (parallel!)
  ├─ DB-002: Provision PostgreSQL (45 min)
  └─ DB-003: Create migration scripts (60 min)

Phase 3: Dual-Write Layer
  └─ DB-004: Implement dual-write (50 min)

Phase 4: Migration (parallel!)
  ├─ DB-005: Migrate historical data (45 min)
  └─ DB-006: Set up sync monitoring (40 min)

Phase 5: Queries
  └─ DB-007: Update app queries (55 min)

Phase 6: Testing
  └─ DB-008: Validation and cutover tests (35 min)

Total: 180 minutes
Sequential: 360 minutes
You save: 180 minutes (50%)!
```

**Key feature:** Zero downtime because dual-write happens before switching!

---

### Example 3: Real-Time Notifications

**What you want:** Add WebSocket notifications to your app.

```bash
# Terminal:
droid

# Droid chat:
/parallel "add real-time notification system with WebSockets including backend events, WebSocket server, frontend components, and Redis pub/sub"
```

**What Droidz creates:**

```
9 tasks using multiple specialist droids:

Phase 1: Design
  └─ NOTIF-001: Design data model (20 min)
      [droidz-codegen]

Phase 2: Infrastructure (parallel!)
  ├─ NOTIF-002: Set up Redis pub/sub (30 min)
  │   [droidz-infra]
  └─ NOTIF-003: Create notification service (40 min)
      [droidz-codegen]

Phase 3: WebSocket
  └─ NOTIF-004: WebSocket server (45 min)
      [droidz-integration]

Phase 4: Integration (all parallel!)
  ├─ NOTIF-005: Backend event emitters (35 min)
  │   [droidz-codegen]
  ├─ NOTIF-006: Frontend WebSocket client (30 min)
  │   [droidz-codegen]
  └─ NOTIF-007: UI notification components (40 min)
      [droidz-codegen]

Phase 5: Connect
  └─ NOTIF-008: Wire everything together (25 min)
      [droidz-integration]

Phase 6: Testing
  └─ NOTIF-009: E2E and load tests (35 min)
      [droidz-test]

Total: 150 minutes
Sequential: 270 minutes
You save: 120 minutes (44%)!
```

**Notice:** Different specialist droids handle different parts!

---

## 🔍 Troubleshooting

### Problem: `/auto-parallel` or `/parallel` command not found

**Cause:** Either Droidz not installed, or custom commands not enabled.

**Fix:**

1. **Check if installed:**
   ```bash
   # In terminal (not droid chat):
   ./status
   ```

2. **Install Droidz (if needed):**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
   ```

3. **Enable custom commands in droid:**
   - Type `/settings` in droid chat
   - Enable "Custom Commands"
   - Enable "Custom Droids"
   - **Restart droid** (important!)

4. **Verify commands loaded:**
   - Type `/commands` in droid
   - Should see: auto-parallel, parallel, watch, gh-helper, status, summary, attach

**Note:** Commands are in Factory.ai format (`.md` for prompts, `.sh` for executables)

---

### Problem: "No such file or directory: .factory/droids"

**Cause:** You're in the wrong directory.

**Fix:**
```bash
# In terminal:
pwd  # Check where you are
cd /path/to/your/project  # Go to right place
ls -la .factory  # Should see the .factory folder
droid  # Now start droid
```

---

### Problem: Task seems stuck

**What to do:**

```bash
# In droid chat:

# 1. Check status
/status

# 2. See details
/summary session-id-here

# 3. Watch the stuck task
/attach TASK-003

# 4. Check logs
# In regular terminal (new window):
cat .runs/.coordination/orchestration.log
```

---

### Problem: "Session already exists"

**Cause:** Previous orchestration didn't clean up.

**Fix:**
```bash
# In regular terminal (not droid chat):
tmux ls  # See sessions

# Kill old sessions:
tmux kill-session -t droidz-TASK-001

# Or kill all:
tmux ls | grep droidz | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

---

### Problem: I don't understand what's happening

**That's okay!** Here's the simple version:

1. **Install Droidz** (follow Installation section)
2. **Start droid**: Type `droid` in terminal
3. **Ask for help**: Type `/parallel "what you want"` in droid chat
4. **Watch progress**: Type `/status` in droid chat
5. **That's it!**

The rest is automatic. You don't need to understand how it works to use it!

---

## 🎓 Learning Path

### Week 1: Basics
- Install Droidz
- Try `/parallel` with a small task
- Use `/status` to watch progress
- That's enough to be productive!

### Week 2: Monitoring
- Learn `/summary` for details
- Try `/attach` to watch tasks
- Understand phases and dependencies

### Week 3: Advanced
- Try creating custom tasks.json
- Use manual orchestration (removed - use `/parallel` instead)
- Explore different helper droids

### Week 4: Expert
- Create your own helper droids
- Optimize task breakdowns
- Help others learn!

---

## 🆘 Need Help?

### Quick Help

```bash
# In droid chat:
/help           # See all commands
/droids         # See all helper droids
/commands       # See all shortcuts
```

### Get Support

1. **Check logs**: `.runs/.coordination/orchestration.log`
2. **GitHub Issues**: https://github.com/korallis/Droidz/issues
3. **Discord Community**: [Join our Discord](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW) - Get help, share workflows, connect with other users
4. **Read this guide** again - the answer is probably here!

### Common Questions

**Q: Do I need to understand how it works?**
A: No! Just use `/parallel "what you want"` and it works.

**Q: How much faster is it really?**
A: Usually 40-50% faster for tasks with some parallel work.

**Q: Can I use it for any project?**
A: Yes! Works with any programming language or framework.

**Q: Is it safe?**
A: Yes, but always review changes before committing them.

**Q: What if something breaks?**
A: Droidz works in separate git worktrees, so your main code is safe.

---

## 🎉 You're Ready!

**Remember the basics:**

1. Type `droid` in terminal to start Factory.ai chat
2. Type `/parallel "what you want"` in the droid chat
3. Type `/status` to watch progress
4. That's it!

Everything else is optional. Start simple, learn as you go.

**Your first task:**

```bash
# Terminal:
cd your-project
droid

# Droid chat:
/parallel "add a simple hello world endpoint"

# Watch it work:
/status
```

Have fun! 🚀

---

## 📚 Appendix: File Structure

When you install Droidz, here's what you get:

```
your-project/
├── status                 # Quick installation status (NEW! v0.0.7)
├── .factory/
│   ├── commands/          # Slash commands (Factory.ai format)
│   │   ├── auto-parallel.md    # The /auto-parallel command (NEW! ⭐)
│   │   ├── parallel.md         # The /parallel command (markdown prompt)
│   │   ├── watch.sh            # The /watch command (NEW! live monitoring)
│   │   ├── gh-helper.sh        # The /gh-helper command (NEW! GitHub)
│   │   ├── status.sh           # The /status command (bash executable)
│   │   ├── summary.md          # The /summary command (markdown prompt)
│   │   ├── attach.md           # The /attach command (markdown prompt)
│   │   └── parallel-watch.sh   # Helper script (NEW!)
│   │
│   ├── droids/            # Helper droids (specialists)
│   │   ├── droidz-parallel.md      # Enhanced with auto-guidance! ⭐
│   │   ├── droidz-orchestrator.md
│   │   ├── droidz-codegen.md
│   │   ├── droidz-test.md
│   │   ├── droidz-refactor.md
│   │   ├── droidz-integration.md
│   │   ├── droidz-infra.md
│   │   └── droidz-generalist.md
│   │
│   └── scripts/           # Behind-the-scenes tools
│       ├── orchestrator.sh
│       ├── dependency-resolver.sh
│       └── parallel-executor.sh
│
├── config.yml             # Your settings (optional)
└── README.md              # This guide!
```

**You don't need to touch these files!** Droidz uses them automatically.

**Quick Status:** Run `./status` anytime to see what's installed!

---

## 💝 Support Droidz

If Droidz saves you time and makes development easier, consider supporting the project:

**Donate via PayPal**: [@gideonapp](https://www.paypal.com/paypalme/gideonapp)  
**Join the Community**: [Discord Server](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)

Your support helps keep Droidz free and constantly improving!

---

**Version:** 0.0.9  
**Updated:** 2025-11-14  
**Difficulty:** Beginner-Friendly ⭐⭐⭐⭐⭐

## 🆕 What's New in v0.0.7

### Parallel Orchestration Actually Works Now! 🎉

**Major Fixes:**
- ✅ **Parallel tasks actually execute** - Previously, orchestration created worktrees but never spawned droids
- ✅ **Real-time monitoring** - New `/watch` command shows live progress with color-coded status
- ✅ **Better visibility** - Enhanced `/status` reads actual task progress from worktrees
- ✅ **GitHub PR helpers** - New `/gh-helper` command with correct JSON fields
- ✅ **Auto-guidance** - New `/auto-parallel` command with automatic monitoring instructions
- ✅ **Clean status display** - New `./status` script for tidy installation summary

**What Changed:**
- `droidz-parallel` now spawns Task() calls for each specialist droid
- Status commands read from `.droidz-meta.json` files in worktrees
- Live monitoring with progress bars and updates every 2s
- Fixed GitHub CLI field name errors (`bucket` vs `status`)

**Before v0.0.7:**
```
/parallel "build auth"
✅ Created worktrees
❌ Nothing happens (tasks sit idle)
```

**After v0.0.7:**
```
/parallel "build auth"
✅ Created worktrees
✅ Spawned specialist droids
⏳ Tasks actually working!
📊 /watch shows real-time progress
```

See `UPDATE_INSTALLATION.md` for detailed upgrade guide.

---

Made with ❤️ for developers who want to move faster
