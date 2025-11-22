# 🤖 Droidz

> **Production-grade AI development framework for Factory.ai Droid CLI**

Transform vague ideas into production code with AI-powered validation, native skills, and intelligent parallel execution.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.2.2-blue.svg)](https://github.com/korallis/Droidz)
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

## ✨ What's New in v3.0

Droidz v3.0 is a complete architectural refactor that fully leverages Factory.ai's native capabilities:

### 🎯 Major Improvements

**1. Native Factory.ai Skills System** ✨
- **Skills auto-activate** based on your code context
- No manual skill selection needed
- Uses Factory.ai's official Skills system (v0.26.0)
- Skills are **model-invoked** - CLI reports when used
- Manage with `/skills` command

**2. Perfect Model Inheritance** 🎨
- All 15 specialist droids use `model: inherit`
- **Your model choice is always respected**
- Switch models → all droids switch automatically
- No more conflicting models

**3. Comprehensive Validation** ✅
- **`/validate-init`** - Auto-generates project-specific validation
- **`/validate`** - Runs 5-phase validation pipeline
  - Phase 1: Linting (ESLint, ruff, etc.)
  - Phase 2: Type checking (TypeScript, mypy)
  - Phase 3: Style checking (Prettier, black)
  - Phase 4: Unit tests
  - Phase 5: E2E tests (workflow-based)
- **One command to validate everything**

**4. Live Progress Tracking** 📊
- Real-time TodoWrite updates during parallel execution
- See exactly what each droid is doing
- No more guessing if work is stuck
- Built on Factory.ai's native TodoWrite tool

**5. Clean Architecture** 🏗️
- **100% `.factory/`-based** - no external folders
- Eliminated `.droidz/` folder confusion
- Standard Factory.ai conventions
- Proper gitignore patterns

**6. Enhanced Hooks System** 🪝
- All 7 Factory.ai hook types supported
- Auto-lint after file edits
- Block dangerous commands (rm -rf, dd, etc.)
- Session summaries on exit
- Subagent completion tracking

**7. Simplified Installation** ⚡
- < 30 second installation
- No git worktree setup needed
- No tmux installation required
- Just Factory.ai CLI + Droidz

---

## 🚀 Quick Start

### Installation

The installer now supports **both Droid CLI and Claude Code**!

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.2.2/install.sh | bash
```

**When prompted, select:**
- **Option 1**: Droid CLI (Factory.ai)
- **Option 2**: Claude Code (Anthropic)

Or download first:

```bash
wget https://raw.githubusercontent.com/korallis/Droidz/v3.2.2/install.sh
chmod +x install.sh
./install.sh
```

### Setup for Droid CLI (Factory.ai)

```bash
droid
/settings
# Toggle "Custom Droids" ON
# Toggle "Hooks" ON
```

Restart: `Ctrl+C` and run `droid` again.

Verify:
```bash
/droids           # See all 15 specialist droids
/skills           # Manage skills
```

### Setup for Claude Code (Anthropic)

After installation completes, restart Claude Code:

```bash
exit           # Exit current session
claude        # Start new session
```

Verify:
```bash
/agents       # See all 15 specialist agents
# CLAUDE.md is automatically loaded
```

**See [CLAUDE_CODE_SETUP.md](CLAUDE_CODE_SETUP.md) for detailed Claude Code setup guide.**

---

## 💡 The Simple Workflow

```bash
# Step 1: Initialize your project
/init

# Step 2: Generate validation workflow (auto-runs on /init)
/validate-init

# Step 3: Build something
/build "add user authentication with JWT"
# → Asks clarifying questions
# → Generates .factory/specs/active/001-auth.md
# → Offers: Execute now?

# Step 4: Execute in parallel (optional)
/parallel
# → Spawns specialist droids
# → Live progress via TodoWrite
# → 3-5x faster than sequential

# Step 5: Validate everything
/validate
# → Runs all 5 phases
# → Shows pass/fail
# → Ready for deployment
```

---
## 🎯 Core Features

### 1. Native Skills System (NEW in v3.0)

**Skills automatically activate based on your code:**

```bash
You: "Add TypeScript types to auth.ts"
# → TypeScript skill auto-activates
# → CLI reports: "Using skill: typescript"
# → No manual selection needed
```

**61 Auto-Activating Skills:**
- **TypeScript** - Types, interfaces, generics
- **React** - Hooks, components, performance
- **Next.js** - App router, caching, PPR
- **Prisma** - Schema, migrations, queries
- **TailwindCSS** - Modern utilities
- **GraphQL** - Schemas, resolvers
- **WebSocket** - Real-time features
- **Security** - OWASP, GDPR compliance
- **Performance** - Profiling, optimization
- And 52 more...

**Manage skills:**
```bash
/skills           # View all skills
/skills create    # Create new skill
/skills import    # Import from Claude Code
```

---

### 2. 15 Specialist Droids (All Use Your Model)

**Every droid respects your model choice:**

| Droid | Purpose | Model |
|-------|---------|-------|
| **droidz-orchestrator** | Coordinate parallel work | inherit |
| **droidz-codegen** | Implement features | inherit |
| **droidz-test** | Write & fix tests | inherit |
| **droidz-refactor** | Code improvements | inherit |
| **droidz-infra** | CI/CD & deployment | inherit |
| **droidz-integration** | External APIs | inherit |
| **droidz-ui-designer** | UI components | inherit |
| **droidz-ux-designer** | User flows | inherit |
| **droidz-database-architect** | Schema design | inherit |
| **droidz-api-designer** | API design | inherit |
| **droidz-security-auditor** | Security reviews | inherit |
| **droidz-performance-optimizer** | Performance tuning | inherit |
| **droidz-accessibility-specialist** | WCAG compliance | inherit |
| **droidz-generalist** | General tasks | inherit |

**What `model: inherit` means:**
- You select GPT-4o → all droids use GPT-4o
- You switch to Claude Sonnet → all droids switch too
- **Consistent model across entire workflow**

---

### 3. Comprehensive Validation (NEW in v3.0)

**`/validate-init` - Smart Generation**

Analyzes your project and generates custom validation:

```bash
/validate-init

# Detects:
✓ Linter: ESLint
✓ Type checker: TypeScript
✓ Formatter: Prettier
✓ Tests: Jest + Playwright
✓ Framework: React + Next.js

# Generates: .factory/commands/validate.md
# Configured for YOUR project
```

**`/validate` - One Command, Full Validation**

```bash
/validate

Phase 1: Linting ✅
Phase 2: Type Checking ✅
Phase 3: Style Checking ✅
Phase 4: Unit Tests ✅ (24 passed)
Phase 5: E2E Tests ✅ (12 workflows tested)

All validation passed! Ready for deployment.
```

---

### 4. Intelligent Spec Generation

**`/build` - From Vague Ideas to Production Specs**

```bash
/build "add authentication"

Droidz asks:
- JWT or sessions? → JWT
- Password requirements? → 8+ chars, letters+numbers
- Social providers? → No

Generates: .factory/specs/active/001-auth.md

Contains:
✓ 6 parallelizable tasks
✓ Security requirements (OWASP)
✓ Edge cases covered
✓ Testing strategy
✓ Ready-to-execute plan

Execute now? [Yes/Review/Save]
```

---

## 📁 Project Structure (v3.0)

```
.factory/                    # Everything lives here
├── commands/                # Slash commands
│   ├── init.md             # /init
│   ├── build.md            # /build
│   ├── validate-init.md    # /validate-init (NEW)
│   ├── validate.md         # /validate (auto-generated)
│   └── parallel.md         # /parallel
├── droids/                  # 15 specialists
│   ├── droidz-orchestrator.md
│   ├── droidz-codegen.md
│   └── ... (all use model: inherit)
├── skills/                  # 61 auto-activating skills
│   ├── typescript/SKILL.md
│   ├── react/SKILL.md
│   └── ...
├── hooks/                   # Lifecycle hooks
│   ├── scripts/
│   │   ├── auto-lint.sh
│   │   ├── block-dangerous.sh
│   │   └── validate-on-edit.sh
│   └── settings.json
├── specs/                   # Generated specs
│   ├── active/             # Current (gitignored)
│   └── archived/           # Completed
├── validation/             # Validation framework (NEW)
│   ├── .validation-cache/
│   └── test-helpers/
└── memory/                  # Persistent context
    ├── org/                # Team decisions
    └── user/               # Your notes
```

**No `.droidz/` folder** - everything standardized in `.factory/`

---

## 🎬 Real-World Examples

### Example 1: Build Auth (v3.0 workflow)

```bash
# Step 1: Initialize
/init
✓ Project analyzed
✓ Validation generated
✓ Ready to build

# Step 2: Build auth
/build "add JWT authentication"

Droidz clarifies:
- Sessions or JWT? → JWT
- Requirements? → 8+ chars
- Social? → No

Generates spec:
✓ 6 tasks (3 parallel Phase 1, 3 parallel Phase 2)
✓ Security checklist
✓ Test strategy

# Step 3: Execute
Choose "Execute in parallel"

TodoWrite shows progress:
✅ Database schema
⏳ API endpoints...
⏳ JWT utilities...

15 minutes later:
✅ All complete! 12 files, 24 tests passing

# Step 4: Validate
/validate

Phase 1-5: All ✅
Ready for deployment!
```

---

### Example 2: Skills Auto-Activation

```bash
# No manual skill selection needed!

You: "Add Prisma schema for users"
→ Prisma skill auto-activates
→ CLI: "Using skill: prisma"
→ Applies Prisma best practices

You: "Create React component"
→ React skill auto-activates
→ CLI: "Using skill: react"
→ Follows React 19 patterns

You: "Optimize database queries"
→ Performance skill auto-activates
→ CLI: "Using skill: performance-optimizer"
→ Analyzes and optimizes
```

---

## 🆚 v2.x vs v3.0 Comparison

| Feature | v2.x | v3.0 |
|---------|------|------|
| **Skills** | Manual descriptions | ✅ Native Factory.ai (auto-activate) |
| **Model Inheritance** | Mixed | ✅ All droids use `model: inherit` |
| **Folder Structure** | `.droidz/` + `.factory/` | ✅ 100% `.factory/` |
| **Validation** | None | ✅ 5-phase pipeline |
| **Progress Tracking** | None | ✅ Live TodoWrite updates |
| **Hooks System** | Partial (4 types) | ✅ Full (7 types) |
| **Installation** | Complex (tmux, worktrees) | ✅ Simple (< 30s) |
| **CLI Integration** | Manual | ✅ `/skills` command |
| **Skill Reporting** | No | ✅ CLI reports usage |

---

## 📚 Documentation

- **Quick Start:** [This README]
- **Commands Guide:** [COMMANDS.md](COMMANDS.md)
- **Skills Guide:** [SKILLS.md](SKILLS.md) (NEW)
- **Validation Guide:** [VALIDATION.md](VALIDATION.md) (NEW)
- **Droids Guide:** [DROIDS.md](DROIDS.md) (NEW)
- **Migration Guide:** [MIGRATION_V3.md](MIGRATION_V3.md) (NEW)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)

---

## 🔧 Configuration (Optional)

Droidz works out-of-the-box, but you can customize:

### config.yml (optional)

```yaml
# Linear Integration (optional)
linear:
  project_name: "MyProject"

# Orchestrator Settings (optional)
orchestrator:
  max_parallel_streams: 5
  enable_monitoring: true
```

### Custom Skills

```bash
/skills create    # Create new skill
/skills import    # Import from Claude Code
/skills list      # View all skills
```

---

## 🐛 Troubleshooting

### Droids not showing?

```bash
/settings
# Ensure "Custom Droids" ON
# Ensure "Hooks" ON
# Restart: Ctrl+C then `droid`

/droids  # Should show all 15
```

### Skills not activating?

```bash
/skills list
# Ensure skills are present
# Skills auto-activate - no action needed
# CLI reports: "Using skill: <name>"
```

### Validation not generating?

```bash
# Run manually
/validate-init

# Check output
ls .factory/commands/validate.md
```

---

## 🚀 Migration from v2.x

v3.0 includes automatic migration:

```bash
# Run migration script
.factory/scripts/migrate-v3.sh

✅ Moves .droidz/specs/ → .factory/specs/archived/
✅ Removes .droidz/ folder
✅ Generates validation workflow
✅ Updates .gitignore

# Verify
droid
/init
/droids   # All droids present
/skills   # All skills present
```

**See [MIGRATION_V3.md](MIGRATION_V3.md) for detailed migration guide.**

**Breaking Changes:**
- `.droidz/` folder removed (auto-migrated)
- Commands renamed (old names aliased)
- All droids now use `model: inherit`

---

## 🤝 Contributing

Contributions welcome!

1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

## 🙏 Credits

**Built for Factory.ai Droid CLI** | **v3.0.0**

**Factory.ai Features Used:**
- Skills System (v0.26.0)
- Custom Droids with model inheritance
- Hooks System (v0.25.0)
- TodoWrite for progress
- Native CLI integration

**Created by the Droidz community** 🚀

---

**Transform vague ideas into production code - powered by Factory.ai** ✨
