# Droidz

Droidz is a Factory-native multi-agent system for parallel software development. It transforms Linear tickets into production-ready pull requests using Task tool delegation, git worktrees, and specialist droids.

## Core Commands

- **Install dependencies**: `bun install`
- **Test orchestrator scripts**: `bun test orchestrator/*.test.ts`
- **Run orchestrator V1** (shell-based): `bun orchestrator/launch.ts`
- **Run orchestrator V2** (Factory-native): Via `droidz-orchestrator` custom droid
- **Type-check**: `bun run tsc --noEmit`
- **Validate Linear fetch**: `bun orchestrator/linear-fetch.ts --project "ProjectName" --sprint "SprintName"`
- **Update Linear ticket**: `bun orchestrator/linear-update.ts --issue PROJ-123 --status "In Progress"`
- **Setup worktree**: `bun orchestrator/worktree-setup.ts <repoRoot> <baseDir> <branch> <key> worktree`

All scripts use **Bun only** - never use npm, npx, or node commands.

## Project Layout

```
├─ .factory/droids/     → Custom droid definitions (orchestrator + specialists)
│  ├─ droidz-orchestrator.md  → Main orchestrator droid
│  ├─ codegen.md       → Feature implementation specialist
│  ├─ test.md          → Test writing specialist
│  ├─ refactor.md      → Code cleanup specialist
│  ├─ infra.md         → CI/CD and tooling specialist
│  ├─ integration.md   → External API integration specialist
│  └─ generalist.md    → Fallback for unclear tickets
├─ orchestrator/        → Orchestration scripts and helpers
│  ├─ linear-*.ts      → Linear API integration helpers
│  ├─ worktree-*.ts    → Git worktree setup and management
│  ├─ task-*.ts        → Task coordination bridge
│  ├─ workers.ts       → Specialist execution (V1)
│  ├─ launch.ts        → Main entry point (V1)
│  └─ run.ts           → Execution runner (V1)
├─ workflows/          → Workflow templates for different project types
├─ standards/          → Coding standards and architectural conventions
├─ docs/              → Architecture docs (especially V2_ARCHITECTURE.md)
└─ config.yml         → Project configuration for Droidz framework
```

## Development Patterns & Constraints

### Technology Stack
- **Runtime**: Bun only (not npm/npx/node)
- **Tests**: `bun test`
- **Package management**: `bun add` / `bun remove`
- **Type checking**: `bun run tsc --noEmit`

### Architecture Principles

**Parallel Execution is Core Value**:
- 3-5x faster than sequential development via git worktrees
- Each specialist works in isolated `.runs/<TICKET-KEY>/` directory
- True isolation prevents conflicts between parallel workers
- Target: 5-10 concurrent specialists processing tickets simultaneously

**Factory-Native Design**:
- Uses Task tool for orchestrator → specialist delegation
- Custom droids with comprehensive MCP tool access
- Real-time visibility via TodoWrite progress updates
- LLM-driven routing (not just label-based)

**Isolated Workspaces**:
- Each specialist gets own git worktree
- Independent branches prevent merge conflicts
- Easy cleanup after PR merge
- Worktree mode is default and strongly recommended

### Coding Style

- TypeScript strict mode enabled
- Minimal comments - code should be self-documenting
- Match existing patterns in `orchestrator/*.ts` files
- No hardcoded secrets - always use environment variables
- Error messages should be actionable and clear

## Git Workflow Essentials

1. **Branch naming**: Follow pattern `{type}/{issueKey}-{slug}`
   - Example: `feature/PROJ-123-add-login-form`
2. **Worktrees**: Automatically created in `.runs/<TICKET-KEY>/` for parallel work
3. **Isolation**: Each specialist works in own worktree - no conflicts!
4. **PRs**: Created from feature branches, never push directly to `main`
5. **Force push**: Only allowed on your feature branch with `--force-with-lease`
6. **Commits**: Atomic, descriptive, include ticket key: `PROJ-123: Add login validation`

## External Services

### Linear (Project Management)
- **API Key**: Set `LINEAR_API_KEY` environment variable
- **Usage**: Ticket fetching, status updates, comment posting
- **Integration**: Both manual scripts and MCP tools available

### GitHub (Code Hosting)
- **CLI Required**: `gh` command must be installed for PR creation
- **Auth**: Authenticate with `gh auth login`
- **PRs**: Auto-created by specialists after implementation

### Factory.ai (Droid Orchestration)
- **Custom Droids**: Must be enabled in Factory settings (`/settings`)
- **MCP Tools**: Linear, Exa, Ref, code-execution, Desktop Commander available
- **Access**: Droids use MCP tools autonomously - no permission needed

## Droidz-Specific Context

### V2 Architecture (Factory-Native)

The current recommended architecture uses Factory's native capabilities:

