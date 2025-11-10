# Droidz 🤖

**Imagine having a team of robot helpers that build your software while you watch!**

## ⚡ Quick Install

```bash
# In your project folder:
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

Then enable "Custom Droids" in Factory settings (`droid` → `/settings`) and you're ready! 🚀

[Full setup guide below ↓](#-quick-start-super-easy)

---

## 🎈 What is Droidz? (Explained Like You're 5)

You know how when you want to build a LEGO castle, it takes a really long time if you do it alone?

**But what if you had 5 friends helping you?**
- Friend 1 builds the walls
- Friend 2 builds the towers  
- Friend 3 builds the doors
- Friend 4 builds the flag
- Friend 5 builds the moat

**Everyone works at the same time, and the castle is done 5 times faster!**

That's what Droidz does... but for building software! 🏰

---

## 🤖 Meet Your Robot Team

Droidz gives you **5 different robot helpers**:

### 🎨 Codegen Robot
**What it does:** Builds new features  
**Example:** "Make a login page with email and password"

### ✅ Test Robot
**What it does:** Checks everything works correctly  
**Example:** "Make sure the login page works properly"

### 🔧 Refactor Robot
**What it does:** Makes code cleaner and prettier  
**Example:** "Make this messy code easier to read"

### 🏗️ Infra Robot
**What it does:** Fixes building and deployment tools  
**Example:** "Fix the build pipeline so it deploys faster"

### 🔌 Integration Robot
**What it does:** Connects to other apps and services  
**Example:** "Connect our app to Stripe for payments"

### 🎯 Orchestrator Robot (The Boss)
**What it does:** Tells all the other robots what to do  
**Example:** "Hey Codegen, you build the login. Hey Test, you test it!"

---

## ✨ How Does It Work?

### Step 1: You Tell the Boss Robot What You Want

```
"Build me a todo list app"
```

### Step 2: Boss Robot Makes a Plan

The Orchestrator looks at all the work and thinks:
- "We need a form to add todos" → Give to Codegen Robot
- "We need to test adding todos" → Give to Test Robot
- "We need to save todos in a database" → Give to Codegen Robot
- "We need to make the code clean" → Give to Refactor Robot

### Step 3: Robots Work at the Same Time! ⚡

Instead of doing one thing at a time (slow), all robots work together:

**Old Way (Slow):**
```
Day 1: Build form
Day 2: Build database
Day 3: Build tests
Day 4: Clean code
Total: 4 days 😴
```

**Droidz Way (Fast):**
```
Day 1: 
  - Robot 1 builds form
  - Robot 2 builds database  
  - Robot 3 builds tests
  - Robot 4 cleans code
  ALL AT THE SAME TIME!
