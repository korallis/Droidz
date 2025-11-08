#!/usr/bin/env bun
import path from "path";
import { promises as fs } from "fs";
import readline from "node:readline";
import { OrchestratorConfig } from "./types";
import { validateEnvironment } from "./validators";
import { findProjectByName, findCycleByName } from "./linear";

function rl() { return readline.createInterface({ input: process.stdin, output: process.stdout }); }
function ask(q: string) { const r = rl(); return new Promise<string>(res => r.question(q, a => { r.close(); res(a.trim()); })); }

async function loadConfig(root: string): Promise<OrchestratorConfig | null> {
  try { return JSON.parse(await fs.readFile(path.join(root, "orchestrator", "config.json"), "utf-8")); } catch { return null; }
}
async function saveConfig(root: string, cfg: OrchestratorConfig) {
  const p = path.join(root, "orchestrator", "config.json");
  await fs.mkdir(path.dirname(p), { recursive: true });
  await fs.writeFile(p, JSON.stringify(cfg, null, 2));
}

async function spawn(cmd: string, args: string[], cwd: string) {
  const p = Bun.spawn([cmd, ...args], { cwd, stdout: "pipe", stderr: "pipe" });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  const code = await p.exited;
  return { code, out, err };
}

async function main() {
  const root = process.cwd();
  let cfg = await loadConfig(root);
  if (!cfg) {
    console.log("No config found. Running setup...");
    await spawn("bun", [path.join("orchestrator", "setup.ts")], root);
    cfg = await loadConfig(root);
    if (!cfg) { console.error("Setup failed to generate config."); process.exit(1); }
  }

  console.log("Validating environment...");
  const checks = await validateEnvironment(cfg.linear.apiKey);
  for (const c of checks) console.log(`- ${c.name}: ${c.ok ? "OK" : "MISSING"}${c.info?` (${c.info})`:""}`);

  const useNew = (await ask("Create a NEW Linear project from an idea? (y/N): ")).toLowerCase().startsWith("y");
  if (useNew) {
    const res = await spawn("bun", [path.join("orchestrator", "new-project.ts")], root);
    if (res.code !== 0) { console.error(res.err || res.out); process.exit(1); }
    cfg = await loadConfig(root);
  } else {
    // Ensure existing project is valid
    const name = (await ask(`Existing Linear project name [${cfg!.linear.project}]: `)) || cfg!.linear.project;
    const proj = await findProjectByName(cfg!.linear.apiKey || "", name);
    if (!proj) { console.error(`Project '${name}' not found.`); process.exit(1); }
    cfg!.linear.project = proj.name;
    cfg!.linear.projectId = proj.id;

    // Derive team and ensure standard labels exist
    const { getProjectTeam, getOrCreateLabel } = await import("./linear");
    const team = await getProjectTeam(cfg!.linear.apiKey || "", proj.id);
    if (team) {
      cfg!.linear.teamId = team.id;
      const stdLabels = ["frontend","backend","infra","test","refactor","integration","epic"];
      for (const L of stdLabels) await getOrCreateLabel(cfg!.linear.apiKey || "", L, team.id);
    }

    const setSprint = (await ask(`Set sprint/cycle name? Current [${cfg!.linear.sprint}] (leave blank to keep): `));
    if (setSprint) {
      const cyc = await findCycleByName(cfg!.linear.apiKey || "", setSprint);
      if (!cyc) console.warn(`Cycle '${setSprint}' not found (team cycles may be auto-managed). We'll proceed without cycle filter.`);
      cfg!.linear.sprint = setSprint;
    }
    await saveConfig(root, cfg!);
  }

  console.log("\nClarify run settings (press Enter to keep current):");
  const conc = await ask(`Concurrency [${cfg!.concurrency}]: `);
  if (conc) cfg!.concurrency = Math.max(1, parseInt(conc, 10) || cfg!.concurrency);
  const appr = await ask(`Approvals (auto|require_manual|disallow_push) [${cfg!.approvals.prs}]: `);
  if (appr) cfg!.approvals.prs = appr as any;
  const upd = await ask(`Update Linear comments? (y/n) [${cfg!.linear.updateComments?"y":"n"}]: `);
  if (upd) cfg!.linear.updateComments = upd.toLowerCase().startsWith("y");
  const wt = await ask(`Use git worktrees for parallel tasks? (y/n) [${cfg!.workspace.useWorktrees!==false?"y":"n"}]: `);
  if (wt) cfg!.workspace.useWorktrees = wt.toLowerCase().startsWith("y");
  await saveConfig(root, cfg!);

  console.log("\nReady for execution?");
  const doPlan = (await ask("Run a dry-run plan first? (Y/n): ")) || "y";
  if (doPlan.toLowerCase().startsWith("y")) {
    const res = await spawn("bun", [path.join("orchestrator", "run.ts"), "--project", cfg!.linear.project, "--sprint", cfg!.linear.sprint, "--concurrency", String(cfg!.concurrency), "--plan"], root);
    console.log(res.out); if (res.err.trim()) console.error(res.err);
  }
  const start = (await ask("Start execution now? (y/N): ")).toLowerCase().startsWith("y");
  if (start) {
    const res = await spawn("bun", [path.join("orchestrator", "run.ts"), "--project", cfg!.linear.project, "--sprint", cfg!.linear.sprint, "--concurrency", String(cfg!.concurrency)], root);
    console.log(res.out); if (res.err.trim()) console.error(res.err);
  } else {
    console.log("You can start later with: bun orchestrator/run.ts --project \"...\" --sprint \"...\" --concurrency N");
  }
}

main().catch(err => { console.error(err); process.exit(1); });
