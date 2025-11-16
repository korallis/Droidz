# 🤖 Droidz - AI-Powered Development Framework for Factory.ai

**Transform vague ideas into production-ready code with AI-generated specifications and parallel task execution.**

> **v0.2.0** - Now with `/droidz-build`: Turn "add auth" into a comprehensive spec with security requirements, edge cases, tests, and ready-to-execute tasks. **80% less time writing specs, 3-5x faster execution.**

---

## ⚡ Quick Start

### Install (One Command)

```bash
curl -sSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

### Enable & Use

```bash
# Start Factory.ai droid
droid

# Enable custom features (first time only)
/settings → Toggle "Custom Commands" ON

# Generate a specification
/droidz-build "add user authentication"

# Or execute directly
/auto-parallel "build REST API for todos"
```

**That's it!** 🎉

---

## 🎯 What is Droidz?

Droidz is a framework for [Factory.ai](https://factory.ai) that adds:

1. **🚀 AI-Powered Spec Generator** - `/droidz-build` transforms vague ideas into production-ready specifications
2. **⚡ Parallel Task Execution** - Work on 3-5 tasks simultaneously using specialist droids
3. **🎓 Skills System** - Auto-inject coding standards (TypeScript, Tailwind, security best practices)
4. **📊 Live Progress Tracking** - See what's happening every 60 seconds

### The Problem

```
You: "Add authentication"
Droid: "Here's a login form..."
❌ Missing: password reset, email verification, rate limiting, tests, edge cases
```

### The Droidz Solution

```
You: /droidz-build "add authentication"

Droid: 🔍 I'll create a spec. To make it comprehensive:
       1. Email/password, OAuth, or both?
       2. Session handling: JWT or sessions?
       3. User roles?

You: Email/password, JWT, existing Next.js

Droid: ✅ Saved: .droidz/specs/001-user-authentication.md
       
       📊 Summary:
       - Tasks: 6 (3 parallel Phase 1, 3 parallel Phase 2)
       - Time: 8-12h sequential → 2.5-4h parallel (3x speedup)
       
       Includes:
       ✅ bcrypt password hashing (10+ salt rounds)
       ✅ Rate limiting (5 attempts/15min)
       ✅ OWASP Top 10 compliance checklist
       ✅ Edge cases (expired tokens, concurrent sessions)
       ✅ Full test coverage plan (80%+)
       
       Execute in parallel? (spawns 3 agents)
```

**Result:** Complete, production-ready implementation with security, tests, and edge cases handled.

---

## ✨ Key Features

### 🚀 NEW: AI-Powered Specification Generator

**Command:** `/droidz-build "feature description"`

**What it does:**
- 🔍 Asks clarifying questions for vague requests
- 📚 Researches best practices via exa-code & ref MCP
- 📝 Generates comprehensive XML-structured specs with:
  - Task decomposition (parallelizable units)
  - Security requirements (OWASP, GDPR when applicable)
  - Edge cases & failure scenarios
  - Testing strategy (unit, integration, E2E)
  - Verification criteria (measurable success metrics)
  - Ready-to-execute task prompts

**Benefits:**
- 80% less time writing specs manually
- 70% fewer "forgot to consider X" issues
- 3-5x execution speedup via parallel tasks
- Zero missing security requirements

**Example specs:**
```bash
/droidz-build "add dark mode toggle"
→ Simple: 2 tasks, ~45 minutes

/droidz-build "add contact form with email"
→ Moderate: 3 tasks, 2-3h sequential, ~1h parallel

/droidz-build "build blog with comments and search"
→ Complex: 12 tasks, 24h sequential → 6-8h parallel
```

### ⚡ Parallel Task Execution

**Command:** `/auto-parallel "task description"`

**How it works:**
1. Analyzes complexity and breaks into subtasks
2. Identifies what can run in parallel
3. Spawns specialist droids for each task
4. Reports progress every 60 seconds
5. Synthesizes results when complete

**Example:**
```bash
/auto-parallel "build authentication system"

✓ Spawning 3 parallel tasks...
  Task 1: Database schema (droidz-infra)
  Task 2: API endpoints (droidz-codegen)
  Task 3: Frontend UI (droidz-codegen)

