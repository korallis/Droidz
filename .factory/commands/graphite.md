---
description: Guide for Graphite stacked diffs workflow. Helps create, manage, and submit stacks of pull requests using Graphite CLI. Use when breaking large work into reviewable chunks or working on dependent features.
argument-hint: [command] - setup | create | modify | submit | sync | help
allowed-tools: Read, Bash, Edit, Grep, Glob, TodoWrite
---

# /graphite - Graphite Stacked Diffs Workflow

Complete guide for using Graphite CLI to create and manage stacked pull requests.

## When to Use Graphite Stacking

### ✅ Use Graphite Stacking When:
- Large feature can be broken into smaller, reviewable chunks
- Multiple dependent changes that build on each other
- Want to stay unblocked while waiting for reviews
- Need to create logical progression of changes
- Working on feature that touches multiple areas
- Want to submit work incrementally for faster reviews

### ❌ Don't Use Stacking When:
- Single, simple change (regular PR is fine)
- Independent changes (can be separate PRs)
- Hotfix or emergency patch (unless complex)
- Changes that can't be broken down logically

## Core Concepts

### What is a Stack?
A **stack** is a sequence of pull requests, each building off its parent. Stacks enable:
- Breaking large work into small, incremental changes
- Each PR can be tested, reviewed, and merged independently
- Stay unblocked by continuing work while waiting for reviews
- Easier code review with smaller, focused diffs

### The Graphite CLI (`gt`)
- Simplifies git commands (especially rebasing)
- Enables PR stacking as first-class concept
- Automatically handles upstack/downstack sync
- Integrates with GitHub for PR management

## Usage

```bash
# First-time setup
/graphite setup

# Create a new PR in stack
/graphite create

# Modify current PR
/graphite modify

# Submit PR to GitHub
/graphite submit

# Sync stack with trunk
/graphite sync

# Show help for all commands
/graphite help
```

## Complete Workflow

### Phase 1: Initial Setup (First Time Only)

```bash
# Install Graphite CLI
npm install -g @withgraphite/graphite-cli@stable
# or
brew install --cask graphite

# Authenticate with Graphite
gt auth
# Follow the link to get token from: https://app.graphite.dev/activate

# Initialize Graphite in repository
gt init
# Select your trunk branch (usually 'main' or 'master')
```

### Phase 2: Creating Your First PR in a Stack

```bash
# 1. Start from trunk
gt checkout main

# 2. Make your changes
# ... edit files ...

# 3. Create branch and commit in one command
gt create --all \
  --message "feat(api): Add user authentication endpoint"

# Alternative: Use AI to generate branch name and message
gt create --all --ai

# 4. Submit to create PR
gt submit

# 5. If you need follow-up changes
# ... edit files ...
gt modify --all  # Amends the existing commit
gt submit        # Updates the PR
```

**Key Commands:**
- `gt create -am "message"` - Create branch + commit staged changes
- `gt modify -a` - Amend existing commit with new changes
- `gt submit` - Push and create/update PR

### Phase 3: Building Upstack (Adding More PRs)

```bash
# After creating first PR, add more PRs that build on it

# 1. Make next set of changes
# ... edit files ...

# 2. Create another PR upstack
gt create --all \
  --message "feat(api): Add JWT token generation"

# 3. Submit the new PR
gt submit

# 4. Continue building upstack
# ... edit files ...
gt create -am "feat(api): Add token validation middleware"
gt submit

# Now you have a stack:
# ┌─────────────────────────────────────┐
# │  PR #3: Token validation middleware │ ← top of stack
# ├─────────────────────────────────────┤
# │  PR #2: JWT token generation        │
# ├─────────────────────────────────────┤
# │  PR #1: User authentication endpoint│
# ├─────────────────────────────────────┤
# │  main (trunk)                       │
# └─────────────────────────────────────┘
```

### Phase 4: Managing Your Stack

```bash
# Navigate between PRs in stack
gt up      # Move up one level in stack
gt down    # Move down one level
gt top     # Jump to top of stack
gt bottom  # Jump to bottom of stack

# View your stack
gt stack
# Shows: visualization of all PRs in current stack

gt log
# Shows: commit history with branch structure

# Make changes to PR in middle of stack
gt checkout PR-branch-name
# ... edit files ...
gt modify -a
gt submit

# Sync changes upstack
gt upstack onto
# Updates all PRs above current one to include your changes
```

