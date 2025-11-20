# Droidz Installer Audit Report
**Date:** November 20, 2025  
**Auditor:** Droid AI Assistant  
**Scope:** install.sh (v2.6.2) and install-claude-code.sh (v2.1.1)

## Executive Summary

Analyzed both Droidz installers for redundancy, outdated patterns, and alignment with Factory.ai documentation. Found several areas for optimization and consolidation.

## Installer Comparison

### install.sh (Factory.ai Droid CLI Edition)
- **Version:** 2.6.2-droid
- **Size:** ~1200 lines
- **Branch:** main
- **Target:** Factory.ai Droid CLI users
- **Features:**
  - OS/package manager detection (7 supported: apt, dnf, yum, pacman, zypper, apk, brew)
  - Auto-dependency installation (git, jq, tmux, Bun)
  - WSL2 auto-configuration for Claude Code compatibility
  - Node.js package manager detection (npm, yarn, pnpm, bun)
  - Interactive mode with user choices
  - Memory system initialization
  - Skills installation (45+ skills)
  - Standards templates installation
  - Comprehensive error logging

### install-claude-code.sh (Claude Code Framework)
- **Version:** 2.1.1
- **Size:** ~900 lines
- **Branch:** Claude-Code
- **Target:** Claude Code users
- **Features:**
  - Custom file detection and preservation
  - Smart merge functionality
  - Memory/specs backup and restore
  - Base vs custom file differentiation
  - Update mode with intelligent merging
  - Error reporting with system diagnostics

## Key Findings

### 1. Redundant Code (Critical)

**Duplicate Functions:**
- `detect_os()` - Identical in both installers
- `detect_package_manager()` - Identical logic
- `get_install_cmd()` - Same implementation
- `install_package()` - Nearly identical
- `check_prerequisites()` - 80% overlap
- `log_*()` functions - Identical logging helpers
- `generate_error_report()` - Same error handling
- `cleanup()` trap - Identical cleanup logic

**Recommendation:** Extract common functions into `install-common.sh` library.

### 2. Outdated Patterns

#### A. Skills Download (install.sh lines 772-791)
```bash
SKILL_NAMES=(
    "ADAPTATION_GUIDE"
    "auto-orchestrator"
    ...
)

for skill in "${SKILL_NAMES[@]}"; do
    mkdir -p ".factory/skills/${skill}"
    if curl -fsSL "${GITHUB_RAW}/.factory/skills/${skill}/SKILL.md${CACHE_BUST}" ...
```

**Issues:**
- Hardcoded list of 45 skills
- Downloads SKILL.md (uppercase) but repo uses skill.md (lowercase)
- No verification of skill existence before download
- Silent failures with warnings

**Recommendation:** 
- Use dynamic skill discovery from repository
- Check file existence first (404 prevention)
- Standardize on lowercase skill.md

#### B. Settings.json Merge (install.sh lines 562-593)
```bash
if [[ ! -f "$target_file" ]]; then
    mv "$tmp_file" "$target_file"
else
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$tmp_file" "$target_file" <<'PY'
```

**Issues:**
- Requires Python3 for JSON merging
- No fallback if Python unavailable
- Could use jq (already required dependency)

**Recommendation:** Use jq for JSON merging (already required, more reliable).

#### C. WSL Configuration (both installers)
```bash
configure_wsl_for_claude_code() {
    # Detects Windows npm in WSL
    if [[ "$npm_path" == /mnt/c/* ]]; then
        log_warning "Detected Windows npm in WSL..."
```

**Issues:**
- Only checks npm, not node
- Doesn't verify VS Code Server compatibility
- No detection of WSL1 vs WSL2

**Recommendation:** Enhanced WSL detection with VS Code integration checks.

### 3. Inconsistent Behavior

#### Update vs Fresh Install
- install.sh: Always asks for package manager choice on fresh install
- install-claude-code.sh: Clones entire repo, copies .factory directory
- Different directory structures expected by each installer

#### Memory Initialization
- install.sh: Creates JSON files directly in script (lines 843-918)
- install-claude-code.sh: Same logic but in different function
- Duplication of JSON schemas

### 4. Missing Features

#### install.sh Missing:
- Custom file preservation (claude-code.sh has this)
- Smart update/merge logic
- Backup and restore functionality
- Version migration handling

#### install-claude-code.sh Missing:
- Node.js package manager detection
- WSL2 optimization
- Interactive package manager selection
- Comprehensive error diagnostics
- Standards templates installation

### 5. Alignment with Factory.ai Documentation

#### Correct Patterns:
✅ Skills auto-activation via frontmatter `description` field
✅ Custom droids in `.factory/droids/` directory
✅ Commands in `.factory/commands/` directory
✅ Memory system structure (org/user separation)
✅ Settings.json hooks (SessionStart, UserPromptSubmit)

