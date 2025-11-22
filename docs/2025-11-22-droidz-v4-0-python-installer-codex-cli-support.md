# Droidz v4.0: Python Installer + Full Codex CLI Support

## 🎯 Overview

Create a **Python-based interactive installer** that:
1. ✅ Replaces buggy bash installer
2. ✅ Supports **Claude Code** and **Codex CLI**
3. ✅ Only installs compatible components per platform
4. ✅ Interactive TUI with component selection
5. ✅ Smart dependency detection and management
6. ✅ Comprehensive compatibility validation

---

## 📊 Component Compatibility Matrix

| Component | Claude Code | Codex CLI | Notes |
|-----------|-------------|-----------|-------|
| **Commands** (5 total) | ✅ Direct | ⚠️ Adapt | Convert `!`cmd`` to instructions |
| **Droids/Agents** (15 total) | ✅ Native | ✅ Prompts | Map to `~/.codex/prompts/` |
| **Skills** (60+ total) | ✅ Native | ⚠️ AGENTS.md | Embed in project docs |
| **CLAUDE.md** | ✅ | → **AGENTS.md** | Rename + adapt |
| **Specs System** | ✅ | ✅ | Identical |
| **Validation** | ✅ Direct | ⚠️ Descriptive | Instructions vs commands |
| **Hooks** | ✅ | ❌ | Not supported |

---

## 🏗️ New Project Structure

```
Droidz/
├── install.py                      # New Python installer
├── installer/
│   ├── __init__.py
│   ├── cli.py                      # Interactive TUI (inquirer/questionary)
│   ├── compatibility.py            # Platform detection
│   ├── installer_claude.py         # Claude Code installer
│   ├── installer_codex.py          # Codex CLI installer
│   ├── components.py               # Component registry
│   ├── converters.py               # Claude → Codex conversion
│   └── validators.py               # Pre/post install checks
│
├── templates/
│   ├── claude/                     # Claude Code templates
│   │   ├── commands/
│   │   ├── droids/
│   │   └── skills/
│   └── codex/                      # Codex CLI templates
│       ├── prompts/
│       │   ├── build.md
│       │   ├── validate.md
│       │   ├── codegen.md
│       │   └── ...
│       └── AGENTS.md.template
│
├── .claude/                        # Claude Code (existing)
│   ├── commands/
│   ├── skills/
│   └── CLAUDE.md
│
├── .factory/                       # Droid CLI (existing)
│   ├── droids/
│   ├── skills/
│   ├── commands/
│   └── specs/
│
├── .codex/                         # **NEW** Codex CLI templates
│   └── prompts/
│       ├── build.md
│       ├── validate.md
│       ├── codegen.md
│       ├── test-specialist.md
│       └── orchestrator.md
│
├── docs/
│   ├── CODEX_CLI.md               # Codex usage guide
│   ├── CODEX_MIGRATION.md         # Claude → Codex migration
│   └── CODEX_COMPATIBILITY.md     # What works/doesn't
│
└── legacy/
    └── install.sh                  # Keep old installer for reference
```

---

## 🎨 Python Installer Features

### 1. Interactive TUI (using `inquirer` or `questionary`)

```python
# Example flow
from inquirer import List, Checkbox, prompt

questions = [
    List('platform',
         message='Select platform to install for:',
         choices=[
             'Claude Code',
             'Codex CLI',
             'Droid CLI (Factory.ai)',
             'All platforms'
         ]),
    
    Checkbox('components',
             message='Select components to install:',
             choices=[
                 {'name': '✅ Core Commands (5)', 'checked': True},
                 {'name': '✅ Specialist Agents (15)', 'checked': True},
                 {'name': '⚠️  Skills (60+) - Will adapt for Codex', 'checked': True},
                 {'name': '✅ Validation Pipeline', 'checked': True},
                 {'name': '✅ Specs System', 'checked': True},
                 {'name': '⚠️  Hooks (Claude/Droid only)', 'checked': False},
             ])
]

answers = prompt(questions)
```

### 2. Smart Dependency Detection

```python
class DependencyManager:
    def detect_platform(self) -> Platform:
        """Detect Claude Code, Codex CLI, or Droid CLI"""
        
    def check_codex_installation(self) -> bool:
        """Check if Codex CLI is installed"""
        return shutil.which('codex') is not None
        
    def check_claude_installation(self) -> bool:
        """Check if Claude Code is installed"""
        return shutil.which('claude') is not None
        
    def verify_node_version(self) -> bool:
        """Verify Node.js version for Codex CLI"""
        
    def install_missing_deps(self, platform: Platform):
        """Offer to install missing dependencies"""
```

