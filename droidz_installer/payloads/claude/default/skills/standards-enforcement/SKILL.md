---
name: standards-enforcement
description: Setting up project guidelines, code reviews, enforcing best practices, maintaining consistency.. Use when standards enforcement. Use when working with standards enforcement in your development workflow.
---

# Standards Enforcement - Maintaining Code Quality

## When to use this skill

- Setting up project guidelines, code reviews, enforcing best practices, maintaining consistency.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Setting up project guidelines, code reviews, enforcing best practices, maintaining consistency.

## Tools

### ESLint
```json
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "error"
  }
}
```

### Prettier
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### Husky + lint-staged
```json
{
  "lint-staged": {
    "*.{js,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

## Resources
- [ESLint](https://eslint.org/)
- [Prettier](https://prettier.io/)
- [Husky](https://typicode.github.io/husky/)
