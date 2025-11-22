# Validation System Guide

> **Comprehensive validation workflow for Droidz v3.0**

Droidz v3.0 introduces a powerful validation system that automatically detects your project's tools and generates a comprehensive 5-phase validation pipeline.

---

## Quick Start

```bash
# Step 1: Generate validation workflow (run once per project)
/validate-init

# Step 2: Run validation anytime
/validate
```

That's it! The system automatically detects your linters, type checkers, formatters, and test frameworks.

---

## The 5-Phase Validation Pipeline

### Phase 1: Linting ✓

**Purpose**: Catch code quality issues, enforce style conventions, identify potential bugs

**Auto-detects:**
- ESLint (JavaScript/TypeScript)
- Ruff, Pylint, Flake8 (Python)
- RuboCop (Ruby)
- Golangci-lint (Go)
- Clippy (Rust)

**Example output:**
```bash
Phase 1: Linting ✓
Running: npm run lint

✓ No linting errors found
```

### Phase 2: Type Checking ✓

**Purpose**: Validate type safety, catch type errors before runtime

**Auto-detects:**
- TypeScript compiler (`tsc`)
- Mypy (Python)
- Flow (JavaScript)
- Go type checking
- Rust type checking

**Example output:**
```bash
Phase 2: Type Checking ✓
Running: tsc --noEmit

✓ No type errors found
```

### Phase 3: Style Checking ✓

**Purpose**: Ensure consistent formatting across the codebase

**Auto-detects:**
- Prettier (JavaScript/TypeScript/CSS/JSON)
- Black (Python)
- Rustfmt (Rust)
- Gofmt (Go)

**Example output:**
```bash
Phase 3: Style Checking ✓
Running: prettier --check .

✓ All files properly formatted
```

### Phase 4: Unit Tests ✓

**Purpose**: Test individual functions/components, generate coverage reports

**Auto-detects:**
- Jest (JavaScript/TypeScript)
- Vitest (Vite projects)
- Pytest (Python)
- RSpec (Ruby)
- Go test
- Cargo test (Rust)

**Example output:**
```bash
Phase 4: Unit Tests ✓
Running: npm test -- --coverage

✓ 142 tests passed
✓ Coverage: 87%
```

### Phase 5: E2E Tests ✓

**Purpose**: Test complete user workflows, validate external integrations

**Auto-detects:**
- Playwright (browser automation)
- Cypress (E2E testing)
- Selenium
- Puppeteer

**Example output:**
```bash
Phase 5: E2E Tests ✓

Setup Test Environment:
Running: docker-compose -f docker-compose.test.yml up -d

Run E2E Workflows:
Running: npx playwright test

✓ 24 E2E tests passed

Cleanup:
Running: docker-compose -f docker-compose.test.yml down -v

✓ Test environment cleaned up
```

---

## `/validate-init` - Generation Process

When you run `/validate-init`, Droidz:

### 1. Scans Your Project

```
🔍 Analyzing project for validation tools...

Checking for linters...
✓ Found: ESLint (.eslintrc.js)

Checking for type checkers...
✓ Found: TypeScript (tsconfig.json)

Checking for formatters...
✓ Found: Prettier (.prettierrc)

Checking for test frameworks...
✓ Found: Jest (jest.config.js)
✓ Found: Playwright (playwright.config.ts)

Checking for Docker...
✓ Found: Docker Compose (docker-compose.yml)
```

### 2. Generates Custom Validation

Creates `.factory/commands/validate.md` with commands specific to YOUR project:

```markdown
---
description: Run comprehensive validation
---

# Project Validation

## Phase 1: Linting ✓
!`npm run lint`

## Phase 2: Type Checking ✓
!`tsc --noEmit`

## Phase 3: Style Checking ✓
!`prettier --check .`

## Phase 4: Unit Tests ✓
!`npm test -- --coverage`

## Phase 5: E2E Tests ✓

### Setup
!`docker-compose -f docker-compose.test.yml up -d`

### Run Tests
!`npx playwright test`

### Cleanup
!`docker-compose -f docker-compose.test.yml down -v`
```

