# Process for Orchestrating a Spec's Implementation

Now that we have a spec and tasks list ready for implementation, we will proceed with orchestrating implementation of each task group by a dedicated agent using the following MULTI-PHASE process.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### FIRST: Get tasks.md for this spec

IF you already know which spec we're working on and IF that spec folder has a `tasks.md` file, then use that and skip to the NEXT phase.

IF you don't already know which spec we're working on and IF that spec folder doesn't yet have a `tasks.md` THEN output the following request to the user:

```
Please point me to a spec's `tasks.md` that you want to orchestrate implementation for.

If you don't have one yet, then run any of these commands first:
/shape-spec
/write-spec
/create-tasks
```

### NEXT: Create orchestration.yml to serve as a roadmap for orchestration of task groups

In this spec's folder, create this file: `agent-os/specs/[this-spec]/orchestration.yml`.

Populate this file with with the names of each task group found in this spec's `tasks.md` and use this EXACT structure for the content of `orchestration.yml`:

```yaml
task_groups:
  - name: [task-group-name]
  - name: [task-group-name]
  - name: [task-group-name]
  # Repeat for each task group found in tasks.md
```

{{IF use_claude_code_subagents}}
### NEXT: Ask user to assign subagents to each task group

Next we must determine which subagents should be assigned to which task groups.  Ask the user to provide this info using the following request to user and WAIT for user's response:

```
Please specify the name of each subagent to be assigned to each task group:

1. [task-group-name]
2. [task-group-name]
3. [task-group-name]
[repeat for each task-group you've added to orchestration.yml]

Simply respond with the subagent names and corresponding task group number and I'll update orchestration.yml accordingly.
```

Using the user's responses, update `orchestration.yml` to specify those subagent names.  `orchestration.yml` should end up looking like this:

```yaml
task_groups:
  - name: [task-group-name]
    claude_code_subagent: [subagent-name]
  - name: [task-group-name]
    claude_code_subagent: [subagent-name]
  - name: [task-group-name]
    claude_code_subagent: [subagent-name]
  # Repeat for each task group found in tasks.md
```

For example, after this step, the `orchestration.yml` file might look like this (exact names will vary):

```yaml
task_groups:
  - name: authentication-system
    claude_code_subagent: backend-specialist
  - name: user-dashboard
    claude_code_subagent: frontend-specialist
  - name: api-endpoints
    claude_code_subagent: backend-specialist
```
{{ENDIF use_claude_code_subagents}}

{{UNLESS standards_as_claude_code_skills}}
### NEXT: Ask user to assign standards to each task group

Next we must determine which standards should guide the implementation of each task group.  Ask the user to provide this info using the following request to user and WAIT for user's response:

```
Please specify the standard(s) that should be used to guide the implementation of each task group:

1. [task-group-name]
2. [task-group-name]
3. [task-group-name]
[repeat for each task-group you've added to orchestration.yml]

For each task group number, you can specify any combination of the following:

"all" to include all of your standards
"global/*" to include all of the files inside of standards/global
"frontend/css.md" to include the css.md standard file
"none" to include no standards for this task group.
```

Using the user's responses, update `orchestration.yml` to specify those standards for each task group.  `orchestration.yml` should end up having AT LEAST the following information added to it:

```yaml
task_groups:
  - name: [task-group-name]
    standards:
      - [users' 1st response for this task group]
      - [users' 2nd response for this task group]
      - [users' 3rd response for this task group]
      # Repeat for all standards that the user specified for this task group
  - name: [task-group-name]
    standards:
      - [users' 1st response for this task group]
      - [users' 2nd response for this task group]
      # Repeat for all standards that the user specified for this task group
  # Repeat for each task group found in tasks.md
```

For example, after this step, the `orchestration.yml` file might look like this (exact names will vary):

