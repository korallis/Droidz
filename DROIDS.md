# Custom Droids Guide

> **15 specialist droids that respect your model choice**

Droidz v3.0 provides 15 custom droids (subagents) that all use `model: inherit` to respect your model selection throughout the entire workflow.

---

## What Are Custom Droids?

**Custom droids are reusable subagents** that Factory.ai can spawn to handle specialized tasks.

Each droid has:
- **Specific expertise** (e.g., testing, infrastructure, security)
- **Appropriate tools** (e.g., Execute for infra, TodoWrite for orchestration)
- **Model inheritance** - Uses YOUR chosen model

### Key Feature: `model: inherit`

**All Droidz v3.0 droids use `model: inherit`:**

```yaml
---
name: droidz-codegen
description: Implements features and bugfixes with comprehensive tests
model: inherit  # ✅ Uses your model choice
tools: ["Read", "Execute", "Edit", "Create", "Grep", "Glob"]
---
```

**What this means:**
- You select GPT-4o → all droids use GPT-4o
- You switch to Claude Sonnet → all droids switch too
- **Consistent model across the entire workflow**

---

## The 15 Specialist Droids

### Core Droids (Most Common)

#### 1. droidz-orchestrator

**Purpose**: Coordinates parallel work, spawns other droids

**When Used**:
- User says "build [complex feature]"
- Request involves 3+ components (frontend + backend + tests)
- User mentions "parallel", "multiple features", "orchestrate"

**Capabilities**:
- Analyzes task complexity
- Breaks work into parallel streams
- Spawns specialist droids
- Tracks progress via TodoWrite
- Synthesizes results

**Example**:
```
You: /parallel "build authentication system"

droidz-orchestrator:
1. Analyzes: Frontend + Backend + Tests = 3 streams
2. Spawns: droidz-codegen (x2) + droidz-test
3. Monitors: TodoWrite updates every 30s
4. Completes: Synthesizes all work
```

**Tools**: Read, LS, Grep, Glob, Create, Edit, Execute, WebSearch, FetchUrl, ApplyPatch, TodoWrite

---

#### 2. droidz-codegen

**Purpose**: Implements features and fixes bugs

**When Used**:
- Implement new features
- Fix bugs
- Refactor code (simple cases)
- Add functionality

**Capabilities**:
- Writes production code
- Follows project patterns
- Adds comprehensive tests
- Documents changes

**Example**:
```
You: "Add JWT authentication API"

droidz-codegen:
- Creates auth.ts with JWT functions
- Adds API routes
- Writes unit tests
- Updates documentation
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob, TodoWrite, WebSearch, FetchUrl

---

#### 3. droidz-test

**Purpose**: Writes and fixes tests

**When Used**:
- Write unit tests
- Write integration tests
- Write E2E tests
- Fix failing tests
- Improve test coverage

**Capabilities**:
- Creates comprehensive test suites
- Follows TDD principles
- Writes effective assertions
- Avoids test anti-patterns
- Achieves high coverage

**Example**:
```
You: "Write tests for the auth system"

droidz-test:
- Creates auth.test.ts
- Tests success cases
- Tests error cases
- Tests edge cases
- Achieves 95% coverage
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob, TodoWrite

---

### Architecture Droids

#### 4. droidz-database-architect

**Purpose**: Designs database schemas and optimizes queries

**When Used**:
- Design database schema
- Plan migrations
- Optimize queries
- Design indexes
- Handle relations

**Capabilities**:
- Creates normalized schemas
- Designs efficient indexes
- Plans migration strategies
- Optimizes query performance
- Handles relationships (1:1, 1:N, N:M)

**Example**:
```
You: "Design database schema for e-commerce"

droidz-database-architect:
- Users table (normalized)
- Products with variants
- Orders with line items
- Indexes on foreign keys
- Migration plan
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob

---

#### 5. droidz-api-designer

**Purpose**: Designs REST/GraphQL APIs

**When Used**:
- Design API endpoints
- Plan API structure
- Design request/response formats
- API versioning strategy

**Capabilities**:
- RESTful design principles
- GraphQL schema design
- API documentation
- Versioning strategies
- Error handling patterns

**Example**:
```
You: "Design REST API for task management"

