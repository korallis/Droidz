# MCP Tools in Droidz - How It Actually Works

## 🔑 Key Concept: Dynamic Tool Availability

**MCP tools are NOT in the tools array!**

```yaml
# ❌ WRONG - Don't do this:
tools: [
  "Read", "Execute", 
  "exa___web_search_exa",  # DON'T ADD MCP TOOLS HERE!
  "linear___list_issues"   # This causes errors!
]

# ✅ CORRECT - Only standard tools:
tools: ["Read", "LS", "Execute", "Edit", "Grep", "Glob", "Create", "TodoWrite", "WebSearch", "FetchUrl"]
```

## 🎯 How MCP Works in Factory

### Step 1: User Configures MCP Server

```bash
droid
/mcp add exa  # Configure Exa MCP server
```

### Step 2: Factory Provides Tools Dynamically

- Factory automatically makes `exa___web_search_exa` available
- It's provided to **ALL droids** automatically
- No need to declare it in tools array
- The droid can just call it!

### Step 3: Droid Calls MCP Tool

```typescript
// This works if user configured Exa MCP:
const results = await exa___web_search_exa("React patterns");

// If not configured, tool doesn't exist (graceful failure)
// Droid falls back to: WebSearch("React patterns")
```

## 📋 Complete Example

### User Setup

```bash
droid
/mcp add exa
/mcp add linear
/mcp add ref
```

### What Happens

1. Factory connects to Exa MCP server
2. Factory connects to Linear MCP server  
3. Factory connects to Ref MCP server
4. All droids can now use:
   - `exa___web_search_exa()`
   - `exa___get_code_context_exa()`
   - `linear___list_issues()`
   - `linear___get_issue()`
   - `linear___create_issue()`
   - `linear___update_issue()`
   - `linear___create_comment()`
   - `ref___ref_search_documentation()`
   - `ref___ref_read_url()`

### Orchestrator Code

```typescript
// Orchestrator can call these directly:
try {
  // Try MCP tool first
  const results = await exa___web_search_exa("React patterns", { numResults: 5 });
  // Use results...
} catch (error) {
  // MCP not configured, fall back
  WebSearch: "React patterns best practices"
}
```

## 🚫 Common Mistakes

### Mistake 1: Adding MCP Tools to Tools Array

```yaml
# ❌ DON'T DO THIS:
tools: ["Read", "Execute", "exa___web_search_exa"]
# Error: Invalid tools: exa___web_search_exa
```

**Why it fails:**
- MCP tools are dynamically provided
- They can't be statically declared
- Factory manages their availability

### Mistake 2: Assuming MCP Tools Are Always Available

```typescript
// ❌ DON'T DO THIS:
const results = await exa___web_search_exa("query");
// Will fail if user didn't configure Exa MCP!
```

**Fix: Always have fallback:**
```typescript
// ✅ DO THIS:
try {
  const results = await exa___web_search_exa("query");
} catch {
  // Fallback
  WebSearch: "query"
}
```

### Mistake 3: Telling Users to Add API Keys to config.yml

```yaml
# ❌ OLD WAY (don't document this):
exa:
  api_key: "exa_YOUR_KEY"
```

**New way: MCP servers!**
```bash
# ✅ CORRECT WAY:
droid
/mcp add exa  # Provide key when prompted
```

## 📚 Why This Design?

**Benefits of dynamic MCP tools:**

1. **User choice** - Only available if user wants them
2. **No errors** - Tools missing = graceful fallback
3. **Secure** - API keys stored in Factory, not in git
4. **Flexible** - Different users can have different MCPs
5. **Simple** - No complex tool array management

## 🎓 For Droid Developers

When creating custom droids:

```yaml
---
name: my-custom-droid
tools: ["Read", "Execute", "WebSearch"]  # Only standard tools
---

# In your instructions:
# "Try calling exa___web_search_exa() if available"
# "Fall back to WebSearch if MCP not configured"
```

**Don't:**
- Add MCP tools to tools array
- Assume MCP tools exist
- Document API keys in config.yml as primary method

**Do:**
- Call MCP tools directly (they might be available!)
- Always have fallback to standard tools
- Document MCP servers as recommended setup

## 🔗 References

- [Factory MCP Documentation](https://docs.factory.ai/cli/configuration/mcp)
- [MCP Setup Guide](./MCP_SETUP.md)
- [Code Execution Pattern](./CODE_EXECUTION_PATTERN.md)
