---
description: Check code against project standards and best practices
argument-hint: "[file-path] [--fix] [--severity <level>]"
allowed-tools: Read, Edit, Grep
---

# /check-standards

Validates code against all applicable CLAUDE.md standards and framework-specific best practices.

## Usage

```bash
# Check current file
/check-standards

# Check specific file
/check-standards src/components/LoginForm.tsx

# Check and auto-fix issues
/check-standards --fix

# Show only critical/high severity
/check-standards --severity critical
/check-standards --severity high
```

## What It Does

1. **Loads All Applicable Standards**
   - Root CLAUDE.md
   - Directory-specific CLAUDE.md files
   - Framework standards (.factory/standards/react.md, etc.)
   - Organization memory (team conventions)

2. **Analyzes Code**
   - Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
   - TypeScript type safety (any usage, missing types)
   - Framework best practices (React hooks, component patterns)
   - Performance issues (missing memoization, expensive operations)
   - Code style (formatting, naming conventions)

3. **Reports Issues by Severity**
   - 🚨 **CRITICAL**: Security vulnerabilities, must fix before commit
   - ⚠️ **HIGH**: Major code quality issues
   - ℹ️ **MEDIUM**: Best practice violations
   - 💡 **LOW**: Style suggestions

4. **Suggests Fixes**
   - Shows current code
   - Shows proposed fix
   - Explains rationale
   - Links to standard

5. **Auto-Fix** (with --fix flag)
   - Applies fixes automatically
   - Shows diff of changes
   - Creates backup

## Example Output

```
📋 Standards Check: src/components/auth/LoginForm.tsx

Loaded Standards:
✅ /CLAUDE.md
✅ src/CLAUDE.md
✅ src/components/CLAUDE.md
✅ .factory/standards/react.md
✅ .factory/standards/typescript.md
✅ .factory/standards/security.md

Analyzing code... (134 lines)

Issues Found: 4

🚨 CRITICAL (1):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Hardcoded API key detected
   Location: Line 15
   Standard: .factory/standards/security.md - Environment Variables
   
   Current:
   15 | const apiKey = 'sk_live_abc123def456';
   
   Fix:
   15 | const apiKey = process.env.NEXT_PUBLIC_API_KEY;
   16 | if (!apiKey) {
   17 |   throw new Error('API key not configured');
   18 | }
   
   Required Actions:
   1. Remove hardcoded key from code
   2. Add to .env.local: NEXT_PUBLIC_API_KEY=sk_live_...
   3. Add to .env.example: NEXT_PUBLIC_API_KEY=sk_test_...
   4. Ensure .env.local in .gitignore
   
   ⛔ MUST FIX BEFORE COMMIT

⚠️ HIGH (1):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. Missing error handling on API call
   Location: Line 23-28
   Standard: src/components/CLAUDE.md - Error Handling Required
   
   Current:
   23 | const response = await fetch('/api/login', {
   24 |   method: 'POST',
   25 |   body: JSON.stringify({ email, password })
   26 | });
   27 | const data = await response.json();
   28 | setUser(data);
   
   Fix:
   23 | try {
   24 |   const response = await fetch('/api/login', {
   25 |     method: 'POST',
   26 |     body: JSON.stringify({ email, password })
   27 |   });
   28 |   
   29 |   if (!response.ok) {
   30 |     throw new Error('Login failed');
   31 |   }
   32 |   
   33 |   const data = await response.json();
   34 |   setUser(data);
   35 | } catch (error) {
   36 |   toast.error('Login failed. Please try again.');
   37 |   console.error('Login error:', error);
   38 | }

ℹ️ MEDIUM (1):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. Component not memoized
   Location: Line 45-67
   Standard: .factory/standards/react.md - Performance
   
   Component re-renders on every parent update but has no dependencies.
   
   Fix: Wrap with React.memo()
   
   Current:
   45 | function LoginForm({ onSuccess }: Props) {
   
   Fix:
   45 | const LoginForm = React.memo(function LoginForm({ onSuccess }: Props) {
   67 | }
   67 | });

💡 LOW (1):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. Inconsistent naming convention
   Location: Line 12
   Standard: .factory/standards/typescript.md - Naming Conventions
   
   Current:
   12 | const API_endpoint = '/api/login';
   
   Fix:
   12 | const API_ENDPOINT = '/api/login'; // SCREAMING_SNAKE_CASE for constants

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
🚨 1 CRITICAL - Must fix before commit
⚠️ 1 HIGH - Should fix
ℹ️ 1 MEDIUM - Recommended
💡 1 LOW - Optional

Auto-fixable: 2 issues (3, 4)
Requires Manual Fix: 2 issues (1, 2)

Actions:
A) Auto-fix issues 3, 4 and show proposed fixes for 1, 2
B) Show all proposed fixes for review
C) Fix critical issues only
Q) Quit without changes

Select A, B, C, or Q:
```