#### Misaligned Patterns:
❌ Skill filename: Downloads SKILL.md but should be skill.md
❌ No validation of Factory.ai CLI version compatibility
❌ Doesn't check if custom droids feature is enabled
❌ No verification of MCP servers (exa, linear, ref)

### 6. Security Issues

#### Moderate Risk:
- `config.yml` gitignore check (both installers) - GOOD
- No verification of downloaded file integrity (checksums)
- Executable scripts created without verification

#### Low Risk:
- Temporary directory cleanup (handled correctly)
- No credential exposure in error logs

## Optimization Opportunities

### 1. Consolidate Installers

**Proposed Structure:**
```
install.sh                 # Main installer (universal)
├── install-common.sh      # Shared functions library
├── install-factory.sh     # Factory.ai specific
└── install-claude-code.sh # Claude Code specific
```

### 2. Reduce Code Duplication

**Common Library Functions (install-common.sh):**
- OS/package manager detection
- Dependency installation
- Error handling and logging
- Git operations
- JSON merging utilities
- Memory initialization

**Estimated Reduction:** 400-500 lines (33-40%)

### 3. Improve Error Handling

**Current Issues:**
- Silent skill download failures
- No rollback on partial installation
- Error logs not cleaned up on success

**Proposed:**
- Transactional installation (all-or-nothing)
- Automatic rollback on failure
- Better progress indicators
- Structured error codes

### 4. Dynamic Content Discovery

Instead of hardcoded lists:
```bash
# Get skills from GitHub API
SKILLS=$(curl -s "https://api.github.com/repos/korallis/Droidz/contents/.factory/skills" | jq -r '.[].name')

for skill in $SKILLS; do
    # Download skill if skill.md exists
    if curl -fsSL --head "${GITHUB_RAW}/.factory/skills/${skill}/skill.md" &>/dev/null; then
        download_skill "$skill"
    fi
done
```

### 5. Standardize on skill.md (lowercase)

**Current:** Mixed SKILL.md and skill.md
**Proposed:** All lowercase skill.md for consistency
**Impact:** Requires renaming in repository

## Recommended Actions

### High Priority
1. ✅ **Create new specialized skills** (GraphQL, WebSocket, Monitoring, Load Testing) - COMPLETED
2. ⚠️ **Consolidate installers** - Extract common.sh library (400 lines saved)
3. ⚠️ **Fix skill.md filename inconsistency** - Standardize on lowercase
4. ⚠️ **Add custom file preservation to install.sh** - Copy from claude-code.sh
5. ⚠️ **Improve error handling** - Transactional install with rollback

### Medium Priority
6. Replace Python3 JSON merge with jq
7. Enhanced WSL2 detection and optimization
8. Dynamic skill discovery via GitHub API
9. Add installer version compatibility check
10. Verify Factory.ai CLI installation and version

### Low Priority
11. Add checksums for downloaded files
12. Progress bar for downloads
13. Colorized output improvements
14. Add `--uninstall` flag to both installers

## Installer Metrics

### Code Coverage
| Feature | install.sh | install-claude-code.sh |
|---------|-----------|----------------------|
| OS Detection | ✅ | ✅ |
| Package Mgr Detection | ✅ | ✅ |
| Auto Dependencies | ✅ | ✅ |
| WSL Configuration | ✅ | ✅ |
| Custom File Preservation | ❌ | ✅ |
| Smart Merge | ❌ | ✅ |
| Memory Init | ✅ | ✅ |
| Skills Download | ✅ | ✅ |
| Standards Templates | ✅ | ❌ |
| Error Diagnostics | ✅ | ✅ |
| Package Manager Choice | ✅ | ❌ |

### Size Metrics
- Total lines: 2,100
- Duplicate lines: ~450 (21%)
- Potential reduction: 400-500 lines
- Target size: 1,600 lines total

## Conclusion

Both installers work well but have significant overlap. Consolidating common functionality into a shared library would:
- Reduce maintenance burden
- Ensure consistency
- Make updates easier
- Improve reliability

The main installer (install.sh) is more comprehensive but lacks smart update features. The Claude Code installer has better custom file handling but missing some modern features.

**Recommendation:** Create unified installer with modular architecture:
1. install-common.sh (shared functions)
2. install.sh (main entry point with mode selection)
3. Legacy support for both workflows

This would reduce codebase by 30-40% while improving maintainability.

## Next Steps

1. Create install-common.sh library
2. Refactor both installers to use common library
3. Standardize skill.md filename across repository
4. Add integration tests for installers
5. Document installer architecture
6. Create new release with optimized installers
