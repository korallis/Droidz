# Process for Orchestrating a Spec's Implementation

Now that we have a spec and tasks list ready for implementation, we will proceed with orchestrating implementation of each task group by a dedicated agent using the following MULTI-PHASE process.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Pre-Requisite: Detect Project Configuration

### Detect Package Manager

**IMPORTANT**: Before orchestrating any tasks, detect the project's package manager by checking for lockfiles. Use the detected package manager for ALL implementation prompts and commands.

**Detection Order** (first match wins):
1. `bun.lockb` → Use **bun** (`bun install`, `bun run`, `bunx`)
2. `pnpm-lock.yaml` → Use **pnpm** (`pnpm install`, `pnpm run`, `pnpm dlx`)
3. `yarn.lock` → Use **yarn** (`yarn install`, `yarn run`, `yarn dlx`)
4. `package-lock.json` → Use **npm** (`npm install`, `npm run`, `npx`)
5. No lockfile found → Default to **npm** but note that the user should verify their preferred package manager

**Command Mapping**:
| Action | npm | yarn | pnpm | bun |
|--------|-----|------|------|-----|
| Install deps | `npm install` | `yarn install` | `pnpm install` | `bun install` |
| Add package | `npm install <pkg>` | `yarn add <pkg>` | `pnpm add <pkg>` | `bun add <pkg>` |
| Run script | `npm run <script>` | `yarn <script>` | `pnpm <script>` | `bun run <script>` |
| Execute bin | `npx <cmd>` | `yarn dlx <cmd>` | `pnpm dlx <cmd>` | `bunx <cmd>` |

Store the detected package manager and use it when:
- Generating implementation prompts
- Writing orchestration.yml
- Creating any bash scripts or commands for specialists

---

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

In this spec's folder, create this file: `droidz/specs/[this-spec]/orchestration.yml`.

Populate this file with with the names of each task group found in this spec's `tasks.md` and use this EXACT structure for the content of `orchestration.yml`:

```yaml
task_groups:
  - name: [task-group-name]
  - name: [task-group-name]
  - name: [task-group-name]
  # Repeat for each task group found in tasks.md
```

### NEXT: Ask user to assign specialists to each task group

Next we must determine which specialists should be assigned to which task groups.  Ask the user to provide this info using the following request to user and WAIT for user's response:

```
Please specify the name of each specialist to be assigned to each task group:

1. [task-group-name]
2. [task-group-name]
3. [task-group-name]
[repeat for each task-group you've added to orchestration.yml]

Simply respond with the specialist names and corresponding task group number and I'll update orchestration.yml accordingly.

Examples: backend-specialist, frontend-specialist, database-specialist, test-specialist
```

Using the user's responses, update `orchestration.yml` to specify those specialist names.  `orchestration.yml` should end up looking like this:

```yaml
task_groups:
  - name: [task-group-name]
    assigned_specialist: [specialist-name]
  - name: [task-group-name]
    assigned_specialist: [specialist-name]
  - name: [task-group-name]
    assigned_specialist: [specialist-name]
  # Repeat for each task group found in tasks.md
```

For example, after this step, the `orchestration.yml` file might look like this (exact names will vary):

```yaml
task_groups:
  - name: authentication-system
    assigned_specialist: backend-specialist
  - name: user-dashboard
    assigned_specialist: frontend-specialist
  - name: api-endpoints
    assigned_specialist: backend-specialist
```

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

Note: The final `orchestration.yml` would include BOTH `assigned_specialist` assignments AND `standards` for each task group.

### NEXT: Delegate task groups implementations to assigned specialists

Loop through each task group in `droidz/specs/[this-spec]/tasks.md` and delegate its implementation to the assigned specialist specified in `orchestration.yml`.

For each delegation, provide the specialist with:
- The task group (including the parent task and all sub-tasks)
- The spec file: `droidz/specs/[this-spec]/spec.md`
- Instruct specialist to:
  - Perform their implementation
  - Check off the task and sub-task(s) in `droidz/specs/[this-spec]/tasks.md`

In addition to the above items, also instruct the specialist to closely adhere to the user's standards & preferences as specified in the following files.  To build the list of file references to give to the specialist, follow these instructions:

#### Building the Standards File List for a Task Group

For each task group, look up its `standards` entry in `orchestration.yml` and resolve it to actual file paths:

