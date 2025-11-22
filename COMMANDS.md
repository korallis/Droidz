# Droidz Commands Reference

**Current Version:** v3.1.6  
**Last Updated:** 2025-11-22

---

## 🎯 All Available Commands

Droidz has **6 powerful commands** built on Factory.ai's native capabilities:

### 1. `/init` - Smart Project Initialization 🆕

**Purpose:** Verify installation, analyze project, generate architecture docs

**Aliases:** `/droidz-init` (for backward compatibility)

**Usage:**
```
/init
```

**Optional arguments:**
```
/init frontend    # Focus on frontend analysis
/init backend     # Focus on backend analysis
/init fullstack   # Analyze both
```

**What it does:**
- ✅ Verifies Droidz installation (all commands & droids)
- 🔍 Detects project type (greenfield vs brownfield)
- 📊 Analyzes tech stack (framework, database, UI library)
- 📁 Maps codebase architecture
- 📄 Generates `.factory/architecture.md` documentation
- 💾 Creates `.factory/project.json` metadata
- 🎯 Provides personalized next steps
- 🎨 Suggests `/validate-init` to set up project validation

**When to use:**
- First time using Droidz in a project
- Want to verify installation
- Need architecture documentation
- Onboarding new team members

**Output:**
- `.factory/architecture.md` - Complete project analysis
- `.factory/project.json` - Structured metadata
- Recommendations for next steps

**Example output:**
```
✅ Installation verified - all 15 droids present
📊 Project: Brownfield (Existing Next.js 15 app)
📁 156 TypeScript files, 47 dependencies
📄 Generated: .factory/architecture.md
🎯 Next: /validate-init (set up validation)
🎯 Then: /build "add user authentication"
```

---

### 2. `/build` - Meta-Prompted Spec Generator ⭐ NEW IN v3.1

**Purpose:** Transform ideas into comprehensive, execution-ready specifications using advanced meta prompting

**Aliases:** `/droidz-build` (for backward compatibility)

**Usage:**
```
/build "feature description"
```

**Examples:**
```
/build "add user authentication"
/build "add dark mode toggle"
/build "implement real-time notifications with WebSocket"
/build "build e-commerce checkout flow with Stripe"
```

**🧠 What Makes v3.1 Different (Meta Prompting):**

#### Phase 1: Meta-Analysis
- **Adaptive Reasoning Orchestrator** - Analyzes complexity (Simple → Expert)
- **Domain Detection** - Identifies Frontend/Backend/Fullstack/Infrastructure
- **Stakeholder Analysis** - End users, developers, security, business, ops
- **Reasoning Type Selection** - Deductive, inductive, abductive, or analogical

#### Phase 2: Intelligent Clarification
- **Recursive Question Generation** - Uses "5 Whys" technique
- **Prioritized Questions** - Critical (🔴) → Important (🟡) → Nice-to-have (🟢)
- **Knowledge Graph Building** - Tracks answers and generates follow-ups
- **Auto-skips** for clear, detailed requests

#### Phase 3: Research & Pattern Discovery
- **Parallel Research** - Uses exa-code + ref tools for best practices
- **Framework-Specific** - Finds patterns for your tech stack
- **Security Research** - OWASP guidelines automatically included
- **Performance Patterns** - Caching, optimization techniques

#### Phase 4: Multi-Perspective Generation
- **Security Engineer View** - Threat modeling, OWASP checklist
- **Performance Engineer View** - Scalability, latency budgets
- **UX Designer View** - User flows, accessibility (WCAG 2.1)
- **DevOps View** - Deployment, monitoring, rollback strategies
- **QA Engineer View** - Test coverage, edge cases, automation

#### Phase 5: Self-Verification Loop
- **20-Point Quality Checklist** - Completeness, clarity, testability, actionability
- **Minimum 18/20 Score** - Ensures high quality before finalization
- **Recursive Refinement** - Identifies gaps and fills them automatically
- **Gap Analysis** - Finds missing requirements, ambiguous acceptance criteria

#### Phase 6: Simulated Peer Review
- **5 Expert Personas** - Senior Engineer, Security, UX, DevOps, QA
- **Catches Issues** - Things human reviewers would question
- **Addresses Feedback** - Incorporates critical concerns before finalizing

