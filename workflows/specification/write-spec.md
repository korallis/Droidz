# Write Specification

Create a comprehensive specification document for a feature using research and codebase analysis.

## Prerequisites
- `droidz/specs/[spec-slug]/planning/requirements.md` must exist

## Step 1: Research Documentation

Search for relevant documentation and implementation guides:

**Note:** This workflow is designed for Factory CLI. When running in Droid CLI, use WebSearch and FetchUrl instead of ref tools.

```bash
# Option 1: Using WebSearch (available in both Factory and Droid CLI)
# Search for technical documentation
# Example: "Next.js authentication implementation guide"
# Example: "Stripe API setup documentation"

# Option 2: Using FetchUrl (available in both Factory and Droid CLI)  
# Once you have specific URLs from search results, fetch the content
# Example: https://docs.stripe.com/api/authentication
```

## Step 2: Find Implementation Examples

Find implementation examples and patterns using web search:

**Note:** This workflow is designed for Factory CLI. When running in Droid CLI, use WebSearch instead of exa tools.

```bash
# Using WebSearch (available in both Factory and Droid CLI)
# Search for code examples and best practices
# Example: "React authentication implementation best practices GitHub"
# Example: "Next.js API routes examples"
# Example: "Stripe payment integration tutorial"
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
