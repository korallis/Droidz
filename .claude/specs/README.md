# Droidz Specs Layer

Specifications define **what you're building next** with detailed implementation guidance.

## Directory Structure

```
.claude/specs/
├── README.md                  # This file
├── templates/                 # Spec templates
│   ├── feature-spec.md       # Template for feature specifications
│   ├── epic-spec.md          # Template for epic specifications
│   ├── refactor-spec.md      # Template for refactoring specs
│   └── integration-spec.md   # Template for integration specs
├── active/                    # Current work specifications
│   └── .gitkeep
└── archive/                   # Completed specifications
    └── .gitkeep
```

## Spec Types

### Feature Spec
For new features or enhancements.
- **Use when**: Adding new functionality
- **Template**: `templates/feature-spec.md`
- **Command**: `/create-spec feature feature-name`

### Epic Spec
For large initiatives spanning multiple features.
- **Use when**: Complex projects with multiple components
- **Template**: `templates/epic-spec.md`
- **Command**: `/create-spec epic epic-name`

### Refactor Spec
For code restructuring and improvements.
- **Use when**: Improving code quality without changing behavior
- **Template**: `templates/refactor-spec.md`
- **Command**: `/create-spec refactor refactor-name`

### Integration Spec
For third-party service integrations.
- **Use when**: Adding external APIs or services
- **Template**: `templates/integration-spec.md`
- **Command**: `/create-spec integration service-name`

## Workflow

### 1. Create Spec
```bash
# From template
/create-spec feature auth-system

# Opens: .claude/specs/active/auth-system.md
```

### 2. Write Specification
Fill in all sections:
- Overview & goals
- Requirements
- Architecture decisions
- Acceptance criteria
- Implementation plan

### 3. Validate Spec
```bash
/validate-spec .claude/specs/active/auth-system.md
```

Checks for:
- ✅ All required sections present
- ✅ Clear acceptance criteria
- ✅ Realistic implementation plan
- ✅ Dependencies identified

### 4. Convert to Tasks
```bash
/spec-to-tasks .claude/specs/active/auth-system.md
```

Generates `auth-system-tasks.json` with:
- Task breakdown
- Specialist assignments
- Priority ordering
- Dependencies mapped

### 5. Orchestrate
```bash
/orchestrate file:auth-system-tasks.json
```

Creates parallel worktrees and executes.

### 6. Archive
After completion:
```bash
/archive-spec .claude/specs/active/auth-system.md
```

Moves to `.claude/specs/archive/auth-system.md` with metadata.

## Spec Quality Guidelines

### ✅ Good Specs

**Clear Purpose**
```markdown
## Purpose
Enable users to securely authenticate using email/password, supporting
password reset and remember-me functionality.
```

**Measurable Criteria**
```markdown
## Acceptance Criteria
- [ ] User can register with email/password
- [ ] Password requirements: 8+ chars, 1 uppercase, 1 number
- [ ] Password reset email sent within 30 seconds
- [ ] Session persists for 30 days with remember-me
- [ ] All auth endpoints return < 200ms response time
```

**Detailed Architecture**
```markdown
## Architecture Decisions
- Use JWT for stateless authentication
- bcrypt for password hashing (cost factor: 12)
- Redis for session storage
- Rate limiting: 5 login attempts per hour
```

### ❌ Bad Specs

**Vague Purpose**
```markdown
## Purpose
Add login stuff
```

**Unmeasurable Criteria**
```markdown
## Acceptance Criteria
- Should work well
- Users should be happy
```

**No Architecture**
```markdown
## Architecture
We'll figure it out during implementation
```

## Spec-Driven Benefits

1. **Clarity Before Code** - Know exactly what to build
2. **Parallelization** - Tasks clearly identified
3. **Quality Gates** - Validation before execution
4. **Documentation** - Specs serve as design docs
5. **Onboarding** - New team members understand decisions
6. **Context** - Agents get full picture before implementing

## Integration with Orchestrator

The orchestrator reads specs to:
- **Decompose** - Break into parallel tasks
- **Assign** - Match tasks to specialists
- **Coordinate** - Handle dependencies
- **Validate** - Check against acceptance criteria
- **Report** - Track progress against spec

## Example: Feature Spec → Orchestration

### Input: auth-system.md
```markdown
# Feature Spec: Authentication System

## Tasks
1. Backend API endpoints
2. Frontend login/register forms
3. Password reset flow
4. Session management
5. Integration tests
```

### Output: auth-system-tasks.json
```json
{
  "spec": "auth-system",
  "tasks": [
    {
      "key": "AUTH-API",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "AUTH-UI",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "AUTH-TESTS",
      "specialist": "droidz-test",
      "priority": 2
    }
  ]
}
```

### Result: Parallel Execution
```
.runs/AUTH-API/    ← droidz-codegen (tmux: droidz-AUTH-API)
.runs/AUTH-UI/     ← droidz-codegen (tmux: droidz-AUTH-UI)
.runs/AUTH-TESTS/  ← droidz-test (tmux: droidz-AUTH-TESTS)
```

---

## Best Practices

### Start with Why
Always explain the business value and user benefit.

### Be Specific
"Fast response time" → "< 200ms P95 latency"

### List Dependencies
Identify what must exist before implementation.

### Define Success
Clear, testable acceptance criteria.

### Plan Implementation
Break down into concrete tasks.

### Document Decisions
Explain architectural choices and trade-offs.

### Keep Updated
Modify spec as requirements evolve.

### Archive When Done
Preserve as historical documentation.

---

*Last Updated: 2025-01-12*
*Version: 1.0.0*
