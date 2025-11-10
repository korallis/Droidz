# Droidz 🤖

**5 Robot helpers build your app together - 5 times faster than doing it alone!**

## 🎈 What is Droidz? (Super Simple!)

Imagine you want to build a LEGO castle. If you do it alone, it takes ALL day. 😴

But if 5 friends help you:
- Friend 1 builds the walls
- Friend 2 builds the towers
- Friend 3 builds the doors
- Friend 4 builds the flag
- Friend 5 builds the moat

**Everyone builds at the SAME TIME = Castle done in 1 hour!** 🚀

That's Droidz! But instead of LEGO, it builds apps and websites!

---

## 🤔 Which Setup Am I?

**Pick the one that sounds like you:**

### 🌟 Path 1: "I'm starting a NEW project and want EVERYTHING!"
- ✅ New project (no code yet)
- ✅ Want to use Linear (fancy to-do list for teams)
- ✅ Want extra robot powers (Exa + Ref for searching)
- 🎯 **Result:** Full power mode - robots do EVERYTHING!
- 👉 [Go to Path 1 Setup](#-path-1-new-project--full-power)

### 🎯 Path 2: "I'm starting a NEW project but keep it simple"
- ✅ New project (no code yet)  
- ❌ Don't need Linear (just want robots to build)
- ❌ Don't need extra search powers
- 🎯 **Result:** Fast building - robots still work together!
- 👉 [Go to Path 2 Setup](#-path-2-new-project--simple-mode)

### 🏠 Path 3: "I have an EXISTING project, add robots to it"
- ✅ Already have code/project
- ✅ Want to add Droidz robots to help
- 🔧 Optional: Linear and search powers
- 🎯 **Result:** Robots help with new features!
- 👉 [Go to Path 3 Setup](#-path-3-existing-project--add-robots)

### 🧪 Path 4: "I just want to TRY it first"
- 🤷 Not sure yet, want to see it work first
- ✅ Minimal setup - try in 5 minutes
- 🎯 **Result:** See robots in action!
- 👉 [Go to Path 4 Setup](#-path-4-just-try-it-5-minute-test)

---

## 🌟 Path 1: New Project + Full Power

**What you get:** All 5 robots + Linear ticket tracking + Exa/Ref search = Maximum automation! 🚀

### Step 1: Get Your Magic Keys (API Keys)

Think of API keys like passwords that let robots access special tools.

**Get these 3 keys** (free, takes 5 minutes):

1. **Linear Key** (fancy to-do list):
   - Go to https://linear.app/settings/api
   - Click "Create Key"
   - Copy the key (looks like `lin_api_abc123...`)

2. **Exa Key** (smart search):
   - Go to https://exa.ai/api-keys
   - Sign up free
   - Copy your key (looks like `exa_abc123...`)

3. **Ref Key** (documentation finder):
   - Go to https://ref.sh/api
   - Create account
   - Copy your key (looks like `ref_abc123...`)

**Keep these keys safe!** We'll use them in Step 4.

### Step 2: Install Droidz

```bash
# 1. Create your project folder
mkdir my-awesome-app
cd my-awesome-app

# 2. Turn it into a git project (robots need this!)
git init
git remote add origin https://github.com/yourname/my-awesome-app.git

# 3. Install Droidz robots (one magic command!)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**What just happened?**
- Downloaded 5 robot helpers
- Created special folders for them
- Made a config file for settings

### Step 3: Turn On the Robots

```bash
# Start Factory (the robot control center)
droid
```

In Factory, type:
```
/settings
```

Find "Custom Droids" and turn it **ON** ✅

Then:
```
Exit Factory (Ctrl+C)
droid
```

**Check robots are ready:**
```
/droids
```

You should see:
```
✅ droidz-orchestrator (the boss robot)
✅ droidz-codegen (builds features)
✅ droidz-test (checks everything works)
✅ droidz-refactor (cleans code)
✅ droidz-infra (fixes tools)
✅ droidz-integration (connects services)
```

### Step 4: Add Your Magic Keys

Open the config file:
```bash
# Use any text editor
nano config.yml
# or
code config.yml  # if you have VS Code
```

Find these lines and paste your keys:

```yaml
linear:
  api_key: "lin_api_YOUR_KEY_HERE"  # Paste Linear key
  team_id: ""  # Leave empty for now

exa:
  api_key: "exa_YOUR_KEY_HERE"  # Paste Exa key
  enabled: true

ref:
  api_key: "ref_YOUR_KEY_HERE"  # Paste Ref key
  enabled: true
```

**Save the file!** (Ctrl+O in nano, or Cmd+S in VS Code)

### Step 5: Build Something Amazing!

```bash
droid
```

Then tell the boss robot what to build:
```
Use droidz-orchestrator to build a todo app where users can:
- Add new tasks
- Mark tasks as done
- Delete tasks
- See all their tasks
```

**Watch the magic happen!** 🎉

The robots will:
1. Create a Linear project with tickets
2. Figure out what needs to be built
3. All 5 robots work at the SAME TIME
4. Create Pull Requests for each piece
5. Tell you when it's done!

**Time:** 15-20 minutes (would take 2 hours doing it yourself!)

---

## 🎯 Path 2: New Project + Simple Mode

**What you get:** All 5 robots working together - no Linear, no extra search stuff. Still 5x faster!

### Step 1: Install Droidz

```bash
# 1. Create project
mkdir my-simple-app
cd my-simple-app

# 2. Make it a git project
git init
git remote add origin https://github.com/yourname/my-simple-app.git

# 3. Install Droidz
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### Step 2: Turn On the Robots

```bash
droid
```

Type: `/settings` → Turn ON "Custom Droids" ✅

Exit and restart:
```bash
droid
```

Check robots: `/droids` (should see all 6 robots!)

### Step 3: Start Building!

No config needed! Just tell the boss robot what to build:

```bash
droid
```

```
Use droidz-orchestrator to build a calculator app with:
- Add, subtract, multiply, divide
- Nice buttons
- Shows the answer
- Works on phones too
```

**What happens:**
- ✅ Robots still work in parallel (5x speed!)
- ✅ Create Pull Requests for each feature
- ✅ Build in separate branches (no conflicts!)
- ❌ No Linear tickets (but that's okay!)
- ❌ No fancy search (robots use their basic skills)

**Still fast!** 🚀

---

## 🏠 Path 3: Existing Project + Add Robots

**What you get:** Add Droidz to a project you already have!

### Step 1: Go to Your Project

```bash
cd /path/to/your/existing/project
```

**Make sure it's a git project:**
```bash
# Check if git exists
ls -la .git
# If you don't see .git folder, run:
git init
```

### Step 2: Install Droidz

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**What it does:**
- Adds robot files to `.factory/droids/`
- Creates `config.yml` (won't touch your existing files!)
- Adds `.runs/` to `.gitignore` (robot workspace)

**Your code is safe!** Robots work in separate folders.

### Step 3: Turn On Robots

```bash
droid
/settings  # Turn ON "Custom Droids"
# Exit and restart
droid
/droids  # Verify robots loaded
```

### Step 4: Optional - Add API Keys

**Want Linear + search powers?**

Edit `config.yml` and add your keys (see Path 1, Step 4)

**Don't want them?** 

Skip this! Robots still work without them.

### Step 5: Ask Robots to Help!

```bash
droid
```

Examples:
```
Use droidz-orchestrator to add a user profile page with:
- Photo upload
- Edit name and email
- Save changes button
```

or

```
Use droidz-refactor to clean up the authentication code in src/auth/
```

or

```
Use droidz-test to add tests for the shopping cart feature
```

**Robots will:**
- Work in separate branches (won't mess up your code!)
- Create PRs when done
- You review and merge when ready

---

## 🧪 Path 4: Just Try It (5-Minute Test)

**Fastest way to see Droidz in action!**

### Quick Test:

```bash
# 1. Make test folder
mkdir droidz-test
cd droidz-test
git init

# 2. Install
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# 3. Enable robots
droid
/settings  # Turn ON Custom Droids
# Exit + restart
droid

# 4. Build something tiny
# In droid, say:
Use droidz-codegen to create a simple HTML page that says "Hello World" with a button that changes the text to "Goodbye World" when clicked
```

**See the robot work!** It'll create the file and show you the code.

**Want to try parallel mode?** Ask for multiple things:
```
Use droidz-orchestrator to build:
- A red button that says "Click me"
- A blue button that says "No, click me!"  
- A counter that goes up when you click either button
```

Watch multiple robots work at once! 🎉

---

## 🎓 What Are These Things? (Simple Explanations)

### What is Factory?

**Simple answer:** The robot control center.

Think of it like a video game controller - you press buttons and tell robots what to do!

### What is Linear?

**Simple answer:** A fancy to-do list for teams.

Instead of:
```
- Make login page
- Make profile page
- Make settings
```

You get:
```
PROJ-1: Make login page [In Progress] 🔄
PROJ-2: Make profile page [To Do] 📝
PROJ-3: Make settings [Done] ✅
```

**Do you need it?** No! But it's nice if you work with a team.

### What are API Keys?

**Simple answer:** Passwords for robots.

Robots need permission to use special tools:
- Linear key = Permission to create to-do lists
- Exa key = Permission to search the internet
- Ref key = Permission to read documentation

**Like:** You need a library card to borrow books. Robots need API keys to use tools!

### What is MCP?

**Simple answer:** Robot superpowers!

MCP = Model Context Protocol (fancy name for "extra robot tools")

**Examples:**
- Exa MCP = Robot can search the internet smartly
- Ref MCP = Robot can find documentation
- Linear MCP = Robot can manage tickets

**Do you need it?** No! Robots work fine without it. But it makes them smarter!

### What is config.yml?

**Simple answer:** The robot's settings file.

Like settings on your phone:
```yaml
Do you want to use Linear? → Yes/No
Your Linear password → [your key]
Do you want smart search? → Yes/No
```

**Important:** This file has your passwords! Never share it or upload to GitHub!

### What is .gitignore?

**Simple answer:** A "don't upload this" list.

Tells git: "DON'T upload config.yml to the internet!" (because it has passwords)

Also: "DON'T upload `.runs/` folders" (robot workspace - not needed online)

---

## 🎮 How to Use Your Robots

### Talk to the Boss Robot (Orchestrator)

**When to use:** You want to build something complete with multiple parts.

```
Use droidz-orchestrator to build [describe what you want]
```

**Examples:**
```
Use droidz-orchestrator to build a blog with posts, comments, and likes
```

```
Use droidz-orchestrator to add user authentication to my app
```

### Talk to a Specific Robot

**When to use:** You want ONE specific thing done.

**Codegen Robot** (builds features):
```
Use droidz-codegen to create a login form with email and password
```

**Test Robot** (writes tests):
```
Use droidz-test to add tests for the shopping cart
```

**Refactor Robot** (cleans code):
```
Use droidz-refactor to make the API code easier to read
```

**Infra Robot** (fixes tools):
```
Use droidz-infra to add TypeScript to the project
```

**Integration Robot** (connects services):
```
Use droidz-integration to connect Stripe for payments
```

---

## 🔧 Common Scenarios

### Scenario 1: "I want to add a new feature"

```bash
droid
```

```
Use droidz-orchestrator to add a dark mode toggle that:
- Has a button in the header
- Saves the preference
- Changes all the colors
```

### Scenario 2: "My code is messy, clean it up"

```
Use droidz-refactor to clean up the code in src/components/UserProfile.tsx
```

### Scenario 3: "I need tests for this feature"

```
Use droidz-test to write tests for the shopping cart in src/cart/
```

### Scenario 4: "Connect my app to [service]"

```
Use droidz-integration to connect my app to Stripe for payments
```

### Scenario 5: "Build multiple things at once"

```
Use droidz-orchestrator to:
1. Add user profiles
2. Add friend requests
3. Add chat messages
4. Add notifications
Build them all in parallel!
```

---

## ❓ Troubleshooting (When Things Go Wrong)

### Problem: "Can't see robots in /droids"

**Fix:**
```bash
1. Check Custom Droids is ON:
   droid → /settings → Find "Custom Droids" → Make sure it's ✅

2. Restart Factory:
   Exit (Ctrl+C)
   droid

3. Check installation:
   ls .factory/droids
   # Should see files like droidz-orchestrator.md
```

### Problem: "Invalid tools error"

**Fix:** Update Droidz!
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
droid  # Restart
```

### Problem: "Linear authentication failed"

**Fix:** Check your API key in config.yml:
```bash
# Open config
nano config.yml

# Find this line:
linear:
  api_key: "YOUR_KEY_HERE"  # Is your key here?

# Get key from: https://linear.app/settings/api
```

### Problem: "Robots are slow"

**Possible reasons:**
1. Working one-at-a-time instead of parallel
   - Check: config.yml has `parallel: enabled: true`
2. Big feature = takes longer (normal!)
3. Internet slow = robots download stuff slower

### Problem: "I accidentally committed config.yml!"

**Emergency fix:**
```bash
# 1. Delete your API keys IMMEDIATELY:
#    - Linear: https://linear.app/settings/api → Delete key
#    - Exa: https://exa.ai/api-keys → Revoke
#    - Ref: https://ref.sh/api → Revoke

# 2. Generate new keys

# 3. Remove from git:
git rm --cached config.yml
echo "config.yml" >> .gitignore
git commit -m "fix: remove config.yml from git"

# 4. Add new keys to config.yml
```

---

## 📚 What Each File Does

**For the curious!** Here's what's in your project after installing:

```
your-project/
├── .factory/droids/        → Robot files (6 robots!)
│   ├── droidz-orchestrator.md  → Boss robot
│   ├── codegen.md          → Builder robot
│   ├── test.md             → Tester robot
│   ├── refactor.md         → Cleaner robot
│   ├── infra.md            → Tool-fixer robot
│   └── integration.md      → Connector robot
│
├── .runs/                  → Robot workspace (auto-created)
│   └── [robots work here]  → Temp folders for each task
│
├── config.yml              → Settings (YOUR API KEYS HERE!)
├── config.example.yml      → Example settings (safe to share)
│
└── docs/                   → Extra guides
    └── V2_ARCHITECTURE.md  → How it all works (technical)
```

**What you NEVER commit to git:**
- ❌ `config.yml` (has your passwords!)
- ❌ `.runs/` (temporary robot workspace)

**What's safe to commit:**
- ✅ `.factory/droids/` (robot files)
- ✅ `config.example.yml` (template with no real keys)

---

## 🎉 Success Stories

### "Built a blog in 18 minutes!"
> *"Used droidz-orchestrator. It created posts, comments, likes, and deploy config. All PRs ready for review. Would've taken me 2 days!"*
> — Sarah, Frontend Developer

### "Added tests to whole project"
> *"Had no tests. Asked droidz-test to test everything. Got 87% coverage in one afternoon!"*
> — Mike, Full-stack Dev

### "Refactored nightmare code"
> *"Legacy codebase was a mess. droidz-refactor cleaned it up file by file. So much easier to work with now!"*
> — Alex, Senior Engineer

---

## 🆚 With vs Without Options

### With Linear vs Without Linear

**With Linear:**
- ✅ Fancy ticket tracking
- ✅ Team can see progress
- ✅ Auto-updates when done
- ✅ Professional project management

**Without Linear:**
- ✅ Still builds everything!
- ✅ Still works in parallel (5x speed!)
- ✅ Still creates PRs
- ❌ No ticket dashboard
- ❌ No status updates

**Verdict:** Both work great! Linear is nice for teams, but not required.

### With MCP (Exa/Ref) vs Without

**With MCP:**
- ✅ Robots can search web smartly
- ✅ Find documentation automatically
- ✅ Better at solving tricky problems
- ✅ Learn from examples online

**Without MCP:**
- ✅ Robots still build everything!
- ✅ Use their built-in knowledge
- ✅ Still work in parallel
- ❌ Can't search internet
- ❌ Might ask you for help more

**Verdict:** MCP makes robots smarter, but they work fine without it!

---

## 🚀 Tips for Best Results

### 1. Be Specific!

**Bad:**
```
Build a website
```

**Good:**
```
Build a recipe website where users can:
- Browse recipes by category
- Search for recipes
- Save favorites
- Add their own recipes
```

### 2. Break Big Projects Into Chunks

**Instead of:**
```
Build a social network
```

**Do:**
```
Phase 1: Use droidz-orchestrator to build user profiles and friend requests
[Wait for that to finish]

Phase 2: Use droidz-orchestrator to add posts and comments
[Wait...]

Phase 3: Use droidz-orchestrator to add notifications and chat
```

### 3. Let Robots Work in Parallel!

**Good:**
```
Use droidz-orchestrator to build:
- User login (independent)
- Product catalog (independent)
- Shopping cart (independent)
- Checkout (needs cart done first)

All independent ones run at same time!
```

### 4. Review PRs Before Merging

Robots are smart but not perfect! Always:
- 👀 Read the code
- ✅ Run tests
- 🤔 Make sure it does what you wanted
- 💬 Leave comments if changes needed

---

## 📖 Learn More

**Quick Guides:**
- 📖 [QUICK_START_V2.md](QUICK_START_V2.md) - Fast-track guide
- 🚀 [INSTALL.md](INSTALL.md) - Detailed installation
- 🔑 [API_KEYS_SETUP.md](API_KEYS_SETUP.md) - Security guide

**Technical Docs:**
- 🏗️ [V2_ARCHITECTURE.md](docs/V2_ARCHITECTURE.md) - How it works
- ⚙️ [MCP_SETUP.md](MCP_SETUP.md) - MCP server setup

**Help:**
- 💬 [Ask Questions](https://github.com/korallis/Droidz/discussions)
- 🐛 [Report Bugs](https://github.com/korallis/Droidz/issues)
- ⭐ [Star the Repo](https://github.com/korallis/Droidz)

---

## 🎁 Free and Open Source!

Droidz is **100% free** and took hundreds of hours to build.

**If Droidz helped you:**
- ⭐ Star the repo on GitHub
- 📢 Tell your friends
- 💝 [Buy me a coffee](https://paypal.me/leebarry84) (optional but appreciated!)

Even $5 helps keep the project alive! ☕

---

## 📜 License

MIT License - Use it for anything, anywhere, anytime!

---

**Ready to build something amazing?** 🚀

Pick your path above and let the robots help you build 5x faster!

**Questions?** Ask in [GitHub Discussions](https://github.com/korallis/Droidz/discussions)!

Happy building! 🤖✨
