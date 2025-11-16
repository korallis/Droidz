---
name: using-droidz
description: Use when starting any conversation - establishes mandatory workflows for finding and using skills in the Droidz/Factory.ai system, including reading skills before usage, following brainstorming before coding, and creating TodoWrite todos for checklists
category: workflow
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST read the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Getting Started with Droidz Skills

## MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message, you MUST complete this checklist:

1. ☐ List available skills in `.factory/skills/`
2. ☐ Ask yourself: "Does ANY skill match this request?"
3. ☐ If yes → Read the skill file from `.factory/skills/`
4. ☐ Announce which skill you're using
5. ☐ Follow the skill exactly

**Responding WITHOUT completing this checklist = automatic failure.**

## Critical Rules

1. **Follow mandatory workflows.** Brainstorming before coding. Check for relevant skills before ANY task.

2. **Skills auto-load based on code context.** Factory.ai automatically loads production-ready guidance when you work with specific technologies:
   - Writing Next.js code → Next.js 16 skill (1,053 lines)
   - Supabase queries → Supabase skill (963 lines of RLS, Auth)
   - Tailwind classes → Tailwind v4 skill (963 lines)
   - TypeScript → TypeScript skill (871 lines)
   - React components → React skill (2,232 lines)
   - Prisma/Drizzle → Database skills (2,072 / 1,992 lines)
   - And 15+ more comprehensive skills (31,296 lines total)

3. **Use Droidz features for complex work:**
   - `/droidz-build` - AI-powered spec generator (vague ideas → production specs)
   - `/auto-parallel` - Parallel execution with specialist droids (3-5x faster)
   - `droidz-orchestrator` - Task decomposition and coordination

## Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these thoughts, STOP. You are rationalizing. Check for and use the skill.

- "This is just a simple question" → WRONG. Questions are tasks. Check for skills.
- "I can check git/files quickly" → WRONG. Files don't have conversation context. Check for skills.
- "Let me gather information first" → WRONG. Skills tell you HOW to gather information. Check for skills.
- "This doesn't need a formal skill" → WRONG. If a skill exists for it, use it.
- "I remember this skill" → WRONG. Skills evolve. Read the current version from `.factory/skills/`.
- "This doesn't count as a task" → WRONG. If you're taking action, it's a task. Check for skills.
- "The skill is overkill for this" → WRONG. Skills exist because simple things become complex. Use it.
- "I'll just do this one thing first" → WRONG. Check for skills BEFORE doing anything.

**Why:** Skills document proven techniques that save time and prevent mistakes. Not using available skills means repeating solved problems and making known errors.

If a skill for your task exists, you must use it or you will fail at your task.

## Skills with Checklists

If a skill has a checklist, YOU MUST create TodoWrite todos for EACH item.

**Don't:**
- Work through checklist mentally
- Skip creating todos "to save time"
- Batch multiple items into one todo
- Mark complete without doing them

**Why:** Checklists without TodoWrite tracking = steps get skipped. Every time. The overhead of TodoWrite is tiny compared to the cost of missing steps.

## Announcing Skill Usage

Before using a skill, announce that you are using it.
"I'm using [Skill Name] to [what you're doing]."

**Examples:**
- "I'm using the brainstorming skill to refine your idea into a design."
- "I'm using the test-driven-development skill to implement this feature."
- "I'm using the React skill to ensure proper hooks usage and component patterns."

**Why:** Transparency helps your human partner understand your process and catch errors early. It also confirms you actually read the skill.

# About Droidz Skills

**Many skills contain rigid rules (TDD, debugging, verification).** Follow them exactly. Don't adapt away the discipline.

**Some skills are flexible patterns (architecture, naming).** Adapt core principles to your context.

The skill itself tells you which type it is.

## How Factory.ai Loads Skills

Factory.ai automatically detects which skills apply based on:
- **Code context**: Files you're reading/editing trigger relevant tech skills
- **File types**: `.tsx` → React skill, `schema.prisma` → Prisma skill
- **Imports**: `import { useQuery }` → Tanstack Query skill
- **Task type**: Bug fixing → systematic-debugging, feature work → brainstorming

You don't configure this - it just works. Focus on following the loaded skills.

## Instructions ≠ Permission to Skip Workflows

Your human partner's specific instructions describe WHAT to do, not HOW.

"Add X", "Fix Y" = the goal, NOT permission to skip brainstorming, TDD, or RED-GREEN-REFACTOR.

**Red flags:** "Instruction was specific" • "Seems simple" • "Workflow is overkill"

**Why:** Specific instructions mean clear requirements, which is when workflows matter MOST. Skipping process on "simple" tasks is how simple tasks become complex problems.

## When to Use Droidz Features

### `/droidz-build` - AI-Powered Spec Generation

**Use when:**
- Vague requirements → need comprehensive spec
- User says "add authentication" without details
- Building complex features that need scoping

**Process:**
1. Asks clarifying questions (OAuth vs email/password? JWT vs sessions?)
2. Generates production-ready spec in `.droidz/specs/`
3. Covers: acceptance criteria, edge cases, testing, security

### `/auto-parallel` - Parallel Execution

**Use when:**
- Multiple independent tasks (3-5 tasks)
- Each task can run in parallel
- Want 3-5x faster execution

**How it works:**
- Spawns specialist droids: `droidz-codegen`, `droidz-test`, `droidz-refactor`
- Each works independently on assigned task
- Coordinator synthesizes results

### Workflow Skills

Available in `.factory/skills/`:
- `brainstorming.md` - Ideas → designs before coding
- `test-driven-development.md` - RED-GREEN-REFACTOR workflow
- `systematic-debugging.md` - Root cause analysis
- `subagent-driven-development.md` - When to spawn specialists
- `verification-before-completion.md` - Quality gates
- `finishing-a-development-branch.md` - PR checklist

## Summary

**Starting any task:**
1. If relevant skill exists in `.factory/skills/` → Read the skill
2. Announce you're using it
3. Follow what it says

**Skill has checklist?** TodoWrite for every item.

**Complex multi-step work?** Consider `/droidz-build` or `/auto-parallel`.

**Finding a relevant skill = mandatory to read and use it. Not optional.**
