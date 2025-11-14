# Droidz Quick Start Guide

> **Status**: Production Ready ✅
> **Validated**: 2025-11-12
> **All Tests**: 7/7 Passed

## Prerequisites

Ensure you have these installed:
```bash
brew install git jq tmux
```

## 5-Minute Quick Start

### 1. Initialize Droidz (First Time Only)
```bash
/droidz-init
```

This sets up:
- Memory system (5 JSON files)
- Directory structure
- Coordination infrastructure

### 2. Create a Specification
```bash
/create-spec feature my-feature
```

Available types:
- `feature` - New functionality
- `epic` - Multi-feature initiative
- `refactor` - Code improvement
- `integration` - External service integration

### 3. Validate Your Spec
```bash
/validate-spec .claude/specs/active/my-feature.md
```

Modes: `--quick`, `--standard` (default), `--strict`

### 4. Generate Task Breakdown
```bash
/spec-to-tasks .claude/specs/active/my-feature.md
```

Creates: `my-feature-tasks.json` with orchestration metadata

### 5. Execute in Parallel
```bash
/orchestrate file:my-feature-tasks.json
```

This will:
- Create isolated git worktrees (one per task)
- Spawn tmux sessions for monitoring
- Set up coordination tracking
- Execute tasks in parallel phases

### 6. Monitor Progress
```bash
/orchestrate list
```

View active orchestrations and their status.

## Common Workflows

### Simple Feature (No Parallelization Needed)
```bash
# Just describe what you want
"I need to add a search bar to the header"

# spec-shaper skill auto-activates
# Creates spec → validates → implements
```

### Complex Multi-Task Feature
```bash
# Describe complex requirement
"Build authentication system with OAuth, JWT, and user management"

# spec-shaper creates comprehensive spec
# auto-orchestrator detects complexity
# Recommends parallel execution plan
# /orchestrate executes with 1.5-2.5x speedup
```

### Existing Spec to Orchestration
```bash
/spec-to-tasks .claude/specs/active/auth-system.md
/orchestrate file:auth-system-tasks.json
```

### Linear Integration (Future)
```bash
/orchestrate linear:"team:ENG sprint:current"
```

## Understanding Parallelization

Droidz analyzes your tasks and creates an execution plan:

**Example**: 4 tasks, 6.5 hours sequential
- Phase 1 (Parallel): Tasks A + B → 2 hours
- Phase 2 (Sequential): Task C (depends on A) → 1 hour
- Phase 3 (Sequential): Task D (depends on A+B) → 2 hours
- **Total**: 3.6 hours instead of 6.5 hours (1.8x speedup)

## Specialist Agents

Droidz routes tasks to domain experts:

| Agent | Specialty | Use For |
|-------|-----------|---------|
| droidz-codegen | Feature implementation | New code, components, APIs |
| droidz-test | Testing & quality | Unit tests, integration tests |
| droidz-refactor | Code improvement | Performance, structure, cleanup |
| droidz-infra | CI/build/tooling | Pipelines, configs, automation |
| droidz-integration | External services | OAuth, APIs, webhooks |
| droidz-orchestrator | Coordination | Multi-task orchestration |
| droidz-generalist | General tasks | Fallback for simple tasks |

Agents auto-activate based on task requirements.

## Auto-Activating Skills

These skills trigger automatically based on context:

### spec-shaper
**Triggers**: Fuzzy requests, incomplete requirements
**Purpose**: Transform ideas into clear specifications
**Example**: "I want to build..." → Comprehensive spec

### auto-orchestrator
**Triggers**: Complex multi-task requests, 3+ distinct tasks
**Purpose**: Detect complexity and recommend parallelization
**Example**: Large feature → Parallel execution plan

### memory-manager
**Triggers**: Architectural decisions, pattern establishment
**Purpose**: Auto-persist decisions and patterns
**Example**: "Let's use PostgreSQL" → Saved to decisions.json

## Memory System

Droidz remembers across sessions:

### Organization Memory (`.claude/memory/org/`)
- **decisions.json** - Architectural choices
- **patterns.json** - Code patterns and conventions
- **tech-stack.json** - Technology configuration

