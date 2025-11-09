import { spawn } from "bun";
import path from "path";
import { promises as fs } from "fs";
import { buildPrompt } from "./workerPrompt";
import { OrchestratorConfig, TaskSpec } from "./types";
// Droid CLI performs git/Linear work; orchestrator only schedules
import { loadAgentsGuide, truncateGuide } from "./agents";

async function run(cmd: string, args: string[], cwd: string, env?: Record<string, string>): Promise<{ code: number; stdout: string; stderr: string }> {
  const p = spawn([cmd, ...args], { cwd, stdout: "pipe", stderr: "pipe", env });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  const code = await p.exited;
  return { code, stdout: out, stderr: err };
}

async function prepareWorkspace(repoRoot: string, baseDir: string, branch: string, key: string, mode: OrchestratorConfig["workspace"]["mode"] | boolean | undefined): Promise<{ workDir: string; mode: "worktree" | "branch" | "clone" }>
{
  const workDir = path.resolve(repoRoot, baseDir, key);
  await run("mkdir", ["-p", workDir], repoRoot).catch(() => {});

  // Ensure this is a git repo
  const isGit = await run("git", ["rev-parse", "--is-inside-work-tree"], repoRoot);
  if (isGit.code !== 0) throw new Error("Not a git repository. Initialize git and add a remote 'origin' to use branches/PRs.");

  await run("git", ["fetch", "--all"], repoRoot);

  // Back-compat: boolean useWorktrees maps to mode
  const resolvedMode: "worktree" | "clone" | "branch" = (typeof mode === "boolean") ? (mode ? "worktree" : "branch") : (mode || "worktree");

  if (resolvedMode === "worktree") {
    await run("git", ["worktree", "remove", "-f", workDir], repoRoot).catch(() => {});
    const res = await run("git", ["worktree", "add", "-B", branch, workDir, "HEAD"], repoRoot);
    if (res.code !== 0) throw new Error(`worktree failed: ${res.stderr}`);
    return { workDir, mode: "worktree" };
  }

  if (resolvedMode === "clone") {
    await run("rm", ["-rf", workDir], repoRoot).catch(() => {});
    const clone = await run("git", ["clone", "--local", ".", workDir], repoRoot);
    if (clone.code !== 0) throw new Error(`clone failed: ${clone.stderr}`);
    const checkout = await run("git", ["checkout", "-B", branch], workDir);
    if (checkout.code !== 0) throw new Error(`checkout failed: ${checkout.stderr}`);
    return { workDir, mode: "clone" };
  }

  // branch mode: shadow copy (no clone). We'll later compute a patch and apply it under a repo lock.
  await run("rm", ["-rf", workDir], repoRoot).catch(() => {});
  // Prefer rsync if available for speed
  const rs = await run("which", ["rsync"], repoRoot);
  if (rs.code === 0) {
    const rsync = await run("rsync", ["-a", "--delete", "--exclude", ".git", repoRoot + "/", workDir + "/"], repoRoot);
    if (rsync.code !== 0) throw new Error(`shadow copy failed: ${rsync.stderr}`);
  } else {
    const cp = await run("cp", ["-R", repoRoot + "/", workDir + "/"], repoRoot);
    if (cp.code !== 0) throw new Error(`shadow copy failed: ${cp.stderr}`);
    await run("rm", ["-rf", path.join(workDir, ".git")], repoRoot).catch(() => {});
  }
  return { workDir, mode: "branch" };
}

async function acquireRepoLock(repoRoot: string, baseDir: string) {
  const lockDir = path.resolve(repoRoot, baseDir, ".apply.lock");
  for (;;) {
    try {
      await fs.mkdir(lockDir);
      return () => fs.rmdir(lockDir).catch(() => {});
    } catch {
      await new Promise(r => setTimeout(r, 200));
    }
  }
}

