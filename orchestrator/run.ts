#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import { OrchestratorConfig, TaskSpec } from "./types";
import { detectRepoProfile } from "./detectors";
import { routeSpecialist } from "./routing";
import { runSpecialist } from "./workers";
import { loadAgentsGuide, truncateGuide } from "./agents";

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

async function runDroidJson(prompt: string, cwd: string): Promise<any | null> {
  const p = Bun.spawn(["droid", "exec", "--output-format", "text", "--cwd", cwd, prompt], { stdout: "pipe", stderr: "pipe" });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  if (err.trim()) console.error(err);
  const m = out.match(/\{[\s\S]*\}\s*$/);
  if (!m) return null;
  try { return JSON.parse(m[0]); } catch { return null; }
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
  let concurrency = Number((args.get("concurrency") as string) || cfg.concurrency || 4);
  const planOnly = Boolean(args.get("plan"));
  const planFile = (args.get("plan-file") as string) || "";


  const profile = await detectRepoProfile(repoRoot);
  console.log("Detected repo profile:", profile);

  // Ask Droid to list issues for this project (and sprint if provided)
  const agents = await loadAgentsGuide(repoRoot);
  const agentsText = truncateGuide(agents.text);
  const listPrompt = `List all issues for Linear project \"${project}\"${sprint?` in sprint/cycle \"${sprint}\"`:''} as compact JSON ONLY: {"issues":[{"id":"","identifier":"","title":"","description":"","labels":[],"blockedBy":[]}]}\nUse LINEAR_API_KEY from env. Do not print secrets.` + (agentsText?`\n\nGuidelines (AGENTS.md):\n${agentsText}`:"");
  const resJson = await runDroidJson(listPrompt, repoRoot);
  const issues = Array.isArray(resJson?.issues) ? resJson.issues : [];
  if (!issues.length) { console.log("No issues found."); return; }

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

  let order = topoSort(tasks);
  // Apply plan override if provided
  if (planFile) {
    try {
      const raw = await fs.readFile(path.resolve(planFile), "utf-8");
      const override = JSON.parse(raw) as { plan: Array<{ key: string }> };
      const orderMap = new Map(order.map((t, i) => [t.key, t]));
      const overridden: TaskSpec[] = [];
      for (const p of override.plan || []) if (orderMap.has(p.key)) overridden.push(orderMap.get(p.key)!);
      const rest = order.filter(t => !overridden.find(o => o.key === t.key));
      order = [...overridden, ...rest];
    } catch (e) {
      console.warn("Could not apply plan-file override:", String(e));
    }
  }

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
        await runSpecialist(t, cfg, repoRoot);
      } catch (e: any) {
        console.error(`Task ${t.key} failed:`, e.message || e);
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
