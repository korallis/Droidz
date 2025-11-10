# Droidz 🤖

**5 Robot helpers that build your app together - while you sleep! 5x faster than working alone.**

## 🎈 What is Droidz?

Imagine building a LEGO castle. Doing it alone takes ALL day. 😴

But with 5 friends helping:
- Friend 1 builds walls
- Friend 2 builds towers  
- Friend 3 builds doors
- Friend 4 builds flag
- Friend 5 builds moat

**Everyone works at the SAME TIME = Done in 1 hour!** 🚀

Droidz is like that, but for building apps! 5 robot helpers work together in parallel.

### How Fast Is It Really?

**Without Droidz:** Build 10 features = 10 hours (one at a time)
**With Droidz:** Build 10 features = 2 hours (5 robots work simultaneously!)

Real speed: **3-5x faster** than traditional AI coding tools.

---

## 🚀 Quick Start (5 Minutes)

**Step 1: Install**
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**Step 2: Enable robots**
```bash
droid
/settings     # Turn ON "Custom Droids"
/quit
droid         # Restart
```

**Step 3: Get a plan!**
```
/droidz-orchestrator plan a todo app with:
- Add tasks
- Mark tasks done  
- Delete tasks
```

Whatever you type after the command is passed verbatim to the planner.

**Step 4: Follow the plan!**
Orchestrator creates delegation instructions. YOU execute them:
```
"Use droidz-codegen to implement TASK-1"
"Use droidz-test to implement TASK-2"
```

**That's it!** Specialists work in parallel. ✨

---

## 📖 Table of Contents

