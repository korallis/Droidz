---
description: Generate project-specific validation workflow by detecting available tools
---

# /validate-init - Smart Validation Setup

Detects available tools in your project and generates a custom validation workflow.

## Detection Phase

Checking for available tools...

### Linters
!`command -v eslint >/dev/null 2>&1 && echo "✓ ESLint detected" || echo "⚠ ESLint not found"`

### Type Checkers  
!`command -v tsc >/dev/null 2>&1 && echo "✓ TypeScript detected" || echo "⚠ TypeScript not found"`

### Formatters
!`command -v prettier >/dev/null 2>&1 && echo "✓ Prettier detected" || true`
!`test -f .prettierrc -o -f .prettierrc.json -o -f prettier.config.js && echo "✓ Prettier config found" || true`

### Test Frameworks
!`command -v jest >/dev/null 2>&1 && echo "✓ Jest detected" || echo "⚠ Jest not found"`
!`command -v vitest >/dev/null 2>&1 && echo "✓ Vitest detected" || true`
!`command -v playwright >/dev/null 2>&1 && echo "✓ Playwright detected" || true`

---

## Generating Validation Workflow

Based on detected tools, creating `.factory/commands/validate.md`...

### Phase 1: Linting
!`if command -v eslint >/dev/null 2>&1; then
  echo "## Phase 1: Linting ✓" >> .factory/commands/validate.md
  echo '!`npm run lint`' >> .factory/commands/validate.md
  echo "✓ Added ESLint validation"
else
  echo "⚠ No linter detected - skipping Phase 1"
fi`

### Phase 2: Type Checking  
!`if command -v tsc >/dev/null 2>&1; then
  echo "## Phase 2: Type Checking ✓" >> .factory/commands/validate.md  
  echo '!`npx tsc --noEmit`' >> .factory/commands/validate.md
  echo "✓ Added TypeScript validation"
else
  echo "⚠ No type checker detected - skipping Phase 2"
fi`

### Phase 3: Style Checking
!`if command -v prettier >/dev/null 2>&1 || test -f .prettierrc -o -f .prettierrc.json; then
  echo "## Phase 3: Style Checking ✓" >> .factory/commands/validate.md
  echo '!`npx prettier --check .`' >> .factory/commands/validate.md
  echo "✓ Added Prettier validation (using npx)"
else
  echo "⚠ No formatter detected - skipping Phase 3"  
fi`

### Phase 4: Unit Tests
!`if command -v jest >/dev/null 2>&1 || command -v vitest >/dev/null 2>&1; then
  echo "## Phase 4: Unit Tests ✓" >> .factory/commands/validate.md
  echo '!`npm test`' >> .factory/commands/validate.md
  echo "✓ Added test validation"
else
  echo "⚠ No test framework detected - skipping Phase 4"
fi`

### Phase 5: E2E Tests (Optional)
!`if command -v playwright >/dev/null 2>&1; then
  echo "## Phase 5: E2E Tests ✓" >> .factory/commands/validate.md
  echo '!`npx playwright test`' >> .factory/commands/validate.md
  echo "✓ Added E2E validation"  
else
  echo "⚠ No E2E framework detected - skipping Phase 5"
fi`

---

## Finalize

!`echo "---

✅ Validation workflow complete!

Run /validate to execute all checks." >> .factory/commands/validate.md`

✅ **Validation workflow created!**

Your custom `.factory/commands/validate.md` has been generated based on your project's tools.

**Usage:**
```
/validate
```

**To customize:** Edit `.factory/commands/validate.md` directly.

**Note:** All formatters and type checkers use `npx` to auto-install if needed.
