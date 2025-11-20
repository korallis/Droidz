# Spec: Meta-Prompting System - AI-Powered Feature Specification Generator

## 🎯 Overview

Add a powerful meta-prompting command (`/droidz-build`) that helps users go from vague ideas to fully-spec'd, execution-ready features. This adapts the taches-cc-prompts meta-prompting system to Droidz philosophy and Factory.ai Task tool patterns.

**Core Value:** Turn "I want to add auth" into complete, executable specifications with task decomposition, acceptance criteria, edge cases, and execution strategy.

---

## 📋 Feature: `/droidz-build` Command

### User Experience Flow

```
User: /droidz-build Add user authentication with email/password

Droid: 🔍 Analyzing your request...

I'll help you create a complete specification for user authentication. Let me clarify a few things:

1. Authentication method: Email/password only, or also social logins (Google, GitHub)?
2. Password requirements: Basic (8+ chars) or strict (uppercase, numbers, symbols)?
3. User roles: Single user type or multiple (admin, user, guest)?
4. Session handling: JWT, sessions, or other?
5. Existing codebase: Is this a new project or existing? [analyzing...]

Please answer what applies, or say 'continue' if I have enough context.

---

User: Just email/password, JWT, existing Next.js project

Droid: ✅ Got it! Creating specification for: JWT-based email/password authentication in Next.js

This will be a **complex** spec requiring:
- Backend authentication API (3-4 endpoints)
- Database schema for users
- Frontend auth UI (login, register, forgot password)
- Security requirements (OWASP, bcrypt, rate limiting)
- Test coverage

📝 Generating specification in parallel streams...

[TodoWrite showing spec generation progress]

✅ Specification complete! Saved to:
  .droidz/specs/001-user-authentication.md

**Ready to execute?**
1. Review spec first
2. Execute in parallel (3 agents)
3. Execute sequentially
4. Modify spec and regenerate
```

---

## 🏗️ Architecture

### New Files Structure

```
.factory/
  commands/
    droidz-build.md              # Meta-prompt command
    
.droidz/
  specs/                          # Generated specifications
    001-feature-name.md          # Individual specs
    002-next-feature.md
  tasks/                          # Task tracking (from init feature)
  architecture.md                 # From init feature
```

### Specification Format (XML-Structured)

Each generated spec follows this pattern:

