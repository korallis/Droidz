# Factory.ai Droid CLI vs Claude Code - Usage Comparison

## TL;DR: Very Similar UX, Different Under the Hood

**The user experience is 95% identical**, but there are some key differences in how you invoke features and what happens behind the scenes.

---

## Side-by-Side Comparison

### 1. Starting a Session

**Claude Code:**
```bash
claude
```

**Factory.ai Droid CLI:**
```bash
droid
```

**Difference:** Just a different command name. Everything else works the same.

---

### 2. Using Custom Droids/Agents

**Claude Code:**
```
You: "Build an authentication system"

Claude: [Automatically invokes codegen agent via Task tool]
        Running codegen agent in isolated worktree...
```

**Factory.ai Droid CLI:**
```
You: "Build an authentication system"

Droid: [Automatically invokes droidz-codegen via Task tool]
       Running droidz-codegen in isolated worktree...
```

**Difference:** 
- ✅ Same auto-invocation behavior
- ✅ Same Task tool mechanism
- ✅ Same isolation via worktrees
- ⚠️ Different tool names internally (Execute vs Bash)
- ⚠️ Must enable "Custom Droids" in settings first

---

### 3. Slash Commands

**Claude Code:**
```
/agents           # List available agents
/task             # Manually invoke an agent
/commands         # List custom commands
```

**Factory.ai Droid CLI:**
```
/droids           # List available droids
/task             # Same - manually invoke a droid
/commands         # Same - list custom commands
```

**Difference:**
- ✅ Same functionality
- ⚠️ `/agents` renamed to `/droids`
- ✅ All custom commands work identically

---

### 4. Auto-Activation Skills

**Claude Code (.claude/skills/):**
```
.claude/
├── skills/
│   ├── spec-shaper.md       # Auto-activates for fuzzy ideas
│   ├── auto-orchestrator.md # Auto-activates for complex tasks
│   └── memory-manager.md    # Auto-activates after completion
```

**Factory.ai Droid CLI (.factory/skills/):**
```
.factory/
├── skills/
│   ├── spec-shaper/SKILL.md       # Auto-activates for fuzzy ideas
│   ├── auto-orchestrator/SKILL.md # Auto-activates for complex tasks
│   └── memory-manager/SKILL.md    # Auto-activates after completion
```

**How it works:**
- ✅ Same auto-activation triggers (fuzzy ideas, complex tasks, etc.)
- ✅ Same seamless UX (no user action needed)
- ⚠️ Factory.ai uses `settings.json` hooks instead of skill files for activation
- ⚠️ Skills are documentation/guidance, hooks do the triggering

**Example flow (both versions work the same way):**

```
You: "I want to build a dashboard"
    ↓
Auto-activation detects fuzzy idea
    ↓
Automatically uses /spec-shaper
    ↓
Guides you through spec creation
```

---

### 5. MCP Server Integration

**Claude Code:**
```bash
# Add MCP server
claude mcp add linear

# Auto-discovers and configures
```

**Factory.ai Droid CLI:**
```bash
# Add MCP server
droid mcp add linear

# Or via interactive UI
droid
/mcp
```

**Difference:**
- ✅ Same MCP protocol support
- ✅ Same servers available (Linear, Exa, Ref, etc.)
- ✅ Same authentication flows
- ⚠️ Factory.ai has interactive `/mcp` UI (better UX)

---

### 6. Memory Management

**Claude Code:**
```
.claude/
├── memory/
│   ├── org/     # Team decisions
│   └── user/    # Personal preferences
```

**Factory.ai Droid CLI:**
```
.factory/
├── memory/
│   ├── org/     # Team decisions
│   └── user/    # Personal preferences
```

**Usage (identical):**
```bash
# Save decision
/save-decision architecture "Using microservices"

# Load memory
/load-memory org
```

**Difference:** ✅ No difference - works identically

---

### 7. Settings Configuration

**Claude Code (~/.claude/settings.json):**
```json
{
  "model": "sonnet",
  "autonomyLevel": "auto-medium",
  "cloudSessionSync": true
}
```

**Factory.ai Droid CLI (~/.factory/settings.json):**
```json
{
  "model": "sonnet",
  "autonomyLevel": "auto-medium", 
  "cloudSessionSync": true,
  "hooks": {
    "UserPromptSubmit": [...]
  }
}
```

**Difference:**
- ✅ Same settings available
- ✅ Same `/settings` UI for configuration
- ➕ Factory.ai adds `hooks` configuration for auto-activation
- ⚠️ Different file location (~/.factory vs ~/.claude)

---

### 8. Orchestration & Parallel Execution

**Claude Code:**
```bash
# Orchestrate from Linear
/orchestrate linear:"sprint:current"

# Creates worktrees
# Spawns agents in parallel
# Uses 'claude exec --auto medium'
```

