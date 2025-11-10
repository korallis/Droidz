# MCP Server Setup for Droidz

## 🎯 Overview

Droidz orchestrator uses **dynamic MCP tools** when available, with automatic fallbacks.

**How MCP Works:**
- MCP tools are **dynamically provided by Factory** when you configure servers via `/mcp add`
- They're **NOT in the tools array** - Factory makes them available automatically
- The orchestrator can call them directly (e.g., `exa___web_search_exa()`)
- If not configured, gracefully falls back to WebSearch or Execute scripts

**Setup options (pick one):**
1. **MCP Servers** (Recommended) - Dynamic tools provided by Factory
2. **Config.yml** (Fallback) - API keys for Execute scripts
3. **No setup** (Basic) - Uses WebSearch/FetchUrl

---

## 🚀 Recommended: MCP Server Setup

**Best experience** - orchestrator uses direct tool calls!

### Step 1: Configure MCP Servers

```bash
droid
/mcp add exa      # Web & code search
/mcp add linear   # Project management
/mcp add ref      # Documentation search
```

### Step 2: Test

```bash
droid
> Use droidz-orchestrator to search for "React patterns" with Exa
```

Orchestrator will automatically use MCP tools!

## 🔄 Alternative: config.yml (Simple!)

**Don't want MCP servers?** Just set your Linear project name:

```yaml
linear:
  project_name: "MyProject"  # For existing projects
```

That's it! Orchestrator will use WebSearch for research.

**Advanced:** If you have Exa/Linear API keys and want to use Execute script fallbacks:
- Add them to config.yml (see orchestrator/exa-search.ts, orchestrator/linear-fetch.ts)
- Scripts will read keys and make API calls
- Still works, just not as fast as MCP direct calls

**Security:** config.yml is gitignored by default!

---

## 🔍 How It Works

**Droidz orchestrator automatically:**

1. **Tries MCP tools first** - Calls `exa___web_search_exa()` directly
2. **Falls back if needed** - Uses `Execute: bun orchestrator/exa-search.ts`
3. **Final fallback** - Uses `WebSearch` for general queries

**Result:** Always works, regardless of your setup!

### Priority Order

| Method | Speed | Setup Required |
|--------|-------|----------------|
| MCP direct calls | ⚡⚡⚡ Fastest | `/mcp add` commands |
| Execute scripts | ⚡⚡ Fast | API keys in config.yml |
| WebSearch/FetchUrl | ⚡ Basic | None |

---

## 📦 MCP Servers for Droidz

### Quick Setup (All Three)

```bash
droid
/mcp add exa      # AI search - get key from https://exa.ai/api-keys  
/mcp add linear   # Project mgmt - get key from https://linear.app/settings/api
/mcp add ref      # Documentation - get key from https://ref.sh/api
```

### What Each Server Provides

**Exa** - AI-powered search:
- `exa___web_search_exa` - Web search optimized for AI
- `exa___get_code_context_exa` - Code context search

**Linear** - Project management:
- `linear___list_issues` - Fetch tickets
- `linear___update_issue` - Update status
- `linear___create_comment` - Add comments
- Plus: create_issue, get_issue, list_projects, list_teams

**Ref** - Documentation:
- `ref___ref_search_documentation` - Search docs
- `ref___ref_read_url` - Read specific documentation pages

---

## 🚀 Factory CLI Setup (Alternative Method)

If you prefer to configure MCP servers via Factory CLI instead of config.yml:

### Step 1: Get API Keys

Before adding MCP servers, obtain API keys:

1. **Linear**: https://linear.app/settings/api
2. **Exa**: https://exa.ai/api-keys
3. **Ref**: https://ref.sh/api

### Step 2: Add MCP Servers

Start Factory and add each server:

```bash
droid
```

Then add servers one by one:

```bash
# Linear
/mcp add --type http linear https://api.linear.app/mcp \
  -H "Authorization: Bearer lin_api_..."

# Exa
/mcp add --type http exa https://mcp.exa.ai \
  -H "Authorization: Bearer exa_..."

# Ref
/mcp add --type http ref https://mcp.ref.sh \
  -H "Authorization: Bearer ref_..."
```

### Step 3: Verify MCP Servers

Check that servers are configured:

```bash
/mcp list
```

You should see:
```
✓ linear (http) - connected
✓ exa (http) - connected
✓ ref (http) - connected
```

### Step 4: Test Availability

In Factory, test that MCP tools work:

```bash
droid
```

Then try:
```
Search for "React hooks best practices" using exa
```

If Exa MCP is configured, it will use `exa___web_search_exa` automatically!

---

## 🔧 Configuration Storage

MCP server configurations are stored in:
```
~/.factory/mcp-config.json
```

This file is **user-specific**, not project-specific. Each user configures their own MCP servers.

---

## 📝 Using MCPs in Droidz

