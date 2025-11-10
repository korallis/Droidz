#!/usr/bin/env bun
import path from "path";
import { promises as fs } from "fs";
import readline from "node:readline";
import { OrchestratorConfig } from "./types";
import { validateEnvironment, validateWorkspaceMode } from "./validators";
import { findProjectByName, findCycleByName } from "./linear";

function rl() { return readline.createInterface({ input: process.stdin, output: process.stdout }); }
function ask(q: string) { const r = rl(); return new Promise<string>(res => r.question(q, a => { r.close(); res(a.trim()); })); }

async function spawnInteractive(cmd: string, args: string[], cwd: string) {
  const p = Bun.spawn([cmd, ...args], { cwd, stdin: "inherit", stdout: "inherit", stderr: "inherit" });
  const code = await p.exited;
  return { code };
}

async function ensureGitRepo(root: string) {
  const p = Bun.spawn(["git", "rev-parse", "--is-inside-work-tree"], { cwd: root, stdout: "pipe", stderr: "pipe" });
  const code = await p.exited;
  if (code === 0) return;
  const ans = await ask("No git repo found here. Initialize git now? (y/N): ");
  if (!ans.toLowerCase().startsWith("y")) return;
  await Bun.spawn(["git", "init"], { cwd: root, stdin: "inherit", stdout: "inherit", stderr: "inherit" }).exited;
  // Ensure we don't commit secrets or temp files
  const gi = path.join(root, ".gitignore");
  try {
    const existing = await fs.readFile(gi, "utf-8").catch(() => "");
    const lines = new Set(existing.split(/\r?\n/).filter(Boolean));
    ["/orchestrator/config.json", "/orchestrator/plan.json", "/.runs/"].forEach(l => lines.add(l));
    await fs.writeFile(gi, Array.from(lines).join("\n") + "\n");
  } catch {}
  console.log("Git initialized.");
}

async function ensureGitRemote(root: string) {
  // Get existing remotes
  const rem = await Bun.spawn(["git", "remote", "-v"], { cwd: root, stdout: "pipe", stderr: "pipe" });
  const out = await new Response(rem.stdout).text();
  const names = Array.from(new Set(out.split(/\r?\n/).map(l => l.split(/\s+/)[0]).filter(Boolean)));
  const hasAny = names.length > 0;
  const q = hasAny ? "Create another git remote? (y/N): " : "No git remote set. Create one now? (y/N): ";
  const ans = await ask(q);
  if (!ans.toLowerCase().startsWith("y")) return;
  const defaultName = names.includes("origin") ? "origin-2" : "origin";
  const name = (await ask(`Remote name [${defaultName}]: `)) || defaultName;
  const url = await ask("Remote URL (e.g., https://github.com/user/repo.git or git@github.com:user/repo.git): ");
  if (!url) { console.log("No URL provided. Skipping remote setup."); return; }
  const add = await Bun.spawn(["git", "remote", "add", name, url], { cwd: root, stdin: "inherit", stdout: "inherit", stderr: "inherit" });
  const addCode = await add.exited;
  if (addCode === 0) console.log(`Remote '${name}' added → ${url}`);
  else {
    const err = await new Response(add.stderr).text();
    console.warn("Failed to add remote:", err.trim());
  }
}

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

function isApiKeyValid(k?: string) {
  if (!k) return false;
  if (k.includes("__PUT_YOUR_LINEAR_API_KEY_HERE__")) return false;
  return k.length >= 10;
}

async function main() {
  const root = process.cwd();
  let cfg = await loadConfig(root);
  if (!cfg) {
    console.log("No config found. Running setup...");
    await spawnInteractive("bun", [path.join("orchestrator", "setup.ts")], root);
    cfg = await loadConfig(root);
    if (!cfg) { console.error("Setup failed to generate config."); process.exit(1); }
  }
  // Ensure Linear API key exists before continuing
  if (!isApiKeyValid(cfg.linear.apiKey)) {
    console.log("Linear API key is missing. Opening setup to capture it...");
    await spawnInteractive("bun", [path.join("orchestrator", "setup.ts")], root);
    cfg = await loadConfig(root);
    if (!isApiKeyValid(cfg?.linear?.apiKey)) { console.error("Linear API key still missing. Aborting."); process.exit(1); }
  }

  await ensureGitRepo(root);
  await ensureGitRemote(root);

  console.log("Validating environment...");
  const checks = await validateEnvironment(cfg.linear.apiKey);
  for (const c of checks) console.log(`- ${c.name}: ${c.ok ? "OK" : "MISSING"}${c.info?` (${c.info})`:""}`);
  
  // Validate workspace mode for parallel execution
  console.log("\nValidating workspace configuration...");
  validateWorkspaceMode(cfg);
  
  // Ensure baseline custom droids exist
  try {
    await Bun.spawn(["bun", path.join("orchestrator", "generate-droids.ts")]).exited;
  } catch {}

  const useNew = (await ask("Create a NEW Linear project from an idea? (y/N): ")).toLowerCase().startsWith("y");
  if (useNew) {
    // Choose workspace mode up front for clarity
    const wt = await ask(`Workspace mode (worktree|clone|branch) [${cfg!.workspace.mode || (cfg!.workspace.useWorktrees===false?"branch":"worktree")}]: `);
    if (wt) cfg!.workspace.mode = wt as any;
    await saveConfig(root, cfg!);

    const res = await spawnInteractive("bun", [path.join("orchestrator", "new-project.ts")], root);
    if (res.code !== 0) { console.error("New project setup failed."); process.exit(1); }
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
  if (!cfg!.workspace.mode) {
    const mode = await ask(`Workspace mode (worktree|clone|branch) [worktree]: `);
    if (mode) cfg!.workspace.mode = mode as any;
  }
  const am = await ask(`Enable auto-merge after PR when checks pass? (y/n) [${cfg!.merge?.autoMerge?"y":"n"}]: `);
  if (am) cfg!.merge = { ...(cfg!.merge||{}), autoMerge: am.toLowerCase().startsWith("y") } as any;
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
