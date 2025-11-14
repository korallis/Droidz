---
description: Save an architectural or technical decision to organization memory
argument-hint: "<category> <decision> [rationale]"
allowed-tools: Read, Edit, Create
---

# /save-decision

Records important architectural and technical decisions to organization memory for future reference.

## Usage

```bash
# Save architectural decision
/save-decision architecture "Use PostgreSQL for database" "Strong typing, good migrations"

# Save security policy
/save-decision security "Require MFA for all users" "Compliance requirement"

# Save performance guideline
/save-decision performance "API responses <200ms" "User experience target"

# Save testing strategy
/save-decision testing "80% coverage minimum" "Quality gate"

# Save deployment decision
/save-decision deployment "Use AWS ECS Fargate" "Managed, auto-scaling"
```

## What It Does

1. **Captures Decision Details**
   - Category (architecture, security, performance, etc.)
   - Decision text
   - Rationale/justification
   - Timestamp
   - Alternatives considered (if provided)

2. **Saves to Organization Memory**
   - Appends to `.factory/memory/org/decisions.json`
   - Preserves existing decisions
   - Maintains chronological order

3. **Makes Available to All Sessions**
   - Auto-loaded in future sessions
   - Accessible via `/load-memory org`
   - Used by agents in decision-making

## Categories

### architecture
System design and technology choices:
- Database selection
- Framework choices
- Design patterns
- System architecture
- Component structure

### security
Security policies and requirements:
- Authentication methods
- Authorization rules
- Data protection
- Compliance requirements
- Security standards

### performance
Performance targets and optimizations:
- Response time targets
- Caching strategies
- Optimization techniques
- Resource limits
- Scalability approaches

### testing
Testing strategies and requirements:
- Test frameworks
- Coverage targets
- Testing approaches (TDD, BDD)
- CI/CD integration
- Quality gates

### deployment
Infrastructure and deployment decisions:
- Hosting platform
- Container strategy
- CI/CD pipeline
- Monitoring/observability
- Disaster recovery

### tooling
Development tools and workflows:
- Build tools
- Linters/formatters
- Package managers
- IDE configurations
- Development workflows

## Example Output

```
📝 Saving Decision to Organization Memory...

Category: architecture
Decision: Use PostgreSQL for database
Rationale: Strong typing with Prisma, excellent migrations, proven performance
Timestamp: 2025-11-11T21:45:00Z

✅ Decision saved to .factory/memory/org/decisions.json

This decision will be:
- Available in all future sessions
- Loaded automatically when relevant
- Used by agents for consistency
- Visible to entire team

View all decisions: /load-memory org --category architecture
```

## Decision Record Format

Saved as JSON in `.factory/memory/org/decisions.json`:

```json
{
  "decisions": [
    {
      "id": "dec_20251111_214500",
      "timestamp": "2025-11-11T21:45:00Z",
      "category": "architecture",
      "title": "Database Selection",
      "decision": "Use PostgreSQL for database",
      "rationale": "Strong typing with Prisma, excellent migrations, proven performance",
      "alternatives": [
        "MySQL - considered but weaker typing",
        "MongoDB - considered but prefer relational"
      ],
      "participants": ["team"],
      "tags": ["database", "postgresql", "prisma"],
      "status": "active",
      "review_date": null
    }
  ]
}
```

## Interactive Mode

If rationale is omitted, prompts for details:

```
📝 Recording Decision: Use PostgreSQL for database

What was the rationale for this decision?
> Strong typing with Prisma, excellent migrations

What alternatives were considered? (comma-separated, or enter to skip)
> MySQL, MongoDB

Why were alternatives not chosen?
> MySQL: weaker typing support
> MongoDB: prefer relational model for our data

Any additional notes? (enter to skip)
> Team has PostgreSQL expertise

✅ Decision saved!
```

## Arguments

- `$1`: **Category** (required) - architecture, security, performance, testing, deployment, tooling
- `$2`: **Decision** (required) - What was decided
- `$3`: **Rationale** (optional) - Why this decision was made
- `$ARGUMENTS`: Additional details (alternatives, notes, etc.)

## Advanced Usage

### With Alternatives

```bash
/save-decision architecture \
  "Use Next.js for frontend" \
  "SSR support, excellent DX, strong ecosystem" \
  --alternatives "Remix: newer, less mature" "Vite+React: no SSR out of box"
```

### With Review Date

```bash
/save-decision security \
  "JWT token expiration: 15m" \
  "Balance security and UX" \
  --review "2026-01-01" # Review decision in 2 months
```

### Linking to Documentation

```bash
/save-decision deployment \
  "Use AWS ECS Fargate" \
  "See ADR-001 for full analysis" \
  --link "docs/adr/001-container-platform.md"
```

## Decision Status

Decisions can have status:
- `active`: Currently in effect (default)
- `deprecated`: No longer recommended
- `superseded`: Replaced by newer decision
- `proposed`: Under consideration

```bash
# Mark decision as deprecated
/update-decision dec_20251001 --status deprecated
```

## Integration with ADRs

For formal Architecture Decision Records (ADRs):

1. **Create ADR document:**
   ```markdown
   # ADR-001: Container Platform Selection
   
   ## Status: Accepted
   Date: 2025-11-11
   
   ## Context
   Need to deploy microservices with auto-scaling...
   
   ## Decision
   Use AWS ECS with Fargate...
   
   ## Consequences
   ...
   ```

2. **Save to memory:**
   ```bash
   /save-decision deployment \
     "Use AWS ECS Fargate" \
     "See docs/adr/001-container-platform.md"
   ```

3. **Link both** - ADR is detailed, memory is quick reference

## Viewing Decisions

```bash
# All decisions
/load-memory org

# Category-specific
/load-memory org --category architecture

# Search decisions
/search-decisions "database"
```

## Team Collaboration

Decisions are:
- ✅ Committed to git (`.factory/memory/org/decisions.json`)
- ✅ Shared with entire team
- ✅ Version controlled
- ✅ Reviewable in PRs

## Implementation

```typescript
// Read existing decisions
const orgMemory = JSON.parse(
  await Read('.factory/memory/org/decisions.json')
);

// Add new decision
orgMemory.decisions.push({
  id: generateId(),
  timestamp: new Date().toISOString(),
  category: $1,
  decision: $2,
  rationale: $3,
  participants: ['team'],
  status: 'active'
});

// Save back
await Edit('.factory/memory/org/decisions.json', 
  JSON.stringify(orgMemory, null, 2)
);
```

## Output Format

```
STATUS=SAVED
DECISION_ID=${id}
CATEGORY=${category}
```

## Best Practices

1. **Be Specific**: "Use PostgreSQL v14+ for primary database"
   Not: "Use database"

2. **Explain Why**: Include rationale for future context

3. **Document Alternatives**: Show what was considered

4. **Review Periodically**: Set review dates for time-sensitive decisions

5. **Link to Details**: Reference ADRs, docs, or discussions

6. **Update Status**: Deprecate outdated decisions

## Notes

- Decisions persist across all sessions
- Automatically loaded when relevant
- Used by agents for consistency
- Version controlled with code
- Team-wide visibility
