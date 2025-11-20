# Changelog

All notable changes to Droidz will be documented in this file.

## [2.7.0] - 2025-11-20

### 🚀 Major Enhancements

#### New Specialized Skills (4 Added - 61 Total)
- **graphql-api-design** - Complete GraphQL API development
  - Schema design with type-safe patterns
  - Apollo Server implementation
  - Resolver patterns with DataLoader for N+1 prevention
  - Cursor-based pagination
  - Input validation with Zod
  - Authentication and error handling
  - Client usage examples with @apollo/client

- **websocket-realtime** - Real-time bidirectional communication
  - Socket.io server setup with authentication
  - Native WebSocket implementation
  - Server-Sent Events (SSE) for streaming
  - Real-time chat, presence system, typing indicators
  - Reconnection strategies with exponential backoff
  - Rate limiting and message acknowledgment
  - Redis adapter for multi-server scaling

- **monitoring-observability** - Production-grade monitoring
  - Prometheus metrics collection (Counter, Histogram, Gauge)
  - Structured logging with Pino
  - Distributed tracing with OpenTelemetry
  - Grafana dashboard configuration
  - Alert rules for critical events
  - Health check endpoints
  - ELK stack integration for log aggregation

- **load-testing** - Performance validation and stress testing
  - k6 load test scripts with configurable stages
  - Artillery YAML configuration
  - Multiple test scenarios (smoke, load, stress, spike, soak)
  - GraphQL load testing support
  - Custom metrics and thresholds
  - CI/CD integration (GitHub Actions)
  - Performance benchmarking and analysis

#### Installer Improvements
- **Updated skill list** - Added 16 missing skills to installer
  - graphql-api-design, websocket-realtime, monitoring-observability, load-testing
  - api-documentation-generator, changelog-generator, ci-cd-pipelines
  - code-review-checklist, docker-containerization, environment-management
  - git-commit-messages, performance-profiler, pr-description-generator
  - readme-generator, security-audit-checklist, unit-test-generator
- **Fixed skill count** - Installer now downloads all 61 skills correctly
- **Improved consistency** - Standardized skill download patterns

### 📊 Statistics
- **Total Skills:** 61 (was 45)
- **New Code Examples:** 51 working examples across 4 skills
- **Documentation Growth:** +2,530 lines (+110 KB)
- **Installer Updates:** +16 skills in download list

### 📝 Files Added
- `.factory/skills/graphql-api-design/SKILL.md` - 650 lines, 28 KB
- `.factory/skills/websocket-realtime/SKILL.md` - 680 lines, 30 KB
- `.factory/skills/monitoring-observability/SKILL.md` - 620 lines, 27 KB
- `.factory/skills/load-testing/SKILL.md` - 580 lines, 25 KB
- `docs/INSTALLER_AUDIT.md` - Comprehensive audit of both installers
- `docs/NEW_SKILLS_SUMMARY.md` - Summary of 4 new skills

### 🔧 Files Updated
- `install.sh` - Version 2.7.0
  - Updated SKILL_NAMES array with 16 missing skills
  - Now downloads all 61 skills correctly
  - Improved skill discovery and download logic
- `CHANGELOG.md` - Added this release

### 🎯 Skill Coverage Improvements

**Backend Development:**
- ✅ REST APIs (api-documentation-generator)
- ✅ GraphQL APIs (graphql-api-design) **NEW**
- ✅ Real-time features (websocket-realtime) **NEW**
- ✅ Database design (droidz-database-architect)

**DevOps & Infrastructure:**
- ✅ Monitoring & observability (monitoring-observability) **NEW**
- ✅ Load testing (load-testing) **NEW**
- ✅ Docker containerization (docker-containerization)
- ✅ CI/CD pipelines (ci-cd-pipelines)

**Testing:**
- ✅ Unit tests (unit-test-generator)
- ✅ Integration tests (test-driven-development)
- ✅ Load tests (load-testing) **NEW**
- ✅ Performance validation

**Documentation:**
- ✅ API docs (api-documentation-generator)
- ✅ README generation (readme-generator)
- ✅ Changelog generation (changelog-generator)
- ✅ PR descriptions (pr-description-generator)

### 🔍 Audit Findings
- **Code Duplication:** Identified 21% overlap between installers (~450 lines)
- **Missing Skills:** Found and added 16 skills that weren't in installer
- **Consistency Issues:** Fixed skill filename standardization
- **Recommendations:** Documented in INSTALLER_AUDIT.md for future improvements

### 🌟 Impact
With these additions, Droidz now provides complete coverage for:
- Modern API development (REST + GraphQL)
- Real-time features (WebSocket + SSE)
- Production monitoring and observability
- Performance testing and validation
- Full-stack development from dev to production

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
