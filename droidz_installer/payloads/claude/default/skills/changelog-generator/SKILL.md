---
name: changelog-generator
description: Generating changelogs from git commits.
---

# Changelog Generator - Automated Release Notes

**Use when**: Generating changelogs from git commits.

## Pattern
\`\`\`bash
git log --oneline --pretty=format:"- %s" v1.0.0..HEAD
\`\`\`

## Resources
- [Keep a Changelog](https://keepachangelog.com/)
