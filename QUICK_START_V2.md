# Droidz V2 Quick Start

## What is Droidz V2?

Droidz V2 is a **Factory-native multi-agent system** that transforms Linear tickets into production-ready pull requests. It uses:

- **Task tool delegation** for parallel execution
- **Custom specialist droids** for different types of work
- **Git worktrees** for true isolation
- **TodoWrite** for real-time progress tracking
- **Dynamic MCP tools** (automatically available when you configure servers)

## Prerequisites

1. **Factory CLI** installed and configured
2. **JavaScript Runtime** - Bun (recommended) or Node.js/npm
3. **Custom Droids** enabled (experimental feature)
4. **API Keys** (optional) - Linear, Exa, Ref for enhanced features
5. **GitHub CLI** (`gh`) installed and authenticated
6. **Git repository** with remote origin

### Install JavaScript Runtime

**Option 1: Bun (Recommended - 3-10x faster!)**
```bash
curl -fsSL https://bun.sh/install | bash
bun --version
```

**Option 2: Node.js (Already have it?)**
```bash
node --version  # Check if installed
# If not: Download from https://nodejs.org
```

## Installation

### 1. Enable Custom Droids

```bash
# Start Factory CLI
droid

# In Factory, type:
/settings

# Enable "Custom Droids" (Experimental feature)
# Restart Factory
```

### 2. Verify Droids Loaded

```bash
droid

# In Factory, type:
/droids

# You should see:
# - droidz-orchestrator
# - droidz-codegen
# - droidz-test
# (and others)
```

### 3. Configure API Access (Optional but Recommended)

**Method 1: MCP Servers (Recommended - Direct tool access)**

```bash
droid
/mcp add exa      # AI search
/mcp add linear   # Project management
/mcp add ref      # Documentation
```

Orchestrator will use direct MCP tool calls for best performance!

**Method 2: config.yml (Fallback - Still works great!)**

```bash
nano config.yml
```

Add API keys:
```yaml
linear:
  api_key: "lin_api_YOUR_KEY"  # https://linear.app/settings/api
  project_name: "MyProject"

exa:
  api_key: "exa_YOUR_KEY"  # https://exa.ai/api-keys

# Note: Ref requires MCP server (no REST API)

runtime:
  package_manager: "bun"  # or "npm", "pnpm", "yarn"
```

**Method 3: No Setup (Basic - Uses WebSearch)**

Droidz works without any setup! Just less powerful research tools.

**Note:** config.yml is gitignored for security!

## Usage

### Basic Usage

**Option 1: Work on Existing Linear Project**

First, add your project name to config.yml:
```yaml
linear:
  project_name: "MyProject"  # Your actual Linear project name
```

Then:
```bash
# Start Factory
droid

# Then say:
> Use droidz-orchestrator to process project "MyProject" sprint "Sprint-5"
```

**Option 2: Create New Linear Project**

Leave `project_name` empty in config.yml, then:
```bash
droid

# Describe what to build:
> Use droidz-orchestrator to build a todo app with user authentication
```

Droidz will create the Linear project automatically!

**What happens:**
1. Orchestrator fetches all Linear tickets in Sprint-5
2. Shows execution plan via TodoWrite
3. Prepares git worktrees for each ticket
4. Delegates to specialists (runs 5-10 in parallel)
5. Each specialist:
   - Updates Linear to "In Progress"
   - Implements feature in isolated worktree
   - Runs tests
   - Creates PR
   - Updates Linear with PR link
6. Orchestrator shows final summary with all PRs

### Single Ticket

```bash
droid

# Then say:
> Use droidz-orchestrator to process ticket PROJ-123
```

### Custom Configuration

Create `config.yml` in your repo:

```yaml
linear:
  teamId: "your-team-id"
  apiKey: "${LINEAR_API_KEY}"
  updateComments: true

workspace:
  baseDir: ".runs"
  branchPattern: "feature/{issueKey}-{slug}"
  mode: "worktree"  # or "clone" or "branch"

guardrails:
  testsRequired: true
  secretScan: true

parallelization:
  maxConcurrent: 5  # Max parallel specialists
```

## How It Works

### 1. Orchestrator Fetches Tickets

```bash
# Behind the scenes:
bun orchestrator/linear-fetch.ts --project MyProject --sprint Sprint-5

# Returns:
{
  "issues": [
    {
      "key": "PROJ-123",
      "title": "Add login form",
      "labels": ["frontend", "feature"],
      "deps": ["PROJ-120"]
    }
  ]
}
```

### 2. Orchestrator Creates Plan

Shows TodoWrite:
```
✅ PROJ-120: Auth API endpoint (backend)
🔄 PROJ-123: Login form (frontend) - In Progress
⏳ PROJ-124: Login tests (test) - Pending
```

### 3. Orchestrator Prepares Worktrees

```bash
# For each ticket:
bun orchestrator/task-coordinator.ts '{
  "ticket": {"key": "PROJ-123", ...},
  "specialist": "codegen",
  "repoRoot": "/path/to/repo",
  "config": {...}
}'

# Creates isolated worktree:
# /path/to/repo/.runs/PROJ-123/
```

### 4. Orchestrator Delegates to Specialists

```typescript
// Uses Factory's Task tool:
Task({
  subagent_type: "droidz-codegen",
  description: "Implement PROJ-123: Add login form",
  prompt: `
    # Working Directory: /path/to/repo/.runs/PROJ-123
    # Branch: feature/PROJ-123-add-login-form
    # Ticket: PROJ-123
    
    Implement the login form with email/password fields...
    [Full context and instructions provided]
  `
})
```

