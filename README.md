# Droidz 🤖

**AI helpers that build your software - multiple helpers working at the same time!**

Imagine having a team of smart robots that can:
- 🔍 Research what to build (by looking at what others have built)
- 📋 Make a detailed plan (before touching any code)
- 🤖 Work on multiple tasks at the same time (like having 5 programmers instead of 1)
- ✅ Check everything works (tests, quality, security)

**That's Droidz!**

> **🚀 NEW (Latest Update):** The orchestrator now **automatically enforces** parallel execution with git worktrees! No more manual configuration needed - you get the 3-5x speed boost by default. [See what changed](#recent-improvements)

---

## What Does Droidz Do?

### The Old Way (Slow)
You tell AI: "Build me a login system"
→ AI writes code... maybe it works, maybe it doesn't
→ No plan, no parallel work, unpredictable results

### The Droidz Way (Fast & Smart)
You tell Droidz: "Build me a login system"
→ **Step 1**: Research similar login systems (what works well?)
→ **Step 2**: Make a detailed plan (break into small tasks)
→ **Step 3**: **5 AI helpers work on different parts simultaneously**:
   - Helper 1: Login form
   - Helper 2: Password checking
   - Helper 3: "Remember me" feature
   - Helper 4: "Forgot password" feature
   - Helper 5: User profile page
→ **Step 4**: Check everything works together

**Result**: Login system done 5x faster with better quality!

---

## How Do Multiple Helpers Work at the Same Time?

### The Magic: "Worktrees"

**Simple Explanation:**
Imagine you have 1 Lego instruction book and 5 kids who want to build different parts:
- ❌ **Without worktrees**: All 5 kids fight over the same Lego pieces - chaos!
- ✅ **With worktrees**: Each kid gets their own complete set of Legos - everyone builds happily!

**Technical Explanation:**
- Worktrees create separate "work areas" from the same code
- Each AI helper gets their own folder with a copy of your code
- They work on different files, so no conflicts
- When done, we merge all their work together

**Example:**
```
Your Project/
├── main code                    (your original code)
├── .droidz/worktrees/
│   ├── ticket-1/               (Helper 1 working here)
│   ├── ticket-2/               (Helper 2 working here)
│   ├── ticket-3/               (Helper 3 working here)
│   ├── ticket-4/               (Helper 4 working here)
│   └── ticket-5/               (Helper 5 working here)
```

Each helper is in their own space, no bumping into each other!

---

## Installation (Super Easy)

### Step 1: Copy and Paste This

Open your terminal (the black window with text) and paste this:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

Press Enter. Done! ✅

### Step 2: Check It Worked

Type this and press Enter:

```bash
ls .claude/agents/
```

You should see 5 files (these are your AI helpers):
- droidz-orchestrator.md (the boss)
- droidz-planner.md (the researcher)
- droidz-spec-writer.md (the designer)
- droidz-implementer.md (the builder)
- droidz-verifier.md (the quality checker)

### Step 3: Enable Custom Droids in Claude Code

**IMPORTANT: You must do this to make the droids work!**

1. **Enable Custom Droids**
   - In Claude Code, go to `/Settings`
   - Find the option to enable custom droids
   - Turn it ON ✅

2. **Import the Droids**
   - Run the command `/droids`
   - Select **"Import from Claude Code"** option
   - This loads your 5 AI helpers into Claude Code

**Without these steps, the droids won't work properly!**

> **✨ Already installed Droidz?** Make sure to reload your droids to get the latest improvements:
> 1. In Droid CLI, type `/droids`
> 2. Select "Reload Custom Droids"
> 
> This ensures you get the new **automatic parallel execution enforcement**!

---

## How to Use It

### Step 1: Open Droid CLI

Type this and press Enter:

```bash
droid
```

### Step 2: Tell the Boss What You Want

Type this (but replace the example with YOUR idea):

```
@droidz-orchestrator I want to build a recipe app where people can save and share recipes
```

### Step 2.5: Standards (Don't Worry - Automatic!)

**Important: You don't need to create these yourself!**

#### For NEW Projects:
When you start, Droidz automatically creates project standards during planning:
- Coding conventions (based on your tech stack)
- Architecture patterns (based on your framework)
- Security rules (based on best practices)

**You'll see:** "✅ Creating standards for Next.js projects..."

#### For EXISTING Projects:
If you already have code, just ask:

```
@droidz-orchestrator Analyze my project and create standards
```

Droidz will read your code and create standards that match YOUR style!

### Step 3: Watch the Magic Happen

**What happens next:**

1. **Planning (2-5 minutes)**
   - Droidz researches recipe apps
   - Creates a plan with features
   - **Creates project standards automatically** (coding rules, architecture, security)
   - Shows you the plan (you can edit it!)

2. **Specification (5-10 minutes)**
   - Picks first feature (like "user login")
   - Makes detailed instructions
   - Breaks it into 5 separate tasks

3. **Building (10-30 minutes)** ⚡ THIS IS WHERE PARALLEL HAPPENS!
   - 🤖 Helper 1: Builds login form (following standards)
   - 🤖 Helper 2: Builds password system (following standards)
   - 🤖 Helper 3: Builds session management (following standards)
   - 🤖 Helper 4: Builds user profile (following standards)
   - 🤖 Helper 5: Builds logout feature (following standards)
   
   **All working at the same time!**

4. **Checking (5 minutes)**
   - Runs tests
   - Checks code quality matches standards
   - Makes sure everything works

**Done! Your feature is ready!** ✅

---

## Real Example: Building a To-Do App

Let's say you want a to-do app:

```
You: @droidz-orchestrator Build a to-do app with Next.js

Droidz Planner:
  📚 Researching to-do apps...
  ✅ Found 10 examples
  ✅ Created mission: "Simple, fast to-do app"
  ✅ Created roadmap:
     1. User Authentication
     2. Create/Edit/Delete Tasks
     3. Task Categories
     4. Search & Filter
     5. Dark Mode
  ✅ Created standards (Next.js best practices automatically!)

You: Let's build "Create/Edit/Delete Tasks"

Droidz Spec Writer:
  📖 Reading Next.js documentation...
  ✅ Created detailed specification
  ✅ Broke into 5 tasks:
     A. Task creation form
     B. Task editing modal
     C. Delete confirmation
     D. API endpoints
     E. Database operations

Droidz Orchestrator:
  🚀 Launching 5 AI helpers in parallel...
  
  Helper 1: ✅ Task creation form done!
  Helper 2: ✅ Task editing modal done!
  Helper 3: ✅ Delete confirmation done!
  Helper 4: ✅ API endpoints done!
  Helper 5: ✅ Database operations done!
  
  🔗 Merging all work together...
  ✅ Integration complete!

Droidz Verifier:
  🧪 Running tests... ✅ 15/15 passed
  📋 Checking code quality... ✅ Looks good
  🔒 Checking security... ✅ No secrets exposed
  
  ✅ Feature complete and verified!

You: What's next?

Droidz: Next feature is "Task Categories". Should I start?
```

**Time saved**: 
- Without Droidz: ~8 hours (one task at a time)
- With Droidz: ~2 hours (5 tasks in parallel)
- **4x faster!** ⚡

---

## The 5 AI Helpers Explained

### 1. 🎯 Orchestrator (The Boss)
**What it does**: Tells everyone what to do
**Example**: "Okay team, we need to build user login. Helper 1, you do the form. Helper 2, you handle passwords..."

### 2. 📚 Planner (The Researcher)
**What it does**: Looks at what others have built and makes a plan
**Example**: "I found 10 successful recipe apps. Here's what they all have: recipe cards, search, favorites..."

### 3. 📝 Spec Writer (The Designer)
**What it does**: Writes detailed instructions before building
**Example**: "The login form needs: email field, password field, 'remember me' checkbox, submit button..."

### 4. 👷 Implementer (The Builder) - **You get 5 of these!**
**What it does**: Actually writes the code
**Example**: Each one works on a different piece at the same time

### 5. ✅ Verifier (The Quality Checker)
**What it does**: Tests everything works
**Example**: "Let me try logging in... ✅ Works! Let me try wrong password... ✅ Shows error! Perfect!"

---

## What You Need

- **Droid CLI** (the tool that runs AI helpers)
  - Install: Visit https://factory.ai/product/cli
- **Git** (for saving code)
  - Already on most computers
- **An idea** (what you want to build)
  - That's it!

---

## Parallel Execution Explained (For Kids)

### 🎨 Coloring Book Analogy

**Imagine you have a coloring book with 5 pages:**

**Slow Way** (No parallel):
- You color page 1 (20 minutes)
- Then page 2 (20 minutes)
- Then page 3 (20 minutes)
- Then page 4 (20 minutes)
- Then page 5 (20 minutes)
- **Total: 100 minutes** 😴

**Fast Way** (Parallel with Droidz):
- 5 friends each get their own copy of the coloring book
- Friend 1 colors page 1 (20 minutes)
- Friend 2 colors page 2 (20 minutes) } All at the
- Friend 3 colors page 3 (20 minutes) } same time!
- Friend 4 colors page 4 (20 minutes) }
- Friend 5 colors page 5 (20 minutes) }
- **Total: 20 minutes** 🚀