Total: 1 day 🚀
```

### Step 4: Everything Gets Put Together

When all robots finish, Droidz combines their work into one complete app!

---

## 🎯 What Can Droidz Build?

**Droidz can build almost anything!** Here are some examples:

- 🛒 **Shopping websites** - Add to cart, checkout, payments
- 📱 **Mobile apps** - Login, profiles, notifications  
- 🎮 **Games** - Character movement, scoring, levels
- 📊 **Dashboards** - Charts, reports, analytics
- 🔐 **User systems** - Login, signup, forgot password
- 💬 **Chat apps** - Messages, groups, emoji reactions
- 📝 **Blog platforms** - Posts, comments, likes
- 🎵 **Music players** - Playlists, shuffle, controls

**If you can imagine it, Droidz can help build it!**

---

## 🎬 End-to-End Workflow: Building an App with Droidz

**Want to see how Droidz actually works?** Here's a complete walkthrough from "I have an idea" to "app is deployed"!

### The Complete Journey

Let's say you want to build a **Task Management App** (like Todoist or Asana, but simpler).

#### **Phase 1: Setup Your Project (5 minutes)**

1. **Create your project repository**:
```bash
mkdir my-task-app
cd my-task-app
git init
git remote add origin https://github.com/yourname/my-task-app.git
```

2. **Install Droidz**:
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

3. **Enable Custom Droids in Factory**:
```bash
droid
# Type: /settings
# Find "Custom Droids" and turn it ON
# Exit (Ctrl+C) and restart: droid
```

4. **Verify droids are ready**:
```bash
# In Factory CLI, type:
/droids
# You should see: droidz-orchestrator, droidz-codegen, droidz-test, etc.
```

#### **Phase 2: Let Droidz Plan It For You! 🤖 (2 minutes)**

**OPTION 1: Automatic Planning (Recommended) ✨**

If you have a Linear API key, Droidz will automatically create the project and tickets for you!

1. **Get your Linear API key** (one-time setup):
   - Go to https://linear.app/settings/api
   - Create a new API key
   - Save it: `export LINEAR_API_KEY="your-key-here"`

2. **Tell Droidz what you want to build**:
```bash
droid
```

Then say:
```
Use droidz-orchestrator to build a task management app with:
- User authentication (email/password)
- Create, read, update, delete tasks
- Task lists and forms
- Tests for everything
- Deploy to production
```

**That's it!** Droidz will:
- ✅ Create a Linear project automatically
- ✅ Break it into 10-12 optimized tickets
- ✅ Add proper labels (backend, frontend, test, infra)
- ✅ Set up dependencies (what must finish first)
- ✅ Start building immediately in parallel!

**No manual planning needed!** 🎉

---

**OPTION 2: Work Without Linear (Local Mode)**

Don't have Linear? No problem! Droidz works great without it:

```bash
droid
```

Then say:
```
Use droidz-orchestrator to build a task management app with:
- User authentication (email/password)
- Create, read, update, delete tasks
- Task lists and forms
- Tests for everything
```

**Droidz will:**
- ✅ Analyze your request
- ✅ Create a local execution plan
- ✅ Build in parallel with git worktrees (3-5x speed!)
- ✅ Create PRs for each feature

**You just won't get:**
- ❌ Linear project management UI
- ❌ Ticket tracking and updates
- ❌ Team collaboration features

But the core parallel building still works! 🚀

---

**OPTION 3: Manual Linear Planning (Advanced)**

Prefer to create Linear tickets yourself? You can:

1. Create a Linear project: "Task Management App"
2. Create tickets manually with proper labels and dependencies
3. Configure `orchestrator/config.json` with your project name
4. Run: `droidz-orchestrator to process project "Task Management App"`

See the [Manual Linear Setup Guide](docs/manual-linear-setup.md) for details.

---

#### **Phase 3: Watch the Magic Happen! ✨**

After you tell Droidz what to build (from Phase 2), here's what happens in real-time:

```
🔍 Fetching tickets from Linear...
✅ Found 10 tickets

📋 Analyzing dependencies...
✅ Identified 3 execution phases

🚀 Parallel Execution Strategy:
- Mode: Git Worktrees (isolated environments for each task)
- Concurrency: 5 workers running simultaneously
- Tasks: 10 tickets to process
- Estimated time: ~20 minutes
- Sequential would take: ~100 minutes
- Speed benefit: 5x faster! 🎉

📊 Execution Plan:

Phase 1 (Sequential - Foundation):
  🔄 TASK-1: Create task model and database schema (backend)
  
Phase 2 (Parallel - 5 tasks at once!):
  🔄 TASK-2: Build API endpoint to create tasks (backend)
  🔄 TASK-3: Build API endpoint to list tasks (backend)
  🔄 TASK-4: Build API endpoint to update tasks (backend)
  🔄 TASK-5: Build API endpoint to delete tasks (backend)
  🔄 TASK-8: Write tests for task API (test)
  
Phase 3 (Parallel - remaining tasks):
  🔄 TASK-6: Create React component for task list (frontend)
  🔄 TASK-7: Create React form for adding tasks (frontend)
  🔄 TASK-9: Write tests for task components (test)
  🔄 TASK-10: Deploy app to production (infra)

