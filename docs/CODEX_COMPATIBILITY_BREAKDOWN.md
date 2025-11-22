# Codex CLI Compatibility: What Works & What Doesn't

**Quick Reference**: Understand exactly what Droidz features will work in Codex CLI

---

## ✅ What WORKS in Codex CLI

### 1. Simple Commands with Instructions

**Example**: `/validate-init` command

**Claude Code Version**:
```markdown
---
description: Initialize validation workflow
---

!`echo "🔍 Checking for validation tools..."`
!`command -v eslint && echo "✓ ESLint found"`
!`command -v prettier && echo "✓ Prettier found"`
```

**Codex CLI Version**:
```markdown
---
description: Initialize validation workflow
---

# Validation Setup

Check for these validation tools and report status:
- ESLint (command: eslint)
- Prettier (command: prettier)  
- TypeScript (command: tsc)
- Jest (command: jest)

For each tool:
- ✓ if found
- ⚠️ if missing with installation command

Example output:
✓ ESLint found
⚠️ Prettier not found (install: npm i -D prettier)
```

**Why it works**: Codex interprets instructions and produces the same result.

---

### 2. High-Level Workflows

**Example**: Droidz orchestrator

**Current** (Factory.ai Droid):
```yaml
---
name: droidz-orchestrator
description: Coordinates parallel work
model: inherit
tools: ["Read", "Execute", "TodoWrite"]
---

You coordinate multiple specialist droids...
```

**Codex CLI Version**:
```markdown
---
description: Orchestrate complex multi-step features
argument-hint: FEATURE=<description>
---

# Orchestrator

You are coordinating implementation of: $FEATURE

## Process

1. **Analyze Complexity**
   - Break down into independent tasks
   - Identify dependencies
   - Estimate effort (S/M/L)

2. **Create Parallel Plan**
   - Task 1: [Component] - Files: x, y
   - Task 2: [Tests] - Files: z
   - Task 3: [Docs] - Files: readme

3. **Track Progress**
   - Create todo list with status
   - Update as you complete each task
   - Report blockers

4. **Synthesize Results**
   - Summary of changes
   - Testing instructions
   - Deployment notes

## Rules
- One task at a time
- Test after each task
- Commit frequently
- Document changes
```

**Why it works**: AI can follow workflow instructions naturally.

---

### 3. Project Documentation

**Example**: CLAUDE.md → AGENTS.md

**Current** (Claude Code):
```markdown
# CLAUDE.md

## Tech Stack
- TypeScript + React + Next.js
- Bun package manager

## Coding Standards
- Use functional components
- Prefer TypeScript strict mode
```

**Codex CLI**:
```markdown
# AGENTS.md

## Tech Stack
- TypeScript + React + Next.js
- Bun package manager

## Coding Standards
- Use functional components
- Prefer TypeScript strict mode
```

**Why it works**: Direct 1:1 mapping, same format.

---

### 4. Feature Specifications

**Example**: `.droidz/specs/` system

**Works identically in both**:
```
.droidz/specs/
├── active/001-feature.md
├── archive/
└── templates/
```

**Why it works**: File system organization, not tool-specific.

---

### 5. Knowledge as Instructions

**Example**: Skills converted to AGENTS.md

**Current** (Skill file):
```markdown
# test-driven-development.md
---
description: Write tests first, then implementation
---

When implementing features:
1. Write failing test first
2. Write minimal code to pass
3. Refactor
```

**Codex CLI** (in AGENTS.md):
```markdown
# AGENTS.md

## Development Process

### Test-Driven Development
When implementing features:
1. Write failing test first
2. Write minimal code to pass
3. Refactor

Example:
```typescript
// 1. Write test
test('adds numbers', () => {
  expect(add(2, 3)).toBe(5);
});

// 2. Implement
function add(a, b) { return a + b; }
```
```

**Why it works**: Instructions are instructions, regardless of location.

---

## ⚠️ What NEEDS ADAPTATION

### 1. Direct Shell Command Execution

**Example**: `/validate` command

