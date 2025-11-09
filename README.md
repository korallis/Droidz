# Droidz — your friendly project helper (Bun‑only)

Droidz is a simple helper that plans your work and asks the Droid app to do it. 
You tell it your idea (or point it at an existing Linear project). It shows you a plan first. 
When you say “Yes”, it does the work for you.

— No scary steps. No coding needed. —

## What you need
- A Linear account (and an API key — we’ll ask you to paste it)
- Bun installed (https://bun.sh)
- Droid CLI installed (run `droid --help` to check)
- Optional: GitHub CLI (`gh auth status`) if you want Pull Requests

If your repo has a file named `AGENTS.md` (rules for helpers), we follow it.

## Install (takes ~1 minute)
Run this inside the project folder you want to work on:

```sh
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

This adds an `orchestrator/` folder with everything set up.

## Start (the wizard)
```sh
bun orchestrator/launch.ts
```
What you’ll see:
1) Small checks (Bun, Droid, git, Linear access)
2) Pick NEW project (from an idea) or EXISTING Linear project
3) We show you a plan (a clear list of tickets/steps)
4) You can edit the plan (we save it to `orchestrator/plan.json`)
5) We only start after you say “Yes”

## If you choose NEW project
- We ask: “What’s your idea?” (Example: “Build a To‑Do app with Next.js”)
- We make a simple, complete plan (epics + tickets with short acceptance)
- You can edit the plan
- After you confirm, we ask the Droid app to create the Linear project and all tickets for you (using best practices)

## If you choose an EXISTING Linear project
- Tell us the project name (and a sprint/cycle if you have one)
- We read the tickets and make a plan
- You can edit the plan, then say “Yes” to start

## What happens when you start
- We mark each ticket “In Progress” and create a branch
- The Droid app writes code, runs tests, and opens a Pull Request for review
- We add short status notes on the Linear ticket
- When all tickets are done, you’ll see a summary

By default we open a PR for review (we do NOT auto‑merge).
You can turn on auto‑merge in the wizard later if you want.

## Where we work (pick one)
- Worktree (best): like giving each ticket its own desk — fastest and safest for many tickets at once
- Clone: like making a copy of your folder for each ticket — also parallel, just a little heavier
- Branch: one desk for all — we work in scratch space first, then safely paste changes onto the right branch

The wizard will help you pick. You can change it anytime.

## Common commands
- Start the wizard (recommended):
```sh
bun orchestrator/launch.ts
```

- See the plan only (no changes):
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10 --plan
```

- Run now (after you’ve reviewed the plan):
```sh
bun orchestrator/run.ts --project "Project X" --sprint "Sprint 1" --concurrency 10
```

## Friendly notes
- We always show a plan and ask before doing anything
- We follow your `AGENTS.md` rules if present
- If your Droid supports Custom Droids, we set them up for you automatically
- You can stop anytime and run again later — it will pick up where it left off

## Troubleshooting
- “It can’t find my project” → Re‑run the wizard, check the exact name in Linear
- “I don’t have a sprint” → Leave sprint empty — we’ll use the whole project
- “I want auto‑merge” → Turn on auto‑merge in the wizard (you can also pick squash/merge/rebase)
- “PRs aren’t opening” → Make sure `gh auth status` says you’re logged in
- “What does it change?” → It only starts after you confirm; all changes go through a Pull Request

That’s it. Tell us what you want to build — we’ll show you the plan, and then the Droid app will do the work for you. 😊
