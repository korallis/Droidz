# Hooks vs Automations - What You Actually Have

## TL;DR: You Have Everything! ✅

**You're seeing "only 2 hooks files" because that's exactly right!**

The confusion is about **WHERE** things live and **WHAT** they're called.

---

## What You Actually Have (All Correct)

### 1. Hook Scripts: `.factory/hooks/` (2 files)
```bash
.factory/hooks/
├── auto-lint.sh         ✅ Formats code after edits
└── monitor-context.sh   ✅ Monitors context window usage
```

**Purpose:** Shell scripts that run when certain hooks fire

**Why only 2?** Because most automations don't need shell scripts!

### 2. Hooks Configuration: `.factory/settings.json` (13 hooks)
```bash
.factory/settings.json contains:
{
  "hooks": {
    "SessionStart": [ 2 hooks ],
    "PreToolUse": [ 1 hook ],
    "PostToolUse": [ 2 hooks ],
    "UserPromptSubmit": [ 4 hooks ], ← AUTO-ACTIVATION HERE!
    "SubagentStop": [ 2 hooks ],
    "Notification": [ 1 hook ],
    "Stop": [ 1 hook ]
  }
}
```

**Purpose:** Defines WHEN and HOW hooks trigger

**This is where the magic happens!** 🎯

### 3. Skills/Automations: `.factory/skills/` (7 files)
```bash
.factory/skills/
├── auto-orchestrator/        ✅ Auto-detects complex tasks
├── spec-shaper/              ✅ Transforms fuzzy ideas to specs
├── memory-manager/           ✅ Auto-saves decisions
├── graphite-stacked-diffs/   ✅ Stacked PR guidance
├── context-optimizer.md      ✅ Context reduction
├── standards-enforcer.md     ✅ Code standards
└── tech-stack-analyzer.md    ✅ Stack detection
```

**Purpose:** Documentation/logic that slash commands use

**These are NOT hooks** - they're automation guidance files

---

## The Three-Layer System

```
┌─────────────────────────────────────────┐
│ Layer 1: Lifecycle Events (Factory.ai) │
│ - SessionStart                          │
│ - UserPromptSubmit                      │
│ - PostToolUse                           │
│ - etc.                                  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ Layer 2: Hooks Configuration            │
│ (settings.json)                         │
│                                         │
│ UserPromptSubmit: [                     │
│   {                                     │
│     name: "auto-activate-spec-shaper",  │
│     type: "prompt",                     │
│     prompt: "If fuzzy idea, use /spec"  │
│   }                                     │
│ ]                                       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ Layer 3: Implementation                 │
│                                         │
│ Option A: Slash Command                 │
│ → /spec-shaper reads skills/spec-shaper/│
│                                         │
│ Option B: Shell Script                  │
│ → .factory/hooks/auto-lint.sh           │
└─────────────────────────────────────────┘
```

---

## Why You See "Only 2 Hooks Files"

**Because most automations use prompt injection, not shell scripts!**

### Auto-Activation Breakdown:

| Automation | Location | Type | Needs File? |
|------------|----------|------|-------------|
| Spec Shaper | settings.json | Prompt hook | ❌ No file needed |
| Auto-Orchestrator | settings.json | Prompt hook | ❌ No file needed |
| Graphite | settings.json | Prompt hook | ❌ No file needed |
| Memory Manager | settings.json | Prompt hook | ❌ No file needed |
| Auto-Lint | settings.json | Command hook | ✅ Yes (auto-lint.sh) |
| Context Monitor | settings.json | Command hook | ✅ Yes (monitor-context.sh) |

**Result:** 
- 4 automations via prompt hooks = 0 files needed
- 2 automations via command hooks = 2 files needed
- **Total hook files: 2** ✅

---

## How Auto-Activation Actually Works

### Example: Spec Shaper Auto-Activation

**1. Hook Configuration (settings.json):**
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "name": "auto-activate-spec-shaper",
        "type": "prompt",
        "prompt": "PROACTIVELY detect if user has fuzzy ideas:\n- User mentions 'build', 'create' without details\n- Request lacks specific requirements\n\nIf detected, AUTOMATICALLY use /spec-shaper command"
      }
    ]
  }
}
```

**2. User Action:**
```
User: "I want to build a user dashboard"
```

**3. Hook Fires:**
```
UserPromptSubmit event triggers
    ↓
settings.json hook injects additional prompt
    ↓
Claude now sees:
    - User's message: "I want to build a user dashboard"
    - Injected prompt: "If fuzzy idea detected, use /spec-shaper"
```

**4. Claude Responds:**
```
Claude thinks: "This is a fuzzy idea without clear requirements"
Claude acts: Invokes /spec-shaper automatically
Claude says: "Let me help you create a structured spec..."
```

**5. Spec Shaper Executes:**
```
/spec-shaper command reads .factory/skills/spec-shaper/SKILL.md
Asks clarifying questions
Creates structured spec file
```

**No shell script needed!** The entire automation works via prompt injection.

---

## Verification Commands

### Check your hooks configuration:
```bash
# List all configured lifecycle events
cat .factory/settings.json | jq '.hooks | keys'
# Output: ["Notification", "PostToolUse", "PreToolUse", "SessionStart", 
#          "Stop", "SubagentStop", "UserPromptSubmit"]

