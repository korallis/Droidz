# Create Product Roadmap

Generate an ordered feature checklist based on the product mission and research.

## Prerequisites
- `droidz/product/mission.md` must exist
- `droidz/product/info.md` must exist

## Research Phase (Use Exa Code)

Research implementation patterns and technical approaches:

```typescript
// Research framework-specific patterns for the chosen tech stack
const techResearch = await exa___get_code_context_exa({
  query: "[Tech stack] best practices project structure patterns",
  tokensNum: 5000
});

// Research implementation approaches for each major feature
const featureResearch = await exa___get_code_context_exa({
  query: "[Feature category] implementation patterns examples",
  tokensNum: 5000
});
```

Analyze research to determine:
- Technical dependencies between features
- Proven implementation patterns
- Optimal feature sequencing
- Complexity estimates based on real examples

## Creating the Roadmap

1. **Review the Mission** - Read `droidz/product/mission.md` to understand goals
2. **Identify Features** - Based on mission and info.md, list concrete features
3. **Research-Driven Ordering** - Use Exa research to order by:
   - Technical dependencies (foundational features first)
   - Proven implementation patterns
   - Complexity informed by real-world examples
   - Most direct path to achieving the mission

## Roadmap Structure

Create `droidz/product/roadmap.md`:

```markdown
# Product Roadmap

## MVP Phase

1. [ ] **[Feature Name]** — [1-2 sentence description] `[Effort]`
   - Dependencies: [None or other feature names]
   - Pattern: [Implementation pattern from research]

2. [ ] **[Feature Name]** — [1-2 sentence description] `[Effort]`
   - Dependencies: [Feature 1]
   - Pattern: [Implementation pattern from research]

[Continue for all MVP features...]

## Post-MVP Phase

1. [ ] **[Enhancement Name]** — [1-2 sentence description] `[Effort]`
   - Dependencies: [MVP feature names]
   - Pattern: [Implementation pattern from research]

[Continue for post-MVP features...]

## Research Insights
[Key technical findings from Exa research that informed this roadmap]

---

**Effort Scale:**
- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks
```

## Validation
- Ensure features map to mission success criteria
- Verify dependencies are correctly sequenced
- Confirm effort estimates align with research findings
- Check that each feature is testable and complete
