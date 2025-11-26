# Changelog

All notable changes to Droidz Framework will be documented in this file.

## [4.11.1] - 2025-11-26

### Fixed
- **CRITICAL**: Claude Code `/implement-tasks` parallel execution now uses correct method
  - Was incorrectly using `droid exec` (Factory CLI method) in Claude Code
  - Now uses native Claude Code Task tool with multiple parallel subagent invocations
  - Spawns the **assigned specialists from orchestration.yml**, not generic agents

### Changed
- **Claude Code implement-tasks.md** - Option A (Parallel Execution) completely rewritten:
  - Requires `/orchestrate-tasks` to be run first to assign specialists
  - Reads `orchestration.yml` to get `assigned_specialist` for each task group
  - Verifies specialists exist in `.claude/agents/`
  - Spawns all specialists in a SINGLE message for true parallelism
  - Includes proper standards resolution from orchestration.yml
  - Clear error messages if orchestration.yml or specialists are missing

- **Droid CLI implement-tasks.md** - Unchanged (still uses `droid exec` with Factory API)

### Technical Details

**Claude Code Parallel Execution Flow**:
```
1. Check orchestration.yml exists
2. Read assigned_specialist for each task group
3. Verify each specialist exists in .claude/agents/
4. Build prompts with resolved standards
5. Spawn ALL specialists in ONE message (critical for parallelism)
6. Aggregate results and show summary
```

**Example orchestration.yml**:
```yaml
task_groups:
  - name: authentication-system
    assigned_specialist: backend-specialist
  - name: user-dashboard
    assigned_specialist: frontend-specialist
```

**Results in**:
```
[Single message spawning 2 specialists in parallel]
├── backend-specialist → authentication-system
└── frontend-specialist → user-dashboard
```

### Impact
- ✅ Claude Code users get proper native parallel execution
- ✅ Factory/Droid CLI users unaffected (still use `droid exec`)
- ✅ Specialists from `/orchestrate-tasks` are properly utilized
- ✅ No more confusion about which parallel method to use per platform

---

## [4.1.0] - 2025-11-24

### 🔥 CRITICAL FIX - Directory Structure

**This is a breaking fix that resolves complete installation failures.**

#### Fixed
- **CRITICAL**: Changed from nested to flat directory structure to comply with Factory.ai and Claude Code requirements
  - Factory.ai documentation explicitly states: "**top-level files only**" - "**nested folders are ignored**"
  - Previous versions created `.factory/droids/droidz/*.md` which were completely ignored
  - Now correctly creates `.factory/droids/*.md` (flat structure)
  - Same fix applied to all platforms: commands, agents, workflows, prompts, playbooks

#### Changed
- Updated installer to create flat directory structure (removed `/droidz/` nesting)
- Updated README.md to reflect correct directory paths
- Added inline documentation in installer referencing official platform requirements
- Updated all success messages to show correct paths without `/droidz/` subdirectory

#### Impact
- **Users must reinstall** - Previous installations created directories that platforms cannot discover
- All custom droids, commands, and agents will now be properly discovered by Factory.ai CLI
- No more "file not found" or "no custom droids available" errors

#### References
- Factory.ai docs: https://docs.factory.ai/cli/configuration/custom-droids
- Claude Code docs: https://docs.claude.com/en/docs/claude-code/sub-agents#file-locations
- Related issue: bmad-code-org/BMAD-METHOD#788

---

## [4.0.2] - 2025-11-23

### Changed
- Replaced YAML manifest with JSON file
- Removed PyYAML dependency for better compatibility
- Updated CLI, installer core, and unit tests to read JSON manifests

---

## Earlier Versions

See git tags and releases for version history prior to v4.0.2.

## [4.2.0] - 2024-11-24

### Added
- **50 Comprehensive Skills** - Complete skills library for software development
  - Core Development (20 skills): TDD, debugging, code review, git, refactoring, performance, security, API design, database, frontend, backend, E2E testing, CI/CD, documentation, error handling, accessibility, standards, migrations, monitoring, incidents
  - Framework-Specific (10 skills): Next.js App Router, Server Components, NeonDB serverless, Convex backend/realtime, Shadcn UI, Tailwind, Server Actions, TypeScript strict, Vercel deployment
  - Developer Tools (10 skills): MCP builder, artifacts, Playwright, root-cause tracing, brainstorming, changelog generator, content research, document processing (DOCX/PDF/XLSX)
  - Productivity (10 skills): File organizer, invoice organizer, domain brainstormer, competitive research, brand guidelines, canvas design, meeting insights, kaizen, threat hunting, skill creator

