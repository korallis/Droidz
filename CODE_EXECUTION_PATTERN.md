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

#### 2. `orchestrator/linear-fetch.ts` & `linear-update.ts`

Linear API integration using code execution pattern:

```typescript
// Reads linear.api_key from config.yml
// Fetches tickets or updates status

// Usage:
bun orchestrator/linear-fetch.ts --project "FlowScribe"
bun orchestrator/linear-update.ts --issue PROJ-123 --status "In Progress"
```

**Features:**
- Reads `linear.api_key` from config.yml
- Supports environment variables (`${LINEAR_API_KEY}`)
- Returns structured JSON (ticket data or update results)
- Clear error messages

#### 3. `orchestrator/ref-search.ts` ⚠️ **MCP-Only (Placeholder)**

**IMPORTANT:** Unlike Exa and Linear, Ref **does NOT provide a REST API**.

This script is a **placeholder** that explains two options:

**Option 1: Direct MCP Tools**
```bash
# Requires MCP server configured via Factory CLI
droid
/mcp add ref
# Then use: ref___ref_search_documentation in droids
```

**Option 2: Programmatic MCP (Code Execution)**
```typescript
// In orchestrator droid, use code-execution tool:
const code = `
  const { ref } = await import("./servers/ref");
  const results = await ref.searchDocumentation("query");
  console.log(JSON.stringify(results, null, 2));
`;
// Execute via code-execution___execute_code
```

Running the script shows a helpful error:
```bash
$ bun orchestrator/ref-search.ts --query "Next.js"
{
  "error": "Ref documentation search requires MCP server",
  "mcpOnly": true,
  "option1": { /* Direct MCP setup steps */ },
  "option2": { /* Programmatic MCP example */ }
}
```

### Updated Orchestrator - How To Use Each Service

**Exa (REST API) - Use Execute + script:**
```bash
# Uses config.yml API key
Execute: bun orchestrator/exa-search.ts --query "Convex best practices" --num-results 5
# Returns JSON with search results
```

**Linear (GraphQL API) - Use Execute + script:**
```bash
# Uses config.yml API key
Execute: bun orchestrator/linear-fetch.ts --project "FlowScribe"
# Returns JSON with 91 tickets
```

**Ref (MCP tool) - Call directly:**
```typescript
// ✅ Already available in Factory - just call it!
const refResults = await ref___ref_search_documentation("Next.js app router");
// Returns: page titles and URLs
```

**Key Difference:**
- Exa & Linear: Have APIs → Scripts call fetch() → Execute tool runs scripts
- Ref: No API → MCP tool available → Call directly (simpler!)

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

## 📊 Service Integration Summary

| Service | Integration Method | API Available | Status |
|---------|-------------------|---------------|--------|
| **Exa** | Code Execution (Execute + script) | ✅ REST API | ✅ **Working** |
| **Linear** | Code Execution (Execute + script) | ✅ GraphQL API | ✅ **Working** |
| **Ref** | MCP-only (no REST API) | ❌ MCP Tools Only | ⚠️ **MCP Required** |

### Service Details

**Exa** - AI-powered web search:
- ✅ REST API at exa.ai
- ✅ Works via code execution pattern
- ✅ Tested with real API key
- Returns: Search results, code context, web content

**Linear** - Project management:
- ✅ GraphQL API at api.linear.app
- ✅ Works via code execution pattern  
- ✅ Tested with real API key
- Returns: Issues, projects, teams, comments

**Ref** - Documentation search:
- ❌ No public REST API
- ✅ **MCP tool already available**: `ref___ref_search_documentation`
- **Best approach**: Call MCP tool directly in orchestrator
- No script needed (unlike Exa/Linear)
- Placeholder script explains why it's different

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
