#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import readline from "node:readline";
import { OrchestratorConfig, ProjectPlan, EpicPlan, TaskPlan } from "./types";
import { listTeams, createProject, createIssue, getOrCreateLabel } from "./linear";

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

async function runDroidPlan(prompt: string, cwd: string): Promise<ProjectPlan | null> {
  const p = Bun.spawn(["droid", "exec", "--output-format", "text", "--cwd", cwd, prompt], { stdout: "pipe", stderr: "pipe" });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  if (err.trim()) console.error(err);
  // Extract last JSON block
  const m = out.match(/\{[\s\S]*\}\s*$/);
  if (!m) return null;
  try { return JSON.parse(m[0]) as ProjectPlan; } catch { return null; }
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
  const plan = await runDroidPlan(planPrompt(idea), root);
  if (!plan) {
    console.error("Could not parse plan JSON from droid. Please try again with a clearer idea.");
    process.exit(1);
  }

  // Choose team
  const teams = await listTeams(apiKey);
  if (!teams.length) { console.error("No Linear teams available."); process.exit(1); }
  console.log("Select a Linear team:");
  teams.forEach((t, i) => console.log(`${i+1}) ${t.name}${t.key?` (${t.key})`:''}`));
  const idxStr = await ask(`Team number [1-${teams.length}]: `);
  const idx = Math.max(1, Math.min(teams.length, parseInt(idxStr || "1", 10))) - 1;
  const team = teams[idx];

  // Create project
  console.log(`Creating Linear project: ${plan.name}`);
  const proj = await createProject(apiKey, plan.name, plan.description, team.id);

  // Ensure standard labels
  const stdLabels = ["frontend","backend","infra","test","refactor","integration","epic"];
  const labelMap: Record<string,string> = {};
  for (const L of stdLabels) labelMap[L] = await getOrCreateLabel(apiKey, L, team.id);

  // Create epics and tasks
  const created: Array<{ epicTitle: string; epicId: string; tasks: Array<{ id: string; identifier: string; title: string }> }> = [];
  for (const epic of plan.epics) {
    const epicLabels = [labelMap["epic"], ...(epic.labels||[]).map(l => labelMap[l]).filter(Boolean)];
    const epicIssue = await createIssue(apiKey, {
      teamId: team.id,
      projectId: proj.id,
      title: epic.title,
      description: epic.description || "",
      labelIds: epicLabels
    });
    const epicTasks: Array<{ id: string; identifier: string; title: string }> = [];
    for (const task of epic.tasks) {
      const taskLabels = (task.labels||[]).map(l => labelMap[l]).filter(Boolean);
      const desc = `${task.description||""}\n\nAcceptance Criteria:\n- ${(task.acceptance||[]).join("\n- ")}`.trim();
      const issue = await createIssue(apiKey, {
        teamId: team.id,
        projectId: proj.id,
        parentId: epicIssue.id,
        title: task.title,
        description: desc,
        labelIds: taskLabels
      });
      epicTasks.push({ id: issue.id, identifier: issue.identifier, title: task.title });
    }
    created.push({ epicTitle: epic.title, epicId: epicIssue.id, tasks: epicTasks });
  }

  // Update config
  cfg.linear.project = proj.name;
  cfg.linear.projectId = proj.id;
  cfg.linear.teamId = team.id;
  await saveConfig(root, cfg);

  console.log("Project created in Linear:");
  console.log(`- ${proj.name}`);
  for (const e of created) {
    console.log(`  Epic: ${e.epicTitle} (${e.epicId})`);
    for (const t of e.tasks) console.log(`    - ${t.identifier} ${t.title}`);
  }
  console.log("Config updated with project and team IDs. You can now run orchestrator/run.ts to execute tasks.");
}

main().catch(err => { console.error(err); process.exit(1); });
