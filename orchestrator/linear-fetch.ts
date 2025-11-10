#!/usr/bin/env bun
/**
 * Linear Fetch Helper
 * Fetches tickets from Linear for a given project and sprint
 * Returns JSON for orchestrator droid to parse
 * 
 * This implements the code execution pattern - reads API key from config.yml
 */

import { fetchIssuesByProject, fetchIssuesByProjectAndCycle } from "./linear";
import type { LinearIssue } from "./types";
import { readFileSync } from "fs";
import { resolve } from "path";
import YAML from "yaml";

interface FetchArgs {
  project: string;
  sprint?: string;
  apiKey?: string;
}

function parseArgs(): FetchArgs {
  const args: FetchArgs = { project: "" };
  
  for (let i = 2; i < process.argv.length; i++) {
    const arg = process.argv[i];
    if (arg === "--project" && process.argv[i + 1]) {
      args.project = process.argv[i + 1];
      i++;
    } else if (arg === "--sprint" && process.argv[i + 1]) {
      args.sprint = process.argv[i + 1];
      i++;
    } else if (arg === "--api-key" && process.argv[i + 1]) {
      args.apiKey = process.argv[i + 1];
      i++;
    }
  }
  
  return args;
}

function getApiKeyFromConfig(): string | null {
  try {
    const configPath = resolve(process.cwd(), "config.yml");
    const configContent = readFileSync(configPath, "utf-8");
    const config = YAML.parse(configContent);
    
    // Get API key from config
    const apiKey = config?.linear?.api_key || "";
    
    // Handle environment variable substitution
    if (apiKey.startsWith("${") && apiKey.endsWith("}")) {
      const envVar = apiKey.slice(2, -1); // Remove ${ and }
      return process.env[envVar] || null;
    }
    
    return apiKey || null;
  } catch (error) {
    return null;
  }
}

async function main() {
  try {
    const args = parseArgs();
    
    if (!args.project) {
      console.error(JSON.stringify({
        error: "Missing required --project argument",
        usage: "bun orchestrator/linear-fetch.ts --project 'ProjectName' [--sprint 'Sprint-5']"
      }, null, 2));
      process.exit(1);
    }
    
    // Get API key from args, config.yml, or environment
    const apiKey = args.apiKey || 
                   getApiKeyFromConfig() || 
                   process.env.LINEAR_API_KEY || 
                   "";
    
    if (!apiKey) {
      console.error(JSON.stringify({
        error: "No Linear API key found",
        help: "Add your Linear API key to config.yml or set LINEAR_API_KEY environment variable",
        config: "Edit config.yml and add: linear.api_key"
      }, null, 2));
      process.exit(1);
    }
    
    let issues: LinearIssue[];
    
    if (args.sprint) {
      // Fetch by project and cycle
      issues = await fetchIssuesByProjectAndCycle(apiKey, args.project, args.sprint);
    } else {
      // Fetch all issues in project
      issues = await fetchIssuesByProject(apiKey, args.project);
    }
    
    // Output JSON for orchestrator
    const result = {
      project: args.project,
      sprint: args.sprint || null,
      count: issues.length,
      issues: issues.map(iss => ({
        key: iss.identifier,
        id: iss.id,
        title: iss.title,
        description: iss.description || "",
        labels: iss.labels,
        deps: iss.blockedBy
      }))
    };
    
    console.log(JSON.stringify(result, null, 2));
    
  } catch (error: any) {
    console.error(JSON.stringify({
      error: error.message || String(error),
      stack: error.stack
    }, null, 2));
    process.exit(1);
  }
}

main();
