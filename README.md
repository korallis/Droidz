# Droidz Orchestrator (Agentic Framework for Linear)

Bun‑only orchestration to plan, create, and implement Linear projects with parallel specialized droids via `droid exec`.

## Features
- Single command launcher to initialize config, validate environment, and guide you through either:
  - Existing Linear projects: verify, ask clarifying questions, plan, and execute.
  - New projects from an idea: auto‑plan epics/tasks, create a Linear Project with best‑practice labels and tickets, then execute.
- Parallel execution with per‑ticket isolated workspaces: git worktrees (default) or lightweight local clones.
- Token‑efficient ticket content (short descriptions + crisp acceptance criteria).
- Linear comments for status and summaries (configurable).
- Bun‑only: no npm/npx.

## Prerequisites
- macOS/Linux with:
  - Bun (>= 1.0)
  - git and GitHub CLI (`gh auth status` should be logged in) if you want auto PRs
  - Factory Droid CLI (`droid` in PATH)
- Linear API key

## Installation (public repo)
Recommended one‑liner (no npm/npx):

```sh
curl -fsSL https://raw.githubusercontent.com/leebarry/Droidz/main/scripts/install.sh | bash
```

- This downloads the orchestrator folder into your current repo and makes the entry points executable.
- To install from a different branch or fork:

```sh
DROIDZ_REPO="your-org/your-repo" DROIDZ_BRANCH="dev" \
  curl -fsSL https://raw.githubusercontent.com/your-org/your-repo/dev/scripts/install.sh | bash
```

## Quick start
After installation, in your repo root run:

```sh
bun orchestrator/launch.ts
```

The launcher will:
   - Run an interactive setup to write `orchestrator/config.json` (includes your Linear API key).
   - Validate environment (bun, droid, git repo, gh auth, Linear connectivity).
   - Ask whether to create a NEW Linear project from your idea or use an existing one.
   - For new projects: it will plan a compact JSON (epics → tasks) and create the project/issues.
   - For existing projects: it verifies project (and optional sprint) and updates config.
   - Offer a dry‑run plan, then ask “Start execution now?”.

## Commands
- Setup only (interactive):
  ```sh
  bun orchestrator/setup.ts
  ```

- Create a new Linear project from an idea (and update config):
  ```sh
  bun orchestrator/new-project.ts
  ```

- Run orchestrator (plan only):
  ```sh
  bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10 --plan
  ```

- Run orchestrator (execute):
  ```sh
  bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10
  ```

- One‑command flow (recommended):
  ```sh
  bun orchestrator/launch.ts
  ```

## Configuration
`orchestrator/config.json` (created/updated by setup/launch):
- `linear.apiKey`: your Linear API key
- `linear.project` / `linear.projectId`: selected or created project
- `linear.sprint`: optional cycle name filter (falls back to project‑only)
- `concurrency`: number of parallel tasks (default 10)
- `approvals.prs`: `auto` | `require_manual` | `disallow_push`
- `workspace.baseDir`: workspace base directory (default `.runs`)
- `workspace.branchPattern`: e.g., `{type}/{issueKey}-{slug}`
- `workspace.useWorktrees`: true to use git worktrees; false to use lightweight clones (still supports parallel runs)
- `guardrails`: `dryRun`, `secretScan`, `testsRequired`, `maxJobMinutes`
- `routing.rules`: map labels to specialists; `fallback` for others

## Implementation notes
- Each ticket runs in its own git worktree and branch to avoid conflicts.
- If no issues are found for the selected sprint, the orchestrator falls back to project‑only issue queries.
- Linear comments are posted at start and completion (unless dry‑run).
- Auto PR creation happens only when `approvals.prs` is set to `auto`.

## Safety
- Dry‑run/plan mode available in `launch.ts` and `run.ts`.
- Optional secret scan hook spot in workers (you can integrate your scanner).
- Tests are expected to pass before completion (configurable).

## Troubleshooting
- Not a git repo: initialize with `git init` and add a remote `origin` if you plan to open PRs.
- Linear API key: set via `setup.ts`/`launch.ts` which write `orchestrator/config.json`.
- Cycles/Sprints: If your team manages cycles automatically, you can omit `--sprint`; the orchestrator will fetch by project only.

## Extending
- Add new specialist droids by adjusting `routing.rules` and prompts in `workerPrompt.ts`.
- Integrate Slack or other reporters in `workers.ts` and `run.ts`.
- Implement secret scanning and policy checks in `workers.ts` before commits.
