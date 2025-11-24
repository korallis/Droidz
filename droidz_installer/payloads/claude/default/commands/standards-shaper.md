# Standards Shaper - Create Project Standards

You are helping me establish comprehensive project standards that will guide all development work. These standards will include detailed dos and don'ts, best practices, patterns, and conventions.

## Overview

This command uses all available tools and research capabilities to create detailed, well-researched standards documents organized by category (global, frontend, backend, etc.).

**Tools Used**:
- Read, Write, Edit, Grep, Glob for file operations
- Exa Code Context for technical research (if available)
- Ref Documentation Search for framework docs (if available)
- Execute for environment checks

**Note**: This command gracefully handles missing MCP tools - if exa or ref aren't installed, it will continue using general knowledge and existing project patterns.

## Multi-Phase Process

Follow these phases IN SEQUENCE:

### PHASE 1: Analyze Current Project

First, understand the current project structure and tech stack.

#### Step 1.1: Check for existing standards

Look for existing standards in these locations:
- `droidz/standards/` (primary location)
- `.claude/` or `.factory/` configuration
- Project root for framework indicators

```bash
# Check what exists
ls droidz/standards/ 2>/dev/null || echo "No standards directory yet"
```

#### Step 1.2: Detect tech stack

Analyze the project to determine tech stack:

**Check for indicators**:
- `package.json` → Node.js, frameworks (React, Next.js, Vue, etc.)
- `requirements.txt` or `pyproject.toml` → Python, Django, FastAPI
- `Gemfile` → Ruby on Rails
- `go.mod` → Go
- `Cargo.toml` → Rust
- `composer.json` → PHP
- Database config files → PostgreSQL, MySQL, MongoDB, etc.

Use Glob to find these files:
```
Glob: ["package.json", "requirements.txt", "pyproject.toml", "Gemfile", "go.mod", "Cargo.toml", "composer.json"]
```

#### Step 1.3: Check for MCP tools availability

Attempt to use research tools but don't fail if unavailable:

**Try Exa Code Context** (gracefully handle if not available):
```
Try: exa code context query about detected framework
If fails: Continue without external research
```

**Try Ref Documentation** (gracefully handle if not available):
```
Try: ref search for detected framework best practices
If fails: Continue without external docs
```

**Output to user**:
```
🔍 Project Analysis:

Tech Stack Detected:
- [List detected technologies]

Research Tools Available:
✅ Exa Code Context: [Available/Not Available]
✅ Ref Documentation: [Available/Not Available]

[If tools unavailable, add: "Continuing with general best practices and framework knowledge"]
```

### PHASE 2: Ask User for Standards Scope

Present options to user and wait for response:

```
I'll help you create comprehensive project standards. Let me know your preference:

📋 STANDARDS SCOPE OPTIONS:

1. **Full Standards Suite** (Recommended for new projects)
   - Global standards (coding principles, error handling, testing, security)
   - Frontend standards (components, styling, state management)
   - Backend standards (API design, database, authentication)
   - Infrastructure standards (deployment, monitoring, CI/CD)

2. **Minimal Standards** (Quick start)
   - Global coding principles only
   - Framework-specific basics

3. **Custom Selection**
   - Choose specific categories you want

4. **Update Existing**
   - Enhance/update your current standards with research

Which option would you like? [1-4]
```

Wait for user's choice before proceeding.

### PHASE 3: Research Best Practices

Based on detected tech stack and user's scope choice, research best practices.

#### Step 3.1: Use available research tools

**If Exa is available**, research:
```
Query 1: "[Framework] best practices patterns 2024"
Query 2: "[Framework] coding standards conventions"
Query 3: "[Framework] testing patterns examples"
Query 4: "[Framework] security best practices"
```

**If Ref is available**, search:
```
Query 1: "[Framework] official documentation coding standards"
Query 2: "[Framework] style guide best practices"
```

#### Step 3.2: Analyze existing codebase

Use Grep to find existing patterns:
```
- Component patterns: Grep "export (default )?(function|const|class)"
- Error handling: Grep "try|catch|throw|error"
- Testing patterns: Grep "describe|test|it\(|expect"
- API patterns: Grep "api|endpoint|route"
```

### PHASE 4: Generate Standards Documents

Create comprehensive standards files based on research and project analysis.

#### Step 4.1: Create directory structure

```
droidz/standards/
├── README.md
├── global/
│   ├── coding-principles.md
│   ├── error-handling.md
│   ├── testing.md
│   ├── security.md
│   └── performance.md
├── frontend/          [if frontend detected]
│   ├── components.md
│   ├── styling.md
│   ├── state-management.md
│   └── routing.md
├── backend/           [if backend detected]
│   ├── api-design.md
│   ├── database.md
│   ├── authentication.md
│   └── error-responses.md
└── infrastructure/    [if scope includes it]
    ├── deployment.md
    ├── ci-cd.md
    └── monitoring.md
```

#### Step 4.2: Standards Document Format

Each standard file should follow this format:

```markdown
# [Standard Name]

## Overview

[Brief description of what this standard covers]

## When to Apply

- [Situation 1]
- [Situation 2]
- [Situation 3]

## Core Principles

1. **[Principle Name]**
   - [Explanation]
   - [Why it matters]

2. **[Principle Name]**
   - [Explanation]
   - [Why it matters]

## ✅ DO

### [Category 1]

**✅ DO**: [Good practice]
```[language]
// Good example
[code showing good practice]
```

**✅ DO**: [Another good practice]
```[language]
// Good example
[code]
```

### [Category 2]

[More DO examples...]

## ❌ DON'T

### [Category 1]

**❌ DON'T**: [Bad practice]
```[language]
// Bad example
[code showing what to avoid]
```
**Why**: [Explanation of why this is bad]

**❌ DON'T**: [Another bad practice]
```[language]
// Bad example
[code]
```
**Why**: [Explanation]

### [Category 2]

[More DON'T examples...]

## Patterns & Examples

### Pattern 1: [Pattern Name]

**Use Case**: [When to use this pattern]

**Implementation**:
```[language]
// Complete working example
[full code example]
```

**Explanation**:
- [Key point 1]
- [Key point 2]

### Pattern 2: [Pattern Name]

[More patterns...]

## Common Mistakes

1. **[Mistake 1]**
   - Problem: [What goes wrong]
   - Solution: [How to fix]
   - Example: [Code]

2. **[Mistake 2]**
   - Problem: [What goes wrong]
   - Solution: [How to fix]

## Testing Standards

[Testing requirements for this standard's domain]

## Resources

- [Official docs]
- [Community resources]
- [Tools and linters]
```

#### Step 4.3: Generate content for each standard

For each standard file, include:

1. **Research-backed content** (if tools available)
2. **Framework-specific patterns** (from detected tech stack)
3. **Project-specific patterns** (from codebase analysis)
4. **Concrete examples** (with actual code)
5. **Clear dos and don'ts** (with explanations)

### PHASE 5: Create README.md

Create `droidz/standards/README.md`:

```markdown
# Project Standards

This directory contains comprehensive coding standards, best practices, and conventions for this project.

## Purpose

These standards ensure:
- **Consistency**: All code follows same patterns
- **Quality**: Best practices enforced
- **Maintainability**: Code is easy to understand and modify
- **Collaboration**: Team has shared conventions

## Standards Categories

### Global Standards

Apply to all code in this project:

- **[coding-principles.md](global/coding-principles.md)** - Core coding principles
- **[error-handling.md](global/error-handling.md)** - Error handling patterns
- **[testing.md](global/testing.md)** - Testing requirements and patterns
- **[security.md](global/security.md)** - Security best practices

### Frontend Standards

[List frontend standards if applicable]

### Backend Standards

[List backend standards if applicable]

### Infrastructure Standards

[List infrastructure standards if applicable]

## How to Use

### For Developers

1. **Read relevant standards** before starting work
2. **Reference during development** to ensure compliance
3. **Update standards** when discovering new patterns

### For AI Assistants

Standards are automatically:
- Loaded during task orchestration (`/orchestrate-tasks`)
- Referenced during implementation (`/implement-tasks`)
- Enforced during code generation

### For Code Review

Use standards as checklist:
- [ ] Follows coding principles
- [ ] Proper error handling
- [ ] Has tests
- [ ] Security considerations addressed

## Tech Stack

This project uses:
[Auto-generated list from detection]

## Standards Version

Last Updated: [Date]
Droidz Version: [Version]

## Maintenance

Standards should be updated when:
- New patterns emerge in codebase
- Framework best practices change
- Team learns better approaches
- New team members have questions
```

### PHASE 6: Inform User

Output to user:

```
✅ Project standards created successfully!

📁 Standards Location: droidz/standards/

📋 Created Standards:

Global:
  ✅ coding-principles.md - [X lines, Y examples]
  ✅ error-handling.md - [X lines, Y examples]
  ✅ testing.md - [X lines, Y examples]
  ✅ security.md - [X lines, Y examples]

[List other categories created]

📊 Research Used:
  [✅/❌] Exa Code Context - [X queries]
  [✅/❌] Ref Documentation - [X docs]
  ✅ Codebase Analysis - [X patterns found]
  ✅ Framework Knowledge - [Framework name]

💡 Next Steps:

1. Review the standards in droidz/standards/
2. Customize any sections for your team's specific needs
3. Run `/plan-product` to define your product vision
4. Standards will automatically guide all future development

🔗 Workflow Guide: droidz/standards/RECOMMENDED_WORKFLOW.md
```

## Error Handling

### If MCP tools not available:
```
ℹ️ Note: Exa and Ref tools not available
   Using general best practices and framework knowledge
   Standards will still be comprehensive and useful
```

### If tech stack not detected:
```
⚠️ Could not auto-detect tech stack
   
Please specify:
1. Frontend framework (React, Vue, Angular, etc.)
2. Backend framework (Express, Django, Rails, etc.)
3. Database (PostgreSQL, MongoDB, etc.)
```

### If directory exists:
```
⚠️ Standards directory already exists!

Options:
1. Update existing standards (merge new research)
2. Create backup and regenerate
3. Cancel

Your choice: [1-3]
```

## Implementation Notes

**Key Points**:
- Use all available tools (Read, Write, Grep, Glob, Execute)
- Try exa and ref but continue if unavailable
- Analyze existing codebase for current patterns
- Generate concrete, actionable examples
- Include clear dos and don'ts
- Make standards searchable and referenceable
- Link to official documentation
- Keep standards maintainable (not too verbose)

**Quality Checks**:
- Each standard should have 5+ DO examples
- Each standard should have 5+ DON'T examples
- All examples should be runnable code
- Explanations should be clear and concise
- Patterns should be framework-specific when applicable