droidz-api-designer:
- GET /tasks (list)
- POST /tasks (create)
- PUT /tasks/:id (update)
- DELETE /tasks/:id (delete)
- Proper status codes
- Error responses
- OpenAPI spec
```

**Tools**: Read, LS, Edit, Create, Grep, Glob

---

### UI/UX Droids

#### 6. droidz-ui-designer

**Purpose**: Designs and implements UI components

**When Used**:
- Create React/Vue components
- Implement design systems
- Build reusable UI components
- Style with TailwindCSS/CSS

**Capabilities**:
- Component design
- Responsive layouts
- Accessibility (ARIA, keyboard nav)
- Design system implementation
- Modern CSS/Tailwind patterns

**Example**:
```
You: "Create a button component library"

droidz-ui-designer:
- Button.tsx (variants: primary, secondary, ghost)
- Proper TypeScript props
- Tailwind styling
- Accessibility (ARIA labels)
- Storybook stories
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob

---

#### 7. droidz-ux-designer

**Purpose**: Designs user flows and experiences

**When Used**:
- Plan user journeys
- Design workflows
- Improve UX
- Design onboarding flows

**Capabilities**:
- User flow mapping
- Journey optimization
- Interaction design
- Usability improvements
- Onboarding design

**Example**:
```
You: "Design onboarding flow for new users"

droidz-ux-designer:
1. Welcome screen (value prop)
2. Account creation (minimal fields)
3. Profile setup (optional)
4. Quick tutorial (interactive)
5. First action (guided)
```

**Tools**: Read, LS, Edit, Create, Grep, Glob

---

### Quality & Security Droids

#### 8. droidz-refactor

**Purpose**: Improves code quality and refactors

**When Used**:
- Clean up messy code
- Reduce technical debt
- Improve performance (code-level)
- Extract duplicated code
- Simplify complex logic

**Capabilities**:
- Identifies code smells
- Extracts reusable functions
- Simplifies complex logic
- Improves naming
- Maintains functionality

**Example**:
```
You: "Refactor the authentication module"

droidz-refactor:
- Extracts duplicate validation logic
- Simplifies nested conditionals
- Renames unclear variables
- Adds TypeScript types
- All tests still pass ✓
```

**Tools**: Read, LS, Execute, Edit, Grep, Glob

---

#### 9. droidz-security-auditor

**Purpose**: Reviews code for security issues

**When Used**:
- Security audit
- Check for vulnerabilities
- Review auth/permissions
- OWASP compliance

**Capabilities**:
- OWASP Top 10 checks
- SQL injection prevention
- XSS prevention
- CSRF protection
- Auth/authorization review
- Sensitive data handling

**Example**:
```
You: "Audit the payment processing code"

droidz-security-auditor:
❌ Found issues:
1. SQL injection risk in query
2. Missing CSRF token validation
3. API keys in plaintext

✅ Recommendations:
1. Use parameterized queries
2. Add CSRF middleware
3. Move keys to env variables
```

**Tools**: Read, Grep, Glob

---

#### 10. droidz-performance-optimizer

**Purpose**: Optimizes code and queries for speed

**When Used**:
- Improve performance
- Optimize database queries
- Reduce bundle size
- Fix slow endpoints

**Capabilities**:
- Identifies bottlenecks
- Optimizes database queries
- Reduces N+1 queries
- Adds caching strategies
- Improves algorithmic complexity

**Example**:
```
You: "Optimize the product listing page"

droidz-performance-optimizer:
Issues found:
- N+1 query (fetching categories)
- Missing database index
- Unoptimized images

Fixed:
✓ Use join to fetch categories
✓ Add index on product.category_id
✓ Implement lazy loading for images

Result: 2.5s → 350ms load time
```

**Tools**: Read, LS, Execute, Grep, Glob

---

#### 11. droidz-accessibility-specialist

**Purpose**: Ensures WCAG compliance and accessibility

**When Used**:
- Accessibility audit
- WCAG compliance
- Keyboard navigation
- Screen reader support

**Capabilities**:
- WCAG 2.1 AA/AAA compliance
- ARIA implementation
- Keyboard navigation
- Color contrast checks
- Screen reader testing
- Focus management

**Example**:
```
You: "Make the dashboard accessible"

droidz-accessibility-specialist:
❌ Issues found:
1. No ARIA labels on buttons
2. Poor color contrast (2.8:1, needs 4.5:1)
3. No keyboard navigation
4. Missing focus indicators

✅ Fixed:
- Added aria-label to all interactive elements
- Updated colors (now 5.2:1 contrast)
- Implemented keyboard shortcuts
- Visible focus outlines
```

