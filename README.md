# Droidz — Agentic Framework that drives Droid CLI (no Bun commands)

Droidz plans with you first, then asks the Droid CLI to do the work — all inside Droid.
- NEW projects: describe your idea → Droidz shows a plan → you edit/confirm → Droid CLI creates the Linear project & tickets → executes tasks in parallel.
- EXISTING projects: Droidz reads tickets → proposes a plan → you edit/confirm → Droid CLI implements in parallel.

It always asks before changing anything and follows your AGENTS.md.

---

## Prerequisites
- Linear API key (Linear → Settings → API Keys)
- Droid CLI installed and on PATH (`droid --help`)
- Optional: GitHub CLI (`gh auth status`) if you want Pull Requests
- Optional: An `AGENTS.md` in your repo (we follow it)

Tip: Export your key so Droid can use it (or the orchestrator will prompt you):
```sh
export LINEAR_API_KEY=lk_************************
```

---

## Install (1 minute)
Run this inside the project folder you want to work on:
```sh
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```
This installs the custom droid preset and helper files into your repo.

---

## Use inside Droid CLI (recommended)
1) Start Droid CLI:
```sh
droid
```
2) Pick the custom droid:
- `droidz-orchestrator`

3) Follow the prompts step-by-step:
- You’ll be asked to choose NEW project (from an idea) or EXISTING Linear project
- If the Linear API key is missing, you can paste it right there (or export it beforehand)
- If your repo is not a git repo, the orchestrator offers to initialize it and add a safe `.gitignore`
- If you don’t have a remote, it offers to add one (it asks the remote name and URL)
- Pick a workspace mode (see below)
- For NEW: describe your idea (e.g., “Build a To‑Do app with Next.js 14 + TypeScript”), including tech stack and constraints
- For EXISTING: provide the Linear project name and optional sprint/cycle
- The droid shows a JSON-only plan (epics → tasks with acceptance criteria & labels). Ask the droid to refine it until you’re happy
- Confirm when ready — only then will Droid start execution

4) Execution (after you confirm the plan):
- Each ticket is set to “In Progress” and a branch is created
- Droid implements the work, runs tests, and opens a Pull Request for review (default)
- Auto‑merge is optional — the orchestrator will ask and configure it if you choose
- Short, clear status comments are added to the Linear ticket
- When finished, you’ll see a summary (PR links, results)

Notes
- The orchestrator obeys `AGENTS.md` if present and passes key guidance into every worker
- The Linear key comes from your environment; the droid never prints secrets
- Implementation (branching, tests, commits, PRs, Linear comments) is done by Droid CLI; Droidz only plans and coordinates

---

## Workspace modes (parallel execution)
You can pick one in the conversation, and change later any time.
- worktree (recommended): each ticket gets its own isolated worktree → fastest & safest parallel mode
- clone: each ticket gets a lightweight local clone → also parallel
- branch: single repo with per‑ticket branches → we work in a temporary shadow copy in parallel, then safely apply patches to the branch

Why three modes?
- Worktrees are the safest/fastest for most repos
- Clone works when worktrees aren’t available or tools expect a standalone copy per ticket
- Branch mode avoids extra directories, while still enabling parallel work via shadow copies

---

## NEW vs EXISTING flows (in detail)

NEW project from an idea
- The droid asks for your idea and tech stack (e.g., “Next.js 14 + TS, Postgres, Tailwind; focus on performance & modern UX”)
- It generates a clear, token‑efficient JSON plan: project name, epics, and tasks with short acceptance criteria & labels
- You can ask it to add/remove epics, rename tasks, or change frameworks (“use Next.js 18”, etc.)
- When you confirm, the droid creates a Linear Project and tickets using best practices (labels, parent/child tasks, dependency links, sensible names)
- Then it begins implementation in parallel

EXISTING Linear project
- Provide the Linear project name (and optional sprint/cycle)
- The droid lists tickets and proposes a safe parallelization plan
- You can refine the order, labels, or acceptance criteria
- When you confirm, the droid begins implementation in parallel

---

## AGENTS.md (we obey your rules)
If your repo has an `AGENTS.md`, the orchestrator reads it and uses the key guidance in every worker prompt. You can use this file to define:
- project conventions and standards
- code style rules
- commit message format
- definition of done, review requirements
- security and secret-handling policies

Example snippet:
```
# AGENTS.md
- Use Bun for JS/TS tasks, no npm/npx
- PR title: [TYPE] Short summary (#ISSUE)
- Require tests for every feature change
- Never log secrets or tokens; use env vars only
```

---

## Git helpers (still inside Droid)
- If no repo is found, the orchestrator offers to `git init` and writes a safe `.gitignore` (ignores orchestrator/config.json, orchestrator/plan.json, .runs/)
- It can add a remote: you provide the remote name (default `origin`) and the URL (HTTPS or SSH)

---

## Troubleshooting
- “Linear API key missing” → export `LINEAR_API_KEY` first, or paste it when prompted
- “Custom droid not visible” → ensure `.factory/droids/orchestrator.droid.json` exists and your Droid build loads custom droids
- “PRs aren’t opening” → check `gh auth status` and that a remote exists; approvals mode must not be `disallow_push`
- “Workspace choice?” → pick `worktree` unless you have special needs; you can change later
- “Plan JSON looks wrong” → ask the droid to regenerate or refine parts (e.g., “use Next 18”, “split auth epic into X/Y/Z”)

---

## Why this design
- Droid CLI is the single place you plan and run everything; Droidz just installs the presets and coordinates the flow
- You see a plan first and must confirm before anything runs
- The droid does the hands‑on work (git, code, tests, PRs, Linear), so you stay in one tool the whole time