### Orchestrator Droid

The orchestrator can automatically use MCP tools if available:

**Linear integration:**
- If Linear MCP is configured → Uses MCP tools directly
- If not configured → Falls back to helper scripts (linear-fetch.ts, linear-update.ts)

**Web search:**
- If Exa MCP is configured → Uses `exa___web_search_exa`
- If not configured → Uses Factory's built-in `WebSearch` tool

**Documentation:**
- If Ref MCP is configured → Uses `ref___ref_search_documentation`
- If not configured → Uses `WebSearch` or `FetchUrl`

### Specialist Droids

Specialist droids (codegen, test, etc.) also get access to configured MCPs automatically. No changes needed!

---

## 💡 Optional vs Required

### MCPs are OPTIONAL

Droidz works **without** any MCP servers configured. Helper scripts provide fallback functionality:

```bash
# Without Linear MCP - uses helper script
bun orchestrator/linear-fetch.ts --project X --sprint Y

# With Linear MCP - uses MCP tool
linear___list_issues(project: "X", sprint: "Y")
```

### When to Use MCPs

**Use MCP servers when:**
- ✅ You have API keys for the services
- ✅ You want direct API access (faster, more features)
- ✅ You need real-time data
- ✅ You're using services heavily

**Use helper scripts when:**
- ✅ You don't have API keys
- ✅ You want simplicity (no setup)
- ✅ You're testing/prototyping
- ✅ You need offline functionality

---

## 🐛 Troubleshooting

### Problem: MCP server won't connect

**Solution:**
```bash
# Check server status
/mcp list

# Get server details
/mcp get linear

# Remove and re-add with correct key
/mcp remove linear
/mcp add --type http linear https://api.linear.app/mcp \
  -H "Authorization: Bearer NEW_API_KEY"
```

### Problem: MCP tools not available

**Verify:**
1. Server is added: `/mcp list`
2. Server is enabled (not disabled)
3. API key is valid
4. Network connection works

### Problem: Wrong MCP server URL

**Check documentation:**
- Linear: Check Linear's MCP documentation
- Exa: https://docs.exa.ai/mcp
- Ref: https://docs.ref.sh/mcp

**Note:** Some MCP server URLs in this guide may be examples. Check official documentation for actual endpoints.

---

## 📊 MCP vs Helper Scripts Comparison

| Feature | MCP Servers | Helper Scripts |
|---------|-------------|----------------|
| **Setup** | Requires API keys | Works out of box |
| **Speed** | Direct API (fast) | Via Execute tool |
| **Features** | Full API access | Limited features |
| **Offline** | Requires internet | Can work offline |
| **Cost** | May have API costs | Free (uses Execute) |
| **Maintenance** | User configures | Included in Droidz |

---

## 🎯 Best Practices

### 1. Secure API Keys

**DO:**
- Store keys in `~/.factory/mcp-config.json` (done automatically)
- Never commit API keys to git
- Use environment variables for scripts

**DON'T:**
- Put API keys in config.yml
- Share API keys in code
- Commit MCP configurations to repo

### 2. Enable Only What You Need

Don't add all MCPs if you won't use them:

```bash
# Only use Linear? Just add Linear
/mcp add --type http linear https://api.linear.app/mcp -H "Authorization: Bearer ..."

# Skip Exa and Ref if not needed
```

### 3. Test Before Production

Test MCP configurations before using in important workflows:

```bash
droid
> Test linear integration by listing my issues
```

### 4. Disable When Not Needed

Temporarily disable MCPs without removing:

```bash
# Disable during testing
/mcp disable exa

# Re-enable later
/mcp enable exa
```

---

## 🔗 Resources

- **Factory MCP Docs**: https://docs.factory.ai/cli/configuration/mcp
- **MCP Protocol**: https://modelcontextprotocol.io/
- **Anthropic MCP Guide**: https://www.anthropic.com/engineering/code-execution-with-mcp

---

## 📝 Summary

**Key Points:**
1. ✅ MCP servers are user-configured via `/mcp add` command
2. ✅ NOT referenced in droid tools arrays
3. ✅ Available to all droids once configured
4. ✅ Optional - Droidz works without them
5. ✅ Helper scripts provide fallback functionality

**Quick Setup:**
```bash
# 1. Start Factory
droid

# 2. Add MCP servers with your API keys
/mcp add --type http linear https://api.linear.app/mcp -H "Authorization: Bearer YOUR_KEY"
/mcp add --type http exa https://mcp.exa.ai -H "Authorization: Bearer YOUR_KEY"
/mcp add --type http ref https://mcp.ref.sh -H "Authorization: Bearer YOUR_KEY"

# 3. Verify
/mcp list

# 4. Use Droidz normally - MCPs available automatically!
```

**That's it!** MCP servers enhance Droidz but aren't required. 🚀
