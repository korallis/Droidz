#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import readline from "node:readline";
import { OrchestratorConfig, ProjectPlan } from "./types";
import { loadAgentsGuide, truncateGuide } from "./agents";

function rl() { return readline.createInterface({ input: process.stdin, output: process.stdout }); }
function ask(q: string) { const r = rl(); return new Promise<string>(res => r.question(q, a => { r.close(); res(a.trim()); })); }

async function loadConfig(root: string): Promise<OrchestratorConfig> {
  const p = path.join(root, "orchestrator", "config.json");
  return JSON.parse(await fs.readFile(p, "utf-8"));
}
async function saveConfig(root: string, cfg: OrchestratorConfig) {
  const p = path.join(root, "orchestrator", "config.json");
  await fs.writeFile(p, JSON.stringify(cfg, null, 2));
  console.log("Updated:", p);
}

async function runDroidJson(prompt: string, cwd: string, env?: Record<string,string>): Promise<any | null> {
  const p = Bun.spawn(["droid", "exec", "--output-format", "text", "--cwd", cwd, prompt], { stdout: "pipe", stderr: "pipe" /*, env*/ });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  if (err.trim()) console.error(err);
  const m = out.match(/\{[\s\S]*\}\s*$/);
  if (!m) return null;
  try { return JSON.parse(m[0]); } catch { return null; }
}

function planPrompt(idea: string): string {
  return `You are an expert product/tech planner. Turn the user's idea into a compact JSON plan for a Linear project.
- Keep it token-efficient and actionable for code droids.
- Use labels from this set only: ["frontend","backend","infra","test","refactor","integration"].
- Create 3-6 epics; each epic has 3-8 tasks.
- Each task must include a short description and 2-5 acceptance criteria.
- Output JSON ONLY, no prose, in this shape:
{
  "name": "Project Name",
  "description": "one-paragraph summary",
  "epics": [
    {"title":"...","description":"...","labels":["frontend"],"tasks":[
      {"title":"...","description":"...","labels":["frontend","test"],"acceptance":["...","..."]}
    ]}
  ]
}
User idea: ${idea}`;
}

async function main() {
  const root = process.cwd();
  const cfg = await loadConfig(root);
  const apiKey = cfg.linear.apiKey || "";
  if (!apiKey) {
    console.error("Missing linear.apiKey in orchestrator/config.json. Run setup first.");
    process.exit(1);
  }

  const idea = await ask("What's your project or feature idea? ");
  console.log("Planning...");
  const agents = await loadAgentsGuide(root);
  const agentsText = truncateGuide(agents.text);
  let plan = await runDroidJson(planPrompt(idea) + (agentsText?`\n\nGuidelines (AGENTS.md):\n${agentsText}`:""), root) as ProjectPlan | null;
  if (!plan) {
    console.error("Could not parse plan JSON from droid. Please try again with a clearer idea.");
    process.exit(1);
  }

  // Let user review/edit the plan
  const planPath = path.join(root, "orchestrator", "plan.json");
  await fs.writeFile(planPath, JSON.stringify(plan, null, 2));
  console.log(`\nProposed plan written to ${planPath}.`);
  const edit = await ask("Open plan for editing now? (y/N): ");
  if (edit.toLowerCase().startsWith("y")) {
    const editor = process.env.EDITOR || "vi";
    await Bun.spawn([editor, planPath]).exited;
    try { plan = JSON.parse(await fs.readFile(planPath, "utf-8")); } catch {
      console.error("Edited plan is not valid JSON. Aborting.");
      process.exit(1);
    }
  }
  const proceed = await ask("Create Linear project and tickets from this plan? (y/N): ");
  if (!proceed.toLowerCase().startsWith("y")) {
    console.log("Cancelled. You can re-run after adjusting the plan.");
    process.exit(0);
  }

  // Ask Droid to create Linear project and tickets per plan; return JSON summary
  const creationPrompt = `Create a Linear project and issues per the following plan JSON. Apply all best practices (naming, workflows/states, labels, parent/child tasks, dependency links). Use LINEAR_API_KEY from env; do not print the key. Output JSON ONLY with: {"projectId":"","projectName":"","teamId":"","issues":[{"id":"","identifier":"","title":""}]}
\nPlan JSON:\n\n${"```json"}\n${JSON.stringify(plan, null, 2)}\n${"```"}` + (agentsText?`\n\nGuidelines (AGENTS.md):\n${agentsText}`:"");
  const summary = await runDroidJson(creationPrompt, root, { LINEAR_API_KEY: apiKey });
  if (!summary || !summary.projectId) {
    console.error("Droid did not return a valid creation summary JSON. Aborting.");
    process.exit(1);
  }

  // Update config from Droid output
  cfg.linear.project = summary.projectName || plan.name;
  cfg.linear.projectId = summary.projectId;
  cfg.linear.teamId = summary.teamId || cfg.linear.teamId;
  await saveConfig(root, cfg);

  console.log("Project created in Linear by Droid:");
  console.log(`- ${cfg.linear.project} (${cfg.linear.projectId})`);
  if (Array.isArray(summary.issues)) {
    for (const t of summary.issues) console.log(`  - ${t.identifier} ${t.title}`);
  }
  console.log("Config updated with project and team IDs. You can now run orchestrator/run.ts to execute tasks.");
}

main().catch(err => { console.error(err); process.exit(1); });
