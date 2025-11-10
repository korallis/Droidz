# How To Use Droidz - Corrected Architecture

## Quick Start

After the v2.0.2 fix, Droidz follows Factory.ai's official Custom Droid architecture where the orchestrator is a **planner**, not an executor.

## The Correct Workflow

### 1. Enable Custom Droids

```bash
droid
/settings
# Toggle "Custom Droids" to ON
/quit
droid
```

### 2. Ask Orchestrator to Create a Plan

In your main droid session:

```bash
droid
```

Then say one of:
```
"Use droidz-orchestrator to analyze tickets in Linear project MyApp"

"Use droidz-orchestrator to plan implementation of these features:
- User authentication
- Task CRUD
- Dashboard UI
- Testing"

"Use droidz-orchestrator to break down ticket PROJ-123"
```

### 3. Orchestrator Creates Execution Plan

The orchestrator will:
- Analyze requirements
- Break into tasks
- Identify dependencies
- Suggest which specialist droid for each task
- Output clear delegation instructions

**Example output:**
```
📋 Execution Plan Generated

Phase 1: Foundation (Sequential)
├─ TASK-1: Setup project structure → droidz-infra
└─ TASK-2: Database schema → droidz-codegen

Phase 2: Core Features (Parallel - all can run simultaneously)
├─ TASK-3: Auth API endpoints → droidz-codegen
├─ TASK-4: Task CRUD API → droidz-codegen
└─ TASK-5: UI components → droidz-codegen

Phase 3: Quality (Parallel)
├─ TASK-6: API tests → droidz-test
└─ TASK-7: UI tests → droidz-test

⚡ Parallel Execution Strategy:
Sequential would take: ~70 minutes (7 tasks × 10 min)
With parallel: ~30 minutes (3 phases)
Time saved: ~40 minutes (2.3x faster)

🚀 NEXT STEPS FOR YOU:

Phase 1 - Run these sequentially:
1. "Use droidz-infra to implement TASK-1: Setup project with Bun, TypeScript, React"
2. "Use droidz-codegen to implement TASK-2: Create database schema with Prisma"

Phase 2 - Run these in PARALLEL (3 separate sessions):
3. "Use droidz-codegen to implement TASK-3: Build auth API with JWT"
4. "Use droidz-codegen to implement TASK-4: Build task CRUD API"
5. "Use droidz-codegen to implement TASK-5: Create React UI components"

Phase 3 - Run these in PARALLEL after Phase 2:
6. "Use droidz-test to implement TASK-6: Test all API endpoints"
7. "Use droidz-test to implement TASK-7: Test UI components"

Each task uses isolated git worktrees (.runs/TASK-X/) for true parallelism.
```

### 4. YOU Delegate to Specialists

Copy the instructions from orchestrator and execute them:

**Sequential tasks (one at a time):**
```bash
droid
> "Use droidz-infra to implement TASK-1: Setup project with Bun, TypeScript, React"
# Wait for completion...

droid
> "Use droidz-codegen to implement TASK-2: Create database schema with Prisma"
# Wait for completion...
```

**Parallel tasks (open multiple terminal windows):**
```bash
# Terminal 1:
droid
> "Use droidz-codegen to implement TASK-3: Build auth API with JWT"

# Terminal 2 (simultaneously):
droid
> "Use droidz-codegen to implement TASK-4: Build task CRUD API"

# Terminal 3 (simultaneously):
droid
> "Use droidz-codegen to implement TASK-5: Create React UI components"
```

### 5. Specialists Do The Work

When you say "Use droidz-codegen to implement X":
- Factory automatically invokes the `droidz-codegen` custom droid
- Specialist has ALL tools (Create, Edit, Execute, etc.)
- Specialist works in isolated git worktree
- Specialist creates files, runs tests, commits, pushes, creates PR
- Results returned to YOU

### 6. Review Pull Requests

```bash
gh pr list
gh pr view 1
gh pr merge 1
```

## Key Architecture Points

### ✅ Correct Understanding

1. **Orchestrator = Planner**
   - Analyzes requirements
   - Creates execution strategy
   - Outputs delegation instructions
   - Does NOT execute or delegate directly

2. **User = Delegator**
   - Receives plan from orchestrator
   - Invokes specialists via: "Use droidz-X to implement Y"
   - Can run multiple specialists in parallel
   - Reviews and merges PRs

3. **Specialists = Executors**
   - Invoked by user in main droid session
   - Have ALL Factory tools when `tools` field is undefined
   - Work in isolated git worktrees
   - Create PRs and return results