**Claude Code** (Direct execution):
```markdown
!`npx eslint . 2>/dev/null || echo "⚠ Skipping"`
!`npx tsc --noEmit 2>/dev/null || echo "⚠ Skipping"`
!`npx prettier --check . 2>/dev/null || echo "⚠ Skipping"`
!`npm test 2>/dev/null || echo "⚠ Skipping"`
```

**Codex CLI** (Instructions to AI):
```markdown
# Validation Pipeline

Run these validation checks in sequence:

## Phase 1: Linting
- Command: `npx eslint .`
- If fails: Report errors
- If no config: Skip gracefully with "⚠ No ESLint config"

## Phase 2: Type Checking  
- Command: `npx tsc --noEmit`
- If fails: Show type errors
- If no config: Skip with "⚠ No TypeScript config"

## Phase 3: Style Checking
- Command: `npx prettier --check .`
- If fails: List files needing formatting
- If no config: Skip with "⚠ No Prettier config"

## Phase 4: Unit Tests
- Command: `npm test`
- If fails: Show test failures
- If no test script: Skip with "⚠ No test script"

## Output Format
Present results as table:

| Phase | Status | Details |
|-------|--------|---------|
| Linting | ✅ Pass | 0 errors |
| Types | ❌ Fail | 3 errors in src/utils.ts |
| Style | ✅ Pass | All formatted |
| Tests | ✅ Pass | 42 tests passed |
```

**Key Difference**: 
- Claude Code: `!`cmd`` = **execute this**
- Codex CLI: Instructions = **please do this**

**Trade-off**:
- ❌ Less predictable (AI interprets)
- ✅ More flexible (AI can handle errors)
- ✅ More context-aware (AI knows when to skip)

---

### 2. File Generation with Embedded Commands

**Example**: Dynamic command generation

**Claude Code** (Try to generate):
```markdown
!`cat > validate.md << 'EOF'
## Run Validation
!`npm test`
EOF`
```

**Codex CLI** (Cannot do this):
```markdown
# ❌ THIS DOESN'T WORK
# Cannot generate files with executable commands
# Codex prompts don't execute; they instruct

# ✅ INSTEAD: Provide template
Create a validation workflow file at `.droidz/validate.md`:

---
description: Run project validation
---

# Validation

1. Run linting: `npx eslint .`
2. Run type check: `npx tsc --noEmit`
3. Run tests: `npm test`
4. Report results in table format
```

**Workaround**: Provide templates, not generators.

---

### 3. Multi-Agent Parallel Execution

**Example**: Orchestrator spawning multiple droids

**Claude Code / Factory.ai**:
```yaml
# Can spawn multiple agents in parallel
Task:
  subagent_type: droidz-codegen
  prompt: "Implement auth API"

Task:
  subagent_type: droidz-test  
  prompt: "Write tests for auth"

Task:
  subagent_type: droidz-ui-designer
  prompt: "Create login form"
```

**Codex CLI**:
```markdown
# ❌ Cannot spawn parallel agents
# Codex CLI is single-threaded

# ✅ WORKAROUND 1: Sequential execution
1. First, implement auth API
2. Then, write tests
3. Finally, create login form

# ✅ WORKAROUND 2: Detailed plan for manual parallel
Create parallel execution plan:

**Stream 1: Backend (30 min)**
- File: src/api/auth.ts
- Tasks: JWT functions, routes
- Dependencies: None

**Stream 2: Tests (20 min)**  
- File: tests/auth.test.ts
- Tasks: Unit tests, integration tests
- Dependencies: Stream 1 complete

**Stream 3: Frontend (40 min)**
- File: src/components/LoginForm.tsx
- Tasks: Form component, validation
- Dependencies: Stream 1 complete

User can then run 3 Codex CLI sessions manually.
```

**Workaround**: 
- Create detailed parallel plans
- User runs multiple Codex sessions
- Or work sequentially (slower but simpler)

---

### 4. Agent Isolation / Context Separation

**Example**: Fresh context for each agent

**Claude Code / Factory.ai**:
```yaml
# Each agent starts fresh
Task 1: droidz-codegen (isolated context)
Task 2: droidz-test (isolated context)
```