1. **If `standards` contains "all"**:
   - Include all files from `droidz/standards/global/*.md`
   - Include all files from `droidz/standards/frontend/*.md`
   - Include all files from `droidz/standards/backend/*.md`
   - Include all files from `droidz/standards/infrastructure/*.md`

2. **If `standards` contains a wildcard pattern** (e.g., "global/*", "frontend/*"):
   - Include all `.md` files from `droidz/standards/[pattern]/`
   - Example: "backend/*" → all files in `droidz/standards/backend/`

3. **If `standards` contains a specific file path** (e.g., "frontend/components.md"):
   - Include that specific file: `droidz/standards/[path]`
   - Example: "frontend/components.md" → `droidz/standards/frontend/components.md`

4. **If `standards` is missing or contains "none"**:
   - Do not include any standards files for this task group

5. **Format the file list** for the specialist as markdown file references:
   ```
   - @droidz/standards/global/coding-principles.md
   - @droidz/standards/global/error-handling.md
   - @droidz/standards/frontend/components.md
   ```

Provide all of the above to the specialist when delegating tasks for it to implement.

### NEXT: Generate prompts

Now we must generate an ordered series of prompt texts, which will be used to direct the implementation of each task group listed in `orchestration.yml`.

Follow these steps to generate this spec's ordered series of prompts texts, each in its own .md file located in `droidz/specs/[this-spec]/implementation/prompts/`.

LOOP through EACH task group in `droidz/specs/[this-spec]/tasks.md` and for each, use the following workflow to generate a markdown file with prompt text for each task group:

#### Step 1. Create the prompt markdown file

Create the prompt markdown file using this naming convention:
`droidz/specs/[this-spec]/implementation/prompts/[task-group-number]-[task-group-title].md`.

For example, if the 3rd task group in tasks.md is named "Comment System" then create `3-comment-system.md`.

#### Step 2. Populate the prompt file

Populate the prompt markdown file using the following Prompt file content template.

##### Bracket content replacements

In the content template below, replace "[spec-title]" and "[this-spec]" with the current spec's title, and "[task-group-number]" with the current task group's number.

To replace "[orchestrated-standards]", use the following workflow:

1. **Look up this task group in `orchestration.yml`** to find its `standards` entries
2. **Resolve each standards entry to actual file paths** using the same logic from "Building the Standards File List for a Task Group" above:
   - "all" → list all files from all standards subdirectories
   - "global/*" → list all files from `droidz/standards/global/`
   - "frontend/components.md" → `droidz/standards/frontend/components.md`
   - "none" or missing → leave [orchestrated-standards] empty or write "No specific standards assigned."

3. **Format as markdown file references**:
   ```
   - @droidz/standards/global/coding-principles.md
   - @droidz/standards/global/error-handling.md
   - @droidz/standards/frontend/components.md
   ```

4. **Replace [orchestrated-standards]** in the prompt template with the formatted list

**Example**: If `orchestration.yml` has:
```yaml
- name: user-dashboard
  standards:
    - global/*
    - frontend/components.md
```

Then [orchestrated-standards] becomes:
```
- @droidz/standards/global/coding-principles.md
- @droidz/standards/global/error-handling.md
- @droidz/standards/global/testing.md
- @droidz/standards/global/security.md
- @droidz/standards/frontend/components.md
```

#### Prompt file content template:

```markdown
We're continuing our implementation of [spec-title] by implementing task group number [task-group-number]:

## Implement this task and its sub-tasks:

[paste entire task group including parent task, all of its' sub-tasks, and sub-bullet points]

## Understand the context

Read @droidz/specs/[this-spec]/spec.md to understand the context for this spec and where the current task fits into it.

Also read these further context and reference:
- @droidz/specs/[this-spec/]/planning/requirements.md
- @droidz/specs/[this-spec/]/planning/visuals

## Perform the implementation

## User Standards & Preferences Compliance

IMPORTANT: Ensure that your implementation work is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

[orchestrated-standards]
```

### Step 3: Output the list of created prompt files

Output to user the following:

```
Ready to begin implementation of [spec-title]!

Use the following list of prompts to direct the implementation of each task group:

[list prompt files in order]

Input those prompts into this chat one-by-one or queue them to run in order.

Progress will be tracked in `droidz/specs/[this-spec]/tasks.md`
```
