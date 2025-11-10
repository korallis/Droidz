import { spawn } from "bun";

async function run(cmd: string, args: string[], cwd?: string) {
  const p = spawn([cmd, ...args], { cwd, stdout: "pipe", stderr: "pipe" });
  const stdout = await new Response(p.stdout).text();
  const stderr = await new Response(p.stderr).text();
  const code = await p.exited;
  return { code, stdout, stderr };
}

export async function validateEnvironment(apiKey?: string) {
  const checks: Array<{ name: string; ok: boolean; info?: string }> = [];
  const bun = await run("which", ["bun"]);
  checks.push({ name: "bun", ok: bun.code === 0, info: bun.stdout.trim() });
  const droid = await run("which", ["droid"]);
  checks.push({ name: "droid", ok: droid.code === 0, info: droid.stdout.trim() });
  const git = await run("git", ["rev-parse", "--is-inside-work-tree"]);
  checks.push({ name: "git repo", ok: git.code === 0, info: git.stdout.trim() });
  const remotes = await run("git", ["remote", "-v"]);
  const remInfo = remotes.stdout.trim().split(/\r?\n/).filter(Boolean)[0] || remotes.stderr.trim();
  checks.push({ name: "git remotes", ok: remotes.code === 0 && remotes.stdout.trim().length > 0, info: remInfo });
  const gh = await run("gh", ["auth", "status"]);
  checks.push({ name: "gh auth", ok: gh.code === 0 });
  if (apiKey) {
    const cwd = process.cwd() + "/orchestrator";
    const code = `import('./linear.ts').then(m=>m.listTeams('${apiKey}')).then(x=>console.log(x.length)).catch(e=>{console.error(e.message); process.exit(1);})`;
    const teams = await run("bun", ["-e", code], cwd);
    checks.push({ name: "linear api", ok: teams.code === 0, info: teams.stdout.trim() });
  } else {
    checks.push({ name: "linear api", ok: false, info: "missing api key" });
  }
  return checks;
}

export function validateWorkspaceMode(config: { workspace: { mode?: string; useWorktrees?: boolean } }): void {
  const mode = config.workspace.mode || (config.workspace.useWorktrees === false ? "branch" : "worktree");
  
  if (mode !== "worktree") {
    console.warn(`\n⚠️  WARNING: Workspace mode is "${mode}" - NOT RECOMMENDED!`);
    console.warn(`   Parallel execution requires "worktree" mode for 3-5x speed benefit.`);
    console.warn(`   Current mode will be MUCH slower and may cause conflicts.`);
    console.warn(`\n   FIX: Set workspace.mode = "worktree" in orchestrator/config.json\n`);
  } else {
    console.log(`✅ Workspace mode: worktree (optimal for parallel execution)`);
  }
}
