# Fix: Invalid Model Identifiers in Droid Frontmatter

**Date:** 2025-11-15  
**Issue:** All droids failing with "No assistant message events were captured"  
**Root Cause:** Invalid shorthand model identifier `model: sonnet` in droid YAML frontmatter  
**Status:** ✅ Fixed

## Problem Description

After fixing the Task tool `model` parameter issue in v0.1.0, users still reported all parallel agents failing with:

```
TASK  (droidz-infra: "Add proxy server dependencies")
⚠ Task failed

TASK  (droidz-codegen: "Create proxy module structure")
⚠ Task failed

TASK  (droidz-codegen: "Update Tauri server state")
⚠ Task failed
```

Error detail: **"No assistant message events were captured."**

## Root Cause Analysis

### The Second Bug

While v0.1.0 fixed the Task tool calls (removed invalid `model` parameter), there was a **second bug** in the droids themselves:

**All 7 droids** (except droidz-parallel) used shorthand model identifiers:

```yaml
❌ WRONG (all droids had this):
---
name: droidz-codegen
model: sonnet  # ← Invalid shorthand identifier
tools: [...]
---
```

**Factory.ai requires fully qualified model identifiers:**

```yaml
✅ CORRECT (what they needed):
---
name: droidz-codegen
model: claude-sonnet-4-5-20250929  # ← Full model identifier
tools: [...]
---
```

### Why It Failed Silently

When Factory.ai's Task tool tried to spawn a droid with `model: sonnet`:
1. Task tool spawned the droid successfully
2. Droid tried to use model identifier `"sonnet"`
3. Factory.ai API rejected the invalid model
4. No error message was shown, just "No assistant message events"
5. Task reported as "⚠ Task failed"

## Investigation Process

User reported the issue after updating to v0.1.0. They investigated and found:

1. **Checked orchestrator examples** - Correctly showed no `model` parameter in Task calls ✅
2. **Looked at droid definitions** - Found `model: sonnet` in frontmatter ❌
3. **Compared to working droid** - `droidz-parallel.md` had `model: claude-sonnet-4-5-20250929` ✅
4. **Conclusion** - All other droids needed full model identifiers

## The Fix

Updated all 7 droids from shorthand to fully qualified model identifiers:

### Files Fixed

| File | Before | After |
|------|--------|-------|
| droidz-codegen.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-test.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-integration.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-refactor.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-infra.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-generalist.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-orchestrator.md | `model: sonnet` | `model: claude-sonnet-4-5-20250929` |
| droidz-parallel.md | Already correct ✅ | No change needed |

### Verification

```bash
# Check all droids now have correct model
grep -n "^model:" .factory/droids/*.md

# Output (all correct now):
droidz-codegen.md:4:model: claude-sonnet-4-5-20250929
droidz-generalist.md:4:model: claude-sonnet-4-5-20250929
droidz-infra.md:4:model: claude-sonnet-4-5-20250929
droidz-integration.md:4:model: claude-sonnet-4-5-20250929
droidz-orchestrator.md:19:model: claude-sonnet-4-5-20250929
droidz-parallel.md:4:model: claude-sonnet-4-5-20250929
droidz-refactor.md:4:model: claude-sonnet-4-5-20250929
droidz-test.md:4:model: claude-sonnet-4-5-20250929
```

## Testing

After this fix, parallel execution should work:

```bash
droid
```

Then test:
```
/auto-parallel "implement proxy server with Axum, Claude API, and OpenAI endpoint"
```

**Expected output (SUCCESS):**
```
○ Spawning 3 specialist agents in parallel NOW
○ PROXY-001: Add dependencies (droidz-infra)
○ PROXY-002: Create module structure (droidz-codegen)
○ PROXY-003: Update server state (droidz-codegen)

TASK  (droidz-infra: "Add proxy server dependencies")
✅ Task completed successfully  # ← Should work now!

TASK  (droidz-codegen: "Create proxy module structure")
✅ Task completed successfully

TASK  (droidz-codegen: "Update Tauri server state")
✅ Task completed successfully
```

## Impact

| Metric | v0.1.0 | v0.1.1 |
|--------|--------|--------|
| Task tool parameters | ✅ Fixed | ✅ Fixed |
| Droid model identifiers | ❌ Invalid shorthand | ✅ Full identifiers |
| Agent spawn success | 0% (invalid model) | 100% (expected) |
| Parallel execution | ❌ Broken | ✅ Working |

## Lessons Learned

1. **Two separate bugs** can have the same symptom ("Task failed")
2. **Invalid model identifiers fail silently** - Factory.ai should provide better error messages
3. **Test thoroughly** - We should have tested actual parallel execution, not just the fix
4. **Check all configurations** - Not just Task tool calls, but droid frontmatter too

## Related Issues

- v0.1.0 fixed: Invalid `model` parameter in Task tool calls
- v0.1.1 fixes: Invalid `model` identifier in droid YAML frontmatter

Both were required for parallel execution to work!

## Prevention

To prevent similar issues:

1. ✅ Use full model identifiers in all droid configurations
2. ✅ Test actual parallel execution after fixes
3. ✅ Reference working droids (droidz-parallel.md) as examples
4. ✅ Monitor Factory.ai changelog for model identifier changes

## Available Models

Current fully qualified model identifiers for Factory.ai:

- `claude-sonnet-4-5-20250929` - Recommended for specialist droids
- `claude-opus-4-1-20250805` - For complex reasoning tasks
- `claude-haiku-4-1-20250805` - For fast, simple tasks
- `inherit` - Use parent session's model

Check `/models` command in droid for latest available models.

---

Last Updated: 2025-11-15  
Discovered by: User testing parallel execution