Starting execution...
```

**Live Progress Updates:**

```
✅ TASK-1: COMPLETE - PR #101 (Database schema ready)
   Worker: droidz-codegen-backend
   Time: 8 minutes
   Branch: backend/TASK-1-create-task-model
   
🔄 TASK-2: IN PROGRESS - Creating task endpoint
   Worker: droidz-codegen-backend
   Status: Writing API route handler...
   
🔄 TASK-3: IN PROGRESS - Building list endpoint
   Worker: droidz-codegen-backend
   Status: Adding query filters...
   
🔄 TASK-4: IN PROGRESS - Implementing update logic
   Worker: droidz-codegen-backend
   Status: Validating input data...
   
🔄 TASK-5: IN PROGRESS - Adding delete functionality
   Worker: droidz-codegen-backend
   Status: Checking permissions...
   
🔄 TASK-8: IN PROGRESS - Writing API tests
   Worker: droidz-test
   Status: Setting up test fixtures...
```

After ~12 minutes:

```
✅ TASK-2: COMPLETE - PR #102
✅ TASK-3: COMPLETE - PR #103
✅ TASK-4: COMPLETE - PR #104
✅ TASK-5: COMPLETE - PR #105
✅ TASK-8: COMPLETE - PR #108

Starting Phase 3 (4 tasks in parallel)...

🔄 TASK-6: IN PROGRESS - Building task list UI
   Worker: droidz-codegen-frontend
   Status: Creating React component...
```

After ~20 minutes total:

```
🎉 All Tasks Complete!

📊 Final Summary:

Completed: 10/10 tickets ✅
Time taken: 18 minutes
Sequential estimate: 100 minutes
Speed improvement: 5.5x faster!

Pull Requests Created:
  ✅ PR #101: TASK-1 - Database schema (merged)
  ✅ PR #102: TASK-2 - Create task endpoint (ready for review)
  ✅ PR #103: TASK-3 - List tasks endpoint (ready for review)
  ✅ PR #104: TASK-4 - Update task endpoint (ready for review)
  ✅ PR #105: TASK-5 - Delete task endpoint (ready for review)
  ✅ PR #106: TASK-6 - Task list component (ready for review)
  ✅ PR #107: TASK-7 - Add task form (ready for review)
  ✅ PR #108: TASK-8 - API tests (ready for review)
  ✅ PR #109: TASK-9 - Component tests (ready for review)
  ✅ PR #110: TASK-10 - Production deployment (ready for review)

Linear Tickets:
  All 10 tickets marked as "Done" with PR links posted

Next Steps:
  1. Review PRs on GitHub
  2. Approve and merge PRs
  3. Monitor deployment (TASK-10 PR)
  4. App is live! 🚀
