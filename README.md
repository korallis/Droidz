# Droidz: Robot Friends That Build Your App Together

> **Tagline:** Five specialist robots share the work, so your features ship 3–5× faster while you supervise.

## TL;DR (for busy adults and curious kids)
- **Droidz is a toolkit** that plugs into the Factory CLI and gives you an orchestrator plus five specialist droids.
- **The orchestrator plans first**, then launches multiple specialists in parallel using git worktrees, the Task tool, and TodoWrite.
- **Specialist droids = tiny experts** (codegen, infra, integration, refactor, tests, generalist). Call them directly for quick jobs or let the orchestrator coordinate them for big tasks.
- **Install once with `install.sh`**, enable Custom Droids in the Factory CLI, and start prompting. The installer no longer overwrites your README.
- **Optional power-ups:** connect MCP servers (Linear, Exa, Ref) so droids can fetch tickets, research, and documentation automatically.

## What Is Droidz?
### The short version
Droidz turns the Factory CLI into a small team of robot helpers. You explain the job once, they split it up, work in isolated git worktrees, and hand back pull requests plus testing notes.

### Why five robots?
- **Codegen Droid** writes and updates code while following repo patterns.
- **Test Droid** adds or fixes tests so changes are safe.
- **Refactor Droid** cleans existing code without breaking behavior.
- **Infra Droid** keeps CI/tooling healthy.
- **Integration Droid** connects external APIs using env vars only.
- **Generalist Droid** jumps in when a task does not fit the boxes above.

### What makes Droidz different?
- **Parallel execution:** the orchestrator always chooses git worktree mode so multiple tickets run at once.
- **Task tool delegation:** every specialist is launched with Factory’s Task tool, which streams progress and keeps context isolated.
- **TodoWrite plans:** the orchestrator keeps a single, always-up-to-date TodoWrite list so humans and robots see the same plan.
- **MCP aware:** when Linear, Exa, or Ref MCP servers are available, the orchestrator confirms and uses them automatically.

