# ✅ Factory Documentation Verification Complete

## Summary

All Droidz documentation has been verified and corrected against **official Factory documentation**.

---

## 🔍 Sources Verified

### Official Factory Documentation
1. **CLI Reference**: https://docs.factory.ai/cli/configuration/cli-reference
2. **Custom Droids**: https://docs.factory.ai/cli/configuration/custom-droids
3. **Autonomy Levels**: https://docs.factory.ai/cli/configuration/cli-reference#autonomy-levels

---

## ✅ Corrections Made

### 1. Installation Command

**INCORRECT (Before):**
```bash
npm install -g @factory-ai/cli
```

**CORRECT (After):**
```bash
curl -fsSL https://app.factory.ai/cli | sh
```

**Source**: [Factory CLI Installation Docs](https://docs.factory.ai/cli/configuration/cli-reference#installation)

---

### 2. Starting Factory CLI

**INCORRECT (Before):**
```bash
droid --auto high
```

**CORRECT (After):**
```bash
droid
```

**Why**: The `--auto` flag is **only for `droid exec`** (non-interactive mode), not for the interactive `droid` command.

**Source**: [Factory CLI Flags](https://docs.factory.ai/cli/configuration/cli-reference#cli-flags)

#### Official Documentation States:

> **CLI commands**
> - `droid` - Start interactive REPL
> - `droid exec` - Execute task without interactive mode
>
> **Autonomy levels**
> `droid exec` uses tiered autonomy to control what operations the agent can perform.
>
> | Flag | Description | Example |
> |------|-------------|---------|
> | `--auto <level>` | Set autonomy level (`low`, `medium`, `high`) | `droid exec --auto medium "run tests"` |

**Key Point**: Notice `--auto` is in the `droid exec` examples, **not** the interactive `droid` examples.

---

### 3. Custom Droids Setup

**VERIFIED CORRECT** ✅

Our instructions match official documentation:

```bash
# 1. Start Factory
droid

# 2. In Factory, type:
/settings

# 3. Enable "Custom Droids" (Experimental feature)

# 4. Restart Factory
# Exit (Ctrl+C or /quit)
# Then start again:
droid

# 5. Verify droids loaded:
/droids
```

**Source**: [Custom Droids Quick Start](https://docs.factory.ai/cli/configuration/custom-droids#quick-start)

---

### 4. Custom Droids Format

**VERIFIED CORRECT** ✅

Our `.md` file format matches official spec:

```markdown
---
name: droid-name
description: What the droid does
model: inherit
tools: ["Read", "Edit", "Execute"]
---

System prompt goes here...
```

**Source**: [Custom Droids Configuration](https://docs.factory.ai/cli/configuration/custom-droids#configuration)

---

### 5. Task Tool Delegation

**VERIFIED CORRECT** ✅

Our orchestrator uses Task tool properly:

```typescript
Task({
  subagent_type: "droidz-codegen",
  description: "Implement PROJ-123",
  prompt: `[full context]`
})
```

**Source**: [Custom Droids - Using Effectively](https://docs.factory.ai/cli/configuration/custom-droids#using-custom-droids-effectively)

Official docs state:
> "Invoke via the Task tool – when custom droids are enabled, the droid may call it autonomously, or you can request it directly"

---

### 6. Invoking Custom Droids

**VERIFIED CORRECT** ✅

Our instructions match official guidance:

```
Use droidz-orchestrator to process project "MyProject" sprint "Sprint-5"
```

**Source**: [Custom Droids Examples](https://docs.factory.ai/cli/configuration/custom-droids#examples)

Official example:
> "Run the subagent `code-reviewer` on the staged diff."

---

## 📊 Verification Summary

| Item | Status | Source |
|------|--------|--------|
| Installation command | ✅ CORRECTED | CLI Reference |
| `droid` command | ✅ CORRECTED | CLI Reference |
| `--auto` flag usage | ✅ CORRECTED | CLI Flags |
| Custom droids setup | ✅ VERIFIED | Custom Droids |
| Droid file format | ✅ VERIFIED | Custom Droids |
| Task tool delegation | ✅ VERIFIED | Custom Droids |
| Invoking droids | ✅ VERIFIED | Custom Droids |

---

## 📝 Files Updated

1. **README.md**
   - Fixed installation command
   - Fixed all `droid --auto high` → `droid`
   - Verified custom droids instructions

2. **QUICK_START_V2.md**
   - Fixed all `droid --auto high` → `droid`
   - Updated migration section (V2-only)
   - Removed V1 references

---

## 🔍 What `--auto` Actually Does

According to official docs, `--auto` is for **headless execution** only:

### For `droid exec` (headless/CI/CD):

```bash
# Default (read-only)
droid exec "Analyze the auth system"

# Low autonomy - safe edits
droid exec --auto low "Add comments"

# Medium autonomy - development
droid exec --auto medium "Install deps, run tests"

# High autonomy - deployment
droid exec --auto high "Run tests, commit, push"
```

### For `droid` (interactive):

```bash
# Just start it - no flags needed
droid

# Then talk to it naturally
> "Use droidz-orchestrator to build my app"
```

**Autonomy in interactive mode** is controlled through Settings (`/settings`), not command-line flags.

---

## ✅ All Documentation Now Accurate

Every Factory-specific command and instruction in Droidz documentation has been:

1. ✅ **Verified** against official Factory docs
2. ✅ **Corrected** where necessary
3. ✅ **Committed** to repository
4. ✅ **Pushed** to GitHub

---

## 📚 Reference Links

- **Factory CLI Reference**: https://docs.factory.ai/cli/configuration/cli-reference
- **Custom Droids Guide**: https://docs.factory.ai/cli/configuration/custom-droids
- **Factory Quickstart**: https://docs.factory.ai/cli/getting-started/quickstart
- **Video Walkthrough**: https://docs.factory.ai/cli/getting-started/video-walkthrough

---

**Verification Date**: 2025-01-10  
**Verified By**: Thorough comparison with official Factory documentation  
**Status**: ✅ All commands and instructions now 100% accurate