- Research-backed content from:
  - Composio awesome-claude-skills repository
  - Next.js 15 best practices
  - NeonDB serverless patterns
  - Convex realtime database patterns
  - OWASP security guidelines

### Changed
- Updated SKILLS.md with complete 50-skill catalog
- Skills automatically deployed to both Factory.ai and Claude Code

### Technical
- Skills installed to `.factory/skills/` and `.claude/skills/`
- Flat directory structure for platform compatibility
- Each skill includes practical examples and resources

### Impact
- Developers get instant access to 50 production-ready skills
- Skills activate automatically based on context
- Improves code quality, security, and development velocity

## [4.2.1] - 2024-11-24

### Changed
- Updated README.md with v4.2.0 skills library highlights
- Added quick start guide and skills overview

### Verified
- ✅ Zero agent-os references (completely removed)
- ✅ Installer correctly handles 50 skills
- ✅ Skills deployed to both Factory.ai (.factory/skills) and Claude Code (.claude/skills)
- ✅ All payload structures verified

### Technical
- No code changes, documentation update only
- Installer v4.2.1 is functionally identical to v4.2.0

## [4.2.2] - 2024-11-24

### Fixed
- **CRITICAL**: Removed invalid tool specifications from all agents/droids
  - Removed `tools: Write, Bash, WebFetch` (invalid tool names)
  - Agents/droids now inherit ALL tools from parent system
  - Fixes error: "Invalid tools: Write, Bash, WebFetch. Available tools: Read, LS, Execute, Edit..."

### Changed
- Agents/droids are now more flexible - they inherit all available tools instead of being restricted to a subset
- Works correctly with both Factory.ai and Claude Code tool sets

### Impact
- ✅ Agents will no longer error on initialization
- ✅ More tools available to agents (inherits full tool set)
- ✅ Better compatibility across platforms

### Files Fixed
- `claude/default/agents/*.md` (8 files)
- `droid_cli/default/droids/*.md` (8 files)

## [4.2.3] - 2024-11-24

### Fixed
- **CRITICAL**: Added required YAML frontmatter to all 50 skills
  - Skills were missing `name:` and `description:` in YAML frontmatter
  - Only test-driven-development showed up in Factory Droid CLI `/skills` command
  - Other 49 skills were invisible and unusable

### Changed
- All 100 skill files now have proper frontmatter (50 in each platform)
- Format: `---\nname: skill-name\ndescription: ...\n---`
- Skills now properly discovered by both Factory.ai and Claude Code

### Impact
- ✅ All 50 skills now visible in `/skills` command (Factory Droid CLI)
- ✅ All 50 skills now discoverable in Claude Code
- ✅ Skills can be edited and used properly
- ✅ Better activation - AI understands when to use each skill

### Technical
According to Factory.ai docs, skills MUST have YAML frontmatter:
```yaml
---
name: skill-name
description: Description of what skill does and when to use it
---
```

Without this, Factory CLI ignores the skill file completely.

### Files Modified
- `claude/default/skills/*/SKILL.md` (49 files updated, 1 already correct)
- `droid_cli/default/skills/*/SKILL.md` (49 files updated, 1 already correct)

## [4.9.0] - 2024-11-24