**Orchestrator Droid** (`droidz-orchestrator`):
- Fetches Linear tickets using helper scripts
- Analyzes dependencies and creates execution plan
- Routes tickets to appropriate specialists (LLM-driven)
- Prepares isolated git worktrees via task-coordinator
- Delegates using Task tool (spawns multiple in parallel)
- Monitors progress with TodoWrite
- Aggregates results and provides final summary

**Specialist Droids** (codegen, test, refactor, infra, integration):
- Receive workspace + ticket context from orchestrator
- Update Linear status to "In Progress"
- Implement changes in isolated worktree
- Run tests/lint to ensure quality
- Commit, push, and create PR
- Update Linear with PR link
- Return JSON result to orchestrator

### MCP Tools Integration

All droids have access to comprehensive MCP tools:
- **Linear**: Manage tickets, comments, projects, teams autonomously
- **Exa**: Web search and code context for research
- **Ref**: Documentation search (public and private)
- **code-execution**: Execute TypeScript for complex operations
- **Desktop Commander**: Advanced file operations and process management

**Key principle**: Droids use these tools autonomously when beneficial - no need to ask permission.

### Performance Characteristics

- **Target concurrency**: 5-10 specialists working simultaneously
- **Average time per ticket**: 8-12 minutes
- **Total sprint time**: max(longest dependency chain) + overhead
- **Speed benefit**: 3-5x faster than sequential development
- **Limitation**: System resources (CPU, memory, disk)

## Evidence Required for Every Change

Before marking any task complete, ensure:

1. ✅ All tests pass: `bun test`
2. ✅ Type-check passes: `bun run tsc --noEmit`
3. ✅ No hardcoded secrets (secret scan enabled in guardrails)
4. ✅ PR created with clear description linking to Linear ticket
5. ✅ Linear ticket updated with PR link
6. ✅ Changes confined to assigned workspace (no cross-contamination)

## Gotchas & Important Notes

### Bun vs npm/npx
- **Always use Bun**: Commands like `bun test`, `bun add`, `bun run`
- **Never use npm/npx**: Will cause environment inconsistencies
- **Node not available**: Don't reference `node` command directly

### Git Worktrees
- **Requires git 2.5+**: Check with `git --version`
- **Cleanup**: Remove worktrees after PR merge: `git worktree remove .runs/PROJ-123`
- **Disk space**: Each worktree is lightweight but does use disk space
- **Mode is critical**: Only "worktree" mode enables true parallelization

### Linear Integration
- **API key required**: Must have `LINEAR_API_KEY` in environment
- **Rate limits**: Linear API has rate limits, helper scripts handle retries
- **Team ID needed**: Configure in `orchestrator/config.json`

### Factory Custom Droids
- **Must be enabled**: Go to `/settings` in droid CLI and enable "Custom Droids"
- **Requires restart**: After enabling, exit and restart droid CLI
- **Verification**: Run `/droids` to see available custom droids

### Workspace Modes
- **worktree** (RECOMMENDED): True isolation, fastest, safest
- **clone**: Full repo copies, slower, more disk space (fallback only)
- **branch**: Shadow copies, no git isolation, defeats parallelization (avoid!)

## Troubleshooting Common Issues

### "Not a git repository"
**Solution**: Initialize git and add remote origin before using Droidz.

### "Linear API key missing"
**Solution**: Export `LINEAR_API_KEY` environment variable before running orchestrator.

### "Custom droids not found"
**Solution**: Enable "Custom Droids" in Factory settings, restart droid CLI.

### "Worktree creation failed"
**Solution**: Ensure git 2.5+, remove any existing worktrees with same name.

### "Tests failing in worktree"
**Solution**: Ensure dependencies installed in worktree: `cd .runs/PROJ-123 && bun install`

### "Parallel execution not happening"
**Solution**: Verify `workspace.mode = "worktree"` in `orchestrator/config.json`.

## Quick Start Examples

### Process Linear Sprint
```bash
# Start Factory CLI
droid --auto high

# Invoke orchestrator (V2)
> Use droidz-orchestrator to process project "MyProject" sprint "Sprint-5"
```

### Run V1 Shell-Based
```bash
# Direct orchestrator execution
bun orchestrator/launch.ts
```

### Test Linear Integration
```bash
# Fetch tickets
bun orchestrator/linear-fetch.ts --project "MyProject" --sprint "Sprint-5"

# Update ticket status
LINEAR_API_KEY=your_key bun orchestrator/linear-update.ts --issue PROJ-123 --status "In Progress"
```

### Manual Worktree Setup
```bash
# Create worktree for ticket
bun orchestrator/worktree-setup.ts . .runs feature/PROJ-123-test PROJ-123 worktree
```

---

**Remember**: Droidz's superpower is parallel execution with git worktrees. Always ensure worktree mode is enabled for maximum velocity! 🚀