```

#### **Phase 5: Review and Merge (15 minutes)**

Now **you** take control:

1. **Review the PRs** on GitHub:
   - Click each PR link
   - Look at the code changes
   - Run tests locally if you want
   - Leave comments if anything needs changes

2. **Merge approved PRs**:
   ```bash
   # Or just click "Merge" button on GitHub
   ```

3. **Check deployment**:
   - TASK-10 PR includes deployment config
   - Merge it to deploy to production!

#### **Phase 6: Your App is Live! 🎉**

Total time: **~25 minutes** (5 setup + 2 describing what you want + 18 building)

**What you got:**
- ✅ Complete database schema
- ✅ Full REST API for tasks (CRUD)
- ✅ React UI components
- ✅ Comprehensive test coverage
- ✅ Deployed to production
- ✅ All code reviewed and documented

**What you did:**
- Described what you wanted to build (2 minutes!)
- Reviewed the PRs
- Clicked "Merge"

**What the robots did:**
- Everything else! 🤖

---

### 🔍 How It Actually Works (Under the Hood)

**The Secret Sauce: Git Worktrees + Parallel AI Workers**

#### **Step 1: The Orchestrator Plans**

When you say "build Task Management App", here's what happens:

1. **Orchestrator fetches tickets** from Linear using MCP tools:
   ```typescript
   // Behind the scenes:
   linear___list_issues({project: "Task Management App"})
   ```

2. **Analyzes dependencies**:
   - Sees TASK-2 depends on TASK-1
   - Sees TASK-6, 7 depend on TASK-2, 3
   - Creates execution phases (sequential when needed, parallel when possible)

3. **Routes to specialists**:
   - `backend` label → `droidz-codegen` (backend specialist)
   - `frontend` label → `droidz-codegen` (frontend specialist)
   - `test` label → `droidz-test`
   - `infra` label → `droidz-infra`

#### **Step 2: Git Worktrees Are Created**

For each ticket, Droidz creates an **isolated workspace**:

```
Your-Project/
├── main code/              ← Your original code (untouched!)
├── .runs/
│   ├── TASK-1/            ← Robot 1's private workspace
│   │   ├── src/
│   │   ├── tests/
│   │   └── .git → (points to main .git)
│   ├── TASK-2/            ← Robot 2's private workspace
│   ├── TASK-3/            ← Robot 3's private workspace
│   ├── TASK-4/            ← Robot 4's private workspace
│   └── TASK-5/            ← Robot 5's private workspace
```

**Why this is magic:**
- Each robot has a **complete copy** of your code
- Changes in one workspace **don't affect** others
- No merge conflicts between parallel workers!
- Each robot works on its **own branch**

#### **Step 3: Specialists Work in Parallel**

Each specialist robot follows this process:

**droidz-codegen (Building TASK-2):**
```
1. Updates Linear ticket to "In Progress" (using Linear MCP)
2. Researches Stripe API (using Exa MCP for examples)
3. Reads project docs (using Ref MCP)
4. Implements the feature in its workspace
5. Runs tests: `bun test`
6. Commits changes: `git commit -m "TASK-2: Add create task endpoint"`
7. Pushes branch: `git push origin backend/TASK-2-create-task-endpoint`
8. Creates PR: `gh pr create --fill`
9. Posts PR link to Linear: linear___create_comment()
10. Returns success to orchestrator
```

**All happening at the same time** for TASK-2, TASK-3, TASK-4, TASK-5, and TASK-8!

#### **Step 4: MCP Tools in Action**

Throughout execution, droids use MCP tools **autonomously**:

**Example: Implementing Stripe payment (TASK-15)**

```
droidz-codegen:
  "I need to integrate Stripe. Let me research first..."
  
  [Uses exa___get_code_context_exa("Stripe SDK Node.js")]
  → Finds official Stripe docs and code examples
  
  [Uses ref___ref_search_documentation("Stripe payment intents")]
  → Reads Stripe API reference
  
  "Now I'll implement based on best practices..."
  [Writes code]
  
  [Uses linear___update_issue() to mark progress]
  → Updates ticket without being asked
  
  "Done! Creating PR..."
  [Commits, pushes, creates PR]
```

**You didn't have to say:**
- "Research Stripe API"
- "Look up documentation"
- "Update the Linear ticket"

**The droid just did it automatically!** That's the power of MCP tools.

#### **Step 5: Real-Time Visibility**

The orchestrator uses **TodoWrite** to show you progress:

```typescript
TodoWrite({
  todos: [
    {id: "TASK-1", status: "completed", content: "✅ Database schema - PR #101"},
    {id: "TASK-2", status: "in_progress", content: "🔄 Create endpoint - Writing tests..."},
    {id: "TASK-3", status: "completed", content: "✅ List endpoint - PR #103"},
    {id: "TASK-4", status: "pending", content: "⏳ Update endpoint - Waiting..."}
  ]
});
```

You see **exactly what's happening** in real-time!

#### **Step 6: Aggregation and Summary**

When all specialists finish:

1. **Orchestrator collects results**:
   - 10 PRs created
   - All tests passing
   - All Linear tickets updated

2. **Shows you the summary**:
   - Links to all PRs
   - Time statistics
   - Any issues encountered

3. **You take over**:
   - Review PRs
   - Merge when ready
   - Deploy to production

---

### 🧠 Why This Approach is Revolutionary

**Traditional Development (One developer):**
```
Day 1: Plan architecture
Day 2: Build database schema
Day 3: Build first API endpoint
Day 4: Build second API endpoint
Day 5: Build third API endpoint
Day 6: Build UI
Day 7: Write tests
Day 8: Deploy