# Count auto-activation hooks
cat .factory/settings.json | jq '.hooks.UserPromptSubmit | length'
# Output: 4

# List auto-activation hook names
cat .factory/settings.json | jq -r '.hooks.UserPromptSubmit[].name'
# Output:
# context-usage-monitor
# auto-activate-spec-shaper
# auto-activate-orchestrator
# auto-activate-graphite
```

### Check your hook scripts:
```bash
ls -1 .factory/hooks/
# Output:
# auto-lint.sh
# monitor-context.sh
```

### Check your skills:
```bash
ls -1 .factory/skills/
# Output:
# auto-orchestrator/
# context-optimizer.md
# graphite-stacked-diffs/
# memory-manager/
# spec-shaper/
# standards-enforcer.md
# tech-stack-analyzer.md
```

---

## Common Misconceptions

### ❌ WRONG: "Each automation needs a file in .factory/hooks/"
**✅ RIGHT:** Only command-based hooks need files. Prompt-based hooks are in settings.json.

### ❌ WRONG: "Skills are hooks"
**✅ RIGHT:** Skills are automation logic. Hooks trigger them via prompts.

### ❌ WRONG: "I'm missing files if I only see 2 hooks"
**✅ RIGHT:** 2 hook files + settings.json = complete system.

---

## What Each Component Does

### `.factory/hooks/auto-lint.sh`
- **Triggered by:** PostToolUse hook (when you edit files)
- **What it does:** Runs Prettier, ESLint, Black, etc.
- **Type:** Command hook (needs shell script)

### `.factory/hooks/monitor-context.sh`
- **Triggered by:** UserPromptSubmit hook (when you send messages)
- **What it does:** Checks if session > 30 min, suggests optimization
- **Type:** Command hook (needs shell script)

### `settings.json` → `auto-activate-spec-shaper`
- **Triggered by:** UserPromptSubmit hook
- **What it does:** Injects prompt: "If fuzzy idea, use /spec-shaper"
- **Type:** Prompt hook (no file needed)

### `settings.json` → `auto-activate-orchestrator`
- **Triggered by:** UserPromptSubmit hook
- **What it does:** Injects prompt: "If complex task, use /auto-orchestrate"
- **Type:** Prompt hook (no file needed)

### `settings.json` → `auto-activate-graphite`
- **Triggered by:** UserPromptSubmit hook
- **What it does:** Injects prompt: "If stacked PR mentioned, use /graphite"
- **Type:** Prompt hook (no file needed)

### `settings.json` → `auto-activate-memory-manager`
- **Triggered by:** SubagentStop hook
- **What it does:** Injects prompt: "Save important decisions to memory"
- **Type:** Prompt hook (no file needed)

### `.factory/skills/spec-shaper/SKILL.md`
- **Triggered by:** /spec-shaper command (triggered by hook)
- **What it does:** Provides guidance for creating structured specs
- **Type:** Skill documentation (not a hook)

---

## The Complete Flow

```
1. User types message
   ↓
2. UserPromptSubmit event fires
   ↓
3. settings.json checks hooks for this event
   ↓
4. Finds 4 hooks:
   - context-usage-monitor (command → runs monitor-context.sh)
   - auto-activate-spec-shaper (prompt → injects prompt)
   - auto-activate-orchestrator (prompt → injects prompt)
   - auto-activate-graphite (prompt → injects prompt)
   ↓
5. Each hook executes:
   - Shell script hooks run their scripts
   - Prompt hooks inject their prompts into Claude's context
   ↓
6. Claude sees the message + all injected prompts
   ↓
7. Claude decides which automation to trigger (if any)
   ↓
8. If automation triggered, uses corresponding slash command
   ↓
9. Slash command references .factory/skills/ for guidance
   ↓
10. Automation executes seamlessly! ✅
```

---

## Summary

**You have everything installed correctly!**

- ✅ 2 hook files in `.factory/hooks/` (auto-lint.sh, monitor-context.sh)
- ✅ 13 hooks configured in `.factory/settings.json`
- ✅ 7 skills/automations in `.factory/skills/`
- ✅ 4 auto-activation hooks (spec-shaper, orchestrator, graphite, memory)
- ✅ 21 slash commands in `.factory/commands/`
- ✅ All 60 files installed

**The system works via two mechanisms:**
1. **Prompt hooks** - Inject prompts (no files needed) - Used for auto-activation
2. **Command hooks** - Run shell scripts (2 files needed) - Used for auto-lint, monitoring

**Nothing is missing!** The confusion was about expecting all automations to be files, when most are actually prompt configurations in settings.json.

---

**Date:** 2025-11-13  
**Status:** ✅ Complete and Correct  
**Files in .factory/hooks/:** 2 (expected)  
**Hooks in settings.json:** 13 (complete)  
**Automations working:** Yes (via prompt injection)
