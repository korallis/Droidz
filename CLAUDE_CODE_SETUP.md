# Droidz for Claude Code - Setup Guide

**Version**: 3.2.0  
**Target**: Claude Code (Anthropic's CLI tool)

---

## 📋 What You Get

Droidz provides Claude Code with:
- **15 specialist agents** for parallel execution
- **4 slash commands** for workflow orchestration  
- **Comprehensive validation** pipeline
- **Event hooks** for automation
- **Memory system** for persistent context

---

## 🚀 Installation

### Fresh Installation

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v3.3.2/install.sh | bash
```

When prompted, select:
```
Select installation:
  1) Droid CLI (Factory.ai)
  2) Claude Code (Anthropic)  ← Choose this

Choice: 2
```

### What Gets Installed

```
.claude/
├── agents/              # 15 specialist agents
│   ├── orchestrator.md
│   ├── codegen.md
│   ├── test.md
│   └── ... (12 more)
├── commands/            # 4 slash commands
│   ├── init.md
│   ├── build.md
│   ├── parallel.md
│   └── validate.md
├── skills/              # 61 auto-activating skills
│   ├── typescript/
│   ├── react/
│   ├── nextjs-16/
│   └── ... (58 more)
├── hooks/               # Event automation
│   └── scripts/
└── settings.json        # Configuration

CLAUDE.md               # Root instructions (auto-loaded)
config.yml              # Optional config
```

---

## ✅ Verification

After installation:

### 1. Restart Claude Code
```bash
# Exit current session
exit

# Start new session
claude
```

### 2. Check Agents
```bash
/agents
```

You should see 15 agents:
- orchestrator
- codegen
- test
- refactor
- infra
- integration
- ui-designer
- ux-designer
- accessibility-specialist
- database-architect
- api-designer
- performance-optimizer
- security-auditor
- generalist

### 3. Check Commands
```bash
/init
```

Should display the initialization command.

### 4. Check Skills
```bash
# Skills auto-activate based on context
# They're loaded automatically - no action needed
```

You should have **61 skills** available:
- TypeScript, React, Next.js, Vue
- PostgreSQL, Prisma, Drizzle
- TailwindCSS, GraphQL, tRPC
- And 51 more...

---

## 🎯 Usage

### Initialize Project
```bash
/init
```

Analyzes your project and sets up validation.

### Build Feature
```bash
/build "add user authentication"
```

Generates detailed spec with clarifying questions.

### Execute in Parallel
```bash
/parallel
```

Spawns multiple agents for 3-5x faster execution.

### Validate Everything
```bash
/validate
```

Runs 5-phase validation pipeline.

---

## 🤖 Using Agents

### Automatic Invocation

Claude Code automatically uses agents when appropriate:

```
You: "Build authentication system"

Claude: I'll use the orchestrator agent to break this into 
       parallel work streams...
       
       [Spawns 3 agents in parallel]
```

### Explicit Invocation

```
You: "Use the security-auditor agent to review auth.ts"

Claude: [Invokes security-auditor agent]
```

### Agent Capabilities

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **orchestrator** | Parallel coordination | Complex features (5+ files) |
| **codegen** | Feature implementation | New code, APIs, components |
| **test** | Test writing/fixing | Test failures, coverage gaps |
| **refactor** | Code quality | Tech debt, optimization |
| **security-auditor** | Security review | Pre-deployment checks |

---

## 🔧 Configuration

### .claude/settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "script": ".claude/hooks/scripts/block-dangerous.sh",
        "enabled": true
      }
    ],
    "PostToolUse": [
      {
        "script": ".claude/hooks/scripts/auto-lint.sh",
        "enabled": true,
        "tools": ["Edit", "Create"]
      }
    ]
  },
  "agents": {
    "defaultModel": "inherit",
    "allowCustomAgents": true
  }
}
```

### Optional: config.yml

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

## 📚 Key Differences from Droid CLI

| Feature | Droid CLI | Claude Code |
|---------|-----------|-------------|
| **Folder** | `.factory/` | `.claude/` |
| **Droids/Agents** | `.factory/droids/` | `.claude/agents/` |
| **Root Config** | `plugin.json` | `CLAUDE.md` |
| **Activation** | `/settings` toggle | Automatic on restart |
| **Commands** | Same | Same |
| **Hooks** | Same scripts | Different config |

---

## 🐛 Troubleshooting

### Agents Not Showing

```bash
# Check .claude/agents/ exists
ls .claude/agents/

# Restart Claude Code
exit
claude

# List agents
/agents
```

### Commands Not Working

```bash
# Check .claude/commands/ exists
ls .claude/commands/

# Verify CLAUDE.md exists
cat CLAUDE.md
```

### Hooks Not Running

```bash
# Check .claude/settings.json
cat .claude/settings.json

# Verify hook scripts have execute permissions
ls -la .claude/hooks/scripts/

# Fix permissions if needed
chmod +x .claude/hooks/scripts/*.sh
```

---

## 🚀 Next Steps

1. **Initialize your project**:
   ```bash
   /init
   ```

2. **Build something**:
   ```bash
   /build "add dark mode toggle"
   ```

3. **Explore agents**:
   ```bash
   /agents
   ```

4. **Read documentation**:
   - CLAUDE.md (auto-loaded)
   - .claude/agents/*.md (agent details)
   - .claude/commands/*.md (command docs)

---

## 💡 Tips

### 1. Use Parallel Execution for Complex Work

```
Bad:  "Build auth" → 60 min sequential
Good: "Build auth" → orchestrator → 20 min parallel (3x faster!)
```

### 2. Leverage Memory

Store decisions in `.factory/memory/org/`:
```bash
cat > .factory/memory/org/tech-decisions.md << 'EOF'
## Database Choice
Decision: PostgreSQL with Prisma
Rationale: Team familiarity, type safety
Date: 2025-11-22
EOF
```

Agents will read this automatically!

### 3. Validate Before Merging

```bash
/validate
```

Runs linting, type checking, tests - ensures quality.

---

## 🆘 Support

- **GitHub Issues**: [github.com/korallis/Droidz/issues](https://github.com/korallis/Droidz/issues)
- **Documentation**: [github.com/korallis/Droidz](https://github.com/korallis/Droidz)

---

**Happy building with Claude Code! 🚀**
