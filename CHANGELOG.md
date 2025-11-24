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
