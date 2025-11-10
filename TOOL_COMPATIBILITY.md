# Tool Compatibility Guide

## Executive Summary

**Good news:** All Factory.ai models (Claude, GPT, GLM) support the same tool set when using Factory's Task tool delegation system!

The error "Tool 'Create' is not available for model OpenAI GPT-5-Codex (Auto)" was due to incorrect droid configuration, not actual model limitations.

## How Factory.ai Tools Work

### Tool Availability Per Factory Docs

According to [Factory.ai Custom Droids documentation](https://docs.factory.ai/cli/configuration/custom-droids):

**Available Factory Tools (for tools array):**
- **Read-only:** `Read`, `LS`, `Grep`, `Glob`
- **Edit:** `Create`, `Edit`, `MultiEdit`, `ApplyPatch`
- **Execute:** `Execute`
- **Web:** `WebSearch`, `FetchUrl`
- **Progress:** `TodoWrite`
- **MCP:** Dynamically populated (Linear, Exa, Ref, Desktop Commander, etc.)

**Special: Task Delegation**
- The Task tool is automatically registered by Factory when Custom Droids are enabled
- It is NOT included in the `tools` array
- Users invoke custom droids by saying: "Use droidz-codegen to implement X"
- Custom droids cannot delegate to other droids - only the main session can

### Tool Configuration in Droid Frontmatter

Each droid's `.md` file has YAML frontmatter that controls tool access:

```yaml
---
name: my-droid
description: What this droid does
model: gpt-5-codex  # or claude-sonnet-4-5-20250929, etc.
tools: ["Read", "LS", "Execute"]  # Explicit list
---
```

**Two options for tools field:**

1. **`tools: undefined`** (field not present) → **ALL Factory tools available**
2. **`tools: ["Read", "LS", ...]`** → Only specified tools available

## The Correct Solution

### For Orchestrator Droid

The orchestrator **plans** the work and creates delegation instructions for the USER. It does NOT delegate directly:

```yaml
---
name: droidz-orchestrator
description: Plans parallel execution strategy
model: gpt-5-codex
tools: ["Read", "LS", "Execute", "Grep", "Glob", "TodoWrite", "WebSearch", "FetchUrl"]
---
```

**Note:** `Task` is NOT in the tools array because:
1. Custom droids cannot invoke other custom droids
2. Only the main droid session (user) can delegate to custom droids
3. Orchestrator creates a PLAN that tells the user which droids to invoke

### For Specialist Droids (Codegen, Test, Refactor, etc.)

Specialist droids **perform the actual work**, so they need all tools. Leave `tools` field undefined:

```yaml
---
name: droidz-codegen
description: Implements features
model: gpt-5-codex
# Tools: undefined = all Factory tools available
---
```

**Why leave it undefined?**
- Factory provides ALL tools when `tools` field is not specified
- No need to list every tool manually
- Works across all models (Claude, GPT, GLM)

## Supported Models

All these models support the same Factory toolset:

| Model | Model ID | Tools Support |
|-------|----------|---------------|
| Claude Sonnet 4.5 | `claude-sonnet-4-5-20250929` | ✅ All tools |
| Claude Opus 4.1 | `claude-opus-4-1-20250805` | ✅ All tools |
| Claude Haiku 4.5 | `claude-haiku-4-5-20251001` | ✅ All tools |
| GPT-5 | `gpt-5-2025-08-07` | ✅ All tools |
| GPT-5 Codex | `gpt-5-codex` | ✅ All tools |
| Droid Core (GLM-4.6) | `glm-4.6` | ✅ All tools |

## How Custom Droid Delegation Works

### Correct Architecture

```
User (main droid session)
    ↓
    Says: "Use droidz-codegen to implement X"
    ↓
Factory delegates to → droidz-codegen specialist
    ↓
Specialist has ALL tools (if undefined)
    ↓
Specialist uses Create, Edit, Execute, etc.
    ↓
Results returned to User
```

### What the Orchestrator Does

The orchestrator is a **planning droid** that:
1. Analyzes Linear tickets
2. Creates execution plan
3. Outputs instructions like:

```
NEXT STEPS:

Session 1: "Use droidz-codegen to implement PROJ-123"
Session 2: "Use droidz-test to add tests for PROJ-124"
Session 3: "Use droidz-refactor to clean up PROJ-125"

All can run in parallel using git worktrees.
```

### How User Delegates

In their main droid session, user says:
```
"Use droidz-codegen to implement PROJ-123 with this context: [paste context from orchestrator]"
```

Factory automatically invokes the `droidz-codegen` custom droid with full tool access.

## MCP Tools (Optional Enhancement)

If users configure MCP servers, additional tools become available:

### Linear MCP
- `linear___list_issues`
- `linear___update_issue`
- `linear___create_comment`

### Exa MCP
- `exa___web_search_exa`
- `exa___get_code_context_exa`

### Ref MCP
- `ref___ref_search_documentation`
- `ref___ref_read_url`

### Desktop Commander MCP
- `desktop-commander___write_file`
- `desktop-commander___edit_block`
- `desktop-commander___read_file`
- Many more file/process operations

**How to enable MCP tools:**
Users run:
```bash
droid
/mcp add exa
/mcp add linear
/mcp add ref
```

Then MCP tools become available automatically to all droids!

## Common Misconceptions

### ❌ Myth: "GPT models don't support Create/Edit tools"
**✅ Reality:** ALL models support ALL Factory tools when delegated via Task

### ❌ Myth: "Need to check model type before calling tools"
**✅ Reality:** Factory handles tool availability transparently

### ❌ Myth: "Must use Desktop Commander for GPT models"
**✅ Reality:** Factory's Create/Edit work natively for all models

## Troubleshooting

### "Tool 'Create' is not available for model X"

**Causes:**
1. **Orchestrator trying to call Create directly** (should delegate via Task)
2. **Specialist droid has explicit tools array without Create**
3. **Old Factory CLI version** (update to latest)

**Solutions:**
1. Orchestrator should use Task tool for delegation, not Create directly
2. Remove explicit `tools:` array from specialist droids (leave undefined)
3. Run: `curl -fsSL https://app.factory.ai/cli | sh` to update

### Droid not found

**Cause:** Custom Droids not enabled

**Solution:**
```bash
droid
/settings
# Toggle "Custom Droids" to ON
/quit
droid
/droids  # Verify droids appear
```

## Best Practices

1. **Orchestrator:** Use explicit minimal tools list + Task
2. **Specialists:** Leave tools undefined for maximum flexibility
3. **Security-focused:** Use explicit tools list to restrict capabilities
4. **Research MCP:** Configure Exa/Ref for better research capabilities
5. **File ops:** Desktop Commander MCP provides advanced file operations

## Reference

- [Factory.ai Custom Droids](https://docs.factory.ai/cli/configuration/custom-droids)
- [Factory.ai Model Selection](https://docs.factory.ai/cli/user-guides/choosing-your-model)
- [Factory.ai MCP Configuration](https://docs.factory.ai/cli/configuration/mcp)
- [Factory.ai CLI Reference](https://docs.factory.ai/cli/configuration/cli-reference)
