# Droidz — Agentic Framework that drives Droid CLI (Bun‑only)

Droidz plans with you first, then asks the Droid CLI to do the work.
- NEW projects: you describe the idea → Droidz shows a plan → you edit/confirm → Droid CLI creates the Linear project & tickets → executes tasks in parallel.
- EXISTING projects: Droidz reads tickets → proposes a plan → you edit/confirm → Droid CLI implements in parallel.

It always asks before changing anything and follows your AGENTS.md.

---

## Quick install (1 minute)
Run this inside the project folder you want to work on:

```sh
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

This adds an `orchestrator/` folder and a Custom Droid preset.

---

## What you need
- Linear API key (Linear → Settings → API Keys)
- Bun installed: https://bun.sh (check with `bun --version`)
- Droid CLI installed and on PATH (check with `droid --help`)
- Optional: GitHub CLI (`gh auth status`) if you want PRs
- Optional: `AGENTS.md` in your repo (we follow it)

Tip: You can paste your Linear API key when asked by the wizard, or export it first so Droid can use it:

```sh
export LINEAR_API_KEY=lk_************************
```

---

## Recommended: Use inside Droid CLI (pure‑Droid flow)
This lets you do everything from the Droid CLI, including planning and confirmation.

1) Start Droid CLI:
```sh
droid
```
2) Pick the custom droid named:
- `droidz-orchestrator`

3) Follow the prompts:
- Choose NEW or EXISTING project
- (NEW) Describe your idea (e.g., “Build a To‑Do app with Next.js 14 + TypeScript”)
- The droid shows a JSON-only plan (epics → tasks with acceptance & labels). You can ask it to edit/refine the plan.
- Confirm when ready. The droid will then run the Bun scripts for you to create the Linear project/tickets and start execution.

Notes
- The custom droid obeys your `AGENTS.md` and uses `LINEAR_API_KEY` from your environment.
- It runs: `bun orchestrator/new-project.ts` (NEW) or `bun orchestrator/run.ts` (EXISTING) after you confirm the plan.
- All implementation work (branching, tests, commits, PRs, Linear comments) is done by the Droid CLI workers.

---

## Alternative: Use the Bun wizard
If you prefer a simple terminal wizard without Droid selecting:

```sh
bun orchestrator/launch.ts
```
The wizard will:
1) Check your setup (Bun, Droid, git, Linear)
2) Ask to initialize git and set a remote if missing
3) Ask for the Linear API key (masked) if missing
4) Ask for NEW vs EXISTING project
5) Ask for a workspace mode (see below)
6) Show a plan (saved to `orchestrator/plan.json`) and allow you to edit it
7) Only after you confirm, it will execute

---

## Workspace modes (how we run in parallel)
Pick one in the wizard or set it in `orchestrator/config.json` via `workspace.mode`:
- worktree (recommended): Each ticket gets its own isolated worktree → fastest & safest parallel mode
- clone: Each ticket gets a lightweight local clone → also parallel
- branch: Single repo with per-ticket branches → Droidz builds changes in a shadow copy in parallel, then applies patches safely to the branch

You can change this any time.

---

## What happens when you start
- Each ticket is set to “In Progress” and a branch is created
- Droid CLI implements the work, runs tests, and opens a Pull Request for review (default) or auto‑merge if you enable it
- Short status comments are added to the Linear ticket
- When done, you’ll see a summary

By default we open PRs for review (no auto‑merge). You can enable auto‑merge during setup.

---

## Editing the plan
- The plan is saved to `orchestrator/plan.json`
- You can reorder or adjust items and re‑run
- NEW projects: the plan is used to create a Linear Project with best practices (labels, parent/child tasks, dependency links, sensible names)

---

## Git helpers
- If no repo is found, the wizard offers to `git init` and adds a safe `.gitignore` (ignores `orchestrator/config.json`, `orchestrator/plan.json`, `.runs/`)
- The wizard also offers to add a remote and asks for the name (default `origin`) and URL

---

## Common commands
- Launch the Droid CLI orchestrator (recommended):
```sh
droid  # then pick droidz-orchestrator and follow prompts
```

- Launch the Bun wizard:
```sh
bun orchestrator/launch.ts
```

- Show plan only (no changes):
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10 --plan
```

- Execute now (after confirming the plan):
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10
```

---

## AGENTS.md (we obey your rules)
If your repo has an `AGENTS.md`, we load it and pass key guidance into every worker prompt so the Droid CLI follows your rules.

---

## Troubleshooting
- “It keeps saying the Linear API key is missing” → Export `LINEAR_API_KEY` first or run the wizard to paste it; placeholders like `__PUT_YOUR_LINEAR_API_KEY_HERE__` are considered missing
- “Droid CLI doesn’t show the custom droid” → Ensure `.factory/droids/orchestrator.droid.json` exists and your Droid build supports custom droids
- “It doesn’t create PRs” → Check `gh auth status` and that a remote exists; approvals mode must not be `disallow_push`
- “Workspaces confuse me” → Choose `worktree` (recommended) in the wizard; you can switch later in `orchestrator/config.json`
- “I want auto‑merge” → Turn it on in the wizard when asked (you can also set the merge strategy)

---

## Why this design
- Droid CLI does the actual work (git, code changes, tests, PRs, Linear updates). Droidz only plans, coordinates, and starts those Droid runs.
- This keeps things simple, transparent, and easy to control from inside the Droid CLI itself.
