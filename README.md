# Droidz 🤖

**Spec-driven development with parallel execution for Droid CLI**

Droidz transforms your development workflow by implementing agent-os principles inside Droid CLI. Plan with research (Exa + Ref), write detailed specs, then execute tasks in parallel with specialized droids.

```
Planning → Specification → Parallel Implementation → Verification
(Research-driven with Exa/Ref) → (Multiple droids, isolated workspaces)
```

---

## Why Droidz?

Traditional AI coding: "Build feature X" → unpredictable results, no plan, no parallelization

**Droidz workflow:**
1. **Research first** - Use Exa to find similar products, Ref for documentation
2. **Plan thoroughly** - Create mission, roadmap, tech stack (research-backed)
3. **Spec before code** - Detailed specifications with task breakdowns
4. **Parallel execution** - Multiple droids work simultaneously in isolated worktrees
5. **Verify everything** - Tests, standards, documentation checks

**Result:** Predictable, high-quality features with proper planning and parallel efficiency.

---

## Features

✨ **Research-Driven Planning**
- Uses Exa to research similar products and best practices
- Uses Ref to find official documentation
- Evidence-based technical decisions

🎯 **Spec-Driven Development**
- Always plans before implementing
- Detailed specifications with clear requirements
- Parallelizable task breakdowns

⚡ **Parallel Execution**
- Multiple droids work simultaneously
- Git worktrees for isolation
- Smart dependency management

🛡️ **Built-In Standards**
- Coding conventions
- Architecture patterns
- Security requirements
- Customizable for your project

🔍 **Verification**
- Automated testing
- Standards compliance checks
- Functional testing with screenshots
- Comprehensive reports

---

## Installation

One command installs everything:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

Or clone and install:

```bash
git clone https://github.com/korallis/Droidz.git
cd Droidz
bash scripts/install.sh ../my-project  # or just "bash scripts/install.sh" for current dir
```

This installs:
- `workflows/` - Planning, spec, and implementation workflows
- `standards/` - Coding, architecture, and security standards
- `.claude/agents/` - 5 specialized droids
- `config.yml` - Configuration
- `droidz/` - Working directory for specs and products

**Quick verification:**
```bash
ls .claude/agents/  # Should see 5 droids
ls workflows/       # Should see planning, specification, implementation
```

📖 **[Complete Installation Guide](INSTALL.md)** - Troubleshooting, manual install, uninstall, upgrade

---

## Prerequisites

- **Droid CLI** installed and working (`droid --help`)
- **Git** repository initialized
- **Optional:** Exa and Ref tools enabled (for research features)

---

## Quick Start

### 1. Install Droidz

```bash
# In your project directory
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

Verify installation:
```bash
ls .claude/agents/  # Should see: droidz-orchestrator.md, droidz-planner.md, etc.
```

### 2. Open Droid CLI

```bash
droid
```

### 3. Start with the Orchestrator

```
@droidz-orchestrator I want to build [your project idea]
```

Example:
```
@droidz-orchestrator I want to build a recipe sharing app with Next.js 14 and Supabase
```

The orchestrator will guide you through:

**NEW Product Flow:**
```
Planning Phase:
  → Research similar products with Exa
  → Create mission, roadmap, tech stack
  → All choices backed by research

Specification Phase:
  → Pick a feature from roadmap
  → Research docs with Ref
  → Create detailed spec
  → Break into parallel tasks

Implementation Phase:
  → Foundation work (sequential)
  → Parallel droids execute task groups
  → Integration work (sequential)
  → All in isolated worktrees

Verification Phase:
  → Run all tests
  → Check standards compliance
  → Functional testing
  → Update roadmap
```

**EXISTING Roadmap Flow:**
```
Skip to Specification Phase
  → Read your existing roadmap
  → Pick feature to implement
  → Spec → Parallel Implementation → Verify
