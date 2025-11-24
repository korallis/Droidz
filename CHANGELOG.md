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