**Factory.ai Droid CLI:**
```bash
# Orchestrate from Linear  
/orchestrate linear:"sprint:current"

# Creates worktrees
# Spawns droids in parallel
# Uses 'droid exec --auto medium'
```

**Difference:**
- ✅ Same orchestration logic
- ✅ Same worktree isolation
- ✅ Same tmux sessions
- ⚠️ Uses `droid exec` instead of `claude exec`

---

### 9. Tool Names (Internal Difference)

**Claude Code Agents:**
```yaml
tools: ["Read", "Bash", "Write", "Edit", "Grep", "Glob", "Task"]
```

**Factory.ai Droids:**
```yaml
tools: ["Read", "Execute", "Create", "Edit", "Grep", "Glob", "Task", "WebSearch", "FetchUrl"]
```

**Mapping:**
| Claude Code | Factory.ai | Purpose |
|-------------|------------|---------|
| `Bash` | `Execute` | Run shell commands |
| `Write` | `Create` | Create new files |
| - | `LS` | List directory contents |
| - | `WebSearch` | Search the web |
| - | `FetchUrl` | Fetch URL content |
| `Task` | `Task` | Invoke subagents (same) |

**User Impact:** ✅ None - handled internally by droids

---

### 10. Enabling Custom Droids/Agents

**Claude Code:**
```bash
claude
# Custom agents auto-discovered from .claude/agents/
# No enable step needed
```

**Factory.ai Droid CLI:**
```bash
droid
/settings
# Toggle "Custom Droids" ON (experimental feature)
# Restart droid
```

**Difference:**
- ⚠️ Factory.ai requires enabling in settings first
- ⚠️ Marked as "experimental" feature
- ✅ Once enabled, works identically

---

## Key Differences Summary

### What's Different:

1. **Command name** - `droid` vs `claude`
2. **Settings location** - `~/.factory/` vs `~/.claude/`
3. **Tool names** - `Execute`/`Create` vs `Bash`/`Write`
4. **Droids must be enabled** - Requires toggling experimental setting
5. **Hooks in settings.json** - Factory.ai uses settings.json for auto-activation
6. **Interactive MCP UI** - Factory.ai has `/mcp` command for easier management

### What's the Same:

1. ✅ **Auto-activation** - Skills trigger automatically
2. ✅ **Slash commands** - All custom commands work
3. ✅ **Memory management** - Same org/user memory
4. ✅ **Orchestration** - Same parallel execution
5. ✅ **MCP integration** - Same servers and protocols
6. ✅ **Spec-driven development** - Same workflow
7. ✅ **Git worktree isolation** - Same mechanism
8. ✅ **User experience** - 95% identical

---

## Usage Examples (Side by Side)

### Example 1: Build a Feature

**Claude Code:**
```
You: Build user authentication with OAuth

Claude: [Detects complexity, auto-activates orchestrator]
        Breaking into parallel tasks...
        - codegen: OAuth integration (worktree 1)
        - codegen: Login UI (worktree 2)  
        - test: Integration tests (worktree 3)
        
        Spawning 3 agents in parallel via 'claude exec --auto medium'
```

**Factory.ai Droid CLI:**
```
You: Build user authentication with OAuth

Droid: [Detects complexity, auto-activates orchestrator]
       Breaking into parallel tasks...
       - droidz-codegen: OAuth integration (worktree 1)
       - droidz-codegen: Login UI (worktree 2)
       - droidz-test: Integration tests (worktree 3)
       
       Spawning 3 droids in parallel via 'droid exec --auto medium'
```

**Result:** ✅ Identical user experience

---

### Example 2: Fuzzy Idea to Spec

**Claude Code:**
```
You: I want some kind of notification system

Claude: [Auto-activates spec-shaper skill]
        Let me help create a structured spec...
        
        1. What types of notifications? (email, push, in-app)
        2. Who receives them? (users, admins, specific roles)
        3. What triggers them? (events, schedules, manual)
```

**Factory.ai Droid CLI:**
```
You: I want some kind of notification system

Droid: [Auto-activates spec-shaper skill via hooks]
       Let me help create a structured spec...
       
       1. What types of notifications? (email, push, in-app)
       2. Who receives them? (users, admins, specific roles)
       3. What triggers them? (events, schedules, manual)
```

**Result:** ✅ Identical user experience

---

### Example 3: Using MCP Servers

**Claude Code:**
```bash
# Setup
claude mcp add linear

# Usage in session
You: Update LINEAR-123 to "In Progress"

Claude: [Uses Linear MCP]
        Updated LINEAR-123 status to "In Progress" ✓
```

**Factory.ai Droid CLI:**
```bash
# Setup
droid mcp add linear
# Or: droid → /mcp → Add linear

# Usage in session
You: Update LINEAR-123 to "In Progress"

Droid: [Uses Linear MCP]
       Updated LINEAR-123 status to "In Progress" ✓
```

**Result:** ✅ Identical user experience

---

