# Code Review - Systematic Code Quality Analysis

**Use when**: Reviewing pull requests, feature implementations, or code changes before merging to ensure quality, maintainability, and adherence to best practices.

## Core Principles

1. **Review for Understanding First** - Before suggesting changes, ensure you understand the intent and context
2. **Be Specific and Actionable** - Point to exact lines with concrete suggestions
3. **Balance Positives with Improvements** - Acknowledge good patterns while suggesting enhancements
4. **Focus on Impact** - Prioritize critical issues (security, correctness) over style preferences
5. **Educate, Don't Just Correct** - Explain *why* a change matters

## Review Checklist

### 1. **Correctness & Logic**
```
✓ Does the code do what it claims to do?
✓ Are edge cases handled (null, empty, boundary values)?
✓ Are there potential race conditions or timing issues?
✓ Is error handling appropriate and complete?
✓ Are assumptions validated?
```

### 2. **Security**
```
✓ Input validation on all user-provided data?
✓ SQL injection, XSS, CSRF protections?
✓ Secrets/credentials properly secured (env vars, not hardcoded)?
✓ Authentication and authorization checks?
✓ Rate limiting on public endpoints?
```

### 3. **Performance**
```
✓ N+1 query problems?
✓ Unnecessary database calls or API requests?
✓ Memory leaks (event listeners, subscriptions)?
✓ Proper pagination for large datasets?
✓ Efficient algorithms (avoid O(n²) when O(n log n) possible)?
```

### 4. **Maintainability**
```
✓ Clear, descriptive names for variables/functions?
✓ Functions do one thing well (Single Responsibility)?
✓ DRY - no copy-paste duplication?
✓ Magic numbers replaced with named constants?
✓ Complex logic explained with comments?
```

### 5. **Testing**
```
✓ Tests cover happy path and error cases?
✓ Tests are deterministic (no flaky tests)?
✓ Edge cases tested?
✓ Integration points mocked/stubbed appropriately?
✓ Test names describe what they verify?
```

### 6. **Code Style & Standards**
```
✓ Consistent with project conventions?
✓ Follows language idioms?
✓ No unused imports or dead code?
✓ Proper error types thrown/returned?
✓ TypeScript types specific (not 'any')?
```

## Review Process

### Step 1: High-Level Review
```
1. Read PR description and linked issues
2. Understand the "why" behind changes
3. Scan file list - does scope match description?
4. Check for missing files (tests, migrations, docs)
```

### Step 2: Deep Code Review
```
1. Review critical paths first (security, data integrity)
2. Check test coverage and quality
3. Look for architectural issues
4. Review error handling
5. Check for performance concerns
```

### Step 3: Provide Feedback
```
Format: [SEVERITY] Issue - Specific suggestion

Example:
[CRITICAL] SQL Injection vulnerability on line 45
- Use parameterized queries instead of string concatenation
- Change: `query = f"SELECT * FROM users WHERE id = {user_id}"`
- To: `query = "SELECT * FROM users WHERE id = ?"` with params

[SUGGESTION] Consider extracting this 50-line function into smaller pieces
- Lines 100-150 could be broken into:
  - `validateInput()` (lines 100-120)
  - `processData()` (lines 121-140)  
  - `formatOutput()` (lines 141-150)
```

## Feedback Severity Levels

- **[CRITICAL]** - Security issue, data loss risk, broken functionality
- **[MAJOR]** - Performance problem, poor error handling, incorrect logic
- **[MINOR]** - Code smell, maintainability concern, style inconsistency
- **[SUGGESTION]** - Nice-to-have improvement, alternative approach
- **[PRAISE]** - Well-done pattern worth highlighting

## Example Code Review

**Pull Request**: Add user authentication endpoint

### Review Comments:

**[CRITICAL] Missing authentication on password change endpoint (line 67)**
```typescript
// Current - No auth check
app.post('/change-password', (req, res) => {
  const { userId, newPassword } = req.body;
  updatePassword(userId, newPassword);
});

// Should be:
app.post('/change-password', requireAuth, (req, res) => {
  // Only allow users to change their own password
  if (req.user.id !== req.body.userId) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const { newPassword } = req.body;
  updatePassword(req.user.id, newPassword);
});
```

**[MAJOR] Password not hashed before storage (line 23)**
```typescript
// Never store plain text passwords
await db.users.update({ password: req.body.password }); // ❌

// Use bcrypt or argon2
const hashedPassword = await bcrypt.hash(req.body.password, 10);
await db.users.update({ passwordHash: hashedPassword }); // ✅
```

**[MINOR] Magic number for token expiry (line 45)**
```typescript
const token = jwt.sign(payload, secret, { expiresIn: 3600 }); // ❌

// Use named constant
const TOKEN_EXPIRY_SECONDS = 60 * 60; // 1 hour
const token = jwt.sign(payload, secret, { expiresIn: TOKEN_EXPIRY_SECONDS }); // ✅
```

**[PRAISE] Excellent input validation (lines 12-20)**
The zod schema here is comprehensive and includes all necessary checks. This prevents malformed data from reaching the database.

## Common Anti-Patterns to Flag

### 1. **Silent Failures**
```typescript
// Bad - errors disappear
try {
  await criticalOperation();
} catch (e) {
  console.log('oops'); // ❌
}

// Good - proper error handling
try {
  await criticalOperation();
} catch (e) {
  logger.error('Critical operation failed', { error: e, context: {...} });
  throw new CriticalOperationError('Failed to process', { cause: e });
}
```

### 2. **Callback Hell / Pyramid of Doom**
```typescript
// Bad
getData((data) => {
  processData(data, (result) => {
    saveResult(result, (saved) => {
      // 3+ levels deep ❌
    });
  });
});

// Good - use async/await
const data = await getData();
const result = await processData(data);
const saved = await saveResult(result);
```

### 3. **God Functions**
```typescript
// Bad - function doing too much
function handleUserRequest(req) {
  // 200 lines of validation, processing, formatting, saving ❌
}

// Good - split responsibilities
function handleUserRequest(req) {
  const validated = validateRequest(req);
  const processed = processUserData(validated);
  const formatted = formatResponse(processed);
  return saveAndRespond(formatted);
}
```

## When to Block vs Approve with Comments

**Block merge (Request Changes):**
- Security vulnerabilities
- Data loss risks
- Broken functionality
- Missing critical tests
- Major performance issues

**Approve with comments:**
- Style improvements
- Refactoring suggestions
- Minor performance optimizations
- Documentation enhancements
- Nice-to-have tests

## Automated Checks

Before manual review, ensure automated checks pass:
```bash
✓ Linting (ESLint, Pylint, etc.)
✓ Type checking (TypeScript, mypy)
✓ Unit tests passing
✓ Integration tests passing
✓ Code coverage meets threshold
✓ Security scanning (SAST)
✓ Dependency vulnerability scanning
```

## Review Response Template

```markdown
## Summary
[High-level assessment of the PR]

## Critical Issues
- [List blocking issues]

## Major Concerns  
- [List important but not blocking issues]

## Suggestions
- [List nice-to-have improvements]

## Positive Highlights
- [Call out well-done patterns]

## Questions
- [Clarifying questions about intent or approach]

## Approval Status
- [ ] Approved - ready to merge
- [ ] Approved with minor comments
- [ ] Request changes - blocking issues need resolution
```

## Resources

- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)
- [Code Review Best Practices](https://docs.gitlab.com/ee/development/code_review.html)

---

**Remember**: The goal is to improve code quality while maintaining team morale. Be thorough but respectful, specific but not pedantic, and always explain the "why" behind suggestions.
