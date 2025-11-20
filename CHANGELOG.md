# Changelog

All notable changes to Droidz will be documented in this file.

## [2.7.0] - 2025-11-20

### 🎉 Major Release: 7 New Specialized Droids + Quality Improvements

This release **doubles** the Droidz team from 7 to 14 droids, adding specialized experts for every aspect of software development. All droids have been validated against Factory.ai official documentation and include comprehensive, production-ready prompts.

### ✨ New Specialized Droids (7)

Research-driven development using exa-code and Factory.ai documentation to create expert-level specialist droids:

1. **droidz-ui-designer** (~550 lines)
   - Modern CSS, Design Systems, Tailwind, Responsive Design
   - Auto-invokes: "design UI", "create interface", "style components"
   - Expertise: Grid/Flexbox, Container Queries, Design Tokens, Atomic Design

2. **droidz-ux-designer** (~600 lines)
   - User Flows, Journey Mapping, Onboarding, Micro-copy
   - Auto-invokes: "improve UX", "user experience", "user flow"
   - Expertise: User research, personas, wireframes, usability testing

3. **droidz-api-designer** (~700 lines)
   - REST/GraphQL, OpenAPI, OAuth 2.0, Rate Limiting
   - Auto-invokes: "design API", "API endpoints", "REST API"
   - Expertise: Richardson Maturity Model, versioning, error handling

4. **droidz-database-architect** (~650 lines)
   - SQL/NoSQL Schema, Query Optimization, Migrations
   - Auto-invokes: "database schema", "design database", "migrations"
   - Expertise: PostgreSQL, MongoDB, indexing, normalization vs denormalization

5. **droidz-security-auditor** (~750 lines)
   - OWASP Top 10, Penetration Testing, Compliance
   - Auto-invokes: "security audit", "vulnerability scan", "security review"
   - Expertise: SQL injection, XSS, CSRF, authentication/authorization flaws

6. **droidz-performance-optimizer** (~550 lines)
   - Core Web Vitals, Caching, Bundle Optimization
   - Auto-invokes: "optimize performance", "improve speed", "performance tuning"
   - Expertise: Chrome DevTools, lazy loading, code splitting, CDN optimization

7. **droidz-accessibility-specialist** (~650 lines)
   - WCAG 2.2, ARIA, Screen Readers, Keyboard Nav
   - Auto-invokes: "accessibility", "WCAG", "screen readers", "a11y"
   - Expertise: Semantic HTML, ARIA patterns, focus management, color contrast

**Total**: ~4,450 lines of expert prompts with real-world examples and best practices!

### 🔧 Critical Fixes

#### Factory.ai Standards Compliance (v2.7.0)
- **Fixed name field mismatch** in all 7 new droids
  - Factory.ai requires `name` field to match filename (without .md)
  - Issue: `name: ui-designer` vs filename `droidz-ui-designer.md`
  - Fixed: All droids now have matching names (e.g., `name: droidz-ui-designer`)
  - Impact: Ensures correct `subagent_type` resolution in Task tool
- **Validated all droids** against Factory.ai official documentation
  - 10/10 validation categories pass
  - Added comprehensive VALIDATION_REPORT.md

#### Naming Consistency (v2.7.0)
- **Renamed ALL droids** to use `droidz-` prefix for consistency
  - Original droids: codegen.md → droidz-codegen.md (6 renames)
  - New droids: Already created with droidz- prefix
  - All 14 droids now follow `droidz-*` pattern
  - Benefits: Clear namespace, better organization, professional

### 🚀 Performance Improvements

#### Automatic Progress Monitoring (v2.7.0)
- **Added sleep polling** to orchestrator for automatic progress updates
  - Pattern: `Execute({command: "sleep 30", timeout: 35, riskLevel: "low"})`
  - Monitors file system changes every 30 seconds
  - Reports observable progress automatically (no user prompting needed)
  - Smooth UX: Users see updates without asking "How's it going?"
  - Continuous loop until agents complete

**Before** (manual):
```
🤖 Spawning agents...
[5 minutes of silence]
USER: "How's it going?" ← User must ask
```

**After** (automatic):
```
🤖 Spawning agents... I'll monitor automatically every 30s
⏱️ Progress Update (30s): 🔄 All agents working...
⏱️ Progress Update (1 min): ✅ Agent 1: Created 4 files
⏱️ Progress Update (1.5 min): ✅ Agent 2: Created 3 components
```

