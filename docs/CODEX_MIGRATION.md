# Migrating from Claude Code to Codex CLI

Guide for teams transitioning from Claude Code (Droidz v3.x) to Codex CLI (Droidz v4.0).

---

## 📖 Table of Contents

- [Should You Migrate?](#should-you-migrate)
- [Key Differences](#key-differences)
- [Command Mapping](#command-mapping)
- [Agent to Prompt Conversion](#agent-to-prompt-conversion)
- [Skills Migration](#skills-migration)
- [Migration Strategy](#migration-strategy)
- [Conversion Tools](#conversion-tools)
- [Troubleshooting](#troubleshooting)

---

## Should You Migrate?

### ✅ Migrate to Codex CLI If:

- You prefer working in the terminal over IDE
- Your team already uses OpenAI tools
- You want official OpenAI support and updates
- You need cross-IDE compatibility
- You prefer sequential workflows over parallel execution

### ✅ Stay with Claude Code If:

- You love IDE integration and inline suggestions
- You heavily rely on parallel agent execution (3-5x speedup)
- You're deep into Anthropic's ecosystem
- You prefer Factory.ai's specialized tools
- Your workflow is already optimized with v3.x

### ✅ Use Both!

The best approach: **Use both platforms with unified specs**

Droidz v4.0 supports both with shared `.droidz/specs/`:
- **Claude Code**: Use for IDE integration and parallel execution
- **Codex CLI**: Use for terminal workflows and OpenAI features
- **Shared specs**: Both platforms read/write to `.droidz/specs/`

---

## Key Differences

### Architecture

| Feature | Claude Code (v3.x) | Codex CLI (v4.0) |
|---------|-------------------|------------------|
| **Execution Model** | Parallel agents (spawn multiple) | Sequential prompts |
| **Location** | IDE extension | Terminal CLI |
| **Commands** | Slash commands (`/build`) | Prompt calls (`/prompts:build`) |
| **Agents** | 15 specialist agents | 6 core prompts |
| **Shell Execution** | Direct (`!`git status``) | Descriptive instructions |
| **Specs Location** | `.droidz/specs/` | `.droidz/specs/` ✅ Same |
| **Configuration** | `CLAUDE.md` | `AGENTS.md` |

---

### Execution Model: Parallel vs Sequential

**Claude Code (Parallel)**
```
User: Build auth system

orchestrator spawns 3 agents in parallel:
  ├─ codegen: Backend API (20 min) ──┐
  ├─ codegen: Frontend UI (25 min) ──┼─> Results synthesis (5 min)
  └─ test: Write tests (15 min) ─────┘

Total: ~30 minutes (3x speedup)
```

**Codex CLI (Sequential)**
```
User: Build auth system

orchestrator works sequentially:
  1. codegen: Backend API (20 min)
  2. codegen: Frontend UI (25 min)  
  3. test: Write tests (15 min)

Total: ~60 minutes (+ validation between steps)
```

**Implication**: For complex multi-domain features, Claude Code is faster. For focused single-domain work, Codex CLI is equivalent.

---

### Command Syntax

**Claude Code:**
```bash
/build FEATURE="user auth" COMPLEXITY=medium
/validate
/parallel SPEC=001-auth-system
```

**Codex CLI:**
```bash
codex /prompts:build FEATURE="user auth" COMPLEXITY=medium
codex /prompts:validate
codex /prompts:orchestrator FEATURE="implement spec 001"
```

**Key difference**: `codex` prefix and `/prompts:` namespace

---

### Shell Execution

**Claude Code (Direct Execution):**
```markdown
Run the following commands:
!`npm test`
!`git status`
!`npx eslint .`
```

**Codex CLI (Descriptive Instructions):**
```markdown
Run validation:
1. Execute: npm test
2. Check git status for uncommitted changes
3. Run linter: npx eslint .
```

**Implication**: Codex CLI prompts guide rather than execute directly

---

## Command Mapping

### Core Commands

| Claude Code | Codex CLI | Notes |
|-------------|-----------|-------|
| `/init` | `codex /prompts:init` | Same functionality |
| `/build` | `codex /prompts:build` | Same arguments |
| `/validate` | `codex /prompts:validate` | 5 phases both |
| `/parallel` | `codex /prompts:orchestrator` | Sequential in Codex |
| N/A | `codex /prompts:codegen` | New in v4.0 |
| N/A | `codex /prompts:test-specialist` | New in v4.0 |

### Agent Mapping

| Claude Code Agent | Codex CLI Prompt | Usage |
|-------------------|------------------|-------|
| `orchestrator` | `/prompts:orchestrator` | Complex features |
| `codegen` | `/prompts:codegen` | Implementation |
| `test` | `/prompts:test-specialist` | Testing |
| `refactor` | `/prompts:codegen` | Refactoring (use codegen with FEATURE="refactor X") |
| `infra` | `/prompts:codegen` | Infrastructure (use codegen with FILES=...) |
| `ui-designer` | `/prompts:codegen` | UI work (use codegen with FEATURE="UI...") |
| `integration` | `/prompts:codegen` | API integration |
| `generalist` | `/prompts:codegen` | General tasks |

**Note**: Codex CLI has fewer prompts but they're more versatile.

---

### Workflow Comparison

#### Simple Feature

**Claude Code (v3.x):**
```bash
/build FEATURE="dark mode toggle" COMPLEXITY=low
# Review spec
# Implement directly (no agent needed for simple features)
/validate
git commit -m "feat: dark mode"
```

**Codex CLI (v4.0):**
```bash
codex /prompts:codegen FEATURE="dark mode toggle"
codex /prompts:validate
git commit -m "feat: dark mode"
```

**Time**: Same (~15 minutes)

---

#### Medium Feature (Frontend + Backend)

**Claude Code (v3.x):**
```bash
/build FEATURE="user profile page" COMPLEXITY=medium
/parallel SPEC=001-user-profile
# orchestrator spawns codegen (frontend) + codegen (backend) in parallel
# Results: ~30 minutes total
```

**Codex CLI (v4.0):**
```bash
codex /prompts:build FEATURE="user profile page" COMPLEXITY=medium
codex /prompts:orchestrator FEATURE="implement spec 001"
# orchestrator works sequentially: backend → frontend → tests
# Results: ~60 minutes total
```

**Time**: Claude Code 2x faster due to parallelism

---

#### Complex Feature (Full System)

**Claude Code (v3.x):**
```bash
/build FEATURE="auth system" COMPLEXITY=high
/parallel SPEC=001-auth
# orchestrator spawns:
#   - codegen: JWT utilities
#   - codegen: Backend API
#   - codegen: Frontend UI
#   - test: Test suite
# All work in parallel where dependencies allow
# Results: ~2-3 hours
```

**Codex CLI (v4.0):**
```bash
codex /prompts:build FEATURE="auth system" COMPLEXITY=high
codex /prompts:orchestrator FEATURE="implement spec 001"
# orchestrator works in phases:
#   Phase 1: Foundation (JWT utilities)
#   Phase 2: Backend API (depends on Phase 1)
#   Phase 3: Frontend UI (depends on Phase 2)
#   Phase 4: Testing (depends on Phase 2-3)
# Results: ~5-6 hours
```

**Time**: Claude Code 2-3x faster for complex multi-domain features

---

## Agent to Prompt Conversion

### Orchestrator

**Claude Code (`.claude/agents/orchestrator.md`):**
```markdown
---
model: inherit
tools: []
---

# Orchestrator Agent

You coordinate complex features by spawning specialist agents in parallel.

## Process

1. Analyze complexity
2. Identify parallelizable tasks
3. Spawn agents with Task tool:
   - `Task(subagent_type="codegen", ...)`
   - `Task(subagent_type="test", ...)`
4. Synthesize results
```

**Codex CLI (`~/.codex/prompts/orchestrator.md`):**
```markdown
---
description: Orchestrates complex multi-step features with sequential execution
argument-hint: FEATURE=<description>
---

# Orchestrator - Complex Feature Workflow

## Process

1. Analyze complexity
2. Break into sequential phases with dependencies
3. Execute phases in order (no parallel spawning)
4. Validate between phases
5. Synthesize results
```

**Key Changes:**
- ❌ Removed: `model`, `tools` (not supported in Codex)
- ✅ Added: `description`, `argument-hint` (Codex YAML format)
- ❌ Removed: `Task` tool calls (no parallel spawning)
- ✅ Changed: Parallel → Sequential execution model

---

### Codegen

**Claude Code (`.claude/agents/codegen.md`):**
```markdown
---
model: inherit
---

# Code Generation Agent

Implement features with comprehensive tests.

## Workflow

1. Use Read tool to understand context
2. Use Write tool to create files
3. Use Bash tool to run tests
   !`npm test`
4. Use Edit tool to fix issues
```

**Codex CLI (`~/.codex/prompts/codegen.md`):**
```markdown
---
description: Code generation specialist - implements features with comprehensive tests
argument-hint: FEATURE=<description> [FILES=<paths>]
---

# Code Generation Specialist

## Workflow

1. Understand context (read existing code)
2. Plan implementation approach
3. Write production-ready code
4. Include comprehensive tests
5. Validate:
   - Run: npm test
   - Check: npx eslint .
   - Verify: npx tsc --noEmit
```

**Key Changes:**
- ❌ Removed: Tool calls (`Read`, `Write`, `Bash`)
- ✅ Changed: Tool usage → Descriptive instructions
- ❌ Removed: `!`cmd`` syntax
- ✅ Changed: Commands described in natural language

---

### Test Specialist

**Claude Code (`.claude/agents/test.md`):**
```markdown
---
model: inherit
---

# Test Specialist Agent

Write and fix tests.

!`npm test -- --coverage`

Analyze coverage, write missing tests.
```

**Codex CLI (`~/.codex/prompts/test-specialist.md`):**
```markdown
---
description: Testing specialist - writes comprehensive tests with TDD approach
argument-hint: ACTION=<write|fix|coverage> [TARGET=<file>]
---

# Testing Specialist

## Actions

### `ACTION=write`
1. Generate coverage report: npm test -- --coverage
2. Analyze gaps
3. Write missing tests
```

**Key Changes:**
- ✅ Added: Structured `ACTION` parameter
- ❌ Removed: Direct command execution
- ✅ Changed: Commands → Step-by-step instructions

---

## Skills Migration

Skills in Claude Code can be converted to instructions in Codex CLI's `AGENTS.md`.

### Claude Code Skills (`.claude/skills/`)

```
.claude/skills/
├── typescript.md
├── react.md
├── nextjs.md
└── testing.md
```

**Auto-activate** based on context.

### Codex CLI Approach

**Embed skills into `AGENTS.md`:**

```markdown
# AGENTS.md

## TypeScript Guidelines
- Use strict mode
- No `any` types (use `unknown` and narrow)
- Prefer `type` over `interface` for unions

## React Patterns
- Functional components only
- Use hooks (useState, useEffect, etc.)
- Keep components small and focused

## Testing
- Write tests alongside implementation (TDD)
- Use React Testing Library for components
- Aim for 80%+ coverage
```

**Why?**
- Codex CLI doesn't have auto-activating skills system
- `AGENTS.md` is always loaded, providing same guidance
- More explicit and customizable per project

---

## Migration Strategy

### Option 1: Dual Setup (Recommended)

Use both platforms with shared specs:

```
your-project/
├── .claude/              # Claude Code setup
│   ├── agents/
│   └── commands/
├── AGENTS.md             # Codex CLI config
├── .droidz/
│   └── specs/            # ✅ Shared between both!
│       ├── active/
│       └── archive/
└── ...
```

**Benefits:**
- Choose best tool for each task
- Specs work with both platforms
- No migration needed - gradual adoption

**Workflow:**
```bash
# Use Claude Code for complex parallel work
# In IDE: /parallel SPEC=001-auth-system

# Use Codex CLI for terminal-focused work
# In terminal: codex /prompts:validate
```

---

### Option 2: Full Migration

Migrate entirely to Codex CLI:

#### Step 1: Install Codex CLI
```bash
npm install -g @openai/codex
```

#### Step 2: Install Droidz for Codex
```bash
cd path/to/Droidz
python3 install.py
# Select "Codex CLI" platform
```

#### Step 3: Initialize Project
```bash
cd your-project/
codex /prompts:init
```

This creates `AGENTS.md` from detected tech stack.

#### Step 4: Migrate Skills
Copy skills content from `.claude/skills/*.md` to `AGENTS.md`:

```bash
# Extract key guidelines from skills
cat .claude/skills/typescript.md >> AGENTS.md
cat .claude/skills/react.md >> AGENTS.md
# Edit AGENTS.md to organize
```

#### Step 5: Test Workflows
```bash
# Test basic workflow
codex /prompts:codegen FEATURE="test migration"
codex /prompts:validate

# Test complex workflow
codex /prompts:build FEATURE="test feature" COMPLEXITY=medium
codex /prompts:orchestrator FEATURE="implement test feature"
```

#### Step 6: Update Team Docs
Update README.md, CONTRIBUTING.md with new commands:
```markdown
## Development

### With Codex CLI
```bash
codex /prompts:init          # Initialize project
codex /prompts:build         # Create spec
codex /prompts:validate      # Run validation
```
```

---

### Option 3: Hybrid Workflows

Use each platform for its strengths:

| Task | Best Platform | Why |
|------|---------------|-----|
| Complex multi-domain features | Claude Code | Parallel execution (3x faster) |
| Single-domain features | Either | Same speed |
| Quick validation | Codex CLI | Terminal-native |
| Exploratory coding | Claude Code | IDE integration |
| Spec creation | Either | Same functionality |
| Testing workflows | Codex CLI | Better test-specific prompts |

---

## Conversion Tools

Droidz v4.0 includes conversion utilities in the Python installer.

### Convert Agents to Prompts

```bash
cd path/to/Droidz

# Convert single agent
python3 -m installer.converters \
  --input .claude/agents/codegen.md \
  --output templates/codex/prompts/codegen.md

# Convert all agents (batch)
python3 -m installer.converters \
  --input-dir .claude/agents/ \
  --output-dir templates/codex/prompts/
```

**What it does:**
- Removes `model`, `tools` from frontmatter
- Converts `!`cmd`` to descriptive instructions
- Removes Tool calls (Read, Write, Bash)
- Adds Codex CLI frontmatter (description, argument-hint)

### Validate Codex Compatibility

```bash
# Validate single prompt
python3 -m installer.validators \
  --file templates/codex/prompts/codegen.md

# Validate all prompts
python3 -m installer.validators \
  --directory templates/codex/prompts/
```

**Output:**
```
✅ codegen.md: Compatible
⚠️ orchestrator.md: 2 warnings
  • Line 45: Task tool call detected (not supported in Codex)
  • Line 67: Bash tool call detected
❌ test-specialist.md: 1 error
  • Line 23: Direct shell execution (!`cmd`) detected
```

---

## Troubleshooting

### Parallel Execution Not Available

**Issue:** Missing the 3x speedup from parallel agents

**Solution:** Use Claude Code for complex parallel work, Codex CLI for sequential tasks:

```bash
# Complex multi-domain feature
# Use Claude Code: /parallel SPEC=001-auth

# Single-domain feature
# Use Codex CLI: codex /prompts:codegen FEATURE="login endpoint"
```

---

### Commands Not Found

**Issue:** `/build` doesn't work in Codex CLI

**Solution:** Use `/prompts:` namespace:

```bash
# ❌ Wrong
codex /build

# ✅ Correct
codex /prompts:build
```

---

### AGENTS.md vs CLAUDE.md

**Issue:** Both files exist, unclear which is used

**Answer:**
- `CLAUDE.md` - Used by Claude Code only
- `AGENTS.md` - Used by Codex CLI only
- Keep both if using dual setup
- They can coexist without conflicts

---

### Skills Not Working

**Issue:** Skills from `.claude/skills/` not being applied

**Solution:** Codex CLI doesn't auto-activate skills. Embed guidance in `AGENTS.md`:

```bash
# Extract skills content
cat .claude/skills/typescript.md >> AGENTS.md
cat .claude/skills/react.md >> AGENTS.md

# Edit AGENTS.md to organize into sections
code AGENTS.md
```

---

### Specs in Wrong Location

**Issue:** Specs created outside `.droidz/specs/`

**Solution:** Re-run init to create directory structure:

```bash
codex /prompts:init

# Or manually:
mkdir -p .droidz/specs/{active,archive,templates,examples}
```

---

## Performance Comparison

### Simple Feature (1-3 files)

| Platform | Time | Notes |
|----------|------|-------|
| Claude Code | ~15 min | Direct implementation |
| Codex CLI | ~15 min | Via /prompts:codegen |

**Winner:** Tie

---

### Medium Feature (4-10 files, single domain)

| Platform | Time | Notes |
|----------|------|-------|
| Claude Code | ~45 min | Sequential (no parallel benefit) |
| Codex CLI | ~45 min | Sequential orchestration |

**Winner:** Tie

---

### Complex Feature (10+ files, multi-domain)

| Platform | Time | Notes |
|----------|------|-------|
| Claude Code | ~2 hours | Parallel execution across domains |
| Codex CLI | ~5 hours | Sequential phases |

**Winner:** Claude Code (2.5x faster)

---

### Validation

| Platform | Time | Notes |
|----------|------|-------|
| Claude Code | ~3 min | Via /validate command |
| Codex CLI | ~3 min | Via /prompts:validate |

**Winner:** Tie

---

## Recommendation Matrix

| Your Situation | Recommendation |
|----------------|----------------|
| **New to Droidz** | Start with Codex CLI (simpler setup) |
| **Existing Claude Code user** | Keep Claude Code, add Codex CLI for terminal work |
| **Terminal-focused workflow** | Use Codex CLI |
| **IDE-focused workflow** | Use Claude Code |
| **Need maximum speed** | Use Claude Code for complex features |
| **Team uses OpenAI** | Use Codex CLI |
| **Team uses Anthropic** | Use Claude Code |
| **Want both** | Dual setup with shared `.droidz/specs/` ✅ |

---

## Next Steps

1. **Try Codex CLI** without removing Claude Code setup
2. **Initialize your project**: `codex /prompts:init`
3. **Run a simple feature**: `codex /prompts:codegen FEATURE="..."`
4. **Compare workflows** and choose what fits your team
5. **Update team docs** with chosen approach

Both platforms are excellent - choose based on your workflow preferences!
