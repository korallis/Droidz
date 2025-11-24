# Droidz Skills Library

**Comprehensive collection of AI agent skills for software development**

Skills extend AI agent capabilities with specialized workflows, domain expertise, and best practices. This library provides production-ready skills that work in both **Factory.ai** and **Claude Code**.

---

## 📚 Table of Contents

- [What Are Skills?](#what-are-skills)
- [Installation](#installation)
- [Skill Categories](#skill-categories)
- [Top 20 Essential Skills](#top-20-essential-skills)
- [Creating Custom Skills](#creating-custom-skills)
- [Platform Compatibility](#platform-compatibility)

---

## What Are Skills?

Skills are **model-invoked** capabilities that AI agents use on-demand. They package:

- **Workflows** - Step-by-step procedures for specific tasks
- **Expertise** - Domain knowledge and conventions
- **Best Practices** - Team standards and guardrails
- **Tool Integration** - Instructions for using specific tools/APIs

### Key Properties

- ✅ **Model-Invoked** - AI decides when to use them (not explicit commands)
- ✅ **Composable** - Can be chained together
- ✅ **Token-Efficient** - Lightweight and focused
- ✅ **Reusable** - Shared across projects and teams

---

## Installation

Skills are included with Droidz Framework v4.2.0+:

**Factory.ai:**
```
.factory/skills/<skill-name>/SKILL.md
```

**Claude Code:**
```
.claude/skills/<skill-name>/SKILL.md
```

**Installing:**
```bash
cd /path/to/your/project
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)
```

---

## Skill Categories

### 🧪 Testing & Quality
- `test-driven-development` - TDD workflow with red-green-refactor
- `code-review` - Comprehensive code review process
- `testing-e2e` - End-to-end testing patterns
- `debugging-systematic` - Systematic debugging approach
- `code-standards` - Enforce coding standards

### 🔧 Development Workflows
- `git-workflow` - Git best practices and branching
- `refactoring` - Safe refactoring patterns
- `migration-strategy` - Code migration workflows
- `ci-cd-pipeline` - CI/CD setup and optimization
- `error-handling` - Robust error handling

### 🎨 Frontend Development
- `frontend-component` - React/Vue component patterns
- `accessibility` - WCAG compliance and a11y
- `frontend-performance` - UI performance optimization

### ⚙️ Backend Development
- `backend-service` - Microservice architecture
- `api-design` - REST/GraphQL API design
- `database-design` - Schema design and optimization

### 🔒 Security & Operations
- `security-audit` - Security vulnerability scanning
- `performance-optimization` - Performance tuning
- `monitoring-logging` - Observability and logging
- `incident-response` - Production incident handling

### 📝 Documentation
- `documentation` - Technical documentation standards

---

## Top 20 Essential Skills

### 1. Test-Driven Development (TDD)
**When to use:** Writing new features, fixing bugs, refactoring code

Implements red-green-refactor cycle:
1. Write failing test first
2. Write minimal code to pass
3. Refactor while keeping tests green

### 2. Code Review
**When to use:** Reviewing pull requests, pre-merge validation

Comprehensive review checklist:
- Code quality and readability
- Test coverage
- Security vulnerabilities
- Performance implications
- Documentation updates

### 3. Systematic Debugging
**When to use:** Investigating bugs, tracking down issues

Four-phase debugging framework:
1. Reproduce the issue
2. Isolate the root cause
3. Form and test hypotheses
4. Implement and verify fix

### 4. Git Workflow
**When to use:** Creating branches, making commits, managing PRs

Best practices for:
- Branch naming conventions
- Commit message format
- PR descriptions
- Merge strategies

### 5. Refactoring
**When to use:** Improving code structure, reducing tech debt

Safe refactoring patterns:
- Extract method/function
- Rename for clarity
- Remove duplication
- Simplify conditionals

### 6. Performance Optimization
**When to use:** Slow endpoints, high memory usage, bottlenecks

Systematic optimization:
1. Profile and measure
2. Identify bottlenecks
3. Apply targeted optimizations
4. Verify improvements

### 7. Security Audit
**When to use:** Pre-deployment, security reviews, vulnerability scans

Checks for:
- SQL injection
- XSS vulnerabilities
- Authentication/authorization flaws
- Secrets exposure
- Dependency vulnerabilities

### 8. API Design
**When to use:** Creating new APIs, designing endpoints

RESTful/GraphQL design:
- Resource modeling
- Endpoint naming
- Request/response formats
- Error handling
- Versioning strategy

### 9. Database Design
**When to use:** Creating schemas, optimizing queries

Database best practices:
- Schema normalization
- Index strategy
- Query optimization
- Migration patterns

### 10. Frontend Component
**When to use:** Building React/Vue components

Component patterns:
- Props and state management
- Component composition
- Reusability patterns
- Testing strategies

### 11. Backend Service
**When to use:** Implementing microservices

Service design:
- API contracts
- Error handling
- Logging and monitoring
- Testing strategies

### 12. End-to-End Testing
**When to use:** Testing user flows, integration testing

E2E testing with:
- Playwright/Cypress
- User journey scenarios
- Cross-browser testing
- CI integration

### 13. CI/CD Pipeline
**When to use:** Setting up deployment pipelines

Pipeline best practices:
- Build automation
- Test execution
- Deployment strategies
- Rollback procedures

### 14. Documentation
**When to use:** Writing docs, README files, API specs

Documentation standards:
- Code comments
- README structure
- API documentation
- Architecture diagrams

### 15. Error Handling
**When to use:** Implementing error handling, logging errors

Robust error handling:
- Try-catch patterns
- Error propagation
- User-friendly messages
- Logging strategy

### 16. Accessibility (a11y)
**When to use:** Building accessible UIs

WCAG compliance:
- Semantic HTML
- ARIA attributes
- Keyboard navigation
- Screen reader support

### 17. Code Standards
**When to use:** Enforcing team standards, linting

Code quality checks:
- Style guide enforcement
- Linting configuration
- Formatting standards
- Pre-commit hooks

### 18. Migration Strategy
**When to use:** Migrating code, updating dependencies

Migration patterns:
- Incremental migration
- Feature flags
- Rollback strategy
- Testing approach

### 19. Monitoring & Logging
**When to use:** Setting up observability

Observability stack:
- Structured logging
- Metrics collection
- Distributed tracing
- Alerting rules

### 20. Incident Response
**When to use:** Production issues, outages

Incident workflow:
1. Detect and alert
2. Assess impact
3. Mitigate
4. Root cause analysis
5. Post-mortem

---

## Creating Custom Skills

### Skill Structure

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description)
│   └── Markdown instructions
└── references/ (optional)
    ├── examples.md
    └── checklists.md
```

### SKILL.md Format

```markdown
---
name: your-skill-name
description: Clear description of what this skill does and when to use it. Include specific triggers and use cases.
---

# Skill Name

## When to use this skill

- Specific use case 1
- Specific use case 2
- Specific use case 3

## Instructions

1. Step-by-step guidance
2. Expected inputs
3. Success criteria

## Examples

[Concrete examples of using this skill]

## Verification

[How to verify the skill worked correctly]
```

---

## Platform Compatibility

### Factory.ai
- **Location:** `.factory/skills/`
- **Personal:** `~/.factory/skills/`
- **Format:** `SKILL.md` or `skill.mdx`
- **Discovery:** Automatic on CLI restart

### Claude Code
- **Location:** `.claude/skills/`
- **Personal:** `~/.claude/skills/`
- **Format:** `SKILL.md`
- **Discovery:** Automatic on restart
- **Extras:** Supports `allowed-tools` frontmatter

---

## References

- [Factory.ai Skills Documentation](https://docs.factory.ai/cli/configuration/skills)
- [Claude Code Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- [Anthropic Official Skills Repo](https://github.com/anthropics/skills)
- [Awesome Skills Directory](https://skills.intellectronica.net/)

---

## Contributing

To add new skills or improve existing ones:

1. Follow the skill structure above
2. Test in both Factory.ai and Claude Code
3. Submit a pull request to [Droidz Repository](https://github.com/korallis/Droidz)

---

## License

Apache 2.0 - See LICENSE file for details

---

**Version:** 4.2.0  
**Last Updated:** 2025-11-24  
**Maintained by:** Droidz Framework Team