**Codex CLI**:
```markdown
# ❌ Same conversation context continues
# Previous conversation affects next task

# ✅ WORKAROUND: Use /new command
After completing auth implementation, user runs:
/new

Then starts fresh with:
/prompts:test-specialist ACTION=write TARGET=auth.ts
```

**Workaround**: Use `/new` slash command to clear context.

---

### 5. Tool-Specific MCP Integrations

**Example**: Linear ticket updates

**Claude Code / Factory.ai**:
```typescript
// Can call MCP tools directly if configured
linear___update_issue({
  issueId: "PROJ-123",
  state: "In Progress"
})
```

**Codex CLI**:
```markdown
# ✅ MCP works but different syntax

If you have Linear MCP configured, update ticket:

Linear ticket PROJ-123:
- Status: In Progress
- Comment: "Implemented auth API, tests passing"

(Codex will use configured MCP server automatically)
```

**Works but**: Syntax is more conversational, not direct API calls.

---

## ❌ What DOESN'T WORK (No Workaround)

### 1. Complex Bash Scripting in Commands

**Example**: Multi-line conditional logic

**Claude Code**:
```markdown
!`if [ -f "package.json" ]; then
  if command -v bun >/dev/null; then
    bun install
  elif command -v pnpm >/dev/null; then
    pnpm install
  else
    npm install
  fi
fi`
```

**Codex CLI**:
```markdown
# ❌ Cannot embed complex bash scripts
# AI interprets instructions, doesn't execute bash

# ✅ MUST SIMPLIFY to high-level instruction:
Check if package.json exists.
If yes, install dependencies using:
- Bun (preferred)
- pnpm (fallback)  
- npm (last resort)

Report which package manager was used.
```

**Limitation**: Cannot execute complex bash logic; must rely on AI interpretation.

---

### 2. Generating Self-Modifying Commands

**Example**: Commands that create other commands

**Claude Code**:
```markdown
!`cat > .claude/commands/new-feature.md << 'EOF'
!`echo "Creating feature..."`
EOF`
```

**Codex CLI**:
```markdown
# ❌ IMPOSSIBLE
# Cannot create prompts that contain executable commands
# Prompts are static instruction files

# ✅ ALTERNATIVE: Template library
Create a template at `.droidz/templates/feature.md`
User can copy to `~/.codex/prompts/` and customize
```

**Limitation**: No metaprogramming; prompts are static.

---

### 3. Real-Time Command Output Streaming

**Example**: Watching test output live

**Claude Code**:
```markdown
!`npm test --watch`
# User sees output stream in real-time
```

**Codex CLI**:
```markdown
# ❌ No streaming output in prompts
# AI runs command, returns final result

# ✅ WORKAROUND: User runs directly
Tell user to run: `npm test --watch`
(Cannot show live output in Codex session)
```

**Limitation**: Batch results only, no streaming.

---

## 📊 Compatibility Summary Table

| Feature | Claude Code | Codex CLI | Workaround |
|---------|-------------|-----------|------------|
| **High-level workflows** | ✅ | ✅ | Direct conversion |
| **Project docs (CLAUDE.md)** | ✅ | ✅ (AGENTS.md) | Rename file |
| **Spec system** | ✅ | ✅ | Works unchanged |
| **Simple commands** | ✅ | ⚠️ | Convert to instructions |
| **Shell execution** | ✅ Direct | ⚠️ AI-interpreted | Accept less control |
| **Complex bash** | ✅ | ❌ | Simplify to high-level |
| **Parallel agents** | ✅ | ❌ | Sequential or manual parallel |
| **Agent isolation** | ✅ | ⚠️ | Use `/new` command |
| **Real-time output** | ✅ | ❌ | User runs manually |
| **Command generation** | ✅ | ❌ | Use templates |
| **MCP tools** | ✅ | ✅ | Different syntax |

---

## 🎯 Practical Guidelines

### ✅ DO Convert These Features

