---
description: Transform fuzzy ideas into clear, actionable specifications. Use when you have an idea but need help clarifying requirements, acceptance criteria, and implementation approach.
argument-hint: [topic or idea]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# /spec-shaper - Specification Shaping Assistant

Transforms vague ideas and incomplete requirements into structured, actionable specifications.

## When to Use

Use `/spec-shaper` when you:
- Have a fuzzy idea that needs clarification
- Want to build something but lack clear requirements
- Need help defining acceptance criteria
- Want to break down a large idea into manageable specs
- Are unsure whether you need a feature, epic, or integration spec

## Usage

```bash
# Interactive mode (recommended)
/spec-shaper

# With topic hint
/spec-shaper authentication system

# For specific project
/spec-shaper e-commerce checkout flow
```

## What It Does

The spec shaper will guide you through:

1. **Vision Understanding** - Ask clarifying questions about what, why, who, when, and how
2. **Spec Type Identification** - Determine if you need a feature, epic, refactor, or integration spec
3. **Requirements Extraction** - Extract functional, non-functional requirements and constraints
4. **Acceptance Criteria Definition** - Create SMART (Specific, Measurable, Achievable, Relevant, Time-bound) criteria
5. **Implementation Breakdown** - Identify components, technical approach, and task breakdown
6. **Spec Creation** - Generate a properly formatted spec file using the appropriate template

## Spec Types

**Feature Spec** - Single feature or enhancement
- Clear scope
- Can be built in 1-2 weeks
- Example: "Add user authentication"

**Epic Spec** - Large initiative with multiple features
- Broad scope
- Multiple weeks/months
- Example: "Build complete e-commerce platform"

**Refactor Spec** - Code improvement without behavior change
- Structural improvement
- No new features
- Example: "Refactor auth module to use modern patterns"

**Integration Spec** - Third-party service integration
- External API/service
- Security considerations
- Example: "Integrate Stripe payments"

## Output

Creates a spec file in `.factory/specs/active/` with:
- Clear title and description
- Functional and non-functional requirements
- Acceptance criteria (SMART format)
- Implementation approach
- Task breakdown for orchestration
- Dependencies and estimated effort

## Example Session

```bash
You: /spec-shaper user dashboard

Spec Shaper: I'll help you create a spec for the user dashboard. Let me ask some questions:

1. What should users be able to do on this dashboard?
2. What information needs to be displayed?
3. Are there any specific performance requirements?
4. What's the timeline for this feature?
5. Should this work on mobile devices?

[After discussion...]

Great! I'll create a feature spec for the user dashboard with the requirements we discussed.

✓ Created: .factory/specs/active/user-dashboard.md
✓ Type: Feature Spec
✓ Acceptance Criteria: 8 items
✓ Task Breakdown: 5 tasks
✓ Estimated Effort: 1-2 weeks

Next steps:
1. Review the spec: /validate-spec .factory/specs/active/user-dashboard.md
2. Generate tasks: /spec-to-tasks .factory/specs/active/user-dashboard.md
3. Start development: /orchestrate spec:.factory/specs/active/user-dashboard.md
```

## Best Practices

1. **Be Honest** - Say "I don't know" if requirements are unclear; the spec shaper will help you figure it out
2. **Think User-First** - Focus on what users need, not just technical implementation
3. **Start Broad** - Begin with the overall vision, then drill down into details
4. **Validate Assumptions** - Question and validate all assumptions about requirements
5. **Keep It SMART** - Ensure all acceptance criteria are specific and measurable

## Tips

- **For Complex Projects**: Start with an epic spec, then break it down into feature specs
- **For Refactors**: Clearly define what should NOT change (behavior preservation)
- **For Integrations**: Document API authentication, rate limits, and error handling
- **For MVPs**: Focus on must-have features only; defer nice-to-haves

---

## Implementation

<execute>
echo "🎯 Spec Shaping Assistant"
echo ""
echo "I'll help you transform your idea into a clear, actionable specification."
echo ""

if [ -z "$ARGUMENTS" ]; then
  echo "What would you like to build?"
  echo ""
  echo "Please describe your idea, and I'll help you:"
  echo "  • Clarify requirements"
  echo "  • Define acceptance criteria"
  echo "  • Choose the right spec type"
  echo "  • Break down implementation"
  echo "  • Create a structured spec file"
  echo ""
  echo "Examples:"
  echo "  - 'A user authentication system'"
  echo "  - 'An e-commerce checkout flow'"
  echo "  - 'Refactor the API layer'"
  echo "  - 'Integrate Stripe payments'"
else
  echo "Topic: $ARGUMENTS"
  echo ""
  echo "Great! Let's shape this into a clear specification."
  echo ""
  echo "I'll ask you some questions to understand your vision:"
  echo ""
  echo "1. **What** are you trying to build?"
  echo "   (What should the feature do? What problem does it solve?)"
  echo ""
  echo "2. **Why** do you need it?"
  echo "   (Business value? User benefit? Pain point it addresses?)"
  echo ""
  echo "3. **Who** is it for?"
  echo "   (Target users? Internal tool? Customer-facing?)"
  echo ""
  echo "4. **When** is it needed?"
  echo "   (Timeline? Urgency? Dependencies?)"
  echo ""
  echo "5. **How** complex is it?"
  echo "   (Single feature? Multi-week epic? Integration?)"
  echo ""
  echo "Please answer these questions, and I'll create a structured spec for you."
fi
</execute>