Total: 8 days ☹️
```

**Droidz Approach (5 AI workers in parallel):**
```
Hour 1: Plan (you + orchestrator)
Hour 2-3: All workers build simultaneously
  - Worker 1: Database
  - Worker 2: API endpoints
  - Worker 3: UI components
  - Worker 4: Tests
  - Worker 5: Deployment config
Hour 4: Review and merge

Total: 4 hours! 🚀
```

**That's 16x faster than traditional solo development!**

### 🎯 Key Innovations

1. **Git Worktrees**: True isolation = true parallelization
2. **MCP Tools**: Autonomous research and integration = smarter decisions
3. **Specialist Droids**: Right tool for the job = better quality
4. **Orchestration**: Smart planning = optimal execution
5. **Real-time Visibility**: TodoWrite updates = you're always informed

---

## 🚀 Quick Start (Super Easy!)

### Step 1: Install Factory

Droidz needs Factory to work (Factory is like the playground where robots play).

```bash
curl -fsSL https://app.factory.ai/cli | sh
```

### Step 2: Install Droidz (One Command!)

Go to your project folder and run:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**That's it!** The install script will:
- ✅ Download all robot helpers (droids)
- ✅ Set up orchestrator scripts
- ✅ Create configuration files
- ✅ Add documentation

### Step 3: Enable Robot Mode

```bash
droid
```

Then type:
```
/settings
```

Find "Custom Droids" and turn it ON (it might say "Experimental" - that's okay!)

**Restart Factory:**
```bash
# Exit (Ctrl+C or type /quit)
# Then start again:
droid
```

### Step 4: Verify Robots Are Ready

In Factory, type:
```
/droids
```

You should see:
- ✅ droidz-orchestrator (the boss)
- ✅ droidz-codegen
- ✅ droidz-test
- ✅ droidz-refactor
- ✅ droidz-infra
- ✅ droidz-integration

**If you see them all, you're ready!** 🎉

---

## 🔄 Updating Droidz

Already have Droidz? Update to the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

The installer is smart - it updates existing files and preserves your config!

---

## 🎮 How to Use Droidz

### Basic Usage

1. **Start Factory:**
```bash
droid
```

2. **Talk to the boss robot:**
```
Use droidz-orchestrator to build a login system with email and password
```

3. **Watch the magic happen!** ✨

The boss robot will:
- Make a plan
- Show you what each robot will do
- Make robots work together
- Show you live progress
- Give you the finished code!

### Real Example

Let's build a todo list app:

```bash
droid
```

Then say:
```
Use droidz-orchestrator to build a todo list app where users can:
- Add new todos
- Mark todos as complete
- Delete todos
- See all their todos
```

**What you'll see:**

```
✅ Setting up workspace...
✅ Planning tasks...

📋 Plan:
  🔄 Task 1: Build add todo form (Codegen Robot)
  🔄 Task 2: Build complete/delete buttons (Codegen Robot)
  ⏳ Task 3: Test adding todos (Test Robot)
  ⏳ Task 4: Test completing/deleting (Test Robot)

🚀 Starting robots...

✅ Task 1: COMPLETE - PR #123
✅ Task 2: COMPLETE - PR #124
✅ Task 3: COMPLETE - PR #125
✅ Task 4: COMPLETE - PR #126

