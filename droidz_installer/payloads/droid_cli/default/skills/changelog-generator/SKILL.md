---
name: changelog-generator
description: Generate comprehensive changelogs from Git history, commit messages, pull requests, and issue tracking for release documentation. Use when preparing releases, documenting changes, creating release notes, categorizing commits, generating version summaries, maintaining project history, or automating changelog updates.
---

# Changelog Generator - Automated Release Notes

## When to use this skill

- Preparing software releases
- Documenting changes between versions
- Creating release notes from commits
- Categorizing changes (features, fixes, breaking)
- Generating version summaries
- Maintaining project changelog files
- Automating changelog updates in CI
- Creating GitHub release notes
- Tracking breaking changes
- Communicating changes to users
- Following Conventional Commits standard
- Building release announcement content

## When to use this skill

- Generating changelogs from git commits.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Generating changelogs from git commits.

## Pattern
\`\`\`bash
git log --oneline --pretty=format:"- %s" v1.0.0..HEAD
\`\`\`

## Resources
- [Keep a Changelog](https://keepachangelog.com/)
