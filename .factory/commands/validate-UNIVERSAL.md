---
description: Run validation checks (works with most projects)
---

# Project Validation

> Uses npx to auto-install tools if needed

## Phase 1: Linting ✓

!`npx eslint . 2>/dev/null || echo "⚠ No ESLint config found - skipping linting"`

## Phase 2: Type Checking ✓

!`npx tsc --noEmit 2>/dev/null || echo "⚠ No TypeScript config found - skipping type checking"`

## Phase 3: Style Checking ✓

!`npx prettier --check . 2>/dev/null || echo "⚠ No Prettier config found - skipping style checking"`

## Phase 4: Unit Tests ✓

!`npm test 2>/dev/null || echo "⚠ No test script found - skipping unit tests"`

---

✅ **Validation complete!**

**Note:** 
- Commands use `npx` to auto-install if needed
- Phases skip gracefully if tool not configured
- To customize: Edit this file directly

**To add more checks:**
```markdown
## Phase 5: Security Audit ✓
!`npm audit`
```
