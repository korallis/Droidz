#!/usr/bin/env bun
/**
 * Droid Configuration Validator and Fixer
 * 
 * This script validates and fixes droid configurations to ensure they only use
 * tools available in the Droid CLI environment.
 */

import { promises as fs } from "fs";
import path from "path";

// Available tools in Droid CLI (based on official error message and Factory docs)
// See: https://docs.factory.ai/cli/configuration/custom-droids
const AVAILABLE_TOOLS = [
  "Read",
  "LS",
  "Execute",
  "Edit",
  "MultiEdit",
  "ApplyPatch",
  "Grep",
  "Glob",
  "Create",
  "WebSearch",
  "TodoWrite",
  "FetchUrl",
  "slack_post_message"
] as const;

// Tool name mappings for Factory CLI → Droid CLI
// Factory CLI has these MCP tools that don't exist in Droid CLI
const TOOL_MAPPINGS: Record<string, string> = {
  // Basic tool name differences
  "Write": "Create",  // Factory's Write → Droid's Create for new files
  "Task": "TodoWrite", // Factory's Task → Droid's TodoWrite
  
  // Exa tools (available in Factory CLI, not in Droid CLI)
  "exa___web_search_exa": "WebSearch",  // Use WebSearch instead
  "exa___get_code_context_exa": "WebSearch",  // Use WebSearch for code search
  
  // Ref tools (available in Factory CLI, not in Droid CLI)  
  "ref___ref_search_documentation": "WebSearch",  // Use WebSearch instead
  "ref___ref_read_url": "FetchUrl",  // Use FetchUrl to read URLs
  
  // Desktop Commander tools (may not be available in all environments)
  "desktop-commander___read_file": "Read",
  "desktop-commander___list_directory": "LS",
};

// Tools that should be removed (no equivalent in Droid CLI)
const INVALID_TOOLS = [
  "exa___web_search_exa",
  "exa___get_code_context_exa",
  "ref___ref_search_documentation",
  "ref___ref_read_url"
];

interface DroidConfig {
  id?: string;
  name: string;
  description: string;
  model?: string;
  policies?: Record<string, any>;
  prompt: string;
  defaults?: {
    enabled_tools?: string[];
  };
  enabled_tools?: string[];
}

async function findDroidFiles(dir: string): Promise<string[]> {
  const files: string[] = [];
  
  try {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      if (entry.isDirectory() && !entry.name.startsWith(".")) {
        files.push(...await findDroidFiles(fullPath));
      } else if (entry.isFile() && (
        entry.name.endsWith(".droid.json") || 
        entry.name.endsWith(".md") ||
        entry.name.endsWith(".droid.md")
      )) {
        files.push(fullPath);
      }
    }
  } catch (err) {
    // Skip directories we can't read
  }
  
  return files;
}

function validateAndFixTools(tools: string[]): { fixed: string[], changed: boolean, invalid: string[] } {
  const fixed: string[] = [];
  const invalid: string[] = [];
  let changed = false;
  
  for (const tool of tools) {
    if (AVAILABLE_TOOLS.includes(tool as any)) {
      // Tool is valid
      fixed.push(tool);
    } else if (TOOL_MAPPINGS[tool]) {
      // Tool can be mapped to a valid one
      const mappedTool = TOOL_MAPPINGS[tool];
      if (!fixed.includes(mappedTool)) {
        fixed.push(mappedTool);
      }
      console.log(`  ℹ️  Mapped '${tool}' → '${mappedTool}'`);
      changed = true;
    } else {
      // Tool is invalid and has no mapping
      invalid.push(tool);
      console.log(`  ⚠️  Removed invalid tool: '${tool}'`);
      changed = true;
    }
  }
  
  return { fixed, changed, invalid };
}