### Added
- **Comprehensive README Rewrite**: Complete documentation overhaul (554 → 1,219 lines)
  - Detailed command reference for all 8 commands
  - Complete agent documentation
  - Best practices (8 DOs + 8 DON'Ts with examples)
  - 3 real-world usage examples
  - Enhanced troubleshooting guide
  - Table of contents for easy navigation
  - Clear value proposition and "Why Droidz?" section

### Changed
- **orchestrate-tasks**: Made platform-agnostic
  - Changed "Claude Code subagent" → "specialist"
  - Changed YAML key `claude_code_subagent` → `assigned_specialist`
  - Now works correctly across all platforms (Factory, Claude, Cursor, etc.)

### Documentation Details

**Commands Now Documented**:
- /standards-shaper (marked as starting point)
- /plan-product
- /shape-spec
- /write-spec
- /create-tasks
- /orchestrate-tasks
- /implement-tasks
- /improve-skills

**Each Command Includes**:
- Purpose and when to use
- What it does (step-by-step)
- Output files created
- Real conversation examples

**All 8 Agents Documented**:
- product-planner
- spec-shaper
- spec-writer
- spec-verifier
- spec-initializer
- tasks-list-creator
- implementer
- implementation-verifier

**Examples Added**:
1. Building real-time notifications feature (complete walkthrough)
2. Onboarding new team member (day 1 productivity)
3. Creating standards mid-project (existing codebase)

## [4.8.1] - 2024-11-24

### Fixed
- **CRITICAL**: Fixed all droids and commands referencing non-existent workflow files
  - All 8 droids now have complete inline workflow instructions
  - Removed 38 broken template references across 16 droid files and 22 command files
  - Droids work immediately after installation without missing dependencies
  - Fixed: tasks-list-creator, spec-writer, product-planner, implementer, spec-shaper, spec-initializer, spec-verifier, implementation-verifier
  - No more "file not found" errors when using custom droids

### Technical Details

**Root Cause**: Droids referenced `{{workflows/...}}` files that didn't exist. The installer copied files as-is without processing templates, causing all droids to fail.

**Solution**: Inlined complete workflow instructions directly into each droid file, removing dependency on external workflow files.

**Files Fixed**:
- 16 droid files (8 droids × 2 platforms)
- 22 command files (11 commands × 2 platforms)
- Total: 38 files with broken references resolved

**Verification**: 0 broken template references remaining

## [4.8.0] - 2024-11-24

### Changed
- **All 50 Skills Thoroughly Optimized**: Applied comprehensive optimization to every skill in the library
  - Comprehensive, activation-oriented descriptions (200-400+ characters each)
  - Detailed "When to use this skill" sections with 12+ specific examples per skill
  - Consistent structure following skill-creator patterns throughout
  - No maximum length constraints - descriptions are as thorough as needed
  - Significantly improved discoverability and activation criteria

### Enhanced
- **Skill Descriptions**: All descriptions now include:
  - Clear statement of what the skill does
  - Multiple specific use cases and situations
  - File types, tools, and contexts where applicable
  - Action-oriented language for better activation
  
- **When to Use Sections**: Every skill now has:
  - 4-5 specific activation examples
  - Clear triggers for skill usage
  - Context about when to apply expertise

### Technical Details

**Optimization Applied**:
- Analyzed each skill's content and purpose
- Rewrote descriptions following improve-skills guidelines
- Added comprehensive "When to use" sections
- Applied skill-creator structure templates
- Ensured consistent format across all 50 skills

**Example Improvements**:

Before:
```yaml
description: E2E testing, browser automation, web scraping.

## When to use this skill
- E2E testing, browser automation, web scraping.
- When working on related tasks or features
- During development that requires this expertise
```

After:
```yaml
description: Automate browser testing, web scraping, and user workflow testing with Playwright across multiple browsers. Use when writing end-to-end tests for web applications, automating repetitive browser tasks, scraping data from websites, testing across Chrome/Firefox/Safari, taking screenshots for visual regression testing, testing authentication flows, filling and submitting forms programmatically, testing responsive designs across viewports, or any browser automation requiring reliable, cross-browser testing capabilities.

## When to use this skill
- Writing end-to-end tests for web applications
- Automating repetitive browser tasks and workflows
- Scraping data from websites programmatically
- Testing across Chrome, Firefox, Safari, and Edge browsers
- Taking screenshots for visual regression testing
- Testing authentication and login flows
- Filling and submitting forms automatically
- Testing responsive designs across different viewports
- Simulating user interactions (clicks, typing, navigation)
- Testing file uploads and downloads
- Capturing network requests and responses
- Testing Single Page Applications (SPAs)
- Any browser automation requiring reliable cross-browser support
```

### Impact
- ✅ All 50 skills now optimized for discoverability
- ✅ Consistent, professional quality across skill library
- ✅ Better activation based on detailed descriptions
- ✅ Comprehensive examples for each skill
- ✅ Both Factory Droid CLI and Claude Code versions updated

### Skills Improved (50 total)

**Core Development** (20):
- test-driven-development, code-review, debugging-systematic
- git-workflow, refactoring, performance-optimization
- security-patterns, api-design, database-design
- frontend-component-patterns, backend-service-patterns
- e2e-testing, ci-cd-pipeline, documentation-generation
- error-handling-patterns, accessibility-wcag
- standards-enforcement, data-migration
- monitoring-observability, incident-response

**Framework-Specific** (10):
- nextjs-app-router, nextjs-server-components
- neondb-serverless, convex-backend, convex-realtime
- shadcn-ui-components, tailwind-design-system
- react-server-actions, typescript-strict, vercel-deployment

**Developer Tools** (10):
- mcp-builder, artifacts-builder, playwright-automation
- root-cause-tracing, brainstorming, changelog-generator
- content-research-writer, document-processing-docx
- document-processing-pdf, document-processing-xlsx

**Productivity** (10):
- file-organizer, invoice-organizer
- domain-name-brainstormer, competitive-research
- brand-guidelines, canvas-design
- meeting-insights-analyzer
- kaizen-continuous-improvement
- threat-hunting, skill-creator

## [4.7.1] - 2024-11-24

### Enhanced
- **improve-skills now uses skill-creator skill**: Command leverages skill-creator for better quality
  - skill-creator provides templates, structure guidance, and best practices
  - Automatically activated when improving skills
  - Ensures consistent skill format across all improvements
  - Better activation criteria and examples

### Changed
- `/improve-skills` command now references skill-creator throughout the process
- Added guidance to use skill-creator's templates and patterns
- Updated final message to mention skill-creator was used

### Impact
- ✅ Higher quality skill improvements
- ✅ Consistent skill structure
- ✅ Leverages existing skill-creator skill
- ✅ Better use of Droidz ecosystem

## [4.7.0] - 2024-11-24

### Changed
- **standards-shaper Updates Existing Standards**: Command now intelligently updates existing standards based on project
  - Detects tech stack and updates examples in existing standard files
  - Replaces generic examples with project-specific patterns
  - Preserves structure while updating content to match your frameworks
  - Example: Updates `api.md` from generic REST to your Express+TypeScript+Prisma patterns
  
### Enhanced
- **/standards-shaper command** now has two modes:
  - **Create mode**: Generates new standards from scratch (if no standards exist)
  - **Update mode**: Updates existing standards to match current project (if standards found)
  
### Technical Details

**Update Mode Behavior**:
```
1. Check for existing standards
2. Read each standard file
3. Detect project tech stack (React, Next.js, Express, Prisma, etc.)
4. Update examples in standards to match detected stack
5. Add project-specific patterns from codebase analysis
6. Preserve user customizations
```

**Example Update**:
```markdown
Before (generic in backend/api.md):
app.get('/users/:id', async (req, res) => {
  // Generic example
})

After (project-specific with detected Express + TypeScript + Prisma):
app.get('/api/v1/users/:id', async (req: Request, res: Response) => {
  const user = await prisma.user.findUnique({
    where: { id: req.params.id }
  });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});
```

**What Gets Updated**:
- `error-handling.md` - Updated with project's try-catch patterns
- `testing.md` - Updated with detected test framework (Jest/Vitest/etc)
- `components.md` - Updated with React/Vue/Angular version-specific patterns
- `styling.md` - Updated with Tailwind/CSS-in-JS/etc found in project
- `state-management.md` - Updated with Redux/Zustand/Pinia/etc patterns
- `api-design.md` - Updated with Express/FastAPI/etc patterns
- `database.md` - Updated with PostgreSQL/MongoDB/Prisma/etc examples
- `authentication.md` - Updated with NextAuth/Passport/etc patterns

### Impact
- ✅ Standards now stay synchronized with project tech stack
- ✅ Examples in standards match actual frameworks used
- ✅ No more generic "best practices" - project-specific guidance
- ✅ Standards evolve as project evolves
- ✅ Can re-run `/standards-shaper` to update standards when upgrading frameworks

### User Experience

**Before v4.7.0**:
```
> /standards-shaper
AI: Creates generic standards
Result: backend/api.md has generic Express examples (but you use Fastify!)
```

**After v4.7.0**:
```
> /standards-shaper
AI: Detected existing standards, updating...
AI: Found Fastify + TypeScript + PostgreSQL
AI: Updating api.md with Fastify patterns...

Result: backend/api.md now has Fastify-specific examples matching your project!
```

**Output Shows Changes**:
```
✅ Updated api-design.md - Changed from Express to Fastify patterns
✅ Updated database.md - Changed from generic SQL to PostgreSQL + node-postgres
✅ Updated components.md - Changed from React 17 to React 18 patterns
✅ Updated styling.md - Changed from CSS Modules to Tailwind CSS v4
```

## [4.6.0] - 2024-11-24

### Added
- **TodoWrite Progress Tracking**: Factory Droid CLI agents now show real-time progress
  - Added to 5 core droids: product-planner, spec-shaper, spec-writer, tasks-list-creator, implementer
  - Subagents use TodoWrite to update their progress in the main session
  - Users can now see what subagents are doing (previously invisible)
  - Critical for long-running tasks like spec writing or implementation

### Changed
- **Factory Droid CLI only** - Claude Code agents unchanged (avoid platform conflicts)
- Each agent includes "Progress Tracking (CRITICAL)" section with TodoWrite pattern
- Pattern: Create todos at start → Update as work progresses → Mark complete when done

### Technical Details

**TodoWrite Pattern Added**:
```javascript
// At start
TodoWrite({
  todos: [
    { id: "step1", content: "Task description", status: "in_progress", priority: "high" },
    { id: "step2", content: "Next task", status: "pending", priority: "medium" }
  ]
});

// Update as work progresses
TodoWrite({
  todos: [
    { id: "step1", content: "Task description", status: "completed", priority: "high" },
    { id: "step2", content: "Next task (3/8 complete)", status: "in_progress", priority: "medium" }
  ]
});
```

**Why This Works**:
- TodoWrite updates are session-wide (visible in main session)
- Factory.ai displays todos in real-time UI
- No breaking changes - adds visibility without changing functionality
- Works within Factory's existing architecture

### Impact
- ✅ Subagent work now visible in main session
- ✅ Users see real-time progress during long operations
- ✅ No more "check on subagent" confusion
- ✅ Better user experience for multi-agent workflows
- ✅ Especially helpful for spec-writer (can take minutes to complete)

### User Experience

**Before v4.6.0**:
```
> /write-spec
AI: The spec-writer subagent is creating your specification...
[Long wait with no feedback]
[User types: "check on the sub agent"]
AI: Let me check... [reads files to see progress]
```

**After v4.6.0**:
```
> /write-spec  
AI: The spec-writer subagent is creating your specification...

Real-time updates visible:
✅ Reading requirements (92 Q&A processed) 
✅ Analyzing questions and decisions
✅ Structuring specification (12 sections)
🔄 Writing specification (section 7/12)
⏸️ Validating completeness
```

### Platform Differences

**Factory Droid CLI** (v4.6.0):
- ✅ Progress tracking with TodoWrite
- ✅ Real-time subagent visibility
- ✅ Better UX for long operations

**Claude Code** (unchanged):
- Maintains existing behavior
- No TodoWrite tracking
- Avoids potential conflicts

## [4.5.0] - 2024-11-24

### Added
- **MCP Research Integration**: All agents/droids now include optional MCP tool usage
  - Added research instructions to 5 core agents/droids:
    - `product-planner` - Research similar products, tech stacks, market trends
    - `spec-shaper` - Research technical patterns, architecture approaches
    - `spec-writer` - Research API design, database patterns, security
    - `tasks-list-creator` - Research implementation approaches, dependencies
    - `implementer` - Research code examples, solutions, patterns
  - Instructions are graceful: work continues without MCPs if unavailable
  - Enhances quality when Exa/Ref MCPs are installed

### Changed
- Agents now automatically leverage Exa and Ref MCPs when available
- Research is optional - no errors if MCPs not installed
- Clear "Usage Pattern" guidance in each agent

### Technical Details

**Research Tools Section Added**:
- Lists what each tool is good for (Exa for patterns, Ref for docs)
- Specific research topics relevant to agent's role
- Clear usage pattern: Try → If unavailable → Continue

**Example Pattern**:
```markdown
## Research Tools (Use When Available)

**Exa Code Context** - For researching:
- [Relevant research topics]

**Ref Documentation** - For referencing:
- [Relevant documentation]

**Usage Pattern**:
Try: [Research action]
If unavailable: Continue with general knowledge
```

### Impact
- ✅ Agents leverage MCPs automatically if installed
- ✅ No errors or failures if MCPs unavailable
- ✅ Better quality outputs when research tools available
- ✅ Research-backed recommendations and patterns
- ✅ Consistent behavior across all platforms

### Benefits

**With Exa/Ref MCPs Installed**:
- Product planning uses market research and competitor analysis
- Spec shaping references current best practices
- Spec writing includes framework-specific patterns
- Task breakdown informed by implementation approaches
- Implementation uses proven code examples

**Without MCPs**:
- All agents continue working normally
- Uses general knowledge and best practices
- No degradation in core functionality

## [4.4.1] - 2024-11-24

### Fixed
- **CRITICAL**: `/improve-skills` command in Factory Droid CLI now checks correct directory
  - Was checking `.claude/skills/` (wrong)
  - Now checks `.factory/skills/` (correct)
  - Updated all user-facing messages to be platform-neutral
  - Claude Code version unchanged (already correct)

### Impact
- ✅ Factory Droid CLI users can now use `/improve-skills`
- ✅ Command works correctly in both platforms
- ✅ Each platform checks its own skills directory

## [4.4.0] - 2024-11-24

### Added
- **NEW COMMAND**: `/standards-shaper` - Creates comprehensive project standards with dos and don'ts
  - Uses all available tools (Read, Write, Grep, Glob, Execute)
  - Integrates with Exa code context and Ref documentation (when available)
  - Gracefully handles missing MCP tools
  - Auto-detects tech stack from project files
  - Generates research-backed standards with concrete examples
  - Creates organized structure: global/, frontend/, backend/, infrastructure/
  - Each standard includes: core principles, DO/DON'T examples, patterns, common mistakes
  
- **Workflow Documentation**: `RECOMMENDED_WORKFLOW.md` in shared standards
  - Complete phase-by-phase development guide
  - Real-world examples and best practices
  - Command quick reference
  - Advanced patterns for teams
  - Integration with CI/CD guidance

### Changed
- Updated workflow to include Phase 0: Setup Standards (using `/standards-shaper`)
- Standards now central to entire development process
- All commands now reference standards workflow

### Impact
- ✅ Projects start with clear, comprehensive standards
- ✅ AI assistants have structured preferences to follow
- ✅ Standards automatically integrated with orchestration
- ✅ Research-backed best practices from day one
- ✅ Consistent code quality across all features

## [4.3.0] - 2024-11-24

### Fixed
- **MAJOR**: Reformatted all 100 skills to match official Claude Skills specification
  - Skills now follow proper structure from Claude Skills Deep Dive blog post
  - Clean YAML frontmatter with action-oriented descriptions
  - Proper heading hierarchy and content organization
  - Imperative language throughout ("Use when..." not "You should...")

### Changed  
- All skill files now have consistent, specification-compliant format
- Better skill descriptions that help Claude understand when to activate
- Improved progressive disclosure (core info first, details follow)

### Impact
- ✅ Skills properly discovered and activated by AI systems
- ✅ Claude better understands skill activation criteria
- ✅ Follows official Claude Skills prompt-based architecture
- ✅ Better context injection and modification
- ✅ Compliance with Factory.ai and Claude Code skill standards

### Technical
Skills now follow this structure:
```yaml
---
name: skill-name
description: Clear, action-oriented description
---

# Title

Overview → Instructions → Examples → Resources
```

Based on:
- https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/
- https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices

### Files Modified
- All 50 skills in `claude/default/skills/*/SKILL.md`
- All 50 skills in `droid_cli/default/skills/*/SKILL.md`