## Severity Levels

### 🚨 CRITICAL
- Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
- Data corruption risks
- Authentication/authorization bypasses
- **Action:** Block commit until fixed

### ⚠️ HIGH
- Type safety violations (using `any`)
- Missing error handling
- Performance issues (blocking operations)
- **Action:** Should fix before merge

### ℹ️ MEDIUM
- Best practice violations
- Missing optimizations (memoization)
- Incomplete documentation
- **Action:** Recommended to fix

### 💡 LOW
- Code style inconsistencies
- Naming convention mismatches
- Optional improvements
- **Action:** Nice to have

## Auto-Fix Capabilities

Can automatically fix:
- ✅ Code formatting (via Prettier/ESLint)
- ✅ Import organization
- ✅ Naming convention fixes
- ✅ Simple type annotations
- ✅ React.memo wrapping

Requires manual review:
- ⚠️ Error handling (business logic)
- ⚠️ Security fixes (environment variables)
- ⚠️ API changes (breaking changes)
- ⚠️ Complex refactoring

## Arguments

- `$1`: File path (optional, defaults to current file)
- `--fix`: Auto-apply fixable issues
- `--severity <level>`: Show only issues of specified severity or higher
  - `critical`: Only critical issues
  - `high`: Critical + high
  - `medium`: Critical + high + medium
  - `low`: All issues (default)

## Implementation

**Step 1: Load standards**
```typescript
// Load hierarchical CLAUDE.md
const standards = loadHierarchicalStandards(filePath);

// Load framework standards
const frameworkStandards = loadFrameworkStandards(filePath);

// Load org memory
const orgStandards = loadOrgMemory();
```

**Step 2: Analyze code**
```typescript
const issues = [
  ...checkSecurity(code, standards),
  ...checkTypeScript(code, standards),
  ...checkFramework(code, standards),
  ...checkPerformance(code, standards),
  ...checkStyle(code, standards)
];
```

**Step 3: Sort by severity**
```typescript
const sorted = issues.sort((a, b) => {
  const severityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
  return severityOrder[a.severity] - severityOrder[b.severity];
});
```

**Step 4: Apply fixes** (if --fix)
```typescript
const fixable = issues.filter(i => i.autoFixable);
applyFixes(filePath, fixable);
```

## Integration with Git

Can be used as pre-commit hook:

```bash
#!/bin/bash
# .git/hooks/pre-commit

changed_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$')

for file in $changed_files; do
  /check-standards "$file" --severity critical
  
  if [ $? -ne 0 ]; then
    echo "⛔ Critical standards violations found in $file"
    exit 1
  fi
done
```

## Output Format

```
STATUS=<PASS|WARN|FAIL>
CRITICAL_COUNT=${count}
HIGH_COUNT=${count}
MEDIUM_COUNT=${count}
LOW_COUNT=${count}
AUTO_FIXABLE=${count}
```

**Exit codes:**
- `0`: No critical issues (PASS)
- `1`: Critical issues found (FAIL)
- `2`: High issues found (WARN)

## Notes

- Always checks security first
- Blocks on critical security issues
- Creates backup before auto-fixing
- Shows diff of applied changes
