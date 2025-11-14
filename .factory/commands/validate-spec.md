---
description: Validate a specification file for completeness and quality. Checks for required sections, clear acceptance criteria, realistic implementation plans, and identified dependencies.
argument-hint: [spec-file] - path to spec file in .factory/specs/active/
allowed-tools: Bash(*), Read, Grep
---

# /validate-spec - Validate Specification

Validates a specification file to ensure it's complete and ready for implementation.

## Usage

```bash
# Validate specific spec
/validate-spec .factory/specs/active/auth-system.md

# Validate with strict mode (all optional sections required)
/validate-spec .factory/specs/active/auth-system.md --strict

# Quick validation (required sections only)
/validate-spec .factory/specs/active/auth-system.md --quick
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

File: .factory/specs/active/auth-system.md
Type: Feature Spec
Status: Ready for orchestration

✅ All required sections present
✅ Acceptance criteria are measurable
✅ Task breakdown is complete
✅ Dependencies identified
✅ No blockers found

Next steps:
  /spec-to-tasks .factory/specs/active/auth-system.md
  /orchestrate file:auth-system-tasks.json
```

### Failure
```
❌ Spec Validation: FAILED

File: .factory/specs/active/auth-system.md
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

## Implementation

<execute>
SPEC_FILE="$ARGUMENTS"

# Remove flags from file path
SPEC_FILE=$(echo "$SPEC_FILE" | sed 's/ --strict$//' | sed 's/ --quick$//')

# Check validation mode
STRICT_MODE=false
QUICK_MODE=false

if echo "$ARGUMENTS" | grep -q -- "--strict"; then
  STRICT_MODE=true
fi

if echo "$ARGUMENTS" | grep -q -- "--quick"; then
  QUICK_MODE=true
fi

if [ -z "$SPEC_FILE" ]; then
  echo "❌ Error: No spec file specified"
  echo ""
  echo "Usage: /validate-spec [spec-file]"
  echo "Example: /validate-spec .factory/specs/active/auth-system.md"
  exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
  echo "❌ Error: Spec file not found: $SPEC_FILE"
  exit 1
fi

echo "🔍 Validating Spec"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "File: $SPEC_FILE"

if [ "$STRICT_MODE" = true ]; then
  echo "Mode: Strict (all sections required)"
elif [ "$QUICK_MODE" = true ]; then
  echo "Mode: Quick (required sections only)"
else
  echo "Mode: Standard"
fi

echo ""

# Read the spec file
SPEC_CONTENT=$(cat "$SPEC_FILE")

# Initialize counters
ERRORS=0
WARNINGS=0

# Required sections to check
REQUIRED_SECTIONS=(
  "Overview"
  "Purpose"
  "Requirements"
  "Architecture"
  "Implementation"
  "Acceptance Criteria"
)

echo "📋 Checking Required Sections..."
echo ""

for section in "${REQUIRED_SECTIONS[@]}"; do
  if echo "$SPEC_CONTENT" | grep -qi "##.*$section"; then
    echo "  ✅ $section"
  else
    echo "  ❌ Missing: $section"
    ((ERRORS++))
  fi
done

echo ""
echo "📊 Quality Checks..."
echo ""

# Check for placeholders
if echo "$SPEC_CONTENT" | grep -q "\[.*\]"; then
  PLACEHOLDER_COUNT=$(echo "$SPEC_CONTENT" | grep -o "\[.*\]" | wc -l)
  echo "  ⚠️  Found $PLACEHOLDER_COUNT placeholder(s) - fill these in"
  ((WARNINGS++))
else
  echo "  ✅ No placeholders found"
fi

# Check for TODOs
if echo "$SPEC_CONTENT" | grep -qi "TODO"; then
  TODO_COUNT=$(echo "$SPEC_CONTENT" | grep -oi "TODO" | wc -l)
  echo "  ⚠️  Found $TODO_COUNT TODO(s) - resolve these"
  ((WARNINGS++))
else
  echo "  ✅ No TODOs found"
fi

# Check for acceptance criteria
if echo "$SPEC_CONTENT" | grep -q "- \[ \]"; then
  CRITERIA_COUNT=$(echo "$SPEC_CONTENT" | grep -o "- \[ \]" | wc -l)
  echo "  ✅ Found $CRITERIA_COUNT acceptance criteria"
else
  echo "  ❌ No checkbox-style acceptance criteria found"
  ((ERRORS++))
fi

# Check for task breakdown
if echo "$SPEC_CONTENT" | grep -qi "specialist"; then
  echo "  ✅ Task breakdown includes specialist assignments"
else
  echo "  ⚠️  No specialist assignments found in tasks"
  ((WARNINGS++))
fi

# Check for dependencies
if echo "$SPEC_CONTENT" | grep -qi "dependenc"; then
  echo "  ✅ Dependencies section present"
else
  echo "  ⚠️  No dependencies documented"
  ((WARNINGS++))
fi

# Check for risks
if echo "$SPEC_CONTENT" | grep -qi "risk"; then
  echo "  ✅ Risks documented"
else
  if [ "$STRICT_MODE" = true ]; then
    echo "  ❌ No risks documented (required in strict mode)"
    ((ERRORS++))
  else
    echo "  ⚠️  No risks documented"
    ((WARNINGS++))
  fi
fi

# Check for timeline
if echo "$SPEC_CONTENT" | grep -Eqi "timeline|duration|estimate"; then
  echo "  ✅ Timeline/estimates present"
else
  echo "  ⚠️  No timeline or estimates found"
  ((WARNINGS++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
if [ $ERRORS -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo "✅ Spec Validation: PASSED (Perfect)"
  elif [ $WARNINGS -le 2 ]; then
    echo "✅ Spec Validation: PASSED (Minor warnings)"
  else
    echo "✅ Spec Validation: PASSED ($WARNINGS warnings)"
  fi
  echo ""
  echo "Status: Ready for orchestration"
  echo ""
  echo "Next steps:"
  echo "  1. /spec-to-tasks $SPEC_FILE"
  echo "  2. /orchestrate file:[spec-name]-tasks.json"
else
  echo "❌ Spec Validation: FAILED"
  echo ""
  echo "Issues found:"
  echo "  Errors: $ERRORS"
  echo "  Warnings: $WARNINGS"
  echo ""
  echo "Fix errors before proceeding."
  exit 1
fi

# Show warnings if any
if [ $WARNINGS -gt 0 ]; then
  echo ""
  echo "Note: Address warnings to improve spec quality."
fi

</execute>
