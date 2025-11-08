import { SpecialistKind, TaskSpec } from "./types";

export function buildPrompt(kind: SpecialistKind, task: TaskSpec): string {
  const base = `You are a specialized ${kind} droid working in a Bun-only environment. Follow these constraints:
- Use Bun (bun run/test) for all scripts; do not use npm or npx.
- Work with the repository and Linear context only; avoid referencing internal tooling not available to this app.
- Match existing code style; add minimal comments only when necessary.
- Ensure tests and lint pass before marking complete.
- Never push or create PRs unless explicitly instructed by the orchestrator prompt.

Task:
- Linear ${task.key}: ${task.title}
- Acceptance: ${(task.acceptance||[]).join("; ")||"N/A"}
- Labels: ${task.labels.join(", ")}
- Branch: ${task.branch}
- Repo dir: ${task.repoDir}
- Dependencies: ${task.deps.join(", ") || "none"}
`;

  const role = (() => {
    switch (kind) {
      case "codegen":
        return "Implement the requested feature/fix with production-quality code. Create or update files as needed. Update or add tests. Run bun test. Commit changes.";
      case "test":
        return "Write or fix tests to satisfy acceptance and stabilize flaky areas. Use bun test. Commit test-only changes unless code changes are required.";
      case "infra":
        return "Modify CI/build/tooling. Keep pipelines green. Prefer minimal diffs. Update bun scripts if needed.";
      case "refactor":
        return "Refactor to improve structure without changing behavior unless stated. Keep diffs focused and safe.";
      case "integration":
        return "Integrate external services/APIs. Handle secrets via env vars; do not hardcode. Provide integration tests or mocks.";
      default:
        return "Generalist: analyze the ticket and make the safest changes to progress it towards completion with tests.";
    }
  })();

  const actions = `Actions to perform now:
1) Create and checkout branch ${task.branch}.
2) Implement work per role above.
3) Run: bun run lint (if available), bun test, and any build command.
4) If all pass, create a local commit with a clear message referencing ${task.key}.
5) Output a concise JSON summary at the end with keys: {"status":"success|blocked|failed","notes":"...","nextSteps":[],"branch":"${task.branch}"}`;

  return `${base}\n${role}\n\n${actions}`;
}
