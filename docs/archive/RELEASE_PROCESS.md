# Droidz Release Process

This document explains how to create new releases for Droidz using Git tags and GitHub releases.

## 📋 Version Numbering

We use **semantic versioning** (SemVer): `MAJOR.MINOR.PATCH`

- **MAJOR** (e.g., `1.0.0` → `2.0.0`) - Breaking changes, incompatible API changes
- **MINOR** (e.g., `0.1.0` → `0.2.0`) - New features, backward-compatible
- **PATCH** (e.g., `0.1.0` → `0.1.1`) - Bug fixes, backward-compatible

### Examples:
- `0.0.98` → `0.1.0` - Added critical fix (minor version bump)
- `0.1.0` → `0.1.1` - Small bug fix (patch version)
- `0.9.0` → `1.0.0` - Stable release (major version)

---

## 🚀 Release Checklist

### 1. Update Version Numbers

Update in **all** these files:

```bash
# package.json
{
  "version": "0.X.Y"
}

# plugin.json
{
  "version": "2.X.Y"  # Different versioning
}

# install.sh (line 14)
VERSION="0.X.Y"

# install.sh (What's New section, around line 350)
echo -e "${CYAN}🆕 What's New in v${VERSION}:${NC}"
echo ""
echo "  ✅ Feature 1..."
echo "  🔧 Fix 1..."
```

### 2. Update Documentation

- `CHANGELOG.md` - Add entry for this version
- `README.md` - Update version references if needed
- `docs/fixes/` - Add fix documentation if it's a bugfix release

### 3. Commit Version Bump

```bash
git add package.json plugin.json install.sh
git commit -m "chore: bump version to 0.X.Y for [feature/fix]

- package.json: 0.A.B → 0.X.Y
- plugin.json: 2.A.B → 2.X.Y
- install.sh: Updated version and What's New

[Brief description of what's in this release]

Co-authored-by: factory-droid[bot] <138933559+factory-droid[bot]@users.noreply.github.com>"
```

### 4. Create Git Tag

Create an **annotated tag** (not lightweight):

```bash
git tag -a v0.X.Y -m "Release v0.X.Y: [Brief Title]

[Multi-line description of what changed]

## What's New
- Feature 1
- Feature 2

## What's Fixed
- Bug 1
- Bug 2

## Changes
- File 1
- File 2

Commits: [commit-hash], [commit-hash]"
```

**Example:**
```bash
git tag -a v0.1.0 -m "Release v0.1.0: Fix parallel agent spawning

Critical fix restoring parallel execution functionality.

## What's Fixed
- Removed invalid 'model' parameter from Task tool calls
- All specialist droids now spawn correctly (100% success rate)
- 3-5x parallel speedup restored

Commits: 223db97, 9e6124b"
```

### 5. Push Everything

```bash
# Push commits
git push origin factory-ai

# Push tag
git push origin v0.X.Y
```

### 6. Create GitHub Release

Create release notes in a file:

```bash
cat > /tmp/release-notes.md << 'EOF'
# [Title]

[Description]

## What's New
- Feature 1

## What's Fixed
- Bug 1

## How to Install
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

## Testing
[Testing instructions]
EOF
```

Create the release:

```bash
gh release create v0.X.Y \
  --title "v0.X.Y - [Brief Title]" \
  --notes-file /tmp/release-notes.md \
  --target factory-ai
```

### 7. Verify Release

Check the release page:
```
https://github.com/korallis/Droidz/releases/tag/v0.X.Y
```

Verify users can install:
```bash
# In a test directory
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

---

## 📦 Release Types

### Bug Fix Release (Patch)

**When:** Fix critical bugs, no new features

```bash
# 0.1.0 → 0.1.1
VERSION_OLD="0.1.0"
VERSION_NEW="0.1.1"

# Update files
# Commit: "fix: [description]"
# Tag message: "Release v0.1.1: Fix [issue]"
```

### Feature Release (Minor)

**When:** Add new features, backward-compatible

```bash
# 0.1.0 → 0.2.0
VERSION_OLD="0.1.0"
VERSION_NEW="0.2.0"

# Update files
# Commit: "feat: [description]"
# Tag message: "Release v0.2.0: Add [feature]"
```

### Breaking Change Release (Major)

**When:** Breaking changes, incompatible updates

```bash
# 0.9.0 → 1.0.0
VERSION_OLD="0.9.0"
VERSION_NEW="1.0.0"

# Update files
# Commit: "feat!: [description] BREAKING CHANGE: [details]"
# Tag message: "Release v1.0.0: [Major changes]"
```

---

## 🔍 Finding Releases

### List all tags:
```bash
git tag -l
```

### Show tag details:
```bash
git tag -l -n9 v0.1.0
```

### List releases (GitHub):
```bash
gh release list
```

### View specific release:
```bash
gh release view v0.1.0
```

### Download specific version:
```bash
# Clone at specific tag
git clone --branch v0.1.0 https://github.com/korallis/Droidz.git

# Or fetch specific version
git fetch --tags
git checkout v0.1.0
```

---

## 🎯 For Users: Installing Specific Versions

### Latest Release (Recommended):
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

### Specific Version:
```bash
# Clone specific version
git clone --branch v0.1.0 https://github.com/korallis/Droidz.git
cd Droidz
./install.sh
```

### Check Current Version:
```bash
# In your Droidz installation
cat package.json | grep version
# or
grep VERSION= install.sh
```

---

## 📝 Changelog Format

Keep `CHANGELOG.md` updated with each release:

```markdown
# Changelog

## [0.1.0] - 2025-11-15

### Fixed
- Parallel agent spawning restored (removed invalid model parameter)
- 100% success rate for Task tool spawning

### Changed
- Updated installer to download fix documentation
- Version bump: 0.0.98 → 0.1.0

### Documentation
- Added docs/fixes/2025-11-15-task-tool-model-parameter-fix.md

## [0.0.98] - 2025-11-14
...
```

---

## 🔧 Automation Ideas (Future)

Consider automating releases with:
- GitHub Actions workflow on tag push
- Automatic changelog generation from commits
- Release note templates
- Version bump scripts

---

## 📞 Questions?

- **Tags not showing?** Run `git fetch --tags`
- **Release failed?** Check `gh auth status` and repo permissions
- **Wrong version?** Delete tag: `git tag -d v0.X.Y && git push --delete origin v0.X.Y`

---

Last Updated: 2025-11-15
