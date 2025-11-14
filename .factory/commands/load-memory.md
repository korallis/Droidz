---
description: Load organizational or user memory into context
argument-hint: "[org|user] [--category <name>]"
allowed-tools: Read
---

# /load-memory

Loads persistent memory (decisions, patterns, preferences) from previous sessions into current context.

## Usage

```bash
# Load organization memory (team decisions & patterns)
/load-memory org

# Load user memory (personal preferences)
/load-memory user

# Load both
/load-memory all

# Load specific category
/load-memory org --category architecture
/load-memory org --category security
```

## What It Does

### Organization Memory

Loads team-wide knowledge from `.factory/memory/org/`:

1. **Architectural Decisions**
   - Technology choices (databases, frameworks, etc.)
   - Design patterns adopted
   - Rationale and alternatives considered

2. **Code Patterns**
   - Discovered conventions
   - Reusable patterns
   - Team preferences

3. **Standards & Policies**
   - Security requirements
   - Performance guidelines
   - Code review criteria

### User Memory

Loads personal preferences from `.factory/memory/user/{username}.json`:

1. **Development Preferences**
   - Code style preferences
   - Testing approach
   - Git workflow

2. **Work History**
   - Common patterns you use
   - Frequently used tools
   - Your conventions

3. **Environment Setup**
   - OS and tools
   - Editor configuration
   - Container runtime

## Example Output

### Organization Memory

```
📚 Loading Organization Memory...

📋 Architectural Decisions (5 found)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. State Management
   Decision: Use Zustand for client state
   Rationale: Simpler API than Redux, better TypeScript support
   Date: 2025-10-15
   Alternatives: Redux, Jotai, Context API

2. Database Choice
   Decision: PostgreSQL with Prisma ORM
   Rationale: Strong typing, excellent migrations, good performance
   Date: 2025-09-20
   Alternatives: MySQL, MongoDB

3. Authentication
   Decision: JWT with refresh tokens (15m/7d expiration)
   Rationale: Stateless, works with microservices, mobile-friendly
   Date: 2025-09-10
   Alternatives: Session cookies, OAuth only

4. Testing Strategy
   Decision: Vitest for unit tests, Playwright for E2E
   Rationale: Faster than Jest, better TypeScript support
   Date: 2025-08-25
   Alternatives: Jest, Cypress

5. Deployment
   Decision: Docker + AWS ECS (Fargate)
   Rationale: Containerized, auto-scaling, managed infrastructure
   Date: 2025-08-01
   Alternatives: Kubernetes, traditional VMs

🎨 Code Patterns (3 found)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Repository Pattern for Data Access
   - All database operations through repository classes
   - Example: UserRepository, OrderRepository
   - Enables easy mocking for tests

2. Result<T, E> Pattern for Error Handling
   - No throwing exceptions in business logic
   - Explicit error handling at boundaries
   - TypeScript: type Result<T, E> = Success<T> | Failure<E>

3. Custom Hook Pattern for API Calls
   - All API calls through custom hooks
   - Example: useUser(id), useOrders()
   - Handles loading, error, and success states

🔒 Security Standards
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- All secrets in AWS Secrets Manager
- Input validation with Zod schemas
- Rate limiting: 5 req/15min on auth endpoints
- HTTPS required in production
- Security headers via Helmet.js

✅ Memory Loaded Successfully

This context is now available for the session. Agents will follow
these decisions and patterns automatically.
```

### User Memory

```
👤 Loading User Memory...

⚙️ Development Preferences
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Code Style:
- Function style: Arrow functions preferred
- Component style: Functional components
- Import organization: Absolute paths first

Testing:
- Approach: TDD (write tests first)
- Framework: Vitest
- Coverage threshold: 80%

Git:
- Commit style: Conventional commits
- Branch naming: feature/{ticket}-{description}

🎨 Common Patterns You Use
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Prefers custom hooks over inline logic
- Uses Zod for all input validation
- Follows Repository pattern for data access
- Uses React Query for server state
- Prefers composition over prop drilling

🛠️ Frequently Used Tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- React Query (for API calls)
- Tailwind CSS (for styling)
- Zod (for validation)
- TypeScript (strict mode)
- Vitest (for testing)

💻 Environment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OS: macOS
Editor: VSCode
Terminal: iTerm2
Container: Docker

✅ User Memory Loaded Successfully

Your personal preferences will be respected throughout this session.
```

## Memory Categories

### Organization Categories
- `architecture`: System design decisions
- `security`: Security policies and standards
- `performance`: Performance guidelines
- `testing`: Testing strategies
- `deployment`: Deployment and infrastructure

### User Categories
- `preferences`: Code style and workflow
- `patterns`: Personal coding patterns
- `tools`: Frequently used tools
- `environment`: Development setup

## When Memory is Auto-Loaded

The memory-manager skill automatically loads memory when:
- **SessionStart**: Loads relevant org and user memory
- **Context optimization**: Re-loads after compaction
- **New task**: Loads context-relevant memory

## Arguments

- `$1`: Scope (`org`, `user`, or `all`)
- `--category <name>`: Load only specific category

## Implementation

**Load organization memory:**
```typescript
const orgMemory = JSON.parse(
  await Read('.factory/memory/org/decisions.json')
);

// Filter by category if specified
const filtered = category 
  ? orgMemory.decisions.filter(d => d.category === category)
  : orgMemory.decisions;

// Format and display
displayDecisions(filtered);
```

**Load user memory:**
```typescript
const username = process.env.USER || 'default';
const userMemory = JSON.parse(
  await Read(`.factory/memory/user/${username}.json`)
);

displayPreferences(userMemory.preferences);
displayPatterns(userMemory.workHistory.commonPatterns);
```

## Saving to Memory

To save decisions to memory, use `/save-decision`:

```bash
/save-decision architecture "Use Zustand for state" "Simpler than Redux"
```

Or decisions are automatically saved when:
- Making architectural choices
- Establishing patterns
- Setting preferences

## Output Format

```
STATUS=LOADED
SCOPE=${scope}
DECISIONS_COUNT=${count}
PATTERNS_COUNT=${count}
PREFERENCES_COUNT=${count}
```

## Notes

- Memory persists across all sessions
- Organization memory is shared with team
- User memory is private to you
- Memory is backed up during optimization
- Can be version controlled (org memory)
