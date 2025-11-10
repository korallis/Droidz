#!/usr/bin/env bun
import { promises as fs } from "fs";
import path from "path";
import { OrchestratorConfig } from "./types";

const SPECIALISTS = [
  { id: "codegen", desc: "Implements features/bugfixes with tests in a Bun-only environment." },
  { id: "test", desc: "Writes/fixes tests and ensures coverage without destabilizing code." },
  { id: "infra", desc: "Maintains CI/build/tooling; minimal diffs to keep pipelines green." },
  { id: "refactor", desc: "Improves structure safely; no behavior changes unless requested." },
  { id: "integration", desc: "Integrates external services/APIs using env vars (no hardcoded secrets)." },
  { id: "generalist", desc: "Safe fallback: makes conservative changes to progress tickets." }
] as const;

function systemPrompt(kind: string) {
  return [
    `You are the ${kind} specialist droid.`,
    `Constraints:`,
    `- Use Bun (bun run/test) only; do not use npm or npx.`,
    `- Minimal comments; match repo style; avoid secrets.`,
    `- Ensure tests/build pass before completion.`,
  ].join("\n");
}

async function main() {
  const root = process.cwd();
  const cfgPath = path.join(root, "orchestrator", "config.json");
  const cfg: OrchestratorConfig = JSON.parse(await fs.readFile(cfgPath, "utf-8"));
  const outDir = path.join(root, ".factory", "droids");
  await fs.mkdir(outDir, { recursive: true });

  for (const s of SPECIALISTS) {
    // Create Markdown file with YAML frontmatter (Factory CLI format)
    const file = path.join(outDir, `${s.id}.md`);
    
    // Available tools in Droid CLI - only use these
    const availableTools = ["Read", "LS", "Execute", "Edit", "Grep", "Glob", "Create", "TodoWrite"];
    
    const markdownContent = `---
name: droidz-${s.id}
description: ${s.desc}
model: gpt-5-codex
tools: ${JSON.stringify(availableTools)}
---

${systemPrompt(s.id)}

## Policies

- Tests must pass before completion
- Secret scanning enabled
- No hardcoded credentials
`;
    
    await fs.writeFile(file, markdownContent);
  }
  console.log(`Custom droid presets written to ${outDir}.`);
  console.log("Droids created as Markdown files with YAML frontmatter (Factory CLI format).");
  console.log("Enable custom droids in settings (/settings) to use them.");
}

main().catch(err => { console.error(err); process.exit(1); });
