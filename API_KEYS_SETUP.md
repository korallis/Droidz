# API Keys Setup Guide

## 🔐 Secure API Key Management for Droidz

This guide explains how to safely configure API keys for Linear, Exa, and Ref in Droidz.

---

## 🎯 Quick Start

### 1. Get Your API Keys

**Linear (Project Management)**
- URL: https://linear.app/settings/api
- Click "Create Key" → Copy the key
- Format: `lin_api_...`

**Exa (AI Search)**
- URL: https://exa.ai/api-keys
- Sign up → Get API key
- Format: `exa_...`

**Ref (Documentation)**
- URL: https://ref.sh/api
- Create account → Generate key
- Format: `ref_...`

### 2. Add Keys to config.yml

Open `config.yml` in your project and add your keys:

```yaml
# API Keys Configuration
linear:
  api_key: "lin_api_YOUR_ACTUAL_KEY_HERE"
  team_id: "YOUR_LINEAR_TEAM_ID"
  update_comments: true
  auto_status_updates: true

exa:
  api_key: "exa_YOUR_ACTUAL_KEY_HERE"
  enabled: true

ref:
  api_key: "ref_YOUR_ACTUAL_KEY_HERE"
  enabled: true
```

### 3. Verify Security Setup

**Check that config.yml is gitignored:**

```bash
# Should output: config.yml
git check-ignore config.yml

# Verify it won't be committed
git status
# config.yml should NOT appear in untracked files
```

**If config.yml shows up in git status:**

```bash
# Add to .gitignore immediately!
echo "config.yml" >> .gitignore
git rm --cached config.yml 2>/dev/null || true
```

---

## 🔒 Security Best Practices

### ✅ DO:

- **Keep config.yml in .gitignore** (installed by default)
- **Use environment variables** for CI/CD:
  ```yaml
  linear:
    api_key: "${LINEAR_API_KEY}"
  ```
- **Use config.example.yml** as a template (safe to commit)
- **Rotate keys regularly** (every 90 days recommended)
- **Use separate keys** for dev/staging/production

### ❌ DON'T:

- **Never commit config.yml** to git
- **Never share API keys** in issues/PRs
- **Never hardcode keys** in code
- **Never commit keys** to public repos
- **Never use production keys** in development

---

## 🌍 Environment Variables (Alternative)

Instead of pasting keys directly, you can use environment variables:

### Setup Environment Variables

**macOS/Linux:**

```bash
# Add to ~/.zshrc or ~/.bashrc
export LINEAR_API_KEY="lin_api_your_key_here"
export EXA_API_KEY="exa_your_key_here"
export REF_API_KEY="ref_your_key_here"

# Reload shell
source ~/.zshrc  # or source ~/.bashrc
```

**Windows (PowerShell):**

```powershell
# Add to $PROFILE
$env:LINEAR_API_KEY="lin_api_your_key_here"
$env:EXA_API_KEY="exa_your_key_here"
$env:REF_API_KEY="ref_your_key_here"
```

### Use in config.yml

```yaml
linear:
  api_key: "${LINEAR_API_KEY}"  # Reads from environment
  
exa:
  api_key: "${EXA_API_KEY}"
  
ref:
  api_key: "${REF_API_KEY}"
```

**Benefits:**
- ✅ Keys never stored in files
- ✅ Easy to rotate without editing files
- ✅ Works across projects
- ✅ CI/CD friendly

---

## 🏢 Team Setup

### For Team Projects

1. **Each developer gets their own keys:**
   - Everyone creates their own `config.yml` from `config.example.yml`
   - Everyone adds their own API keys
   - `config.yml` is never committed (in .gitignore)

2. **Share config.example.yml:**
   ```yaml
   # config.example.yml (safe to commit)
   linear:
     api_key: "${LINEAR_API_KEY}"  # Team uses env vars
     team_id: "shared_team_id"     # This is safe to share
   ```

3. **Document in README:**
   ```markdown
   ## Setup
   1. Copy config.example.yml to config.yml
   2. Add your API keys (see API_KEYS_SETUP.md)
   3. Never commit config.yml!
   ```

---

## 🔄 Rotating Keys

**When to rotate:**
- Every 90 days (good practice)
- After team member leaves
- If key is exposed/leaked
- After security incident

**How to rotate:**

1. **Generate new key** in service (Linear/Exa/Ref)
2. **Update config.yml** with new key
3. **Test immediately:**
   ```bash
   droid
   # Test Linear
   Use droidz-orchestrator to fetch my Linear issues
   ```
4. **Delete old key** from service
5. **Update team** (if shared team account)

---

## 🐛 Troubleshooting

### "Authentication failed" Errors

**Check:**
1. Key is correct (no extra spaces/newlines)
2. Key has proper permissions
3. Key hasn't expired
4. Service is online

**Test Linear key:**
```bash
curl -H "Authorization: Bearer YOUR_KEY" \
  https://api.linear.app/graphql \
  -d '{"query":"{ viewer { id name } }"}'
```

### "API key not found" Errors

**Check:**
1. config.yml exists in project root
2. Keys are properly formatted:
   ```yaml
   linear:
     api_key: "lin_api_..."  # Must be quoted!
   ```
3. No typos in field names

### Keys Not Working After Update

**Solution:**
1. Compare your `config.yml` with `config.example.yml`
2. Check for new required fields
3. Ensure proper YAML formatting (indentation matters!)

---

## 📚 Related Documentation

- **[MCP_SETUP.md](MCP_SETUP.md)** - MCP server configuration
- **[QUICK_START_V2.md](QUICK_START_V2.md)** - Getting started guide
- **[README.md](README.md)** - Main documentation

---

## 🚨 Emergency: Key Leaked!

**If you accidentally committed your API key:**

1. **Revoke immediately:**
   - Linear: https://linear.app/settings/api → Delete key
   - Exa: https://exa.ai/api-keys → Revoke
   - Ref: https://ref.sh/api → Revoke

2. **Generate new key:**
   - Create new key in service
   - Update config.yml

3. **Clean git history:**
   ```bash
   # Remove from last commit
   git reset --soft HEAD~1
   
   # Add config.yml to .gitignore
   echo "config.yml" >> .gitignore
   
   # Commit properly
   git add .gitignore
   git commit -m "fix: add config.yml to gitignore"
   ```

4. **If already pushed to remote:**
   ```bash
   # Use BFG Repo Cleaner or git-filter-repo
   # See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
   ```

**Consider using GitHub secret scanning alerts!**

---

## ✅ Security Checklist

Before sharing your project:

- [ ] config.yml is in .gitignore
- [ ] config.example.yml has no real keys
- [ ] No API keys in code comments
- [ ] No keys in commit history
- [ ] README explains setup process
- [ ] Team knows not to commit config.yml

---

**Stay safe! 🔒 Happy building! 🚀**
