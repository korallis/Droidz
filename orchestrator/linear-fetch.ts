#!/usr/bin/env bun
/**
 * Linear Fetch Helper
 * Fetches tickets from Linear for a given project and sprint
 * Returns JSON for orchestrator droid to parse
 */

import { fetchIssuesByProject, fetchIssuesByProjectAndCycle } from "./linear";
import type { LinearIssue } from "./types";

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

async function main() {
  try {
    const args = parseArgs();
    
    if (!args.project) {
      console.error(JSON.stringify({
        error: "Missing required --project argument"
      }, null, 2));
      process.exit(1);
    }
    
    const apiKey = args.apiKey || process.env.LINEAR_API_KEY || "";
    if (!apiKey) {
      console.error(JSON.stringify({
        error: "Missing LINEAR_API_KEY environment variable or --api-key argument"
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