### 3. Component Conversion Engine

```python
class ComponentConverter:
    def convert_command_to_codex_prompt(self, cmd_path: Path) -> str:
        """
        Convert Claude Code command to Codex CLI prompt
        
        Example:
        Claude: !`npx eslint .`
        Codex: "Run ESLint to lint the project..."
        """
        
    def convert_droid_to_codex_prompt(self, droid_path: Path) -> str:
        """Convert specialist droid to Codex prompt"""
        
    def embed_skills_in_agents_md(self, skills: List[Path]) -> str:
        """Combine skills into AGENTS.md for Codex"""
```

### 4. Compatibility Validator

```python
class CompatibilityValidator:
    def validate_codex_prompt(self, prompt: str) -> ValidationResult:
        """Check if prompt uses incompatible features"""
        issues = []
        
        # Check for shell execution
        if '!`' in prompt:
            issues.append("Direct shell commands not supported")
            
        # Check for complex bash
        if any(x in prompt for x in ['if [', 'for ', 'while ']):
            issues.append("Complex bash scripting not supported")
            
        return ValidationResult(valid=len(issues)==0, issues=issues)
```

---

## 📝 Converted Codex CLI Prompts

### `/prompts:build` (from `/build` command)

```markdown
---
description: Generate comprehensive feature implementation plan
argument-hint: FEATURE=<description> [COMPLEXITY=<low|medium|high>]
---

# Feature Planning & Specification

Create a detailed implementation plan for: **$FEATURE**

Complexity Level: ${COMPLEXITY:-medium}

## Planning Process

1. **Analyze Requirements**
   - Break down feature into components
   - Identify dependencies
   - Assess technical complexity

2. **Create Architecture**
   - System design
   - Data models
   - API contracts

3. **Task Breakdown**
   - List parallelizable tasks
   - Estimate effort (S/M/L)
   - Identify dependencies

4. **Testing Strategy**
   - Unit test requirements
   - Integration test scenarios
   - E2E test flows

5. **Deployment Plan**
   - Migration steps
   - Rollback strategy
   - Monitoring

## Output

Save plan to `.droidz/specs/active/NNN-feature-name.md`

Use template from `.droidz/specs/templates/feature-spec.md`

Format each task as:
- **Task N**: [Component] - Brief description
- **Files**: List of files to modify
- **Effort**: S/M/L
- **Dependencies**: Task numbers this depends on
- **Parallelizable**: Yes/No

Example:
**Task 1**: [Backend] Create auth API endpoints
**Files**: `src/api/auth.ts`, `src/routes/auth.ts`
**Effort**: M
**Dependencies**: None
**Parallelizable**: Yes
```

### `/prompts:validate` (from `/validate` command)

```markdown
---
description: Run comprehensive validation pipeline (5 phases)
argument-hint: [PHASE=<1-5|all>]
---

# Validation Pipeline

Run validation checks for phase: ${PHASE:-all}

## Phase Overview

1. **Linting** - Code quality (ESLint, Ruff, etc.)
2. **Type Checking** - Type safety (TypeScript, mypy)
3. **Style** - Formatting (Prettier, black)
4. **Unit Tests** - Component tests
5. **Integration Tests** - API/database tests

## Execution Process

For each phase:

### 1. Detect Tools
Check `package.json`, config files for:
- ESLint (`.eslintrc`, `eslint.config.js`)
- TypeScript (`tsconfig.json`)
- Prettier (`.prettierrc`)
- Jest/Vitest (`jest.config`, `vitest.config`)

### 2. Run Commands
Use `npx` for auto-installation:
- `npx eslint .` (or configured path)
- `npx tsc --noEmit`
- `npx prettier --check .`
- `npm test` (or `bun test`)

### 3. Handle Results
- ✅ Pass: Show success with counts
- ❌ Fail: Show error excerpts (max 10 lines)
- ⚠️ Skip: Tool not configured

### 4. Report Format

Present results as table:

| Phase | Tool | Status | Details |
|-------|------|--------|---------|
| Linting | ESLint | ✅ Pass | 0 errors, 0 warnings |
| Types | TypeScript | ❌ Fail | 3 errors (see below) |
| Style | Prettier | ✅ Pass | All files formatted |
| Tests | Jest | ✅ Pass | 42/42 tests passed |

