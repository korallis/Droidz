# 🤖 Droidz

> **Simple AI development framework for Factory.ai Droid CLI**

Transform vague ideas into production code with AI-powered spec generation and parallel execution.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.7.4-blue.svg)](https://github.com/korallis/Droidz)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=flat&logo=discord&logoColor=white)](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
[![Donate](https://img.shields.io/badge/PayPal-Donate-00457C?style=flat&logo=paypal&logoColor=white)](https://www.paypal.com/paypalme/gideonapp)

---

## 💬 Join Our Discord Community

**Built specifically for Ray Fernando's Discord members!** 🎯

Get early access, share tips, connect with contributors, and influence future development.

**[→ Join Discord Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

---

## 💝 Support This Project

If Droidz saves you time, consider supporting its development!

**[→ Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

Your support helps maintain and improve this framework! 🙏

---

## What is Droidz?

**Droidz makes Factory.ai's Droid CLI more powerful with 4 simple commands:**

1. **`/droidz-init`** - Analyze your project
2. **`/droidz-build`** - Generate production specs from vague ideas
3. **`/auto-parallel`** - Execute tasks 3-5x faster with parallel agents
4. **`/gh-helper`** - Manage GitHub PRs

**That's it. Simple, powerful, fast.**

---

## Quick Start

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

Or download first:

```bash
wget https://raw.githubusercontent.com/korallis/Droidz/main/install.sh
chmod +x install.sh
./install.sh
```

### Enable in Factory.ai

```bash
droid
/settings
# Toggle "Custom Droids" ON
# Toggle "Hooks" ON
```

Then restart: `Ctrl+C` and run `droid` again.

### Verify

```bash
/droids
# Should show: droidz-orchestrator, codegen, test, refactor, etc.
```

---

## Usage

### The Simple Workflow

```bash
# Step 1: Analyze your project (one-time)
/droidz-init

# Step 2: Generate a spec from your idea
/droidz-build "add user authentication"
# → Asks clarifying questions
# → Generates .droidz/specs/001-authentication.md
# → Asks: "Execute in parallel?"

# Step 3: Choose "Yes" → Done!
# → Spawns 3 agents in parallel
# → Live progress every 60 seconds
# → 3-5x faster than sequential
```

### Or Skip the Spec

```bash
# Direct execution
/auto-parallel "build REST API for todos"
# → Analyzes, decomposes, spawns agents
# → Live progress updates
```

### GitHub Management

```bash
/gh-helper pr-status 10
/gh-helper pr-checks 10
/gh-helper pr-list
```

---

## The 4 Commands

### 1. `/droidz-init` - Smart Onboarding

- Verifies installation
- Analyzes your project (tech stack, architecture)
- Generates `.droidz/architecture.md`

**When to use:** First time setup, onboarding new team members

---

### 2. `/droidz-build` - AI Spec Generator ⭐

**Turn vague ideas into production-ready specifications.**

**Input:**
```bash
/droidz-build "add authentication"
```

**Output:** `.droidz/specs/001-authentication.md`

**Contains:**
- Task decomposition (what to build, in what order)
- Security requirements (OWASP, GDPR)
- Edge cases (what could go wrong)
- Testing strategy (unit, integration, e2e)
- Ready-to-execute prompts for parallel agents

**Features:**
- Asks clarifying questions for vague requests
- Researches best practices (security, frameworks)
- Generates specs in 1-5 minutes
- Offers: Execute now? (Parallel/Sequential/Review/Save)

**Benefits:**
- 80% less time writing specs
- 70% fewer forgotten requirements
- Zero missing security requirements

---

### 3. `/auto-parallel` - Parallel Execution

**Execute tasks 3-5x faster with live progress tracking.**

**How it works:**
1. Analyzes your task
2. Breaks into independent subtasks
3. Spawns specialist agents (codegen, test, refactor, etc.)
4. Reports progress every 60 seconds via TodoWrite
5. Synthesizes results when complete

**Example:**
```bash
/auto-parallel "build payment integration"

# You'll see:
✅ Database schema created (3 files)
⏳ API endpoints (implementing Stripe webhook...)
⏳ Frontend UI (building checkout form...)
⏸ Tests (pending)

# Then:
✅ API endpoints complete (5 files, all tests passing)
⏳ Frontend UI (adding error handling...)
⏳ Tests (writing integration tests...)

# Finally:
✅ All tasks complete! Review: .droidz/results/payment-integration.md
```

**Speedup:**
- Sequential: 10 hours
- Parallel: 3 hours (3.3x faster!)

---

### 4. `/gh-helper` - GitHub Operations

Simple GitHub CLI helpers with correct JSON fields.

```bash
/gh-helper pr-status 10    # Comprehensive PR status
/gh-helper pr-checks 10    # Show check status
/gh-helper pr-list         # List all PRs
```

---

## What You Get

### 15 Specialist Droids

| Droid | Purpose |
|-------|---------|
| **droidz-orchestrator** | Coordinate parallel work |
| **droidz-codegen** | Implement features & bugfixes |
| **droidz-test** | Write & fix tests |
| **droidz-refactor** | Code improvements |
| **droidz-infra** | CI/CD & deployment |
| **droidz-integration** | External API integrations |
| **droidz-ui-designer** | UI design & components |
| **droidz-ux-designer** | User experience & flows |
| **droidz-database-architect** | Database schema & optimization |
| **droidz-api-designer** | API design & documentation |
| **droidz-security-auditor** | Security reviews & OWASP |
| **droidz-performance-optimizer** | Performance profiling & tuning |
| **droidz-accessibility-specialist** | WCAG compliance & a11y |
| **droidz-generalist** | General tasks |

### 61 Auto-Activated Skills

Skills automatically load based on your code:

- **TypeScript** (871 lines) - Best practices, types
- **React** (2,232 lines) - Hooks, patterns, performance
- **Next.js 16** (1,053 lines) - App router, caching, PPR
- **Tailwind v4** (963 lines) - Modern utilities
- **Prisma** (2,072 lines) - Schema, migrations, queries
- **GraphQL API Design** (650 lines) - Apollo Server, resolvers, DataLoader
- **WebSocket Real-time** (680 lines) - Socket.io, SSE, presence
- **Monitoring & Observability** (620 lines) - Prometheus, Grafana, tracing
- **Load Testing** (580 lines) - k6, Artillery, benchmarking
- **Security** - OWASP, GDPR, input validation
- **TDD** - RED-GREEN-REFACTOR workflow
- And 50 more...

### Persistent Memory

Save architectural decisions, patterns, and context:

```bash
/save-decision "Why we chose PostgreSQL over MongoDB"
/load-memory    # Loads saved context
```

---

## Installation Options

### New Projects

```bash
./install.sh
# Choose: 3) Fresh Install
# Choose package manager: npm/yarn/pnpm/bun
```

### Existing Projects (Update)

```bash
./install.sh
# Choose: 1) Update
# Your custom commands are backed up automatically
```

### Uninstall

```bash
./install.sh
# Choose: 2) Uninstall
# Removes .factory/ directory
```

---

## Configuration (Optional)

Create `config.yml` (optional - Droidz works without it):

```yaml
# Linear Integration (optional)
linear:
  project_name: "MyProject"

# Orchestrator Settings (optional)
orchestrator:
  max_parallel_streams: 5
  enable_monitoring: true
```

---

## Project Structure

After installation:

```
.factory/
├── commands/           # 4 slash commands
│   ├── droidz-init.md
│   ├── droidz-build.md
│   ├── auto-parallel.md
│   └── gh-helper.md
├── droids/             # 15 specialist droids
│   ├── droidz-orchestrator.md
│   ├── codegen.md
│   ├── test.md
│   └── ...
├── skills/             # 61 auto-skills
│   ├── typescript/
│   ├── react/
│   └── ...
└── memory/             # Persistent context
    ├── org/           # Team decisions
    └── user/          # Your notes

.droidz/
└── specs/              # Generated specs
    ├── 001-authentication.md
    └── 002-payment-integration.md

config.yml              # Your config (gitignored)
```

---

## Examples

### Example 1: Build Auth (15 minutes)

```bash
# Generate spec
/droidz-build "add email/password authentication with JWT"

# Droidz asks:
# - Sessions or JWT? → JWT
# - Password requirements? → 8+ chars, letters+numbers
# - Social providers? → No

# Generates spec → .droidz/specs/001-auth.md
# Contains: 6 tasks (3 parallel Phase 1, 3 parallel Phase 2)

# Execute
Choose "Yes - Execute in parallel"

# Progress (every 60s):
✅ Database schema (User model, migrations)
⏳ API endpoints (POST /register, POST /login...)
⏳ JWT utilities (sign, verify, refresh...)

# 15 minutes later:
✅ All complete! 12 files created, 24 tests passing
```

### Example 2: Direct Execution (No Spec)

```bash
/auto-parallel "refactor payment module to use strategy pattern"

# Analyzes → 2 parallel tasks
# Task 1: Create strategy interfaces
# Task 2: Write tests for new structure

# Then sequential:
# Task 3: Migrate existing code
# Task 4: Update documentation

# Done in 20 minutes vs 60 sequential
```

### Example 3: Analyze First

```bash
# Onboarding to new project
/droidz-init

# Output: .droidz/architecture.md
# - Tech stack: Next.js 14, Prisma, PostgreSQL
# - File structure: App router, /src layout
# - Patterns: Server components, Tailwind
# - Next steps: Suggestions for getting started
```

---

## Troubleshooting

### Droids not showing?

```bash
/settings
# Ensure "Custom Droids" and "Hooks" are ON
# Restart: Ctrl+C then `droid`
/droids  # Should show all 7 droids
```

### Installation failed?

```bash
# Check logs
cat .droidz-install-*.log

# Common fixes:
# 1. Workspace restrictions? Add 'yaml' to root package.json
# 2. npm errors? Run: npm install yaml --save
# 3. Re-run installer: ./install.sh
```

### Commands not working?

```bash
/commands  # Should show 4 commands
# If missing, re-run: ./install.sh → Choose "1) Update"
```

---

## What's New in v2.7.2

**🚀 Major Skills Expansion + CLI Auto-Activation!**

### New Skills (4 Added)

- ✅ **GraphQL API Design** (650 lines) - Apollo Server, DataLoader, cursor pagination
- ✅ **WebSocket Real-time** (680 lines) - Socket.io, SSE, presence systems
- ✅ **Monitoring & Observability** (620 lines) - Prometheus, Grafana, OpenTelemetry
- ✅ **Load Testing** (580 lines) - k6, Artillery, performance benchmarking

### CLI Auto-Activation

- ✅ **All 61 skills now auto-activate** based on your context!
- ✅ Added trigger keywords to 18 skills (React, TypeScript, Next.js, Prisma, etc.)
- ✅ Skills load automatically when mentioned - just like magic ✨

### Installer Improvements

- ✅ Updated skill list from 45 → 61 skills
- ✅ Fixed missing skills in installer
- ✅ Better consistency and error handling

### Complete Coverage

Now includes complete support for:
- Modern API development (REST + GraphQL)
- Real-time features (WebSocket + SSE)
- Production monitoring and observability
- Performance testing and validation
- Full-stack development from dev to production

**See [CHANGELOG.md](CHANGELOG.md) or [Release v2.7.2](https://github.com/korallis/Droidz/releases/tag/v2.7.2) for full details.**

---

## Documentation

- **Commands Guide:** [COMMANDS.md](COMMANDS.md) - Comprehensive 4-command reference
- **Changelog:** [CHANGELOG.md](CHANGELOG.md) - Version history
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

---

## Support & Community

- **Issues:** [GitHub Issues](https://github.com/korallis/Droidz/issues)
- **Discussions:** [GitHub Discussions](https://github.com/korallis/Droidz/discussions)
- **Discord:** [Ray Fernando's Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
- **Donate:** [PayPal @gideonapp](https://www.paypal.com/paypalme/gideonapp)

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Built for Factory.ai Droid CLI** | **v2.7.4** | **Created by the community** 🚀