## Migration Path

If you're coming from Claude Code:

### 1. Install Factory.ai Droid CLI
```bash
npm install -g @factory-ai/droid-cli
# or
brew install factory-ai/tap/droid
```

### 2. Install Droidz for Factory.ai
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
```

### 3. Enable Custom Droids
```bash
droid
/settings
# Toggle "Custom Droids" ON
# Restart droid
```

### 4. Verify
```bash
droid
/droids  # Should see all 7 droids
/commands  # Should see all 21 commands
```

### 5. Use Exactly the Same Way
```
You: Build authentication system
     ↓
Droid works exactly like Claude did!
```

---

## Performance Comparison

| Feature | Claude Code | Factory.ai Droid CLI | Winner |
|---------|-------------|----------------------|--------|
| **Auto-activation** | ✅ Yes | ✅ Yes | Tie |
| **Parallel execution** | ✅ 3-5x faster | ✅ 3-5x faster | Tie |
| **Custom agents/droids** | ✅ Auto-discovered | ⚠️ Must enable first | Claude Code |
| **MCP integration** | ✅ CLI only | ✅ CLI + Interactive UI | Factory.ai |
| **Settings management** | ✅ JSON only | ✅ JSON + Interactive UI | Factory.ai |
| **Cloud sync** | ❌ No | ✅ Yes (sessions sync to web) | Factory.ai |
| **Tool variety** | Good | Better (WebSearch, FetchUrl built-in) | Factory.ai |

---

## What You Get with Factory.ai Edition

### Advantages over Claude Code:

1. **Cloud session sync** - Access sessions from web
2. **Interactive MCP UI** - Easier server management via `/mcp`
3. **Interactive settings UI** - Easier config via `/settings`
4. **Built-in WebSearch/FetchUrl** - No MCP needed for web research
5. **Better tool variety** - More tools available to droids
6. **Active development** - Factory.ai is actively maintained

### Trade-offs:

1. **Extra setup step** - Must enable Custom Droids in settings
2. **Experimental flag** - Custom Droids marked experimental
3. **Different tool names** - Internal difference (doesn't affect users)

---

## Real-World Usage Patterns

### Pattern 1: Daily Development

**Both versions:**
```bash
# Start session
droid  # or claude

# Work normally
"Add user profile page"
  → Auto-activates appropriate droid/agent
  → Implements feature
  → Runs tests
  → Creates PR

# Review work
/droids  # or /agents to see what ran
```

**Experience:** ✅ Identical

---

### Pattern 2: Sprint Planning

**Both versions:**
```bash
# Start orchestration
/orchestrate linear:"sprint:current"
  → Fetches 10 tickets
  → Creates 10 worktrees
  → Spawns 10 droids/agents in parallel
  → Completes sprint in 1/3 the time
```

**Experience:** ✅ Identical

---

### Pattern 3: Learning/Research

**Claude Code:**
```
You: How do I implement JWT auth in Next.js?

Claude: [Searches internally or asks to use Exa MCP]
        Here's how...
```

**Factory.ai Droid CLI:**
```
You: How do I implement JWT auth in Next.js?

Droid: [Uses built-in WebSearch automatically]
       Here's how...
```

**Experience:** ✅ Factory.ai slightly smoother (WebSearch built-in)

---

## Bottom Line

### For Users:

**95% identical experience.** You interact with Factory.ai Droid CLI exactly like Claude Code:
- Same commands (just `/droids` instead of `/agents`)
- Same auto-activation
- Same orchestration
- Same memory management
- Same MCP integration

### For Framework Developers:

**Different internals.** Droidz for Factory.ai uses:
- Different tool names (Execute/Create vs Bash/Write)
- `settings.json` hooks for auto-activation
- Factory.ai's experimental Custom Droids feature

### Should You Switch?

**Yes, if you want:**
- ✅ Cloud session sync
- ✅ Interactive UI for MCP/settings
- ✅ Built-in WebSearch/FetchUrl
- ✅ Active Factory.ai development

**Stick with Claude Code if:**
- ✅ You prefer stable, non-experimental features
- ✅ You don't need cloud sync
- ✅ You're happy with current setup

---

## Common Questions

**Q: Can I use both versions simultaneously?**

A: Yes! They use different directories (`.factory/` vs `.claude/`) so they don't conflict.

**Q: Will my Claude Code agents work with Factory.ai?**

A: Yes! Factory.ai has an import feature (`/droids` → Import) that converts Claude Code agents to Factory.ai droids automatically.

**Q: Is performance the same?**

A: Yes, identical. Both use the same git worktree + parallel execution architecture.

**Q: Which should I use for new projects?**

A: Factory.ai Droid CLI - it's actively developed and has more features (cloud sync, interactive UI).

---

**Date:** 2025-11-13  
**Status:** ✅ Complete Comparison  
**Recommendation:** Factory.ai for new projects, both work great
