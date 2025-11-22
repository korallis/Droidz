# Codex CLI Research: Droidz Compatibility Analysis

**Date**: 2025-11-22  
**Purpose**: Assess whether Droidz framework can be adapted to work with OpenAI Codex CLI  
**Status**: ✅ **HIGHLY COMPATIBLE** - Codex CLI supports custom prompts that map directly to Droidz architecture

---

## Executive Summary

**Codex CLI is HIGHLY compatible with Droidz!** OpenAI's Codex CLI has a native **custom prompts system** (`~/.codex/prompts/`) that works almost identically to Claude Code's slash commands. We can adapt Droidz to work with Codex CLI with minimal changes.

### Key Findings

| Feature | Claude Code | Codex CLI | Compatibility |
|---------|------------|-----------|---------------|
| **Custom Commands** | `.claude/commands/*.md` | `~/.codex/prompts/*.md` | ✅ **100%** - Nearly identical |
| **Markdown Format** | `!`command`` blocks | Markdown content sent directly | ✅ **95%** - Different execution model |
| **Slash Commands** | `/command` | `/prompts:command` | ✅ **90%** - Different prefix |
| **Custom Agents** | `.claude/agents/*.md` | No direct equivalent | ⚠️ **Manual** - Use custom prompts |
| **Skills** | `.claude/skills/*.md` | No direct equivalent | ⚠️ **Manual** - Use custom prompts |
| **Config File** | `config.toml` | `~/.codex/config.toml` | ✅ **100%** - Same format |
| **Project Docs** | `CLAUDE.md` | `AGENTS.md` | ✅ **100%** - Direct equivalent |
| **Memory** | Not native | Not native | ✅ **Equal** - Both via project docs |

---

## 1. Codex CLI Architecture

### 1.1 Core Components

```
~/.codex/
├── config.toml              # Configuration (TOML format, like Claude Code)
├── prompts/                 # ✅ CUSTOM PROMPTS (like Claude Code commands)
│   ├── review.md
│   ├── ticket.md
│   └── build.md
├── auth.json                # Authentication
└── history/                 # Session history
```

### 1.2 Custom Prompts System

**Location**: `~/.codex/prompts/` or `$CODEX_HOME/prompts/`

**Format**: Markdown files (`.md` only)

**Invocation**: `/prompts:<name>` or just `/<name>` if no conflicts

**Features**:
- ✅ YAML frontmatter for metadata
- ✅ Named placeholders (`$FILE`, `$TICKET_ID`)
- ✅ Positional arguments (`$1`-`$9`, `$ARGUMENTS`)
- ✅ Description field for UI
- ✅ Argument hints for documentation

**Example Custom Prompt**:

```markdown
---
description: Generate implementation plan for a feature
argument-hint: FEATURE=<name> [COMPLEXITY=<level>]
---

# Feature Implementation Plan

Create a detailed implementation plan for: $FEATURE

Complexity level: $COMPLEXITY

Break down into:
1. Architecture decisions
2. File structure
3. Dependencies
4. Testing strategy
5. Deployment plan
```

**Usage**:
```
/prompts:build FEATURE="user authentication" COMPLEXITY=high
```

---

## 2. Droidz Compatibility Matrix

### 2.1 Direct Compatibility (No Changes Needed)

| Droidz Component | Codex CLI Equivalent | Notes |
|------------------|---------------------|--------|
| `config.yml` → `config.toml` | `~/.codex/config.toml` | Same TOML format |
| `CLAUDE.md` | `AGENTS.md` | Project-level instructions |
| `.droidz/specs/` | `.droidz/specs/` | Spec storage works identically |
| Memory system | `AGENTS.md` + prompts | Can use project docs for memory |

### 2.2 Requires Adaptation

