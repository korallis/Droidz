Now that you have the spec.md AND/OR requirements.md, please break those down into an actionable tasks list with strategic grouping and ordering, by following these instructions:

## Display confirmation and next step

Display the following message to the user:

```
The tasks list has created at `droidz/specs/[this-spec]/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 Run `/implement-tasks` (simple, effective) or `/orchestrate-tasks` (advanced, powerful) to start building!
```

## User Standards & Preferences Compliance

IMPORTANT: Ensure that the tasks list is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

### Standards Loading Instructions

Before creating the tasks list, check for and load project standards:

1. **Check if standards exist**: Look for `droidz/standards/` directory
2. **If standards exist**, **read ALL standards files recursively**:
   - Use glob pattern `droidz/standards/**/*.md` to find all markdown files
   - This includes all subdirectories (global, frontend, backend, infrastructure, and any custom directories the user has created)
   - Read every `.md` file found in the standards directory tree

3. **Apply ALL loaded standards to task creation** by ensuring:
   - Tasks follow documented coding principles and patterns
   - Task groupings align with documented architectural boundaries
   - Sub-tasks include necessary standards compliance (e.g., testing requirements)
   - Tasks don't propose approaches that conflict with established conventions
   - Error handling, security, and other concerns from standards are reflected in relevant tasks

If no standards directory exists, proceed normally but note to the user:
```
ℹ️ No project standards found. Consider running /shape-standards to establish conventions.
```
