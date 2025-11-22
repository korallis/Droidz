# Droidz for Codex CLI

Complete guide to using Droidz framework with Codex CLI.

---

## 📖 Table of Contents

- [What is Droidz for Codex CLI?](#what-is-droidz-for-codex-cli)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Available Prompts](#available-prompts)
- [Workflow Examples](#workflow-examples)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## What is Droidz for Codex CLI?

Droidz for Codex CLI brings the power of the Droidz framework to OpenAI's Codex CLI, providing:

- **6 production-ready prompts** for feature development
- **Unified specs system** (`.droidz/specs/`) shared with Claude Code
- **Project-aware prompts** with AGENTS.md configuration
- **Validation pipelines** for code quality
- **Testing workflows** with comprehensive coverage
- **Documentation generation** and tech stack detection

### Why Codex CLI?

Codex CLI is OpenAI's official AI-powered development assistant that:
- Runs in your terminal with natural language commands
- Integrates with your existing development workflow
- Supports custom prompts for domain-specific workflows
- Works with any project structure

---

## Installation

### Prerequisites

- **Node.js 18+** (required for Codex CLI)
- **Git** (for version control)
- **Python 3.7+** (for Droidz installer)

### Step 1: Install Codex CLI

```bash
npm install -g @openai/codex
```

Verify installation:
```bash
codex --version
# Should show: 0.63.0 or higher
```

### Step 2: Install Droidz Framework

```bash
# Clone the Droidz repository
git clone https://github.com/yourusername/Droidz.git
cd Droidz

# Install Python dependencies (optional, for installer)
pip3 install -r requirements.txt

# Run the interactive installer
python3 install.py
```

### Step 3: Interactive Installation

The installer will:
1. Detect your platform (Codex CLI, Claude Code, or Droid CLI)
2. Show available components with compatibility status
3. Let you select which components to install
4. Install prompts to `~/.codex/prompts/`
5. Create `.droidz/specs/` directory structure
6. Generate `AGENTS.md` with project context

**Example Session:**
```
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║      🤖 Droidz v4.0 Installer                           ║
║      Production-Grade AI Development Framework          ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

✓ Platform detected: macOS (darwin)
✓ Shell detected: zsh
✓ Node.js: v20.10.0 ✓
✓ Git: 2.43.0 ✓
✓ Codex CLI: 0.63.0 ✓

? Select your platform:
  ❯ Codex CLI (OpenAI's official CLI)
    Claude Code (Anthropic's IDE extension)
    Droid CLI (Factory.ai's CLI)

? Select components to install:
  ❯ ◉ Core Prompts (build, validate, codegen)
    ◉ Specialist Prompts (test, orchestrator)
    ◉ Project Setup (init, AGENTS.md)
    ◯ Documentation Templates
    ◯ Example Specs

Installing to: ~/.codex/prompts/

✓ Installed 6 prompts
✓ Created .droidz/specs/ structure
✓ Generated AGENTS.md

🎉 Droidz installed successfully!

Next steps:
  1. cd your-project/
  2. codex /prompts:init
  3. codex /prompts:build FEATURE="your feature"
```

### Manual Installation

If you prefer manual installation:

```bash
# Copy prompts to Codex CLI directory
mkdir -p ~/.codex/prompts
cp templates/codex/prompts/*.md ~/.codex/prompts/

# Create specs directory in your project
cd your-project/
mkdir -p .droidz/specs/{active,archive,templates,examples}

# Optional: Add to .gitignore
echo ".droidz/specs/active/" >> .gitignore
echo ".droidz/specs/archive/" >> .gitignore
```

---

## Quick Start

### 1. Initialize Your Project

```bash
cd your-project/
codex /prompts:init
```

This will:
- Detect your tech stack (TypeScript, React, Next.js, etc.)
- Create `AGENTS.md` with project-specific instructions
- Set up `.droidz/specs/` directory structure
- Generate example specs

### 2. Create a Feature Specification

```bash
codex /prompts:build FEATURE="user authentication system" COMPLEXITY=medium
```

This generates a comprehensive spec in `.droidz/specs/active/001-user-auth.md` with:
- Architecture overview
- Task breakdown
- Testing strategy
- Security considerations
- Deployment plan

### 3. Implement the Feature

```bash
codex /prompts:codegen FEATURE="implement login endpoint"
```

This will:
- Analyze existing code patterns
- Write production-ready code
- Include comprehensive tests
- Follow project conventions
- Validate everything works

### 4. Validate Your Work

```bash
codex /prompts:validate
```

Runs 5-phase validation:
1. Linting (ESLint)
2. Type checking (TypeScript)
3. Style checking (Prettier)
4. Unit tests
5. Integration tests

---

## Available Prompts

### `/prompts:init`

Initialize Droidz framework in your project.

**Usage:**
```bash
codex /prompts:init
codex /prompts:init --quick     # Skip interactive questions
codex /prompts:init --status    # Check current setup
```

**What it does:**
- Detects tech stack (language, frameworks, tools)
- Creates `.droidz/specs/` directory structure
- Generates `AGENTS.md` with project context
- Creates example specs
- Validates environment

**Output:**
- `AGENTS.md` - Project instructions for Codex CLI
- `.droidz/specs/` - Specs directory structure
- `.droidz/memory/tech-stack.md` - Detected tech info

---

### `/prompts:build`

Generate comprehensive feature specification.

**Usage:**
```bash
codex /prompts:build FEATURE="user profile page"
codex /prompts:build FEATURE="payment integration" COMPLEXITY=high
```

**Arguments:**
- `FEATURE` (required) - Feature description
- `COMPLEXITY` (optional) - `low`, `medium`, or `high` (default: medium)

**What it does:**
- Analyzes feature complexity
- Asks clarifying questions (if medium/high complexity)
- Creates detailed implementation plan
- Identifies parallel execution opportunities
- Documents testing strategy and security

**Output:**
- `.droidz/specs/active/NNN-feature-name.md` - Complete specification

**Example Output:**
```markdown
# User Profile Page Specification

## Executive Summary
Implement user profile page with editable fields, avatar upload, and
account settings. Impact: Allows users to manage their information.

## Tasks

### Task 1: [Backend] Create Profile API
**Files**: src/api/profile.ts, src/routes/profile.ts
**Effort**: M (4 hours)
**Dependencies**: None
**Parallelizable**: Yes
...
```

---

### `/prompts:validate`

Run comprehensive validation pipeline.

**Usage:**
```bash
codex /prompts:validate           # Run all 5 phases
codex /prompts:validate PHASE=1   # Run linting only
codex /prompts:validate PHASE=4   # Run tests only
```

**Arguments:**
- `PHASE` (optional) - 1-5 or `all` (default: all)

**Phases:**
1. **Linting** - ESLint, Ruff, etc.
2. **Type Checking** - TypeScript, mypy
3. **Style Checking** - Prettier, Black
4. **Unit Tests** - Jest, Vitest, pytest
5. **Integration Tests** - E2E tests, API tests

**What it does:**
- Detects available tools automatically
- Runs validation commands
- Handles missing tools gracefully
- Shows detailed error excerpts
- Provides fix suggestions

**Output Example:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Validation Results

Overall: ✅ 4/5 phases passed

  ✅ Phase 1: Linting passed (0 errors, 0 warnings)
  ❌ Phase 2: Type checking failed (3 errors)
  ✅ Phase 3: Style checking passed
  ✅ Phase 4: Unit tests passed (42 tests)
  ⚠️  Phase 5: Integration tests skipped (not configured)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Action Items:

1. Fix TypeScript errors:
   • src/utils/auth.ts:23 - Property 'foo' doesn't exist
   • src/api/login.ts:18 - Undefined not assignable

2. Re-run validation: codex /prompts:validate
```

---

### `/prompts:codegen`

Implement features with comprehensive tests.

**Usage:**
```bash
codex /prompts:codegen FEATURE="add navigation menu"
codex /prompts:codegen FEATURE="login endpoint" FILES=src/api/auth.ts
codex /prompts:codegen FEATURE="fix auth bug" TICKET=PROJ-123
```

**Arguments:**
- `FEATURE` (required) - What to implement
- `FILES` (optional) - Target files to modify
- `TICKET` (optional) - Issue/ticket reference

**What it does:**
1. Analyzes existing code patterns
2. Plans implementation approach
3. Writes production-ready code
4. Includes comprehensive tests
5. Runs validation (lint, typecheck, tests)
6. Provides detailed summary

**Output:**
```markdown
## Implementation Complete ✨

### Files Created
- `src/components/Navigation.tsx` - Navigation component
- `tests/components/Navigation.test.tsx` - Component tests (8 tests)

### Validation Results
✅ ESLint: 0 errors
✅ TypeScript: No type errors
✅ Tests: 8/8 passed (100% coverage)

### Next Steps
1. Test manually in browser
2. Commit changes: git commit -m "feat: add navigation menu"
3. Create PR for review
```

---

### `/prompts:test-specialist`

Write, fix, or improve tests.

**Usage:**
```bash
codex /prompts:test-specialist ACTION=write TARGET=src/api/auth.ts
codex /prompts:test-specialist ACTION=fix TARGET=tests/api/auth.test.ts
codex /prompts:test-specialist ACTION=coverage
```

**Arguments:**
- `ACTION` (required) - `write`, `fix`, or `coverage`
- `TARGET` (optional) - File or component to test

**Actions:**

**`write`** - Write tests for new code
- Analyzes code to test
- Plans test cases (happy path, edge cases, errors)
- Writes comprehensive tests
- Verifies coverage (80%+ target)

**`fix`** - Fix failing tests
- Analyzes test failures
- Determines root cause
- Fixes tests or implementation
- Verifies all pass

**`coverage`** - Improve test coverage
- Generates coverage report
- Identifies gaps (<80% coverage)
- Writes missing tests
- Verifies improvement

**Output Example:**
```markdown
## Testing Complete ✨

### Tests Written
- `tests/api/auth.test.ts` - 12 tests (100% coverage)
  * Happy path: login with valid credentials
  * Error case: invalid email format
  * Error case: wrong password
  * Edge case: SQL injection attempt
  ... (8 more)

### Coverage Report
| File | Coverage | Lines | Branches |
|------|----------|-------|----------|
| src/api/auth.ts | 100% | 45/45 | 12/12 |

### Validation
✅ All 12 tests passing
✅ 100% coverage on new code
✅ 0 linting errors
```

---

### `/prompts:orchestrator`

Orchestrate complex multi-step features.

**Usage:**
```bash
codex /prompts:orchestrator FEATURE="authentication system"
codex /prompts:orchestrator FEATURE="payment integration"
```

**Arguments:**
- `FEATURE` (required) - Complex feature to build

**What it does:**
1. Analyzes feature complexity
2. Breaks into logical phases with dependencies
3. Creates todo list for progress tracking
4. Executes phases sequentially
5. Validates between phases
6. Synthesizes comprehensive results

**Best for:**
- Features involving 5+ files
- Multiple domains (frontend + backend + tests)
- Complex dependencies between tasks
- Long-running implementations (>4 hours)

**Output Example:**
```markdown
## Feature Implementation Complete ✨

### Summary
Implemented full authentication system with JWT tokens.

### Statistics
- **Total Time**: ~15 hours (estimated 13-18h)
- **Files Created**: 12
- **Tests Written**: 28 (all passing ✅)
- **Test Coverage**: 95%

### Phase Breakdown
| Phase | Tasks | Status | Time |
|-------|-------|--------|------|
| Foundation | 3 | ✅ Complete | 2.5h |
| Backend API | 4 | ✅ Complete | 5h |
| Frontend | 4 | ✅ Complete | 4h |
| Testing | 3 | ✅ Complete | 3.5h |
| Documentation | 4 | ✅ Complete | 1.5h |

### Next Steps
1. Review changes: git diff origin/main
2. Create PR: gh pr create --fill
```

---

## Workflow Examples

### Example 1: Simple Feature (15 minutes)

```bash
# 1. Quick feature implementation
codex /prompts:codegen FEATURE="add dark mode toggle to settings page"

# 2. Validate
codex /prompts:validate

# 3. Commit
git add .
git commit -m "feat: add dark mode toggle"
```

---

### Example 2: Medium Feature (2-4 hours)

```bash
# 1. Create specification
codex /prompts:build FEATURE="user profile page with avatar upload" COMPLEXITY=medium

# 2. Review spec (opens in editor)
code .droidz/specs/active/001-user-profile.md

# 3. Implement backend
codex /prompts:codegen FEATURE="profile API endpoints" FILES=src/api/profile.ts

# 4. Implement frontend
codex /prompts:codegen FEATURE="profile page UI" FILES=src/pages/profile.tsx

# 5. Write tests
codex /prompts:test-specialist ACTION=write TARGET=src/api/profile.ts

# 6. Validate everything
codex /prompts:validate

# 7. Commit
git add .
git commit -m "feat: add user profile page with avatar upload"
```

---

### Example 3: Complex Feature (1-2 days)

```bash
# 1. Create comprehensive specification
codex /prompts:build FEATURE="full authentication system with OAuth" COMPLEXITY=high

# 2. Review and refine spec
code .droidz/specs/active/001-auth-system.md
# (Make any adjustments needed)

# 3. Use orchestrator for complex implementation
codex /prompts:orchestrator FEATURE="implement authentication system per spec 001"

# Orchestrator will:
# - Break into phases (Foundation → Backend → Frontend → Testing → Docs)
# - Execute sequentially with validation between phases
# - Track progress with todo list
# - Provide comprehensive summary

# 4. Final validation
codex /prompts:validate

# 5. Manual testing
npm run dev
# (Test the feature manually)

# 6. Create PR
gh pr create --title "feat: authentication system with OAuth" --fill
```

---

### Example 4: Bug Fix Workflow

```bash
# 1. Understand the bug (run tests)
npm test

# 2. Fix implementation
codex /prompts:codegen FEATURE="fix authentication token expiry bug" TICKET=BUG-456

# 3. Fix or update tests
codex /prompts:test-specialist ACTION=fix TARGET=tests/api/auth.test.ts

# 4. Validate
codex /prompts:validate

# 5. Commit
git add .
git commit -m "fix: authentication token expiry (BUG-456)"
```

---

### Example 5: Test Coverage Improvement

```bash
# 1. Check current coverage
npm test -- --coverage

# 2. Improve coverage
codex /prompts:test-specialist ACTION=coverage

# 3. Validate
codex /prompts:validate PHASE=4

# 4. Commit
git add tests/
git commit -m "test: improve coverage to 85%"
```

---

## Configuration

### Project Configuration (AGENTS.md)

The `AGENTS.md` file provides project-specific instructions to Codex CLI:

```markdown
# AGENTS.md - Project Instructions for Codex CLI

## Tech Stack

### Frontend
- **Language**: TypeScript 5.3
- **Framework**: React 18.2 with Next.js 14.0 (App Router)
- **Styling**: Tailwind CSS 3.4

### Build & Package Management
- **Package Manager**: Bun (use `bun install`, `bun run`, `bun test`)

---

## Development Guidelines

### Code Style
- **Indentation**: 2 spaces
- **Components**: Functional components with hooks
- **File Naming**: kebab-case

### Commands
```bash
bun run dev          # Start dev server
bun test             # Run tests
```

---

## Project-Specific Notes

- API base URL: `process.env.NEXT_PUBLIC_API_URL`
- Authentication: JWT tokens in httpOnly cookies
```

**Customize AGENTS.md** for your project:
- Add project-specific commands
- Document architectural decisions
- List environment variables
- Include deployment instructions

---

### Specs Configuration

Specs are stored in `.droidz/specs/` with this structure:

```
.droidz/
└── specs/
    ├── active/       # Work-in-progress (not in git)
    ├── archive/      # Completed specs (not in git)
    ├── templates/    # Spec templates (in git)
    └── examples/     # Reference examples (in git)
```

**Recommended `.gitignore`:**
```
# Ignore WIP and completed specs (team preference)
.droidz/specs/active/
.droidz/specs/archive/

# Keep templates and examples in git
!.droidz/specs/templates/
!.droidz/specs/examples/
```

---

## Best Practices

### 1. Initialize Projects Properly

Always run `/prompts:init` when setting up a new project:
```bash
cd new-project/
codex /prompts:init
```

This ensures Codex CLI understands your:
- Tech stack
- Development commands
- Project conventions
- Testing setup

---

### 2. Use Specifications for Complex Work

For features that will take >1 hour, create a spec first:
```bash
codex /prompts:build FEATURE="complex feature" COMPLEXITY=medium
# Review spec
code .droidz/specs/active/NNN-feature.md
# Then implement
codex /prompts:orchestrator FEATURE="implement spec NNN"
```

Benefits:
- Clarifies requirements upfront
- Identifies parallel opportunities
- Documents decisions
- Provides implementation roadmap

---

### 3. Validate Early and Often

Run validation after each significant change:
```bash
# Quick validation (phases 1-2)
codex /prompts:validate PHASE=1
codex /prompts:validate PHASE=2

# Full validation before committing
codex /prompts:validate
```

---

### 4. Write Tests Alongside Code

Don't skip testing:
```bash
# Implement feature
codex /prompts:codegen FEATURE="new endpoint"

# Write tests immediately
codex /prompts:test-specialist ACTION=write TARGET=src/api/new-endpoint.ts

# Validate
codex /prompts:validate PHASE=4
```

---

### 5. Use Orchestrator for Complex Features

If a feature involves:
- 5+ files
- Multiple domains (frontend + backend)
- Complex dependencies
- >4 hours of work

Use the orchestrator:
```bash
codex /prompts:orchestrator FEATURE="authentication system"
```

---

### 6. Keep AGENTS.md Updated

Update `AGENTS.md` when you:
- Add new dependencies
- Change build commands
- Make architectural decisions
- Update coding conventions

---

### 7. Archive Completed Specs

Move completed specs to archive:
```bash
mv .droidz/specs/active/001-feature.md .droidz/specs/archive/
```

This keeps active specs focused on current work.

---

## Troubleshooting

### Prompts Not Found

**Error:** `Prompt not found: /prompts:build`

**Solution:**
```bash
# Check if prompts are installed
ls ~/.codex/prompts/

# If empty, reinstall
cd path/to/Droidz
python3 install.py

# Or manually copy
cp templates/codex/prompts/*.md ~/.codex/prompts/
```

---

### AGENTS.md Not Being Used

**Issue:** Codex CLI not following project conventions

**Solution:**
1. Ensure `AGENTS.md` exists in project root:
   ```bash
   ls -la AGENTS.md
   ```

2. If missing, regenerate:
   ```bash
   codex /prompts:init
   ```

3. Verify content is project-specific:
   ```bash
   cat AGENTS.md
   ```

---

### Validation Fails with "Tool Not Found"

**Error:** `ESLint not found`

**Solution:**
Validation uses `npx` for automatic tool installation, but ensure package.json exists:
```bash
# Initialize if needed
npm init -y

# Install dev dependencies
npm install -D eslint prettier typescript

# Or let validation use npx (auto-installs)
codex /prompts:validate
```

---

### Specs Not Saving to .droidz/specs/

**Issue:** Specs created in wrong location

**Solution:**
1. Check if directory exists:
   ```bash
   ls -la .droidz/specs/
   ```

2. If missing, create manually:
   ```bash
   mkdir -p .droidz/specs/{active,archive,templates,examples}
   ```

3. Or re-run init:
   ```bash
   codex /prompts:init
   ```

---

### Codex CLI Not Installed

**Error:** `command not found: codex`

**Solution:**
```bash
# Install globally
npm install -g @openai/codex

# Verify
codex --version

# If still not found, check Node.js version (need 18+)
node --version

# Update Node.js if needed (use nvm)
nvm install 20
nvm use 20
npm install -g @openai/codex
```

---

## Support & Resources

- **Documentation**: [docs/](../docs/)
- **Examples**: [.droidz/specs/examples/](../.droidz/specs/examples/)
- **Issues**: [GitHub Issues](https://github.com/yourusername/Droidz/issues)
- **Changelog**: [CHANGELOG.md](../CHANGELOG.md)

---

## Next Steps

Now that you understand Droidz for Codex CLI:

1. **Install** - Run the Python installer
2. **Initialize** - Set up your project with `/prompts:init`
3. **Build** - Create your first spec with `/prompts:build`
4. **Implement** - Use `/prompts:codegen` to build features
5. **Validate** - Ensure quality with `/prompts:validate`

Happy building! 🚀
