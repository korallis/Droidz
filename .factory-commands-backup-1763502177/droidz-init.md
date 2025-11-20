---
description: Initialize Droidz framework in your project
argument-hint: "[--quick | --status]"
---

Initialize the Droidz development framework in this project with the following setup:

**Task:** $ARGUMENTS

## Setup Steps

1. **Environment Check:**
   - Verify Git repository exists
   - Check for dependencies: git, jq, tmux, bun
   - Validate disk space for worktrees

2. **Directory Structure:**
   - Create `.factory/memory/` for tech stack and preferences
   - Create `.factory/specs/` for active, archived, and example specs
   - Create `.factory/scripts/` for orchestration
   - Create `.runs/.coordination/` for parallel execution tracking

3. **Tech Stack Detection:**
   - Analyze package.json, requirements.txt, go.mod, etc.
   - Detect frameworks (React, Vue, Next.js, etc.)
   - Identify build tools and test frameworks
   - Save findings to `.factory/memory/org/tech-stack.json`

4. **Create Example Spec:**
   - Generate a sample feature spec in `.factory/specs/examples/`
   - Show proper spec format and task breakdown
   - Demonstrate orchestration workflow

5. **Validation:**
   - Test orchestrator script exists
   - Verify tmux and git worktree support
   - Check all droids are enabled

## Options

- `--quick`: Skip questions, use sensible defaults
- `--status`: Check current Droidz setup status without changes
- (no args): Interactive mode with customization questions

After setup, show available commands and next steps for using Droidz.
