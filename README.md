# Droidz — Agentic Framework that drives Droid CLI (no Bun commands)

Droidz plans with you first, then asks the Droid CLI to do the work — all inside Droid.
- NEW projects: describe your idea → Droidz shows a plan → you edit/confirm → Droid CLI creates the Linear project & tickets → executes tasks in parallel.
- EXISTING projects: Droidz reads tickets → proposes a plan → you edit/confirm → Droid CLI implements in parallel.

It always asks before changing anything and follows your AGENTS.md.

---

## Quick install (1 minute)
Run this in the project folder you want to work on:

```sh
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

This installs the custom droid preset and helper files.

---

## What you need
- Linear API key (Linear → Settings → API Keys)
- Droid CLI installed and on PATH (`droid --help`)
- Optional: GitHub CLI (`gh auth status`) if you want PRs
- Optional: `AGENTS.md` in your repo (we follow it)

Tip: You can export your key so Droid can use it:
```sh
export LINEAR_API_KEY=lk_************************
```

---

## Use inside Droid CLI (recommended)
1) Start Droid CLI:
```sh
droid
```
2) Pick the custom droid:
- `droidz-orchestrator`

3) Follow the prompts:
- Choose NEW or EXISTING project
- (NEW) Describe your idea (e.g., “Build a To‑Do app with Next.js 14 + TypeScript”)
- You get a JSON‑only plan (epics → tasks with acceptance & labels). Ask it to refine until happy.
- Confirm when ready. The orchestrator will guide Droid to create the Linear project/tickets (NEW) or plan existing work, then implement.

Notes
- We obey `AGENTS.md` if present.
- The Linear key comes from your environment; we never print secrets.
- Implementation (branching, tests, commits, PRs, Linear comments) is done by Droid.

---

## How parallel workspaces are handled
The orchestrator will agree a workspace mode with you:
- worktree (recommended): each ticket gets its own isolated worktree → fastest & safest parallel mode
- clone: each ticket gets a lightweight local clone → also parallel
- branch: single repo with per‑ticket branches → we work in a shadow copy in parallel, then safely apply patches to the branch

---

## What happens when you start
- Each ticket is set to “In Progress” and a branch is created
- Droid implements the work, runs tests, and opens a Pull Request for review (default)
- Auto‑merge is optional — the orchestrator will ask
- Short status comments are added to the Linear ticket

---

## Git helpers (still inside Droid)
- If no repo is found, the orchestrator offers to `git init` and adds a safe `.gitignore`
- It can also add a remote (asks for the name and URL)

---

## Troubleshooting
- “Linear API key missing” → export `LINEAR_API_KEY` or let the orchestrator prompt you to paste it
- “Custom droid not visible” → ensure `.factory/droids/orchestrator.droid.json` exists and your Droid build loads custom droids
- “PRs aren’t opening” → check `gh auth status` and that a remote exists; approvals mode must not be `disallow_push`
- “Workspace choice?” → pick `worktree` unless you have special needs; you can change later

---

## Why no Bun commands here?
We made Droid the single place where you plan and run everything. Droidz just installs the prompts/presets and coordinates the flow — Droid CLI handles the actual work end‑to‑end.