## Install in Three Friendly Steps
1. **Check your tools.** Make sure you have `git`, the [Bun runtime](https://bun.sh), and the Factory CLI (`droid`) installed.
2. **Run the installer from your repo root.**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
   ```
   The script creates `.factory/droids`, `.factory/commands`, and `.factory/orchestrator/` files, installs Bun dependencies, and leaves your README untouched.
3. **Enable Custom Droids inside Factory CLI.**
   ```text
   droid
   /settings → toggle "Custom Droids" ON
   (restart the CLI)
   ```
   Afterwards run `/droids` to confirm you see the Droidz specialists.

> 💡 **Optional:** Add MCP servers with `/mcp add exa`, `/mcp add linear`, and `/mcp add ref` so the orchestrator can research, fetch tickets, and read docs without extra prompts.

## Meet the Robot Team
| Droid | Superpower | Great For | Built-in Tools |
| --- | --- | --- | --- |
| `droidz-orchestrator` | Plans work, checks MCP servers, keeps TodoWrite list, launches specialists in parallel | Whole sprints, multi-ticket batches | Read, LS, Grep, Glob, Execute, TodoWrite, WebSearch, FetchUrl, all MCP tools |
| `droidz-codegen` | Implements features and bug fixes | New components, API changes, bug tickets | All Factory tools + MCP |
| `droidz-test` | Writes and repairs tests, tracks coverage | Adding missing tests, stabilizing suites | All Factory tools + MCP |
| `droidz-refactor` | Improves structure without changing behavior | Cleanup, tech debt, migrations | All Factory tools + MCP |
| `droidz-infra` | Tends CI, build scripts, deployment configs | Pipeline fixes, lint/build issues | All Factory tools + MCP |
| `droidz-integration` | Connects third-party APIs safely | Stripe, Twilio, Linear integrations | All Factory tools + MCP |
| `droidz-generalist` | Safe fallback that nudges stuck work forward | Mixed or ambiguous tickets | All Factory tools + MCP |

> 🧸 **Explain like I’m five:** Imagine seven toy robots. One boss robot (the orchestrator) reads your mission, writes a chore list, and sends the other six robots to different play mats so they can build at the same time.

## Two Ways to Work
### 1. Autopilot: `/droidz-orchestrator`
Use this when you want the full planning experience or need multiple tickets done in parallel. The orchestrator will:
1. Read your entire prompt verbatim (no summaries).
2. Confirm MCP access (Linear cycles, Exa research, Ref docs).
3. Build a TodoWrite plan that marks which tasks can run together.
4. Create git worktrees via `.factory/orchestrator/task-coordinator.ts` so every specialist gets its own branch.
5. Launch the specialists with the Task tool and stream progress.
6. Finish with a summary plus a speed comparison (parallel vs sequential).

### 2. Manual Control: Specialist Slash Commands
Call a specialist directly when the job is simple or sequential:
- `/droidz-codegen Implement ticket LEE-512` – one-off feature or bug fix.
- `/droidz-test Improve tests for payments` – targeted testing work.
- `/droidz-refactor Clean up auth middleware` – safe refactor.

> **Rule of thumb:** If the task feels like “one quick change,” go direct. If it sounds like “three or more pieces” or a sprint, use the orchestrator.

## What Happens During an Orchestrator Run?
1. **Listen:** The orchestrator copies your prompt exactly into `full_user_prompt` so every specialist sees the same instructions.
2. **Scout:** Reads project files (AGENTS.md, config.yml, README), checks `.factory/mcp.json`, and verifies `workspace.mode === "worktree"` in `.factory/orchestrator/config.json`.
3. **Research (optional):** If you asked for it—or if Linear/Exa/Ref MCPs exist—it pulls ticket data, searches code examples, or reads docs.
4. **Plan:** Writes a TodoWrite list with statuses (`pending → in_progress → completed`), grouping items into sequential and parallel phases.
5. **Setup:** Calls `task-coordinator.ts`, which clones a fresh git worktree, creates the feature branch, and returns the workspace path plus guardrail hints (tests required, secret scan, etc.).
6. **Delegate:** Invokes the Task tool with the right `subagent_type` (`droidz-codegen`, `droidz-test`, …) and streams tool outputs. Specialists run Bun commands, edits, tests, and git operations inside their isolated worktree.
7. **Wrap up:** Marks todos complete, reports timing (parallel vs sequential), lists PR URLs, and updates Linear if allowed.

This flow follows Factory’s recommended multi-agent pattern: TodoWrite for progress, Task tool for delegation, git worktrees for isolation, MCP for context, and human-readable summaries.

## Common Use Cases
| Scenario | Recommended Flow | Why It Shines |
| --- | --- | --- |
| **New product from scratch** | `/droidz-orchestrator` with a feature list | Automatically plans phases (infra → backend → frontend → tests) and spins up multiple branches so you get a full MVP quickly.
| **Process a sprint backlog** | `/droidz-orchestrator process sprint "Cycle 4"` | Pulls Linear tickets, groups by skill (frontend/backend/test), and runs several in parallel.
| **Burn down bugs** | `/droidz-codegen Fix bug LEE-441` or orchestrator for batches | Specialists focus on one bug each; orchestrator keeps track of PRs and test status.
| **Raise test coverage** | `/droidz-test Add tests for checkout` | Uses Bun to run tests, adds missing cases, and reports coverage.
| **CI/tooling fire drill** | `/droidz-infra repair pipeline` | Updates GitHub Actions, lint configs, or build scripts while keeping diffs small.
| **Integrate third-party service** | `/droidz-integration connect Stripe` | Adds clients using env vars only, updates config, and writes verification steps.

## Tips & Best Practices
- **One prompt = one story.** Give the orchestrator everything it needs (tickets, requirements, constraints) in a single message so it can share the same story with every specialist.
- **Describe parallel hopes.** Mention if tickets are independent; the orchestrator will mark them as parallel in TodoWrite.
- **Keep secrets secret.** API keys belong in `config.yml` or environment variables. The installer already adds `config.yml` to `.gitignore`.
- **Run Bun-friendly commands.** Specialists prefer `bun test`, `bun run lint`, etc. Avoid `npm` or `npx` unless absolutely necessary.
- **Review PRs like usual.** Each specialist returns PR URLs and notes. Merge when you are happy.
- **Clean worktrees when done.** After merging, run `git worktree remove .runs/<ticket>` to free disk space.

## Troubleshooting Cheat Sheet
| Symptom | Likely Cause | Quick Fix |
| --- | --- | --- |
| Orchestrator says "worktree mode disabled" | `.factory/orchestrator/config.json` set to `clone` or `branch` | Edit the file (or rerun installer) so `workspace.mode` is `"worktree"` |
| Droids cannot see MCP tools | MCP server not configured or disabled | `/mcp list` → ensure `linear`, `exa`, `ref` show `enabled`; add them if missing |
| Todo list looks duplicated | Multiple planning passes | Stick with orchestrator output; it updates the same TodoWrite list as tasks finish |
| Tests fail in a worktree | Missing dependencies inside worktree | Inside `.runs/<ticket>` run `bun install` or follow error hints |
| Installer overwrote files you edited | Running on top of local changes | Commit or stash before reinstall; README is now safe |

## Friendly Glossary
- **Git worktree:** A separate copy of your repository that shares history but has its own working folder. Droidz uses `.runs/<ticket>` folders so robots never bump into each other.
- **Task tool:** Factory’s way to launch a sub-agent. It streams every tool call so you can watch specialists work.
- **TodoWrite:** A tool that writes the entire to-do list at once. The orchestrator updates it every time something starts or finishes.
- **MCP (Model Context Protocol):** A plug system that lets droids talk to services like Linear (tickets), Exa (code/web search), or Ref (documentation).
- **Bun:** The JavaScript runtime Droidz uses for scripts, installs, and tests.

## Need More Help?
- **CHANGELOG.md** – See what changed last release.
- **Factory.ai docs** – `/settings` → open in browser, or visit [docs.factory.ai](https://docs.factory.ai).
- **Support the project** – If Droidz saves you time, consider saying thanks at [paypal.me/leebarry84](https://paypal.me/leebarry84).

Now grab your favourite snack, open the Factory CLI, and tell `/droidz-orchestrator` what to build. The robots have your back. 🤖✨