**📊 Impact vs v2.x:**
- 150% more targeted clarification questions
- 200% more thorough security coverage
- 100% performance requirements coverage (was often missing)
- 150% more comprehensive edge case handling
- 70% fewer revision cycles (self-refinement)
- 30% faster implementation (clearer specs)

**📝 Generated Specification Includes:**
- Executive Summary & Goals
- Architecture diagrams (Mermaid: C4, sequence, user journey)
- Detailed component breakdown
- Data models & API contracts
- Security threat model & OWASP checklist
- Performance budgets & monitoring
- Testing strategy (Unit, Integration, E2E)
- Edge cases with handling strategies
- Task breakdown with dependencies & estimates
- Rollout & migration strategy
- Open questions & risk analysis

**💾 Output:**
- Saves to `.factory/specs/active/NNN-feature-name.md`
- Offers execution options (parallel, sequential, review, modify)

**📚 Documentation:**
- See `docs/META_PROMPTING.md` for complete guide with 60+ examples

**Example Session:**

```
You: /build "add real-time notifications"

AI: [Meta-Analysis]
Complexity: Complex
Domain: Backend + Frontend
Primary Stakeholders: End users, developers, ops
Key Uncertainties: WebSocket vs SSE, offline handling, rate limiting

[Prioritized Questions]
🔴 Critical:
1. What triggers notifications? (user actions, system events, external webhooks?)
2. Who should receive notifications? (all users, specific roles, subscription-based?)

🟡 Important:
3. Offline notification handling? (queue in IndexedDB, email fallback?)
4. Rate limiting strategy? (max notifications/hour per user?)

You: [Answers...]

AI: [Research + Multi-Perspective Generation + Self-Verification]
Quality Score: 19/20 ✅

Spec saved to: .factory/specs/active/042-real-time-notifications.md

What would you like to do?
1️⃣  Review spec
2️⃣  Execute in parallel (⚡ Recommended, ~3 days with 2 devs)
3️⃣  Execute sequentially (~7 days)
4️⃣  Modify spec
```

---

---

### 3. `/parallel` - Intelligent Parallel Execution

**Purpose:** Execute specifications in parallel with automatic progress tracking

**Aliases:** `/auto-parallel` (for backward compatibility)

**Usage:**
```
/parallel "task description"
# OR
/parallel .factory/specs/active/NNN-feature-name.md
```

**Examples:**
```
/parallel "build REST API for todos"
/parallel "add payment integration"
/parallel .factory/specs/active/042-real-time-notifications.md
```

**What it does:**
- Analyzes complexity and breaks into subtasks
- Identifies what can run in parallel
- Spawns specialist droids for each task
- Reports progress via TodoWrite (live updates)
- Synthesizes results when complete
- 3-5x faster than sequential execution

**Progress Tracking:**
Progress appears directly in conversation:
```
TODO LIST UPDATED
✅ Database schema created (3 files)
⏳ API endpoints (implementing login...)
⏳ Frontend UI (building forms...)
✅ API endpoints complete (5 files)
⏳ Frontend UI (adding state management...)
```

---

### 4. `/validate-init` - Validation Setup Generator 🆕

**Purpose:** Auto-generate project-specific validation workflow

**Usage:**
```
/validate-init
```

**What it does:**
- 🔍 **Detects project tools** - Scans for linters, type checkers, formatters, test frameworks
- 📝 **Generates `/validate` command** - Tailored to YOUR project's tools
- 📊 **5-Phase pipeline** - Linting → Type checking → Style → Unit tests → E2E tests
- ⚙️ **Auto-configuration** - Works with ESLint, TypeScript, Prettier, Jest, Playwright, etc.
- 💾 **Saves to** `.factory/commands/validate.md`

**Detected Tools:**
- **Linters:** ESLint, Ruff, Flake8, pylint, RuboCop
- **Type Checkers:** TypeScript, Mypy, Flow
- **Style Checkers:** Prettier, Black, autopep8
- **Test Frameworks:** Jest, Vitest, Pytest, Mocha, RSpec
- **E2E Frameworks:** Playwright, Cypress, Selenium

**Output:**
- `.factory/commands/validate.md` - Complete validation workflow
- Ready-to-use `/validate` command
- Can customize phases as needed