### 3. Creates Test Helpers

For E2E tests, generates:

```
.factory/validation/test-helpers/
├── docker-compose.test.yml    # Isolated test environment
├── seed-test-db.sh            # Database seeding
└── setup-test-env.sh          # Environment setup
```

---

## Usage Examples

### Example 1: React + TypeScript Project

```bash
# Initialize validation
/validate-init

# Output:
✓ Detected: ESLint (JavaScript/TypeScript)
✓ Detected: TypeScript compiler
✓ Detected: Prettier
✓ Detected: Jest
✓ Detected: Playwright

Created: .factory/commands/validate.md

# Run validation
/validate

# Output:
Phase 1: Linting ✓ (0 errors)
Phase 2: Type Checking ✓ (0 errors)
Phase 3: Style Checking ✓ (all formatted)
Phase 4: Unit Tests ✓ (87 passed, 85% coverage)
Phase 5: E2E Tests ✓ (12 passed)

✅ All validation passed!
```

### Example 2: Python + FastAPI Project

```bash
/validate-init

# Output:
✓ Detected: Ruff (linter)
✓ Detected: Mypy (type checker)
✓ Detected: Black (formatter)
✓ Detected: Pytest (tests)

Created: .factory/commands/validate.md

/validate

# Output:
Phase 1: Linting ✓ (ruff check .)
Phase 2: Type Checking ✓ (mypy .)
Phase 3: Style Checking ✓ (black --check .)
Phase 4: Unit Tests ✓ (pytest --cov=src)
Phase 5: E2E Tests ✓ (pytest tests/e2e/)

✅ All validation passed!
```

### Example 3: Monorepo (Nx/Turborepo)

```bash
/validate-init

# Output:
✓ Detected: Nx workspace
✓ Detected: Multiple projects (frontend, backend, shared)

Created: .factory/commands/validate.md (runs validation for all projects)

/validate

# Output:
Validating: frontend
  Phase 1-4: ✓

Validating: backend
  Phase 1-4: ✓

Validating: shared
  Phase 1-3: ✓

✅ All projects validated!
```

---

## Customization

After generation, you can customize `.factory/commands/validate.md`:

### Add Custom Steps

```markdown
## Phase 6: Security Audit
!`npm audit --audit-level=high`

## Phase 7: Performance Benchmarks
!`npm run bench`
```

### Skip Phases

Remove or comment out phases you don't need:

```markdown
## Phase 3: Style Checking ✓
<!-- Skipped - formatter runs on commit -->
```

### Conditional Execution

Add conditions for certain phases:

```markdown
## Phase 5: E2E Tests ✓
<!-- Only run in CI -->
!`if [ "$CI" = "true" ]; then npx playwright test; fi`
```

---

## CI/CD Integration

### GitHub Actions

Droidz can auto-generate `.github/workflows/validate.yml`:

```yaml
name: Validate
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: droid --initial-prompt "/validate"
```

### GitLab CI

```yaml
validate:
  script:
    - droid --initial-prompt "/validate"
```

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
droid --initial-prompt "/validate"
```

---

## Advanced Features

### Validation Caching

The system caches results in `.factory/validation/.validation-cache/` to speed up repeated runs:

```
.factory/validation/.validation-cache/
├── lint-cache/
├── type-cache/
└── test-cache/
```

**Cache is automatically invalidated when:**
- Source files change
- Config files change
- Dependencies update

### Parallel Execution

For large projects, validation phases can run in parallel:

```bash
# Enable parallel validation (experimental)
DROIDZ_PARALLEL_VALIDATE=true /validate
```

Runs phases 1-3 in parallel (linting, type checking, style), then phases 4-5.

### Selective Validation

Run specific phases only:

```bash
# Lint only
/validate --phase=1

# Lint + types
/validate --phase=1,2

