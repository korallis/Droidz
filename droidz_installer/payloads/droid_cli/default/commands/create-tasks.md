# Task List Creation Process

You are creating a tasks breakdown from a given spec and requirements for a new feature.

## User Standards & Preferences Compliance

**IMPORTANT**: Before creating tasks, you MUST check for and adhere to the user's project standards.

### Step 0: Load Standards & Detect Project Configuration

#### 0a. Load Standards

Check if standards exist and load them:

1. Check for standards directory: `droidz/standards/`
2. If it exists, **read ALL standards files recursively**:
   - Use glob pattern `droidz/standards/**/*.md` to find all markdown files
   - This includes all subdirectories (global, frontend, backend, infrastructure, and any custom directories the user has created)
   - Read every `.md` file found in the standards directory tree

3. When creating the tasks list, ensure adherence to ALL loaded standards:
   - Tasks follow documented coding principles and patterns
   - Task groupings align with documented architectural boundaries
   - Sub-tasks include necessary standards compliance (e.g., testing requirements)
   - Tasks don't propose approaches that conflict with established conventions

If no standards directory exists, proceed without standards constraints but inform the user:
```
ℹ️ No project standards found at droidz/standards/
   Consider running /shape-standards to establish project conventions.
```

#### 0b. Detect Package Manager

**IMPORTANT**: Detect the project's package manager by checking for lockfiles. Use the detected package manager for ALL tasks involving package installation, script running, or dependency management.

**Detection Order** (first match wins):
1. `bun.lockb` → Use **bun** (`bun install`, `bun run`, `bunx`)
2. `pnpm-lock.yaml` → Use **pnpm** (`pnpm install`, `pnpm run`, `pnpm dlx`)
3. `yarn.lock` → Use **yarn** (`yarn install`, `yarn run`, `yarn dlx`)
4. `package-lock.json` → Use **npm** (`npm install`, `npm run`, `npx`)
5. No lockfile found → Default to **npm** but note in tasks that the user should verify their preferred package manager

**Command Mapping**:
| Action | npm | yarn | pnpm | bun |
|--------|-----|------|------|-----|
| Install deps | `npm install` | `yarn install` | `pnpm install` | `bun install` |
| Add package | `npm install <pkg>` | `yarn add <pkg>` | `pnpm add <pkg>` | `bun add <pkg>` |
| Run script | `npm run <script>` | `yarn <script>` | `pnpm <script>` | `bun run <script>` |
| Execute bin | `npx <cmd>` | `yarn dlx <cmd>` | `pnpm dlx <cmd>` | `bunx <cmd>` |

When creating tasks, **always use the detected package manager commands** instead of hardcoding npm/npx.

---

## PHASE 1: Get and read the spec.md and/or requirements document(s)

You will need ONE OR BOTH of these files to inform your tasks breakdown:
- `droidz/specs/[this-spec]/spec.md`
- `droidz/specs/[this-spec]/planning/requirements.md`

IF you don't have ONE OR BOTH of those files in your current conversation context, then ask user to provide direction on where to you can find them by outputting the following request then wait for user's response:

```
I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those.  If you haven't created them yet, you can run /shape-spec or /write-spec.
```

## PHASE 2: Create tasks.md

Once you have `spec.md` AND/OR `requirements.md`, use the **tasks-list-creator** subagent to break down the spec and requirements into an actionable tasks list with strategic grouping and ordering.

Provide the tasks-list-creator:
- `droidz/specs/[this-spec]/spec.md` (if present)
- `droidz/specs/[this-spec]/planning/requirements.md` (if present)
- `droidz/specs/[this-spec]/planning/visuals/` and its' contents (if present)

The tasks-list-creator will create `tasks.md` inside the spec folder.

## PHASE 3: Inform user

Once the tasks-list-creator has created `tasks.md` output the following to inform the user:

```
Your tasks list ready!

✅ Tasks list created: `droidz/specs/[this-spec]/tasks.md`

NEXT STEP 👉 Run `/implement-tasks` (simple, effective) or `/orchestrate-tasks` (advanced, powerful) to start building!
```
