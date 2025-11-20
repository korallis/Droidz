# Specialist Routing System

## Overview

Droidz uses an **intelligent routing system** to automatically delegate tasks to specialized AI agents. Instead of one generalist assistant doing everything, tasks are routed to domain experts with optimized prompts, tools, and expertise.

## How It Works

### 1. SessionStart Hook

When you start a Factory.ai session in a project with Droidz installed, the `.factory/settings.json` file automatically loads routing instructions via the `SessionStart` hook.

**No AGENTS.md conflicts** - The routing system injects itself via hooks, so it never overwrites your existing `AGENTS.md` file.

### 2. UserPromptSubmit Hook

Before processing every user request, the assistant checks the **Routing Decision Tree** to determine which specialist (if any) should handle the task.

### 3. Automatic Delegation

If a specialist match is found, the assistant uses the **Task tool** to spawn the appropriate specialist droid with clear instructions.

## Routing Decision Tree

```
User Request
    │
    ├─ UI/Visual/Component work? → droidz-ui-designer
    ├─ User Experience/Flow/Journey? → droidz-ux-designer
    ├─ Database/Schema/Query work? → droidz-database-architect
    ├─ API Design/Endpoint planning? → droidz-api-designer
    ├─ External API Integration? → droidz-integration
    ├─ Testing/Coverage/QA? → droidz-test
    ├─ Refactoring/Code Quality? → droidz-refactor
    ├─ Security Audit/Review? → droidz-security-auditor
    ├─ Performance Optimization? → droidz-performance-optimizer
    ├─ Accessibility/WCAG? → droidz-accessibility-specialist
    ├─ CI/CD/Deployment/Docker? → droidz-infra
    ├─ Complex Multi-Component Feature? → droidz-orchestrator
    ├─ Feature Implementation/Bugfix? → droidz-codegen
    └─ Unclear/Mixed Domains? → droidz-generalist
```

## Specialist Reference

| Specialist | Triggers | Examples |
|------------|----------|----------|
| **droidz-ui-designer** | UI, components, styling, design systems | "Build a button", "Style the header", "Create a modal" |
| **droidz-ux-designer** | User flows, journeys, experience | "Improve onboarding", "Design checkout flow" |
| **droidz-database-architect** | Database, schema, queries, migrations | "Design schema", "Optimize query", "Create migration" |
| **droidz-api-designer** | API design, endpoint specs, docs | "Design REST API", "Plan endpoints", "API documentation" |
| **droidz-integration** | External APIs, webhooks, OAuth | "Integrate Stripe", "Add Slack webhook", "OAuth flow" |
| **droidz-test** | Tests, coverage, QA | "Write tests", "Fix failing tests", "Improve coverage" |
| **droidz-refactor** | Code quality, tech debt, cleanup | "Refactor module", "Clean up code", "Extract utilities" |
| **droidz-security-auditor** | Security, vulnerabilities, audits | "Security review", "Check for XSS", "OWASP audit" |
| **droidz-performance-optimizer** | Performance, profiling, optimization | "Optimize query", "Reduce bundle size", "Profile API" |
| **droidz-accessibility-specialist** | Accessibility, WCAG, a11y | "Make accessible", "ARIA labels", "WCAG compliance" |
| **droidz-infra** | CI/CD, builds, deployment, Docker | "Setup CI", "Fix build", "Deploy config" |
| **droidz-orchestrator** | Complex features with 3+ components | "Build auth system" (API + UI + tests) |
| **droidz-codegen** | Feature implementation, bug fixes | "Implement login", "Fix bug", "Add endpoint" |
| **droidz-generalist** | Unclear scope, mixed domains | "Help me understand this", "What's best approach?" |

## Trigger Keywords

The routing system looks for these keywords in user requests:

### UI/Frontend
- UI, component, style, design system, CSS, Tailwind
- button, form, modal, card, navbar, footer, layout
- responsive, animation, theme, colors

### UX/Experience
- UX, user flow, user journey, experience, usability
- onboarding, wizard, stepper, navigation
- user research, personas, accessibility

### Database
- database, schema, SQL, query, migration, index
- table, column, foreign key, constraint, join
- PostgreSQL, MySQL, MongoDB, Prisma

