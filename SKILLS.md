# Skills System Guide

> **Factory.ai native skills that auto-activate based on your code**

Droidz v3.0 fully leverages Factory.ai's official Skills system (v0.26.0+) with 61 production-ready skills that automatically activate when you mention relevant technologies.

---

## What Are Skills?

**Skills are Factory.ai's way of giving Droid specialized knowledge.**

When you mention specific technologies (e.g., "Add TypeScript types"), Factory.ai automatically invokes the relevant skill (e.g., TypeScript skill) to provide expert guidance.

### Key Features

✅ **Auto-activation** - No manual selection needed  
✅ **Model-invoked** - Factory.ai decides when to use skills  
✅ **CLI-reported** - See which skills are active  
✅ **Tool-specific** - Skills specify which tools they can use  

---

## How Skills Work

### 1. You Mention a Technology

```
You: "Add Prisma schema for users table"
```

### 2. Factory.ai Detects Keywords

The Prisma skill's description:
```yaml
description: Use when user mentions Prisma, schema.prisma, 
  database models, or Prisma migrations...
```

Factory.ai scans this and matches "Prisma schema" → activates skill.

### 3. Skill Activates Automatically

```
Droid CLI: Using skill: prisma
```

### 4. Expert Guidance Applied

The skill provides:
- Prisma best practices
- Schema patterns
- Migration strategies
- Query optimization tips

---

## All 61 Droidz Skills

### Language Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **TypeScript** | types, interfaces, generics | Advanced types, utility types, strict mode |
| **JavaScript** | JS patterns, closures | ES2024, functional programming |
| **Python** | py, python code | Type hints, async/await, best practices |
| **Go** | golang, go code | Concurrency, channels, error handling |
| **Rust** | rust, cargo | Ownership, lifetimes, error handling |

### Framework Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **React** | React, hooks, components | React 19, Server Components, hooks |
| **Next.js** | Next.js, App Router | App Router, PPR, caching, RSC |
| **Tailwind CSS** | Tailwind, utility classes | v4, modern utilities, responsive design |
| **TanStack Query** | React Query, data fetching | Caching, mutations, optimistic updates |
| **tRPC** | tRPC, type-safe APIs | End-to-end type safety, procedures |

### Database Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Prisma** | Prisma, schema.prisma | Schema design, migrations, relations |
| **Drizzle** | Drizzle ORM | Type-safe queries, schema management |
| **PostgreSQL** | Postgres, SQL queries | Advanced queries, indexes, performance |
| **Supabase** | Supabase, realtime | Auth, database, storage, realtime |
| **Neon** | Neon, serverless Postgres | Serverless Postgres, branching |

### Backend/API Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **GraphQL** | GraphQL, schemas, resolvers | Schema design, resolvers, federation |
| **WebSocket** | WebSocket, realtime | Real-time connections, Socket.IO |
| **API Design** | REST API, endpoints | RESTful design, versioning, docs |

### Infrastructure Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Docker** | Docker, containers | Dockerfiles, multi-stage builds, compose |
| **CI/CD** | GitHub Actions, pipelines | Automated workflows, deployments |
| **Cloudflare Workers** | Cloudflare, edge functions | Edge computing, Workers, KV |
| **Vercel** | Vercel deployment | Deployments, environment variables |
| **Monitoring** | Observability, metrics | Logging, metrics, tracing |

### Testing Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **TDD** | Test-driven development | Red-green-refactor, unit tests |
| **Unit Tests** | Jest, Vitest, unit tests | Test structure, mocking, coverage |
| **E2E Tests** | Playwright, Cypress | Browser automation, workflows |
| **Load Testing** | Performance testing | Load tests, stress tests, benchmarks |
| **Testing Anti-patterns** | Test smells, bad tests | What NOT to do in tests |

### Security Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Security** | OWASP, security, auth | OWASP Top 10, GDPR, secure coding |
| **Defense in Depth** | Security layers | Multiple security layers, hardening |
| **Security Audit** | Security review | Audit checklists, vulnerability scanning |

