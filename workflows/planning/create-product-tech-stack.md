# Document Product Tech Stack

Research and document the complete technical stack for the product.

## Prerequisites
- `droidz/product/info.md` must exist
- `droidz/product/mission.md` must exist

## Research Phase (Use Exa + Ref)

If tech stack was not specified or needs validation, research optimal choices:

```typescript
// Research current best practices for the product type
const stackResearch = await exa___web_search_exa({
  query: "[Product type] [Year] best tech stack frameworks",
  numResults: 8,
  type: "auto"
});

// Get detailed documentation for considered technologies
const frameworkDocs = await ref___ref_search_documentation({
  query: "[Framework name] getting started architecture guide"
});

// Research integration patterns
const integrationResearch = await exa___get_code_context_exa({
  query: "[Framework A] with [Framework B] integration best practices",
  tokensNum: 5000
});
```

Analyze research to determine:
- Most suitable frameworks for the use case
- Community support and ecosystem maturity
- Integration patterns and compatibility
- Performance characteristics
- Developer experience

## Create Tech Stack Document

Write `droidz/product/tech-stack.md`:

```markdown
# Tech Stack

## Frontend
- **Framework**: [Framework name and version]
- **UI Library**: [Component library]
- **Styling**: [CSS framework/solution]
- **State Management**: [If needed]
- **Rationale**: [Why these choices based on research]

## Backend
- **Runtime**: [Node.js, Deno, etc.]
- **Framework**: [Express, Fastify, Next.js API, etc.]
- **Language**: [TypeScript, JavaScript, etc.]
- **Rationale**: [Why these choices based on research]

## Database
- **Primary Database**: [PostgreSQL, MongoDB, etc.]
- **ORM/Query Builder**: [Prisma, Drizzle, etc.]
- **Rationale**: [Why these choices based on research]

## Authentication
- **Solution**: [NextAuth, Clerk, Auth0, etc.]
- **Strategy**: [JWT, Session, etc.]
- **Rationale**: [Why this choice based on research]

## Deployment
- **Platform**: [Vercel, AWS, Railway, etc.]
- **CI/CD**: [GitHub Actions, etc.]
- **Rationale**: [Why these choices based on research]

## Development Tools
- **Package Manager**: [npm, pnpm, bun]
- **Linting**: [ESLint, Biome, etc.]
- **Testing**: [Jest, Vitest, Playwright, etc.]
- **Type Checking**: [TypeScript configuration]

## Third-Party Services
- [Service 1]: [Purpose]
- [Service 2]: [Purpose]

## Research Insights
[Key findings from Exa/Ref research that informed stack decisions]

## Integration Patterns
[Proven patterns for how these technologies work together]
```

## Validation
- Ensure all tech choices have documentation available (found via Ref)
- Verify compatibility between chosen technologies
- Confirm choices align with team experience level
- Check that deployment platform supports the stack
