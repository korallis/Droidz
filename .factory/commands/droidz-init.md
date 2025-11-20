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
   - Verify Factory.ai CLI is installed (`droid --version`)

2. **Directory Structure:**
   - Create `.factory/memory/` for tech stack and preferences
   - Create `.factory/specs/` for active, archived, and example specs
   - Create `.factory/scripts/` for orchestration
   - Create `.runs/.coordination/` for parallel execution tracking

3. **Factory.ai Compatibility:**
   - Check for custom droids in `.factory/droids/`
   - Apply symlink workaround: `bash .factory/scripts/apply-droid-workaround.sh`
   - This creates `.json → .md` symlinks to work around Factory.ai CLI bug
   - Automatically adds `.gitignore` to exclude symlinks from git
   - Report how many symlinks were created
   - Validate droids are accessible to Factory.ai

4. **Tech Stack Detection:**
   - Analyze package.json, requirements.txt, go.mod, etc.
   - Detect frameworks (React, Vue, Next.js, etc.)
   - Identify build tools and test frameworks
   - Save findings to `.factory/memory/org/tech-stack.json`

5. **Create Example Spec:**
   - Generate a sample feature spec in `.factory/specs/examples/`
   - Show proper spec format and task breakdown
   - Demonstrate orchestration workflow

6. **Validation:**
   - Test orchestrator script exists
   - Verify tmux and git worktree support
   - Check all droids are enabled

## Options

- `--quick`: Skip questions, use sensible defaults
- `--status`: Check current Droidz setup status without changes
- (no args): Interactive mode with customization questions

## Expected Output

After successful initialization, display:

```
✅ Droidz Framework Initialized!

📦 Directory Structure: Created
🔧 Factory.ai Compatibility: Applied workaround (N symlinks created)
🔍 Tech Stack Detected: [frameworks found]
📋 Example Spec: Created in .factory/specs/examples/
✓ Validation: All systems ready

🚀 Next Steps:
1. Review tech stack detection: .factory/memory/org/tech-stack.json
2. Check example spec: .factory/specs/examples/
3. Try: /droidz-build "your feature idea"
4. Or use: /auto-parallel "build authentication system"

💡 Parallel Execution Ready!
   Factory.ai bug workaround applied automatically.
   Your droids are ready for parallel execution.
```

**Important Notes:**
- The symlink workaround is transparent and automatic
- It works around a Factory.ai CLI bug (looks for .json instead of .md)
- Symlinks are git-ignored by default
- Remove symlinks with: `rm .factory/droids/*.json` (when bug is fixed)