### Integration Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Stripe** | Stripe, payments | Payment flows, webhooks, subscriptions |
| **Clerk** | Clerk, authentication | User auth, sessions, organizations |
| **Convex** | Convex backend | Reactive backend, real-time data |

### Development Workflow Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Git Commit Messages** | commit messages | Conventional commits, best practices |
| **Code Review** | PR review, code review | Review checklists, constructive feedback |
| **Requesting Review** | Ask for review | How to request effective reviews |
| **Receiving Review** | Handle feedback | Responding to review comments |
| **Finishing Branch** | Branch completion | Cleanup, merge, documentation |
| **Using Git Worktrees** | Git worktrees | Parallel branch work, worktree management |
| **Graphite Stacked Diffs** | Stacked PRs, Graphite | Stacked diffs workflow |

### Documentation Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **README Generator** | Generate README | Comprehensive README creation |
| **API Documentation** | API docs | OpenAPI, Swagger, endpoint documentation |
| **Changelog Generator** | Generate changelog | CHANGELOG.md, version tracking |
| **PR Description** | PR descriptions | Effective pull request descriptions |

### Orchestration Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Auto Orchestrator** | Complex tasks, parallel work | Detect when to orchestrate, plan execution |
| **Subagent-Driven Development** | Spawning agents | How to effectively use subagents |
| **Dispatching Agents** | Parallel execution | Agent coordination, task routing |
| **Executing Plans** | Execute specs | Turn plans into code |

### Debugging Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Systematic Debugging** | Debug, troubleshoot | Methodical debugging approach |
| **Root Cause Tracing** | Find root cause | Deep investigation techniques |
| **Performance Profiler** | Profiling, optimization | Find bottlenecks, optimize code |

### Droidz Meta Skills

| Skill | Triggers | Expertise |
|-------|----------|-----------|
| **Using Droidz** | Droidz commands | How to use Droidz framework |
| **Writing Skills** | Create skills | How to write custom skills |
| **Sharing Skills** | Share skills | Distribute skills to team |
| **Testing Skills** | Test with subagents | Validate skills before sharing |
| **Memory Manager** | Project memory | Manage persistent context |
| **Context Optimizer** | Token optimization | Reduce token usage |
| **Tech Stack Analyzer** | Analyze stack | Understand project architecture |
| **Standards Enforcer** | Code standards | Enforce team conventions |
| **Spec Shaper** | Refine specs | Improve specification quality |
| **Adaptation Guide** | Onboarding | Help new contributors adapt |
| **Verification** | Validate completion | Ensure work meets requirements |
| **Brainstorming** | Ideation | Generate creative solutions |
| **Condition-Based Waiting** | Polling, waiting | Smart waiting strategies |

---

## Skill Anatomy

Every skill follows Factory.ai's official SKILL.md format:

```markdown
---
name: typescript
description: Use when user mentions TypeScript, types, interfaces, 
  generics, or type safety. Expert in TypeScript best practices...
category: language
allowed-tools: ["Read", "Edit", "Create", "Grep", "Glob"]
---

# TypeScript Best Practices

[Expert guidance here]
```

### Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Skill identifier (lowercase, hyphens) |
| `description` | Yes | **Starts with "Use when"** - triggers auto-activation |
| `category` | Optional | Skill category (language, framework, etc.) |
| `allowed-tools` | Optional | Which Factory.ai tools this skill can use |

---

## Managing Skills

### View All Skills

```bash
/skills
```

Shows:
- All available skills
- Skill descriptions
- Categories

### Create New Skill

```bash
/skills create
```

Prompts for:
- Skill name
- When to activate (trigger keywords)
- Expert knowledge to include

**Example:**
```
You: /skills create

Name: astro
Triggers: Astro, .astro files, Island architecture
Category: framework

[Droid generates SKILL.md with Astro best practices]
```

### Import Skill from Claude Code

