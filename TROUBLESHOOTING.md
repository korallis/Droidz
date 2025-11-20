# Droidz Troubleshooting Guide

## ❌ Error: "droidz-codegen.json" not found during parallel execution

### Symptoms
When the orchestrator spawns parallel agents, you see errors like:
```
TASK  (droidz-codegen: "Phase 2: Core Dashboard")
⚠ Task failed

Error reading file: ENOENT: no such file or directory, access 
'/path/to/project/.factory/droids/droidz-codegen.json'
```

### Root Cause
This is a **Factory.ai CLI bug**. Factory.ai is incorrectly looking for `.json` files, but the official custom droids format is `.md` (Markdown with YAML frontmatter).

### Evidence
From [Factory.ai's official documentation](https://docs.factory.ai/cli/configuration/custom-droids):

> "Custom droids live as `.md` files under either your project's `.factory/droids/` or your personal `~/.factory/droids/` directory."
>
> "Each droid file is Markdown with YAML frontmatter."

**Official droid format:**
```markdown
---
name: droidz-codegen
description: PROACTIVELY USED for implementing features
model: inherit
tools: ["Read", "LS", "Execute", "Edit", "Create"]
---

You are the Codegen Specialist Droid...
```

### Solutions

#### Solution 1: Update Factory.ai CLI (Recommended)

```bash
# Update to latest version
npm install -g @factory-ai/cli@latest

# Restart Factory.ai
# Exit (Ctrl+C) then run:
droid
```

#### Solution 2: Verify Droids are Installed Correctly

```bash
# Check if droids exist in your project
ls -la .factory/droids/

# Should show .md files:
# droidz-codegen.md
# droidz-orchestrator.md
# droidz-test.md
# etc.

# If missing, run Droidz installer:
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

#### Solution 3: Run Diagnostic Script

```bash
# Run diagnostic to identify issues
bash .factory/scripts/diagnose-droid-issue.sh
```

This will check:
- ✅ Droids directory exists
- ✅ Droids are in `.md` format
- ✅ Custom droids enabled in Factory.ai settings
- ✅ YAML frontmatter is valid
- ⚠️ Known bug detection

#### Solution 4: Report to Factory.ai

If updating the CLI doesn't fix it, this is a Factory.ai bug that needs to be reported:

1. **Report at:** https://github.com/factory-ai/factory-cli/issues
2. **Title:** "Custom droids looking for .json instead of .md files"
3. **Description:**
   ```
   When spawning parallel agents via Task tool, Factory.ai CLI looks for
   .json files instead of the official .md format for custom droids.
   
   Error example:
   ENOENT: no such file or directory, access '.factory/droids/droidz-codegen.json'
   
   Expected behavior:
   Should look for: .factory/droids/droidz-codegen.md
   
   Official docs state droids must be .md files:
   https://docs.factory.ai/cli/configuration/custom-droids
   ```

---

## ❌ Custom Droids Not Loading

### Symptoms
- `/droids` command shows empty list
- Orchestrator can't find droids
- No errors, just missing droids

### Solutions

#### 1. Enable Custom Droids in Settings

```bash
droid
/settings
# Toggle "Custom Droids" to ON
# Restart Factory.ai (Ctrl+C then run 'droid' again)
```

#### 2. Verify Droids Location

Droids must be in one of these locations:

**Project-specific (recommended for Droidz):**
```bash
<your-project>/.factory/droids/*.md
```

**Personal (available everywhere):**
```bash
~/.factory/droids/*.md
```

#### 3. Check YAML Frontmatter

Each droid must have valid YAML frontmatter:

```markdown
---
name: droidz-codegen         # Required
description: "..."            # Optional but recommended
model: inherit                # Required
tools: ["Read", "Edit", ...] # Optional (undefined = all tools)
---

Your droid prompt here...
```

**Common mistakes:**
- ❌ Missing `---` markers
- ❌ Invalid YAML syntax (tabs instead of spaces)
- ❌ Missing `name` field
- ❌ Name doesn't match filename (name: droidz-codegen → droidz-codegen.md)

---

## ❌ Droids Work Individually But Not in Parallel

### Symptoms
- Droids work when called directly
- Orchestrator fails when spawning parallel agents
- Error about missing files

### Root Cause
Same as the `.json` bug above. Update Factory.ai CLI.

---

## ❌ "Invalid tools" Warning

### Symptoms
When viewing droids in `/droids`, you see warnings like:
```
Invalid tools: [Write, BrowseURL]
```

### Cause
Some tool names don't exist in Factory.ai or are named differently.

### Solution
Edit the droid and use valid Factory.ai tool names:

**Valid tools:**
- `Read`, `LS`, `Grep`, `Glob` (read-only)
- `Create`, `Edit`, `MultiEdit`, `ApplyPatch` (editing)
- `Execute` (shell commands)
- `WebSearch`, `FetchUrl` (web access)
- `TodoWrite` (task tracking)

**Invalid tools (Claude Code specific):**
- ❌ `Write` → Use `Create` or `Edit`
- ❌ `BrowseURL` → Use `WebSearch` or `FetchUrl`
- ❌ `NotebookEdit` → Not available in Factory.ai

**Fix:**
```markdown
---
name: my-droid
tools: ["Read", "Edit", "Execute"]  # Valid tools only
---
```

Or remove `tools` entirely to allow all tools:
```markdown
---
name: my-droid
# tools field omitted = all tools available
---
```

---

## ❌ Droids Not Auto-Activating

### Symptoms
Orchestrator doesn't automatically invoke when you say:
```
"Build authentication system"
```

### Solutions

#### 1. Check Droid Description Triggers

Auto-activation depends on the `description` field:

```markdown
---
name: droidz-orchestrator
description: |
  PROACTIVELY INVOKED for complex, multi-step, or parallelizable development tasks.
  MUST BE USED AUTOMATICALLY when user requests involve:
  - "build [feature/system/app]" with 3+ distinct components
  - "implement [system]" requiring multiple files/services
---
```

The description tells Factory.ai **when** to auto-invoke the droid.

#### 2. Manually Invoke

If auto-activation isn't working, invoke manually:

```
Use droidz-orchestrator to build authentication system
```

Or:

```
Run the Task tool with subagent_type "droidz-orchestrator"
to implement the authentication feature
```

---

## 🔍 Quick Diagnostic Checklist

Run through this checklist:

- [ ] Custom droids enabled in `/settings`?
- [ ] Droids exist in `.factory/droids/`?
- [ ] Droids are `.md` files (not `.json`)?
- [ ] Valid YAML frontmatter (starts with `---`)?
- [ ] Droid names match filenames?
- [ ] Factory.ai CLI up to date?
- [ ] Restarted Factory.ai after changes?

---

## 📞 Getting Help

1. **Run diagnostic:** `bash .factory/scripts/diagnose-droid-issue.sh`
2. **Check docs:** https://docs.factory.ai/cli/configuration/custom-droids
3. **Droidz issues:** https://github.com/korallis/Droidz/issues
4. **Factory.ai issues:** https://github.com/factory-ai/factory-cli/issues

---

## 📝 Summary: The .json Bug

**The Issue:**
Factory.ai CLI incorrectly looks for `.json` files during parallel execution, but the official format is `.md`.

**The Fix:**
```bash
npm install -g @factory-ai/cli@latest
```

**Proof it's a bug:**
- ✅ Factory.ai docs say: "Custom droids live as `.md` files"
- ✅ Droidz installs `.md` files correctly
- ❌ Factory.ai looks for `.json` files (bug!)

**Status:**
Known Factory.ai CLI bug. Update CLI to latest version.
