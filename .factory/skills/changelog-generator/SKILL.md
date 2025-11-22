---
name: changelog-generator
description: Use when user mentions changelog, release notes, version history, or updating CHANGELOG.md. Generates changelog from git commits.
category: documentation
---

# Changelog Generator

Auto-generates CHANGELOG.md following Keep a Changelog format from git history.

## When This Activates

- User says: "update changelog", "generate release notes", "create changelog"
- Before creating a new release/version
- When preparing for deployment

## Changelog Format

Follows [Keep a Changelog](https://keepachangelog.com/) standard:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes in existing functionality

### Deprecated
- Features that will be removed in upcoming releases

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security fixes and improvements

## [1.2.0] - 2025-11-20

### Added
- User authentication with JWT tokens (#123)
- Password reset functionality (#125)
- Email verification system (#127)

### Changed
- Improved error messages for API endpoints (#124)
- Updated database schema for better performance (#126)

### Fixed
- Fixed null pointer in user profile (#128)
- Resolved memory leak in background jobs (#129)

### Security
- Fixed SQL injection vulnerability in search (#130)
- Updated dependencies with security patches

## [1.1.0] - 2025-10-15

### Added
- Dark mode support (#110)
- Export data to CSV (#112)

### Fixed
- Loading spinner stuck on some pages (#115)

## [1.0.0] - 2025-09-01

### Added
- Initial release
- User registration and login
- Dashboard with analytics
- Basic CRUD operations

[Unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

## Process

1. **Get git commits since last release:**
   ```bash
   git log v1.1.0..HEAD --oneline --no-merges
   ```

2. **Parse conventional commits:**
   - `feat:` → **Added** section
   - `fix:` → **Fixed** section
   - `refactor:` → **Changed** section
   - `perf:` → **Changed** section
   - `docs:` → (not in changelog, internal)
   - `style:` → (not in changelog)
   - `test:` → (not in changelog)
   - `chore:` → (not in changelog, unless notable)
   - `BREAKING CHANGE:` → **Changed** (with warning)

3. **Group by category:**
   - Added (new features)
   - Changed (modifications to existing)
   - Deprecated (will be removed)
   - Removed (features removed)
   - Fixed (bug fixes)
   - Security (security fixes)

4. **Link to PRs/issues:**
   ```markdown
   - User authentication with JWT tokens (#123, @username)
   ```

5. **Add version comparison links**

## Example: From Commits to Changelog

### Git Commits
```
feat(auth): add JWT authentication (#123)
fix(profile): prevent null pointer when no avatar (#128)
feat(email): implement email verification (#127)
perf(db): optimize user queries with indexes (#126)
fix: resolve memory leak in background jobs (#129)
BREAKING CHANGE: change API response format (#124)
security: fix SQL injection in search (#130)
```

### Generated Changelog
```markdown
## [1.2.0] - 2025-11-20

### Added
- JWT authentication for secure API access (#123)
- Email verification system for new users (#127)

### Changed
- **BREAKING:** API response format changed for consistency (#124)
  - Migration guide: See docs/migration/v1.2.0.md
- Optimized database queries with new indexes - 50% faster (#126)

### Fixed
- Prevented null pointer exception in user profile (#128)
- Resolved memory leak in background job processor (#129)

### Security
- Fixed SQL injection vulnerability in search endpoint (#130)
```

## Semantic Versioning

Auto-suggest version bump:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat:` | MINOR (1.1.0 → 1.2.0) | New features |
| `fix:` | PATCH (1.1.0 → 1.1.1) | Bug fixes |
| `BREAKING CHANGE` | MAJOR (1.0.0 → 2.0.0) | Breaking changes |
| `perf:`, `refactor:` | PATCH/MINOR | Improvements |

**Suggest:** "Based on commits, suggest version: 1.2.0 (MINOR - new features added)"

## Migration Guides

For breaking changes, auto-generate migration guide:

```markdown
## Migration Guide: v1.1.0 → v1.2.0

### Breaking Changes

#### API Response Format Changed

**Before:**
\`\`\`json
{ "id": "123", "name": "John" }
\`\`\`

**After:**
\`\`\`json
{ "userId": "123", "name": "John" }
\`\`\`

**Action Required:**
Replace all instances of \`response.id\` with \`response.userId\` in your code.

**Estimated Time:** 10-15 minutes
```

## Best Practices

✅ **DO:**
- Update before each release
- Group related changes
- Link to PR numbers
- Mention breaking changes prominently
- Include migration guides
- Use clear, user-friendly language

❌ **DON'T:**
- Include every tiny commit
- Use technical jargon
- Skip breaking change warnings
- Forget version comparison links
- Make it too verbose

## Automation

```bash
# Generate changelog for next version
git log $(git describe --tags --abbrev=0)..HEAD --oneline --no-merges

# Or use conventional-changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s

# Update version in package.json
npm version minor  # or: patch, major
```

**Generate changelog, present to user, update CHANGELOG.md with approval.**