If you have Claude Code skills in `.claude/skills/`:

```bash
/skills import
```

Converts Claude Code skills to Factory.ai format:
- Updates YAML frontmatter
- Changes "description" to start with "Use when"
- Adds `allowed-tools` if missing

### Test Skill

```bash
You: "Test the TypeScript skill by adding types to this function"

Droid CLI: Using skill: typescript

[Skill activates and applies TypeScript expertise]
```

### Disable Skill (Temporary)

```bash
# Rename skill directory to disable
mv .factory/skills/typescript .factory/skills/.typescript-disabled

# Re-enable
mv .factory/skills/.typescript-disabled .factory/skills/typescript
```

---

## Writing Custom Skills

### Step 1: Choose a Clear Trigger

**Good triggers (specific):**
- "Astro, .astro files, Island architecture"
- "Zod, schema validation, type inference"
- "Vite, build tool, dev server"

**Bad triggers (too vague):**
- "web development"
- "JavaScript"
- "programming"

### Step 2: Create SKILL.md

```bash
mkdir -p .factory/skills/astro
```

Create `.factory/skills/astro/SKILL.md`:

```markdown
---
name: astro
description: Use when user mentions Astro, .astro files, Island architecture, or partial hydration. Expert in Astro framework best practices.
category: framework
allowed-tools: ["Read", "Edit", "Create", "Grep", "Glob"]
---

# Astro Framework Best Practices

## Core Principles

1. **Islands Architecture** - Interactive components only hydrate when needed
2. **Zero JS by Default** - Ship only necessary JavaScript
3. **Framework Agnostic** - Use React, Vue, Svelte together

[... rest of expert guidance ...]
```

### Step 3: Test Activation

```bash
You: "Create an Astro component with React islands"

# Check CLI output
Droid CLI: Using skill: astro

# ✓ Skill activated!
```

### Step 4: Refine Description

If skill doesn't activate, refine the `description`:

```yaml
# Add more trigger keywords
description: Use when user mentions Astro, .astro files, Island architecture,
  partial hydration, content-focused sites, SSG, MPAs, or Astro framework...
```

---

## Best Practices

### 1. Clear Activation Triggers

**✅ Good:**
```yaml
description: Use when user mentions Prisma, schema.prisma, database models,
  Prisma migrations, or Prisma Client queries...
```

**❌ Bad:**
```yaml
description: Database ORM tool
```

The first clearly states WHEN to activate. The second is too vague.

### 2. Comprehensive Expertise

Skills should cover:
- ✅ Core principles
- ✅ Best practices
- ✅ Common patterns
- ✅ Anti-patterns (what NOT to do)
- ✅ Examples (good vs. bad)

### 3. Tool Specification

Specify which tools the skill can use:

```yaml
allowed-tools: ["Read", "Edit", "Create", "Grep", "Glob"]
```

For read-only skills:
```yaml
allowed-tools: ["Read", "Grep", "Glob"]
```

For skills that execute commands:
```yaml
allowed-tools: ["Read", "Execute", "Grep"]
```

### 4. Keep Skills Focused

One skill = one technology/concept

**✅ Good:**
- TypeScript skill (types, generics, utilities)
- React skill (hooks, components, performance)
- Prisma skill (schema, queries, migrations)

**❌ Bad:**
- "Full-stack skill" (too broad)
- "JavaScript + TypeScript + React" (split into 3 skills)

---

## Troubleshooting

### Skill Not Activating

**Problem**: Mention technology but skill doesn't activate

**Solution**:
1. Check skill description includes trigger keywords
2. Verify `description` starts with "Use when..."
3. Add more synonyms/keywords to description
4. Test with explicit mention: "Use the [skill name] skill"

### Multiple Skills Activate

**Problem**: Two skills activate for one request

**Solution**: This is normal! Factory.ai can use multiple skills simultaneously.