4. **Task Tool**
   - Automatically available when Custom Droids enabled
   - NOT listed in tools arrays
   - Only works in main droid session (not in custom droids)

### ❌ Common Mistakes

1. **Don't put "Task" in tools arrays**
   ```yaml
   # WRONG:
   tools: ["Read", "Execute", "Task"]  # ❌ Task is not a listable tool
   
   # CORRECT:
   tools: ["Read", "Execute"]  # ✅ Task is automatically available
   ```

2. **Don't expect custom droids to delegate**
   ```
   # WRONG: Orchestrator tries to call Task() directly
   const result = Task({subagent_type: "droidz-codegen"})  # ❌ Won't work
   
   # CORRECT: Orchestrator tells USER to delegate
   "NEXT STEP: You say 'Use droidz-codegen to implement X'"  # ✅ Works
   ```

3. **Don't skip the orchestrator**
   ```
   # LESS EFFICIENT:
   User directly: "Use droidz-codegen to build entire feature"
   # Specialist has to figure out architecture, dependencies, etc.
   
   # MORE EFFICIENT:
   Step 1: "Use droidz-orchestrator to plan the feature"
   Step 2: Follow orchestrator's detailed delegation instructions
   # Better breakdown, clearer dependencies, parallel execution strategy
   ```

## Advanced Usage

### Parallel Execution with Git Worktrees

The power of Droidz is TRUE parallelism via git worktrees:

```bash
# Traditional: Sequential (60 minutes)
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6
10min    10min    10min    10min    10min    10min

# Droidz: Parallel (20 minutes)
Task 1 (10min sequential)
    ↓
Task 2, Task 3, Task 4 (10min parallel, 3 sessions)
    ↓
Task 5, Task 6 (10min parallel, 2 sessions)

Time saved: 40 minutes (3x faster!)
```

Each specialist works in `.runs/TASK-X/` directory - isolated git worktree:
```
project/
├── .runs/
│   ├── TASK-3/  (specialist 1 working here)
│   ├── TASK-4/  (specialist 2 working here)
│   └── TASK-5/  (specialist 3 working here)
├── .factory/
│   └── droids/
│       ├── droidz-orchestrator.md
│       ├── droidz-codegen.md
│       └── droidz-test.md
└── ...main repo files...
```

### Using with Linear

If you have Linear MCP configured:

```bash
droid
> "Use droidz-orchestrator to process all tickets in Linear project MyApp"

# Orchestrator will:
# 1. Fetch tickets from Linear
# 2. Analyze dependencies
# 3. Create execution plan
# 4. Output delegation instructions

# Then YOU execute the delegations
```

### Specialist Droid Types

- **droidz-codegen**: General feature implementation
- **droidz-test**: Test writing and coverage
- **droidz-refactor**: Code cleanup and restructuring
- **droidz-infra**: CI/CD, build tools, deployment
- **droidz-integration**: External API integration
- **droidz-generalist**: Fallback for unclear tasks

## Model Compatibility

All specialist droids work with ALL Factory models:

| Model | Support | Notes |
|-------|---------|-------|
| Claude Sonnet 4.5 | ✅ Full | Recommended daily driver |
| Claude Opus 4.1 | ✅ Full | For complex reasoning |
| Claude Haiku 4.5 | ✅ Full | Fast and cost-effective |
| GPT-5 | ✅ Full | OpenAI generalist |
| GPT-5 Codex | ✅ Full | Fast coding-focused |
| GLM-4.6 (Droid Core) | ✅ Full | Open-source, air-gapped |

Because specialist droids have undefined `tools` field, Factory provides ALL tools regardless of model.

## Troubleshooting

### "Invalid tools: Task"

Fixed in v2.0.2. Update:
```bash
git pull origin main
# or
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### "Droid not found"

Enable Custom Droids:
```bash
droid
/settings  # Toggle "Custom Droids" ON
/quit
droid
/droids  # Verify droids appear
```

### "Orchestrator isn't working"

Remember the orchestrator is a **planner**:
- It creates plans and delegation instructions
- It does NOT execute or delegate directly
- YOU take the plan and delegate to specialists

Correct usage:
```
Step 1: "Use droidz-orchestrator to plan X"
Step 2: Read the plan
Step 3: Execute the delegation instructions yourself
```

## References

- [TOOL_COMPATIBILITY.md](./TOOL_COMPATIBILITY.md) - Detailed architecture
- [SOLUTION_SUMMARY.md](./SOLUTION_SUMMARY.md) - What was fixed in v2.0.2
- [README.md](./README.md) - Full project documentation
- [Factory.ai Custom Droids Docs](https://docs.factory.ai/cli/configuration/custom-droids) - Official reference