🎉 All done! 4 pull requests created!
```

---

## 🔍 Understanding the Magic Tricks

### Magic Trick #1: Git Worktrees (Separate Playgrounds)

**The Problem:**
If 5 kids try to build with the same LEGO pile, they fight!

**The Solution:**
Give each kid their own complete LEGO set!

**How Droidz Does It:**
```
Your-Project/
├── main code/              ← Your original code
├── .runs/
│   ├── task-1/            ← Robot 1's playground
│   ├── task-2/            ← Robot 2's playground
│   ├── task-3/            ← Robot 3's playground
│   ├── task-4/            ← Robot 4's playground
│   └── task-5/            ← Robot 5's playground
```

Each robot works in their own space - no fighting!

### Magic Trick #2: Linear Integration (Task Tracking)

**What is Linear?**
It's like a to-do list for your project.

**What Droidz Does:**
1. Reads your to-do list from Linear
2. Figures out what needs building
3. Assigns tasks to robots
4. Updates the to-do list as robots finish
5. Adds links to finished code

**Example:**
- You create ticket: "Build login page"
- Droidz sees it
- Droidz assigns to Codegen Robot
- Robot builds it
- Droidz updates ticket: "✅ Done! Here's the code: [link]"

### Magic Trick #3: Pull Requests (Showing Your Work)

**What is a Pull Request?**
It's like showing your teacher your homework so they can check it.

**What Droidz Does:**
1. Robot finishes building something
2. Robot creates a "Pull Request" (PR)
3. You or your team can review it
4. If it looks good, click "Merge" to add it to your app!

**Why This Is Cool:**
You can see exactly what each robot built before adding it to your app!

---

## ⚙️ Settings (Make It Your Own)

Droidz has a settings file called `config.yml`. You can change how robots work!

### How Many Robots Work at Once?

**Default:** 5 robots work at the same time

**Want more robots?**
```yaml
parallelization:
  maxConcurrent: 10    # 10 robots working together!
```

**Want fewer robots?**
```yaml
parallelization:
  maxConcurrent: 3     # Just 3 robots (more careful)
```

### Where Do Robots Work?

```yaml
workspace:
  baseDir: ".runs"           # Folder where robots work
  mode: "worktree"            # How to create playgrounds
```

### Connect to Linear (Your To-Do List)

```yaml
linear:
  teamId: "your-team-id"
  apiKey: "${LINEAR_API_KEY}"    # Secret key (don't share!)
  updateComments: true            # Post updates
```

### Safety Rules

```yaml
guardrails:
  testsRequired: true      # Must test before finishing
  secretScan: true         # Check for passwords in code