```markdown
---
spec-id: 001
feature: User Authentication
complexity: complex
execution-strategy: parallel
created: 2025-11-15T...
dependencies: []
---

# Feature Specification: User Authentication

<objective>
Implement secure email/password authentication with JWT tokens for
an existing Next.js application, including registration, login,
password reset, and session management.
</objective>

<context>
Project: Existing Next.js 14 app (App Router)
Database: PostgreSQL with Prisma ORM
Current auth: None
Tech stack: Next.js 14, TypeScript, Prisma, Tailwind
Target users: End consumers (B2C SaaS)
</context>

<requirements>
**Functional Requirements:**
1. User registration with email verification
2. Secure login with bcrypt password hashing
3. JWT token-based session management
4. Password reset flow via email
5. Protected route middleware
6. Logout functionality

**Non-Functional Requirements:**
1. OWASP security standards compliance
2. Password strength: min 8 chars, 1 uppercase, 1 number
3. Rate limiting: 5 login attempts per 15 min
4. Email verification within 24 hours
5. JWT expiry: 7 days with refresh tokens
</requirements>

<task-decomposition>
**Phase 1: Database & Backend (Parallel)**

Task 1.1: Database Schema
- droidz: droidz-infra
- priority: high
- files: prisma/schema.prisma, migrations/
- acceptance:
  - User model with email, passwordHash, emailVerified, createdAt
  - RefreshToken model with userId, token, expiresAt
  - Indexes on email (unique), token
  - Migration runs successfully

Task 1.2: Auth API Endpoints
- droidz: droidz-codegen
- priority: high
- files: app/api/auth/*.ts
- dependencies: Task 1.1 complete
- acceptance:
  - POST /api/auth/register
  - POST /api/auth/login
  - POST /api/auth/logout
  - POST /api/auth/reset-password
  - All return proper error codes (400, 401, 429)

Task 1.3: Email Service Integration
- droidz: droidz-integration
- priority: medium
- files: lib/email.ts, lib/templates/
- acceptance:
  - Sends verification emails
  - Sends password reset emails
  - Uses environment vars for SMTP config

**Phase 2: Frontend & Tests (Parallel after Phase 1)**

Task 2.1: Auth UI Components
- droidz: droidz-codegen
- priority: high
- files: components/auth/*.tsx, app/(auth)/
- dependencies: Task 1.2 complete
- acceptance:
  - LoginForm component with validation
  - RegisterForm with password strength indicator
  - ForgotPasswordForm
  - Protected route wrapper component
  - All styled with Tailwind

Task 2.2: Auth Tests
- droidz: droidz-test
- priority: high
- files: __tests__/auth/
- dependencies: Tasks 1.1, 1.2, 2.1 complete
- acceptance:
  - API endpoint tests (happy path + errors)
  - Component tests (form validation, submission)
  - Integration tests (full registration → login flow)
  - 80%+ coverage
</task-decomposition>

<security-requirements>
**Critical Security Measures:**

1. Password Storage
   - MUST use bcrypt with salt rounds ≥ 10
   - NEVER store plain text passwords
   - Validate: Check bcrypt.hash() is used

2. JWT Security
   - Sign with strong secret (min 32 chars)
   - Use environment variable JWT_SECRET
   - Implement token expiry (7 days)
   - Validate: Check jwt.sign() has expiresIn

3. Rate Limiting
   - Max 5 login attempts per IP per 15 minutes
   - Return 429 Too Many Requests
   - Validate: Test with 6 rapid requests

4. Input Validation
   - Sanitize all user inputs
   - Email format validation
   - Password strength requirements
   - Validate: Tests cover malicious inputs

5. HTTPS Only
   - Secure flag on cookies
   - HttpOnly flag on JWT cookies
   - Validate: Check cookie options
</security-requirements>

<edge-cases>
**Scenarios to Handle:**

1. Email Already Registered
   - Error: "Email already in use"
   - Status: 400
   - Don't reveal if email exists (security)

2. Unverified Email Login Attempt
   - Error: "Please verify your email first"
   - Status: 403
   - Resend verification option

3. Expired Verification Token
   - Error: "Verification link expired"
   - Action: Generate new token
   - Email new link

4. Concurrent Login Sessions
   - Allow multiple devices
   - Track active sessions
   - Option to "logout all devices"

5. Password Reset Token Reuse
   - Tokens are single-use
   - Invalidate after password change
   - Expire after 1 hour
</edge-cases>

<testing-strategy>
**Test Coverage Plan:**

Unit Tests:
- bcrypt hashing/comparison
- JWT generation/verification
- Email validation logic
- Rate limiter function

Integration Tests:
- Full registration flow
- Login → protected route access
- Password reset end-to-end
- Token refresh mechanism

E2E Tests (Playwright):
- User registers → receives email → verifies → logs in
- User forgets password → resets → logs in
- Failed login attempts trigger rate limit
</testing-strategy>

<verification-criteria>
**Before Marking Complete:**

✅ All API endpoints return correct status codes
✅ Passwords are bcrypted (verified in DB)
✅ JWT tokens have proper expiry
✅ Email verification flow works end-to-end
✅ Rate limiting blocks after 5 attempts
✅ All tests pass with 80%+ coverage
✅ No hardcoded secrets (all in .env)
✅ Protected routes redirect unauthenticated users
✅ Security checklist reviewed (OWASP Top 10)
</verification-criteria>

<execution-plan>
**Recommended Execution:**

Parallel Execution (3-5x faster):
Task({
  subagent_type: "droidz-infra",
  description: "Database schema for auth",
  prompt: [Task 1.1 details]
});

Task({
  subagent_type: "droidz-codegen",
  description: "Auth API endpoints",
  prompt: [Task 1.2 details]
});

Task({
  subagent_type: "droidz-integration",
  description: "Email service integration",
  prompt: [Task 1.3 details]
});

// After Phase 1 completes, spawn Phase 2 in parallel

Estimated Time:
- Sequential: 8-12 hours
- Parallel: 2.5-4 hours
- Speedup: 3-4x
</execution-plan>

<compliance-checklist>
**GDPR/Privacy Requirements:**

- [ ] User data deletion endpoint
- [ ] Privacy policy link on registration
- [ ] Email consent checkbox
- [ ] Data export capability
- [ ] Secure password recovery

**OWASP Top 10:**

- [ ] A01:2021 – Broken Access Control → JWT validation
- [ ] A02:2021 – Cryptographic Failures → bcrypt, HTTPS
- [ ] A03:2021 – Injection → Input sanitization
- [ ] A04:2021 – Insecure Design → Rate limiting
- [ ] A05:2021 – Security Misconfiguration → env vars
- [ ] A07:2021 – Auth Failures → Strong passwords, MFA ready
</compliance-checklist>

<success-metrics>
**How to Measure Success:**

1. Security Metrics:
   - 0 plaintext passwords in DB
   - 100% of endpoints have rate limiting
   - 0 hardcoded secrets in codebase

2. Quality Metrics:
   - Test coverage ≥ 80%
   - All edge cases have tests
   - 0 critical vulnerabilities (run `npm audit`)

3. UX Metrics:
   - Login response time < 500ms
   - Registration flow completion rate > 90%
   - Password reset email delivery < 30 seconds

4. Code Quality:
   - TypeScript strict mode enabled
   - No ts-ignore or eslint-disable
   - All functions have JSDoc comments
</success-metrics>

</specification>
```