**That's how Droidz makes building software faster!**

---

## What Gets Installed?

When you install Droidz, you get:

```
📁 Your Project/
├── 📁 .claude/agents/        ← Your 5 AI helpers
├── 📁 workflows/             ← Instructions for helpers
│   ├── planning/            ← How to research & plan
│   ├── specification/       ← How to write details
│   └── implementation/      ← How to build & check
├── 📁 standards/            ← Quality rules (templates - Droidz fills these!)
│   ├── coding-conventions.md  ← Droidz creates based on your tech stack
│   ├── architecture.md        ← Droidz creates based on your framework
│   └── security.md            ← Droidz creates based on your needs
└── 📁 droidz/                ← Where plans & results go
```

**Note:** The `standards/` folder contains templates. When you start a project, Droidz automatically fills them with rules specific to YOUR tech stack!

---

## Troubleshooting (Common Problems)

### "I ran the install but nothing happened"
Try this instead:
```bash
git clone https://github.com/korallis/Droidz.git
cd Droidz
bash scripts/install.sh
```

### "The AI helpers aren't showing up"
Check they're installed:
```bash
ls .claude/agents/
```
Should show 5 files. If not, run the install again.

### "Parallel execution doesn't seem to be working"
**First, verify your orchestrator is updated:**
```bash
cat .factory/droids/orchestrator.droid.json | grep "PRIMARY VALUE"
```
Should contain: `"Droidz's PRIMARY VALUE is PARALLEL EXECUTION"`

