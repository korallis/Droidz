---
description: Run comprehensive validation pipeline with graceful fallbacks
argument-hint: [PHASE=<1-5|all>]
---

# Validation Pipeline

Run validation checks for: **Phase ${PHASE:-all}**

---

## 🎯 Overview

Run a 5-phase validation pipeline to ensure code quality:

1. **Linting** - Code quality and style rules
2. **Type Checking** - Type safety verification
3. **Style Checking** - Code formatting consistency
4. **Unit Tests** - Component-level testing
5. **Integration Tests** - System-level testing

---

## 🔧 Execution Process

For each phase:

### 1. Detect Available Tools

Check project configuration files:
- **ESLint**: Look for `.eslintrc.*`, `eslint.config.js`, or `"eslint"` in package.json
- **TypeScript**: Look for `tsconfig.json`
- **Prettier**: Look for `.prettierrc.*` or `"prettier"` in package.json
- **Jest**: Look for `jest.config.*` or `"jest"` in package.json scripts
- **Vitest**: Look for `vitest.config.*` or `"vitest"` in package.json scripts

### 2. Run Commands with Auto-Install

Use `npx` for automatic tool installation:

**Phase 1: Linting**
```bash
npx eslint .
# Or if specific path configured: npx eslint src/
```

**Phase 2: Type Checking**
```bash
npx tsc --noEmit
```

**Phase 3: Style Checking**
```bash
npx prettier --check .
# Or: npx prettier --check "src/**/*.{ts,tsx,js,jsx}"
```

**Phase 4: Unit Tests**
```bash
npm test
# Or: bun test
# Or: yarn test
# Or: pnpm test
```

**Phase 5: Integration Tests (if configured)**
```bash
npm run test:integration
# Or: npm run test:e2e
# Or: bun test:e2e
```

### 3. Handle Results Gracefully

For each phase:

**✅ Success Case:**
- Show success message with metrics
- Example: "✓ ESLint passed - 0 errors, 0 warnings (142 files checked)"

**❌ Failure Case:**
- Show failure message with error count
- Display first 10 lines of errors (most relevant)
- Provide suggestions for fixing

**⚠️ Skip Case:**
- If tool not configured, skip gracefully
- Example: "⚠️ No ESLint config found - skipping linting"
- Suggest installation command

---

## 📊 Report Format

Present results in a clear table:

| Phase | Tool | Status | Details |
|-------|------|--------|---------|
| 1. Linting | ESLint | ✅ Pass | 0 errors, 0 warnings (142 files) |
| 2. Type Check | TypeScript | ❌ Fail | 3 errors in 2 files |
| 3. Style | Prettier | ✅ Pass | All 142 files formatted correctly |
| 4. Unit Tests | Jest | ✅ Pass | 42 tests passed (0 failed) |
| 5. Integration | None | ⚠️ Skip | No integration tests configured |

### For Failures, Show Excerpts

```typescript
src/utils/auth.ts:23:5 - error TS2339: Property 'foo' does not exist on type 'User'
src/utils/auth.ts:45:12 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'
src/api/login.ts:18:3 - error TS2322: Type 'undefined' is not assignable to type 'string'
```

---

## 📋 Final Summary

Provide a comprehensive summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Validation Results

Overall: ✅ 4/5 phases passed

  ✅ Phase 1: Linting passed
  ❌ Phase 2: Type checking failed (3 errors)
  ✅ Phase 3: Style checking passed
  ✅ Phase 4: Unit tests passed
  ⚠️  Phase 5: Integration tests skipped (not configured)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Action Items:

1. Fix TypeScript errors:
   • src/utils/auth.ts:23 - Property 'foo' doesn't exist
   • src/utils/auth.ts:45 - Type mismatch (string vs number)
   • src/api/login.ts:18 - Undefined not assignable

2. Verify fixes:
   npx tsc --noEmit

3. Re-run validation:
   /prompts:validate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔄 Phase-Specific Validation

If `PHASE` is specified, run only that phase:

**Examples:**
- `/prompts:validate PHASE=1` - Run linting only
- `/prompts:validate PHASE=2` - Run type checking only
- `/prompts:validate PHASE=4` - Run tests only

---

## 💡 Best Practices

**DO:**
- ✅ Run full validation before committing
- ✅ Fix linting errors first (often causes other issues)
- ✅ Address TypeScript errors (they prevent build)
- ✅ Ensure tests pass (broken tests = broken features)
- ✅ Use npx for consistent tool versions

**DON'T:**
- ❌ Skip validation "to save time"
- ❌ Commit with linting errors
- ❌ Ignore TypeScript warnings
- ❌ Push failing tests
- ❌ Disable validation tools without reason

---

## 🎯 Exit Criteria

Validation is successful when:
- ✅ All configured phases pass (or skip gracefully)
- ✅ No critical errors remain
- ✅ Code meets project standards
- ✅ Tests verify functionality
- ✅ Ready for review/deployment
