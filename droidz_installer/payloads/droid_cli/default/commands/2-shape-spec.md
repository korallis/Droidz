Now that you've initialized the folder for this new spec, proceed with the research phase.

Follow these instructions for researching this spec's requirements:

## Display confirmation and next step

Once you've completed your research and documented it, output the following message:

```
✅ I have documented this spec's research and requirements in `droidz/specs/[this-spec]/planning`.

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

## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

### Standards Loading Instructions

Before proceeding, check for and load project standards:

1. **Check if standards exist**: Look for `droidz/standards/` directory
2. **If standards exist**, **read ALL standards files recursively**:
   - Use glob pattern `droidz/standards/**/*.md` to find all markdown files
   - This includes all subdirectories (global, frontend, backend, infrastructure, and any custom directories the user has created)
   - Read every `.md` file found in the standards directory tree

3. **Apply ALL loaded standards to your research** by ensuring:
   - Questions align with established architectural patterns
   - Proposed approaches don't conflict with documented conventions
   - Requirements gathering considers existing coding principles
   - Design decisions follow documented best practices

If no standards directory exists, proceed normally but note to the user:
```
ℹ️ No project standards found. Consider running /shape-standards to establish conventions.
```
