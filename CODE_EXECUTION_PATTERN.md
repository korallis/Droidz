# Code Execution Pattern for MCP Integration

## 🎯 The Problem

When you told the orchestrator to "test exa integration by searching for Convex best practices," it used `WebSearch` instead of your Exa API key from config.yml.

**Why?** Because Droidz was calling MCP tools directly (e.g., `exa___web_search_exa()`), which requires:
1. MCP servers configured via Factory CLI (`/mcp add`)
2. Per-user setup (not project-based)
3. Complex authentication

## ✅ The Solution: Code Execution Pattern

Per [Anthropic's article](https://www.anthropic.com/engineering/code-execution-with-mcp), the better pattern is:

**Use Execute tool → Call helper scripts → Scripts read config.yml**

### Why This Works

1. **API keys in project config** - No MCP server setup needed
2. **Works immediately** - Just add keys to config.yml
3. **Graceful errors** - Clear messages if keys missing
4. **Factory compliant** - Execute tool always available
5. **Team-friendly** - Everyone uses same config

## 📝 Implementation

### Created Helper Scripts

#### 1. `orchestrator/exa-search.ts`

Searches using Exa API with API key from config.yml:

```typescript
// Reads exa.api_key from config.yml
// Handles ${VAR} environment variable substitution
// Returns JSON results

// Usage:
bun orchestrator/exa-search.ts --query "Convex best practices" --num-results 5
```

**Features:**
- Reads `exa.api_key` from config.yml
- Supports environment variables (`${EXA_API_KEY}`)
- Falls back to `EXA_API_KEY` env var
- Returns structured JSON
- Clear error messages if no key found

#### 2. `orchestrator/ref-search.ts`

Searches documentation using Ref API:

```typescript
// Reads ref.api_key from config.yml
// Returns documentation matches

// Usage:
bun orchestrator/ref-search.ts --query "Next.js documentation"
```

**Same features as exa-search.ts**

### Updated Orchestrator

Changed from:
```typescript
// OLD - Direct MCP tool calls (requires MCP server setup)
const results = await exa___web_search_exa("Convex best practices");
```

To:
```bash
# NEW - Code execution pattern (uses config.yml)
Execute: bun orchestrator/exa-search.ts --query "Convex best practices" --num-results 5
```

## 🧪 Test Results

**Tested with real API keys:**

```bash
$ bun orchestrator/exa-search.ts --query "Convex database best practices" --num-results 3
{
  "requestId": "e23b146f5b9c8ccdf116d29159ad37e6",
  "results": [
    {
      "title": "Opinionated guidelines and best practices for building Convex...",
      "url": "https://gist.github.com/srizvi/966e583693271d874bf65c2a95466339",
      ...
    },
    {
      "title": "Best Practices | Convex Developer Hub",
      "url": "https://docs.convex.dev/understanding/best-practices/",
      ...
    },
    {
      "title": "Authorization Best Practices and Implementation Guide",
      "url": "https://stack.convex.dev/authorization",
      ...
    }
  ]
}
```

✅ **Works perfectly!** Reads API key from config.yml and returns structured results.

## 📚 How to Use

### For Users

1. **Add API keys to config.yml:**
   ```yaml
   exa:
     api_key: "your_exa_key_here"
   
   ref:
     api_key: "your_ref_key_here"
   ```

2. **Use orchestrator normally:**
   ```
   Use droidz-orchestrator to research Convex database patterns
   ```

3. **Orchestrator automatically uses helper scripts:**
   ```bash
   Execute: bun orchestrator/exa-search.ts --query "Convex patterns" --num-results 10
   ```

### For Orchestrator

When you need to research something:

```bash
# Research with Exa
Execute: bun orchestrator/exa-search.ts --query "{{TOPIC}} best practices" --num-results 5

# Parse JSON response
# Use results in your planning
```

**Graceful fallback if no API key:**
```json
{
  "error": "No Exa API key found",
  "help": "Add your Exa API key to config.yml or set EXA_API_KEY environment variable",
  "config": "Edit config.yml and add: exa.api_key"
}
```

## 🎯 Benefits

### Before (MCP Tool Calls)
- ❌ Required MCP server setup via `/mcp add`
- ❌ Per-user configuration (not in project)
- ❌ Complex authentication with headers
- ❌ Silent failures if not configured
- ❌ Fell back to WebSearch without explanation

### After (Code Execution Pattern)
- ✅ Just add keys to config.yml
- ✅ Project-based configuration
- ✅ Simple configuration (one YAML field)
- ✅ Clear error messages
- ✅ Transparent to users

## 🔄 Comparison Table

| Aspect | Direct MCP Calls | Code Execution Pattern |
|--------|------------------|------------------------|
| Setup | `/mcp add` command | Add key to config.yml |
| Scope | Per-user | Per-project |
| Auth | HTTP headers | Config file |
| Errors | Silent fallback | Clear messages |
| Discovery | Hard to debug | Obvious from Execute output |
| Teams | Each person sets up | One config file |
| Factory Compliant | Requires MCP support | Uses Execute (always available) |

## 📖 References

- [Anthropic: Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- [Factory.ai MCP Documentation](https://docs.factory.ai/cli/configuration/mcp)

## 🚀 Next Steps

1. ✅ Helper scripts created (exa-search.ts, ref-search.ts)
2. ✅ Orchestrator updated to use Execute pattern
3. ✅ Tested with real API keys (Exa works!)
4. ✅ Documentation created (this file)
5. 🔄 Commit changes
6. 🔄 Update user documentation

---

**The code execution pattern is now the standard way Droidz uses API services!**

Instead of requiring complex MCP server setup, users just add their API keys to config.yml and everything works automatically. 🎉