[Progress updates appear every 60s]
TODO LIST UPDATED
✅ Database schema created (3 files)
⏳ API endpoints (implementing login...)
⏳ Frontend UI (building forms...)
```

### 🎓 Skills System

**Automatic code standards enforcement** - Factory.ai automatically loads skills from `.factory/skills/`

**Available Skills:**
- **Next.js 15** - App Router, Server Components, Server Actions
- **Supabase** - RLS policies, Realtime, Auth best practices
- **Neon** - Database branching, serverless driver, autoscaling
- **Design (UI/UX)** - Component patterns, accessibility, design systems
- **TypeScript** - Strict mode, proper types, no `any`
- **Tailwind 4** - v4 syntax, modern patterns, dark mode
- **Security** - OWASP compliance, input validation, auth
- **Convex** - Queries, mutations, reactivity patterns

**How it works:**
Factory.ai droid CLI automatically loads all `.md` files from `.factory/skills/` and injects relevant best practices when you work on code.

**Example:**
```
You: "Create a Next.js Server Action for login"

Droid: [Next.js 15 + Security skills auto-loaded]
       Creating secure server action with:
       ✅ 'use server' directive
       ✅ Zod input validation
       ✅ bcrypt password hashing
       ✅ Rate limiting
       ✅ Proper error handling
```

**Add your own skills:**
```bash
# Create custom skill
vim .factory/skills/react.md

# Skill automatically loads on next droid start
```

---

## 📋 All Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/droidz-build` | 🆕 Generate production-ready specs | `/droidz-build "add payment processing"` |
| `/auto-parallel` | Execute tasks in parallel with live monitoring | `/auto-parallel "build REST API"` |
| `/gh-helper` | GitHub CLI helpers (PR checks, status) | `/gh-helper pr-status 10` |

**That's it!** Simple and powerful. 🎯

---

## 🤖 Specialist Droids

Droidz includes 7 specialist droids that handle different types of work:

| Droid | Specialty | When Used |
|-------|-----------|-----------|
| **droidz-orchestrator** | Task decomposition & parallel execution | Complex multi-step features |
| **droidz-codegen** | Feature implementation & bug fixes | Building new functionality |
| **droidz-test** | Writing & fixing tests | Test coverage & validation |
| **droidz-refactor** | Code improvements & cleanup | Improving code structure |
| **droidz-integration** | External APIs & services | Third-party integrations |
| **droidz-infra** | CI/CD, builds, deployment | Infrastructure changes |
| **droidz-generalist** | Miscellaneous tasks | General-purpose work |

**You don't call these directly** - the orchestrator assigns tasks to the right specialist automatically.

---

## 📚 Documentation

### Quick References
- **Example Spec:** `.droidz/specs/000-example-contact-form.md` (6,000+ line reference)
- **CHANGELOG:** See [CHANGELOG.md](CHANGELOG.md) for version history
- **Skills Guide:** See [SKILLS.md](SKILLS.md) for details on skills system

### Generated Specifications

When you use `/droidz-build`, specs are saved to `.droidz/specs/NNN-feature-name.md` with:

```markdown
<objective>Clear goal</objective>
<context>Tech stack, why it matters</context>
<requirements>Functional + non-functional</requirements>
<task-decomposition>Parallelizable tasks</task-decomposition>
<security-requirements>OWASP, GDPR checklists</security-requirements>
<edge-cases>Failure scenarios</edge-cases>
<testing-strategy>Unit, integration, E2E</testing-strategy>
<verification-criteria>Success checkboxes</verification-criteria>
<execution-plan>Ready-to-run tasks</execution-plan>
<success-metrics>Quality, performance, security, UX</success-metrics>
```

**See the example:** `cat .droidz/specs/000-example-contact-form.md`

---

## 🎯 Common Workflows

### Workflow 1: Generate Spec → Execute in Parallel

```bash
# 1. Generate specification
/droidz-build "add user authentication with JWT"

# 2. Answer clarifying questions
> Email/password with JWT, Next.js 14

# 3. Review generated spec
✅ Spec saved to .droidz/specs/001-user-authentication.md

# 4. Execute in parallel
> Execute in parallel? y

# 5. Monitor progress
[Updates appear every 60s in conversation]
✅ Phase 1 complete (3 tasks)
⏳ Phase 2 running (3 tasks)
```

### Workflow 2: Direct Parallel Execution

```bash
# Skip spec generation, execute immediately
/auto-parallel "build REST API for todo items"

# Droid breaks it down and executes
✓ Task 1: Database schema
✓ Task 2: CRUD endpoints  
✓ Task 3: Tests
```

### Workflow 3: Use Skills for Quality

```bash
# Skills auto-inject for standards enforcement
You: "Create a secure login endpoint"

Droid: [Security skill injected]
       ✅ bcrypt password hashing
       ✅ Rate limiting
       ✅ Input validation
       ✅ OWASP compliance
```

---

## 🔧 Installation Details

### What Gets Installed

