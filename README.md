# Droidz — Parallel Agentic Framework for Linear (Bun‑only)

Droidz helps you turn ideas or existing Linear projects into working code by running multiple specialized AI droids in parallel. It guides you with a simple wizard, plans the work, creates (or connects to) a Linear project, and then gets to work.

- No npm/npx. Uses Bun + Factory Droid CLI.
- Works for new projects (from an idea) and existing projects.
- Runs safe, token‑efficient plans and always asks before executing.

---

## What you need (simple checklist)
- A Linear account and API key (you can create one in Linear → Settings → API keys).
- Bun installed (https://bun.sh)
- Factory Droid CLI installed and on your PATH (`droid --help` should work)
- Optional: GitHub CLI (`gh auth status`) if you want auto PRs

Tip: You don’t need to be technical. The wizard asks simple questions and does the rest.

---

## 1‑minute install (into your project)
Run this from the root of the project you want to work on:

```sh
curl -fsSL https://raw.githubusercontent.com/leebarry/Droidz/main/scripts/install.sh | bash
```

This copies the `orchestrator/` folder into your project and makes the tools ready to run.

---

## Start the wizard
```sh
bun orchestrator/launch.ts
```
The wizard will:
1) Check your environment (Bun, Droid CLI, git, Linear access)
2) Ask if you want a NEW project (from an idea) or use an EXISTING Linear project
3) Offer a dry‑run plan so you can review everything
4) Ask “Start execution now?” and then run tasks in parallel

---

## Path A: NEW project from an idea (no setup needed)
- You’ll be asked: “What’s your project or feature idea?”
- Droidz will plan epics and tasks (short, clear, token‑efficient), create a Linear Project for you, and add issues with best‑practice labels.
- You’ll see a plan first, then you can start execution.

What happens during execution:
- Each task gets its own workspace (either git worktree or a lightweight local clone)
- Specialist droids implement, test, and (optionally) open PRs
- Linear tickets get short status comments and a final summary

Run it later again:
```sh
bun orchestrator/run.ts --project "Your Project" --sprint "Sprint 1" --concurrency 10
```

---

## Path B: EXISTING Linear project
- Select “Existing project” in the wizard
- Enter your Linear project name (and a sprint/cycle name if you want)
- Droidz verifies the project and prepares standard labels if needed
- You’ll see a dry‑run plan; confirm to start execution

Run it later again:
```sh
bun orchestrator/run.ts --project "Your Project" --sprint "Sprint 1" --concurrency 10
```

---

## Simple settings you may be asked about
- Linear API key: stored locally so Droidz can create/read issues and comment
- Concurrency: how many tasks to run in parallel (default: 10)
- PR approvals: auto (open PRs automatically), require_manual (default), or disallow_push (local only)
- Workspaces: use git worktrees (default) or simple local clones; both are safe, worktrees are faster and lighter
- Comments: whether to post progress comments back to Linear

Everything is saved in `orchestrator/config.json` so you don’t have to re‑enter it.

Note: Do not share your Linear API key. If your project uses git, avoid committing `orchestrator/config.json` (it contains your key).

---

## Common commands
- Launch the wizard (recommended):
```sh
bun orchestrator/launch.ts
```

- Only run the setup questions:
```sh
bun orchestrator/setup.ts
```

- Create a new Linear project from an idea (skips the full wizard):
```sh
bun orchestrator/new-project.ts
```

- Show plan only (no changes):
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10 --plan
```

- Execute tasks now:
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10
```

---

## What you’ll see while it runs
- A live summary in your terminal (queued/running/completed)
- Short status updates added to the Linear ticket being worked on
- Optional: branches and PRs created automatically if you turn on auto approvals

You can stop at any time; re‑running will pick up again with the same settings.

---

## Troubleshooting (plain English)
- “It can’t find my project”: Re‑run the wizard and check the exact Linear project name
- “I don’t have a sprint”: Leave sprint blank; Droidz will work off the entire project
- “PRs aren’t created”: Turn PR approvals to `auto` in the wizard (or config) and ensure `gh auth status` is logged in
- “Tests or build fail”: The droids will report failures; you can fix manually or re‑run
- “My API key is wrong”: Re‑run the wizard and paste the correct key

---

## How it works (one‑paragraph, optional)
Droidz fetches your Linear issues, routes each to a specialist (feature, test, infra, refactor, integration), prepares an isolated workspace, and drives the Factory `droid exec` tool to make focused changes, run tests, and (optionally) open PRs — in parallel.