```yaml
task_groups:
  - name: authentication-system
    standards:
      - all
  - name: user-dashboard
    standards:
      - global/*
      - frontend/components.md
      - frontend/css.md
  - name: task-group-with-no-standards
  - name: api-endpoints
    standards:
      - backend/*
      - global/error-handling.md
```

Note: If the `use_claude_code_subagents` flag is enabled, the final `orchestration.yml` would include BOTH `claude_code_subagent` assignments AND `standards` for each task group.
{{ENDUNLESS standards_as_claude_code_skills}}

{{IF use_claude_code_subagents}}
### NEXT: Delegate task groups implementations to assigned subagents

Loop through each task group in `agent-os/specs/[this-spec]/tasks.md` and delegate its implementation to the assigned subagent specified in `orchestration.yml`.

For each delegation, provide the subagent with:
- The task group (including the parent task and all sub-tasks)
- The spec file: `agent-os/specs/[this-spec]/spec.md`
- Instruct subagent to:
  - Perform their implementation
  - Check off the task and sub-task(s) in `agent-os/specs/[this-spec]/tasks.md`
{{UNLESS standards_as_claude_code_skills}}

In addition to the above items, also instruct the subagent to closely adhere to the user's standards & preferences as specified in the following files.  To build the list of file references to give to the subagent, follow these instructions:

{{workflows/implementation/compile-implementation-standards}}

Provide all of the above to the subagent when delegating tasks for it to implement.
{{ENDUNLESS standards_as_claude_code_skills}}
{{ENDIF use_claude_code_subagents}}

{{UNLESS use_claude_code_subagents}}
### NEXT: Generate prompts

Now we must generate an ordered series of prompt texts, which will be used to direct the implementation of each task group listed in `orchestration.yml`.

Follow these steps to generate this spec's ordered series of prompts texts, each in its own .md file located in `agent-os/specs/[this-spec]/implementation/prompts/`.

LOOP through EACH task group in `agent-os/specs/[this-spec]/tasks.md` and for each, use the following workflow to generate a markdown file with prompt text for each task group:

#### Step 1. Create the prompt markdown file

Create the prompt markdown file using this naming convention:
`agent-os/specs/[this-spec]/implementation/prompts/[task-group-number]-[task-group-title].md`.

For example, if the 3rd task group in tasks.md is named "Comment System" then create `3-comment-system.md`.

#### Step 2. Populate the prompt file

Populate the prompt markdown file using the following Prompt file content template.

##### Bracket content replacements

In the content template below, replace "[spec-title]" and "[this-spec]" with the current spec's title, and "[task-group-number]" with the current task group's number.

{{UNLESS standards_as_claude_code_skills}}
To replace "[orchestrated-standards]", use the following workflow:

{{workflows/implementation/compile-implementation-standards}}
{{ENDUNLESS standards_as_claude_code_skills}}

#### Prompt file content template:

```markdown
We're continuing our implementation of [spec-title] by implementing task group number [task-group-number]:

## Implement this task and its sub-tasks:

[paste entire task group including parent task, all of its' sub-tasks, and sub-bullet points]

## Understand the context

Read @agent-os/specs/[this-spec]/spec.md to understand the context for this spec and where the current task fits into it.

Also read these further context and reference:
- @agent-os/specs/[this-spec/]/planning/requirements.md
- @agent-os/specs/[this-spec/]/planning/visuals

## Perform the implementation

{{workflows/implementation/implement-tasks}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your implementation work is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

[orchestrated-standards]
{{ENDUNLESS standards_as_claude_code_skills}}
```

### Step 3: Output the list of created prompt files

Output to user the following:

```
Ready to begin implementation of [spec-title]!

Use the following list of prompts to direct the implementation of each task group:

[list prompt files in order]

Input those prompts into this chat one-by-one or queue them to run in order.

Progress will be tracked in `agent-os/specs/[this-spec]/tasks.md`
```
{{ENDUNLESS use_claude_code_subagents}}
