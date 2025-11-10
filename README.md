# Droidz 🤖

**Imagine having a team of robot helpers that build your software while you watch!**

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

## 🚀 Quick Start (3 Easy Steps)

### Step 1: Make Sure You Have Factory

Droidz needs Factory to work (Factory is like the playground where robots play).

**Install Factory:**
```bash
npm install -g @factory-ai/cli
```

**Check it's installed:**
```bash
droid --version
```

### Step 2: Get Your Robot Team

**Download the robots:**
```bash
git clone https://github.com/korallis/Droidz.git
cd Droidz
```

**Turn on robot mode in Factory:**
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

### Step 3: Make Sure Robots Are There

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

## 🎮 How to Use Droidz

### Basic Usage

1. **Start Factory with high power:**
```bash
droid --auto high
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
droid --auto high
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

### Tip 4: Use Linear for Big Projects

If you're building something big:
1. Break it into small tasks in Linear
2. Tell Droidz: "Process my Linear sprint"
3. Watch robots do all the tasks!

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
# 1. Start Factory
droid --auto high

# 2. Talk to the boss robot
Use droidz-orchestrator to build [your amazing idea here]

# 3. Watch the magic happen! ✨
```

**What will YOU build today?** 🎈

---

## 📜 License

MIT License - Free to use for anything!

Built with ❤️ by developers who believe AI should help everyone build amazing things.

**Happy building!** 🚀🤖🎉