### Phase 5: Responding to Review Feedback

```bash
# If reviewer requests changes on PR #2 (middle of stack):

# 1. Navigate to that PR
gt checkout pr-2-branch

# 2. Make requested changes
# ... edit files ...

# 3. Amend the commit
gt modify --all --edit
# Opens editor to update commit message if needed

# 4. Update the PR
gt submit

# 5. Sync changes upstack (IMPORTANT!)
gt upstack onto
# This rebases all PRs above #2 to include your changes

# 6. Force push the updated stack
gt submit --update-all
```

### Phase 6: Merging Your Stack

```bash
# Option 1: Merge PRs one at a time (recommended)
# - Merge PR #1 (bottom) first
# - Wait for CI to pass on PR #2
# - Merge PR #2
# - Repeat up the stack

# Option 2: Use Graphite's merge queue
gt stack submit --merge-when-ready
# Automatically merges each PR after the one below it is merged

# After each merge, sync your local stack
gt sync
# Pulls latest from trunk and updates remaining PRs
```

## Common Commands Reference

### Creating PRs
```bash
gt create -am "message"        # Create branch + commit + message
gt create --all --ai           # Let AI generate branch name and message
gt modify -a                   # Amend current commit with staged changes
gt modify -am "new message"    # Amend commit and update message
gt submit                      # Push and create/update PR
gt submit --draft              # Create as draft PR
```

### Navigation
```bash
gt stack                       # Visualize current stack
gt log                         # View commit history with branches
gt up / gt down                # Navigate up/down stack
gt top / gt bottom             # Jump to top/bottom of stack
gt checkout <branch>           # Switch to specific branch
```

### Syncing
```bash
gt sync                        # Sync with trunk (main/master)
gt upstack onto                # Rebase upstack PRs onto current
gt downstack restack           # Restack all downstack PRs
gt stack fix                   # Fix any stack inconsistencies
```

### Rebasing & Conflicts
```bash
gt stack fix                   # Auto-fix simple conflicts
gt continue                    # Continue after resolving conflicts
gt abort                       # Abort current operation
```

## Example: Full Stack Workflow

Let's build a complete authentication system as a stack:

```bash
# Start from main
gt checkout main

# PR #1: Database schema
# ... create user table migration ...
gt create -am "feat(db): Add users table schema"
gt submit

# PR #2: User model (builds on #1)
# ... create User model using new table ...
gt create -am "feat(api): Add User model and repository"
gt submit

# PR #3: Auth endpoints (builds on #2)
# ... create login/register endpoints ...
gt create -am "feat(api): Add authentication endpoints"
gt submit

# PR #4: Auth middleware (builds on #3)
# ... create JWT middleware ...
gt create -am "feat(api): Add authentication middleware"
gt submit

# PR #5: Integration tests (builds on all)
# ... write end-to-end auth tests ...
gt create -am "test(api): Add authentication integration tests"
gt submit

# View your stack
gt stack
# Output shows:
# ┌─────────────────────────────────────────┐
# │  PR #5: Auth integration tests          │
# │  PR #4: Auth middleware                 │
# │  PR #3: Auth endpoints                  │
# │  PR #2: User model                      │
# │  PR #1: Database schema                 │
# │  main                                   │
# └─────────────────────────────────────────┘

# Reviewer requests changes on PR #2
gt checkout <pr-2-branch>
# ... fix User model ...
gt modify -a
gt submit
gt upstack onto    # Updates PRs #3, #4, #5

# Merge from bottom up
# 1. PR #1 gets approved and merged
gt sync  # Syncs local with updated trunk

# 2. PR #2 gets approved and merged
gt sync

# 3. Continue until all merged
```

## Best Practices

1. **Small, Focused PRs** - Each PR should have a single, clear purpose
2. **Logical Dependencies** - Each PR should build logically on the one below
3. **Sync Often** - Run `gt sync` after any trunk changes
4. **Upstack After Changes** - Always run `gt upstack onto` after modifying PRs in the middle
5. **Descriptive Messages** - Use clear commit messages for each PR
6. **Test Each PR** - Ensure each PR passes tests independently
7. **Merge Bottom-Up** - Always merge PRs from bottom of stack upward

