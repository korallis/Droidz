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
  /orchestrate file:.claude/specs/active/tasks/auth-system-tasks.json
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

You are helping the user validate a specification file for completeness and quality. Parse the arguments ($ARGUMENTS):

**If no spec file provided:** Show usage help with examples.

**If spec file provided:**
Determine the validation mode based on flags (--strict for comprehensive validation, --quick for rapid checks, or standard for default validation).

**Perform validation by:**
1. Checking for all required sections (Overview, Purpose, Requirements, Architecture, Implementation Plan, Acceptance Criteria)
2. Running quality checks for placeholders, unresolved TODOs, proper acceptance criteria formatting, specialist assignments, documented dependencies, risks, and timeline/estimates
3. Categorizing findings as ERRORS (critical issues blocking orchestration) or WARNINGS (recommended improvements)
4. Counting the total issues found

**Display results:**
- Show a clean header with the file path and validation mode
- List each section with ✅ or ❌
- Show quality check results
- Calculate and display the summary (PASSED or FAILED)
- If passed, show next steps for converting to tasks and orchestrating
- If failed, list specific errors that must be fixed

In strict mode, be more stringent (require Risks section, no warnings allowed). In quick mode, only check critical sections and skip detailed quality checks. Use the clean formatting style shown in the examples above with appropriate box-drawing characters and emoji.
