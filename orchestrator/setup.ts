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

  // Ask for Linear API key (required for new/existing project flows)
  const placeholder = "__PUT_YOUR_LINEAR_API_KEY_HERE__";
  let apiKeyInput = await question(`Linear API key${existing?.linear?.apiKey?" (leave blank to keep)":""}: `, true);
  // Keep existing only if it's valid and user leaves blank
  let apiKey = apiKeyInput || (existing?.linear?.apiKey || "");
  while (!apiKey || apiKey === placeholder) {
    console.log("A Linear API key is required. Find it in Linear → Settings → API Keys.");
    apiKey = await question("Paste Linear API key: ", true);
  }
  const project = d(await question(`Linear Project name${existing?.linear?.project?` [${existing.linear.project}]`:""}: `), existing?.linear?.project || "Project X");
  const sprint = d(await question(`Sprint/Cycle name${existing?.linear?.sprint?` [${existing.linear.sprint}]`:""}: `), existing?.linear?.sprint || "Sprint 1");
  const updateCommentsStr = d(await question(`Update Linear with comments? (y/n)${existing?.linear?.updateComments!==undefined?` [${existing.linear.updateComments?"y":"n"}]`:" [y]"}: `), existing?.linear?.updateComments===undefined?"y":(existing.linear.updateComments?"y":"n"));
  const updateComments = String(updateCommentsStr).toLowerCase().startsWith("y");

  const concurrencyStr = d(await question(`Max parallel tasks${existing?.concurrency?` [${existing.concurrency}]`:" [10]"}: `), String(existing?.concurrency ?? 10));
  const concurrency = Math.max(1, parseInt(concurrencyStr, 10) || 10);

  const approvals = d(await question(`PR approvals mode: auto | require_manual | disallow_push${existing?.approvals?.prs?` [${existing.approvals.prs}]`:" [require_manual]"}: `), existing?.approvals?.prs || "require_manual");

  const baseDir = d(await question(`Workspace base dir${existing?.workspace?.baseDir?` [${existing.workspace.baseDir}]`:" [.runs]"}: `), existing?.workspace?.baseDir || ".runs");
  const branchPattern = d(await question(`Branch pattern${existing?.workspace?.branchPattern?` [${existing.workspace.branchPattern}]`:" [{type}/{issueKey}-{slug}]"}: `), existing?.workspace?.branchPattern || "{type}/{issueKey}-{slug}");
  let mode = d(await question(`Workspace mode (worktree | clone | branch)${existing?.workspace?.mode?` [${existing.workspace.mode}]`:" [worktree]"}: `), existing?.workspace?.mode || (existing?.workspace?.useWorktrees===false ? "branch" : "worktree"));

  // VALIDATION: Warn if user chose non-optimal settings
  if (mode !== "worktree") {
    console.log("\n⚠️  WARNING: You selected workspace mode '" + mode + "'");
    console.log("   Droidz's core feature is PARALLEL EXECUTION using git worktrees.");
    console.log("   Without worktrees, parallel workers may conflict or run slower.");
    console.log("   RECOMMENDED: Use 'worktree' mode for best performance (3-5x faster).");
    const confirm = await question("\n   Continue with '" + mode + "' mode anyway? (y/N): ");
    if (!confirm.toLowerCase().startsWith("y")) {
      console.log("   ✅ Switching to 'worktree' mode for optimal parallel execution...");
      mode = "worktree";
    }
  }
  
  // VALIDATION: Warn about low concurrency
  if (concurrency < 3) {
    console.log("\n⚠️  WARNING: Concurrency is set to " + concurrency);
    console.log("   Low concurrency limits parallel execution benefits.");
    console.log("   RECOMMENDED: Use 5-10 workers for typical features (default: 5).");
  }

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
    workspace: { baseDir, branchPattern, mode, useWorktrees: mode === "worktree" ? true : (mode === "branch" ? false : undefined) },
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

  // Merge behavior options
  const autoMergeStr = d(await question(`Enable auto-merge after PR when checks pass? (y/n)${existing?.merge?.autoMerge!==undefined?` [${existing.merge.autoMerge?"y":"n"}]`:" [n]"}: `), existing?.merge?.autoMerge?"y":"n");
  const autoMerge = String(autoMergeStr).toLowerCase().startsWith("y");
  const mergeStrategy = d(await question(`Merge strategy (squash|merge|rebase)${existing?.merge?.strategy?` [${existing.merge.strategy}]`:" [squash]"}: `), existing?.merge?.strategy || "squash");
  const requireChecksStr = d(await question(`Require checks for merge? (y/n)${existing?.merge?.requireChecks!==undefined?` [${existing.merge.requireChecks?"y":"n"}]`:" [y]"}: `), existing?.merge?.requireChecks===undefined?"y":(existing.merge.requireChecks?"y":"n"));
  const requireChecks = String(requireChecksStr).toLowerCase().startsWith("y");
  const reviewStateName = d(await question(`State name for PRs awaiting review${existing?.merge?.reviewStateName?` [${existing.merge.reviewStateName}]`:" [In Review]"}: `), existing?.merge?.reviewStateName || "In Review");
  const doneStateName = d(await question(`State name for completed issues${existing?.merge?.doneStateName?` [${existing.merge.doneStateName}]`:" [Done]"}: `), existing?.merge?.doneStateName || "Done");

  cfg.merge = { autoMerge, strategy: mergeStrategy as any, requireChecks, reviewStateName, doneStateName };

  await saveConfig(repoRoot, cfg);

  // Generate baseline custom droids
  try {
    const pGen = Bun.spawn(["bun", path.join("orchestrator", "generate-droids.ts")]);
    await pGen.exited;
  } catch (e) {
    console.warn("Could not generate custom droids:", String(e));
  }

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