## Troubleshooting

**Stack shows outdated after merge:**
```bash
gt sync
```

**Conflicts after rebase:**
```bash
# Resolve conflicts manually
git add .
gt continue
```

**Accidentally made changes on wrong branch:**
```bash
gt checkout correct-branch
git cherry-pick <commit-hash>
```

**Want to reorder PRs in stack:**
```bash
# Use interactive rebase
git rebase -i main
# Then fix stack
gt stack fix
```

**Need to drop a PR from middle of stack:**
```bash
gt checkout <pr-to-drop>
gt delete
gt stack fix  # Rebases upstack PRs
```

## Resources

- **Graphite Docs**: https://docs.graphite.dev
- **Graphite CLI Repo**: https://github.com/withgraphite/graphite-cli
- **Graphite Dashboard**: https://app.graphite.dev
- **Getting Started Guide**: https://docs.graphite.dev/guides/graphite-cli

---

## Implementation

<execute>
case "$ARGUMENTS" in
  setup)
    echo "🔧 Graphite Setup Guide"
    echo ""
    echo "Step 1: Install Graphite CLI"
    echo "  npm install -g @withgraphite/graphite-cli@stable"
    echo "  # or"
    echo "  brew install --cask graphite"
    echo ""
    echo "Step 2: Authenticate"
    echo "  gt auth"
    echo "  # Visit: https://app.graphite.dev/activate"
    echo ""
    echo "Step 3: Initialize in repository"
    echo "  gt init"
    echo "  # Select trunk branch (main/master)"
    echo ""
    echo "Ready to start stacking! Use: /graphite create"
    ;;

  create)
    echo "📝 Create New PR in Stack"
    echo ""
    echo "1. Make your changes"
    echo ""
    echo "2. Create PR:"
    echo "  gt create --all --message \"feat: Your commit message\""
    echo "  # or let AI help:"
    echo "  gt create --all --ai"
    echo ""
    echo "3. Submit to GitHub:"
    echo "  gt submit"
    echo ""
    echo "Your PR is created! Continue building upstack with more changes."
    ;;

  modify)
    echo "✏️ Modify Current PR"
    echo ""
    echo "1. Make your changes"
    echo ""
    echo "2. Amend commit:"
    echo "  gt modify --all"
    echo ""
    echo "3. Update PR:"
    echo "  gt submit"
    echo ""
    echo "4. If this PR is in middle of stack, sync upstack:"
    echo "  gt upstack onto"
    ;;

  submit)
    echo "🚀 Submit PR to GitHub"
    echo ""
    echo "Create/update PR:"
    echo "  gt submit"
    echo ""
    echo "Create as draft:"
    echo "  gt submit --draft"
    echo ""
    echo "Submit entire stack:"
    echo "  gt stack submit"
    ;;

  sync)
    echo "🔄 Sync Stack"
    echo ""
    echo "Sync with trunk (after merges):"
    echo "  gt sync"
    echo ""
    echo "Sync upstack (after changing middle PR):"
    echo "  gt upstack onto"
    echo ""
    echo "Fix stack inconsistencies:"
    echo "  gt stack fix"
    ;;

  help|"")
    echo "🥞 Graphite Stacked Diffs"
    echo ""
    echo "Available commands:"
    echo "  /graphite setup    - Initial setup guide"
    echo "  /graphite create   - Create new PR in stack"
    echo "  /graphite modify   - Modify current PR"
    echo "  /graphite submit   - Submit PR to GitHub"
    echo "  /graphite sync     - Sync stack with trunk"
    echo ""
    echo "Quick reference:"
    echo "  gt stack           - Visualize stack"
    echo "  gt create -am \"...\" - Create PR"
    echo "  gt modify -a       - Amend PR"
    echo "  gt submit          - Push PR"
    echo "  gt up/down         - Navigate stack"
    echo "  gt sync            - Sync with trunk"
    echo ""
    echo "Learn more: https://docs.graphite.dev"
    ;;

  *)
    echo "❌ Unknown command: $ARGUMENTS"
    echo ""
    echo "Available: setup, create, modify, submit, sync, help"
    ;;
esac
</execute>