For failures, show relevant excerpts:
```
src/utils.ts:23:5 - error TS2339: Property 'foo' does not exist
src/utils.ts:45:12 - error TS2345: Argument of type 'string' is not assignable
```

### 5. Summary

**Overall**: ✅ 4/5 phases passed

**Action Items**:
- Fix TypeScript errors in src/utils.ts
- Run `npx tsc --noEmit` to verify fixes
```

### `/prompts:codegen` (from `droidz-codegen` droid)

```markdown
---
description: Implement features with comprehensive tests
argument-hint: FEATURE=<description> [FILES=<paths>]
---

# Code Generation Specialist

Implement: **$FEATURE**

Target Files: ${FILES:-auto-detect}

## Implementation Process

### 1. Understand Context
- Read existing codebase patterns
- Identify coding standards (from AGENTS.md)
- Review related components
- Check for existing tests

### 2. Plan Implementation
- Which files to create/modify
- What patterns to follow
- Dependencies to add
- Tests to write

### 3. Implement Feature
- Create new files with `Create` (if needed)
- Modify existing files with `Edit`
- Follow project conventions:
  - Indentation (match existing)
  - Naming conventions
  - Import organization
  - Comment style (minimal)
  
### 4. Write Tests
- Unit tests for new functions
- Integration tests for APIs
- Edge cases and error conditions
- Use project's test framework (Jest/Vitest/etc.)

### 5. Verify
- Run linter: `npx eslint [files]`
- Type check: `npx tsc --noEmit`
- Run tests: `npm test` (or `bun test`)
- Fix any issues

## Guidelines

**DO**:
- ✅ Match existing code style
- ✅ Use descriptive variable names
- ✅ Add JSDoc/TSDoc for public APIs
- ✅ Handle errors gracefully
- ✅ Write tests alongside code

**DON'T**:
- ❌ Use hardcoded secrets (use env vars)
- ❌ Add excessive comments
- ❌ Skip error handling
- ❌ Ignore TypeScript errors
- ❌ Forget to run tests

## Output

Provide summary:
- Files created
- Files modified
- Tests added
- Commands run
- Next steps
```

---

## 🔧 Installation Flow

```
┌─────────────────────────────────────┐
│  Droidz v4.0 Installer              │
└─────────────────────────────────────┘

🔍 Detecting environment...
  ✓ OS: macOS 15.1
  ✓ Shell: zsh
  ✓ Node.js: v20.10.0
  ✓ Codex CLI: installed (v0.63.0)
  ✓ Claude Code: not found
  ✓ Droid CLI: installed (v0.26.0)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

? Select installation target:
  › Claude Code
    Codex CLI
    Droid CLI (Factory.ai)
    All platforms

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

? Select components to install:
  ◉ Core Commands (5) - Compatible ✅
  ◉ Specialist Agents (15) - Will convert to prompts
  ◉ Validation Pipeline - Will adapt for Codex
  ◯ Skills (60+) - Will embed in AGENTS.md
  ◉ Specs System (.droidz/specs/) - Fully compatible
  ◯ Examples - Skip

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Installing for Codex CLI...

  ✓ Created ~/.codex/prompts/
  ✓ Converting commands → prompts (5)
      • build.md → prompts/build.md
      • validate.md → prompts/validate.md
      • init.md → prompts/init.md
      • parallel.md → prompts/parallel.md
      • gh-helper.md → prompts/gh-helper.md
  
  ✓ Converting agents → prompts (15)
      • droidz-orchestrator → orchestrator.md
      • droidz-codegen → codegen.md
      • droidz-test → test-specialist.md
      ... (12 more)
  
  ✓ Created AGENTS.md with embedded skills
  ✓ Created .droidz/specs/ structure
  ✓ Installed validation templates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Installation complete!

📖 Quick Start:

  # Start Codex CLI
  codex

  # Try commands:
  /prompts:build FEATURE="user auth" COMPLEXITY=high
  /prompts:validate
  /prompts:codegen FEATURE="login form"

📚 Documentation:
  • Codex Guide: docs/CODEX_CLI.md
  • Migration: docs/CODEX_MIGRATION.md
  • Compatibility: docs/CODEX_COMPATIBILITY.md

🎯 Test installation:
  codex "/prompts:list"
```

---

## 🧪 Testing Strategy

### Unit Tests
```python
# tests/test_converter.py
def test_convert_simple_command():
    converter = ComponentConverter()
    claude_cmd = "!`npx eslint .`"
    codex_prompt = converter.convert_command(claude_cmd)
    assert "Run ESLint" in codex_prompt
    assert "!`" not in codex_prompt