### 5. Specialists Work in Parallel

Each specialist:
1. Updates Linear: "In Progress"
2. Implements feature in worktree
3. Runs `bun test` (must pass)
4. Commits and pushes
5. Creates PR with `gh pr create --fill`
6. Updates Linear with PR link
7. Returns result to orchestrator

### 6. Orchestrator Aggregates Results

Final summary:
```markdown
## 🎉 Sprint Execution Complete

**Completed**: 12 tickets
**PRs Created**: 12
**Average Time**: 8 minutes per ticket

### Pull Requests
- PROJ-120: Auth API endpoint - https://github.com/org/repo/pull/44
- PROJ-123: Login form - https://github.com/org/repo/pull/45
...
```

## Specialist Routing

Orchestrator routes tickets based on labels (but can use LLM judgment):

| Labels | Specialist | Focus |
|--------|------------|-------|
| `frontend`, `ui`, `react` | droidz-codegen | Frontend implementation |
| `backend`, `api`, `server` | droidz-codegen | Backend implementation |
| `test`, `qa`, `testing` | droidz-test | Test writing/fixing |
| `infra`, `ci`, `deployment` | droidz-infra | CI/CD, tooling |
| `refactor`, `cleanup` | droidz-refactor | Code improvements |
| `integration`, `external-api` | droidz-integration | External services |

## Monitoring Progress

### Real-Time with TodoWrite

As orchestrator runs, you'll see TodoWrite updates:

```
Phase 1 (parallel):
  ✅ PROJ-120: Auth API endpoint - PR#44
  ✅ PROJ-121: User model - PR#45
  
Phase 2 (parallel):
  🔄 PROJ-123: Login form - In Progress
  🔄 PROJ-124: Signup form - In Progress
  ⏳ PROJ-125: Profile page - Waiting
```

### Check Worktrees

```bash
# See all active worktrees
git worktree list

# Inspect a specific worktree
cd .runs/PROJ-123
git status
git log
```

### Monitor Linear

Tickets automatically updated:
- Status: "In Progress" → "Completed"
- Comments: PR links posted
- Labels: Preserved and respected

## Troubleshooting

### Custom Droids Not Loading

```bash
# Check Factory settings
droid
/settings

# Ensure "Custom Droids" is enabled
# Restart Factory
```

### Linear API Errors

```bash
# Verify API key
echo $LINEAR_API_KEY

# Test Linear connection
bun orchestrator/linear-fetch.ts --project MyProject

# Should return JSON with issues
```

### Worktree Errors

```bash
# Clean up stale worktrees
git worktree prune

# Remove specific worktree
git worktree remove .runs/PROJ-123

# Force remove if needed
git worktree remove --force .runs/PROJ-123
```

### Test Failures

If specialist reports test failures:
1. Check the worktree: `cd .runs/PROJ-123`
2. Run tests manually: `bun test`
3. Fix failing tests
4. Commit and push
5. PR will update automatically

### PR Creation Fails

If `gh pr create` fails:
1. Check GitHub authentication: `gh auth status`
2. Re-authenticate: `gh auth login`
3. Manually create PR from worktree:
   ```bash
   cd .runs/PROJ-123
   gh pr create --fill --head feature/PROJ-123-...
   ```

## Advanced Usage

### Dependency Management

Tickets with dependencies wait automatically:

```json
{
  "key": "PROJ-123",
  "title": "Login UI",
  "deps": ["PROJ-120"]  // Waits for PROJ-120 to complete
}
```

Orchestrator handles this:
1. Completes PROJ-120 first
2. Then starts PROJ-123
3. Updates TodoWrite to show dependency chain

### Custom Specialist Selection

Orchestrator can override label routing:

```
> Use droidz-orchestrator for project X sprint Y, but route all tickets to droidz-refactor
```

LLM will intelligently adapt routing.

### Partial Sprint Execution

```
> Use droidz-orchestrator to process only frontend tickets in sprint Y
```

Orchestrator will filter tickets based on labels.

## Performance

**Typical Performance** (10 tickets):
- **Fetch tickets**: ~2 seconds
- **Prepare worktrees**: ~10 seconds
- **Parallel execution**: ~8-12 minutes (5-10 concurrent)
- **Total**: ~15-18 minutes

**Compared to V1**:
- V1: ~15 minutes (slightly faster)
- V2: ~18 minutes (20% overhead for richer context)

**Benefits of V2**:
- Better architecture
- Real-time progress
- LLM-driven decisions
- Easier to maintain

## Next Steps

1. **Test with Small Sprint**: Start with 2-3 tickets
2. **Review Generated PRs**: Check quality and consistency
3. **Adjust Configuration**: Tune `maxConcurrent`, routing rules
4. **Scale Up**: Run larger sprints (10-20 tickets)
5. **Automate**: Add to CI/CD for sprint kickoffs

## Migration from V1

V1 (shell-based) has been retired. Droidz is now V2-only.

```bash
# Start Factory
droid

# Then talk to orchestrator:
> "Use droidz-orchestrator to process project X sprint Y"
```

## Support

- **Architecture docs**: `docs/V2_ARCHITECTURE.md`
- **Configuration**: `config.yml` (same as V1)
- **Helper scripts**: `orchestrator/*.ts`
- **Specialist droids**: `.factory/droids/droidz-*.md`

---

**Ready to go?** Enable custom droids and start with `droid`! 🚀
