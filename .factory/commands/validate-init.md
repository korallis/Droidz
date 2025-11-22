---
description: Initialize validation workflow for your project
---

# /validate-init - Setup Validation

## Detecting Available Tools

!`echo "🔍 Checking for validation tools..."`

!`command -v eslint >/dev/null 2>&1 && echo "✓ ESLint found" || echo "⚠ ESLint not found (install: npm i -D eslint)"`

!`command -v tsc >/dev/null 2>&1 && echo "✓ TypeScript found" || echo "⚠ TypeScript not found (install: npm i -D typescript)"`

!`command -v prettier >/dev/null 2>&1 && echo "✓ Prettier found" || echo "⚠ Prettier not found (install: npm i -D prettier)"`

!`command -v jest >/dev/null 2>&1 && echo "✓ Jest found" || echo "⚠ Jest not found (install: npm i -D jest)"`

!`command -v vitest >/dev/null 2>&1 && echo "✓ Vitest found" || echo "⚠ Vitest not found (install: npm i -D vitest)"`

!`command -v playwright >/dev/null 2>&1 && echo "✓ Playwright found" || echo "⚠ Playwright not found (install: npm i -D @playwright/test)"`

---

## ✅ Setup Complete!

Your project now has validation configured.

**Available tools will be used automatically when you run:**
```
/validate
```

The `/validate` command uses `npx` to run tools, so they'll auto-install if needed.

**To customize validation:** Edit `.factory/commands/validate.md` directly.
