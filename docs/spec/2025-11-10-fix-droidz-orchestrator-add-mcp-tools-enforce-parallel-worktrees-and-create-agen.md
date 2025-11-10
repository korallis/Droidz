# Spec: Fix Droidz Orchestrator - MCP Tools, Parallel Worktrees, and AGENTS.md

## Problem Statement

The Droidz orchestrator has three critical issues:
1. **MCP tools not used by default** - Droids don't have access to powerful MCP integrations (Linear, Exa, Ref, Playwright, Desktop Commander, code-execution) unless explicitly told
2. **Parallel git worktrees not always happening** - The core value proposition (3-5x speed via parallel execution) isn't being enforced consistently
3. **No AGENTS.md file** - Missing Factory.ai best practice for providing project context to agents

## Root Causes

### 1. MCP Tools Issue
- Droid definitions (`.factory/droids/*.md`) only list basic Factory tools: `["Read","LS","Execute","Edit","Grep","Glob","Create","TodoWrite"]`
- Missing MCP tools available in Factory.ai ecosystem that should be accessible by default
- According to Factory.ai docs, droids can invoke MCP tools autonomously when they're in the enabled tools list

### 2. Parallel Worktrees Issue
- Config has both `useWorktrees: true` (legacy) and `mode` field, causing confusion
- Orchestrator droid doesn't explicitly enforce worktree mode in its prompt
- No clear messaging to users about parallel execution strategy
- Missing explanation of the 3-5x speed benefit

### 3. AGENTS.md Issue
- No AGENTS.md file exists in repository
- Factory.ai best practice: AGENTS.md provides agents with project context
- Agents read AGENTS.md before planning changes

## Solution Design

### Part 1: Create Comprehensive AGENTS.md (Following Factory.ai Best Practices)

**File**: `AGENTS.md` (repository root)

**Content**: ~150 lines following Factory.ai template structure
- Core Commands (build, test, run)
- Project Layout (directory structure)
- Development Patterns (Bun-only, TypeScript, conventions)
- Git Workflow (worktrees, branching, PRs)
- External Services (Linear, GitHub, Factory.ai)
- Droidz-Specific Context (V2 architecture, MCP tools, performance)
- Evidence Required (tests, type-check, no secrets)
- Gotchas (Bun vs npm, git version, API keys)

### Part 2: Update ALL Droids to Have Access to ALL Tools

**Philosophy**: All agents should have access to all tools and use them autonomously as needed.

**Standard Tool List for ALL Droids** (orchestrator + all specialists):

```yaml
tools: [
  # Factory Native Tools
  "Read", "LS", "Grep", "Glob", "Execute", "Edit", "Create", "TodoWrite", "FetchUrl", "Task",
  
  # Linear MCP Tools
  "linear___list_issues", "linear___get_issue", "linear___create_issue", "linear___update_issue",
  "linear___list_comments", "linear___create_comment",
  "linear___list_projects", "linear___get_project",
  "linear___list_teams", "linear___get_team",
  "linear___list_users", "linear___get_user",
  "linear___list_issue_statuses", "linear___get_issue_status",
  "linear___list_issue_labels", "linear___create_issue_label",
  
  # Exa MCP Tools
  "exa___web_search_exa", "exa___get_code_context_exa",
  
  # Ref MCP Tools
  "ref___ref_search_documentation", "ref___ref_read_url",
  
  # Code Execution MCP Tools
  "code-execution___execute_code", "code-execution___discover_tools", "code-execution___get_tool_usage",
  
  # Desktop Commander MCP Tools (comprehensive file/process management)
  "desktop-commander___read_file", "desktop-commander___write_file", "desktop-commander___edit_block",
  "desktop-commander___create_directory", "desktop-commander___list_directory",
  "desktop-commander___start_search", "desktop-commander___get_more_search_results",
  "desktop-commander___start_process", "desktop-commander___interact_with_process"
]
```