### API Design
- API design, endpoint, REST, GraphQL, OpenAPI
- route, controller, handler, middleware
- API documentation, spec, contract

### Integration
- integrate, integration, external API, third-party
- Stripe, Twilio, Slack, Sendgrid, AWS
- webhook, OAuth, SSO, API key

### Testing
- test, testing, coverage, QA, unit test, integration test
- E2E, end-to-end, Jest, Vitest, Playwright
- test suite, test case, assertion, mock

### Refactoring
- refactor, cleanup, clean up, tech debt, code quality
- restructure, extract, DRY, SOLID
- optimize code, simplify, modularize

### Security
- security, audit, vulnerability, penetration test
- XSS, CSRF, SQL injection, authentication, authorization
- OWASP, CVE, security review, threat model

### Performance
- performance, optimize, optimization, profiling, benchmark
- slow query, bundle size, lazy load, cache
- memory leak, CPU usage, latency

### Accessibility
- accessibility, a11y, WCAG, screen reader, ARIA
- keyboard navigation, focus management, semantic HTML
- contrast ratio, alt text, assistive technology

### Infrastructure
- CI/CD, pipeline, GitHub Actions, CircleCI, GitLab CI
- Docker, Kubernetes, deployment, build
- infrastructure, DevOps, cloud, AWS, Vercel

### Complex Features
- build [system], implement [system], create [application]
- Full auth system, payment processing, search feature
- Multiple components: API + UI + tests + deployment

## How to Use

### Automatic Routing (Recommended)

Just describe what you want in natural language:

```
User: "Build a login form with email and password"
Assistant: I'll delegate this to the UI Designer specialist...
[Spawns droidz-ui-designer]
```

The routing system automatically detects the domain and delegates.

### Manual Routing

You can explicitly request a specialist:

```
User: "Use the database architect to design a schema for users and posts"
Assistant: Using Database Architect specialist...
[Spawns droidz-database-architect]
```

### Viewing Available Specialists

```bash
# In Factory.ai CLI
/droids

# This shows all available specialists and their descriptions
```

## Why Specialists?

### Better Results
- **Optimized prompts** - Each specialist has domain-specific instructions
- **Deep expertise** - Specialists know best practices and patterns
- **Proper tooling** - Each has the exact tools needed for their domain

### Faster Execution
- **Parallel work** - Multiple specialists can work simultaneously
- **Focused context** - No context pollution from unrelated domains
- **Efficient prompts** - No need to explain domain basics

### Consistency
- **Standardized patterns** - Each specialist follows the same patterns
- **Quality gates** - Specialists enforce domain-specific best practices
- **Reproducible results** - Same specialist = same quality

## Configuration

The routing system is configured in `.factory/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "name": "specialist-routing-system",
        "type": "prompt",
        "prompt": "🤖 DROIDZ SPECIALIST ROUTING SYSTEM..."
      }
    ],
    "UserPromptSubmit": [
      {
        "name": "check-specialist-routing",
        "type": "prompt",
        "prompt": "🎯 ROUTING CHECK (MANDATORY)..."
      }
    ]
  }
}
```

### Customizing Routing

To add custom routing rules:

1. Edit `.factory/settings.json`
2. Update the `specialist-routing-system` or `check-specialist-routing` prompts
3. Add new trigger keywords or specialists
4. Reload the session

## Troubleshooting

### Specialist Not Being Used

**Problem**: Main assistant handles task directly instead of delegating.

**Solutions**:
1. Make request more specific - use trigger keywords
2. Explicitly request specialist: "Use the UI designer to..."
3. Check if specialist exists: `/droids` command
4. Verify `.factory/settings.json` has routing hooks

### Wrong Specialist Selected

**Problem**: Task delegated to wrong specialist.

**Solutions**:
1. Use more specific language in your request
2. Explicitly name the specialist you want
3. Provide more context about the domain
4. Check if there's a more appropriate specialist

### Specialist Not Available

**Problem**: Routing suggests specialist that doesn't exist.

**Solutions**:
1. Run `/droids` to see available specialists
2. Check `.factory/droids/` directory
3. Install missing specialists from Droidz
4. Fall back to `droidz-generalist`

## Advanced: Orchestrator

For complex features requiring **multiple specialists working in parallel**, use the **Orchestrator**:

```
User: "Build a complete authentication system"