**Tools**: Read, Edit, Create, Grep, Glob

---

### Infrastructure Droids

#### 12. droidz-infra

**Purpose**: Manages CI/CD, deployment, infrastructure

**When Used**:
- Set up CI/CD
- Configure deployments
- Docker/Kubernetes setup
- Environment management

**Capabilities**:
- GitHub Actions / GitLab CI
- Docker containerization
- Kubernetes manifests
- Environment variables
- Deployment automation

**Example**:
```
You: "Set up CI/CD pipeline"

droidz-infra:
Created:
- .github/workflows/ci.yml
  - Lint on push
  - Test on push
  - Deploy to staging (main branch)
  - Deploy to prod (tags)
- Dockerfile (multi-stage build)
- docker-compose.yml (local dev)
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob

---

#### 13. droidz-integration

**Purpose**: Integrates third-party APIs and services

**When Used**:
- Integrate external APIs
- Set up webhooks
- OAuth flows
- Third-party SDKs

**Capabilities**:
- API integration (Stripe, Twilio, etc.)
- Webhook handling
- OAuth implementation
- SDK configuration
- Error handling for external calls

**Example**:
```
You: "Integrate Stripe for payments"

droidz-integration:
Created:
- lib/stripe.ts (SDK setup)
- app/api/webhooks/stripe/route.ts
- Webhook signature verification
- Payment intent creation
- Subscription management
- Error handling + retries
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob, WebSearch, FetchUrl

---

### Utility Droids

#### 14. droidz-generalist

**Purpose**: Handles general tasks that don't fit other droids

**When Used**:
- Unclear task type
- Mixed responsibilities
- Exploratory work
- Documentation updates

**Capabilities**:
- General-purpose coding
- Documentation
- Configuration
- Exploratory tasks

**Example**:
```
You: "Update the README with new features"

droidz-generalist:
- Reads current README
- Identifies outdated sections
- Adds new feature docs
- Updates installation steps
- Fixes broken links
```

**Tools**: Read, LS, Execute, Edit, Create, Grep, Glob

---

## Droid Routing (Orchestrator Logic)

When `/parallel` is used, the orchestrator routes tasks to appropriate droids:

| Task Type | Routed To | Examples |
|-----------|-----------|----------|
| Frontend/UI | droidz-ui-designer | React components, pages |
| Backend/API | droidz-codegen | API endpoints, business logic |
| Database | droidz-database-architect | Schema design, migrations |
| Tests | droidz-test | Unit, integration, E2E tests |
| Refactor | droidz-refactor | Code cleanup, tech debt |
| Security | droidz-security-auditor | Security reviews, OWASP |
| Performance | droidz-performance-optimizer | Speed optimization |
| Infra/DevOps | droidz-infra | CI/CD, Docker, deployments |
| Integrations | droidz-integration | External APIs, webhooks |
| Accessibility | droidz-accessibility-specialist | WCAG compliance |
| API Design | droidz-api-designer | REST/GraphQL design |
| UX Flows | droidz-ux-designer | User journeys |
| General | droidz-generalist | Unclear or mixed tasks |

---

## Model Inheritance in Action

### Scenario 1: Using GPT-4o

```bash
# Select GPT-4o in Droid CLI
droid --model gpt-4o

You: /parallel "build auth system"

droidz-orchestrator (GPT-4o):
  Spawns:
  - droidz-codegen (GPT-4o) ✓
  - droidz-test (GPT-4o) ✓
  
All droids use GPT-4o!
```

### Scenario 2: Switching to Claude Sonnet

```bash
# Switch to Claude Sonnet
droid --model claude-sonnet-4

You: /parallel "build payment flow"

droidz-orchestrator (Claude Sonnet):
  Spawns:
  - droidz-codegen (Claude Sonnet) ✓
  - droidz-integration (Claude Sonnet) ✓
  
All droids use Claude Sonnet!
```

### Why This Matters

**Before v3.0 (mixed models):**
```
Orchestrator: GPT-4o
  → Codegen: Claude Sonnet (different!)
  → Test: GPT-4o (different!)
  
Result: Inconsistent code styles, potential confusion
```

**After v3.0 (model: inherit):**
```
Orchestrator: GPT-4o
  → Codegen: GPT-4o (same!)
  → Test: GPT-4o (same!)
  
Result: Consistent code styles, coherent output
```