**Example:**
```
You: /validate-init

AI: Scanning project for tools...
✅ Found: ESLint, TypeScript, Prettier, Jest, Playwright
📝 Generating .factory/commands/validate.md...
✅ Complete! Run /validate to check your project.
```

---

### 5. `/validate` - Comprehensive Project Validation 🆕

**Purpose:** Run all project quality checks in one command

**Note:** Auto-generated by `/validate-init` - tailored to YOUR project

**Usage:**
```
/validate
```

**What it does (5-Phase Pipeline):**

#### Phase 1: Linting
- Runs project-specific linters
- Example: `npm run lint` or `ruff check .`

#### Phase 2: Type Checking
- Runs type checkers
- Example: `tsc --noEmit` or `mypy .`

#### Phase 3: Style Checking
- Runs formatters in check mode
- Example: `prettier --check .` or `black --check .`

#### Phase 4: Unit Tests
- Runs unit test suite
- Example: `npm test` or `pytest`

#### Phase 5: E2E Tests
- Runs end-to-end tests
- Example: `playwright test` or `cypress run`

**Benefits:**
- ✅ One command validates everything
- ✅ Catches issues before PR
- ✅ Consistent validation across team
- ✅ Can add to git hooks

**Example Output:**
```
╔════════════════════════════════════════════════╗
║           VALIDATION RESULTS                   ║
╠════════════════════════════════════════════════╣
║ ✅ Phase 1: Linting - PASSED                   ║
║ ✅ Phase 2: Type Checking - PASSED             ║
║ ❌ Phase 3: Style Checking - FAILED            ║
║    → 5 files need formatting                   ║
║ ✅ Phase 4: Unit Tests - PASSED (47 tests)     ║
║ ⏭️  Phase 5: E2E Tests - SKIPPED (CI only)     ║
╠════════════════════════════════════════════════╣
║ Overall: FAILED (1/5 phases failed)            ║
╚════════════════════════════════════════════════╝
```

---

### 6. `/gh-helper` - GitHub CLI Helpers

**Purpose:** GitHub operations with correct JSON field names

**Usage:**
```
/gh-helper <command> [args]
```

**Available commands:**
- `pr-checks <pr-number>` - Show PR checks
- `pr-status <pr-number>` - Comprehensive PR status
- `pr-list` - List all pull requests

**Examples:**
```
/gh-helper pr-status 10
/gh-helper pr-checks 10
/gh-helper pr-list
```

---

## 🎯 Recommended Workflow

### For New Projects:

```bash
1. /init                              # Analyze project, set up Droidz
2. /validate-init                     # Generate validation workflow
3. /build "first feature"             # Generate comprehensive spec
4. /parallel .factory/specs/...       # Execute in parallel
5. /validate                          # Validate before committing
```

### For Existing Projects:

```bash
1. /init                              # Verify setup, analyze architecture  
2. /validate-init                     # Set up validation (if not done)
3. /build "new feature"               # Meta-prompted spec generation
4. Review spec (AI asks clarifying questions)
5. /parallel .factory/specs/...       # Execute with specialist droids
6. /validate                          # Run all quality checks
7. Commit with confidence!
```

---

## 📚 Additional Resources

- **Meta Prompting Guide:** `docs/META_PROMPTING.md` - Complete guide to `/build` improvements
- **Validation Guide:** `VALIDATION.md` - Deep dive into validation system
- **Skills Guide:** `SKILLS.md` - Understanding Factory.ai Skills (auto-activate!)
- **Droids Guide:** `DROIDS.md` - Model inheritance and specialist droids
- **Migration Guide:** `MIGRATION_V3.md` - Upgrading from v2.x to v3.x

---

## 🆕 What's New in v3.1

### Meta-Prompted `/build` Command

The `/build` command now uses **meta prompting** - AI that analyzes and improves its own specification generation process:

**7 Meta Prompting Techniques:**
1. **Adaptive Reasoning Orchestrator** - Selects optimal approach based on complexity
2. **Recursive Question Generation** - "5 Whys" with prioritized questions
3. **Multi-Perspective Analysis** - Security, Performance, UX, DevOps, QA views
4. **Self-Verification Loop** - 20-point quality checklist (18/20 minimum)
5. **Simulated Peer Review** - 5 expert personas review specs
6. **Recursive Meta Prompting** - AI refines itself until quality threshold met
7. **Research-Backed Generation** - exa-code + ref tools for best practices

