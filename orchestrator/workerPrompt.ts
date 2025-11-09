import { SpecialistKind, TaskSpec } from "./types";

export function buildPrompt(kind: SpecialistKind, task: TaskSpec, agentsGuide?: string): string {
  const guide = agentsGuide ? `\nGuidelines (from AGENTS.md):\n${agentsGuide}\n` : "";
  const base = `You are a specialized ${kind} droid working in a Bun-only environment. Follow these constraints:
- Use Bun (bun run/test) for all scripts; do not use npm or npx.
- Where available, use the user's enabled MCP servers (e.g., code search, docs retrieval) to inform decisions; otherwise work with the repository and Linear context only.
- Match existing code style; add minimal comments only when necessary.
- Ensure tests and lint pass before marking complete.
- Use LINEAR_API_KEY from the environment for API operations; never print it.
- You are responsible for the full workflow for this ticket: set status to In Progress, create/check out branch, implement, test, commit, push, open PR, and post concise Linear comments.
${guide}
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
1) Create/check out branch ${task.branch}.
2) Set Linear issue to In Progress, then implement per role above.
3) Run: bun run lint (if available), bun test, and any build command.
4) If all pass, commit with a message that references ${task.key}, push, and open a PR.
5) Post a concise status comment to Linear.
6) Output a JSON summary at the end with keys: {"status":"success|blocked|failed","notes":"...","nextSteps":[],"branch":"${task.branch}","prUrl":""}`;

  return `${base}\n${role}\n\n${actions}`;
}
