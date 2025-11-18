# Droidz Commands Reference

**Current Version:** v2.4.0-droid  
**Last Updated:** 2025-11-18

---

## 🎯 All Available Commands

Droidz has **4 simple commands**. Here they are:

### 1. `/droidz-init` - Smart Onboarding 🆕

**Purpose:** Verify installation, analyze project, generate architecture docs

**Usage:**
```
/droidz-init
```

**Optional arguments:**
```
/droidz-init frontend    # Focus on frontend analysis
/droidz-init backend     # Focus on backend analysis
/droidz-init fullstack   # Analyze both
```

**What it does:**
- ✅ Verifies Droidz installation (all commands & droids)
- 🔍 Detects project type (greenfield vs brownfield)
- 📊 Analyzes tech stack (framework, database, UI library)
- 📁 Maps codebase architecture
- 📄 Generates `.droidz/architecture.md` documentation
- 💾 Creates `.droidz/project.json` metadata
- 🎯 Provides personalized next steps

**When to use:**
- First time using Droidz in a project
- Want to verify installation
- Need architecture documentation
- Onboarding new team members

**Output:**
- `.droidz/architecture.md` - Complete project analysis
- `.droidz/project.json` - Structured metadata
- Recommendations for next steps

**Example output:**
```
✅ Installation verified - all 7 droids present
📊 Project: Brownfield (Existing Next.js 14 app)
📁 156 TypeScript files, 47 dependencies
📄 Generated: .droidz/architecture.md
🎯 Next: /droidz-build "add user authentication"
```

---

### 2. `/droidz-build` - AI-Powered Spec Generator

**Purpose:** Transform vague ideas into production-ready specifications

**Usage:**
```
/droidz-build "feature description"
```

**Examples:**
```
/droidz-build "add user authentication"
/droidz-build "add dark mode toggle"
/droidz-build "build blog with comments and search"
```

**What it does:**
- Asks clarifying questions for vague requests
- Researches best practices (exa-code, ref MCP)
- Generates comprehensive XML-structured specs with:
  - Task decomposition
  - Security requirements (OWASP, GDPR)
  - Edge cases & testing strategies
  - Ready-to-execute task prompts

**Benefits:**
- 80% less time writing specs
- 70% fewer forgotten requirements
- 3-5x faster via parallel execution
- Zero missing security requirements

**Output:**
- Saves to `.droidz/specs/NNN-feature-name.md`
- Offers execution options (parallel, sequential, review)

---

### 3. `/auto-parallel` - Parallel Task Execution

**Purpose:** Execute tasks in parallel with automatic progress tracking

**Usage:**
```
/auto-parallel "task description"
```

**Examples:**
```
/auto-parallel "build REST API for todos"
/auto-parallel "add payment integration"
/auto-parallel "create admin dashboard"
```

**What it does:**
- Analyzes complexity and breaks into subtasks
- Identifies what can run in parallel
- Spawns specialist droids for each task
- Reports progress every 60 seconds (via TodoWrite)
- Synthesizes results when complete

**Progress Tracking:**
Progress appears directly in conversation:
```
TODO LIST UPDATED
✅ Database schema created (3 files)
⏳ API endpoints (implementing login...)
⏳ Frontend UI (building forms...)
```

---

### 4. `/gh-helper` - GitHub CLI Helpers

**Purpose:** GitHub operations with correct JSON field names

**Usage:**
```
/gh-helper <command> [args]
```

**Available commands:**
- `pr-checks <pr-number>` - Show PR checks
- `pr-status <pr-number>` - Comprehensive PR status
- `pr-list` - List all pull requests

**Examples:**
```
/gh-helper pr-status 10
/gh-helper pr-checks 10
/gh-helper pr-list
```

**What it does:**
- Uses correct GitHub CLI JSON fields (`bucket` not `status`)
- Shows PR check status
- Displays comprehensive PR information
- Lists pull requests

---

## 📋 Command Comparison

| Feature | /droidz-init | /droidz-build | /auto-parallel | /gh-helper |
|---------|--------------|---------------|----------------|------------|
| **Purpose** | Onboard & analyze | Generate specs | Execute tasks | GitHub ops |
| **When to use** | First time setup | Planning features | Building code | PR management |
| **Output** | Architecture docs | Spec file | Working code | PR status |
| **Time** | 1-2 minutes | 1-5 minutes | 1-4 hours | Instant |
| **Parallelization** | N/A | N/A | Yes (3-5x faster) | N/A |

---

## 🎯 Common Workflows

### Workflow 1: First Time Setup → Build
```
1. /droidz-init                      # Verify & analyze
2. Review .droidz/architecture.md    # Understand project
3. /droidz-build "add authentication" # Generate spec
4. Choose "Execute in parallel"       # Build it
```

### Workflow 2: Generate Spec → Execute
```
1. /droidz-build "add authentication"
2. Answer clarifying questions
3. Review generated spec
4. Choose "Execute in parallel"
```

### Workflow 3: Direct Execution
```
1. /auto-parallel "build REST API"
2. Monitor progress in conversation
```

### Workflow 4: PR Management
```
1. Create PR via git/GitHub
2. /gh-helper pr-status <number>
3. Check status of checks
```

---

## ❌ Deprecated Commands

These commands no longer exist (removed in v0.1.3):

- `/status` - Was for old tmux/worktree system
- `/watch` - Was for old tmux/worktree system
- `/parallel` - Replaced by `/auto-parallel`
- `/attach` - Was for old system
- `/summary` - Was for old system
- `/parallel-watch` - Was for old system

**Why removed:** Old system used git worktrees + tmux which didn't work with Factory.ai Task tool. Current system uses native Task tool with progress appearing directly in conversation.

---

## 🆕 Planned Commands (v0.3.0)

These commands are planned but not yet implemented:

- `/droidz-status` - Resume conversations with state tracking
- Spec execution tracking in `.droidz/tasks/`

---

## 🤔 Which Command Should I Use?

**If you want to:**
- **Get started / verify setup** → `/droidz-init`
- **Understand your project** → `/droidz-init`
- **Plan a feature carefully** → `/droidz-build`
- **Build something quickly** → `/auto-parallel`
- **Check a GitHub PR** → `/gh-helper`

**Pro tip:** Run `/droidz-init` first to verify everything, then use `/droidz-build` to plan features, and execute them in parallel for 3-5x speedup!

---

## 📚 More Information

- **Full Documentation:** [README.md](README.md)
- **Example Specs:** `.droidz/specs/000-example-contact-form.md`
- **CHANGELOG:** [CHANGELOG.md](CHANGELOG.md) (v0.2.0 section)
- **Skills Guide:** [SKILLS.md](SKILLS.md)

---

**Current Version:** v2.4.0-droid | **Commands:** 4 | **Last Updated:** 2025-11-18
