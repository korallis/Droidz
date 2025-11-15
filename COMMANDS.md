# Droidz Commands Reference

**Current Version:** v0.2.0  
**Last Updated:** 2025-11-15

---

## 🎯 All Available Commands

Droidz has **3 simple commands**. Here they are:

### 1. `/droidz-build` - AI-Powered Spec Generator 🆕

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

### 2. `/auto-parallel` - Parallel Task Execution

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

### 3. `/gh-helper` - GitHub CLI Helpers

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

| Feature | /droidz-build | /auto-parallel | /gh-helper |
|---------|---------------|----------------|------------|
| **Purpose** | Generate specs | Execute tasks | GitHub ops |
| **When to use** | Planning features | Building code | PR management |
| **Output** | Specification file | Working code | PR status |
| **Time** | 1-5 minutes | 1-4 hours | Instant |
| **Parallelization** | N/A | Yes (3-5x faster) | N/A |

---

## 🎯 Common Workflows

### Workflow 1: Generate Spec → Execute
```
1. /droidz-build "add authentication"
2. Answer clarifying questions
3. Review generated spec
4. Choose "Execute in parallel"
```

### Workflow 2: Direct Execution
```
1. /auto-parallel "build REST API"
2. Monitor progress in conversation
```

### Workflow 3: PR Management
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

- `/droidz-init` - Smart project initialization
- `/droidz-status` - Resume conversations with state tracking

---

## 🤔 Which Command Should I Use?

**If you want to:**
- **Plan a feature carefully** → `/droidz-build`
- **Build something quickly** → `/auto-parallel`
- **Check a GitHub PR** → `/gh-helper`

**Pro tip:** For complex features, use `/droidz-build` first to generate a comprehensive spec, then execute it in parallel for 3-5x speedup!

---

## 📚 More Information

- **Full Documentation:** [README.md](README.md)
- **Example Specs:** `.droidz/specs/000-example-contact-form.md`
- **CHANGELOG:** [CHANGELOG.md](CHANGELOG.md) (v0.2.0 section)
- **Skills Guide:** [SKILLS.md](SKILLS.md)

---

**Current Version:** v0.2.0 | **Commands:** 3 | **Last Updated:** 2025-11-15
