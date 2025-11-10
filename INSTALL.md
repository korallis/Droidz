# Droidz Installation Guide

Simple installation guide for Droidz V2.

---

## 🚀 Quick Install (Recommended)

### For New Projects

```bash
# 1. Install Factory CLI
curl -fsSL https://app.factory.ai/cli | sh

# 2. Install Bun (Recommended - 3-10x faster!)
curl -fsSL https://bun.sh/install | bash
# Restart terminal, then verify:
bun --version

# Alternative: Use Node.js (already installed?)
node --version

# 3. Go to your project
cd your-project

# 4. Install Droidz
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash

# 5. Add your API keys (optional)
nano config.yml
# Add Linear, Exa, and Ref API keys
# See API_KEYS_SETUP.md for details

# 6. Enable custom droids
droid
/settings
# Toggle "Custom Droids" ON
# Exit and restart: droid

# 7. Verify
/droids
# Should see all droidz-* robots
```

### For Existing Projects

Already have a project? Same command!

```bash
cd your-existing-project
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

The installer is smart:
- ✅ Detects existing installations
- ✅ Updates files to latest version
- ✅ Preserves your config.yml settings
- ✅ Safe to run multiple times

---

## 🔄 Updating Droidz

Already have Droidz? Update to the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

**What gets updated:**
- ✅ All droid definitions (.factory/droids/)
- ✅ Orchestrator scripts (orchestrator/*.ts)
- ✅ Documentation (QUICK_START_V2.md, etc.)
- ✅ Architecture docs
- ✅ config.example.yml (template)

**What's preserved:**
- ✅ Your config.yml (your API keys are safe!)
- ✅ Your custom settings
- ✅ Your git history
- ✅ Your .gitignore (config.yml remains gitignored)

---

## 📦 What Gets Installed

The install script adds these files to your project:

```
your-project/
├── .factory/
│   └── droids/                      # Robot helpers
│       ├── droidz-orchestrator.md   # Boss robot
│       ├── codegen.md               # Code writer
│       ├── test.md                  # Test writer
│       ├── refactor.md              # Code cleaner
│       ├── infra.md                 # Infrastructure
│       └── integration.md           # External services
├── orchestrator/                    # Helper scripts
│   ├── linear-fetch.ts              # Fetch Linear tickets
│   ├── linear-update.ts             # Update tickets
│   ├── worktree-setup.ts            # Git worktree manager
│   └── task-coordinator.ts          # Coordinator bridge
├── docs/
│   ├── V2_ARCHITECTURE.md           # Technical docs
│   └── (other docs)
├── config.yml                       # YOUR configuration (gitignored!)
├── config.example.yml               # Template (safe to commit)
├── API_KEYS_SETUP.md               # Security guide
├── MCP_SETUP.md                    # MCP server setup
├── QUICK_START_V2.md               # Quick start guide
└── CHANGELOG.md                     # Version history
```

**Total size:** ~500KB (just text files!)

---

## 🛠️ Manual Installation

Prefer to install manually? Here's how:

### 1. Create Directories

```bash
mkdir -p .factory/droids
mkdir -p orchestrator
mkdir -p docs
```

### 2. Download Droids

```bash
cd .factory/droids

# Download each droid
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/droidz-orchestrator.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/codegen.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/test.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/refactor.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/infra.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/integration.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/.factory/droids/generalist.md

cd ../..
```

### 3. Download Orchestrator Scripts

```bash
cd orchestrator

curl -O https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/linear-fetch.ts
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/linear-update.ts
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/worktree-setup.ts
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/orchestrator/task-coordinator.ts

chmod +x *.ts
cd ..
```

### 4. Download Config and Docs

```bash
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/config.yml
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/QUICK_START_V2.md
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/CHANGELOG.md

cd docs
curl -O https://raw.githubusercontent.com/korallis/Droidz/main/docs/V2_ARCHITECTURE.md
cd ..
```

### 5. Update .gitignore

```bash
echo ".runs/" >> .gitignore
```

---

## ⚙️ Configuration

### Linear Integration (Optional)

If you're using Linear for ticket management:

1. **Get API Key:** https://linear.app/settings/api
2. **Set environment variable:**
   ```bash
   export LINEAR_API_KEY="lin_api_..."
   ```
3. **Update config.yml:**
   ```yaml
   linear:
     teamId: "your-team-id"
     apiKey: "${LINEAR_API_KEY}"
   ```

### GitHub CLI (Required for PRs)

Install and authenticate:

```bash
# Install gh
brew install gh  # macOS
# or: https://cli.github.com/

# Authenticate
gh auth login
```

### Factory CLI (Required)

```bash
# Install
curl -fsSL https://app.factory.ai/cli | sh

# Verify
droid --version
```

---

## ✅ Verify Installation

### Check Files Exist

```bash
ls .factory/droids/droidz-*.md
ls orchestrator/*.ts
ls config.yml
```

Should see all files listed.

### Check Factory Recognizes Droids

```bash
droid
/droids
```

Should show:
- droidz-orchestrator
- droidz-codegen
- droidz-test
- droidz-refactor
- droidz-infra
- droidz-integration

### Test with Simple Task

```bash
droid
```

Then say:
```
Use droidz-orchestrator to create a simple hello world function
```

Should see:
- ✅ Orchestrator creates plan
- ✅ Delegates to codegen
- ✅ Code is created
- ✅ Tests run (if configured)

---

## 🔧 Troubleshooting

### Problem: "Custom droids not found"

**Solution:**
1. Make sure Custom Droids is enabled: `droid` → `/settings`
2. Restart Factory: Exit and run `droid` again
3. Verify files exist: `ls .factory/droids/`

### Problem: "Permission denied" when running install script

**Solution:**
```bash
# Download and run manually
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh > install.sh
chmod +x install.sh
./install.sh
```

### Problem: "Not in a git repository"

**Solution:**
```bash
git init
git remote add origin <your-repo-url>
```

The installer requires a git repository.

### Problem: Install script fails partway through

**Solution:**
Safe to re-run! The script is idempotent:
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

---

## 🗑️ Uninstalling

To remove Droidz from your project:

```bash
# Remove droids
rm -rf .factory/droids/droidz-*.md

# Remove orchestrator scripts
rm -rf orchestrator/

# Remove docs
rm -f QUICK_START_V2.md CHANGELOG.md
rm -f docs/V2_ARCHITECTURE.md

# Remove config (optional)
rm -f config.yml
```

Or keep the files and just disable in Factory:
```bash
droid
/settings
# Toggle "Custom Droids" OFF
```

---

## 💡 Next Steps

After installation:

1. **Read Quick Start:** [QUICK_START_V2.md](QUICK_START_V2.md)
2. **Configure Linear:** Add your API key to config.yml
3. **Try Example:** Build something simple to test
4. **Read Architecture:** [docs/V2_ARCHITECTURE.md](docs/V2_ARCHITECTURE.md)
5. **Start Building:** Use orchestrator for real projects!

---

## 📚 Additional Resources

- **Quick Start Guide:** QUICK_START_V2.md
- **Architecture Docs:** docs/V2_ARCHITECTURE.md
- **Changelog:** CHANGELOG.md
- **GitHub:** https://github.com/korallis/Droidz
- **Factory Docs:** https://docs.factory.ai

---

## 💝 Support

Like Droidz? Consider supporting development:

**PayPal:** https://paypal.me/leebarry84  
**Email:** leebarry84@icloud.com

Your support helps make Droidz even better! 🚀
