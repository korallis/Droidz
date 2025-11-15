# Fix: Use Model Inheritance Instead of Hardcoded Models

**Date:** 2025-11-15  
**Issue:** Droids force specific model (Claude Sonnet) regardless of user's CLI session model  
**Root Cause:** Hardcoded `model: claude-sonnet-4-5-20250929` instead of `model: inherit`  
**Status:** ✅ Fixed

## Problem Description

When users had GPT-5 Codex (or other models) selected in their Factory.ai droid CLI session, all spawned droids would still use Claude Sonnet 4.5 because the model was hardcoded in the droid frontmatter.

This prevented users from:
- Using their preferred model (GPT-5 Codex, Claude Opus, etc.)
- Taking advantage of model-specific features
- Controlling costs by using cheaper models when appropriate

## User Impact

**User reported:**
> "What happens if in the droid CLI the user has a specific model selected like GPT-5.1 codex? We don't want to specify a model. It should just use whatever model is selected in the droid CLI."

This is correct! Users should be able to choose their model in the CLI, and droids should respect that choice.

## Root Cause

All 8 droids had hardcoded model identifiers in v0.1.1:

```yaml
❌ WRONG (v0.1.1):
---
name: droidz-codegen
model: claude-sonnet-4-5-20250929  # ← Hardcoded!
tools: [...]
---
```

This overrode the user's CLI model selection.

## The Fix

According to [Factory.ai documentation](https://docs.factory.ai/cli/configuration/custom-droids#4-%C2%B7-configuration):

> **model**: `inherit` (use parent session's model), or specify a model identifier.

All Factory.ai examples use `model: inherit`:

```yaml
✅ CORRECT (v0.1.2):
---
name: droidz-codegen
model: inherit  # ← Inherits user's CLI model selection
tools: [...]
---
```

### How It Works

With `model: inherit`:

| User's CLI Model | Droids Use |
|-----------------|------------|
| GPT-5 Codex | GPT-5 Codex |
| Claude Opus 4.1 | Claude Opus 4.1 |
| Claude Haiku 4.1 | Claude Haiku 4.1 |
| Any custom model | That custom model |

This gives users **full control** over which model powers their parallel execution!

## Research Process

Used `exa-code` and `ref` MCP tools to research Factory.ai documentation:

### Key Findings

1. **Factory.ai Example Droids** - All official examples use `model: inherit`:
   ```yaml
   # code-reviewer example
   model: inherit
   
   # security-sweeper example
   model: inherit
   
   # task-coordinator example
   model: inherit
   ```

2. **Model Field Documentation:**
   > `model`: `inherit` (use parent session's model), or specify a model identifier.

3. **Recommendation:**
   > Choose models strategically – use `inherit` to match the parent session, or specify a different model for specialized tasks.

## Files Fixed

Updated all 8 droids to use `model: inherit`:

| Droid | Before | After |
|-------|--------|-------|
| droidz-codegen.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-test.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-integration.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-refactor.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-infra.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-generalist.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-orchestrator.md | `claude-sonnet-4-5-20250929` | `inherit` |
| droidz-parallel.md | `claude-sonnet-4-5-20250929` | `inherit` |

## Verification

```bash
# Check all droids now use inherit
grep -n "^model:" .factory/droids/*.md

# Output (all correct):
droidz-codegen.md:4:model: inherit
droidz-generalist.md:4:model: inherit
droidz-infra.md:4:model: inherit
droidz-integration.md:4:model: inherit
droidz-orchestrator.md:19:model: inherit
droidz-parallel.md:4:model: inherit
droidz-refactor.md:4:model: inherit
droidz-test.md:4:model: inherit
```

## User Experience

### Before (v0.1.1)
```bash
# User starts droid with GPT-5 Codex
droid --model gpt-5-codex

# Runs parallel task
/auto-parallel "implement feature"

# Problem: All droids use Claude Sonnet (not GPT-5 Codex!)
○ TASK-001 running with Claude Sonnet  # ← Wrong model!
○ TASK-002 running with Claude Sonnet  # ← Wrong model!
```

### After (v0.1.2)
```bash
# User starts droid with GPT-5 Codex
droid --model gpt-5-codex

# Runs parallel task
/auto-parallel "implement feature"

# Fixed: All droids use GPT-5 Codex (user's choice!)
○ TASK-001 running with GPT-5 Codex  # ← Correct!
○ TASK-002 running with GPT-5 Codex  # ← Correct!
```

## When to Override `inherit`

Factory.ai docs suggest you can still specify a different model for specialized tasks:

```yaml
---
name: fast-summarizer
model: claude-haiku-4-1-20250805  # Use fast/cheap model for summaries
tools: ["Read"]
---
```

**Use cases for model override:**
- **Cheaper models** for simple tasks (summaries, formatting)
- **Faster models** when speed matters more than quality
- **Specialized models** that excel at specific tasks

**But for general-purpose droids** (like ours), `model: inherit` is the right choice!

## Testing

After updating, users can test model inheritance:

```bash
# Start with specific model
droid --model gpt-5-codex

# Check /models command shows GPT-5 Codex selected
/models

# Run parallel task
/auto-parallel "implement auth system"

# Droids should all use GPT-5 Codex
```

Verify in the task output - it should show the model name for each spawned droid.

## Benefits

✅ **User Control** - Users choose which model powers their work  
✅ **Flexibility** - Works with GPT-5, Claude, custom models, etc.  
✅ **Cost Management** - Users can select cheaper models when appropriate  
✅ **Future-Proof** - New models automatically work without updating droids  
✅ **Factory.ai Best Practice** - Follows official documentation patterns  

## Related Documentation

- Factory.ai Custom Droids: https://docs.factory.ai/cli/configuration/custom-droids
- Model Configuration Field: Search for "model: inherit" in official examples
- Previous fixes:
  - v0.1.0: Fixed Task tool model parameter
  - v0.1.1: Fixed droid model identifiers (shorthand → full)
  - v0.1.2: Fixed model inheritance (hardcoded → inherit)

## Prevention

To ensure droids respect user model selection:

1. ✅ Always use `model: inherit` for general-purpose droids
2. ✅ Only override model for specific performance/cost optimizations
3. ✅ Reference Factory.ai official examples when creating new droids
4. ✅ Test with different models to verify inheritance works

---

Last Updated: 2025-11-15  
Discovered by: User testing with GPT-5 Codex  
Researched using: exa-code and ref MCP tools per Factory.ai documentation
