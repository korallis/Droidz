---
description: Generate comprehensive feature implementation plan with meta-prompted reasoning
argument-hint: FEATURE=<description> [COMPLEXITY=<low|medium|high>]
---

# Feature Specification Generator

Create a detailed implementation plan for: **$FEATURE**

Complexity Level: ${COMPLEXITY:-medium}

---

## 🔍 Step 1: Analyze the Request

Before creating the specification, analyze the feature:

### Complexity Assessment
- **Simple**: Single component, <3 files, clear requirements
- **Medium**: Multiple components, 3-10 files, some ambiguity
- **High**: System-wide changes, >10 files, significant complexity

### Domain Classification
- Frontend, Backend, Full-stack, Infrastructure, Data, or Integration?

### Key Questions
If complexity is Medium or High, ask clarifying questions:
- What problem does this solve for users?
- What are core requirements vs nice-to-haves?
- What existing systems does this integrate with?
- What are security/performance requirements?
- What is the timeline?

---

## 📝 Step 2: Create the Specification

Generate a comprehensive specification and save to:
`.droidz/specs/active/NNN-feature-name.md`

Use the next available number (check existing specs in `.droidz/specs/active/`).

### Required Sections

#### 1. Executive Summary
- One paragraph: problem, solution, impact
- Key metrics and success criteria

#### 2. Architecture Overview
- System context and components
- Data flow between systems
- Technology stack with rationale

#### 3. Implementation Tasks

Break down into parallelizable tasks:

**Task Format:**
```
### Task N: [Component] - Brief Description
**Files**: src/api/auth.ts, src/routes/auth.ts
**Effort**: S/M/L (Small: <4h, Medium: 4-8h, Large: >8h)
**Dependencies**: Task 1, Task 2 (or None)
**Parallelizable**: Yes/No
**Description**: [Detailed description of what to implement]
```

**Example:**
```
### Task 1: [Backend] Create Auth API
**Files**: src/api/auth.ts, src/middleware/auth.ts
**Effort**: M (6 hours)
**Dependencies**: None
**Parallelizable**: Yes
**Description**: 
- Implement JWT generation and validation
- Create login/register endpoints
- Add auth middleware for protected routes
- Handle token refresh logic
```

#### 4. Testing Strategy
- Unit test requirements
- Integration test scenarios
- E2E test flows
- Coverage targets (aim for 80%+)

#### 5. Security Considerations
- Authentication/authorization approach
- Data validation requirements
- OWASP checklist items (if applicable)
- Secrets management (always use env vars)

#### 6. Deployment Plan
- Migration steps if needed
- Feature flags if phased rollout
- Rollback strategy

---

## ✅ Step 3: Generate Execution Summary

After creating the spec, provide:

```markdown
## Specification Created ✨

**File**: `.droidz/specs/active/NNN-feature-name.md`
**Complexity**: [Simple/Medium/High]
**Total Tasks**: [N]
**Parallelizable Tasks**: [M]
**Estimated Effort**: [X] developer-days
**With parallel execution**: [Y] calendar days

### Task Breakdown
- Phase 1 (Foundation): Task 1, Task 2, Task 3 [can run in parallel]
- Phase 2 (Integration): Task 4, Task 5 [depends on Phase 1]
- Phase 3 (Testing): Task 6, Task 7 [depends on Phase 2]

### Critical Path
Task 1 → Task 4 → Task 6 ([N] days)

### Next Steps
1. Review the full specification in `.droidz/specs/active/NNN-feature-name.md`
2. Make any adjustments needed
3. Execute with: `/prompts:parallel SPEC=NNN-feature-name`
4. Or work through tasks manually one by one
```

---

## 💡 Best Practices

**DO:**
- ✅ Ask clarifying questions for medium/high complexity
- ✅ Research best practices before specifying
- ✅ Break tasks into <8 hour chunks
- ✅ Identify parallel execution opportunities
- ✅ Include comprehensive testing strategy
- ✅ Document security considerations

**DON'T:**
- ❌ Skip requirement analysis
- ❌ Create vague, unmeasurable acceptance criteria
- ❌ Forget to specify error handling
- ❌ Ignore security implications
- ❌ Create tasks that are too large (>8 hours)
