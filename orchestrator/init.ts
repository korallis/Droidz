#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import { detectRepoProfile } from "./detectors";

async function main() {
  const repoRoot = process.cwd();
  const profile = await detectRepoProfile(repoRoot);
  const specialists = [
    { name: "codegen", enabled: true },
    { name: "test", enabled: true },
    { name: "infra", enabled: true },
    { name: "refactor", enabled: true },
    { name: "integration", enabled: true },
    { name: "generalist", enabled: true }
  ];
  const configPath = path.join(repoRoot, "orchestrator", "config.json");
  const raw = await fs.readFile(configPath, "utf-8");
  const cfg = JSON.parse(raw);
  cfg.profile = profile;
  cfg.specialists = specialists;
  await fs.writeFile(configPath, JSON.stringify(cfg, null, 2));
  console.log("Initialized specialists into orchestrator/config.json based on detected profile:", profile);
}

main().catch(err => { console.error(err); process.exit(1); });
