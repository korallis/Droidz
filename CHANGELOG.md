# Changelog

All notable changes to Droidz Framework will be documented in this file.

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
