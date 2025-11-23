# Droidz Validation Standards

## Validation Gate

Every agent must enforce validation before completing tasks. This ensures code quality, test coverage, and adherence to project standards.

## Universal Requirements

1. **Linting**
   - Run project linters (ruff, eslint, pylint, etc.)
   - Fix all linting errors and warnings
   - Respect project-specific lint configurations

2. **Type Checking**
   - Run type checkers if project uses them (mypy, TypeScript, etc.)
   - Fix all type errors before completion

3. **Testing**
   - Run all existing tests
   - Add tests for new functionality
   - Ensure test coverage meets project standards
   - Never break existing tests

4. **Build Verification**
   - Run build commands if project has them
   - Ensure builds succeed before reporting completion

## Agent-Specific Validation

Each agent may have additional validation requirements defined in their standards:

- **Factory AI**: See `~/.factory/standards/`
- **Claude Code**: See `~/.claude/standards/`
- **Cursor**: See `~/Library/Application Support/Cursor/droidz/standards/`
- **Other agents**: Check respective agent directories

## Common Validation Commands

```bash
# Python projects
ruff check .
pytest
mypy .

# JavaScript/TypeScript projects
npm run lint
npm test
npm run type-check

# Go projects
go fmt ./...
go test ./...
go vet ./...

# Rust projects
cargo fmt --check
cargo test
cargo clippy
```

## Validation Failure

If validation fails:
1. **Never ignore errors** - Always fix them
2. **Don't skip tests** - Even if they take time
3. **Report issues** - Let the user know what failed and why
4. **Fix systematically** - Address root causes, not symptoms

## Pre-Commit Checks

If the project uses pre-commit hooks, ensure they pass before committing.