- [How It Works](#-how-it-works)
- [Installation](#-installation)
- [Setup Options](#-setup-options)
- [Usage Examples](#-usage-examples)
- [Existing Project Workflow](#-existing-project-workflow)
- [New Project Workflow](#-new-project-workflow)
- [Sample Workflows](#-sample-workflows)
- [Troubleshooting](#-troubleshooting)

## 📘 Important Notes

**v2.0.2 Architecture Update:**
- Orchestrator is now a **planner** (creates execution plans)
- YOU are the **delegator** (invoke specialists via "Use droidz-X...")
- Custom droids cannot delegate to other droids per Factory.ai docs
- See usage examples below for correct workflow

---

## 🧠 How It Works

### The Team

**Orchestrator (The Boss)**
- Reads your request
- Breaks it into tasks
- Assigns tasks to specialists
- Monitors progress

**5 Specialist Robots**
1. **codegen** - Writes feature code
2. **test** - Creates tests
3. **refactor** - Cleans up code
4. **infra** - Fixes CI/CD and tooling
5. **integration** - Connects external services

### The Magic: Parallel Execution

Traditional AI: Does tasks **one by one** ⏳
```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5
[10 min each = 50 minutes total]
```

Droidz: Does tasks **at the same time** ⚡
```
Task 1 ┐
Task 2 ├─ All 5 work together
Task 3 ├─ [10 min total!]
Task 4 ├─
Task 5 ┘
```

**How?** Git worktrees! Each robot gets its own isolated workspace.

**How YOU use it:** Orchestrator plans, YOU delegate to specialists:
```
Step 1: "Use droidz-orchestrator to plan X"
Step 2: Orchestrator outputs: "Use droidz-codegen for task 1", etc.
Step 3: YOU run those commands (in parallel if possible)
```

---

## 💻 Installation

### Prerequisites

1. **Git repository** (your project folder)
2. **JavaScript runtime** (Bun recommended, npm works too)
3. **Factory CLI** (AI coding tool)
4. **GitHub CLI** (`gh` command)

### Install Bun (Recommended - 3-10x faster!)

```bash
curl -fsSL https://bun.sh/install | bash
```

**Or use npm/node** (already installed? Skip this!)

### Install Droidz

```bash
# In your project folder:
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### Enable Custom Droids

```bash
droid
/settings
# Toggle "Custom Droids" to ON
/quit
droid
/droids  # Verify you see droidz-orchestrator, etc.
```

---

## ⚙️ Setup Options

### Option 1: No Setup (Basic Mode) 🎯

**Best for:** Quick testing, solo developers

Works immediately! No configuration needed.

**What you get:**
- ✅ Parallel execution (5x speed!)
- ✅ Automatic PR creation
- ✅ Code generation
- ⚠️ Basic research (WebSearch only)

**Usage:**
```
Use droidz-orchestrator to build a todo app
```

### Option 2: MCP Servers (Recommended) ⚡

**Best for:** Teams, production projects

**What you get:**
- ✅ Everything from Basic
- ✅ AI-powered search (Exa)
- ✅ Linear ticket management
- ✅ Documentation search (Ref)

**Setup (2 minutes):**
```bash
droid
/mcp add exa      # Get key from exa.ai/api-keys
/mcp add linear   # Get key from linear.app/settings/api  
/mcp add ref      # Get key from ref.sh/api
```

That's it! Robots now have superpowers. 🦸

### Option 3: Existing Linear Project 📋

**Best for:** Teams with existing Linear setup

**Setup:**
```bash
# Edit config.yml
nano config.yml
```

Add your project name:
```yaml
linear:
  project_name: "MyProject"  # Must match Linear exactly!
```

Now orchestrator knows which tickets to fetch!

---

## 🎯 Usage Examples

### Example 1: Build Something New

```bash
droid
```

Then say:
```
Use droidz-orchestrator to build a blog with:
- List all posts
- Read a post
- Create new posts (auth required)
- Markdown support
```

**What happens:**
1. Orchestrator breaks it into 8 tasks
2. Creates Linear project (if you have MCP)
3. Spawns 5 robots working in parallel
4. Each robot:
   - Creates isolated workspace (git worktree)
   - Implements their task
   - Runs tests
   - Creates PR
5. Done in ~15 minutes! (Would take 1+ hour alone)

### Example 2: Process Linear Tickets

```bash
droid
```

```
/droidz-orchestrator process all tickets in project "MyApp"
```

**What happens:**
1. Fetches all tickets from Linear
2. Analyzes dependencies
3. Groups into parallel-safe batches
4. Processes 5 tickets simultaneously
5. Updates Linear status automatically
6. Creates PRs for each

### Example 3: Single Feature

```bash
droid
```

```
/droidz-orchestrator add dark mode to the app
```

**What happens:**
1. Researches dark mode patterns (if Exa configured)
2. Creates tasks:
   - Theme context/state
   - CSS variables
   - Toggle component
   - Persist preference
   - Update all pages
3. Delegates to specialists
4. Creates single PR with all changes

---

## 🏗️ Existing Project Workflow

**Scenario:** You have a React app, want to add features.

### Step 1: Install Droidz

```bash
cd my-existing-app
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### Step 2: (Optional) Connect Linear

If you have existing Linear project:

```bash
nano config.yml
```

```yaml
linear:
  project_name: "MyApp"  # Your Linear project name
```

### Step 3: Add MCP Servers (Optional)

```bash
droid
/mcp add linear  # Connect to your Linear
/mcp add exa     # Better research
```

### Step 4: Process Your Tickets

```bash
droid
```

**Option A: Process all tickets**
```
/droidz-orchestrator process all tickets in project "MyApp"
```

**Option B: Process specific sprint**
```
/droidz-orchestrator process sprint "Sprint 5" in project "MyApp"
```

**Option C: Single ticket**
```
Use droidz-orchestrator to implement ticket MYAPP-123
```

### Step 5: Review PRs

```bash
gh pr list  # See all PRs created
gh pr view 42  # Review a specific PR
gh pr merge 42  # Merge when ready
```

**Cleanup:**
```bash
git worktree remove .runs/MYAPP-123  # Remove worktree after merge
```

---

## 🆕 New Project Workflow

**Scenario:** Starting from scratch.

### Step 1: Create Project

```bash
mkdir my-new-app
cd my-new-app
git init
git remote add origin https://github.com/you/my-new-app.git
```

### Step 2: Install Droidz

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### Step 3: Enable Robots

```bash
droid
/settings  # Turn ON "Custom Droids"
/quit
droid
```

### Step 4: Describe What to Build

```bash
droid
```

```
Use droidz-orchestrator to build a task management app:

Features:
- User authentication (email/password)
- Create, read, update, delete tasks
- Mark tasks as done/undone
- Filter by status (all/active/completed)
- Dark mode toggle
- Responsive design

Tech stack:
- React + TypeScript
- Tailwind CSS
- Supabase for backend
- React Router
```

### Step 5: Let Robots Work

**Orchestrator will:**
1. Create Linear project (if MCP configured)
2. Break into ~15 tasks
3. Research best practices (if Exa configured)
4. Spawn 5 robots
5. Each robot works on their tasks in parallel
6. Creates 15 PRs

**Time:** ~30-40 minutes (would take 3-4 hours solo!)

### Step 6: Review and Merge

```bash
# See all PRs
gh pr list

# Review PRs by feature area
gh pr view 1   # Auth system
gh pr view 2   # Task CRUD
gh pr view 3   # UI components

# Merge in dependency order
gh pr merge 1  # Base first
gh pr merge 2  # Then features
gh pr merge 3  # Then UI
```

---

## 🎬 Sample Workflows

### Workflow 1: E-commerce Site

```
Use droidz-orchestrator to build an e-commerce site:
- Product catalog with search/filter
- Shopping cart (localStorage)
- Checkout flow (Stripe integration)
- Order history
- Admin panel for products
- Tech: Next.js 14, TypeScript, Tailwind, Stripe
```

**Output:** 25-30 PRs, ready in ~1 hour

### Workflow 2: API Service

```
Use droidz-orchestrator to build a REST API:
- User authentication (JWT)
- CRUD for posts, comments, likes
- Rate limiting
- OpenAPI documentation
- Tests with 80%+ coverage
- Tech: Express, TypeScript, PostgreSQL, Prisma
```

**Output:** 15-20 PRs, ready in ~45 minutes

### Workflow 3: Refactor Legacy Code

```
Use droidz-orchestrator to refactor the authentication system:
- Extract auth logic to reusable hooks
- Add TypeScript types throughout
- Improve error handling
- Add unit tests
- Update documentation
```

**Output:** 5-8 PRs, ready in ~20 minutes

### Workflow 4: Add Feature to Existing App

```
Use droidz-orchestrator to add real-time notifications:
- WebSocket connection manager
- Notification bell UI component
- Mark as read functionality
- Notification settings page
- Backend endpoint for notifications
- Tech: Socket.io, React, existing Express backend
```

**Output:** 6-8 PRs, ready in ~25 minutes

---

## 🔧 Troubleshooting

### "Custom droids not found"

**Fix:** Enable custom droids
```bash
droid
/settings  # Toggle ON "Custom Droids"
/quit
droid
```

### "Not a git repository"

**Fix:** Initialize git
```bash
git init
git remote add origin https://github.com/you/repo.git
```

### "No tickets found"

**Fix:** Check Linear project name
```bash
nano config.yml
# Make sure project_name matches exactly!
```

### "Worktree creation failed"

**Fix:** Clean up old worktrees
```bash
git worktree list
git worktree remove .runs/OLD-123
```

### "Tests failing in parallel"

**Fix:** Install dependencies in worktree
```bash
cd .runs/PROJ-123
bun install  # or npm install
```

### "Robots running sequentially, not parallel"

**Fix:** Check worktree mode
```bash
nano config.yml
# Ensure: workspace.mode = "worktree"
```

### "Invalid tools: Task" error

**Fix:** This was fixed in v2.0.2 - update your droids
```bash
# Pull latest changes
git pull origin main

# Or reinstall
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**Background:** 
- `Task` is NOT a tool you list in the tools array
- It's automatically available when Custom Droids are enabled
- Orchestrator creates plans that YOU delegate via: "Use droidz-codegen to implement X"
- Custom droids cannot delegate to other droids (Factory.ai architecture)

---

## 📚 Configuration Reference

### config.yml Structure

```yaml
# Linear project tracking (optional)
linear:
  project_name: "MyProject"  # For existing projects

# Runtime (required)
runtime:
  package_manager: "bun"  # or "npm", "pnpm", "yarn"

# Parallel execution (don't change!)
parallel:
  enabled: true
  max_concurrent_tasks: 5  # 5 robots working simultaneously

# Git worktrees (don't change!)
workspace:
  mode: worktree  # Critical for parallel execution!
  base_dir: ".runs"
  branch_pattern: "feature/{issueKey}-{slug}"

# Safety (optional)
guardrails:
  tests_required: true
  secret_scan: true
```

---

## 🎓 Advanced Topics

### Using with Monorepos

Droidz works great with monorepos! Each robot can work on different packages simultaneously.

### Custom Specialist Droids

You can create your own specialist droids for domain-specific tasks.

### CI/CD Integration

Droidz-created PRs work with your existing CI/CD pipeline.

### Team Workflows

Multiple developers can use Droidz simultaneously - robots use unique worktrees.

---

## 🤝 Support

- **Documentation:** [QUICK_START_V2.md](QUICK_START_V2.md)
- **Architecture:** [docs/V2_ARCHITECTURE.md](docs/V2_ARCHITECTURE.md)
- **Issues:** https://github.com/korallis/Droidz/issues

---

## 💝 Like Droidz?

Consider supporting: https://paypal.me/leebarry84

---

**Happy building! 🚀🤖**
