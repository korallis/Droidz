---
description: Generate project-specific validation workflow by analyzing your codebase and creating a comprehensive /validate command
---

# /validate-init - Generate Project Validation Workflow

## Purpose

Analyzes your project to detect available tools (linters, type checkers, formatters, test frameworks) and generates a custom `.factory/commands/validate.md` file with a 5-phase validation pipeline tailored to your project.

## When to Use

- **First time setup**: Run this once per project after `/init`
- **Tool changes**: Rerun when you add new linters, test frameworks, or validation tools
- **New team members**: Generate validation workflow for contributors

**Auto-runs during first `/init`** if `/validate` command doesn't exist.

## What It Does

### Phase 1: Detection

Scans your project for:

**Linters**
- ESLint (JavaScript/TypeScript)
- Ruff, Pylint, Flake8 (Python)
- RuboCop (Ruby)
- Golangci-lint (Go)

**Type Checkers**
- TypeScript compiler (`tsc`)
- Mypy (Python)
- Flow (JavaScript)

**Formatters**
- Prettier (JavaScript/TypeScript/CSS)
- Black (Python)
- Rustfmt (Rust)
- Gofmt (Go)

**Test Frameworks**
- Jest, Vitest (JavaScript/TypeScript)
- Pytest (Python)
- RSpec (Ruby)
- Playwright, Cypress (E2E)

**Build Tools**
- Detect if project uses npm, yarn, pnpm, bun, cargo, go, etc.

### Phase 2: Generate Validation Command

Creates `.factory/commands/validate.md` with:

```markdown
---
description: Run comprehensive validation (lint, type, style, unit, E2E)
---

# Project Validation - 5 Phases

## Phase 1: Linting ✓
!`npm run lint`

## Phase 2: Type Checking ✓
!`tsc --noEmit`

## Phase 3: Style Checking ✓
!`npx prettier --check .`

## Phase 4: Unit Tests ✓
!`npm test -- --coverage`

## Phase 5: E2E Tests ✓

### Setup Test Environment
!`docker-compose -f docker-compose.test.yml up -d`

### Run E2E Workflows
!`npx playwright test`

### Cleanup
!`docker-compose -f docker-compose.test.yml down -v`

---

✅ All validation passed! Ready for deployment.
```

### Phase 3: Create Test Helpers

For E2E tests, generates:
- Docker Compose test configurations
- Database seed scripts
- Mock service setups
- Test environment helpers

Saves to: `.factory/validation/test-helpers/`

## Usage

```bash
# Generate validation workflow
/validate-init

# Then run validation anytime
/validate
```

## Example Output

```
🔍 Analyzing project for validation tools...

✓ Detected: ESLint (JavaScript/TypeScript)
✓ Detected: TypeScript compiler
✓ Detected: Prettier (formatter)
✓ Detected: Jest (unit tests)
✓ Detected: Playwright (E2E tests)
✓ Detected: Docker Compose (test environment)

📝 Generating validation workflow...

Created: .factory/commands/validate.md
Created: .factory/validation/test-helpers/docker-compose.test.yml
Created: .factory/validation/test-helpers/seed-test-db.sh

✅ Validation workflow ready!

Usage:
  /validate   Run all 5 phases
```

## Smart Detection

**Monorepo Support**
- Detects Nx, Turborepo, Lerna, pnpm workspaces
- Generates validation for each package
- Creates root-level `/validate` that runs all

**CI/CD Integration**
- Adds `.github/workflows/validate.yml` if GitHub Actions detected
- Configures for your detected tools
- Sets up caching for dependencies

**Docker/Kubernetes**
- Detects if project uses containers
- Generates Dockerized test environments
- Handles service dependencies (database, Redis, etc.)

## Customization

After generation, edit `.factory/commands/validate.md` to:
- Add custom validation steps
- Skip certain phases
- Add security scanning (e.g., `npm audit`)
- Add performance benchmarks
- Customize failure handling

## Phase Descriptions

### Phase 1: Linting
- Catches code quality issues
- Enforces style conventions
- Identifies potential bugs

### Phase 2: Type Checking
- Validates type safety (TypeScript, Python, etc.)
- Catches type errors before runtime

### Phase 3: Style Checking
- Ensures consistent formatting
- No manual formatting needed

### Phase 4: Unit Tests
- Tests individual functions/components
- Fast feedback on functionality
- Generates coverage reports

### Phase 5: E2E Tests
- Tests complete user workflows
- Validates external integrations
- Tests production-like scenarios

## Benefits

✅ **One command validation** - All checks in one place
✅ **CI/CD ready** - Same validation locally and in CI
✅ **Team consistency** - Everyone runs same checks
✅ **Fast feedback** - Catch issues before review
✅ **Project-specific** - Tailored to YOUR tools

## Notes

- Re-run if you add new tools (e.g., install ESLint)
- Commit `.factory/commands/validate.md` to version control
- `.factory/validation/.validation-cache/` is gitignored
- E2E test helpers are generated but optional to use

---

**Pro Tip**: Add `/validate` to your git pre-push hook for automatic validation!
