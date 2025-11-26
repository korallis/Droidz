# Spec Writing Process

You are creating a comprehensive specification for a new feature.

## User Standards & Preferences Compliance

**IMPORTANT**: Before writing the spec, you MUST check for and adhere to the user's project standards.

### Step 0: Load Standards

Check if standards exist and load them:

1. Check for standards directory: `droidz/standards/`
2. If it exists, **read ALL standards files recursively**:
   - Use glob pattern `droidz/standards/**/*.md` to find all markdown files
   - This includes all subdirectories (global, frontend, backend, infrastructure, and any custom directories the user has created)
   - Read every `.md` file found in the standards directory tree

3. Ensure the specification document adheres to ALL loaded standards:
   - Follows documented coding principles and patterns
   - References appropriate standards where relevant
   - Does not propose approaches that conflict with established conventions
   - Aligns technical decisions with documented best practices

If no standards directory exists, proceed without standards constraints but inform the user:
```
ℹ️ No project standards found at droidz/standards/
   Consider running /shape-standards to establish project conventions.
```

---

Use the **spec-writer** subagent to create the specification document for this spec:

Provide the spec-writer with:
- The spec folder path (find the current one or the most recent in `droidz/specs/*/`)
- The requirements from `planning/requirements.md`
- Any visual assets in `planning/visuals/`

The spec-writer will create `spec.md` inside the spec folder.

Once the spec-writer has created `spec.md` output the following to inform the user:

```
Your spec.md is ready!

✅ Spec document created: `[spec-path]`

NEXT STEP 👉 Run `/create-tasks` to generate your tasks list for this spec.
```
