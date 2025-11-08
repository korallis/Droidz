#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import { OrchestratorConfig, TaskSpec } from "./types";
import { detectRepoProfile } from "./detectors";
import { fetchIssuesByProjectAndCycle, commentOnIssue } from "./linear";
import { routeSpecialist } from "./routing";
import { runSpecialist } from "./workers";

function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "").slice(0, 40);
}

async function loadConfig(root: string): Promise<OrchestratorConfig> {
  const p = path.join(root, "orchestrator", "config.json");
  const raw = await fs.readFile(p, "utf-8");
  return JSON.parse(raw);
}

function branchFromPattern(pattern: string, issueKey: string, title: string, type: string) {
  return pattern
    .replace("{type}", type)
    .replace("{issueKey}", issueKey)
    .replace("{slug}", slugify(title));
}

function topoSort<T extends { key: string; deps: string[] }>(items: T[]): T[] {
  const map = new Map(items.map(i => [i.key, i]));
  const indeg = new Map<string, number>();
  for (const i of items) indeg.set(i.key, 0);
  for (const i of items) for (const d of i.deps) if (map.has(d)) indeg.set(i.key, (indeg.get(i.key) || 0) + 1);
  const q: T[] = [];
  for (const i of items) if ((indeg.get(i.key) || 0) === 0) q.push(i);
  const out: T[] = [];
  while (q.length) {
    const n = q.shift()!;
    out.push(n);
    for (const m of items) if (m.deps.includes(n.key)) {
      indeg.set(m.key, (indeg.get(m.key) || 0) - 1);
      if ((indeg.get(m.key) || 0) === 0) q.push(m);
    }
  }
  return out.length === items.length ? out : items; // fallback
}

async function main() {
  const repoRoot = process.cwd();
  const cfg = await loadConfig(repoRoot);
  // simple args parser supporting flags without values
  const args = new Map<string, string | boolean>();
  for (let i = 2; i < process.argv.length; i++) {
    const tok = process.argv[i];
    if (tok.startsWith("--")) {
      const key = tok.slice(2);
      const next = process.argv[i + 1];
      if (!next || next.startsWith("--")) {
        args.set(key, true);
      } else {
        args.set(key, next);
        i++;
      }
    }
  }
  const project = (args.get("project") as string) || cfg.linear.project;
  const sprint = (args.get("sprint") as string) || cfg.linear.sprint;
  const concurrency = Number((args.get("concurrency") as string) || cfg.concurrency || 4);
  const planOnly = Boolean(args.get("plan"));

  const profile = await detectRepoProfile(repoRoot);
  console.log("Detected repo profile:", profile);

  let issues = await fetchIssuesByProjectAndCycle(cfg.linear.apiKey || "", project, sprint);
  if (!issues.length) {
    console.log(`No issues found for project='${project}' and sprint='${sprint}'. Falling back to project-only.`);
    const { fetchIssuesByProject } = await import("./linear");
    issues = await fetchIssuesByProject(cfg.linear.apiKey || "", project);
  }
  if (!issues.length) {
    console.log("No issues found.");
    return;
  }

  const tasks: TaskSpec[] = issues.map(iss => {
    const specialist = routeSpecialist(iss.labels, cfg);
    const branch = branchFromPattern(cfg.workspace.branchPattern, iss.identifier, iss.title, specialist);
    return {
      id: iss.id,
      key: iss.identifier,
      title: iss.title,
      description: iss.description,
      labels: iss.labels,
      acceptance: [],
      deps: iss.blockedBy,
      repoDir: repoRoot,
      branch,
      specialist,
    };
  });

  const order = topoSort(tasks);
  console.log(`Planning ${tasks.length} tasks with concurrency ${concurrency}`);

  if (planOnly || cfg.guardrails.dryRun) {
    const plan = order.map(t => ({ key: t.key, title: t.title, specialist: t.specialist, branch: t.branch, deps: t.deps }));
    console.log("Plan (no execution):\n" + JSON.stringify({ project, sprint, total: plan.length, plan }, null, 2));
    return;
  }

  // Simple pool
  const queue = [...order];
  const running = new Set<Promise<void>>();
  async function spawnNext() {
    if (!queue.length) return;
    const t = queue.shift()!;
    const p = (async () => {
      try {
        if (cfg.linear.updateComments) await commentOnIssue(cfg.linear.apiKey || "", t.key, `Queued for execution with ${t.specialist}.`);
        await runSpecialist(t, cfg, repoRoot);
      } catch (e: any) {
        console.error(`Task ${t.key} failed:`, e.message || e);
        if (cfg.linear.updateComments) await commentOnIssue(cfg.linear.apiKey || "", t.key, `Failed: ${"```"}${String(e)}${"```"}`);
      } finally {
        running.delete(pr);
        await spawnNext();
      }
    })();
    const pr = p; // alias for finally closure
    running.add(pr);
  }

  const starters = Math.min(concurrency, queue.length);
  for (let i = 0; i < starters; i++) await spawnNext();
  await Promise.all(Array.from(running));
  console.log("All tasks complete.");
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
