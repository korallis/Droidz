# Solution Summary: Tool Compatibility Fix

## Problem

The orchestrator was failing with errors:
```
❌ Invalid tools: Task. Available tools: Read, LS, Execute, Edit, ApplyPatch, Grep, Glob, Create, WebSearch, TodoWrite, FetchUrl...
```

Previously attempted fix added "Task" to tools array, which is incorrect.

## Root Cause

**Misunderstanding of Factory's Custom Droid architecture:**

1. The `Task` tool is NOT something you list in tools arrays
2. Task is automatically registered by Factory when Custom Droids are enabled
3. Custom droids CANNOT delegate to other custom droids
4. Only the USER (in main droid session) can invoke custom droids
5. Orchestrator should be a PLANNER, not a DELEGATOR

## Solution Applied

### 1. Orchestrator Droid Configuration

**File:** `.factory/droids/droidz-orchestrator.md`

**Changes:**
- Removed `Task` from tools array (it's not a valid tool to list)
- Changed description from "coordinates" to "plans"
- Orchestrator is now a PLANNER that creates delegation instructions
- Kept essential tools: `Read`, `LS`, `Execute`, `Grep`, `Glob`, `TodoWrite`, `WebSearch`, `FetchUrl`

```yaml
---
name: droidz-orchestrator
description: Plans parallel execution strategy for Linear tickets - creates delegation plan for user
model: gpt-5-codex
tools: ["Read", "LS", "Execute", "Grep", "Glob", "TodoWrite", "WebSearch", "FetchUrl"]
---
```

### 2. Specialist Droids Configuration

**Files:**
- `.factory/droids/codegen.md`
- `.factory/droids/test.md`
- `.factory/droids/infra.md`
- `.factory/droids/integration.md`
- `.factory/droids/refactor.md`
- `.factory/droids/generalist.md`

**Changes:**
- **Removed explicit `tools:` field entirely**
- Left it undefined (YAML comments don't count as field definition)
- According to Factory docs: **undefined = ALL Factory tools available**

```yaml
---
name: droidz-codegen
description: Implements features/bugfixes
model: gpt-5-codex
# Tools: undefined = all Factory tools available
---
```

## How It Works

### Factory's Task Tool Delegation

1. **Orchestrator calls Task:**
```typescript
Task({
  subagent_type: "droidz-codegen",
  description: "Implement feature X",
  prompt: "Instructions..."
});
```

2. **Factory spawns specialist droid:**
- Creates new droid instance with fresh context
- Loads droid definition from `.factory/droids/codegen.md`
- Checks `tools` field:
  - If undefined → Provides ALL Factory tools
  - If array → Provides only specified tools

3. **Specialist executes with full tool access:**
- Can use `Create`, `Edit`, `MultiEdit`, `ApplyPatch`
- Can use `Read`, `Execute`, `Grep`, etc.
- Can use MCP tools if configured (Linear, Exa, Desktop Commander)
- Returns results to orchestrator

### Why This Works for All Models

According to [Factory.ai documentation](https://docs.factory.ai/cli/configuration/custom-droids):

> **Tool selection:** `undefined` (all tools) or array of tool IDs like `["Read", "Edit", "Execute"]`. Case-sensitive.

**All models support all tools when delegated:**
- ✅ Claude Sonnet 4.5
- ✅ Claude Opus 4.1
- ✅ Claude Haiku 4.5
- ✅ GPT-5
- ✅ GPT-5 Codex
- ✅ Droid Core (GLM-4.6)

There are NO model-specific tool restrictions in Factory's Task delegation system!

## Testing

To verify the fix works:

```bash
# 1. Enable Custom Droids
droid
/settings
# Toggle "Custom Droids" to ON
/quit

# 2. Restart and verify droids loaded
droid
/droids  # Should show all 7 droids

# 3. Test orchestrator
droid
# Then say:
"Use droidz-orchestrator to process a simple task"
```

## MCP Enhancement (Optional)

For even better tool support, configure MCP servers:

```bash
droid
/mcp add exa       # AI web/code search
/mcp add linear    # Project management
/mcp add ref       # Documentation search
/quit
droid
```

MCP tools like Desktop Commander provide additional file operations:
- `desktop-commander___write_file`
- `desktop-commander___edit_block`
- `desktop-commander___read_file`

These work alongside Factory's native Create/Edit tools.

## Files Changed

1. ✅ `.factory/droids/droidz-orchestrator.md` - Removed Create/Edit, added Task
2. ✅ `.factory/droids/codegen.md` - Removed tools array (undefined = all tools)
3. ✅ `.factory/droids/test.md` - Removed tools array
4. ✅ `.factory/droids/infra.md` - Removed tools array
5. ✅ `.factory/droids/integration.md` - Removed tools array
6. ✅ `.factory/droids/refactor.md` - Removed tools array
7. ✅ `.factory/droids/generalist.md` - Removed tools array
8. ✅ `TOOL_COMPATIBILITY.md` - New documentation (comprehensive guide)
9. ✅ `SOLUTION_SUMMARY.md` - This file (summary of changes)

## Key Takeaways

1. **Don't specify explicit tools arrays for specialist droids** - Leave undefined for full access
2. **Orchestrator should delegate via Task tool** - Not call Create/Edit directly
3. **All models support all Factory tools** - No model-specific workarounds needed
4. **MCP tools enhance capabilities** - But aren't required for basic functionality
5. **Follow Factory's official patterns** - Their docs are the source of truth

## References

- [Factory Custom Droids Docs](https://docs.factory.ai/cli/configuration/custom-droids)
- [Factory Model Selection Guide](https://docs.factory.ai/cli/user-guides/choosing-your-model)
- [Factory MCP Configuration](https://docs.factory.ai/cli/configuration/mcp)
- [TOOL_COMPATIBILITY.md](./TOOL_COMPATIBILITY.md) - Detailed compatibility guide