**Example:**
```
You: "Add Prisma schema with TypeScript types"

Droid CLI: Using skills: prisma, typescript

[Both skills provide guidance]
```

### Skill Description Too Long

**Problem**: YAML frontmatter description is 300+ characters

**Solution**: Keep core triggers in description, move details to body:

```yaml
description: Use when user mentions Prisma, schema.prisma, database models,
  or Prisma Client. Expert in Prisma ORM best practices.
```

Then expand in the body:
```markdown
## When to Use This Skill

This skill activates for:
- Prisma schema design
- Database migrations
- Query optimization
- [... more details ...]
```

### Skill Conflicts with Another

**Problem**: Two skills give conflicting advice

**Solution**: 
1. Make skill descriptions more specific
2. Add "Prefer [X] over [Y]" guidance
3. Consider merging overlapping skills

---

## Skill Categories

Organize skills by category for easier management:

| Category | Purpose | Examples |
|----------|---------|----------|
| `language` | Programming languages | TypeScript, Python, Go |
| `framework` | Frameworks | React, Next.js, FastAPI |
| `database` | Databases & ORMs | Prisma, PostgreSQL, Supabase |
| `backend` | Backend technologies | GraphQL, WebSocket, API Design |
| `infrastructure` | DevOps, deployment | Docker, CI/CD, Cloudflare |
| `testing` | Testing approaches | TDD, E2E, Unit Tests |
| `security` | Security practices | OWASP, Security Audit |
| `integration` | Third-party services | Stripe, Clerk, Convex |
| `workflow` | Development workflow | Git, Code Review, PR Descriptions |
| `documentation` | Documentation tools | README, API Docs, Changelog |
| `orchestration` | Task coordination | Auto Orchestrator, Subagent Dev |
| `debugging` | Debugging & optimization | Systematic Debug, Profiling |
| `meta` | Droidz framework | Using Droidz, Writing Skills |

---

## Advanced: Skill Composition

Skills can reference other skills:

```markdown
# Next.js Skill

## Related Skills

This skill works well with:
- **React** - For component patterns
- **TypeScript** - For type safety
- **TailwindCSS** - For styling

When user mentions both Next.js and React, both skills activate
and provide complementary guidance.
```

---

## CLI Integration

### Check Active Skills

During a session, check which skills are active:

```bash
# Skills activate automatically
You: "Add Prisma schema"

# CLI shows:
Using skill: prisma

# Or multiple:
Using skills: prisma, typescript, postgresql
```

### Skill Usage in Output

Droid will mention when applying skill knowledge:

```
Following Prisma best practices from the prisma skill:
- Using explicit many-to-many relations
- Adding indexes on foreign keys
- Using camelCase for field names
```

---

## Sharing Skills with Your Team

### 1. Commit Skills to Repo

```bash
git add .factory/skills/
git commit -m "feat: add custom Astro skill"
git push
```

### 2. Team Members Pull

```bash
git pull

# Skills automatically available!
/skills  # Shows new skill
```

### 3. Document Custom Skills

Add to `README.md` or `SKILLS.md`:

```markdown
## Custom Skills

We've added these team-specific skills:

- **Astro** - Island architecture patterns
- **Zod** - Schema validation best practices
- **Our API Pattern** - Company API conventions
```

---

## Benefits Summary

✅ **Auto-activation** - No manual skill selection  
✅ **Always up-to-date** - Commit skills with code  
✅ **Team consistency** - Everyone uses same patterns  
✅ **Extensible** - Add custom skills anytime  
✅ **Factory.ai native** - Uses official Skills system  

---

## Further Reading

- [Factory.ai Skills Documentation](https://docs.factory.ai/cli/configuration/skills)
- [VALIDATION.md](./VALIDATION.md) - Validation system guide
- [DROIDS.md](./DROIDS.md) - Custom droids guide
- [Writing Skills Guide](https://docs.factory.ai/cli/configuration/skills#creating-skills)

---

**61 skills ready to accelerate your development** ⚡