### 📊 Coverage Expansion

#### Before v2.7.0: Generic Development (7 droids)
- orchestrator, codegen, test, refactor, infra, integration, generalist

#### After v2.7.0: Full-Stack Expert Team (14 droids)
- ✅ **Frontend**: UI design, UX patterns, accessibility
- ✅ **Backend**: API design, database architecture
- ✅ **Security**: OWASP, penetration testing, compliance
- ✅ **Performance**: Core Web Vitals, optimization
- ✅ **Quality**: Comprehensive testing, refactoring, security audits

### 🔬 Research & Validation

- **Research tools used**: exa-code (AI code context), ref (Factory.ai docs)
- **Patterns analyzed**: 100+ specialized AI agents from production systems
- **Documentation**: Factory.ai official custom droids specification
- **Validation**: 10-category compliance check (see VALIDATION_REPORT.md)
- **Result**: All droids exceed Factory.ai minimum requirements

### 📝 Documentation

#### New Files
- `VALIDATION_REPORT.md` - Comprehensive validation against Factory.ai standards
  - 10-category validation matrix
  - Detailed findings for each droid
  - Research sources and methodology
  - Fixes applied during validation

#### Updated Files
- `install.sh` - Updated DROIDS array with all 14 droidz-* files
- All droid files renamed with droidz- prefix
- All new droids include droidz- prefix in name field

### 💡 Key Features of New Droids

1. **Auto-activation** - Each droid activates automatically based on keywords
2. **Comprehensive prompts** - 500-1000 lines with examples and best practices
3. **Smart tool selection** - Design droids exclude Execute, analysis droids include it
4. **Code examples** - Before/after patterns for every scenario
5. **Industry standards** - OWASP, WCAG, RESTful principles, normalization rules
6. **Research capabilities** - All droids include WebSearch and FetchUrl

### 🎯 Impact

| Metric | Before (v2.6.6) | After (v2.7.0) | Change |
|--------|----------------|---------------|--------|
| Total Droids | 7 | **14** | +100% |
| Specialized Experts | 0 | **7** | +∞ |
| Expert Lines | ~3,000 | **~7,000** | +133% |
| Coverage | Generic | **Full-Stack** | Complete |

### 🔄 Migration Guide

**For new users**: Just run the installer - all 14 droids download automatically

**For existing users**:
```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
# Choose "1) Update" → All droids updated with correct names!
```

**Breaking changes**: None! All existing droids still work. New droids are additions.

### 🙏 Credits

- exa-code: AI-powered code context for research
- Factory.ai: Official custom droids documentation
- lodetomasi/agents-claude-code: 100+ agent pattern analysis

---

## [2.0.2] - 2025-11-10

