# Droidz Scripts

Utility scripts for maintaining and validating Droidz configurations.

## fix-droids.ts

Validates and fixes droid configurations to ensure compatibility with Droid CLI.

### Features

- ✅ Validates droid names (alphanumeric with hyphens/underscores only)
- ✅ Checks tool availability in Droid CLI environment
- ✅ Maps Factory CLI tools to Droid CLI equivalents
- ✅ Supports both JSON (.droid.json) and Markdown (.md, .droid.md) formats
- ✅ Dry-run mode to preview changes
- ✅ Detailed reporting of issues and fixes

### Usage

```bash
# Validate all droids in current directory (dry run)
bun run scripts/fix-droids.ts --dry-run

# Fix droids in current directory
bun run scripts/fix-droids.ts

# Validate specific directory
bun run scripts/fix-droids.ts .factory/droids --dry-run

# Fix droids in specific directory
bun run scripts/fix-droids.ts .factory/droids
```

### What It Fixes

#### Invalid Tool Names

Maps Factory CLI tools to Droid CLI equivalents:

| Factory CLI | Droid CLI | Notes |
|------------|-----------|-------|
| `Write` | `Create` | Use Create for new files, Edit for existing |
| `Task` | `TodoWrite` | Task management tool |
| `exa___web_search_exa` | `WebSearch` | Web search functionality |
| `exa___get_code_context_exa` | `WebSearch` | Code search via web |
| `ref___ref_search_documentation` | `WebSearch` | Documentation search |
| `ref___ref_read_url` | `FetchUrl` | Fetch URL content |

#### Invalid Droid Names

Ensures droid names are alphanumeric with hyphens or underscores:

- ✅ Valid: `code-reviewer`, `security_checker`, `api-client-v2`
- ❌ Invalid: `code reviewer`, `api@client`, `test.droid`

Auto-fixes by replacing invalid characters with hyphens.

### Available Tools in Droid CLI

The script validates against these available tools:

```
Read, LS, Execute, Edit, MultiEdit, ApplyPatch, Grep, Glob,
Create, WebSearch, TodoWrite, FetchUrl, slack_post_message
```

### Output Example

```
🔍 Droid Configuration Validator and Fixer
==========================================

🔍 DRY RUN MODE - No changes will be made

Searching for droid files in: .factory/droids

Found 3 droid file(s):

📄 Checking: code-reviewer.droid.json
  ℹ️  Mapped 'ref___ref_search_documentation' → 'WebSearch'
  ⚠️  Removed invalid tool: 'exa___get_code_context_exa'
  ✅ Would fix configuration

📄 Checking: security-scanner.md
  ✓ Configuration is valid

📄 Checking: test-runner.droid.json
  ℹ️  Fixed invalid name: 'test runner' → 'test-runner'
  ✅ Would fix configuration

==========================================

📊 Summary:
   Total droids: 3
   Would fix: 2
   Already valid: 1

✅ Available tools in Droid CLI:
   Read, LS, Execute, Edit, MultiEdit, ApplyPatch, Grep, Glob,
   Create, WebSearch, TodoWrite, FetchUrl, slack_post_message

💡 Run without --dry-run to apply fixes
```

### File Format Support

#### Markdown Format (.md) - PRIMARY FORMAT

Factory CLI custom droids use Markdown files with YAML frontmatter:

```markdown
---
name: code-reviewer
description: Reviews code changes
model: inherit
tools: ["Read", "Grep", "WebSearch"]
---

You are a code reviewer. Analyze the code for:

## Focus Areas

- Correctness
- Security issues  
- Best practices
- Test coverage

## Guidelines

- Be concise and specific
- Provide actionable feedback
- Reference standards when available
```

#### JSON Format (.droid.json) - DEPRECATED

The old JSON format is still supported for backwards compatibility but should not be used for new droids:

```json
{
  "name": "code-reviewer",
  "description": "Reviews code changes",
  "model": "gpt-5-codex",
  "defaults": {
    "enabled_tools": ["Read", "Grep", "WebSearch"]
  },
  "prompt": "You are a code reviewer..."
}
```

**Note:** Always create new droids as Markdown (.md) files.

### Integration

Add to your CI/CD pipeline:

```yaml
# .github/workflows/validate-droids.yml
name: Validate Droid Configurations

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v1
      - name: Validate droids
        run: bun run scripts/fix-droids.ts --dry-run
```

### Related Documentation

- [Tool Compatibility Guide](../docs/TOOL_COMPATIBILITY.md) - Detailed tool availability comparison
- [Custom Droids Documentation](https://docs.factory.ai/cli/configuration/custom-droids) - Factory CLI droid format
- [Droid CLI Reference](https://docs.factory.ai/cli/droid-exec/overview) - Deployment environment

### Troubleshooting

**Error: "Invalid tools: [list]"**

Run the fix script to map/remove unavailable tools:
```bash
bun run scripts/fix-droids.ts .factory/droids
```

**Error: "Droid name must be alphanumeric"**

The script will auto-fix invalid names by replacing special characters with hyphens.

**Error: "No YAML frontmatter found"**

Only applies to .md files in droids directories. Regular markdown files are ignored.

### Contributing

To add new tool mappings:

1. Update `TOOL_MAPPINGS` in `fix-droids.ts`
2. Add to `AVAILABLE_TOOLS` if it's a new Droid CLI tool
3. Update the Tool Compatibility Guide
4. Test with `--dry-run` flag

### License

Same as Droidz project license.