1. **High-level workflows** (orchestration, planning)
2. **Documentation standards** (CLAUDE.md → AGENTS.md)
3. **Specialist prompts** (codegen, test, refactor as prompts)
4. **Feature specifications** (.droidz/specs/ system)
5. **Knowledge/best practices** (embed in AGENTS.md)

### ⚠️ ADAPT These Features

1. **Validation commands** (describe process, not commands)
2. **File operations** (describe intent, not shell commands)
3. **Complex workflows** (break into steps with decisions)
4. **Error handling** (describe what to do, let AI handle)

### ❌ DON'T Attempt These Features

1. **Complex bash scripting** (loops, conditionals, pipes)
2. **Self-modifying commands** (generating prompts)
3. **Parallel agent spawning** (Codex is single-threaded)
4. **Real-time streaming output** (batch only)
5. **Precise command execution control** (AI interprets)

---

## 💡 Design Philosophy Shift

### Claude Code Philosophy
**"Execute exactly what I specify"**

```markdown
!`npx eslint .`
!`npx tsc --noEmit`
!`npm test`
```

**You control**: Exact commands, order, error handling

### Codex CLI Philosophy  
**"Accomplish what I describe"**

```markdown
Run validation:
1. Lint with ESLint
2. Type check with TypeScript
3. Run tests

Report results in table format.
```

**AI controls**: How to run, error handling, adaptations

---

## 🚦 Migration Decision Tree

```
Does feature involve...

├─ High-level instructions/workflows?
│  └─ ✅ CONVERT DIRECTLY
│
├─ Simple shell commands?
│  └─ ⚠️ CONVERT to descriptive instructions
│
├─ Complex bash (loops/conditionals)?
│  └─ ❌ SIMPLIFY to high-level goals
│
├─ Parallel execution?
│  ├─ Optional? → ⚠️ Make sequential
│  └─ Required? → ❌ Manual workaround only
│
├─ Real-time output?
│  └─ ❌ User runs command directly
│
└─ Self-modifying code?
   └─ ❌ Use static templates
```

---

## 📈 Effort Estimates

| Component | Complexity | Time | Notes |
|-----------|-----------|------|-------|
| **Core commands** (build, validate, init) | 🟡 Medium | 2-3 weeks | Rewrite as instructions |
| **Specialist agents** (15 droids) | 🟢 Low | 1-2 weeks | Convert to prompts |
| **Skills** (60+) | 🟢 Low | 1 week | Embed in AGENTS.md |
| **Orchestration** | 🔴 High | 3-4 weeks | Redesign without parallelism |
| **Validation pipeline** | 🟡 Medium | 1 week | Descriptive workflow |
| **Documentation** | 🟢 Low | 1 week | Update examples |
| **Total** | 🟡 Medium | **9-13 weeks** | MVP in 2-3 weeks |

---

## 🎯 Recommendation

**Create Codex CLI version with these scopes:**

### Phase 1: MVP (2-3 weeks)
- ✅ Core 3 commands (build, validate, init)
- ✅ 5 specialist prompts (codegen, test, refactor, review, debug)
- ✅ AGENTS.md template
- ✅ Basic documentation

**Focus**: Prove the concept works

### Phase 2: Full Feature Set (8-10 weeks)
- ✅ All 15 specialist prompts
- ✅ Skills embedded in AGENTS.md
- ✅ Sequential orchestration workflow
- ✅ Complete documentation
- ✅ Migration guide

**Focus**: Feature parity (minus parallelism)

### Phase 3: Advanced (Optional)
- ✅ MCP integration for parallel execution
- ✅ External orchestrator tool
- ✅ Codex-specific enhancements

**Focus**: Leverage Codex CLI unique features

---

## 📝 Conclusion

**Compatibility Score**: 70% Direct, 20% Adaptable, 10% Not Possible

**Key Insight**: Droidz can work on Codex CLI by shifting from **imperative commands** to **declarative instructions**.

**Trade-offs**:
- ❌ Less precise control
- ❌ No parallel execution  
- ✅ More flexible (AI adapts)
- ✅ More natural language
- ✅ Easier to maintain

**Bottom Line**: Worth creating a Codex CLI version, but it will be a **complementary tool**, not a direct port.