```

---

## The Droids

### @droidz-planner
**Product planning specialist**
- Gathers requirements from you
- Researches with Exa (similar products, best practices)
- Creates mission, roadmap, tech stack
- Research-backed decisions

**Output:** `droidz/product/`
- `mission.md` - Vision and goals
- `roadmap.md` - Ordered features
- `tech-stack.md` - Complete stack with rationale

### @droidz-spec-writer
**Specification specialist**
- Initializes feature specs
- Researches docs with Ref
- Finds code examples with Exa
- Creates detailed specifications
- Breaks work into parallelizable tasks

**Output:** `droidz/specs/[feature]/`
- `spec.md` - Detailed specification
- `tasks.md` - Parallelizable task breakdown
- `planning/requirements.md` - Requirements

### @droidz-implementer
**Parallel worker**
- Works on ONE task group
- Isolated in git worktree
- Uses Ref for just-in-time docs
- Follows project standards
- Self-tests and commits

**Used by:** Orchestrator spawns multiple instances in parallel

### @droidz-verifier
**Quality assurance specialist**
- Checks all requirements met
- Runs tests (unit, integration, E2E)
- Verifies standards compliance
- Functional testing
- Creates comprehensive report

**Output:** `droidz/specs/[feature]/verification/`
- `report.md` - Verification results
- `screenshots/` - UI testing screenshots

### @droidz-orchestrator
**Workflow coordinator**
- Orchestrates complete workflow
- Delegates to specialized droids
- Manages parallel execution
- Coordinates integration
- Reports progress

**Use this** as your main entry point.

---

## Parallel Execution

### How It Works

```
Phase 1: Foundation (Sequential)
├─ Database schema
├─ Type definitions
└─ Shared utilities
     ↓
Phase 2: Parallel Implementation
├─ Worker 1: Component A ─┐
├─ Worker 2: Component B ─┼─→ All in parallel
├─ Worker 3: Service X  ──┤   (isolated worktrees)
└─ Worker 4: Service Y  ──┘
     ↓
Phase 3: Integration (Sequential)
├─ Merge all branches
├─ Wire components together
└─ Integration tests
```

### Configuration

Edit `config.yml`:

```yaml
parallel:
  enabled: true
  max_concurrent_tasks: 5
  workspace_mode: worktree  # worktree | clone | branch
```

**Workspace Modes:**
- `worktree` - Git worktrees (recommended, fastest)
- `clone` - Lightweight clones (if worktrees unavailable)
- `branch` - Shadow copies with patch-apply (fallback)

---

## Standards

Customize these files for your project:

### `standards/coding-conventions.md`
- File naming
- Code structure
- Naming conventions
- Comments
- Error handling
- Testing

### `standards/architecture.md`
- Project structure
- Layer architecture
- Component patterns
- State management
- API layer
- Performance

### `standards/security.md`
- Secrets management
- Input validation
- Authentication
- Authorization
- HTTPS
- CORS
- Rate limiting

**Droids automatically follow these standards** during implementation.

---

## Workflows

Located in `workflows/`, these define how each droid operates:

### Planning Workflows
- `planning/gather-product-info.md`
- `planning/create-product-mission.md` (uses Exa)
- `planning/create-product-roadmap.md` (uses Exa Code)
- `planning/create-product-tech-stack.md` (uses Exa + Ref)

### Specification Workflows
- `specification/initialize-spec.md`
- `specification/write-spec.md` (uses Ref + Exa)
- `specification/create-tasks.md`

### Implementation Workflows
- `implementation/implement-parallel.md`
- `implementation/verify-implementation.md`

---

## Directory Structure

After using Droidz:

```
your-project/
├── droidz/
│   ├── product/              # Product planning
│   │   ├── mission.md
│   │   ├── roadmap.md
│   │   └── tech-stack.md
│   └── specs/                # Feature specifications
│       └── user-auth/
│           ├── spec.md
│           ├── tasks.md
│           ├── planning/
│           │   └── requirements.md
│           └── verification/
│               ├── report.md
│               └── screenshots/
├── .droidz/
│   ├── worktrees/            # Parallel work isolation
│   └── logs/                 # Worker logs
├── workflows/                # Workflow definitions
├── standards/                # Your project standards
├── .claude/agents/           # Custom droids
└── config.yml                # Configuration
```

---

## Example Session

```
You: @droidz-orchestrator I want to build a task management SaaS app

