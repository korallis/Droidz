---
description: Analyze task complexity and recommend whether to use parallel orchestration. Helps determine if work should be broken down and executed in parallel for faster completion.
argument-hint: [task description]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, TodoWrite
---

# /auto-orchestrate - Orchestration Intelligence

Automatically analyzes task complexity and recommends whether parallel orchestration would be beneficial.

## When to Use

Use `/auto-orchestrate` when you:
- Have a complex request and aren't sure if it should be parallelized
- Want to know if orchestration would speed up development
- Need help breaking down work into parallel tasks
- Are planning a sprint and want to optimize task execution
- Have multiple components to build (frontend + backend + tests + infrastructure)

## Usage

```bash
# Analyze a task
/auto-orchestrate build authentication system with OAuth, JWT, and user management

# Analyze current spec
/auto-orchestrate spec:.factory/specs/active/feature-auth.md

# Interactive analysis
/auto-orchestrate
```

## Complexity Decision Criteria

### ✅ Recommend Orchestration If:
- 5+ files need modification across different domains
- Multiple independent features can be built simultaneously
- Different specialists needed (codegen + test + infra + integration)
- Work estimated >2 hours that can be parallelized
- Clear task boundaries exist
- Request involves 3+ distinct components

### ❌ Don't Orchestrate If:
- Single file modification
- Simple bug fix
- Quick documentation update
- Tightly coupled tasks (must be sequential)
- Exploratory/research work
- Work estimated <1 hour

## Analysis Process

The auto-orchestrator will:

1. **Analyze Complexity**
   - Assess scope of work
   - Identify decomposability
   - Check task independence
   - Determine required specialists
   - Calculate coordination overhead

2. **Make Recommendation**
   - Complexity level (Low/Medium/High)
   - Recommended approach (Orchestrate/Sequential/Hybrid)
   - Detailed rationale
   - Proposed task breakdown
   - Estimated speedup (e.g., "3x faster with orchestration")
   - Coordination complexity assessment

3. **Generate Task Plan**
   - Break down into parallel tasks
   - Assign appropriate specialists
   - Identify dependencies
   - Estimate effort per task
   - Create tasks.json for orchestration

## Output

Provides:
- **Complexity Analysis** - Detailed assessment of the work
- **Recommendation** - Whether to orchestrate or execute sequentially
- **Task Breakdown** - Proposed parallel tasks with specialists
- **Estimated Speedup** - Expected time savings
- **Tasks JSON** - Ready-to-use orchestration input

## Example Session

```bash
You: /auto-orchestrate build user dashboard with analytics, notifications, and settings

Auto-Orchestrator:

## Orchestration Analysis

**Request**: Build user dashboard with analytics, notifications, and settings

**Complexity**: High

**Recommended Approach**: Orchestrate (Parallel Execution)

**Rationale**:
- 3 independent components (analytics, notifications, settings)
- Each component can be built in parallel
- Different specialists can work simultaneously
- Minimal cross-dependencies
- Estimated 4-6 hours sequential → 1.5-2 hours parallel

**Proposed Task Breakdown**:

1. **DASH-001**: Analytics Dashboard Widget
   - Specialist: droidz-codegen
   - Effort: 2 hours
   - Dependencies: None
   - Status: Can run in parallel

2. **DASH-002**: Notification Center Component
   - Specialist: droidz-codegen
   - Effort: 1.5 hours
   - Dependencies: None
   - Status: Can run in parallel

3. **DASH-003**: Settings Panel
   - Specialist: droidz-codegen
   - Effort: 1.5 hours
   - Dependencies: None
   - Status: Can run in parallel

4. **DASH-004**: Integration Tests
   - Specialist: droidz-test
   - Effort: 1 hour
   - Dependencies: DASH-001, DASH-002, DASH-003
   - Status: Run after all components complete

**Estimated Speedup**: 3x faster (6 hours → 2 hours)

**Coordination Complexity**: Low (minimal cross-dependencies)

**Recommendation**: ✅ Proceed with orchestration

Would you like me to:
1. Create tasks.json and start orchestration
2. Create a spec file first
3. Adjust task breakdown
```

## Integration with Orchestrator

After analysis, you can:

```bash
# If orchestration recommended, save tasks and orchestrate
/auto-orchestrate build dashboard → generates tasks.json
/orchestrate file:tasks.json → starts parallel execution

# Or create a spec first
/spec-shaper dashboard feature → creates spec
/spec-to-tasks .factory/specs/active/dashboard.md → generates tasks
/orchestrate spec:.factory/specs/active/dashboard.md → orchestrates
```

## Best Practices

1. **Trust the Analysis** - If it recommends against orchestration, there's a good reason
2. **Consider Dependencies** - Tightly coupled tasks should NOT be parallelized
3. **Factor Overhead** - Orchestration adds coordination overhead; only worth it for >2 hour work
4. **Review Task Breakdown** - Adjust specialist assignments and dependencies as needed
5. **Start with Specs** - For complex work, create a spec first, then orchestrate

## Common Patterns

**Fullstack Feature** - ✅ Orchestrate
- Frontend component (droidz-codegen)
- Backend API (droidz-codegen)
- Database migration (droidz-codegen)
- Integration tests (droidz-test)
- Deployment config (droidz-infra)

**Refactoring** - ❌ Don't Orchestrate
- Tightly coupled changes
- Requires understanding full context
- Sequential by nature

**Multiple Features** - ✅ Orchestrate
- Independent features
- Different domains
- Parallel-friendly

**Bug Fix** - ❌ Don't Orchestrate
- Single issue
- Quick fix
- Not worth coordination overhead

---

## Implementation

<execute>
echo "🤖 Orchestration Intelligence"
echo ""

if [ -z "$ARGUMENTS" ]; then
  echo "I'll analyze your task and recommend whether to use parallel orchestration."
  echo ""
  echo "Please describe what you want to build:"
  echo ""
  echo "Examples:"
  echo "  • 'Build authentication system with OAuth, JWT, and user management'"
  echo "  • 'Create e-commerce checkout flow with payment, shipping, and confirmation'"
  echo "  • 'Refactor API layer to use dependency injection'"
  echo "  • 'Add analytics dashboard with charts, tables, and exports'"
  echo ""
  exit 0
fi

# Check if argument is a spec file
if [[ "$ARGUMENTS" == spec:* ]]; then
  SPEC_FILE="${ARGUMENTS#spec:}"
  echo "Analyzing spec file: $SPEC_FILE"
  echo ""

  if [ ! -f "$SPEC_FILE" ]; then
    echo "❌ Spec file not found: $SPEC_FILE"
    exit 1
  fi

  echo "I'll analyze this spec to determine if orchestration would be beneficial."
  echo ""
  echo "Reading spec and analyzing complexity..."
  echo ""
else
  TASK_DESC="$ARGUMENTS"
  echo "Task: $TASK_DESC"
  echo ""
  echo "Analyzing complexity..."
  echo ""
fi

echo "## Complexity Analysis"
echo ""
echo "Let me ask some clarifying questions:"
echo ""
echo "1. How many distinct components or areas does this involve?"
echo "   (e.g., frontend + backend + database + tests = 4 components)"
echo ""
echo "2. Can these components be built independently?"
echo "   (Or do they have tight dependencies?)"
echo ""
echo "3. Roughly how long would this take if done sequentially?"
echo "   (e.g., 4 hours, 2 days, 1 week)"
echo ""
echo "4. Are there different types of work involved?"
echo "   (e.g., feature implementation, testing, infrastructure, integration)"
echo ""
echo "Please answer these questions, and I'll provide a detailed orchestration recommendation."
</execute>
