#!/usr/bin/env bun
/**
 * Linear Update Helper
 * Updates Linear ticket status or posts comments
 * Used by specialist droids to update tickets
 */

import { setIssueState, commentOnIssue, getTeamStateIdByName, getIssueId } from "./linear";

interface UpdateArgs {
  issue: string;
  status?: string;
  comment?: string;
  apiKey?: string;
  teamId?: string;
}

function parseArgs(): UpdateArgs {
  const args: UpdateArgs = { issue: "" };
  
  for (let i = 2; i < process.argv.length; i++) {
    const arg = process.argv[i];
    if (arg === "--issue" && process.argv[i + 1]) {
      args.issue = process.argv[i + 1];
      i++;
    } else if (arg === "--status" && process.argv[i + 1]) {
      args.status = process.argv[i + 1];
      i++;
    } else if (arg === "--comment" && process.argv[i + 1]) {
      args.comment = process.argv[i + 1];
      i++;
    } else if (arg === "--api-key" && process.argv[i + 1]) {
      args.apiKey = process.argv[i + 1];
      i++;
    } else if (arg === "--team-id" && process.argv[i + 1]) {
      args.teamId = process.argv[i + 1];
      i++;
    }
  }
  
  return args;
}

async function getTeamIdFromIssue(apiKey: string, issueIdentifier: string): Promise<string | null> {
  try {
    const LINEAR_GQL = "https://api.linear.app/graphql";
    const query = `
      query GetIssueTeam($identifier: String!) {
        issue(identifier: $identifier) {
          team {
            id
            name
          }
        }
      }
    `;
    
    const res = await fetch(LINEAR_GQL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: apiKey,
      },
      body: JSON.stringify({ query, variables: { identifier: issueIdentifier } }),
    });
    
    if (!res.ok) {
      throw new Error(`Linear API error: ${res.status}`);
    }
    
    const json = (await res.json()) as any;
    if (json.errors) {
      throw new Error("Linear GraphQL errors: " + JSON.stringify(json.errors));
    }
    
    return json.data?.issue?.team?.id || null;
  } catch (err) {
    console.error("Failed to get team ID from issue:", err);
    return null;
  }
}

async function main() {
  try {
    const args = parseArgs();
    
    if (!args.issue) {
      console.error(JSON.stringify({
        error: "Missing required --issue argument"
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
    
    const results: any = {
      issue: args.issue,
      updates: []
    };
    
    // Update status if provided
    if (args.status) {
      // Get team ID (try from args, fallback to fetching from issue)
      let teamId = args.teamId;
      if (!teamId) {
        teamId = await getTeamIdFromIssue(apiKey, args.issue);
      }
      
      if (!teamId) {
        throw new Error("Could not determine team ID for issue");
      }
      
      // Get state ID by name
      const stateId = await getTeamStateIdByName(apiKey, teamId, args.status);
      if (!stateId) {
        throw new Error(`State '${args.status}' not found for team ${teamId}`);
      }
      
      // Update issue state
      const success = await setIssueState(apiKey, args.issue, stateId);
      results.updates.push({
        type: "status",
        value: args.status,
        success
      });
    }
    
    // Post comment if provided
    if (args.comment) {
      const success = await commentOnIssue(apiKey, args.issue, args.comment);
      results.updates.push({
        type: "comment",
        value: args.comment.substring(0, 100) + (args.comment.length > 100 ? "..." : ""),
        success
      });
    }
    
    results.success = results.updates.every((u: any) => u.success);
    console.log(JSON.stringify(results, null, 2));
    
    if (!results.success) {
      process.exit(1);
    }
    
  } catch (error: any) {
    console.error(JSON.stringify({
      error: error.message || String(error),
      stack: error.stack
    }, null, 2));
    process.exit(1);
  }
}

main();
