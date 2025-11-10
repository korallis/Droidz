#!/usr/bin/env bun
/**
 * Ref Documentation Search Helper
 * Searches documentation using Ref MCP server programmatically
 * 
 * IMPORTANT: Unlike Exa and Linear, Ref doesn't provide a REST API.
 * This script is a PLACEHOLDER that explains the MCP-only approach.
 * 
 * To use Ref, you have TWO options:
 * 
 * 1. DIRECT MCP TOOLS (when available in Factory):
 *    - Use ref___ref_search_documentation directly in droid
 *    - Requires MCP server configured via Factory CLI
 *    - See MCP_SETUP.md for instructions
 * 
 * 2. CODE EXECUTION MCP (programmatic):
 *    - Use code-execution___execute_code tool
 *    - Import ref server and call tools programmatically
 *    - Example in orchestrator droid
 * 
 * This file exists to:
 * - Document Ref's MCP-only nature
 * - Provide placeholder for future REST API
 * - Show expected error if called directly
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
    error: "Ref documentation search requires MCP server",
    explanation: "Ref doesn't provide a REST API like Exa or Linear",
    mcpOnly: true,
    
    // Option 1: Direct MCP tools (requires MCP server setup)
    option1: {
      method: "Direct MCP Tools",
      requirement: "MCP server configured via Factory CLI",
      setup: [
        "1. Get API key from https://ref.tools",
        "2. Configure MCP: droid",
        "3. Run: /mcp add ref",
        "4. Use: ref___ref_search_documentation in droids"
      ],
      documentation: "See MCP_SETUP.md for detailed instructions"
    },
    
    // Option 2: Code execution MCP (programmatic)
    option2: {
      method: "Programmatic MCP via code-execution tool",
      description: "Use code-execution___execute_code to call Ref MCP programmatically",
      example: `
// In orchestrator droid, use code-execution tool:
const code = \`
  const { ref } = await import("./servers/ref");
  const results = await ref.searchDocumentation("${args.query}");
  console.log(JSON.stringify(results, null, 2));
\`;
Execute: code-execution___execute_code with code above
      `.trim(),
      note: "This works if code-execution MCP server is configured"
    },
    
    // What was requested
    yourQuery: args.query,
    hasApiKey: !!apiKey,
    
    // Why this script exists
    purpose: "This script exists to document Ref's MCP-only nature and guide users to proper setup",
    
    // Future possibility
    future: "If Ref releases a REST API in the future, this script can be updated to use it"
  }, null, 2));
  
  process.exit(1);
}

main();
