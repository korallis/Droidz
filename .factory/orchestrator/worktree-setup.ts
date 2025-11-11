#!/usr/bin/env bun
/**
 * Worktree Setup Helper
 * Extracted from workers.ts for reuse by v2 architecture
 * Prepares isolated git worktrees for parallel task execution
 */

import { spawn } from "bun";
import path from "path";

async function run(cmd: string, args: string[], cwd: string, env?: Record<string, string>): Promise<{ code: number; stdout: string; stderr: string }> {
  const p = spawn([cmd, ...args], { cwd, stdout: "pipe", stderr: "pipe", env });
  const out = await new Response(p.stdout).text();
  const err = await new Response(p.stderr).text();
  const code = await p.exited;
  return { code, stdout: out, stderr: err };
}

export interface WorkspaceResult {
  workDir: string;
  mode: "worktree" | "clone" | "branch";
}

export async function prepareWorkspace(
  repoRoot: string,
  baseDir: string,
  branch: string,
  key: string,
  mode: "worktree" | "clone" | "branch" | boolean | undefined
): Promise<WorkspaceResult> {
  const workDir = path.resolve(repoRoot, baseDir, key);
  await run("mkdir", ["-p", workDir], repoRoot).catch(() => {});

  // Ensure this is a git repo
  const isGit = await run("git", ["rev-parse", "--is-inside-work-tree"], repoRoot);
  if (isGit.code !== 0) {
    throw new Error("Not a git repository. Initialize git and add a remote 'origin' to use branches/PRs.");
  }

  await run("git", ["fetch", "--all"], repoRoot);

  // Back-compat: boolean useWorktrees maps to mode
  const resolvedMode: "worktree" | "clone" | "branch" = 
    (typeof mode === "boolean") 
      ? (mode ? "worktree" : "branch") 
      : (mode || "worktree");

  if (resolvedMode === "worktree") {
    // Remove existing worktree if present
    await run("git", ["worktree", "remove", "-f", workDir], repoRoot).catch(() => {});
    
    const res = await run("git", ["worktree", "add", "-B", branch, workDir, "HEAD"], repoRoot);
    if (res.code !== 0) {
      throw new Error(`Worktree creation failed: ${res.stderr}`);
    }
    
    return { workDir, mode: "worktree" };
  }

  if (resolvedMode === "clone") {
    // Full clone (slower but independent)
    await run("rm", ["-rf", workDir], repoRoot).catch(() => {});
    
    const clone = await run("git", ["clone", "--local", ".", workDir], repoRoot);
    if (clone.code !== 0) {
      throw new Error(`Clone failed: ${clone.stderr}`);
    }
    
    const checkout = await run("git", ["checkout", "-B", branch], workDir);
    if (checkout.code !== 0) {
      throw new Error(`Checkout failed: ${checkout.stderr}`);
    }
    
    return { workDir, mode: "clone" };
  }

  // branch mode: shadow copy (no git isolation)
  await run("rm", ["-rf", workDir], repoRoot).catch(() => {});
  
  // Prefer rsync if available
  const rs = await run("which", ["rsync"], repoRoot);
  if (rs.code === 0) {
    const rsync = await run("rsync", ["-a", "--delete", "--exclude", ".git", repoRoot + "/", workDir + "/"], repoRoot);
    if (rsync.code !== 0) {
      throw new Error(`Shadow copy (rsync) failed: ${rsync.stderr}`);
    }
  } else {
    const cp = await run("cp", ["-R", repoRoot + "/", workDir + "/"], repoRoot);
    if (cp.code !== 0) {
      throw new Error(`Shadow copy (cp) failed: ${cp.stderr}`);
    }
    await run("rm", ["-rf", path.join(workDir, ".git")], repoRoot).catch(() => {});
  }
  
  return { workDir, mode: "branch" };
}

// CLI interface when run directly
async function main() {
  const modeArg = process.argv[6];
  const mode =
    modeArg === "true"
      ? true
      : modeArg === "false"
        ? false
        : (modeArg as "worktree" | "clone" | "branch" | undefined);

  const args = {
    repoRoot: process.argv[2] || process.cwd(),
    baseDir: process.argv[3] || ".runs",
    branch: process.argv[4],
    key: process.argv[5],
    mode: mode ?? "worktree"
  };
  
  if (!args.branch || !args.key) {
    console.error("Usage: worktree-setup.ts <repoRoot> <baseDir> <branch> <key> [mode]");
    process.exit(1);
  }
  
  try {
    const result = await prepareWorkspace(
      args.repoRoot,
      args.baseDir,
      args.branch,
      args.key,
      args.mode
    );
    
    console.log(JSON.stringify(result, null, 2));
  } catch (error: unknown) {
    const err = error instanceof Error ? error : new Error(String(error));
    console.error(JSON.stringify({
      error: err.message
    }, null, 2));
    process.exit(1);
  }
}

// Run if executed directly
if (import.meta.main) {
  void main();
}
