# Changelog

All notable changes to Droidz will be documented in this file.

## [2.1.0] - 2025-11-10

### 🚀 Major Enhancements

#### MCP Tools Integration
- **Added comprehensive MCP tools to ALL droids** - orchestrator and all specialists now have access to:
  - **Linear MCP**: Direct issue management, commenting, project/team access
  - **Exa Search**: Web and code context research capabilities
  - **Ref Documentation**: Public and private documentation search
  - **Code Execution**: TypeScript execution for MCP server interactions
  - **Desktop Commander**: Advanced file operations and process management
- **Autonomous tool usage** - Droids now use MCP tools automatically without needing permission
- **Research capabilities** - Droids can research APIs, SDKs, best practices autonomously using Exa
- **Documentation lookup** - Automatic documentation search via Ref when implementing features

#### Parallel Execution Enforcement
- **Added CRITICAL worktree enforcement section** to orchestrator droid
- **Workspace mode validation** - New `validateWorkspaceMode()` function in validators.ts
- **Launch-time validation** - Workspace mode is now validated on every orchestrator launch
- **User visibility** - Clear ✅ or ⚠️ messages about workspace configuration
- **Speed benefit messaging** - Orchestrator now explains 3-5x speed benefit to users upfront
- **Automatic config checking** - Orchestrator verifies worktree mode before delegating tasks

#### Factory.ai Best Practices
- **Created comprehensive AGENTS.md** - Following official Factory.ai specification:
  - Project commands and conventions
  - Architecture overview and layout
  - Development patterns (Bun-only, TypeScript strict)
  - Git workflow with worktrees
  - External services configuration
  - Performance characteristics
  - Troubleshooting guide
- **MCP usage guidance** added to all droid prompts with examples
- **Tool access patterns** aligned with Factory.ai recommendations

### 📝 Files Added
- `AGENTS.md` - Comprehensive project guide for AI agents (~150 lines)

### 🔧 Files Updated

#### Droid Definitions (7 files)
- `.factory/droids/droidz-orchestrator.md` - Added all MCP tools, worktree enforcement, usage guidance
- `.factory/droids/codegen.md` - Added all MCP tools and usage guidance
- `.factory/droids/test.md` - Added all MCP tools and usage guidance
- `.factory/droids/refactor.md` - Added all MCP tools and usage guidance
- `.factory/droids/infra.md` - Added all MCP tools and usage guidance
- `.factory/droids/integration.md` - Added all MCP tools and usage guidance
- `.factory/droids/generalist.md` - Added all MCP tools and usage guidance

#### Configuration & Validation (4 files)
- `orchestrator/config.json` - Added explicit `mode: "worktree"` field
- `orchestrator/validators.ts` - Added `validateWorkspaceMode()` function
- `orchestrator/launch.ts` - Added workspace validation call
- `config.yml` - Enabled `use_exa_research` and `use_ref_docs`, added `mcp_tools_enabled` flag

### ✨ Impact

**Before this release:**
- Droids couldn't research APIs or documentation autonomously
- Parallel worktrees not consistently enforced
- Users didn't see speed benefit messaging
- No project context file for agents

**After this release:**
- ✅ Droids autonomously research with Exa, look up docs with Ref, update Linear tickets
- ✅ Parallel execution (3-5x speed) consistently achieved via worktree enforcement
- ✅ Users see clear parallel execution strategy and time estimates
- ✅ All agents have comprehensive project context via AGENTS.md
- ✅ Fully compliant with Factory.ai best practices

### 🎯 Key Benefits

1. **Smarter Droids**: Autonomous research and documentation lookup capabilities
2. **Consistent Performance**: 3-5x speed improvement reliably achieved through enforced parallelization
3. **Better Visibility**: Clear user communication about execution strategy and progress
4. **Factory.ai Compliant**: All changes follow official guidelines and patterns

---

## [2.0.0] - 2025-01-10

### 🎉 MAJOR RELEASE - Factory-Native Multi-Agent System

Complete rewrite of Droidz. V1 (shell-based) is retired.

### ✨ Added

- **Orchestrator Droid** - Central coordinator using Factory's Task tool
- **Specialist Droids** - codegen, test, refactor, infra, integration
- **Real-time Progress** - TodoWrite shows live status
- **LLM-driven Routing** - Smart specialist selection
- **Helper Scripts** - linear-fetch, linear-update, worktree-setup, task-coordinator
- **Git Worktrees** - True isolation for parallel work
- **Comprehensive Docs** - Simple README, architecture guides

### 🔄 Changed

- Complete architecture: Shell-based → Factory-native
- Task tool delegation replaces process spawning
- Custom droids replace shell workers
- Helper scripts for Linear integration

### 🗑️ Removed

- V1 shell-based orchestrator (deprecated)
- Direct process spawning
- All V1-specific code

### 📊 Performance

- ~18 minutes for 10 tickets
- 5-10 parallel specialists
- Real-time visibility

---

## [1.0.0] - 2024-12-15 (DEPRECATED)

Initial shell-based release. No longer supported.
