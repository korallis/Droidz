#!/usr/bin/env bun
/**
 * Exa Search Helper
 * Searches using Exa API with API key from config.yml or environment
 * This implements the code execution pattern from Anthropic's MCP article
 */

import { readFileSync } from "fs";
import { resolve } from "path";
import YAML from "yaml";

interface SearchArgs {
  query: string;
  apiKey?: string;
  numResults?: number;
  type?: "auto" | "keyword" | "neural";
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
    } else if (arg === "--num-results" && process.argv[i + 1]) {
      args.numResults = parseInt(process.argv[i + 1]);
      i++;
    } else if (arg === "--type" && process.argv[i + 1]) {
      args.type = process.argv[i + 1] as "auto" | "keyword" | "neural";
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
    const apiKey = config?.exa?.api_key || "";
    
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

async function searchExa(query: string, apiKey: string, options: { numResults?: number; type?: string } = {}) {
  const url = "https://api.exa.ai/search";
  
  const body = {
    query,
    numResults: options.numResults || 10,
    type: options.type || "auto",
    contents: {
      text: true
    }
  };
  
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });
  
  if (!response.ok) {
    throw new Error(`Exa API error: ${response.status} ${response.statusText}`);
  }
  
  return await response.json();
}

async function main() {
  try {
    const args = parseArgs();
    
    if (!args.query) {
      console.error(JSON.stringify({
        error: "Missing required --query argument",
        usage: "bun orchestrator/exa-search.ts --query 'your search query' [--num-results 10] [--type auto]"
      }, null, 2));
      process.exit(1);
    }
    
    // Get API key from args, config.yml, or environment
    const apiKey = args.apiKey || 
                   getApiKeyFromConfig() || 
                   process.env.EXA_API_KEY || 
                   "";
    
    if (!apiKey) {
      console.error(JSON.stringify({
        error: "No Exa API key found",
        help: "Add your Exa API key to config.yml or set EXA_API_KEY environment variable",
        config: "Edit config.yml and add: exa.api_key"
      }, null, 2));
      process.exit(1);
    }
    
    const results = await searchExa(args.query, apiKey, {
      numResults: args.numResults,
      type: args.type
    });
    
    // Output results as JSON
    console.log(JSON.stringify(results, null, 2));
    
  } catch (error) {
    console.error(JSON.stringify({
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined
    }, null, 2));
    process.exit(1);
  }
}

main();
