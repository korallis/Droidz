Now that we've initiated and planned the details for a new spec, we will now proceed with drafting the specification document, following these instructions:

{{workflows/specification/write-spec}}

## Display confirmation and next step

Display the following message to the user:

```
The spec has been created at `agent-os/specs/[this-spec]/spec.md`.

Review it closely to ensure everything aligns with your vision and requirements.

Next step: Run the command, 2-create-tasks-list.md
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the specification document's content is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