---

## 🔧 Implementation Details

### `/droidz-build` Command Structure

```markdown
---
description: AI-powered spec generator - turn ideas into execution-ready features
argument-hint: "feature description"
---

You are an expert specification engineer for Droidz. Your mission: transform vague feature requests into comprehensive, executable specifications.

## Core Process

### Step 1: Clarity Check (Golden Rule)

Analyze $ARGUMENTS to determine:

1. **Is this clear enough to spec?**
   - Would a developer with minimal context understand what's being asked?
   - Are there ambiguous terms that could mean multiple things?
   - Are there missing details about constraints or requirements?
   - Is the context clear (who it's for, why it matters)?

2. **What's the project context?**
   - Read .droidz/project.json if exists (greenfield vs brownfield)
   - Check package.json for tech stack
   - Use Grep to identify framework patterns

3. **What's the complexity level?**
   - Simple: Single file, clear goal, < 2 hours
   - Moderate: 2-5 files, some research, 2-6 hours
   - Complex: 5+ files, multiple domains, 6+ hours

### Step 2: Clarification (If Needed)

If request is vague or missing critical info, ask targeted questions:

```
🔍 I'll create a spec for: [brief summary]

To make this comprehensive, I need to clarify:

1. [Specific question about ambiguous aspect]
2. [Question about constraints/requirements]
3. What is this for? What's the end goal?
4. Who is the intended user?
5. [Ask for examples if relevant]

Answer what applies, or say 'continue' if I have enough.
```

**Examples of When to Ask:**

- "Add dashboard" → "What type? Admin, analytics, user-facing? What data?"
- "Fix the bug" → "Which bug? What's expected vs actual behavior?"
- "Add auth" → "What type? JWT, OAuth, session? Which providers?"
- "Optimize performance" → "Which aspect? Load time, memory, DB queries?"

### Step 3: Confirmation

Once you have enough information:

```
✅ I'll create a specification for: [summary]

**Complexity:** [Simple/Moderate/Complex]
**Approach:** [key approach description]
**Execution Strategy:** [Parallel/Sequential/Mixed]
**Estimated Time:** 
  - Sequential: [X hours]
  - Parallel: [Y hours]
  - Speedup: [Z]x

Proceed, or adjust anything?
```

### Step 4: Generate Specification

Use exa-code and ref MCP to research:

```typescript
// Research industry best practices
const research = await exa.getCodeContext({
  query: `${framework} ${featureType} best practices security patterns 2025`,
  tokensNum: 8000
});