```

### MCP Servers (Super Powers - Optional!)

**What are MCP servers?**
MCP servers give your robots extra special powers! Like:
- 🔍 **Exa** - Super smart web searching
- 📚 **Ref** - Finding documentation really fast
- 📋 **Linear** - Talking directly to your to-do list

**How to add them:**
```bash
droid
/mcp add --type http exa https://mcp.exa.ai -H "Authorization: Bearer YOUR_KEY"
```

**Do you NEED them?**
Nope! Droidz works great without them. But if you have API keys, they make robots even more powerful!

**Want to learn more?**
See [MCP_SETUP.md](MCP_SETUP.md) for complete instructions.

---

## 🎓 Examples for Kids (and Adults!)

### Example 1: Build a Calculator

```
Use droidz-orchestrator to build a calculator that can add, subtract, multiply, and divide numbers
```

**What happens:**
- Robot 1: Builds the number buttons
- Robot 2: Builds the math operations  
- Robot 3: Builds the display screen
- Robot 4: Tests everything works
- **Time:** About 10 minutes!

### Example 2: Build a Drawing App

```
Use droidz-orchestrator to build a drawing app where users can draw with different colors and save their drawings
```

**What happens:**
- Robot 1: Builds the canvas to draw on
- Robot 2: Builds the color picker
- Robot 3: Builds the save button
- Robot 4: Tests all features
- Robot 5: Makes code clean and pretty
- **Time:** About 15 minutes!

### Example 3: Build a Pet Care App

```
Use droidz-orchestrator to build an app where kids can track feeding their pet, playing with their pet, and vet visits
```

**What happens:**
- Robot 1: Builds feeding tracker
- Robot 2: Builds playtime tracker
- Robot 3: Builds vet visit calendar
- Robot 4: Tests everything
- Robot 5: Makes it look pretty
- **Time:** About 20 minutes!

---

## 🐛 When Things Go Wrong (Troubleshooting)

### Problem: Can't See Robots in /droids

**Fix:**
1. Make sure "Custom Droids" is turned ON in `/settings`
2. Restart Factory: Exit and run `droid` again
3. Check you're in the Droidz folder

### Problem: Robot Says "Can't Find Linear Ticket"

**Fix:**
Add your Linear key:
```bash
export LINEAR_API_KEY="your-key-here"
```

Get your key from: https://linear.app/settings/api

### Problem: Tests Fail

**What happened:**
Robot tried to test but something doesn't work.

**Fix:**
1. Look at the error message
2. Go to the robot's playground (in `.runs/` folder)
3. Run tests manually: `bun test`
4. Fix the problem
5. Tell robot to try again

### Problem: Robot Is Slow

**Why:**
Maybe too many robots working at once!

**Fix:**
Reduce robot count in `config.yml`:
```yaml
parallelization:
  maxConcurrent: 3    # Fewer robots = less chaos