**Files to Update** (all get same tool list):
- `.factory/droids/droidz-orchestrator.md`
- `.factory/droids/codegen.md`
- `.factory/droids/test.md`
- `.factory/droids/infra.md`
- `.factory/droids/integration.md`
- `.factory/droids/refactor.md`
- `.factory/droids/generalist.md`

**Add MCP Usage Guidance Section** to all droid prompts:

```markdown
## Available MCP Tools (Use Autonomously - No Permission Needed)

You have access to comprehensive MCP integrations. **Use them freely whenever they help**:

### Linear Integration
- List/get/create/update issues
- Manage comments, projects, teams, users
- Update ticket status, post PR links
- **Example**: Automatically update ticket to "In Progress" when starting work

### Exa Search (Web & Code Research)
- `exa___web_search_exa`: Search the web with neural or keyword modes
- `exa___get_code_context_exa`: Find code examples, API docs, SDK usage
- **Example**: Research Stripe API usage before implementing payment integration

### Ref Documentation
- `ref___ref_search_documentation`: Search public and private documentation
- `ref___ref_read_url`: Read specific doc pages
- **Example**: Look up Next.js documentation for server components

### Code Execution
- `code-execution___execute_code`: Run TypeScript for MCP server interactions
- `code-execution___discover_tools`: Find available MCP tools
- **Example**: Execute complex data transformations or API calls

### Desktop Commander (Advanced Operations)
- File operations: read, write, edit, search
- Process management: start processes, interact with REPLs
- **Example**: Start Python REPL for data analysis, run complex file searches

**Key Principle**: If a tool helps you complete the task better/faster, use it without asking.
```

### Part 3: Update Orchestrator to Enforce Parallel Worktrees

**File**: `.factory/droids/droidz-orchestrator.md`

**Add new section** (after "Core Mission"):

```markdown
## CRITICAL: Parallel Execution with Git Worktrees (ALWAYS ENFORCE)

**This is Droidz's core value proposition - 3-5x faster than sequential development!**

### Before Starting ANY Execution

1. **Verify worktree mode** is configured:
```bash
# Check workspace.mode in config
cat orchestrator/config.json | grep -A3 '"workspace"'
```

2. **If mode is NOT "worktree"**, fix it immediately:
```bash
# Read config, update mode, write back
Read orchestrator/config.json
# Then use Edit to change workspace.mode to "worktree"
```

3. **Tell user the parallel execution strategy**:
```
🚀 Parallel Execution Strategy:
- Mode: Git Worktrees (isolated environments for each task)
- Concurrency: {N} workers running simultaneously
- Tasks: {total} tickets to process
- Estimated time: ~{total/concurrency * 10} minutes
- Sequential would take: ~{total * 10} minutes
- Speed benefit: {concurrency}x faster! 🎉

Each worker operates in an isolated git worktree (.runs/TICKET-KEY/), preventing conflicts 
and enabling TRUE parallel execution. This is what makes Droidz 3-5x faster!
```

### Worktree Mode Validation

When `task-coordinator.ts` returns workspace info, verify:
```json
{
  "mode": "worktree",  // ← MUST be "worktree", not "clone" or "branch"
  "workspace": "/path/.runs/PROJ-123",
  "ready": true
}
```

If mode is "clone" or "branch", **STOP** and fix the config before delegating to specialists.

### Why This Matters

- **worktree**: TRUE isolation, 3-5x faster (ALWAYS use this)
- **clone**: Full repo copies, slower, more disk space (fallback only)
- **branch**: No isolation, conflicts likely, defeats parallelization (avoid)

**Never proceed without worktree mode unless git worktrees are unsupported.**
```

### Part 4: Update Configuration Files

**File**: `orchestrator/config.json`

Ensure explicit mode setting:
```json
{
  "workspace": {
    "baseDir": ".runs",
    "branchPattern": "{type}/{issueKey}-{slug}",
    "mode": "worktree"
  }
}
```

**File**: `orchestrator/validators.ts`

