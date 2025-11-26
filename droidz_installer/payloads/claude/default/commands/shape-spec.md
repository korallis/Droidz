# Spec Shaping Process

You are helping me shape and plan the scope for a new feature.  The following process is aimed at documenting our key decisions regarding scope, design and architecture approach.  We will use our findings from this process later when we write the formal spec document (but we are NOT writing the formal spec yet).

## User Standards & Preferences Compliance

**IMPORTANT**: Before proceeding with spec shaping, you MUST check for and adhere to the user's project standards.

### Step 0: Load Standards

Check if standards exist and load them:

1. Check for standards directory: `droidz/standards/`
2. If it exists, **read ALL standards files recursively**:
   - Use glob pattern `droidz/standards/**/*.md` to find all markdown files
   - This includes all subdirectories (global, frontend, backend, infrastructure, and any custom directories the user has created)
   - Read every `.md` file found in the standards directory tree

3. Keep ALL standards in mind throughout the spec shaping process to ensure:
   - Research questions align with established patterns
   - Proposed approaches don't conflict with existing standards
   - Architecture decisions follow documented conventions

If no standards directory exists, proceed without standards constraints but inform the user:
```
ℹ️ No project standards found at droidz/standards/
   Consider running /shape-standards to establish project conventions.
```

---

This process will follow 3 main phases, each with their own workflow steps:

Process overview (details to follow)

PHASE 1. Initilize spec
PHASE 2. Research requirements for this spec
PHASE 3. Inform the user that the spec has been initialized

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process:

### PHASE 1: Initialize Spec

Use the **spec-shaper** subagent to initialize a new spec.

IF the user has provided a description, provide that to the spec-initializer.

The spec-initializer will provide the path to the dated spec folder (YYYY-MM-DD-spec-name) they've created.

### PHASE 2: Research Requirements

After spec-initializer completes, immediately use the **spec-shaper** subagent:

Provide the spec-shaper with:
- The spec folder path from spec-initializer

The spec-shaper will give you several separate responses that you MUST show to the user. These include:
1. Numbered clarifying questions along with a request for visual assets (show these to user, wait for user's response)
2. Follow-up questions if needed (based on user's answers and provided visuals)

**IMPORTANT**:
- Display these questions to the user and wait for their response
- The spec-shaper may ask you to relay follow-up questions that you must present to user

### PHASE 3: Inform the user

After all steps complete, inform the user:

```
Spec shaping is complete!

✅ Spec folder created: `[spec-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

NEXT STEP 👉 Run `/write-spec` to generate the detailed specification document.
```
