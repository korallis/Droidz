# Create Product Mission

Generate a comprehensive mission document that defines the product vision and success criteria.

## Prerequisites
- Must have `droidz/product/info.md` created from gather-product-info workflow

## Research Phase (Use Exa)

Before writing the mission, research similar products and best practices:

```typescript
// Use Exa to find similar products and their approaches
const research = await exa___web_search_exa({
  query: "[Product concept] similar products features architecture",
  numResults: 5,
  type: "auto"
});

// Research best practices for the problem domain
const bestPractices = await exa___web_search_exa({
  query: "[Problem domain] best practices UX patterns",
  numResults: 5,
  type: "auto"
});
```

Analyze the research to understand:
- How successful products solve similar problems
- Common patterns and approaches in this space
- Potential differentiators for this product
- Technical architectures that work well

## Create Mission Document

Write `droidz/product/mission.md` using this structure:

```markdown
# Product Mission

## Vision
[2-3 sentences describing what this product will become and its impact]

## Problem Statement
[1-2 sentences describing the core problem being solved]

## Target Users
### Primary Users
[Description of main user group]

### Secondary Users
[Other user groups who will benefit]

## Success Criteria
- [Measurable goal 1]
- [Measurable goal 2]
- [Measurable goal 3]

## Differentiators
[What makes this product unique compared to alternatives found in research]

## Product Principles
- [Core principle 1]
- [Core principle 2]
- [Core principle 3]

## Research Insights
[2-3 key findings from Exa research that informed this mission]
```

## Validation
- Ensure mission aligns with gathered product info
- Verify success criteria are measurable
- Confirm differentiators are meaningful based on research