### Fixed
- **Critical: Custom droid architecture** - Fixed "Invalid tools: Task" error
  - Removed `Task` from orchestrator tools array (it's not a listable tool)
  - Changed orchestrator from delegator to planner role
  - Orchestrator now creates delegation instructions for USER to execute
  - Removed explicit `tools` arrays from specialist droids
  - When `tools` field is undefined, Factory provides ALL tools (Create, Edit, MultiEdit, ApplyPatch, etc.)
  - This works for ALL models: Claude (Sonnet/Opus/Haiku), GPT-5/GPT-5-Codex, GLM-4.6

### Added
- **TOOL_COMPATIBILITY.md** - Comprehensive guide on Factory's tool system
  - Explains tool categories and availability
  - Documents all supported models
  - Provides MCP enhancement options
  - Includes troubleshooting guide
- **SOLUTION_SUMMARY.md** - Executive summary of the tool compatibility fix
  - Problem description and root cause
  - Solution details
  - Testing instructions

### Documentation
- Clarified that ALL Factory models support ALL tools when using Task delegation
- Explained Factory's pattern: undefined `tools` = all tools available
- Added references to official Factory.ai documentation

## [2.2.0] - 2025-11-10

### 🚀 Major Enhancements

#### Runtime Configuration & Performance
- **Added Bun runtime support** - Bun is now the recommended JavaScript runtime (3-10x faster than npm/node)
- **Automatic fallback** - Droidz automatically uses npm/node if Bun is not installed
- **Configurable runtime** - Users can choose between Bun, npm, pnpm, or yarn in config.yml
- **Performance benefits** - Clear documentation of speed improvements with Bun
- **Installation guide** - Step-by-step instructions for all runtime options

#### Secure API Key Management
- **Added Exa and Ref API keys** - config.yml now supports all three services (Linear, Exa, Ref)
- **Security-first approach** - config.yml is now gitignored by default
- **Template system** - config.example.yml serves as safe template to commit
- **Environment variables** - Support for ${VAR} syntax in config files
- **Comprehensive security guide** - New API_KEYS_SETUP.md with emergency procedures

#### Complete Documentation Refactor
- **5-year-old friendly README** - Complete rewrite in simple, accessible language
- **Reduced by 35%** - From 1,230 lines to 808 lines (clearer, more focused)
- **4 clear setup paths** - Different paths for new/existing projects, with/without features
- **Decision tree** - "Which Setup Am I?" section helps users choose the right path
- **Visual structure** - Better use of emojis, headers, and formatting
- **Scenario coverage** - All combinations of Linear/MCP documented

#### Enhanced MCP Setup
- **config.yml method** - Added as recommended approach (easier than Factory CLI)
- **Quick setup guide** - 3-step process to add API keys
- **Security verification** - Instructions to check gitignore status
- **Dual approach** - Both config.yml and Factory CLI methods documented

### 📝 Files Added
- `API_KEYS_SETUP.md` - Comprehensive security guide (288 lines)
  - How to get API keys
  - Security best practices
  - Environment variable setup
  - Team collaboration guide
  - Key rotation procedures
  - Emergency procedures for leaked keys
- `config.example.yml` - Safe template for configuration

### 🔧 Files Updated

#### Core Configuration
- `config.yml` → `config.example.yml` - Renamed and added to git, real config.yml now gitignored
- `.gitignore` - Added config.yml, kept config.example.yml
- `config.example.yml` - Added:
  - Runtime configuration section (Bun/npm/pnpm/yarn)
  - Exa API key configuration
  - Ref API key configuration
  - Clear security warnings

#### Documentation
- `README.md` - Complete refactor (808 lines, was 1,230):
  - Added "Which Setup Am I?" decision tree
  - Added "⚡ Requirements" section for runtimes
  - Created 4 clear setup paths with step-by-step instructions
  - Added runtime installation to all paths
  - Simplified all technical explanations with analogies
  - Added comprehensive troubleshooting (runtime-specific)
  - Added "With vs Without" comparison sections
- `MCP_SETUP.md` - Updated:
  - Added config.yml quick setup method
  - Security verification steps
  - Dual approach (config.yml + Factory CLI)
- `install.sh` - Updated:
  - Downloads config.example.yml
  - Creates config.yml from template
  - Adds config.yml to .gitignore automatically
  - Clear instructions for API keys

### ✨ Impact

**Before this release:**
- No runtime configuration (assumed Bun installed)
- config.yml tracked in git (security risk)
- README was 1,230 lines (overwhelming)
- Only Linear API key supported
- MCP setup only via Factory CLI

**After this release:**
- ✅ Runtime configurable (Bun/npm/pnpm/yarn) with auto-fallback
- ✅ API keys never committed (config.yml gitignored)
- ✅ README 35% shorter and 5-year-old friendly
- ✅ All three API keys supported (Linear, Exa, Ref)
- ✅ MCP setup via config.yml (easier method)
- ✅ Complete security guide included
- ✅ 4 clear paths for all scenarios

### 🎯 Key Benefits

1. **Better Performance**: Bun support provides 3-10x speed improvement
2. **More Secure**: API keys never committed, comprehensive security guide
3. **Easier to Understand**: README refactored for maximum clarity
4. **More Flexible**: Support for all runtimes and all MCP services
5. **Better Onboarding**: Clear decision tree and step-by-step paths

### 🔒 Security Improvements

- config.yml automatically gitignored
- config.example.yml provides safe template
- API_KEYS_SETUP.md guides secure practices
- Emergency procedures for leaked keys
- Team collaboration best practices
- Key rotation documentation

### ⚡ Performance Improvements

- Bun runtime: 3-10x faster script execution
- Clear performance messaging in README
- Automatic detection and fallback
- User choice preserved (can use npm/node)

---

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
- `.factory/orchestrator/config.json` - Added explicit `mode: "worktree"` field
- `.factory/orchestrator/validators.ts` - Added `validateWorkspaceMode()` function
- `.factory/orchestrator/launch.ts` - Added workspace validation call
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
- **MCP Integration** - Linear, Exa, Ref tools automatically available
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