---

## Creating Custom Droids

### Step 1: Create Droid File

```bash
mkdir -p .factory/droids
```

Create `.factory/droids/droidz-mobile-developer.md`:

```markdown
---
name: droidz-mobile-developer
description: Develops mobile apps with React Native or Flutter
model: inherit
tools: ["Read", "LS", "Execute", "Edit", "Create", "Grep", "Glob"]
---

# Mobile Developer Droid

You are a mobile development specialist.

## Your Expertise

- React Native development
- Flutter development
- Mobile UI patterns
- Platform-specific code (iOS/Android)
- App store deployment

## When You're Invoked

- User mentions "mobile app", "React Native", "Flutter"
- Task involves mobile-specific features
- Platform-specific implementations needed

## Your Approach

1. Ask about target platforms (iOS, Android, both)
2. Choose appropriate framework (React Native or Flutter)
3. Implement with platform best practices
4. Handle permissions, navigation, state
5. Prepare for app store deployment

## Deliverables

- Mobile app code
- Platform-specific configs
- Navigation setup
- State management
- Build instructions
```

### Step 2: Test Your Droid

```bash
You: "Build a React Native login screen"

# Check if your droid is available
/droids

# Should show: droidz-mobile-developer
```

### Step 3: Invoke Directly

```bash
# Invoke specific droid
@droidz-mobile-developer "Create a React Native splash screen"

# Or let orchestrator choose
/parallel "Build mobile onboarding flow"
```

---

## Best Practices

### 1. Always Use `model: inherit`

**✅ Good:**
```yaml
model: inherit
```

**❌ Bad:**
```yaml
model: claude-sonnet-4  # Forces specific model
```

**Why**: Respects user's model choice.

### 2. Specify Appropriate Tools

**For code-writing droids:**
```yaml
tools: ["Read", "LS", "Execute", "Edit", "Create", "Grep", "Glob", "TodoWrite"]
```

**For read-only auditors:**
```yaml
tools: ["Read", "Grep", "Glob"]
```

**For infrastructure:**
```yaml
tools: ["Read", "LS", "Execute", "Edit", "Create", "Grep", "Glob"]
```

### 3. Clear Descriptions

**✅ Good:**
```yaml
description: Implements features and bugfixes with comprehensive tests
```

**❌ Bad:**
```yaml
description: Codes stuff
```

### 4. Document When to Use

Include in droid body:

```markdown
## When You're Invoked

- User says "test X"
- Orchestrator needs tests written
- Test coverage needs improvement
```

---

## Troubleshooting

### Droid Not Showing in `/droids`

**Problem**: Created droid but it doesn't appear

**Solution**:
1. Check file is in `.factory/droids/`
2. Check file ends with `.md`
3. Check YAML frontmatter is valid
4. Restart Droid CLI

### Droid Uses Wrong Model

**Problem**: Droid uses different model than selected

**Solution**:
1. Check droid has `model: inherit` (not a specific model)
2. Verify YAML frontmatter syntax
3. Restart session

### Orchestrator Doesn't Choose My Droid

**Problem**: Created droid but orchestrator never uses it

**Solution**:
1. Make description clearer (mention trigger keywords)
2. Test by invoking directly: `@your-droid "task"`
3. Add "When You're Invoked" section to droid

---

## Advanced: Droid Chaining

Droids can spawn other droids:

```markdown
# droidz-fullstack

You are a full-stack developer droid.

## Approach

1. Analyze request
2. Spawn specialized droids:
   - @droidz-api-designer (design API)
   - @droidz-database-architect (design schema)
   - @droidz-ui-designer (design UI)
   - @droidz-test (write tests)
3. Coordinate their work
4. Integrate results
```

---

## Benefits Summary

✅ **Model consistency** - All droids respect your choice  
✅ **Specialized expertise** - Right droid for the job  
✅ **Parallel execution** - Work 3-5x faster  
✅ **Extensible** - Add custom droids anytime  
✅ **Factory.ai native** - Uses official custom droids feature  

---

## Further Reading

- [Factory.ai Custom Droids Documentation](https://docs.factory.ai/cli/configuration/custom-droids)
- [VALIDATION.md](./VALIDATION.md) - Validation system
- [SKILLS.md](./SKILLS.md) - Skills system
- [COMMANDS.md](./COMMANDS.md) - All commands

---

**15 specialist droids ready to accelerate your workflow** 🤖