| Droidz Component | Adaptation Strategy | Effort |
|------------------|---------------------|--------|
| **Commands** (`.claude/commands/`) | Convert to `~/.codex/prompts/` | 🟡 **MEDIUM** - Different execution model |
| **Agents** (`.claude/agents/`) | Create as custom prompts | 🟢 **LOW** - Simple conversion |
| **Skills** (`.claude/skills/`) | Embed in `AGENTS.md` or prompts | 🟡 **MEDIUM** - May need restructuring |
| **Slash Commands** | Use `/prompts:` prefix | 🟢 **TRIVIAL** - Just prefix change |
| **Command Execution** | No `!`cmd`` - use descriptions | 🔴 **HIGH** - Different paradigm |

### 2.3 Key Difference: Execution Model

**Claude Code**:
```markdown
# /build command
!`mkdir -p .droidz/specs/active`
!`echo "Creating spec..." > .droidz/specs/active/plan.md`
```

**Codex CLI**:
```markdown
# /prompts:build command
Please create a new specification in .droidz/specs/active/

1. Create the directory if it doesn't exist
2. Generate a detailed plan
3. Save it to plan.md
```

**Key Insight**: Codex CLI prompts are **instructions to the AI**, not shell commands to execute. The AI decides how to fulfill them.

---

## 3. Implementation Strategy: Droidz for Codex CLI

### 3.1 Recommended Architecture

```
~/.codex/
├── config.toml                    # Codex CLI config
├── prompts/                       # Droidz custom prompts
│   ├── build.md                   # Feature planning
│   ├── parallel.md                # Parallel execution
│   ├── validate.md                # Validation workflow
│   └── init.md                    # Project initialization
│
~/.droidz/                         # Droidz framework (shared)
├── prompts/                       # Prompt templates for Codex
│   ├── agents/
│   │   ├── codegen.md            # Code generation specialist
│   │   ├── test.md               # Testing specialist
│   │   ├── refactor.md           # Refactoring specialist
│   │   └── orchestrator.md       # Workflow orchestrator
│   ├── skills/
│   │   ├── typescript.md         # TypeScript expertise
│   │   ├── react.md              # React patterns
│   │   └── testing.md            # Testing strategies
│   └── templates/
│       ├── feature-spec.md       # Feature specification template
│       └── parallel-plan.md      # Parallel execution plan
│
Project/
├── AGENTS.md                      # Project instructions (Codex standard)
├── .droidz/
│   └── specs/                     # Unified specs location
│       ├── active/
│       ├── archive/
│       ├── templates/
│       └── examples/
```

### 3.2 Conversion Strategy

#### Phase 1: Core Commands (Highest Priority)

Convert essential Droidz commands to Codex prompts:

1. **`/build`** → `/prompts:build`
   - Input: Feature description
   - Output: Detailed implementation plan in `.droidz/specs/active/`
   
2. **`/validate`** → `/prompts:validate`
   - Run linting, type checking, tests
   - Report results
   
3. **`/init`** → `/prompts:init`
   - Create `AGENTS.md` with project context
   - Setup `.droidz/` structure

#### Phase 2: Specialist Agents (Medium Priority)

Create custom prompts for each agent type:

```markdown
# ~/.codex/prompts/codegen.md
---
description: Implement features with comprehensive tests
argument-hint: FEATURE=<description> [FILES=<paths>]
---

You are a specialist code generation agent.

**Your role**: Implement $FEATURE with production-ready code and tests.

**Guidelines**:
1. Write clean, maintainable code
2. Follow project standards in AGENTS.md
3. Include comprehensive unit tests
4. Add JSDoc/TSDoc comments for public APIs
5. Consider edge cases and error handling

**Files to modify**: $FILES

**Process**:
1. Analyze existing code structure
2. Plan implementation approach
3. Write code with tests
4. Verify compilation and tests pass
5. Summary of changes
```

**Usage**:
```
/prompts:codegen FEATURE="Add user profile page" FILES="src/pages/,src/components/"
```

#### Phase 3: Skills Integration (Lower Priority)

**Option A: Embed in AGENTS.md**
```markdown
# AGENTS.md

## TypeScript Guidelines
- Use strict mode
- Prefer `type` over `interface` for unions
- Use `unknown` instead of `any`
...

## React Patterns
- Use functional components with hooks
- Prefer composition over inheritance
...
```

