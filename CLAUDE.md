# Droidz Framework for Claude Code

You are working with the **Droidz Framework** (v3.2.0) - a production-grade AI development system designed for Claude Code.

## 🎯 What is Droidz?

Droidz transforms vague ideas into production code through:
- **15 specialist agents** for parallel execution (3-5x faster)
- **61 auto-activating skills** for domain expertise
- **4 slash commands** for workflow orchestration
- **Comprehensive validation** pipeline (5 phases)
- **Memory system** for persistent context

---

## 🤖 Available Agents

You have access to **15 specialist agents** in `.claude/agents/`:

### Core Workflow
- **orchestrator** - Coordinates parallel work streams, spawns specialist agents
- **codegen** - Implements features with comprehensive tests
- **test** - Writes and fixes tests, ensures coverage
- **refactor** - Code quality improvements, tech debt reduction

### Infrastructure & Integration
- **infra** - CI/CD, deployment, Docker, GitHub Actions
- **integration** - External API integrations, webhooks, third-party services
- **generalist** - Safe fallback for miscellaneous tasks

### Design & UX  
- **ui-designer** - Beautiful user interfaces, component design
- **ux-designer** - User experiences, flows, interaction patterns
- **accessibility-specialist** - WCAG compliance, screen readers, inclusive design

### Architecture & Performance
- **database-architect** - Schema design, query optimization, migrations
- **api-designer** - REST/GraphQL API design, documentation
- **performance-optimizer** - Profiling, caching, bottleneck resolution
- **security-auditor** - Security reviews, OWASP compliance, threat modeling

---

## ⚡ Slash Commands

Use these commands to orchestrate workflows:

### `/init`
Initialize project analysis:
- Auto-detects tech stack
- Scans project structure
- Generates validation workflow
- Creates memory structure

### `/build`
Generate feature specs from vague ideas:
- Asks clarifying questions
- Creates detailed implementation plan
- Identifies dependencies
- Offers parallel execution

### `/parallel`
Execute tasks in parallel:
- Spawns multiple specialist agents
- 3-5x faster than sequential
- Live progress tracking via todos
- Automatic result synthesis

### `/validate`
Run comprehensive validation (5 phases):
- Phase 1: Linting (ESLint, ruff, etc.)
- Phase 2: Type checking (TypeScript, mypy)
- Phase 3: Style checking (Prettier, black)
- Phase 4: Unit tests
- Phase 5: E2E tests

---

## 🧠 When to Use Agents

**Use agents proactively** for these scenarios:

### Complex Features → **orchestrator**
- "Build authentication system"
- "Add payment processing"
- "Implement search feature"
- Any task involving 5+ files or multiple domains

### New Code → **codegen**
- Feature implementation
- API endpoint creation
- Component development

### Test Failures → **test**
- Write missing tests
- Fix failing tests
- Improve coverage

### Security Review → **security-auditor**
- Pre-deployment security checks
- Vulnerability scanning
- OWASP compliance

### Performance Issues → **performance-optimizer**
- Slow queries
- Large bundle sizes
- Memory leaks

### API Integration → **integration**
- Stripe, Twilio, SendGrid
- OAuth providers
- Webhook handling

---

## 📚 Skills Auto-Activation

**61 skills** in `.claude/skills/` auto-activate based on context (no manual selection needed):

### Frameworks & Libraries
- **TypeScript** - Types, interfaces, generics
- **React** - Hooks, components, Server Components
- **Next.js** - App Router, caching, PPR
- **Vue** - Composition API, Nuxt patterns
- **TailwindCSS** - Modern utilities, v4 features

### Databases
- **PostgreSQL** - Schema design, indexing, optimization
- **Prisma** - ORM, migrations, type-safe queries
- **Drizzle** - Lightweight ORM patterns
- **Supabase** - RLS policies, realtime, auth

### Backend & APIs
- **tRPC** - Type-safe APIs, procedures
- **GraphQL** - Schemas, resolvers, federation
- **Stripe** - Payments, subscriptions, webhooks

### Cloud & Deployment
- **Vercel** - Deployment, edge functions
- **Cloudflare Workers** - Edge computing
- **Neon** - Serverless Postgres branching

### Development Practices
- **Test-Driven Development** - Write tests first
- **Systematic Debugging** - Root cause analysis
- **Security** - OWASP Top 10, secure coding
- **Performance Profiling** - Optimization strategies

And **40+ more skills**!

---

## 💾 Memory System

Store decisions and patterns in `.factory/memory/`:

### Team Decisions → `memory/org/`
```markdown
# memory/org/tech-decisions.md

## Database Choice
Decision: PostgreSQL with Prisma
Rationale: Team familiarity, type safety, migration support
Date: 2025-11-22
```

### Personal Notes → `memory/user/`
```markdown
# memory/user/shortcuts.md

## Common Commands
- Deploy staging: `bun run deploy:staging`
- Run e2e: `bun test:e2e --ui`
```

**Agents automatically read memory** for context!

---

## 📋 Unified Specs Location

**All specifications** are stored in `.droidz/specs/` (shared between CLI and Claude Code):

```
.droidz/specs/
├── active/       # Work-in-progress specs (not in git)
├── archive/      # Completed specs (not in git)
├── templates/    # Spec templates
└── examples/     # Reference examples
    └── 000-realtime-notifications.md
```

**Commands default to this location:**
- `/build` → Creates `.droidz/specs/active/NNN-feature.md`
- `/parallel .droidz/specs/active/...` → Executes spec

## 🎨 Standards Enforcement

Project standards in `.factory/standards/templates/`:
- `typescript.md` - TS patterns, strict mode
- `react.md` - Component patterns, hooks
- `nextjs.md` - App Router conventions
- `tailwind.md` - Utility class patterns
- `security.md` - Security requirements

**All agents automatically follow these standards!**

---

## 🔄 Typical Workflows

### Workflow 1: Build New Feature
```
1. User: "Build user profile page"

2. You: Use orchestrator agent
   → Spawns 3 agents in parallel:
   - codegen: Profile API
   - codegen: Profile UI
   - test: Profile tests
   
3. Agents work simultaneously (5-10 min)

4. Results synthesized into PR

Time: 10 min (vs 35 min sequential) = 3.5x faster!
```

### Workflow 2: Debug Issue
```
1. User: "Tests failing in auth.test.ts"

2. You: Use test agent directly
   → Analyzes failures
   → Fixes root cause
   → Verifies all tests pass

3. Returns fixed code + explanation
```

### Workflow 3: Full Validation
```
1. User: /validate

2. You: Run validation command
   → Phase 1: Linting ✓
   → Phase 2: Type checking ✓
   → Phase 3: Style checking ✓
   → Phase 4: Unit tests ✓
   → Phase 5: E2E tests ✓

3. Report: "All validation passed! Ready for deployment."
```

---

## 🚀 Performance Tips

### 1. Use Parallel Execution
When user says "build [complex feature]":
- ✅ Use orchestrator agent
- ✅ Break into parallel streams
- ✅ 3-5x faster completion

### 2. Leverage Skills
Skills auto-activate, but you can invoke explicitly:
- "Using TypeScript skill for type safety"
- "Using Next.js skill for App Router patterns"

### 3. Follow Standards
Always check `.factory/standards/templates/` before coding.

### 4. Update Memory
Save architectural decisions to `memory/org/` for team visibility.

---

## ⚠️ Important Notes

### Agent Limitations
- **Agents can't spawn sub-agents** (no infinite nesting)
- **Agents work in isolation** (separate context)
- **User must approve risky operations** (file deletion, git push)

### Tool Usage
- **Use available tools only** (Read, Write, Bash, Grep, etc.)
- **MCP tools** are available if configured (Linear, Exa, Ref)
- **No direct npm/npx** - use `bun` instead

### Best Practices
- **Analyze before orchestrating** (not every task needs parallel execution)
- **Communicate clearly** (explain why using agents)
- **Synthesize results** (create unified summary)
- **Validate before PR** (run /validate)

---

## 📖 Documentation

For detailed information:
- **Agents**: `.claude/agents/*.md`
- **Commands**: `.claude/commands/*.md`
- **Skills**: `.claude/skills/*.md` (if applicable)
- **Standards**: `.factory/standards/templates/*.md`
- **Memory**: `.factory/memory/`

---

## 🎯 Quick Reference

| Task | Use This |
|------|----------|
| Complex feature (5+ files) | orchestrator agent |
| Simple feature (1-3 files) | Handle directly |
| Test failures | test agent |
| Security review | security-auditor agent |
| Performance issue | performance-optimizer agent |
| API integration | integration agent |
| UI component | ui-designer agent |
| Full validation | /validate command |
| Feature spec | /build command |

---

**Remember**: You're working with a production-grade framework designed for speed and quality. Use agents proactively, follow standards automatically, and leverage parallel execution for complex work!

Happy building! 🚀