### User Memory (`.claude/memory/user/`)
- **preferences.json** - Your settings
- **context.json** - Current session state

Query memory naturally:
```
"What did we decide about authentication?"
"Show me our error handling patterns"
"What's our current tech stack?"
```

## Monitoring Active Orchestrations

### View tmux sessions
```bash
tmux list-sessions | grep droidz
```

### Attach to a session
```bash
tmux attach -t droidz-TASK-KEY
```

### View coordination state
```bash
cat .runs/.coordination/orchestration-*.json
```

### View logs
```bash
tail -f .runs/.coordination/orchestration.log
```

## Cleanup

### Clean up specific orchestration
```bash
/orchestrate cleanup:SESSION_ID
```

This removes:
- Git worktrees
- Tmux sessions
- Archives coordination state

### Manual cleanup
```bash
# List all worktrees
git worktree list

# Remove a worktree
git worktree remove .runs/TASK-KEY

# Kill tmux sessions
tmux kill-session -t droidz-TASK-KEY
```

## Best Practices

### ✅ Do This
- Create clear, detailed specs before implementation
- Let auto-orchestrator recommend parallelization
- Use specialist agents for their expertise
- Review orchestration plan before executing
- Keep specs in `.claude/specs/active/`
- Archive completed specs to `.claude/specs/archive/`

### ❌ Avoid This
- Skipping spec creation for complex features
- Force-parallelizing dependent tasks
- Ignoring dependency warnings
- Running too many concurrent orchestrations
- Leaving worktrees around after completion

## Realistic Expectations

| Scenario | Sequential | With Droidz | Speedup |
|----------|------------|-------------|---------|
| Single task | 4 hours | 4 hours | 1x (no benefit) |
| Feature + tests | 7 hours | 5 hours | 1.4x |
| Full-stack feature | 12 hours | 6 hours | 2x |
| Sprint (10 tickets) | 80 hours | 30 hours | 2.7x |

**When Droidz Helps Most**:
- Multiple independent tasks
- Clear task boundaries
- Well-defined acceptance criteria
- Tasks that can be parallelized

**When Droidz Doesn't Help**:
- Single linear task
- Highly dependent sequential work
- Exploratory/research work
- Rapid prototyping

## Troubleshooting

### "tmux: command not found"
```bash
brew install tmux
```

### "jq: command not found"
```bash
brew install jq
```

### Orchestration won't start
```bash
# Check git status (must be clean or on feature branch)
git status

# Verify dependencies
/droidz-init --status
```

### Memory not persisting
Check file permissions:
```bash
ls -la .claude/memory/org/
ls -la .claude/memory/user/
```

### Worktrees not cleaning up
Manual cleanup:
```bash
git worktree prune
```

## File Locations

```
.claude/
├── agents/              # 7 specialist agent configs
├── commands/            # 5 slash commands
├── skills/              # 3 auto-activating skills
├── memory/
│   ├── org/            # Organization memory (decisions, patterns, tech)
│   └── user/           # User memory (preferences, context)
├── product/            # Vision, roadmap, use cases
├── specs/
│   ├── active/         # Current specifications
│   ├── archive/        # Completed specifications
│   ├── examples/       # Example specifications
│   └── templates/      # Spec templates
└── scripts/
    └── orchestrator.sh # Main orchestration engine

.runs/
├── .coordination/      # Orchestration state and logs
└── [TASK-KEY]/        # Temporary worktrees (cleaned up)
```

## Next Steps

1. **Try it out**: Create a simple spec and orchestrate
2. **Read examples**: Check `.claude/specs/examples/`
3. **Explore use cases**: See `.claude/product/use-cases.md`
4. **Understand vision**: Read `.claude/product/vision.md`
5. **Plan ahead**: Review `.claude/product/roadmap.md`

## Getting Help

- **Documentation**: Check `.claude/product/` directory
- **Examples**: See `.claude/specs/examples/`
- **Validation**: Ask "What did we decide about X?"
- **Status**: Run `/droidz-init --status`

---

**Droidz Version**: 1.0.0
**Last Updated**: 2025-11-12
**Status**: Production Ready ✅

*From idea to implementation, faster and more organized.*