**Option B: Create Skill Prompts**
```markdown
# ~/.codex/prompts/typescript-expert.md
---
description: Apply TypeScript best practices
---

Review the code and apply these TypeScript principles:
- Strict null checking
- Exhaustive type narrowing
- Avoid `any` types
...
```

### 3.3 Installation Script

**`install-codex.sh`**:
```bash
#!/bin/bash

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DROIDZ_VERSION="3.5.0"

echo "📦 Installing Droidz for Codex CLI v${DROIDZ_VERSION}..."

# Create Codex prompts directory
mkdir -p "$CODEX_HOME/prompts"

# Download Droidz prompts
echo "⬇️  Downloading Droidz prompts..."
curl -fsSL "https://raw.githubusercontent.com/korallis/Droidz/v${DROIDZ_VERSION}/prompts/codex/build.md" \
  -o "$CODEX_HOME/prompts/build.md"

curl -fsSL "https://raw.githubusercontent.com/korallis/Droidz/v${DROIDZ_VERSION}/prompts/codex/validate.md" \
  -o "$CODEX_HOME/prompts/validate.md"

curl -fsSL "https://raw.githubusercontent.com/korallis/Droidz/v${DROIDZ_VERSION}/prompts/codex/parallel.md" \
  -o "$CODEX_HOME/prompts/parallel.md"

# Create project structure
mkdir -p .droidz/specs/{active,archive,templates,examples}

# Download templates
curl -fsSL "https://raw.githubusercontent.com/korallis/Droidz/v${DROIDZ_VERSION}/.droidz/specs/templates/feature-spec.md" \
  -o .droidz/specs/templates/feature-spec.md

echo "✅ Droidz for Codex CLI installed!"
echo ""
echo "📖 Usage:"
echo "  /prompts:build    - Generate feature specification"
echo "  /prompts:validate - Run validation checks"
echo "  /prompts:parallel - Execute tasks in parallel"
echo ""
echo "🔧 Configuration: $CODEX_HOME/config.toml"
```

---

## 4. Key Advantages of Codex CLI

### 4.1 Native Features That Help Droidz

1. **Built-in Slash Commands**
   - `/model` - Switch models mid-session
   - `/review` - Code review current changes
   - `/diff` - Show git diff
   - `/new` - Start fresh conversation
   - `/compact` - Summarize to save context

2. **AGENTS.md Support**
   - Direct equivalent to CLAUDE.md
   - Hierarchical project docs
   - Automatic discovery

3. **MCP Integration**
   - Connect to external tools/APIs
   - Extend capabilities beyond built-ins
   - Example: Linear, Sentry, GitHub integration

4. **Sandbox & Approval Policies**
   - `read-only` - Safe exploration
   - `workspace-write` - Edit files
   - `danger-full-access` - Full control
   - Fine-grained approval control

5. **Config Profiles**
   - Multiple configurations
   - Easy switching: `codex --profile work`
   - Override per-session

### 4.2 Limitations vs Claude Code

| Feature | Claude Code | Codex CLI | Impact |
|---------|------------|-----------|--------|
| **Direct Command Execution** | `!`cmd`` blocks | AI interprets instructions | 🔴 **HIGH** - Different paradigm |
| **Multiple Files** | Edit tool handles | Must describe explicitly | 🟡 **MEDIUM** - More verbose |
| **Error Handling** | Immediate feedback | Context-dependent | 🟡 **MEDIUM** - Less predictable |
| **Command Chaining** | `&&` in !`` blocks | Must describe sequence | 🟡 **MEDIUM** - Less direct |

---

## 5. Recommended Implementation Plan

### 5.1 Minimal Viable Product (MVP)

**Goal**: Get core Droidz workflows working on Codex CLI

**Timeline**: 2-3 weeks

**Scope**:
1. ✅ Convert `/build` command
2. ✅ Convert `/validate` command  
3. ✅ Convert `/init` command
4. ✅ Create installation script
5. ✅ Update documentation
6. ✅ Test with sample projects

**Deliverables**:
- `install-codex.sh` - Installation script
- `~/.codex/prompts/` - Core prompts (build, validate, init)
- `CODEX_CLI.md` - Usage documentation
- `MIGRATION_CODEX.md` - Migration guide from Claude Code