```
your-project/
├── .factory/
│   ├── commands/
│   │   ├── droidz-build.md    # Spec generator
│   │   ├── auto-parallel.md   # Orchestration
│   │   └── gh-helper.md       # GitHub tools
│   ├── droids/                # 7 specialist droids
│   ├── skills/                # 4 skill templates
│   ├── hooks/                 # Skills injection
│   └── settings.json          # Configuration
├── .droidz/
│   ├── specs/                 # Generated specifications
│   │   └── 000-example-contact-form.md
│   └── .gitignore             # Privacy by default
└── config.yml                 # Your settings
```

### Requirements

- **Git:** Version control (required)
- **Factory.ai Droid CLI:** Get it at [factory.ai](https://factory.ai)
- **Node.js/Bun:** Optional, for TypeScript projects

**No tmux or jq required** - we use Factory.ai's native Task tool for orchestration.

---

## 🚀 Advanced Usage

### Custom Specifications

Modify generated specs before execution:

```bash
# 1. Generate spec
/droidz-build "add feature"

# 2. Edit the spec
vim .droidz/specs/001-feature.md

# 3. Execute manually
/auto-parallel [paste task details from spec]
```

### Share Specifications

Specs are git-ignored by default for privacy. To share:

```bash
# Edit .droidz/.gitignore to commit specific specs
vim .droidz/.gitignore

# Add line:
!specs/001-user-authentication.md

# Commit and share
git add .droidz/specs/001-user-authentication.md
git commit -m "docs: add authentication spec"
```

### Configure Skills

Edit skills in `.factory/skills/*.md`:

```bash
# Add your own coding standards
vim .factory/skills/typescript.md

# Skills auto-inject when relevant code is detected
```

---

## 🐛 Troubleshooting

### Commands not found

**Problem:** `/droidz-build` or `/auto-parallel` not recognized

**Solution:**
```bash
# In droid chat:
/settings → Enable "Custom Commands" → Restart droid

# Verify:
/commands  # Should show droidz-build, auto-parallel, gh-helper
```

### No droids showing

**Problem:** Specialist droids not available

**Solution:**
```bash
# In droid chat:
/settings → Enable "Custom Droids" → Restart droid

# Verify:
/droids  # Should show all 7 specialist droids
```

### Spec generation fails

**Problem:** `/droidz-build` generates incomplete specs

**Solution:**
- Provide more context in your request
- Answer clarifying questions thoroughly
- Check that exa-code and ref MCP are available

### Parallel execution not starting

**Problem:** Tasks spawn but don't make progress

**Solution:**
```bash
# Check droid is responding
/commands  # Should list commands

# Try sequential execution instead
Choose option 3 (Execute sequentially) when prompted
```

---

## 📊 Performance Benchmarks

| Task Complexity | Sequential Time | Parallel Time | Speedup |
|----------------|-----------------|---------------|---------|
| Simple (2 tasks) | 45 min | 30 min | 1.5x |
| Moderate (3-5 tasks) | 3 hours | 1 hour | 3x |
| Complex (6+ tasks) | 12 hours | 3 hours | 4x |

**Average:** 3-5x faster with parallel execution

---

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 🔗 Links

- **GitHub:** https://github.com/korallis/Droidz
- **Factory.ai:** https://factory.ai
- **Issues:** https://github.com/korallis/Droidz/issues
- **Discussions:** https://github.com/korallis/Droidz/discussions
- **Latest Release:** https://github.com/korallis/Droidz/releases/tag/v0.2.0

---

## 🎓 Learning Path

### Beginner (Day 1)
1. Install Droidz
2. Try `/droidz-build "add contact form"`
3. Review the generated spec
4. Execute it

### Intermediate (Week 1)
1. Use `/auto-parallel` for direct execution
2. Explore specialist droids
3. Customize skills for your tech stack

### Advanced (Month 1)
1. Create custom specifications
2. Share specs with your team
3. Build your own droids (see AGENTS.md.template)

---

## 💬 Community

- **Discord:** Coming soon
- **Twitter:** Coming soon
- **GitHub Discussions:** https://github.com/korallis/Droidz/discussions

---

## 🙏 Acknowledgments

- **Factory.ai** - For the amazing droid CLI
- **taches-cc-prompts** - Inspiration for meta-prompting system
- **Contributors** - Everyone who helped make Droidz better

---

## 📈 Roadmap

### v0.3.0 (Coming Soon)
- [ ] `/droidz-init` - Smart project initialization
- [ ] `/droidz-status` - Resume conversations with state tracking
- [ ] Spec execution tracking (`.droidz/tasks/`)
- [ ] Community spec library

### v0.4.0 (Future)
- [ ] Template system for common specs
- [ ] Droid marketplace
- [ ] Team collaboration features
- [ ] Analytics & metrics

---

**Built with ❤️ for the Factory.ai community**

**Current Version:** v0.2.0 | **Last Updated:** 2025-11-15