```

### Integration Tests
```python
# tests/test_installer.py
def test_codex_installation_flow():
    installer = CodexInstaller()
    result = installer.install(
        components=['commands', 'agents', 'validation']
    )
    assert result.success
    assert Path('~/.codex/prompts/build.md').exists()
```

---

## 📚 Documentation Updates

### New Files
1. **`docs/CODEX_CLI.md`** - Complete Codex usage guide
2. **`docs/CODEX_MIGRATION.md`** - Claude → Codex migration
3. **`docs/PYTHON_INSTALLER.md`** - Installer usage guide

### Updated Files
1. **`README.md`** - Add Codex CLI section
2. **`COMMANDS.md`** - Document Codex prompt syntax
3. **`CHANGELOG.md`** - v4.0.0 release notes

---

## 🚀 Implementation Phases

### Phase 1: Python Installer Foundation (Week 1)
- [ ] Create `install.py` with inquirer/questionary
- [ ] Implement platform detection
- [ ] Build component registry
- [ ] Add dependency checker
- [ ] Test on macOS, Linux, WSL2

### Phase 2: Conversion Engine (Week 2)
- [ ] Build command → prompt converter
- [ ] Build droid → prompt converter
- [ ] Create skills → AGENTS.md embedder
- [ ] Add compatibility validator
- [ ] Write conversion tests

### Phase 3: Codex Templates (Week 2-3)
- [ ] Convert 5 core commands
- [ ] Convert 15 specialist droids
- [ ] Create AGENTS.md template with embedded skills
- [ ] Build validation prompts
- [ ] Test with real Codex CLI

### Phase 4: Documentation & Polish (Week 3)
- [ ] Write CODEX_CLI.md
- [ ] Write CODEX_MIGRATION.md
- [ ] Update README.md
- [ ] Create video tutorials
- [ ] Update CHANGELOG.md

### Phase 5: Testing & Release (Week 4)
- [ ] Beta testing with community
- [ ] Fix bugs
- [ ] Polish UX
- [ ] Release v4.0.0
- [ ] Announce on Discord

---

## 💡 Key Design Decisions

### 1. Python vs Bash
**Choice**: Python with `inquirer`/`questionary`
**Reason**: 
- ✅ Better error handling
- ✅ Cross-platform compatibility
- ✅ Rich TUI libraries
- ✅ Easier to maintain/test
- ✅ No more parsing hell

### 2. Conversion vs Manual
**Choice**: Automated conversion with validation
**Reason**:
- ✅ Faster development
- ✅ Consistency across platforms
- ✅ Easy to update when templates change
- ✅ Reduces human error

### 3. Embedded vs Separate Skills
**Choice**: Embed skills in AGENTS.md for Codex
**Reason**:
- ✅ Codex has no native skills system
- ✅ AGENTS.md is standard Codex practice
- ✅ Simpler for users
- ❌ Trade-off: Less granular control

### 4. Full Compatibility vs Subset
**Choice**: Convert what works, document what doesn't
**Reason**:
- ✅ Honest about limitations
- ✅ Sets clear expectations
- ✅ Focuses on 70% that works well
- ✅ Provides migration path for rest

---

## 🎯 Success Criteria

1. ✅ Python installer works on macOS, Linux, WSL2
2. ✅ 100% component conversion success rate
3. ✅ Zero parsing errors during installation
4. ✅ All Codex prompts work as expected
5. ✅ Comprehensive documentation
6. ✅ Positive community feedback
7. ✅ <2 minutes installation time
8. ✅ Clear migration path from v3.x

---

## 📊 Estimated Effort

- **Python Installer**: 1 week (40 hours)
- **Conversion Engine**: 1 week (40 hours)
- **Codex Templates**: 1.5 weeks (60 hours)
- **Documentation**: 0.5 week (20 hours)
- **Testing & Polish**: 1 week (40 hours)

**Total**: ~4 weeks (200 hours)

---

## 🔄 Backward Compatibility

- ✅ Keep `install.sh` in `legacy/` folder
- ✅ Maintain existing `.claude/` structure
- ✅ `.factory/` unchanged for Droid CLI
- ✅ Existing users can opt-in to v4.0
- ✅ No breaking changes for Claude Code users

---

This spec creates a **production-ready, Python-based installer** that intelligently handles both Claude Code and Codex CLI with full compatibility checking and smart component conversion. Ready to proceed? 🚀