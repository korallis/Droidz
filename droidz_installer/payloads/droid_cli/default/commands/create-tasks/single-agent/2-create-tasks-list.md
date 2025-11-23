Now that you have the spec.md AND/OR requirements.md, please break those down into an actionable tasks list with strategic grouping and ordering, by following these instructions:

{{workflows/implementation/create-tasks-list}}

## Display confirmation and next step

Display the following message to the user:

```
The tasks list has created at `agent-os/specs/[this-spec]/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 Run `/implement-tasks` (simple, effective) or `/orchestrate-tasks` (advanced, powerful) to start building!
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the tasks list is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
