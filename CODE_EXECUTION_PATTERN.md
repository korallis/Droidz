# Droidz MCP Integration Pattern (UPDATED)

## 🎯 Current Approach: Dynamic MCP Tools with Graceful Fallbacks

**IMPORTANT:** MCP tools like `exa___web_search_exa`, `linear___list_issues`, etc. are **NOT in the tools array**.
They're dynamically provided by Factory when users configure MCP servers via `/mcp add`.

The orchestrator can call them directly, and Factory provides them automatically if available.

### The Pattern

**1. Try MCP tools first (if user has them configured):**
```typescript
const results = await exa___web_search_exa("React patterns");
const issues = await linear___list_issues({ project: "MyProject" });
const docs = await ref___ref_search_documentation("Next.js");
```

**2. Fall back gracefully if MCP not available:**
```bash
# WebSearch for research
WebSearch: "React patterns best practices"

# Execute scripts for Linear (reads config.yml)
Execute: bun orchestrator/linear-fetch.ts --project "MyProject"
```

### Why This Works

1. **MCP configured?** → Uses direct calls (fast, powerful)
2. **No MCP?** → Falls back automatically (still works!)
3. **User never sees errors** → Graceful degradation
4. **Zero configuration required** → Works out of the box
5. **Best of both worlds** → Power when available, simplicity when not

## 📝 How Orchestrator Uses Services

### Exa - Web & Code Search

**Primary (MCP Server):**
```typescript
const results = await exa___web_search_exa("Convex best practices", { numResults: 5 });
```

**Fallback (Execute Script):**
```bash
Execute: bun orchestrator/exa-search.ts --query "Convex best practices" --num-results 5
```

The script reads `exa.api_key` from config.yml and returns JSON results.

### Linear - Project Management

**Primary (MCP Server):**
```typescript
const issues = await linear___list_issues({ project: "FlowScribe" });
await linear___update_issue({ id: "issue-id", stateId: "in-progress-id" });
```

**Fallback (Execute Scripts):**
```bash
Execute: bun orchestrator/linear-fetch.ts --project "FlowScribe"
Execute: bun orchestrator/linear-update.ts --issue PROJ-123 --status "In Progress"
```

The scripts read `linear.api_key` from config.yml.

### Ref - Documentation Search

**Primary (MCP Server):**
```typescript
const docs = await ref___ref_search_documentation("Next.js app router");
const content = await ref___ref_read_url("https://nextjs.org/docs/14/app");
```

**Fallback (WebSearch + FetchUrl):**
```bash
WebSearch: "Next.js 14 app router official documentation"
FetchUrl: https://nextjs.org/docs/14/app
```

**Note:** Ref has no REST API, so fallback uses general web tools.

## 🎯 Decision Flow

**The orchestrator automatically:**

1. **Tries MCP tool first** - If user has `/mcp add exa` configured
2. **Falls back gracefully** - Uses Execute scripts or WebSearch
3. **Never errors** - Always finds a way to get the information

## 🛠️ Setup for Users

### Option 1: Use MCP Servers (Recommended for power users)

```bash
droid
/mcp add exa
/mcp add linear
/mcp add ref
```

Orchestrator will use direct MCP tool calls automatically.

### Option 2: Use Execute Scripts (Fallback)

Add API keys to `config.yml`:
```yaml
exa:
  api_key: "exa_YOUR_KEY"
linear:
  api_key: "lin_api_YOUR_KEY"
  project_name: "MyProject"
```

Orchestrator will use Execute scripts if MCP not available.

### Option 3: No Setup (Basic mode)

Use WebSearch and FetchUrl for research. Still works, just less powerful!

## 📚 For Users

### Quick Start

1. **Configure MCP servers** (recommended):
   ```bash
   droid
   /mcp add exa
   /mcp add linear
   /mcp add ref
   ```

2. **Set Linear project name** in config.yml (for existing projects):
   ```yaml
   linear:
     project_name: "MyProject"
   ```

3. **Use orchestrator:**
   ```
   Use droidz-orchestrator to research Convex database patterns
   ```

Orchestrator automatically tries MCP tools, falls back to WebSearch if needed!

### For Droid Users

Orchestrator handles everything automatically:

```
Use droidz-orchestrator to research React patterns

# Behind the scenes:
# 1. Tries: exa___web_search_exa("React patterns") 
# 2. Falls back to: WebSearch("React patterns")
# 3. You get results either way!
```

## 📊 Service Integration Summary

| Service | Primary Method | Fallback | Notes |
|---------|---------------|----------|-------|
| **Exa** | MCP tool | Execute script | REST API available |
| **Linear** | MCP tool | Execute script | GraphQL API available |
| **Ref** | MCP tool | WebSearch + FetchUrl | MCP-only (no REST API) |

## 📖 Resources

- [Factory.ai MCP Documentation](https://docs.factory.ai/cli/configuration/mcp)
- [Droidz MCP Setup Guide](./MCP_SETUP.md)

## 🎯 Practical Example

**Scenario:** Research Convex best practices with Linear tickets

```typescript
// Orchestrator tries MCP first, falls back automatically:

// 1. Try Exa MCP, fallback to Execute script
const exaResults = await exa___web_search_exa("Convex database patterns");
// or: Execute: bun orchestrator/exa-search.ts --query "Convex patterns"

// 2. Try Linear MCP, fallback to Execute script
const issues = await linear___list_issues({ project: "FlowScribe" });
// or: Execute: bun orchestrator/linear-fetch.ts --project "FlowScribe"

// 3. Try Ref MCP, fallback to WebSearch
const docs = await ref___ref_search_documentation("Convex best practices");
// or: WebSearch: "Convex best practices official documentation"
```

**The orchestrator handles all fallback logic automatically - you just call the tools!**