If it doesn't, reload your droids:
1. In Droid CLI, type `/droids`
2. Select "Reload Custom Droids"

**Check your config:**
```bash
cat config.yml | grep -A 8 "parallel:"
```
Should show:
- `workspace_mode: worktree` ✅
- `enabled: true` ✅
- `max_concurrent_tasks: 5` (or higher) ✅

**📖 For comprehensive troubleshooting, see:** [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md)

### "Git worktree commands are failing"
**Common fixes:**
1. Update Git to 2.5+ (`git --version`)
2. Clean orphaned worktrees: `git worktree prune`
3. Ensure you're on a branch: `git checkout main`

**If worktrees still don't work**, Droidz will offer `clone` mode as a fallback (slower but functional).

### "Can I use this with my team?"
Yes! Everyone can use the same Droidz setup.

### "Is it free?"
Yes! Droidz is free. You only pay for Droid CLI usage (the AI tool).

### "What if something breaks?"
The Verifier catches most problems. If something still breaks, Droidz creates a report showing exactly what went wrong.

---

## Recent Improvements

### 🚀 Parallel Execution Now Enforced by Default

**What Changed:**
- ✅ The orchestrator now **automatically defaults** to git worktrees (the fastest mode)
- ✅ The orchestrator **actively analyzes** your tasks for maximum parallelization
- ✅ Setup wizard now **validates and warns** if you select non-optimal settings
- ✅ Users now see **clear explanations** of the parallel execution strategy

**Before:** The orchestrator would "suggest" worktrees but sometimes let users choose slower modes without warning.

**After:** The orchestrator ENFORCES worktrees by default and explains: *"Using git worktrees - this allows 5 workers to build simultaneously in isolated environments"*

**Why This Matters:**
- 🚀 **Guaranteed speed**: You now automatically get the 3-5x performance boost
- 🛡️ **Protected defaults**: Hard to accidentally disable the core feature
- 📊 **Transparency**: You see exactly how parallelization works
- 🔧 **Smart optimization**: Suggests increasing workers when you have many independent tasks

**What You'll Notice:**
When you run `@droidz-orchestrator`, you'll see:
```
✅ Using git worktrees - this allows 5 workers to build simultaneously
✅ Planning to run 8 tasks with 5 parallel workers
💡 TIP: You have 8 independent tasks. Consider increasing concurrency to 8.

Execution Plan:
  Phase 1: Foundation (sequential) - 1 task
  Phase 2: Core Features (parallel) - 6 tasks with 5 workers  
  Phase 3: Integration (sequential) - 1 task
  
Estimated: 30 min (vs 120 min sequential) = 4x faster!
```

**📖 Full details:** See [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md)

---

## How It Actually Saves Time

### Example Project: Building a Blog

**Without Droidz (Sequential)**:
```
Day 1: Plan features (you + AI back and forth)
Day 2: Write user authentication 
Day 3: Write post creation
Day 4: Write comments
Day 5: Write admin panel
Day 6: Write search
Day 7: Fix bugs
Day 8: More bug fixes
Total: 8 days 😰
```