### 5.2 Full Feature Parity

**Goal**: All Droidz features working on Codex CLI

**Timeline**: 1-2 months

**Scope**:
1. All 15 specialist agents as prompts
2. Top 20 skills integrated
3. Parallel execution workflow
4. Memory system via AGENTS.md
5. Standards enforcement
6. Validation pipeline (5 phases)

**Deliverables**:
- Complete prompt library
- Codex-specific configuration templates
- Comprehensive documentation
- Example projects
- Video tutorials

### 5.3 Advanced Features

**Goal**: Leverage Codex CLI unique capabilities

**Timeline**: 2-3 months

**Scope**:
1. MCP integration for Droidz
2. Custom model providers
3. Sandbox policy templates
4. OAuth integrations
5. Multi-profile workflows

---

## 6. Technical Challenges & Solutions

### Challenge 1: No Direct Command Execution

**Problem**: Claude Code's `!`cmd`` blocks execute shell commands directly. Codex CLI prompts are instructions.

**Solution**: 
- **Option A (Recommended)**: Write prompts as high-level instructions, trust AI to execute
  ```markdown
  Please run the validation pipeline:
  1. ESLint on src/
  2. TypeScript compilation check
  3. Jest unit tests
  4. Report results in table format
  ```

- **Option B**: Use MCP to create a shell execution server
  ```toml
  [mcp_servers.droidz-executor]
  command = "droidz-mcp-server"
  args = ["--workspace", "."]
  ```

- **Option C**: Hybrid approach - Critical commands via MCP, others as instructions

**Recommendation**: Start with Option A, add MCP (Option B) if needed for reliability.

### Challenge 2: Agent Isolation

**Problem**: Claude Code agents run in isolated contexts. Codex CLI prompts share context.

**Solution**:
- Use `/new` command to start fresh context when needed
- Design prompts to be self-contained
- Use `AGENTS.md` for shared project context
- Document when to use `/new` vs continuing conversation

### Challenge 3: Parallel Execution

**Problem**: Droidz orchestrator spawns multiple agents in parallel. Codex CLI is sequential.

**Solution**:
- **Option A**: Manual parallelization (user runs multiple Codex sessions)
- **Option B**: Create detailed parallel execution plan, let AI work through it
- **Option C**: Build external orchestrator that manages multiple Codex CLI processes

**Recommendation**: Start with Option B (detailed plans), add Option C if demand exists.

---

## 7. Example Conversions

### 7.1 `/build` Command

**Claude Code Version** (`.claude/commands/build.md`):
```markdown
---
description: Generate feature specification
---

# Build Command

!`mkdir -p .droidz/specs/active`

!`cat > .droidz/specs/active/feature.md << 'EOF'
# Feature Specification
...
EOF`

!`echo "✅ Created .droidz/specs/active/feature.md"`
```

**Codex CLI Version** (`~/.codex/prompts/build.md`):
```markdown
---
description: Generate detailed feature implementation plan
argument-hint: FEATURE=<description> [COMPLEXITY=<low|medium|high>]
---

# Feature Planning

Create a comprehensive implementation plan for: **$FEATURE**

Complexity: $COMPLEXITY

## Required Sections

1. **Overview** - High-level description and goals
2. **Architecture** - System design and component breakdown
3. **Tasks** - Parallelizable implementation tasks (numbered)
4. **Dependencies** - External libraries, APIs, services
5. **Testing Strategy** - Unit, integration, E2E tests
6. **Deployment Plan** - Steps to production
7. **Risks** - Potential issues and mitigations

## Output Format

- Save plan to `.droidz/specs/active/NNN-feature-name.md`
- Use next available number (NNN)
- Follow template from `.droidz/specs/templates/feature-spec.md`

## Task Breakdown Rules

- Each task should be independently completable
- Include file paths to modify
- Estimate complexity (S/M/L)
- Identify dependencies between tasks
- Mark tasks that can run in parallel
```