Add workspace mode validation:
```typescript
export function validateWorkspaceMode(config: OrchestratorConfig): void {
  const mode = config.workspace.mode || (config.workspace.useWorktrees === false ? "branch" : "worktree");
  
  if (mode !== "worktree") {
    console.warn(`\n⚠️  WARNING: Workspace mode is "${mode}" - NOT RECOMMENDED!`);
    console.warn(`   Parallel execution requires "worktree" mode for 3-5x speed benefit.`);
    console.warn(`   Current mode will be MUCH slower and may cause conflicts.`);
    console.warn(`\n   FIX: Set workspace.mode = "worktree" in orchestrator/config.json\n`);
  } else {
    console.log(`✅ Workspace mode: worktree (optimal for parallel execution)`);
  }
}
```

**File**: `orchestrator/launch.ts`

Add validation call before execution:
```typescript
import { validateWorkspaceMode } from "./validators";

// ... in main() function, after loading config:
console.log("Validating workspace configuration...");
validateWorkspaceMode(cfg);
```

## Implementation Summary

### Files to Create (1 file):
1. **`AGENTS.md`** - Comprehensive project guide following Factory.ai best practices (~150 lines)

### Files to Update (11 files):

**Droid Definitions** (7 files - all get same comprehensive tool list):
1. `.factory/droids/droidz-orchestrator.md` - Add all tools, enforce worktrees section
2. `.factory/droids/codegen.md` - Add all tools, add MCP usage guidance
3. `.factory/droids/test.md` - Add all tools, add MCP usage guidance
4. `.factory/droids/refactor.md` - Add all tools, add MCP usage guidance
5. `.factory/droids/infra.md` - Add all tools, add MCP usage guidance
6. `.factory/droids/integration.md` - Add all tools, add MCP usage guidance
7. `.factory/droids/generalist.md` - Add all tools, add MCP usage guidance

**Configuration & Validation** (4 files):
8. `orchestrator/config.json` - Ensure explicit `mode: "worktree"`
9. `orchestrator/validators.ts` - Add `validateWorkspaceMode()` function
10. `orchestrator/launch.ts` - Call validation before execution
11. `config.yml` (project root) - Update to reflect MCP tools usage is enabled

## Expected Outcomes

✅ **All MCP Tools Available to All Droids**: Every droid can use Linear, Exa, Ref, code-execution, Desktop Commander autonomously  
✅ **Parallel Worktrees Always Enforced**: Orchestrator explicitly checks, fixes, and validates worktree mode  
✅ **Clear User Communication**: Users see parallel execution strategy and speed benefits upfront  
✅ **AGENTS.md Provides Context**: All agents have comprehensive project context following Factory.ai best practices  
✅ **Factory.ai Compliant**: All changes follow official guidelines for custom droids, AGENTS.md, and MCP integration  
✅ **Autonomous Tool Usage**: Droids research APIs (Exa), read docs (Ref), update tickets (Linear) without prompting  
✅ **Better Development Velocity**: 3-5x speed improvement consistently achieved through enforced parallelization  

## Testing Plan

1. **Test MCP Tool Access**: Ask any droid to research something → should use Exa autonomously
2. **Test Worktree Enforcement**: Run orchestrator → should validate/fix mode and explain strategy
3. **Test AGENTS.md Loading**: Agents should reference AGENTS.md content (Bun-only, conventions, etc.)
4. **Test Parallel Execution**: Process 5+ tickets → should show clear parallel strategy with time estimates
5. **Test Linear Integration**: All droids should update Linear tickets automatically without being told
6. **Test Code Execution**: Droids should be able to run TypeScript for complex operations
7. **Test Desktop Commander**: Droids should use advanced file/search operations when beneficial

## Alignment with Factory.ai Best Practices

✅ **MCP Integration**: Following official MCP documentation patterns and server usage  
✅ **AGENTS.md Spec**: Following official AGENTS.md format, structure, and best practices  
✅ **Custom Droids**: Using comprehensive tool lists with autonomous invocation capability  
✅ **Task Tool Usage**: Proper orchestrator → specialist delegation with complete tool access  
✅ **Real-time Updates**: Using TodoWrite for progress visibility  
✅ **Tool Philosophy**: All agents have all tools, use autonomously as needed (Factory.ai recommended pattern)