**Impact:**
- 150% more targeted questions
- 200% better security coverage
- 70% fewer revision cycles
- 30% faster implementation

See `docs/META_PROMPTING.md` for complete details and 60+ examples.

---

## 🔄 Command Aliases (Backward Compatibility)

v3.x uses shorter command names, but old names still work:

| v3.x (New) | v2.x (Old) | Status |
|------------|------------|--------|
| `/init` | `/droidz-init` | ✅ Both work |
| `/build` | `/droidz-build` | ✅ Both work |
| `/parallel` | `/auto-parallel` | ✅ Both work |
| `/validate-init` | N/A | 🆕 New in v3.0 |
| `/validate` | N/A | 🆕 New in v3.0 |

---

**Need help?** Join our [Discord community](https://discord.gg/WnFDQqDBvC) or open an issue on GitHub!

**What it does:**
- Uses correct GitHub CLI JSON fields (`bucket` not `status`)
- Shows PR check status
- Displays comprehensive PR information
- Lists pull requests

---

## 📋 Command Comparison

| Feature | /droidz-init | /droidz-build | /auto-parallel | /gh-helper |
|---------|--------------|---------------|----------------|------------|
| **Purpose** | Onboard & analyze | Generate specs | Execute tasks | GitHub ops |
| **When to use** | First time setup | Planning features | Building code | PR management |
| **Output** | Architecture docs | Spec file | Working code | PR status |
| **Time** | 1-2 minutes | 1-5 minutes | 1-4 hours | Instant |
| **Parallelization** | N/A | N/A | Yes (3-5x faster) | N/A |

---

## 🎯 Common Workflows

### Workflow 1: First Time Setup → Build
```
1. /droidz-init                      # Verify & analyze
2. Review .factory/architecture.md    # Understand project
3. /droidz-build "add authentication" # Generate spec
4. Choose "Execute in parallel"       # Build it
```

### Workflow 2: Generate Spec → Execute
```
1. /droidz-build "add authentication"
2. Answer clarifying questions
3. Review generated spec
4. Choose "Execute in parallel"
```

### Workflow 3: Direct Execution
```
1. /auto-parallel "build REST API"
2. Monitor progress in conversation
```

### Workflow 4: PR Management
```
1. Create PR via git/GitHub
2. /gh-helper pr-status <number>
3. Check status of checks
```

---

## ❌ Deprecated Commands

These commands no longer exist (removed in v0.1.3):

- `/status` - Was for old tmux/worktree system
- `/watch` - Was for old tmux/worktree system
- `/parallel` - Replaced by `/auto-parallel`
- `/attach` - Was for old system
- `/summary` - Was for old system
- `/parallel-watch` - Was for old system

**Why removed:** Old system used git worktrees + tmux which didn't work with Factory.ai Task tool. Current system uses native Task tool with progress appearing directly in conversation.

---

## 🆕 Planned Commands (v0.3.0)

These commands are planned but not yet implemented:

- `/droidz-status` - Resume conversations with state tracking
- Spec execution tracking in `.factory/specs/active/`

---

## 🤔 Which Command Should I Use?

**If you want to:**
- **Get started / verify setup** → `/droidz-init`
- **Understand your project** → `/droidz-init`
- **Plan a feature carefully** → `/droidz-build`
- **Build something quickly** → `/auto-parallel`
- **Check a GitHub PR** → `/gh-helper`

**Pro tip:** Run `/droidz-init` first to verify everything, then use `/droidz-build` to plan features, and execute them in parallel for 3-5x speedup!

---

## 📚 More Information

- **Full Documentation:** [README.md](README.md)
- **Example Specs:** `.factory/specs/archived/000-example-contact-form.md`
- **CHANGELOG:** [CHANGELOG.md](CHANGELOG.md) (v0.2.0 section)
- **Skills Guide:** [SKILLS.md](SKILLS.md)

---

**Current Version:** v2.4.0-droid | **Commands:** 4 | **Last Updated:** 2025-11-18