// Get documentation for specific tech
const docs = await ref.searchDocumentation({
  query: `${framework} ${feature} implementation guide`
});
```

**Generate spec with these sections:**

<objective>Clear, single-sentence goal</objective>

<context>
User provided: $ARGUMENTS
Project type: [from .droidz/project.json]
Tech stack: [from package.json + analysis]
Constraints: [from context]
</context>

<thinking>
Key questions this spec must answer:
- What patterns should we follow?
- What are the key architectural decisions?
- What could go wrong?
- How do we validate success?
</thinking>

<requirements>
**Functional Requirements:**
1. [Specific requirement]
2. [Another requirement]

**Non-Functional Requirements:**
1. Performance targets
2. Security requirements
3. Scalability needs
</requirements>

<task-decomposition>
**Phase 1: [Name] (Parallel/Sequential)**

Task 1.1: [Task name]
- droidz: [droidz-codegen/test/refactor/integration/infra]
- priority: [high/medium/low]
- files: [affected files]
- dependencies: [other tasks if any]
- acceptance:
  - [Specific acceptance criterion]
  - [Another criterion]

[Repeat for each task]
</task-decomposition>

<security-requirements>
[If applicable - OWASP, GDPR, data handling]
</security-requirements>

<edge-cases>
[Potential failure scenarios and how to handle]
</edge-cases>

<testing-strategy>
[Unit, integration, E2E test plans]
</testing-strategy>

<verification-criteria>
**Before marking complete:**
✅ [Specific success criterion]
✅ [Another criterion]
</verification-criteria>

<execution-plan>
**Recommended Execution:**

[For each task, show Task tool invocation]

Task({
  subagent_type: "droidz-[type]",
  description: "[1-sentence description]",
  prompt: `# Task: [Task Name]

## Objective
[From task-decomposition]

## Context
[Relevant context from main spec]

## Requirements
[Specific requirements for this task]

## Acceptance Criteria
[From task-decomposition]

## CRITICAL: Progress Reporting
⏰ USE TodoWrite EVERY 60 SECONDS to report progress

## Files to Modify/Create
[List of files]

## Success Criteria
[How to verify completion]
`
});

Estimated Time:
- Sequential: [X hours]
- Parallel: [Y hours]
</execution-plan>

### Step 5: Save and Present Options

Save spec to `.droidz/specs/[number]-[feature-name].md`

**Determine next number:**
```bash
!ls .droidz/specs/ 2>/dev/null | sort -V | tail -1
```

If `.droidz/specs/` doesn't exist:
```bash
!mkdir -p .droidz/specs/
```

**Present Decision Tree:**

```
✓ Saved specification to .droidz/specs/003-user-authentication.md

📊 **Specification Summary:**
- Complexity: Complex
- Tasks: 6 (3 parallel in Phase 1, 3 parallel in Phase 2)
- Estimated Time: 
  - Sequential: 8-12 hours
  - Parallel: 2.5-4 hours
  - Speedup: 3-4x faster

**What's next?**

