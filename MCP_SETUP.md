# MCP Server Setup for Droidz

## 🎯 Overview

Droidz droids can access **MCP (Model Context Protocol) servers** for extended functionality like Linear, Exa, and Ref. 

**Two ways to configure:**
1. **Config.yml (Recommended)** - Store API keys in `config.yml` for easy management
2. **Factory CLI** - Add MCP servers via `/mcp` command (user-specific)

---

## 📋 Quick Setup (config.yml Method)

**This is the easiest way!** Your API keys are stored in `config.yml` and used automatically.

### Step 1: Get Your API Keys

1. **Linear:** https://linear.app/settings/api
2. **Exa:** https://exa.ai/api-keys
3. **Ref:** https://ref.sh/api

### Step 2: Add Keys to config.yml

Edit your `config.yml`:

```yaml
# API Keys Configuration
linear:
  api_key: "lin_api_YOUR_KEY_HERE"  # Paste your Linear key
  team_id: "YOUR_TEAM_ID"
  
exa:
  api_key: "exa_YOUR_KEY_HERE"  # Paste your Exa key
  enabled: true
  
ref:
  api_key: "ref_YOUR_KEY_HERE"  # Paste your Ref key
  enabled: true
```

### Step 3: Verify Security

Make sure `config.yml` is in your `.gitignore`:

```bash
# Check if config.yml is ignored
git check-ignore config.yml
# Should output: config.yml

# If not, add it:
echo "config.yml" >> .gitignore
```

**⚠️ IMPORTANT:** Never commit `config.yml` to git! It contains your API keys.

---

## 🔍 How MCP Works

### Using config.yml (Recommended)

When you add API keys to `config.yml`, Droidz helper scripts use them to:
- Fetch Linear tickets
- Update issue statuses
- Search with Exa
- Query documentation with Ref

**Benefits:**
- ✅ Easy to set up
- ✅ Works immediately
- ✅ All team members can use same config
- ✅ Keys stored locally (not in git)

### Using Factory CLI (Alternative)

You can also add MCP servers directly via Factory CLI:

**Key Concepts:**
1. **MCP servers are user-configured** - Each user adds them via `/mcp add` command
2. **Tools become available dynamically** - Once configured, MCP tools work in all droids
3. **No code changes needed** - Droids automatically get access to configured MCP tools
4. **Optional by design** - Users only add the MCPs they need

**Why Not in Droid Tools Array?**

According to [Factory documentation](https://docs.factory.ai/cli/configuration/custom-droids), MCP tools are **dynamically populated** - they're not referenced directly in the tools array!

---

## 📦 Recommended MCP Servers for Droidz

### 1. Linear (Project Management)

**What it provides:**
- Issue tracking and management
- Project/sprint queries
- Automated status updates
- Comment posting

**How to add:**
```bash
droid
/mcp add --type http linear https://api.linear.app/mcp \
  -H "Authorization: Bearer YOUR_LINEAR_API_KEY"
```

**Get your API key:** https://linear.app/settings/api

**Available tools (once configured):**
- `linear___list_issues`
- `linear___get_issue`
- `linear___create_issue`
- `linear___update_issue`
- `linear___create_comment`
- `linear___list_projects`
- `linear___list_teams`

### 2. Exa (AI-Powered Search)

**What it provides:**
- Web search optimized for AI
- Code context search
- Documentation discovery

**How to add:**
```bash
droid
/mcp add --type http exa https://mcp.exa.ai \
  -H "Authorization: Bearer YOUR_EXA_API_KEY"
```

**Get your API key:** https://exa.ai/api-keys

**Available tools (once configured):**
- `exa___web_search_exa`
- `exa___get_code_context_exa`

### 3. Ref (Documentation Search)

**What it provides:**
- Public documentation search
- Private documentation (if configured)
- API reference lookup

**How to add:**
```bash
droid
/mcp add --type http ref https://mcp.ref.sh \
  -H "Authorization: Bearer YOUR_REF_API_KEY"
```

**Get your API key:** https://ref.sh/api

**Available tools (once configured):**
- `ref___ref_search_documentation`
- `ref___ref_read_url`

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