async function fixDroidConfig(filePath: string, dryRun: boolean = false): Promise<boolean> {
  try {
    const content = await fs.readFile(filePath, "utf-8");
    const isMarkdown = filePath.endsWith(".md");
    let config: DroidConfig;
    let markdownBody = "";
    
    if (isMarkdown) {
      // Parse Markdown with YAML frontmatter
      const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
      if (!frontmatterMatch) {
        console.error(`  ❌ No YAML frontmatter found in ${filePath}`);
        return false;
      }
      
      // Simple YAML parser for basic cases
      const yaml = frontmatterMatch[1];
      markdownBody = frontmatterMatch[2];
      config = {} as DroidConfig;
      
      const lines = yaml.split("\n");
      for (const line of lines) {
        const match = line.match(/^(\w+):\s*(.*)$/);
        if (match) {
          const [, key, value] = match;
          if (key === "tools" && value.startsWith("[")) {
            // Parse tools array
            config.enabled_tools = JSON.parse(value);
          } else {
            (config as any)[key] = value.replace(/^["']|["']$/g, "");
          }
        }
      }
    } else {
      // Parse JSON
      config = JSON.parse(content);
    }
    
    let changed = false;
    
    // Check defaults.enabled_tools
    if (config.defaults?.enabled_tools) {
      const result = validateAndFixTools(config.defaults.enabled_tools);
      if (result.changed) {
        config.defaults.enabled_tools = result.fixed;
        changed = true;
      }
    }
    
    // Check enabled_tools
    if (config.enabled_tools) {
      const result = validateAndFixTools(config.enabled_tools);
      if (result.changed) {
        config.enabled_tools = result.fixed;
        changed = true;
      }
    }
    
    // Validate droid name (alphanumeric with hyphens/underscores only)
    const nameRegex = /^[a-zA-Z0-9_-]+$/;
    if (config.name && !nameRegex.test(config.name)) {
      const oldName = config.name;
      config.name = config.name.replace(/[^a-zA-Z0-9_-]/g, "-");
      console.log(`  ℹ️  Fixed invalid name: '${oldName}' → '${config.name}'`);
      changed = true;
    }
    
    if (changed && !dryRun) {
      if (isMarkdown) {
        // Reconstruct markdown with fixed frontmatter
        let newYaml = "";
        for (const [key, value] of Object.entries(config)) {
          if (key === "enabled_tools" || key === "tools") {
            newYaml += `${key}: ${JSON.stringify(value)}\n`;
          } else if (value !== undefined && !["defaults", "policies"].includes(key)) {
            newYaml += `${key}: ${JSON.stringify(value)}\n`;
          }
        }
        const newContent = `---\n${newYaml}---\n${markdownBody}`;
        await fs.writeFile(filePath, newContent);
      } else {
        await fs.writeFile(filePath, JSON.stringify(config, null, 2));
      }
    }
    
    return changed;
  } catch (err) {
    console.error(`  ❌ Error processing ${filePath}:`, err);
    return false;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run") || args.includes("-n");
  const searchDir = args.find(arg => !arg.startsWith("-")) || process.cwd();
  
  console.log("🔍 Droid Configuration Validator and Fixer");
  console.log("==========================================\n");
  
  if (dryRun) {
    console.log("🔍 DRY RUN MODE - No changes will be made\n");
  }
  
  console.log(`Searching for droid files in: ${searchDir}\n`);
  
  const droidFiles = await findDroidFiles(searchDir);
  
  if (droidFiles.length === 0) {
    console.log("ℹ️  No droid configuration files found.");
    return;
  }
  
  console.log(`Found ${droidFiles.length} droid file(s):\n`);
  
  let totalFixed = 0;
  
  for (const file of droidFiles) {
    const relativePath = path.relative(searchDir, file);
    console.log(`📄 Checking: ${relativePath}`);
    
    const wasFixed = await fixDroidConfig(file, dryRun);
    
    if (wasFixed) {
      totalFixed++;
      console.log(`  ✅ ${dryRun ? "Would fix" : "Fixed"} configuration\n`);
    } else {
      console.log(`  ✓ Configuration is valid\n`);
    }
  }
  
  console.log("==========================================");
  console.log(`\n📊 Summary:`);
  console.log(`   Total droids: ${droidFiles.length}`);
  console.log(`   ${dryRun ? "Would fix" : "Fixed"}: ${totalFixed}`);
  console.log(`   Already valid: ${droidFiles.length - totalFixed}`);
  
  if (dryRun && totalFixed > 0) {
    console.log(`\n💡 Run without --dry-run to apply fixes`);
  }
  
  console.log(`\n✅ Available tools in Droid CLI:`);
  console.log(`   ${AVAILABLE_TOOLS.join(", ")}`);
}

main().catch(err => {
  console.error("Fatal error:", err);
  process.exit(1);
});
