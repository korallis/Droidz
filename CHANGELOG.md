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
