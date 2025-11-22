---
name: git-commit-messages
description: Use when user mentions committing changes, creating commits, or needs commit messages. Generates conventional commit messages following best practices based on git diff.
category: workflow
---

# Git Commit Message Generator

Auto-generates high-quality conventional commit messages from your staged changes.

## When This Activates

- User says: "commit these changes", "create a commit", "write commit message"
- User runs: `git commit` without message
- User asks: "what should my commit message be?"

## Conventional Commits Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Build system changes
- **ci**: CI/CD changes
- **chore**: Maintenance tasks

## Process

1. **Run git diff --staged** to see changes
2. **Analyze changes:**
   - What files changed?
   - What's the primary purpose?
   - Are there breaking changes?
3. **Generate commit message:**
   - Type + scope
   - Short subject (50 chars max)
   - Detailed body if needed
   - Footer for breaking changes
4. **Present to user** before committing

## Examples

### Simple Feature
```bash
# Changes: Added login button component
feat(auth): add login button component

Created reusable LoginButton component with loading state
and error handling. Follows design system patterns.
```

### Bug Fix
```bash
# Changes: Fixed null pointer in user profile
fix(profile): prevent null pointer when user has no avatar

Added null check before accessing user.avatar property.
Fallback to default avatar when user.avatar is undefined.

Fixes #234
```

### Breaking Change
```bash
# Changes: Changed API response format
feat(api)!: change user API response format

BREAKING CHANGE: User API now returns `userId` instead of `id`

Migration guide:
- Replace `user.id` with `user.userId` in all API calls
- Update TypeScript interfaces
```

## Rules

✅ **DO:**
- Keep subject line under 50 characters
- Use imperative mood ("add" not "added")
- Explain WHY, not just WHAT
- Reference issue numbers
- Mark breaking changes with `!`

❌ **DON'T:**
- Write vague messages ("fix bug", "update code")
- Include file names in subject (they're in the diff)
- Use past tense
- Forget the scope when relevant

## Multi-File Changes

When multiple unrelated changes are staged:

```
You've staged changes to multiple unrelated areas:
- src/auth/ (authentication logic)
- src/ui/ (button styling)

RECOMMENDATION: Split into 2 commits

Commit 1:
feat(auth): implement JWT token refresh

Commit 2:
style(ui): update button hover states
```

## Automation

After generating message:
1. Show commit message
2. Ask: "Commit with this message? (y/n)"
3. If yes: `git commit -m "<message>"`
4. If no: Let user edit

**Never commit without user approval.**
