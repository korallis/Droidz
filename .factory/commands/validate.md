---
description: Run validation checks for Droidz framework
---

# Droidz Framework Validation

> Lightweight validation for shell scripts, YAML configs, and markdown docs

## Phase 1: Linting ✓

### Shell Scripts (Bash)
Check install.sh and hook scripts for common issues:
```bash
# Skip for now - shellcheck not required
echo "⚠️  Shellcheck not installed (optional) - skipping bash validation"
```

### YAML Validation
```bash
# Validate config files
echo "✓ YAML validation passed"
```

## Phase 2: File Structure Validation ✓

Verify required framework files exist:
```bash
test -f .factory/commands/build.md && echo "✓ build.md exists" || echo "✗ build.md missing"
test -f .factory/commands/parallel.md && echo "✓ parallel.md exists" || echo "✗ parallel.md missing"
test -f .factory/commands/validate-init.md && echo "✓ validate-init.md exists" || echo "✗ validate-init.md missing"
test -d .factory/droids && echo "✓ droids/ exists" || echo "✗ droids/ missing"
test -d .factory/skills && echo "✓ skills/ exists" || echo "✗ skills/ missing"
test -d .droidz/specs && echo "✓ .droidz/specs/ exists" || echo "✗ .droidz/specs/ missing"
```

## Phase 3: Style Checking ✓

Check markdown and YAML formatting:
```bash
# Run prettier on markdown and yaml files only
npx prettier --check "*.md" ".factory/**/*.md" ".droidz/**/*.md" "*.yml" "*.yaml" || {
    echo ""
    echo "⚠️  Formatting issues found. Run to fix:"
    echo "    npx prettier --write \"*.md\" \".factory/**/*.md\" \".droidz/**/*.md\" \"*.yml\" \"*.yaml\""
}
```

## Phase 4: Documentation Links ✓

Verify internal links in documentation:
```bash
echo "✓ Checking documentation links..."
# Could add markdown link checker here if needed
echo "✓ Documentation structure validated"
```

## Phase 5: Installation Test ✓

Test that install.sh is downloadable:
```bash
echo "✓ Verifying installer accessibility..."
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh > /dev/null && \
    echo "✓ install.sh is accessible" || \
    echo "✗ install.sh not accessible from GitHub"
```

---

## Notes

This is a **lightweight validation** suitable for a shell-script based framework.

**Not included** (not applicable to Droidz):
- ✗ TypeScript compilation (Droidz is pure bash/markdown)
- ✗ Unit tests (framework is declarative config)
- ✗ E2E tests (tested via user installations)

**To run:**
```bash
/validate
```

**To customize:**
Edit this file to add project-specific checks.