**Usage**:
```
/prompts:build FEATURE="Add real-time notifications" COMPLEXITY=high
```

### 7.2 `/validate` Command

**Codex CLI Version** (`~/.codex/prompts/validate.md`):
```markdown
---
description: Run comprehensive validation pipeline
argument-hint: [PHASE=<1-5|all>]
---

# Validation Pipeline

Run validation checks (Phase: $PHASE)

## Phases

1. **Linting** - ESLint, Prettier, etc.
2. **Type Checking** - TypeScript, Flow, etc.
3. **Unit Tests** - Jest, Vitest, etc.
4. **Integration Tests** - API tests, database tests
5. **E2E Tests** - Playwright, Cypress, etc.

## Process

For each phase:
1. Detect available tools (check package.json, config files)
2. Run appropriate commands (npx for auto-install)
3. Report results in table format:

| Phase | Tool | Status | Details |
|-------|------|--------|---------|
| Linting | ESLint | ✅ Pass | 0 errors, 0 warnings |
| Types | TypeScript | ❌ Fail | 3 errors in src/utils.ts |

4. If failures, show relevant excerpts
5. Suggest fixes

## Rules

- Use `npx` to auto-install tools if missing
- Skip phase gracefully if tool not configured
- Always show summary at the end
- If PHASE specified, only run that phase
```

**Usage**:
```
/prompts:validate
/prompts:validate PHASE=1
```

### 7.3 Agent Prompt Example

**Codex CLI Version** (`~/.codex/prompts/test-specialist.md`):
```markdown
---
description: Testing specialist - write and fix tests
argument-hint: ACTION=<write|fix|coverage> [TARGET=<file-or-component>]
---

# Testing Specialist Agent

**Role**: Testing expert focused on comprehensive test coverage

**Action**: $ACTION  
**Target**: $TARGET

## Capabilities

### Write Tests (`ACTION=write`)
- Analyze component/function
- Write unit tests covering:
  - Happy paths
  - Edge cases
  - Error conditions
  - Boundary values
- Follow project test conventions (check existing tests)
- Use appropriate testing library (Jest, Vitest, React Testing Library, etc.)

### Fix Tests (`ACTION=fix`)
- Analyze failing test output
- Identify root cause
- Fix implementation or test (whichever is wrong)
- Ensure tests pass
- Add regression test if needed

### Coverage (`ACTION=coverage`)
- Run coverage report
- Identify untested code paths
- Write tests for uncovered areas
- Aim for >80% coverage

## Testing Principles

1. **Arrange-Act-Assert** pattern
2. **One assertion per test** (when possible)
3. **Descriptive test names** (`should throw error when input is negative`)
4. **Mock external dependencies**
5. **Avoid testing implementation details**
6. **Test behavior, not internals**

## Process

1. Read project test setup (jest.config.js, vitest.config.ts, etc.)
2. Review existing test patterns
3. Execute action
4. Run tests to verify
5. Report results and coverage

## Example Test Structure

\`\`\`typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { name: 'John', email: 'john@example.com' };
      
      // Act
      const user = await userService.createUser(userData);
      
      // Assert
      expect(user).toMatchObject(userData);
      expect(user.id).toBeDefined();
    });

    it('should throw validation error with invalid email', async () => {
      // Arrange
      const userData = { name: 'John', email: 'invalid' };
      
      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects.toThrow('Invalid email');
    });
  });
});
\`\`\`
```

**Usage**:
```
/prompts:test-specialist ACTION=write TARGET=src/services/user.ts
/prompts:test-specialist ACTION=fix TARGET=tests/auth.test.ts
/prompts:test-specialist ACTION=coverage
```

---

## 8. Documentation Structure

### Recommended Docs

1. **`CODEX_CLI.md`** - Main usage guide
   - Installation
   - Core commands
   - Configuration
   - Examples

2. **`MIGRATION_CODEX.md`** - Migration from Claude Code
   - Key differences
   - Conversion guide
   - Troubleshooting

3. **`CODEX_PROMPTS_REFERENCE.md`** - All available prompts
   - Command reference
   - Arguments
   - Examples