# Skip E2E (phases 1-4 only)
/validate --skip-e2e
```

---

## E2E Testing Philosophy

Droidz v3.0 emphasizes **workflow-based E2E testing**:

### What to Test

✅ **DO Test:**
- Complete user journeys (signup → login → action → logout)
- External API integrations (Stripe, Auth0, etc.)
- Critical business workflows
- Cross-service interactions
- Production-like scenarios

❌ **DON'T Test:**
- Internal implementation details
- Unit-testable logic
- UI styling/layout (unless critical)

### E2E Test Structure

```typescript
// tests/e2e/user-auth.spec.ts
import { test, expect } from '@playwright/test'

test('User authentication flow', async ({ page }) => {
  // Setup: Create test user
  await setupTestUser('alice@example.com')
  
  // Workflow: Complete auth flow
  await page.goto('/login')
  await page.fill('[name="email"]', 'alice@example.com')
  await page.fill('[name="password"]', 'password123')
  await page.click('button[type="submit"]')
  
  // Verify: User logged in
  await expect(page).toHaveURL('/dashboard')
  await expect(page.locator('h1')).toContainText('Welcome, Alice')
  
  // Cleanup: Delete test user
  await cleanupTestUser('alice@example.com')
})
```

### Test Environment Isolation

E2E tests run in isolated environments:

```yaml
# docker-compose.test.yml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: app_test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - "5433:5432"
  
  redis:
    image: redis:7
    ports:
      - "6380:6379"
```

Benefits:
- ✅ No side effects on development DB
- ✅ Fast cleanup (just destroy containers)
- ✅ Reproducible environments
- ✅ Parallel test execution

---

## Troubleshooting

### Validation Fails on Fresh Clone

**Problem**: `/validate` fails because tools aren't installed

**Solution**:
```bash
# Install dependencies first
npm install  # or yarn, pnpm, bun

# Then validate
/validate
```

### E2E Tests Hang

**Problem**: E2E tests never complete

**Solution**:
```bash
# Check if test environment is running
docker-compose -f docker-compose.test.yml ps

# Restart test environment
docker-compose -f docker-compose.test.yml down -v
docker-compose -f docker-compose.test.yml up -d

# Run tests again
npx playwright test
```

### Phase 1 Fails with "Command not found"

**Problem**: Linter not in PATH

**Solution**:
```bash
# Check if tool is installed
npm list eslint

# If not, install it
npm install --save-dev eslint

# Re-run validation
/validate
```

### Validation Skips Phase 5

**Problem**: No E2E tests detected

**Solution**:
```bash
# Install E2E framework
npm install --save-dev @playwright/test

# Initialize Playwright
npx playwright install

# Re-generate validation
/validate-init

# Should now include Phase 5
/validate
```

---

## Best Practices

### 1. Run Validation Locally Before Pushing

```bash
# Always validate before git push
/validate
git push
```

### 2. Keep Validation Fast

- Use `--changed-only` flags for linters (only check modified files)
- Use `--onlyChanged` for Jest (only test changed code)
- Skip E2E in local runs (save for CI)

### 3. Fix Issues Immediately

Don't let validation failures accumulate:
- Fix linting errors as they appear
- Address type errors before adding more code
- Keep test coverage high

### 4. Customize for Your Team

Edit `.factory/commands/validate.md` to match your team's workflow:
- Add security scans
- Add performance benchmarks
- Add custom checks

---

## Benefits Summary

✅ **One Command** - All validation in one place  
✅ **Auto-Generated** - Tailored to YOUR project  
✅ **CI/CD Ready** - Same validation locally and in CI  
✅ **Team Consistency** - Everyone runs same checks  
✅ **Fast Feedback** - Catch issues early  
✅ **Extensible** - Add custom validation steps  

---

## Further Reading

- [Factory.ai Hooks Documentation](https://docs.factory.ai/reference/hooks-reference)
- [SKILLS.md](./SKILLS.md) - Skills system guide
- [DROIDS.md](./DROIDS.md) - Custom droids guide
- [COMMANDS.md](./COMMANDS.md) - All Droidz commands

---

**Transform validation from a chore into an automated safety net** ✨