Orchestrator: Let's plan your product! I'll start by researching...

[Uses Exa to research task management products]
[Creates mission, roadmap, tech stack with research citations]

Orchestrator: Your roadmap is ready with 8 features. Let's implement: "User Authentication"

[Delegates to @droidz-spec-writer]
[Spec writer researches auth docs with Ref, creates detailed spec]

Orchestrator: Spec ready. Breaking into 5 parallel task groups...
[Creates 5 git worktrees]
[Spawns 5 @droidz-implementer droids in parallel]

Worker 1: Implementing Login Component... ✅
Worker 2: Implementing Auth Service... ✅
Worker 3: Implementing JWT Handler... ✅
Worker 4: Implementing User Profile... ✅
Worker 5: Implementing Password Reset... ✅

Orchestrator: Merging parallel work... Running integration...

[Delegates to @droidz-verifier]

Verifier: All tests passing ✅
Verifier: Standards compliant ✅
Verifier: Functional tests passed ✅

Orchestrator: Feature "User Authentication" complete! Next feature?
```

---

## Advanced Usage

### Run Individual Droids

```
# Just planning
@droidz-planner Create a product plan for [idea]

# Just specification
@droidz-spec-writer Create spec for "User Authentication"

# Run verification
@droidz-verifier Verify droidz/specs/user-auth/
```

### Customize Standards

Edit `standards/*.md` to match your team's conventions. Droids will automatically follow them.

### Configure Parallel Execution

Edit `config.yml`:
```yaml
parallel:
  max_concurrent_tasks: 10  # More workers
  workspace_mode: clone     # Use clones instead of worktrees
```

### Enable/Disable Research

```yaml
use_exa_research: true   # Research with Exa
use_ref_docs: true       # Documentation with Ref
```

---

## Troubleshooting

**"Installation says success but folders are empty"**
- GitHub's CDN may be cached. Try using commit SHA:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/ba5c9c7/scripts/install.sh | bash
  ```
- Or clone the repo directly:
  ```bash
  git clone https://github.com/korallis/Droidz.git
  cd Droidz && bash scripts/install.sh
  ```

**"Droids not showing up"**
- Check `.claude/agents/` exists and has `droidz-*.md` files
- Run: `ls .claude/agents/` - should see 5 files
- Restart Droid CLI

**"Parallel execution not working"**
- Ensure git repo initialized: `git status`
- Check worktrees: `git worktree list`
- Verify `config.yml` has `parallel.enabled: true`

**"Standards not being followed"**
- Check `standards/*.md` files exist: `ls standards/`
- Verify standards are clear and specific
- Mention standards explicitly in prompts

**"Exa/Ref research failing"**
- Ensure tools are available in Droid CLI
- Check `config.yml` has research enabled
- Tools are optional; droids work without them

**Need help?**
- [Open an issue](https://github.com/korallis/Droidz/issues)
- Check the [workflows/](workflows/) to understand how each phase works
- Review [standards/](standards/) to see what droids follow

---

## Philosophy

Droidz implements **agent-os principles** for Droid CLI:

1. **Spec-Driven** - Always plan before implementing
2. **Research-Backed** - Use Exa and Ref for evidence-based decisions
3. **Parallelizable** - Break work into independent chunks
4. **Standards-Enforced** - Follow project conventions automatically
5. **Verifiable** - Every feature gets tested and validated

Based on [agent-os by buildermethods](https://github.com/buildermethods/agent-os) - adapted for Droid CLI with parallel execution and integrated research tools.

---

## Contributing

PRs welcome! Key areas:
- New workflows
- Better parallelization strategies
- More standards templates
- Framework-specific patterns

---

## License

MIT

---

## Resources

- **Droid CLI**: https://factory.ai/product/cli
- **Agent OS**: https://github.com/buildermethods/agent-os
- **Exa**: Web search and code context
- **Ref**: Documentation search

---

Built for developers who want structured, research-driven, parallel AI development.