4. **`CODEX_AGENTS.md`** - Specialist agents
   - Agent descriptions
   - When to use
   - Invocation examples

---

## 9. Proof of Concept: Priority Prompts

### High Priority (MVP)

1. ✅ **build.md** - Feature specification generation
2. ✅ **validate.md** - Validation pipeline
3. ✅ **init.md** - Project initialization

### Medium Priority

4. ⏳ **parallel.md** - Parallel execution planning
5. ⏳ **codegen.md** - Code generation specialist
6. ⏳ **test.md** - Testing specialist
7. ⏳ **refactor.md** - Refactoring specialist

### Lower Priority

8. ⏳ **review.md** - Code review
9. ⏳ **debug.md** - Systematic debugging
10. ⏳ **optimize.md** - Performance optimization

---

## 10. Conclusion

### ✅ Feasibility: HIGH

Droidz CAN be adapted to work with Codex CLI with reasonable effort. The custom prompts system is a direct analog to Claude Code's commands.

### 🎯 Recommendation: PROCEED

**We should create a Codex CLI version of Droidz.**

**Reasons**:
1. ✅ Native support for custom prompts
2. ✅ AGENTS.md compatibility (project docs)
3. ✅ TOML config format (same as Claude Code)
4. ✅ Large user base (OpenAI ecosystem)
5. ✅ MCP integration for extensibility
6. ✅ Active development and community

**Key Success Factors**:
1. Design prompts as **instructions**, not commands
2. Trust AI to execute (different from `!`cmd`` model)
3. Use AGENTS.md for project context
4. Create comprehensive documentation
5. Provide migration path from Claude Code version

### 📊 Effort Estimate

| Phase | Timeline | Complexity |
|-------|----------|------------|
| MVP (3 core commands) | 2-3 weeks | 🟡 Medium |
| Full agents (15 prompts) | 4-6 weeks | 🟡 Medium |
| Skills integration | 2-3 weeks | 🟢 Low |
| MCP integration | 3-4 weeks | 🔴 High |
| Documentation | 1-2 weeks | 🟢 Low |
| **Total** | **12-18 weeks** | 🟡 **Medium** |

### 🚀 Next Steps

1. ✅ Create MVP prompts (build, validate, init)
2. ✅ Write installation script
3. ✅ Test with sample projects
4. ✅ Document differences from Claude Code
5. ✅ Create migration guide
6. 🔄 Gather feedback from early adopters
7. 🔄 Iterate and expand

---

## Appendix A: Research Sources

- **Codex CLI GitHub**: https://github.com/openai/codex
- **Codex CLI Docs**: https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started
- **Custom Prompts Guide**: https://github.com/openai/codex/blob/main/docs/prompts.md
- **Slash Commands**: https://github.com/openai/codex/blob/main/docs/slash_commands.md
- **Configuration**: https://github.com/openai/codex/blob/main/docs/config.md
- **AGENTS.md Discovery**: https://github.com/openai/codex/blob/main/docs/agents_md.md

## Appendix B: Comparison Table

| Aspect | Droidz (Claude Code) | Droidz (Codex CLI) |
|--------|---------------------|-------------------|
| **Installation** | curl \| bash → .claude/ | curl \| bash → ~/.codex/prompts/ |
| **Commands** | .claude/commands/*.md | ~/.codex/prompts/*.md |
| **Agents** | .claude/agents/*.md | ~/.codex/prompts/agent-*.md |
| **Skills** | .claude/skills/*.md | Embedded in AGENTS.md |
| **Config** | config.toml | ~/.codex/config.toml |
| **Project Docs** | CLAUDE.md | AGENTS.md |
| **Specs** | .droidz/specs/ | .droidz/specs/ (unchanged) |
| **Memory** | .factory/memory/ | .droidz/memory/ (custom) |
| **Invocation** | /command | /prompts:command |
| **Execution** | Direct shell (!`...`) | AI interprets instructions |
| **Parallel** | Multi-agent spawn | Sequential (manual parallel) |

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-22  
**Author**: Droid (Factory.ai)  
**Status**: Research Complete ✅
