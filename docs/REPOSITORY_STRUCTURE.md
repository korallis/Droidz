# Droidz Repository Structure

## Understanding What Each File/Folder Does

This document explains the purpose of every file and folder in the Droidz repository.

---

## 📦 Framework Repository (What You See on GitHub)

### Root Files

| File | Purpose | Committed to Git? |
|------|---------|-------------------|
| **README.md** | Main documentation, quick start guide | ✅ Yes |
| **CHANGELOG.md** | Version history and release notes | ✅ Yes |
| **COMMANDS.md** | Complete reference for 4 slash commands | ✅ Yes |
| **install.sh** | Installer script that sets up Droidz | ✅ Yes |
| **config.example.yml** | Template showing available configuration options | ✅ Yes |
| **package.json** | Node.js dependencies for TypeScript orchestrator | ✅ Yes |
| **plugin.json** | Factory.ai plugin metadata | ✅ Yes |
| **bun.lock** | Dependency lock file | ✅ Yes |
| **.gitignore** | Specifies what NOT to commit | ✅ Yes |

### Root Folders

| Folder | Purpose | Committed to Git? |
|--------|---------|-------------------|
| **docs/** | Documentation (audit reports, guides, archived docs) | ✅ Yes |
| **.factory/** | The actual Droidz framework code | ✅ Yes |
| **node_modules/** | JavaScript dependencies (auto-installed) | ❌ No (gitignored) |

---

## 🏗️ `.factory/` - The Framework Code

This is the heart of Droidz. All framework components live here.

### `.factory/` Structure

```
.factory/
├── droids/               # 15 specialist AI agents
│   ├── droidz-orchestrator.md
│   ├── droidz-codegen.md
│   ├── droidz-test.md
│   └── ... (15 total)
│
├── skills/               # 61 auto-activated skills
│   ├── graphql-api-design/SKILL.md
│   ├── react/SKILL.md
│   ├── typescript/SKILL.md
│   └── ... (61 total)
│
├── commands/             # 4 slash commands
│   ├── droidz-init.md
│   ├── droidz-build.md
│   ├── auto-parallel.md
│   └── gh-helper.md
│
├── orchestrator/         # Parallel execution engine
│   ├── worktree-setup.ts
│   ├── task-coordinator.ts
│   ├── types.ts
│   ├── config.json
│   └── tsconfig.json
│
├── scripts/              # Helper scripts
│   └── orchestrator.sh
│
├── hooks/                # Git and automation hooks
│   ├── monitor-context.sh
│   └── ...
│
├── memory/               # Persistent memory templates
│   ├── org/README.md
│   └── user/README.md
│
├── product/              # Product vision docs
│   ├── vision.md
│   ├── roadmap.md
│   └── use-cases.md
│
├── specs/                # Spec templates
│   └── templates/
│
├── standards/            # Code standards templates
│   └── templates/
│
└── settings.json         # Framework configuration
```

**Purpose:** These files define HOW Droidz works. They're the framework itself.

**Committed to Git:** ✅ Yes - This is what users download when they run `install.sh`

---

## 👤 User Project (After Installation)

When users install Droidz in their project, they get:

### User's Project Structure

```
my-project/
├── .factory/             # Framework files (from installer)
├── .droidz/              # User's generated content ⭐ NEW
│   ├── specs/           # Generated specifications
│   │   ├── 001-auth.md
│   │   └── 002-payment.md
│   └── architecture.md  # Project architecture (generated)
│
├── config.yml            # User's config with API keys ⭐ PERSONAL
├── node_modules/         # Dependencies (from npm install)
└── ... (their existing project files)
```

### User-Specific Files

| File/Folder | Purpose | Created By | Committed to Git? |
|-------------|---------|-----------|-------------------|
| **.droidz/** | User's generated specs and docs | `/droidz-build` command | ❌ No (personal) |
| **config.yml** | User's config with API keys | User copies from config.example.yml | ❌ No (contains secrets) |
| **node_modules/** | JavaScript dependencies | npm/bun install | ❌ No (too large) |
| **.factory/memory/user/** | User's personal notes | Various commands | ❌ No (personal) |
| **.factory/memory/org/** | Team decisions | `/save-decision` | ⚠️ Optional (team can share) |

---

## 🤔 Why Node Modules?

**Q: What is `node_modules/` used for?**

**A:** The Droidz orchestrator (`.factory/orchestrator/`) is written in TypeScript. It needs:

- **`yaml`** - Parse config.yml
- **`@types/node`** - TypeScript type definitions
- **`eslint`**, **`typescript-eslint`** - Code linting (optional)

**Size:** ~100 packages (~50MB)  
**Gitignored:** Yes (too large to commit)  
**Auto-installed:** Yes (installer runs `npm install` or `bun install`)

---

## 🔑 Config Files Explained

### `config.example.yml` (Template)

**Location:** Root of repository  
**Purpose:** Shows users what config options are available  
**Committed:** ✅ Yes - Safe to share (no secrets)

**Example:**
```yaml
linear:
  project_name: ""  # Users fill this in

parallel:
  enabled: true
  max_concurrent_tasks: 5
```

### `config.yml` (User's Actual Config)

**Location:** Root of USER's project (not in framework repo)  
**Purpose:** User's personal config with API keys  
**Committed:** ❌ No - Contains secrets!  
**How to create:** `cp config.example.yml config.yml`

---

## 📊 Why This Structure?

### Before Cleanup (Confusing)
```
Droidz/                    # Framework repo
├── .factory/              # ✅ Framework code
├── .droidz/               # ❌ Example user content (confusing!)
├── .claude/               # ❌ Legacy compatibility (outdated)
├── config.yml             # ❌ Dev's personal config (shouldn't be here)
└── config.example.yml     # ✅ Template
```

**Problem:** Mixed framework files with developer's personal files.

### After Cleanup (Clear)
```
Droidz/                    # Framework repo
├── .factory/              # ✅ Framework code ONLY
├── config.example.yml     # ✅ Template for users
└── install.sh             # ✅ Creates user folders during install
```

**Result:** 
- ✅ Framework repo contains ONLY framework code
- ✅ Users get `.droidz/` and `config.yml` when they install
- ✅ No confusion about what's framework vs user content

---

## 🎯 Summary

### Framework Repository (GitHub)
**Contains:** Only the framework code users need to download  
**Purpose:** Distribute Droidz framework via `install.sh`

### User's Project (After Installation)
**Contains:** Framework + user's generated specs + personal config  
**Purpose:** Actual development workspace with Droidz installed

### Key Principle
**Framework code goes in git, user content stays local.**

---

## 🚀 For Contributors

If you're contributing to Droidz:

1. **Don't commit:**
   - Your `.droidz/` folder
   - Your `config.yml`
   - Your `node_modules/`
   - Your `.factory/memory/user/`

2. **Do commit:**
   - Changes to `.factory/droids/`, `.factory/skills/`, `.factory/commands/`
   - Updates to `README.md`, `CHANGELOG.md`
   - New features in `.factory/orchestrator/`
   - Changes to `config.example.yml` (template only!)

3. **Testing locally:**
   - You WILL have `.droidz/`, `config.yml`, etc. locally
   - That's fine! They're gitignored
   - Just don't commit them

---

**Questions?** Open an issue: https://github.com/korallis/Droidz/issues
