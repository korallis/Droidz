Now that you've initialized the folder for this new spec, proceed with the research phase.

Follow these instructions for researching this spec's requirements:

{{workflows/specification/research-spec}}

## Display confirmation and next step

Once you've completed your research and documented it, output the following message:

```
✅ I have documented this spec's research and requirements in `agent-os/specs/[this-spec]/planning`.

Next step: Run the command, `1-create-spec.md`.
```

After all steps complete, inform the user:

```
Spec initialized successfully!

✅ Spec folder created: `[spec-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

👉 Run `/write-spec` to create the spec.md document.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