1. Review spec first (I'll display it)
2. Execute in parallel (recommended - spawns 3-5 agents)
3. Execute sequentially (safer for shared files)
4. Modify specification and regenerate
5. Save for later

Choose (1-5): _
```

**If user chooses #1 (Review):**
Display the full spec with syntax highlighting

**If user chooses #2 (Execute Parallel):**
```typescript
// Parse execution-plan section
// Extract all Task() calls
// Invoke them in parallel via Task tool

Task({
  subagent_type: "droidz-infra",
  description: "Database schema for authentication",
  prompt: [full prompt from spec]
});

Task({
  subagent_type: "droidz-codegen",
  description: "Auth API endpoints",
  prompt: [full prompt from spec]
});

// etc...
```

**If user chooses #3 (Execute Sequential):**
Execute tasks one-by-one, waiting for completion

**If user chooses #4 (Modify):**
Ask what to change and regenerate

**If user chooses #5:**
Confirm saved location

---

## 🎯 Integration with `/droidz-init`

When user runs `/droidz-init`, after analysis:

```
🎯 What would you like to build?

[Provide your goal - I'll create a complete specification]

Examples:
- "Add user authentication with JWT"
- "Build a blog with comments and tags"
- "Create an admin dashboard with analytics"
- "Implement real-time chat"

You can also use: /droidz-build [feature]
```

Then internally invoke `/droidz-build` with the user's input.

---

## 📊 Spec Quality Rules

### Intelligence Rules

1. **Clarity First (Golden Rule)**
   - If anything is unclear, ask before generating
   - Test: Would a colleague with minimal context understand this?

2. **Context is Critical**
   - Include WHY the feature matters
   - WHO will use it
   - WHAT it will achieve

3. **Be Explicit**
   - Specific instructions over vague guidance
   - Concrete acceptance criteria
   - Measurable success metrics

4. **Research-Driven**
   - Use exa-code for industry best practices
   - Use ref MCP for framework documentation
   - Include security standards when relevant

5. **Task Decomposition**
   - Break into parallelizable units
   - Identify dependencies clearly
   - Assign to appropriate specialist droids

6. **Verification Always**
   - Clear success criteria
   - Security checklists
   - Testing requirements

### Prompt Construction Rules

**Always Include:**
- XML structure with semantic tags
- Contextual information (why, who, what)
- Explicit, sequential steps
- File paths for outputs
- Success criteria in <verification-criteria>
- Progress reporting instructions for droids

**Conditionally Include:**
- Security requirements (auth, payments, user data)
- Compliance checklists (GDPR, OWASP, SOC2)
- Edge cases and failure scenarios
- Performance requirements
- Examples of expected behavior

**For Droidz Prompts:**
```markdown
# Task: [Name]

## Objective
[Clear goal]

## Context
Project: [type]
Tech Stack: [versions]
User provided: [original request]

## Requirements
[Functional + Non-functional]

## CRITICAL: Progress Reporting
⏰ USE TodoWrite EVERY 60 SECONDS

TodoWrite({
  todos: [
    {id: "1", content: "Step description", status: "in_progress", priority: "high"}
  ]
});

## Files to Modify/Create
- path/to/file.ts - [what it should contain]

## Acceptance Criteria
✅ [Criterion 1]
✅ [Criterion 2]

## Success Criteria
[How to verify this is complete]

## Tools Available
["Read", "LS", "Execute", "Edit", "Create", "Grep", "Glob", "TodoWrite", "WebSearch", "FetchUrl"]
```

---

## 🚀 Benefits

### For "Monkey Users"

Before:
```
User: "Add authentication"
Droid: "Here's a login form..."
[Missing: password reset, email verification, security, tests, etc.]
```

After:
```
User: "Add authentication"
Droid: 
  [Asks clarifying questions]
  [Researches best practices]
  [Generates 6-task specification]
  [Includes security checklist]
  [Provides edge cases]
  [Creates test plan]
  [Estimates 3x speedup via parallel execution]
  "Ready to execute?"
```

### For Experienced Users

- **Consistency**: Same specification format every time
- **Completeness**: Never forget security, tests, or edge cases
- **Efficiency**: Parallel execution plans generated automatically
- **Documentation**: Specs serve as permanent project documentation
- **Iteration**: Easy to modify and regenerate

---

## 📦 Dependencies

None! Uses existing capabilities:
- exa-code (already integrated)
- ref MCP (already integrated)
- Task tool (core Droidz feature)
- TodoWrite (existing tool)
- File system tools (Read, Create, LS)

---

## 🎬 Example Flows

### Flow 1: Simple Feature

```
User: /droidz-build Add a contact form

Droid: ✅ Creating spec for: Contact form with email delivery

This is a **simple** feature.

[Generates 1-page spec with 2 tasks]

Saved to: .droidz/specs/001-contact-form.md

Execute now? (1 agent, ~45 min)
```

### Flow 2: Complex System

```
User: /droidz-build Build a blog with comments, tags, search

Droid: 🔍 Analyzing... This is complex. Clarifying:

1. Comment system: Nested replies or flat?
2. Search: Full-text or simple?  
3. Auth required for comments?

User: Nested comments, full-text search, yes require auth

Droid: ✅ Creating spec for: Blog system with nested comments, full-text search, and authentication

This is a **complex** feature requiring:
- Database models (Posts, Comments, Tags, Users)
- Full-text search integration (Algolia/Elasticsearch)
- Frontend UI (blog listing, post detail, comment threads)
- Authentication system
- Admin panel

[Generates 12-task specification with 3 phases]

Saved to: .droidz/specs/001-blog-system.md

**Execution Strategy:** 
Phase 1: 4 parallel tasks (DB schema, auth, search indexing, base UI)
Phase 2: 5 parallel tasks (blog CRUD, comments, tags, search UI, admin)
Phase 3: 3 sequential tasks (integration tests, E2E tests, deployment)

Time: 24 hours sequential → 6-8 hours parallel (3x speedup)

Execute in parallel? (spawns 4 agents for Phase 1)
```

---

## 🎯 Success Metrics

**Feature completeness:**
- 95%+ of generated specs include security requirements when relevant
- 100% include task decomposition with acceptance criteria
- 100% include progress reporting instructions for droids
- 90%+ identify parallelization opportunities correctly

**User satisfaction:**
- Users spend 80% less time writing specs manually
- 70% reduction in "forgot to consider X" issues
- 3-5x execution speedup via parallel task execution

---

This spec creates a powerful meta-prompting system that turns vague ideas into production-ready specifications. Ready to implement?