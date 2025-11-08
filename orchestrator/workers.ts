import { spawn } from "bun";
import path from "path";
import { buildPrompt } from "./workerPrompt";
import { OrchestratorConfig, TaskSpec } from "./types";
import { commentOnIssue, getTeamStartedStateId, setIssueState, getProjectTeam } from "./linear";

async function run(cmd: string, args: string[], cwd: string): Promise<{ code: number; stdout: string; stderr: string }> {
  const p = spawn([cmd, ...args], { cwd, stdout: "pipe", stderr: "pipe" });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  const code = await p.exited;
  return { code, stdout: out, stderr: err };
}

async function prepareWorkspace(repoRoot: string, baseDir: string, branch: string, key: string, useWorktrees: boolean | undefined): Promise<string> {
  const workDir = path.resolve(repoRoot, baseDir, key);
  await run("mkdir", ["-p", workDir], repoRoot);

  // Ensure this is a git repo
  const isGit = await run("git", ["rev-parse", "--is-inside-work-tree"], repoRoot);
  if (isGit.code !== 0) throw new Error("Not a git repository. Initialize git and add a remote 'origin' to use parallel branches/PRs.");

  await run("git", ["fetch", "--all"], repoRoot);

  if (useWorktrees !== false) {
    // Worktree mode
    await run("git", ["worktree", "remove", "-f", workDir], repoRoot).catch(() => {});
    const res = await run("git", ["worktree", "add", "-B", branch, workDir, "HEAD"], repoRoot);
    if (res.code !== 0) throw new Error(`worktree failed: ${res.stderr}`);
  } else {
    // Lightweight clone mode
    await run("rm", ["-rf", workDir], repoRoot).catch(() => {});
    const clone = await run("git", ["clone", "--no-hardlinks", "--local", ".", workDir], repoRoot);
    if (clone.code !== 0) throw new Error(`clone failed: ${clone.stderr}`);
    const checkout = await run("git", ["checkout", "-B", branch], workDir);
    if (checkout.code !== 0) throw new Error(`checkout failed: ${checkout.stderr}`);
  }

  return workDir;
}

export async function runSpecialist(task: TaskSpec, cfg: OrchestratorConfig, repoRoot: string) {
  const prompt = buildPrompt(task.specialist, task);
  const { workspace, approvals, guardrails } = cfg;
  const workDir = await prepareWorkspace(repoRoot, workspace.baseDir, task.branch, task.key, workspace.useWorktrees);

  if (!guardrails.dryRun) {
    // Set issue state to In Progress (started)
    try {
      let teamId = cfg.linear.teamId;
      if (!teamId && cfg.linear.projectId) {
        const team = await getProjectTeam(cfg.linear.apiKey || "", cfg.linear.projectId);
        teamId = team?.id;
      }
      if (teamId) {
        const startedId = await getTeamStartedStateId(cfg.linear.apiKey || "", teamId);
        if (startedId) await setIssueState(cfg.linear.apiKey || "", task.key, startedId);
      }
    } catch (e) {
      console.warn("Could not set issue to In Progress:", String(e));
    }
    if (cfg.linear && cfg.linear.updateComments) {
      await commentOnIssue(cfg.linear.apiKey || "", task.key, `Starting work with ${task.specialist} in branch ${task.branch}.`);
    }
  }

  const args = [
    "exec",
    "--auto",
    "medium",
    "--cwd",
    workDir,
    "--output-format",
    "text",
    prompt,
  ];
  const res = await run("droid", args, workDir);

  // Try to find a JSON summary in output
  const summaryMatch = res.stdout.match(/\{\s*\"status\"[\s\S]*?\}\s*$/);
  const summary = summaryMatch ? summaryMatch[0] : null;

  if (approvals.prs === "auto" && !guardrails.dryRun) {
    // push and create PR
    await run("git", ["add", "-A"], workDir);
    await run("git", ["commit", "-m", `${task.key}: ${task.title}`], workDir).catch(() => {});
    await run("git", ["push", "-u", "origin", task.branch], workDir);
    await run("gh", ["pr", "create", "--fill", "--head", task.branch], workDir);
  }

  if (!guardrails.dryRun && cfg.linear && cfg.linear.updateComments) {
    const notes = summary ? `\n\nSummary:\n\n${"```"}\n${summary}\n${"```"}` : "";
    await commentOnIssue(cfg.linear.apiKey || "", task.key, `Completed run for ${task.specialist} on ${task.branch}.${notes}`);
  }

  return { workDir, stdout: res.stdout, stderr: res.stderr };
}
