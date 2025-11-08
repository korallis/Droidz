## What “use Exa and Ref” means here
- Exa (and Exa Code): MCP search tools to pull external technical context and public code examples; also used by the router to raise confidence when ticket/domain is unclear. Examples: fetch framework docs detected in repo, find sample CI configs, or retrieve API usage patterns.
- Ref: MCP long‑lived memory/knowledge store. We persist per‑ticket run state, routing decisions, logs/links (branches/PRs), dependency graph, and checkpoints; lets the orchestrator resume/retry idempotently and produce summaries for Linear.

## Your constraints integrated
- Concurrency: default 10 (configurable).
- PR approvals: configurable in config.json (auto, require_manual, or disallow_push). Gate enforced before push/PR create.
- Repo‑aware specialists: on init, scan repo to infer stack (package.json, pyproject, go.mod, Dockerfiles, CI, tests). For empty/new repos, ask a short Q&A to generate the right specialists.
- Linear updates: always comment status+summary on the ticket for each major milestone and on completion.

## Files and structure
- .factory/droids/
  - orchestrator.droid.json — Orchestrator permissions/tools/policies
  - specialists/
    - codegen.droid.json, test.droid.json, infra.droid.json, refactor.droid.json, integration.droid.json, generalist.droid.json
- orchestrator/
  - config.json — user settings (see schema below)
  - routing.ts — label/keyword→droid rules + Exa‑assisted LLM fallback
  - run.ts — main loop: Linear fetch → route → spawn → monitor → update Linear
  - workers.ts — `droid exec` spawn helpers, workspace/branching, retries, secret scan, tests
  - reporters.ts — terminal live view + Linear commenter + optional Slack
  - detectors.ts — repo scan (stack detection) + Q&A flow

## config.json (example)
```json
{
  "linear": {"project": "Project X", "sprint": "Sprint 1", "updateComments": true},
  "concurrency": 10,
  "approvals": {"prs": "require_manual"},
  "workspace": {"baseDir": ".runs", "branchPattern": "{type}/{issueKey}-{slug}"},
  "guardrails": {"dryRun": false, "secretScan": true, "testsRequired": true, "maxJobMinutes": 120},
  "routing": {"rules": [{"labels": ["frontend"], "droid": "codegen"}, {"labels": ["backend"], "droid": "codegen"}, {"labels": ["infra","ci"], "droid": "infra"}, {"labels": ["refactor"], "droid": "refactor"}, {"labels": ["test","qa"], "droid": "test"}], "fallback": "generalist"}
}
```

## Orchestrator flow
1) Detect stack: scan repo; if unknown/empty, ask user Q&A; store results in Ref.
2) Fetch issues from Linear by project+sprint; build dependency graph.
3) Build TaskSpec per issue (id, title, labels, acceptance, repo/scripts inferred, dependency list) and persist to Ref.
4) Route to specialist: rules → if low confidence, consult Exa/Exa Code and LLM heuristic; persist decision in Ref.
5) Spawn worker via `droid exec` with TaskSpec and isolated workspace/branch; cap to `concurrency`.
6) Monitor: stream logs, secret scan, run lint/tests/build; on success open PR (respect approval policy); update Linear status and comment with summary/links; on failure retry with backoff or reroute to generalist.
7) Finalize: summarize sprint outcome; write rich summary to Ref and Linear.

## Specialist droids behavior (baseline)
- codegen: implement code changes; run lint/tests; create branch/PR with descriptive title/body.
- test: add/fix tests; ensure coverage delta non‑negative.
- infra: update CI/build/tooling; keep pipelines green.
- refactor: structural changes; ensure no breaking API unless ticket says so.
- integration: external services and glue code.
- generalist: safe fallback with conservative changes.

## Routing rules and Exa assist
- Primary: labels/components/keywords map directly to droids.
- Secondary: Exa docs lookup for framework/domain hints (e.g., "Next.js middleware"); Exa Code samples to confirm implementation patterns.
- Confidence threshold: if below X, route to generalist and tag for review.

## Commands (illustrative)
- Init/scaffold: `droidz init --interactive` → creates .factory/droids, config.json, and specialists; runs detectors and Q&A.
- Dry‑run plan: `droidz plan --project "Project X" --sprint "Sprint 1"` → prints routing plan and dependency order only.
- Execute: `droidz run --project "Project X" --sprint "Sprint 1" --concurrency 10`
- Approval: `droidz approve LIN-123` to allow PR for a gated task.

## Linear commenting format
- Start: "Starting work: LIN-123 — assigned to codegen.droid (branch feat/LIN-123-...); ETA ~45m"
- Progress: checklist of subtasks (analysis, edits, tests, PR created)
- Complete: summary of changes, links to branch/PR, test results, any follow‑ups

## Guardrails
- Always dry‑run available. Block pushes when approvals.prs != "auto".
- Secrets scan on diffs; abort/flag if detected.
- Tests must pass to mark done; configurable override per ticket via label.

## Next steps (on approval)
- Scaffold the droid configs and orchestrator scripts.
- Wire MCP servers (linear, exa/Exa Code, ref) and implement detectors/routing.
- Deliver the single‑command init/run experience with terminal progress and Linear updates.
