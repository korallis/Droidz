#!/usr/bin/env bun
/**
 * Task Coordinator Bridge
 * 
 * Bridges orchestrator droid → specialist droids → worktrees
 * Prepares workspace and returns metadata for Task tool invocation
 */

import { prepareWorkspace } from "./worktree-setup";
import type { OrchestratorConfig } from "./types";
import path from "path";
import { promises as fs } from "fs";

interface TaskRequest {
  ticket: {
    key: string;
    title: string;
    description?: string;
    labels: string[];
  };
  specialist: string;
  repoRoot: string;
  config: {
    workspace: {
      baseDir: string;
      branchPattern: string;
      mode?: "worktree" | "clone" | "branch";
    };
  };
}

function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "").slice(0, 40);
}

function branchFromPattern(pattern: string, issueKey: string, title: string, type: string) {
  return pattern
    .replace("{type}", type)
    .replace("{issueKey}", issueKey)
    .replace("{slug}", slugify(title));
}

async function loadConfigIfNeeded(repoRoot: string): Promise<OrchestratorConfig | null> {
  try {
    const configPath = path.join(repoRoot, "orchestrator", "config.json");
    const content = await fs.readFile(configPath, "utf-8");
    return JSON.parse(content);
  } catch {
    return null;
  }
}

async function main() {
  try {
    // Parse request from orchestrator droid
    const requestJson = process.argv[2];
    if (!requestJson) {
      console.error(JSON.stringify({
        error: "Missing request JSON argument. Usage: task-coordinator.ts '{...}'"
      }, null, 2));
      process.exit(1);
    }
    
    const request: TaskRequest = JSON.parse(requestJson);
    const { ticket, specialist, repoRoot, config } = request;
    
    // Determine branch name
    const branch = branchFromPattern(
      config.workspace.branchPattern || "{type}/{issueKey}-{slug}",
      ticket.key,
      ticket.title,
      specialist
    );
    
    // Prepare isolated workspace (git worktree)
    const workspace = await prepareWorkspace(
      repoRoot || process.cwd(),
      config.workspace.baseDir || ".runs",
      branch,
      ticket.key,
      config.workspace.mode || "worktree"
    );
    
    // Load full config if available (for additional context)
    const fullConfig = await loadConfigIfNeeded(repoRoot || process.cwd());
    
    // Return metadata for orchestrator to use in Task tool prompt
    const result = {
      success: true,
      workspace: workspace.workDir,
      mode: workspace.mode,
      branch,
      specialist: `droidz-${specialist}`,
      ticket: {
        key: ticket.key,
        title: ticket.title,
        description: ticket.description || "",
        labels: ticket.labels
      },
      ready: true,
      // Configuration hints
      config: {
        testsRequired: fullConfig?.guardrails?.testsRequired ?? true,
        secretScan: fullConfig?.guardrails?.secretScan ?? true,
        linearUpdateComments: fullConfig?.linear?.updateComments ?? true
      }
    };
    
    console.log(JSON.stringify(result, null, 2));
    
  } catch (error: unknown) {
    const err = error instanceof Error ? error : new Error(String(error));
    console.error(JSON.stringify({
      success: false,
      error: err.message,
      stack: err.stack
    }, null, 2));
    process.exit(1);
  }
}

void main();
