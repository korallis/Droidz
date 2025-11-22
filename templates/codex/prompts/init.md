---
description: Initialize Droidz framework for Codex CLI in your project
argument-hint: [--quick | --status]
---

# Initialize Droidz Framework

Setup: **${ARGUMENTS:-interactive mode}**

---

## 🎯 Purpose

Initialize the Droidz framework in your project by:
1. Creating necessary directory structure
2. Detecting tech stack and conventions
3. Creating AGENTS.md with project context
4. Setting up specs system
5. Validating environment

---

## 📋 Step 1: Environment Check

Verify prerequisites:

### A. Check Git Repository
```bash
git rev-parse --is-inside-work-tree
```
- ✅ If yes: Proceed
- ❌ If no: Initialize with `git init` or abort

### B. Check Codex CLI
```bash
codex --version
```
- ✅ Should show version (e.g., 0.63.0)
- ❌ If missing: Install with `npm install -g @openai/codex`

### C. Check Project Structure
- Look for package.json, requirements.txt, go.mod, etc.
- Identify if this is a monorepo or single project
- Check for existing AGENTS.md or CLAUDE.md

---

## 🗂️ Step 2: Create Directory Structure

Create Droidz directories:

```
.droidz/
├── specs/
│   ├── active/       # Work-in-progress specs (not tracked in git)
│   ├── archive/      # Completed specs (not tracked in git)
│   ├── templates/    # Spec templates
│   └── examples/     # Example specs
└── memory/
    └── tech-stack.md # Detected tech stack info
```

Create each directory:
```bash
mkdir -p .droidz/specs/{active,archive,templates,examples}
mkdir -p .droidz/memory
```

---

## 🔍 Step 3: Detect Tech Stack

Analyze the project and identify:

### A. Language & Framework
- Check package.json for JavaScript/TypeScript
- Check requirements.txt for Python
- Check go.mod for Go
- Check Cargo.toml for Rust

### B. Frontend Framework (if applicable)
- React (check for react in dependencies)
- Next.js (check for next in dependencies)
- Vue (check for vue in dependencies)
- Svelte (check for svelte in dependencies)

### C. Backend Framework (if applicable)
- Express (check for express in dependencies)
- Fastify (check for fastify in dependencies)
- Django (check for django in requirements.txt)
- FastAPI (check for fastapi in requirements.txt)

### D. Package Manager
- Check for lock files:
  - `bun.lockb` → Bun
  - `pnpm-lock.yaml` → pnpm
  - `yarn.lock` → Yarn
  - `package-lock.json` → npm

### E. Testing Framework
- Jest (check jest.config.*)
- Vitest (check vitest.config.*)
- Pytest (check for pytest in requirements.txt)
- Go test (check for *_test.go files)

### F. Build Tools
- TypeScript (check tsconfig.json)
- Vite (check vite.config.*)
- Webpack (check webpack.config.*)
- Rollup (check rollup.config.*)

Save findings to `.droidz/memory/tech-stack.md`:

```markdown
# Tech Stack Detection

**Detected**: 2025-11-22

## Primary Language
- TypeScript (tsconfig.json found)

## Frontend
- Framework: React 18.2.0
- Meta-framework: Next.js 14.0.0
- UI: Tailwind CSS 3.4.0

## Backend
- Runtime: Node.js 20.10.0
- Framework: Not detected (appears to be frontend-only)

## Package Manager
- Bun (bun.lockb found)

## Testing
- Framework: Jest 29.7.0
- Config: jest.config.js
- Coverage: Yes (--coverage flag available)

## Build Tools
- TypeScript 5.3.0
- Vite 5.0.0 (for dev server)
- Next.js (for production builds)

## Code Quality
- ESLint: Yes (.eslintrc.json found)
- Prettier: Yes (.prettierrc found)

## Conventions Detected
- Import style: ES modules
- Component style: Functional components with hooks
- File naming: kebab-case
- Export style: Named exports preferred
```

---

## 📝 Step 4: Create AGENTS.md

Create `AGENTS.md` in project root with detected context:

```markdown
# AGENTS.md - Project Instructions for Codex CLI

## Tech Stack

### Frontend
- **Language**: TypeScript 5.3
- **Framework**: React 18.2 with Next.js 14.0 (App Router)
- **Styling**: Tailwind CSS 3.4
- **State**: React hooks + Context API

### Build & Package Management
- **Package Manager**: Bun (use `bun install`, `bun run`, `bun test`)
- **Build Tool**: Vite for dev, Next.js for production
- **TypeScript**: Strict mode enabled

### Testing
- **Framework**: Jest 29.7
- **Coverage**: Enabled (run with `--coverage` flag)
- **Location**: tests/ directory

---

## Development Guidelines

### Code Style
- **Indentation**: 2 spaces
- **Components**: Functional components with hooks
- **File Naming**: kebab-case for files, PascalCase for components
- **Imports**: Organize by: React, third-party, local
- **Comments**: Minimal (JSDoc for public APIs only)

### TypeScript
- Use strict mode
- No `any` types (use `unknown` and narrow)
- Prefer `type` over `interface` for unions
- Export types alongside implementations

### React Patterns
- Functional components only
- Use hooks (useState, useEffect, useCallback, useMemo)
- Custom hooks for reusable logic
- Keep components small and focused
- Extract complex logic to utilities

### Testing
- Write tests alongside implementation (TDD)
- Use React Testing Library for components
- Mock external dependencies
- Aim for 80%+ coverage
- Test behavior, not implementation

### Git Workflow
- Commit messages: `type(scope): description`
- Keep commits atomic and focused
- Test before committing
- Use feature branches

### Security
- Never hardcode secrets (use environment variables)
- Validate all user input
- Use prepared statements for database queries
- Implement rate limiting on APIs
- Set security headers

---

## Commands

### Development
```bash
bun run dev          # Start dev server
bun run build        # Production build
bun run lint         # Run ESLint
bun run lint:fix     # Auto-fix linting issues
bun test             # Run tests
bun test --coverage  # Run with coverage
```

### Package Management
```bash
bun install          # Install dependencies
bun add <package>    # Add dependency
bun add -D <package> # Add dev dependency
```

---

## Droidz Framework

This project uses the Droidz framework with Codex CLI.

### Available Prompts
- `/prompts:build` - Generate feature specifications
- `/prompts:validate` - Run validation pipeline
- `/prompts:codegen` - Implement features with tests
- `/prompts:test-specialist` - Write/fix tests
- `/prompts:orchestrator` - Complex multi-phase features

### Specs Location
Feature specifications are stored in `.droidz/specs/`:
- `active/` - Work-in-progress
- `archive/` - Completed
- `templates/` - Templates
- `examples/` - Reference examples

---

## Project-Specific Notes

*(Add any project-specific guidelines here)*

- API base URL: `process.env.NEXT_PUBLIC_API_URL`
- Authentication: JWT tokens in httpOnly cookies
- Database: PostgreSQL (connection via Prisma)
```

---

## ✅ Step 5: Create Example Spec

Create an example spec in `.droidz/specs/examples/000-example-feature.md`:

```markdown
# Example Feature Specification

## Overview
This is an example specification showing the format for feature planning.

## Tasks

### Task 1: [Component] - Create API endpoint
**Files**: src/api/example.ts
**Effort**: S (2 hours)
**Dependencies**: None
**Parallelizable**: Yes

### Task 2: [Tests] - Write API tests
**Files**: tests/api/example.test.ts
**Effort**: S (1 hour)
**Dependencies**: Task 1
**Parallelizable**: No

## Testing Strategy
- Unit tests for API functions
- Integration tests for endpoints
- Target: 80%+ coverage

## Security
- Validate all inputs
- Rate limit endpoints
- Use environment variables for secrets
```

---

## 🎯 Step 6: Validation

Verify the setup:

```bash
# Check directories exist
ls -la .droidz/specs/

# Check AGENTS.md created
cat AGENTS.md

# Check tech stack detected
cat .droidz/memory/tech-stack.md

# Check example spec
cat .droidz/specs/examples/000-example-feature.md
```

---

## 📊 Step 7: Generate Summary

Provide initialization summary:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Droidz Framework Initialized!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Created:
  ✓ .droidz/specs/ directory structure
  ✓ .droidz/memory/ for tech stack info
  ✓ AGENTS.md with project context
  ✓ Example spec in .droidz/specs/examples/

🔍 Detected:
  • Language: TypeScript
  • Framework: React + Next.js 14
  • Package Manager: Bun
  • Testing: Jest
  • Build Tool: Vite + Next.js

📚 Next Steps:

  1. Review AGENTS.md and customize if needed
  
  2. Try creating a feature spec:
     /prompts:build FEATURE="user profile page" COMPLEXITY=medium
  
  3. Or start implementing:
     /prompts:codegen FEATURE="add navigation menu"
  
  4. Or run validation:
     /prompts:validate

🎯 Framework Ready! Start building with Codex CLI.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔄 Options

### `--quick` Mode
Skip interactive questions, use defaults:
- Create all directories
- Detect tech stack automatically
- Use standard AGENTS.md template
- Create example spec

### `--status` Mode
Check current setup without changes:
- List existing directories
- Show if AGENTS.md exists
- Display tech stack if detected
- Report if prompts are installed

---

## 🎯 Success Criteria

Initialization is complete when:
- ✅ `.droidz/specs/` structure created
- ✅ AGENTS.md file created with project context
- ✅ Tech stack detected and saved
- ✅ Example spec created
- ✅ Validation passed (directories exist, AGENTS.md readable)
- ✅ Ready to use Droidz prompts
