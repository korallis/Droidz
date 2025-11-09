# Verify Implementation

Validate that the implemented feature meets all specification requirements.

## Prerequisites
- Implementation must be complete (all tasks marked `[x]`)
- Code must be committed to git
- Tests should have been run during implementation

## Verification Process

### 1. Requirements Check

Read and verify against spec:

```bash
# Load the spec
cat droidz/specs/[spec-slug]/spec.md

# Load the tasks
cat droidz/specs/[spec-slug]/tasks.md
```

Create checklist:
- ✅ All tasks marked complete
- ✅ All user stories addressed
- ✅ All specific requirements implemented
- ✅ No out-of-scope features added

### 2. Code Quality Check

Run project quality tools:

```bash
# TypeScript type checking
npx tsc --noEmit || bun tsc --noEmit

# Linting
npx eslint . || bun eslint . || npm run lint

# Formatting check
npx prettier --check . || bun prettier --check .
```

### 3. Standards Compliance

Verify against `standards/*.md`:

```bash
# Check each standard is followed
for standard in standards/*.md; do
  echo "Checking compliance with: $standard"
  # Manual review or automated checks
done
```

Check:
- Coding conventions followed
- Architecture patterns used correctly
- Security standards applied
- Performance guidelines met

### 4. Test Execution

Run all test suites:

```bash
# Unit tests
npm test || yarn test || bun test

# Integration tests (if applicable)
npm run test:integration || yarn test:integration

# E2E tests (if applicable)
npm run test:e2e || yarn test:e2e
```

Record results:
- Total tests: [N]
- Passed: [N]
- Failed: [N]
- Coverage: [N%]

### 5. Functional Testing

If feature has UI components:

```bash
# Start development server
npm run dev || yarn dev || bun dev
```

Then use browser testing:
- Navigate to feature
- Test all user flows
- Take screenshots of key screens
- Verify against visual requirements

Save screenshots:
```bash
# Screenshots go here
droidz/specs/[spec-slug]/verification/screenshots/
```

### 6. Integration Verification

Test feature integration with existing code:

```typescript
// Use Exa to find similar integration tests for reference
const testExamples = await exa___get_code_context_exa({
  query: "[Framework] integration testing patterns",
  tokensNum: 3000
});
```

Verify:
- APIs return expected data
- Components render correctly
- State management works
- Error handling functions
- Loading states display

### 7. Documentation Check

Verify documentation is complete:

```bash
# Check for code comments
grep -r "TODO\|FIXME" droidz/specs/[spec-slug]/ || echo "✅ No TODOs"

# Check for README updates
git diff main -- README.md

# Verify API documentation
ls docs/ | grep -i api || echo "Check if API docs needed"
```

### 8. Create Verification Report

Write `droidz/specs/[spec-slug]/verification/report.md`:

```markdown
# Verification Report: [Feature Name]

**Date:** [ISO date]
**Spec:** droidz/specs/[spec-slug]
**Status:** ✅ PASSED | ⚠️ ISSUES FOUND | ❌ FAILED

## Requirements Verification

| Requirement | Status | Notes |
|------------|--------|-------|
| [Requirement 1] | ✅ | Implemented as specified |
| [Requirement 2] | ✅ | Implemented as specified |
| [Requirement 3] | ⚠️ | Minor deviation: [explain] |

## Code Quality

- **TypeScript:** ✅ No type errors
- **Linting:** ✅ All rules passed
- **Formatting:** ✅ Code formatted
- **Standards:** ✅ All standards followed

## Test Results

- **Unit Tests:** ✅ [N/N] passed
- **Integration Tests:** ✅ [N/N] passed
- **E2E Tests:** ✅ [N/N] passed
- **Coverage:** [N%]

## Functional Testing

Screenshots saved to: `verification/screenshots/`

| User Flow | Status | Screenshot |
|-----------|--------|------------|
| [Flow 1] | ✅ | screenshot-1.png |
| [Flow 2] | ✅ | screenshot-2.png |

**Notes:** [Any observations from manual testing]

## Integration Verification

- ✅ API endpoints working
- ✅ Component rendering correct
- ✅ State management functional
- ✅ Error handling tested
- ✅ Loading states verified

## Documentation

- ✅ Code comments added
- ✅ README updated (if needed)
- ✅ API docs updated (if applicable)
- ✅ No TODOs or FIXMEs remaining

## Issues Found

[If any issues were found, list them here with severity]

1. **[Issue 1]** - Severity: [Low/Medium/High]
   - Description: [What's wrong]
   - Impact: [How it affects the feature]
   - Resolution: [What needs to be done]

## Sign-off

- [x] All requirements met
- [x] Code quality verified
- [x] Tests passing
- [x] Standards compliant
- [x] Documentation complete

**Verified by:** [Droid verifier]
**Next steps:** [Mark complete in roadmap | Fix issues | Deploy]
```

## Update Roadmap

After successful verification, update `droidz/product/roadmap.md`:

```bash
# Mark feature as complete
sed -i 's/\[ \] \*\*[Feature Name]\*\*/[x] **[Feature Name]**/' droidz/product/roadmap.md
```

## Output

- ✅ Verification report created
- ✅ All tests passed
- ✅ Screenshots captured (if applicable)
- ✅ Roadmap updated
- ✅ Feature ready for production or next phase
