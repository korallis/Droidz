#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import { detectRepoProfile } from "./detectors";
import { OrchestratorConfig, SpecialistKind } from "./types";
import readline from "node:readline";

function rl() {
  return readline.createInterface({ input: process.stdin, output: process.stdout });
}

async function question(q: string, mask = false): Promise<string> {
  if (!mask) {
    const r = rl();
    return new Promise(res => r.question(q, ans => { r.close(); res(ans.trim()); }));
  }
  // masked input
  const r = readline.createInterface({ input: process.stdin, output: process.stdout });
  (r as any)._writeToOutput = (str: string) => {
    if (str.toLowerCase().includes(q.toLowerCase())) {
      (r as any).output.write(q);
    } else if (str.trim()) {
      (r as any).output.write("*");
    }
  };
  return new Promise(res => r.question(q, ans => { r.close(); res(ans.trim()); }));
}

async function loadConfig(repoRoot: string): Promise<OrchestratorConfig | null> {
  const p = path.join(repoRoot, "orchestrator", "config.json");
  try { return JSON.parse(await fs.readFile(p, "utf-8")); } catch { return null; }
}

async function saveConfig(repoRoot: string, cfg: OrchestratorConfig) {
  const p = path.join(repoRoot, "orchestrator", "config.json");
  await fs.mkdir(path.dirname(p), { recursive: true });
  await fs.writeFile(p, JSON.stringify(cfg, null, 2));
  console.log("Saved:", p);
}

function d<T>(v: T, def: T): T { return (v === undefined || v === null || v === "" as any) ? def : v; }

async function main() {
  const repoRoot = process.cwd();
  const existing = await loadConfig(repoRoot);
  const profile = await detectRepoProfile(repoRoot);
  console.log("Detected repo profile:", profile);

  const apiKey = d(await question(`Linear API key${existing?.linear?.apiKey?" (leave blank to keep)":""}: `, true), existing?.linear?.apiKey || "");
  const project = d(await question(`Linear Project name${existing?.linear?.project?` [${existing.linear.project}]`:""}: `), existing?.linear?.project || "Project X");
  const sprint = d(await question(`Sprint/Cycle name${existing?.linear?.sprint?` [${existing.linear.sprint}]`:""}: `), existing?.linear?.sprint || "Sprint 1");
  const updateCommentsStr = d(await question(`Update Linear with comments? (y/n)${existing?.linear?.updateComments!==undefined?` [${existing.linear.updateComments?"y":"n"}]`:" [y]"}: `), existing?.linear?.updateComments===undefined?"y":(existing.linear.updateComments?"y":"n"));
  const updateComments = String(updateCommentsStr).toLowerCase().startsWith("y");

  const concurrencyStr = d(await question(`Max parallel tasks${existing?.concurrency?` [${existing.concurrency}]`:" [10]"}: `), String(existing?.concurrency ?? 10));
  const concurrency = Math.max(1, parseInt(concurrencyStr, 10) || 10);

  const approvals = d(await question(`PR approvals mode: auto | require_manual | disallow_push${existing?.approvals?.prs?` [${existing.approvals.prs}]`:" [require_manual]"}: `), existing?.approvals?.prs || "require_manual");

  const baseDir = d(await question(`Workspace base dir${existing?.workspace?.baseDir?` [${existing.workspace.baseDir}]`:" [.runs]"}: `), existing?.workspace?.baseDir || ".runs");
  const branchPattern = d(await question(`Branch pattern${existing?.workspace?.branchPattern?` [${existing.workspace.branchPattern}]`:" [{type}/{issueKey}-{slug}]"}: `), existing?.workspace?.branchPattern || "{type}/{issueKey}-{slug}");

  const dryRunStr = d(await question(`Default dry-run mode? (y/n)${existing?.guardrails?.dryRun!==undefined?` [${existing.guardrails.dryRun?"y":"n"}]`:" [n]"}: `), existing?.guardrails?.dryRun?"y":"n");
  const dryRun = String(dryRunStr).toLowerCase().startsWith("y");

  const secretScanStr = d(await question(`Secret-scan diffs? (y/n)${existing?.guardrails?.secretScan!==undefined?` [${existing.guardrails.secretScan?"y":"n"}]`:" [y]"}: `), existing?.guardrails?.secretScan===undefined?"y":(existing.guardrails.secretScan?"y":"n"));
  const secretScan = String(secretScanStr).toLowerCase().startsWith("y");

  const testsRequiredStr = d(await question(`Require tests to pass? (y/n)${existing?.guardrails?.testsRequired!==undefined?` [${existing.guardrails.testsRequired?"y":"n"}]`:" [y]"}: `), existing?.guardrails?.testsRequired===undefined?"y":(existing.guardrails.testsRequired?"y":"n"));
  const testsRequired = String(testsRequiredStr).toLowerCase().startsWith("y");

  const maxJobMinutesStr = d(await question(`Max job minutes${existing?.guardrails?.maxJobMinutes?` [${existing.guardrails.maxJobMinutes}]`:" [120]"}: `), String(existing?.guardrails?.maxJobMinutes ?? 120));
  const maxJobMinutes = Math.max(1, parseInt(maxJobMinutesStr, 10) || 120);

  const defaultRouting = existing?.routing ?? { rules: [
    { labels: ["frontend"], droid: "codegen" },
    { labels: ["backend"], droid: "codegen" },
    { labels: ["infra", "ci"], droid: "infra" },
    { labels: ["refactor"], droid: "refactor" },
    { labels: ["test", "qa"], droid: "test" }
  ], fallback: "generalist" as SpecialistKind };

  const cfg: OrchestratorConfig = {
    linear: { project, sprint, updateComments, apiKey },
    concurrency,
    approvals: { prs: approvals as any },
    workspace: { baseDir, branchPattern },
    guardrails: { dryRun, secretScan, testsRequired, maxJobMinutes },
    routing: defaultRouting,
    profile,
    specialists: [
      { name: "codegen", enabled: true },
      { name: "test", enabled: true },
      { name: "infra", enabled: true },
      { name: "refactor", enabled: true },
      { name: "integration", enabled: true },
      { name: "generalist", enabled: true }
    ]
  };

  await saveConfig(repoRoot, cfg);

  const planNow = (await question("Run a dry-run plan now? (y/n) [y]: ", false)) || "y";
  if (planNow.toLowerCase().startsWith("y")) {
    const p = Bun.spawn(["bun", path.join("orchestrator", "run.ts"), "--project", project, "--sprint", sprint, "--concurrency", String(concurrency), "--plan"]);
    const out = await new Response(p.stdout).text();
    const err = await new Response(p.stderr).text();
    console.log(out);
    if (err.trim()) console.error(err);
  }
}

main().catch(err => { console.error(err); process.exit(1); });