export async function runSpecialist(task: TaskSpec, cfg: OrchestratorConfig, repoRoot: string) {
  const prompt = buildPrompt(task.specialist, task);
  const { workspace, approvals, guardrails } = cfg;
  const prep = await prepareWorkspace(repoRoot, workspace.baseDir, task.branch, task.key, workspace.mode ?? workspace.useWorktrees);
  const workDir = prep.workDir;
  const mode = prep.mode;

  // All Linear/git operations are handled by the Droid in this workspace.

  // Load AGENTS.md guidance
  const guide = await loadAgentsGuide(repoRoot);
  const agentsText = truncateGuide(guide.text);
  const prompt = buildPrompt(task.specialist, task, agentsText);

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
  const env = { ...(process.env as any), LINEAR_API_KEY: cfg.linear.apiKey || "" } as any;
  const res = await run("droid", args, workDir);

  // Try to find a JSON summary in output
  const summaryMatch = res.stdout.match(/\{\s*\"status\"[\s\S]*?\}\s*$/);
  const summary = summaryMatch ? summaryMatch[0] : null;

  if (approvals.prs !== "disallow_push" && !guardrails.dryRun) {
    let prUrl = "";
    if (mode === "worktree" || mode === "clone") {
      // push and create PR directly from the isolated workspace
      await run("git", ["add", "-A"], workDir);
      await run("git", ["commit", "-m", `${task.key}: ${task.title}`], workDir).catch(() => {});
      await run("git", ["push", "-u", "origin", task.branch], workDir);
      const prCreate = await run("gh", ["pr", "create", "--fill", "--head", task.branch], workDir);
      const urlMatch = prCreate.stdout.match(/https?:\/\/\S+/);
      prUrl = urlMatch ? urlMatch[0] : "";
    } else {
      // branch mode: compute patch and apply under repo lock, then create PR from repoRoot
      const diff = await run("git", ["--no-pager", "diff", "--no-index", "--binary", repoRoot, workDir], repoRoot);
      const patchPath = path.join(workDir, "changes.patch");
      await fs.writeFile(patchPath, diff.stdout);
      const release = await acquireRepoLock(repoRoot, workspace.baseDir);
      try {
        await run("git", ["checkout", "-B", task.branch], repoRoot);
        const apply = await run("git", ["apply", "--index", "--whitespace=fix", patchPath], repoRoot);
        if (apply.code !== 0) throw new Error(`git apply failed: ${apply.stderr}`);
        await run("git", ["add", "-A"], repoRoot);
        await run("git", ["commit", "-m", `${task.key}: ${task.title}`], repoRoot).catch(() => {});
        await run("git", ["push", "-u", "origin", task.branch], repoRoot);
        const prCreate = await run("gh", ["pr", "create", "--fill", "--head", task.branch], repoRoot);
        const urlMatch = prCreate.stdout.match(/https?:\/\/\S+/);
        prUrl = urlMatch ? urlMatch[0] : "";
      } finally {
        await release();
      }
    }

    // If auto-merge enabled, set it up; else move to review state
    const mergeCfg = cfg.merge || { autoMerge: false, strategy: "squash", requireChecks: true } as any;
    if (mergeCfg.autoMerge) {
      const args = ["pr", "merge", prUrl || task.branch];
      if (mergeCfg.requireChecks) args.push("--auto");
      if (mergeCfg.strategy === "squash") args.push("--squash");
      else if (mergeCfg.strategy === "merge") args.push("--merge");
      else if (mergeCfg.strategy === "rebase") args.push("--rebase");
      args.push("--delete-branch");
      await run("gh", args, workDir).catch(e => console.warn("Auto-merge setup failed:", e));
      // Optionally set Done state will be handled by CI webhook or future enhancement
    } else {
      // Move to In Review if available
      try {
        let teamId = cfg.linear.teamId;
        if (!teamId && cfg.linear.projectId) {
          const team = await getProjectTeam(cfg.linear.apiKey || "", cfg.linear.projectId);
          teamId = team?.id;
        }
        if (teamId) {
          const reviewName = (mergeCfg.reviewStateName || "In Review") as string;
          const reviewId = await getTeamStateIdByName(cfg.linear.apiKey || "", teamId, reviewName);
          if (reviewId) await setIssueState(cfg.linear.apiKey || "", task.key, reviewId);
        }
      } catch (e) {
        console.warn("Could not set issue to review state:", String(e));
      }
    }

    if (cfg.linear && cfg.linear.updateComments) {
      const link = prUrl ? `\nPR: ${prUrl}` : "";
      const notes = summary ? `\n\nSummary:\n\n${"```"}\n${summary}\n${"```"}` : "";
      await commentOnIssue(cfg.linear.apiKey || "", task.key, `PR created for ${task.specialist} on ${task.branch}.${link}${notes}`);
    }
  } else if (!guardrails.dryRun && cfg.linear && cfg.linear.updateComments) {
    const notes = summary ? `\n\nSummary:\n\n${"```"}\n${summary}\n${"```"}` : "";
    await commentOnIssue(cfg.linear.apiKey || "", task.key, `Completed run for ${task.specialist} on ${task.branch}.${notes}`);
  }

  return { workDir, stdout: res.stdout, stderr: res.stderr };
}
