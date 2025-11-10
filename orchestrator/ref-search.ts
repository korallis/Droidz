#!/usr/bin/env bun
/**
 * Ref Documentation Search Helper
 * 
 * IMPORTANT: Ref doesn't have a REST API like Exa and Linear.
 * This script is a DOCUMENTATION PLACEHOLDER explaining how to use Ref.
 * 
 * ✅ GOOD NEWS: ref___ref_search_documentation is ALREADY AVAILABLE in Factory!
 * 
 * HOW TO USE REF:
 * 
 * In orchestrator droid, call the MCP tool directly:
 *   ref___ref_search_documentation("Next.js 14 app router")
 * 
 * Result format:
 *   page='Building Your Application: Routing | Next.js'
 *   https://nextjs.org/docs/14/app/building-your-application/routing
 * 
 * WHY NOT A SCRIPT LIKE EXA/LINEAR?
 * - Exa & Linear: Have REST/GraphQL APIs → Use Execute + script
 * - Ref: MCP tool only → Call directly (no API to fetch from)
 * 
 * This file exists to:
 * - Document that Ref is MCP-only (no REST API)
 * - Explain that ref___ref_search_documentation is available
 * - Show error if someone tries to run this as a script
 */

import { readFileSync } from "fs";
import { resolve } from "path";
import YAML from "yaml";

interface SearchArgs {
  query: string;
  apiKey?: string;
}

function parseArgs(): SearchArgs {
  const args: SearchArgs = { query: "" };
  
  for (let i = 2; i < process.argv.length; i++) {
    const arg = process.argv[i];
    if (arg === "--query" && process.argv[i + 1]) {
      args.query = process.argv[i + 1];
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
    const apiKey = config?.ref?.api_key || "";
    
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
  const args = parseArgs();
  
  if (!args.query) {
    console.error(JSON.stringify({
      error: "Missing required --query argument",
      usage: "bun orchestrator/ref-search.ts --query 'your search query'"
    }, null, 2));
    process.exit(1);
  }
  
  // Get API key (for documentation purposes)
  const apiKey = args.apiKey || 
                 getApiKeyFromConfig() || 
                 process.env.REF_API_KEY || 
                 "";
  
  // Ref is MCP-only, no REST API available
  console.error(JSON.stringify({
    error: "Ref cannot be called as a script - it's an MCP tool only",
    explanation: "Unlike Exa and Linear which have REST APIs, Ref only works through MCP tools",
    mcpOnly: true,
    
    // ✅ Good news: It's already available!
    goodNews: "ref___ref_search_documentation is ALREADY available in Factory CLI!",
    
    // How to use it
    howToUse: {
      method: "Call MCP tool directly in orchestrator droid",
      example: `ref___ref_search_documentation("${args.query}")`,
      result: "Returns: page titles and URLs from documentation",
      note: "No script needed - just call the MCP tool!"
    },
    
    // Comparison with other services
    comparison: {
      exa: "Has REST API → Use: Execute: bun orchestrator/exa-search.ts",
      linear: "Has GraphQL API → Use: Execute: bun orchestrator/linear-fetch.ts",
      ref: "MCP tool only → Use: ref___ref_search_documentation() directly"
    },
    
    // What was requested
    yourQuery: args.query,
    hasApiKey: !!apiKey,
    
    // Why this pattern
    whyDifferent: {
      reason: "Ref has no public REST API to call with fetch()",
      solution: "Use the MCP tool that's already available in Factory",
      benefit: "Simpler than scripts - just one function call!"
    },
    
    // Testing in Factory
    testIt: {
      command: "Try this in droid CLI:",
      example: 'ref___ref_search_documentation("Next.js app router")',
      expected: "You should see documentation URLs"
    }
  }, null, 2));
  
  process.exit(1);
}

main();