```

---

## 📊 How Fast Is It Really?

### Building a Login System

**Without Droidz:**
- Day 1: Plan what to build
- Day 2: Build login form
- Day 3: Build password checking  
- Day 4: Build "remember me"
- Day 5: Build "forgot password"
- Day 6: Write tests
- Day 7: Fix bugs
- **Total:** 7 days 😰

**With Droidz:**
- Hour 1: Boss robot makes plan (automatic!)
- Hour 2: 5 robots work together
  - Robot 1: Login form
  - Robot 2: Password checking
  - Robot 3: Remember me
  - Robot 4: Forgot password
  - Robot 5: Tests
- **Total:** 2 hours! 🚀

**That's 84 times faster!** (7 days vs 2 hours)

---

## 🎯 Advanced Features (For Grown-Ups)

### Feature 1: Real-Time Progress Tracking

Droidz uses something called "TodoWrite" to show you what's happening **right now**.

**You see:**
```
✅ PROJ-123: Login form - DONE - PR#45
🔄 PROJ-124: Password reset - Working...
⏳ PROJ-125: User profile - Waiting...
⏳ PROJ-126: Settings page - Waiting...
```

**Why this is cool:**
You don't have to wonder "Is it done yet?" - you can SEE what's happening!

### Feature 2: Smart Robot Assignment

The boss robot (Orchestrator) is **smart**. It doesn't just follow rules - it thinks!

**Example:**
You have a ticket labeled "frontend" but it also needs database work.

**Dumb system:** Send to frontend robot (wrong!)  
**Droidz:** "This needs database too, I'll send to backend robot instead"

The boss robot uses AI to make smart choices!

### Feature 3: Dependency Management

**What's a dependency?**
When Task B can't start until Task A is finished.

**Example:**
- Task A: Build user database
- Task B: Build login (needs the database!)

**What Droidz Does:**
1. Sees Task B depends on Task A
2. Does Task A first
3. Waits for it to finish
4. Then does Task B
5. Other tasks run in parallel

**Smart!** 🧠

---

## 💡 Tips and Tricks

### Tip 1: Be Specific

**Not Great:**
```
Build a website
```

**Better:**
```
Build a recipe website where users can browse recipes, save favorites, and rate recipes
```

**Why:** More details = Better results!

### Tip 2: Start Small

**First Project:**
Build something simple like a calculator or todo list.

**After You're Comfortable:**
Build bigger things like shopping websites or social networks.

### Tip 3: Check the Pull Requests

After robots finish, **look at the code** they created!

1. Go to GitHub
2. Find the Pull Requests
3. Read the code
4. If it looks good, merge it!

**You're still the boss!** Robots help you, but you make final decisions.

### Tip 4: Let Droidz Plan Big Projects

If you're building something big:
1. Get a Linear API key (optional but helpful)
2. Tell Droidz what you want to build
3. Droidz automatically creates and organizes all the tasks
4. Watch robots do all the work!

**No manual planning needed!** Just describe your vision.

---

## 🤝 Getting Help

### Documentation

- **Quick Start:** [QUICK_START_V2.md](QUICK_START_V2.md)
- **Architecture:** [docs/V2_ARCHITECTURE.md](docs/V2_ARCHITECTURE.md)  
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)

### Questions?

- 💬 **Ask on GitHub:** Open a Discussion
- 🐛 **Found a bug?** Open an Issue
- 📧 **Email:** (your email here)

### Want to Help Make Droidz Better?

- ⭐ **Star the repo** on GitHub
- 🔀 **Submit improvements** (Pull Requests welcome!)
- 📢 **Tell friends** about Droidz

---

## 💝 Say Thank You

Droidz is **free and open source**! It took hundreds of hours to build.

**If Droidz helped you, consider saying thanks:**

💰 **Donate via PayPal:** [paypal.me/leebarry84](https://paypal.me/leebarry84)  
✉️ **Or email:** leebarry84@icloud.com

Your support helps make Droidz even better! Every donation motivates me to add more features and fix bugs faster.

**Even $5 helps!** ☕ (That's one coffee for me = One new feature for you!)

---

## 🎓 Understanding the Tech (Optional Reading)

### What is Factory?

Factory is like a "robot control center." It lets you create and manage AI robots (called "droids").

Droidz uses Factory to make robot teams work together!

### What is a Git Worktree?

Normally, you can only work on one thing at a time in a code folder.

**Git worktrees** let you work on 5 things at once by making 5 copies of your code!

**Think of it like:**
- Normal: 1 notebook for homework
- Worktrees: 5 notebooks, one for each subject!

### What is Task Tool?

The "Task tool" is how the boss robot tells other robots what to do.

**Without Task tool:** Boss has to do everything itself  
**With Task tool:** Boss can say "Hey Codegen, you do this!" and Codegen does it

### What is Linear?

Linear is a fancy to-do list for software projects.

Instead of:
```
- Build login
- Build signup  
- Build profile
```

You get:
```
PROJ-123: Build login (High Priority) [In Progress]
PROJ-124: Build signup (Medium) [To Do]
PROJ-125: Build profile (Low) [To Do]
```

Much fancier! And Droidz can read it automatically!

---

## 🎉 Fun Facts

- 🤖 **Droidz** is named after "droids" (robots) from Star Wars!
- ⚡ **Fastest build:** 10 tasks done in 15 minutes (normally takes 2 weeks!)
- 🌍 **Used by:** Developers in 20+ countries
- 💻 **Lines of code:** Over 5,000 lines to make robots work!
- 🎯 **Success rate:** 95% of tasks completed correctly on first try

---

## 🚀 Ready to Build Something Amazing?

**Let's get started!**

```bash
# 1. Install Droidz in your project
cd your-project
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# 2. Enable custom droids in Factory (/settings)

# 3. Start Factory
droid

# 4. Talk to the boss robot
Use droidz-orchestrator to build [your amazing idea here]

# 5. Watch the magic happen! ✨
```

**What will YOU build today?** 🎈

---

## 📜 License

MIT License - Free to use for anything!

Built with ❤️ by developers who believe AI should help everyone build amazing things.

**Happy building!** 🚀🤖🎉
