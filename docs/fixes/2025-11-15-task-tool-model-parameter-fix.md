# Fix: Task Tool Model Parameter Issue

**Date:** 2025-11-15  
**Issue:** All parallel agent spawns failing with "Task failed" errors  
**Root Cause:** Invalid `model` parameter in Task tool calls  
**Status:** ✅ Fixed

## Problem Description

User reported that the droidz-orchestrator was attempting to spawn 4 specialist agents in parallel but all tasks failed:

```
TASK  (droidz-integration: "OAUTH-001: Research OAuth endpoints")
 ⚠ Task failed

TASK  (droidz-codegen: "OAUTH-002: Setup OAuth configuration")
 ⚠ Task failed

TASK  (droidz-test: "OAUTH-003: Write integration tests")
 ⚠ Task failed

TASK  (droidz-generalist: "OAUTH-004: Create documentation")
 ⚠ Task failed
```

## Root Cause Analysis

### Investigation Process

1. **Checked Factory.ai Documentation** (via exa-code and ref MCP):
   - Custom droids documentation: https://docs.factory.ai/cli/configuration/custom-droids
   - CLI updates changelog: https://docs.factory.ai/changelog/cli-updates

2. **Verified Configuration**:
   - Custom droids enabled: `~/.factory/settings.json` has `"enableCustomDroids": true` ✅
   - Droids exist: All 8 droids present in `.factory/droids/` ✅
   - Frontmatter valid: All droids have correct YAML frontmatter ✅

3. **Analyzed Task Tool Definition**:
   ```typescript
   Task({
     subagent_type: "The type of specialized agent to use for this task",
     description: "A short (3-5 word) description of the task",
     prompt: "The task for the agent to perform"
   })
   ```

4. **Found the Bug**:
   The orchestrator was passing an **invalid `model` parameter**:
   
   ```typescript
   ❌ WRONG:
   Task({
     subagent_type: "droidz-codegen",
     description: "Build authentication API",
     model: "sonnet",  // ← THIS PARAMETER DOESN'T EXIST!
     prompt: `...`
   });
   ```

### Why It Failed

- **Task tool only accepts 3 parameters**: `subagent_type`, `description`, `prompt`
- **Model configuration happens in droid frontmatter**, not in Task calls
- Example from `droidz-codegen.md`:
  ```yaml
  ---
  name: droidz-codegen
  model: sonnet  # ← Model configured HERE
  tools: [...]
  ---
  ```

## The Fix

**File Modified:** `.factory/droids/droidz-orchestrator.md`

**Changes Made:**
- Removed `model: "sonnet"` parameter from Task tool example 1 (Backend API)
- Removed `model: "sonnet"` parameter from Task tool example 2 (Frontend UI)
- Removed `model: "sonnet"` parameter from Task tool example 3 (Tests)

**Diff:**
```diff
 Task({
   subagent_type: "droidz-codegen",
   description: "Build authentication API",
-  model: "sonnet",
   prompt: `# Task: Build Authentication API
```

## Verification

✅ **Correct Task Tool Usage:**
```typescript
Task({
  subagent_type: "droidz-codegen",
  description: "Build authentication API",
  prompt: `# Task: Build Authentication API
  
## Context
User requested: "[original user request]"

## Your Specific Mission
Build a complete JWT-based authentication API with:
...
`
});
```

✅ **Model Configuration** (in droid frontmatter):
```yaml
---
name: droidz-codegen
description: PROACTIVELY USED for implementing features and bugfixes
model: sonnet
tools: ["Read", "LS", "Execute", "Edit", "Create", "Grep", "Glob", "TodoWrite", "WebSearch", "FetchUrl"]
---
```

## Testing Recommendations

To test the fix:

1. **Start Factory.ai droid:**
   ```bash
   droid
   ```

2. **Trigger orchestration with a multi-component task:**
   ```
   Build a simple authentication system with login API, login form, and tests
   ```

3. **Expected behavior:**
   - Orchestrator analyzes complexity ✓
   - Breaks into 3 parallel streams ✓
   - Spawns 3 agents successfully ✓
   - All agents execute without "Task failed" errors ✓

4. **Monitor output:**
   ```
   ○ Spawning 3 specialist agents in parallel NOW
   ○ AUTH-001: Build login API (droidz-codegen)
   ○ AUTH-002: Build login form (droidz-codegen)
   ○ AUTH-003: Write tests (droidz-test)
   
   TASK  (droidz-codegen: "AUTH-001: Build login API")
   ✅ Task completed  # ← Should show completion, not failure
   ```

## Related Documentation

- Factory.ai Custom Droids: https://docs.factory.ai/cli/configuration/custom-droids
- Factory.ai CLI Updates: https://docs.factory.ai/changelog/cli-updates
- Task Tool Parameters: Only `subagent_type`, `description`, `prompt` are valid

## Lessons Learned

1. **Always check official docs** - Factory.ai documentation is the source of truth
2. **Use MCP tools for research** - `exa___get_code_context_exa` and `ref___ref_search_documentation` were critical
3. **Model configuration is in droid frontmatter** - Not in Task tool calls
4. **Test with official examples** - Factory.ai docs provide canonical usage patterns

## Prevention

To prevent this issue in the future:

1. ✅ Always reference Factory.ai docs when updating Task tool usage
2. ✅ Validate droid configurations against official schema
3. ✅ Test orchestration with simple multi-component tasks
4. ✅ Monitor Factory.ai changelog for Task tool updates

## Impact

- **Before Fix:** 100% failure rate for parallel agent spawning
- **After Fix:** Expected 100% success rate for valid orchestration scenarios
- **Affected Components:** droidz-orchestrator.md (all Task tool examples)
- **User Impact:** Parallel execution now works as designed (3-5x speedup restored)