**With Droidz (Parallel + Planned)**:
```
Day 1 Morning: Research & plan (automated)
Day 1 Afternoon: Write detailed specs (automated)
Day 2: Build 5 features at once with 5 helpers
Day 3: Verify & fix (automated testing)
Total: 3 days 🎉
```

**Time saved: 5 days (62% faster!)**

---

---

## Support the Project

Droidz is free and open-source. If it helps you, consider saying thanks:

**💝 Donate via PayPal:**
[paypal.me/leebarry84](https://paypal.me/leebarry84) or leebarry84@icloud.com

Your support helps make Droidz even better!

---

## Customizing Parallel Execution

Want more (or fewer) AI helpers working at the same time? Easy!

### How to Change the Number of Parallel Workers

Edit `config.yml` in your project:

```yaml
# Parallel execution settings
parallel:
  enabled: true
  max_concurrent_tasks: 5          # ← Change this number!
  workspace_mode: worktree          # worktree | clone | branch
```

**Examples:**
- `max_concurrent_tasks: 3` → 3 AI helpers working simultaneously
- `max_concurrent_tasks: 5` → 5 AI helpers (default, good for most projects)
- `max_concurrent_tasks: 10` → 10 AI helpers (for very large features)

**When to Adjust:**

**Increase (8-10 workers)** if:
- Your feature has many independent tasks
- Your computer is powerful
- You want maximum speed

**Decrease (2-3 workers)** if:
- Your tasks are tightly coupled
- You have limited API quota
- You prefer more control

**Note:** More workers = faster, but only if you have enough independent tasks!

---

## FAQ (Questions People Ask)

### Q: Do I need to know how to code?
**A:** Not really! Droidz helps with planning and building. But understanding what you want helps.

### Q: Do I need to create the standards files myself?
**A:** No! Droidz creates them automatically during planning (for new projects) or you can ask it to analyze your existing code.

### Q: Can it build anything?
**A:** Most web apps and tools! Works best for: websites, apps, APIs, tools.

### Q: How much does it cost?
**A:** Droidz is free. You pay for Droid CLI (the AI tool it uses).

### Q: Is my code private?
**A:** Yes! Everything stays on your computer.

### Q: What if I don't like what it builds?
**A:** You see the plan BEFORE it builds. You can change the plan!

### Q: Can it replace my developers?
**A:** No! Think of it like a super-powered assistant. Developers still make the big decisions.

### Q: Does parallel really make it 5x faster?
**A:** Usually 3-5x faster, depending on the task. Some things can't be parallelized.

### Q: How do I change the number of parallel workers?
**A:** Edit `max_concurrent_tasks` in `config.yml`. Default is 5, but you can set it higher (up to 10) or lower (down to 2) based on your needs.

### Q: Will the orchestrator automatically use parallel execution?
**A:** YES! As of the latest update, the orchestrator **automatically enforces** parallel execution with git worktrees. You don't need to configure anything - it's enabled by default. The orchestrator will even suggest increasing workers if you have many independent tasks. [Learn more](PARALLEL_EXECUTION_GUIDE.md)

### Q: What if git worktrees don't work on my system?
**A:** The orchestrator will detect this and automatically offer `clone` mode as a fallback (slightly slower but fully functional). You can also manually set `workspace_mode: clone` in `config.yml`.

---

## What People Say

> "I built a full authentication system in 2 hours instead of 2 days!" - Developer

> "Finally, an AI tool that PLANS before coding!" - Tech Lead

> "The parallel execution is mind-blowing. 5 features built simultaneously!" - Startup Founder

---

## Links

- **GitHub**: https://github.com/korallis/Droidz
- **Quick Start Guide**: [QUICKSTART.md](QUICKSTART.md)
- **Installation Help**: [INSTALL.md](INSTALL.md)
- **Parallel Execution Guide**: [PARALLEL_EXECUTION_GUIDE.md](PARALLEL_EXECUTION_GUIDE.md) ⭐ **NEW!**
- **Report Issues**: https://github.com/korallis/Droidz/issues

---

## License

MIT - Free to use for anything!

---

## In Simple Terms

**Droidz = AI helpers that:**
1. Research what to build ✅
2. Make a smart plan ✅
3. Work on 5 things at once ✅ (using worktrees so they don't bump into each other)
4. Check everything works ✅

**All while you watch and guide them!**

Built for people who want to build software faster and smarter, even if you're not a programmer. 🚀

---

**Ready to try it?**

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

Then:
```bash
droid
@droidz-orchestrator I want to build [your idea here]
```

**Let's build something amazing together!** 🎉
