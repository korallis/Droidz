# Write Specification

Create a comprehensive specification document for a feature using research and codebase analysis.

## Prerequisites
- `droidz/specs/[spec-slug]/planning/requirements.md` must exist

## Step 1: Research with Ref

Search for relevant documentation and implementation guides:

```typescript
// Find documentation for the tech stack being used
const docs = await ref___ref_search_documentation({
  query: "[Tech stack framework] [Feature concept] implementation guide"
});

// Find API documentation for any third-party services
const apiDocs = await ref___ref_search_documentation({
  query: "[Service name] API authentication setup"
});

// Read specific documentation URLs
const detailedDocs = await ref___ref_read_url({
  url: "[Exact URL from search results]"
});
```

## Step 2: Research with Exa Code

Find implementation examples and patterns:

```typescript
// Find code examples for this feature type
const codeExamples = await exa___get_code_context_exa({
  query: "[Framework] [Feature] implementation examples best practices",
  tokensNum: 8000
});

// Find integration patterns
const integrationPatterns = await exa___get_code_context_exa({
  query: "[Service A] integrate with [Service B] [Framework] example",
  tokensNum: 5000
});
```

## Step 3: Analyze Existing Codebase

Search for reusable code and patterns:

```bash
# Find similar features or components
grep -r "[relevant keyword]" . --include="*.ts" --include="*.tsx"

# Search for API patterns
find . -name "*api*" -o -name "*service*"

# Look for authentication/database/UI patterns relevant to this feature
```

## Step 4: Write the Specification

Create `droidz/specs/[spec-slug]/spec.md`:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing the core objective]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- [Up to 3 user stories total]

## Technical Approach

### Architecture
[High-level technical approach informed by research]

### Implementation Strategy
[How this will be built, referencing researched patterns]

## Specific Requirements

### [Requirement Group 1]
- [Detailed requirement with context from research]
- [Implementation note referencing code examples found]
- [API endpoints or database schema if applicable]

### [Requirement Group 2]
- [Requirements...]

[Up to 10 requirement groups]

## API/Database Design

### Endpoints (if applicable)
- `[METHOD] /api/[endpoint]` - [Purpose]
  - Request: [Schema]
  - Response: [Schema]

### Database Schema (if applicable)
- **[Table/Collection name]**
  - [field]: [type] - [description]

## UI Components (if applicable)

### [Component Name]
- Purpose: [What it does]
- Props: [Expected props]
- State: [State management approach]
- Pattern: [Reference to researched UI pattern]

## Existing Code to Leverage

### [File/Component Name]
- Location: [Path]
- What it does: [Description]
- How to reuse: [Specific guidance]
- Pattern to follow: [What to replicate]

[Up to 5 existing code references]

## Integration Points

### [Service/Module Name]
- How this feature integrates
- API calls or events
- Data flow

## Documentation References
[List key Ref documentation URLs that should be referenced during implementation]

## Code Examples
[Brief snippets or patterns from Exa research to follow]

## Out of Scope
- [Specific feature that will NOT be built]
- [Another out-of-scope item]

## Testing Strategy
- [Unit test requirements]
- [Integration test requirements]
- [E2E test scenarios]

## Standards Compliance
[Check standards/*.md and note any specific requirements for this feature]
```

## Step 5: Validate Specification

- Ensure all requirements from `requirements.md` are addressed
- Verify technical approach aligns with `droidz/product/tech-stack.md`
- Check that patterns follow `standards/*.md`
- Confirm documentation references are complete
- Verify spec is implementable given researched examples

## Output
- ✅ Complete specification at `droidz/specs/[spec-slug]/spec.md`
- ✅ Ready for task breakdown phase
