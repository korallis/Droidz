# Tool Compatibility Guide

## Overview

Droidz workflows and droids are designed to work across different AI coding assistant environments. However, tool availability varies between Factory CLI (the environment we develop in) and Droid CLI (the deployment environment for custom droids).

This guide explains the differences and how to write compatible code.

## Environment Comparison

### Factory CLI (Development Environment)

Factory CLI is Anthropic's AI coding assistant with extensive tool support including:

- **Core Tools**: Read, LS, Execute, Edit, MultiEdit, ApplyPatch, Grep, Glob, Create, WebSearch, TodoWrite, FetchUrl
- **MCP Tools**: exa___ (web search, code context), ref___ (documentation), code-execution___, desktop-commander___, and more
- **Extended Features**: Slack integration, Linear integration, custom MCP servers

### Droid CLI (Deployment Environment)

Droid CLI (Factory's custom droid system) has a more limited but focused toolset:

**✅ Available Tools:**
- `Read` - Read file contents
- `LS` - List directory contents  
- `Execute` - Run shell commands
- `Edit` - Edit existing files
- `MultiEdit` - Edit multiple files
- `ApplyPatch` - Apply git patches
- `Grep` - Search file contents
- `Glob` - Find files by pattern
- `Create` - Create new files
- `WebSearch` - Web search
- `TodoWrite` - Manage todo lists
- `FetchUrl` - Fetch web content
- `slack_post_message` - Post to Slack (if configured)

**❌ Not Available in Droid CLI:**
- `exa___web_search_exa` - Use `WebSearch` instead
- `exa___get_code_context_exa` - Use `WebSearch` instead
- `ref___ref_search_documentation` - Use `WebSearch` instead
- `ref___ref_read_url` - Use `FetchUrl` instead
- `Write` - Use `Create` or `Edit` instead
- `Task` - Use `TodoWrite` instead
- `code-execution___*` - Use `Execute` for shell commands
- `desktop-commander___*` - Use equivalent core tools

## Tool Migration Guide

### Research and Documentation

**Factory CLI (Development):**
```typescript
// Search documentation
const docs = await ref___ref_search_documentation({
  query: "Next.js authentication guide"
});

// Read specific docs
const content = await ref___ref_read_url({
  url: "https://docs.example.com/api"
});

// Code search
const examples = await exa___get_code_context_exa({
  query: "React authentication examples",
  tokensNum: 8000
});
```

**Droid CLI (Deployment):**
```bash
# Use WebSearch for documentation
# Query: "Next.js authentication official documentation"

# Use FetchUrl for specific URLs
# URL: https://docs.example.com/api

# Use WebSearch for code examples
# Query: "React authentication implementation GitHub examples"
```

### File Operations

**Factory CLI:**
```typescript
// Both environments use the same tools
await Write("file.ts", content);  // Deprecated - use Create
```

**Droid CLI:**
```bash
# Use Create for new files
# Use Edit for existing files
```

### Task Management

**Factory CLI:**
```typescript
const result = await Task({
  task: "Review code for security issues",
  subagent_type: "security-reviewer"
});
```

**Droid CLI:**
```typescript
await TodoWrite({
  todos: [
    { id: "1", content: "Review code for security", status: "pending" }
  ]
});
```

## Writing Compatible Workflows

### Option 1: Environment Detection

```typescript
// Detect environment based on available tools
const hasExa = typeof exa___web_search_exa !== 'undefined';
const hasRef = typeof ref___ref_search_documentation !== 'undefined';

if (hasExa) {
  // Use Factory CLI tools
  const results = await exa___get_code_context_exa({ query, tokensNum: 8000 });
} else {
  // Fall back to Droid CLI tools
  // Use WebSearch with appropriate query
}
```

### Option 2: Documentation Notes

Add clear notes in workflow documentation:

```markdown
## Step 1: Research

**Factory CLI Users**: Use ref___ref_search_documentation for docs
**Droid CLI Users**: Use WebSearch for documentation search

**Note**: This workflow is optimized for Factory CLI but can be adapted for Droid CLI
by replacing ref/exa tools with WebSearch and FetchUrl.
```

### Option 3: Core Tools Only

Write workflows using only the intersection of available tools:

```markdown
## Cross-Compatible Workflow

Use these tools available in both environments:
- Read, LS, Grep, Glob (exploration)
- Create, Edit, MultiEdit (modifications)
- Execute (running commands)
- WebSearch, FetchUrl (research)
- TodoWrite (task tracking)
```

## Droid Configuration

### Factory CLI Format (.md with YAML frontmatter)

```markdown
---
name: code-reviewer
description: Reviews code for quality issues
model: inherit
tools: ["Read", "LS", "Grep", "Glob"]
---

You are a code reviewer. Check the diff for:
- Correctness issues
- Security vulnerabilities
- Best practice violations
```

### Droid CLI Format (.droid.json)

```json
{
  "name": "code-reviewer",
  "description": "Reviews code for quality issues",
  "model": "gpt-5-codex",
  "defaults": {
    "enabled_tools": ["Read", "LS", "Grep", "Glob"]
  },
  "prompt": "You are a code reviewer. Check the diff for..."
}
```

## Configuration Settings

### Droidz config.yml

```yaml
# Disable tools not available in Droid CLI
use_exa_research: false    # Exa tools not in Droid CLI
use_ref_docs: false         # Ref tools not in Droid CLI

# Enable core features that work everywhere
install_droids: true
parallel:
  enabled: true
  max_concurrent_tasks: 5
  workspace_mode: worktree
```

## Validation

Use the provided validation script to check configurations:

```bash
# Dry run to see what would change
bun run scripts/fix-droids.ts --dry-run

# Fix droid configurations
bun run scripts/fix-droids.ts

# Validate specific directory
bun run scripts/fix-droids.ts .factory/droids
```

## Best Practices

1. **Default to Core Tools**: Use tools available in both environments when possible
2. **Document Environment Requirements**: Clearly state which environment a workflow requires
3. **Provide Alternatives**: Offer both Factory and Droid CLI approaches
4. **Test in Target Environment**: Validate droids in Droid CLI before deployment
5. **Use Validation Scripts**: Run fix-droids.ts to catch compatibility issues

## Common Errors

### "Invalid tools" Error

```
Error: Invalid tools: exa___web_search_exa, ref___ref_read_url
Available tools: Read, LS, Execute, Edit, ...
```

**Solution**: Update droid configuration to use only available tools:
```bash
bun run scripts/fix-droids.ts
```

### "Droid name must be alphanumeric" Error

**Solution**: Droid names must match: `^[a-zA-Z0-9_-]+$`
- ✅ Valid: `code-reviewer`, `security_checker`, `test123`
- ❌ Invalid: `code reviewer`, `test@prod`, `review.droid`

## Resources

- [Factory CLI Documentation](https://docs.factory.ai/cli/configuration/custom-droids)
- [Droid CLI Reference](https://docs.factory.ai/cli/droid-exec/overview)
- [MCP Documentation](https://docs.factory.ai/cli/configuration/mcp)

## Getting Help

If you encounter tool compatibility issues:

1. Check this guide for known solutions
2. Run the validation script: `bun run scripts/fix-droids.ts --dry-run`
3. Review workflow documentation for environment-specific notes
4. Check the Droidz README for configuration examples

---

Last Updated: 2025-11-10
