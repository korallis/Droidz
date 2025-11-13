---
description: Validate a specification file for completeness and quality. Checks for required sections, clear acceptance criteria, realistic implementation plans, and identified dependencies.
argument-hint: [spec-file] - path to spec file in .claude/specs/active/
allowed-tools: Bash(*), Read, Grep
---

# /validate-spec - Validate Specification

Validates a specification file to ensure it's complete and ready for implementation.

## Usage

```bash
# Validate specific spec
/validate-spec .claude/specs/active/auth-system.md

# Validate with strict mode (all optional sections required)
/validate-spec .claude/specs/active/auth-system.md --strict

# Quick validation (required sections only)
/validate-spec .claude/specs/active/auth-system.md --quick
```

## What Gets Validated

### Required Sections
- [ ] Overview/Purpose
- [ ] Requirements (functional & non-functional)
- [ ] Architecture/Technical Approach
- [ ] Implementation Plan/Task Breakdown
- [ ] Acceptance Criteria
- [ ] Timeline/Estimates

### Quality Checks
- [ ] Acceptance criteria are specific and measurable
- [ ] Task breakdown includes specialist assignments
- [ ] Dependencies are identified
- [ ] Risks are documented
- [ ] Success metrics are defined
- [ ] All TODOs and placeholders are filled

### Best Practices
- [ ] Clear user value statement
- [ ] Architecture decisions documented
- [ ] Testing strategy defined
- [ ] Deployment plan included
- [ ] Documentation requirements listed

## Validation Levels

### Quick (--quick)
- Checks only required sections exist
- Fast validation for work-in-progress specs

### Standard (default)
- Checks required sections
- Validates quality of content
- Ensures readiness for implementation

### Strict (--strict)
- All sections must be complete
- No placeholders or TODOs
- Ready for immediate orchestration

## Output

### Success
```
✅ Spec Validation: PASSED

File: .claude/specs/active/auth-system.md
Type: Feature Spec
Status: Ready for orchestration

✅ All required sections present
✅ Acceptance criteria are measurable
✅ Task breakdown is complete
✅ Dependencies identified
✅ No blockers found

Next steps:
  /spec-to-tasks .claude/specs/active/auth-system.md
  /orchestrate file:auth-system-tasks.json
```

### Failure
```
❌ Spec Validation: FAILED

File: .claude/specs/active/auth-system.md
Issues found: 5

Required Sections:
  ❌ Missing: Implementation Plan
  ⚠️  Incomplete: Acceptance Criteria (placeholder text found)

Quality Issues:
  ❌ Acceptance criteria not measurable
  ⚠️  No specialist assignments in tasks
  ⚠️  Missing risk assessment

Fix these issues before proceeding.
```

---

## Implementation Instructions

When this command is executed, perform the following based on $ARGUMENTS:

### Parse Arguments

Extract from `$ARGUMENTS`:
- Spec file path (first argument)
- Optional: `--strict` for strict validation (all sections required)
- Optional: `--quick` for quick validation (required sections only)

If no spec file provided:
```
❌ Error: No spec file specified

Usage: /validate-spec [spec-file] [--strict|--quick]
Example: /validate-spec .claude/specs/active/auth-system.md
```

### Validation

If spec file not found:
```
❌ Error: Spec file not found: [path]
```

### Validation Process

Display header:
```
🔍 Validating Spec
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File: .claude/specs/active/auth-system.md
Mode: Standard
```

**Step 1: Check Required Sections**

Required sections:
- Overview
- Purpose
- Requirements
- Architecture
- Implementation Plan
- Acceptance Criteria

For each section:
- ✅ if present
- ❌ if missing (counts as ERROR)

**Step 2: Quality Checks**

Check for:
1. **Placeholders** - `[Text in brackets]`
   - ⚠️ if found (WARNING)
   - ✅ if none

2. **TODOs** - Unresolved TODO comments
   - ⚠️ if found (WARNING)
   - ✅ if none

3. **Acceptance Criteria** - Checkbox format `- [ ]`
   - ✅ if found
   - ❌ if missing (ERROR)

4. **Specialist Assignments** - Tasks mention specialists
   - ✅ if present
   - ⚠️ if missing (WARNING)

5. **Dependencies** - Dependencies documented
   - ✅ if present
   - ⚠️ if missing (WARNING)

6. **Risks** - Risks section exists
   - ✅ if present
   - ❌ if missing in `--strict` mode (ERROR)
   - ⚠️ if missing in normal mode (WARNING)

7. **Timeline/Estimates** - Duration or timeline mentioned
   - ✅ if present
   - ⚠️ if missing (WARNING)

**Step 3: Calculate Results**

Count:
- ERRORS: Critical issues that must be fixed
- WARNINGS: Recommended improvements

**Step 4: Display Summary**

If no errors:
```
✅ Spec Validation: PASSED (Perfect)

Status: Ready for orchestration

Next steps:
  1. /spec-to-tasks .claude/specs/active/auth-system.md
  2. /orchestrate file:auth-system-tasks.json
```

If warnings only:
```
✅ Spec Validation: PASSED (3 warnings)

Status: Ready for orchestration

Note: Address warnings to improve spec quality

Next steps:
  1. /spec-to-tasks .claude/specs/active/auth-system.md
  2. /orchestrate file:auth-system-tasks.json
```

If errors:
```
❌ Spec Validation: FAILED

Issues found:
  Errors: 2
  Warnings: 3

Fix errors before proceeding:
  - Missing required section: Architecture
  - No acceptance criteria found
```

### Validation Modes

**Standard** (default):
- All required sections must be present
- Warnings for missing optional content

**Quick** (`--quick`):
- Only check critical sections (Overview, Requirements, Implementation)
- Skip quality checks

**Strict** (`--strict`):
- All sections required (including Risks, Dependencies)
- More stringent quality checks
- No warnings allowed for production specs
