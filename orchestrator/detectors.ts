import { promises as fs } from "fs";
import path from "path";

export interface RepoProfile {
  stack: string[]; // e.g., ["node", "nextjs", "typescript"]
  packageManager: "bun" | "npm" | "pnpm" | "yarn" | null;
  tests: { framework?: string };
}

export async function detectRepoProfile(root: string): Promise<RepoProfile> {
  const profile: RepoProfile = { stack: [], packageManager: null, tests: {} };
  const exists = async (p: string) => fs.access(p).then(() => true).catch(() => false);

  // Bun first
  if (await exists(path.join(root, "bun.lockb"))) profile.packageManager = "bun";

  // JS/TS
  if (await exists(path.join(root, "package.json"))) {
    profile.stack.push("node");
    const pkg = JSON.parse(await fs.readFile(path.join(root, "package.json"), "utf-8"));
    if (pkg.dependencies?.react || pkg.devDependencies?.react) profile.stack.push("react");
    if (pkg.dependencies?.next || pkg.devDependencies?.next) profile.stack.push("nextjs");
    if (pkg.type === "module") profile.stack.push("esm");
    if (await exists(path.join(root, "tsconfig.json"))) profile.stack.push("typescript");
    if (pkg.devDependencies?.jest) profile.tests.framework = "jest";
    if (pkg.devDependencies?.vitest) profile.tests.framework = "vitest";
  }

  // Python
  if (await exists(path.join(root, "pyproject.toml")) || await exists(path.join(root, "requirements.txt"))) profile.stack.push("python");

  // Go
  if (await exists(path.join(root, "go.mod"))) profile.stack.push("go");

  // Docker/CI hints
  if (await exists(path.join(root, "Dockerfile"))) profile.stack.push("docker");
  if (await exists(path.join(root, ".github", "workflows"))) profile.stack.push("github-actions");

  return profile;
}
