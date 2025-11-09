# Droidz Installation Guide

Complete installation instructions for all scenarios.

---

## Quick Install (Recommended)

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

This downloads Droidz from GitHub and installs it in the current directory.

**What it does:**
1. Downloads the latest version from GitHub
2. Extracts workflows, standards, and droids
3. Sets up your project for spec-driven development

**Verify installation:**
```bash
ls .claude/agents/    # Should show 5 droids
ls workflows/         # Should show planning, specification, implementation
ls standards/         # Should show 3 standard files
cat config.yml        # Should show configuration
```

---

## Alternative: Clone and Install

If you want to customize or inspect before installing:

```bash
# Clone the repository
git clone https://github.com/korallis/Droidz.git
cd Droidz

# Install in current project
bash scripts/install.sh

# Or install in specific directory
bash scripts/install.sh /path/to/your/project
```

---

## Installation Methods Comparison

| Method | Speed | Use Case |
|--------|-------|----------|
| `curl \| bash` | Fast | Quick setup, production use |
| Clone + install | Slower | Customization, inspection, development |
| Manual copy | Manual | Full control, air-gapped systems |

---

## Environment Variables

Customize the installation:

```bash
# Install from a fork
DROIDZ_REPO="your-org/your-fork" \
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash

# Install specific branch
DROIDZ_BRANCH="develop" \
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash

# Combine both
DROIDZ_REPO="your-org/fork" DROIDZ_BRANCH="custom" \
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

---

## Verify Installation

### Check Files Exist

```bash
# Essential files
ls .claude/agents/droidz-orchestrator.md
ls workflows/planning/create-product-roadmap.md
ls standards/security.md
ls config.yml

# Count installed droids
ls .claude/agents/ | wc -l  # Should be 5

# Check workflow structure
tree workflows/  # or: ls -R workflows/
```

### Verify Content

```bash
# Check droids have content
wc -l .claude/agents/*.md

# Should show:
#   ~450 lines droidz-implementer.md
#   ~850 lines droidz-orchestrator.md
#   ~370 lines droidz-planner.md
#   ~505 lines droidz-spec-writer.md
#   ~558 lines droidz-verifier.md
```

### Test in Droid CLI

```bash
droid
```

Then in Droid:
```
@droidz-orchestrator hello
```

If the droid responds, installation is successful!

---

## Troubleshooting

### Empty Directories After Install

**Symptom:** Installation succeeds but `workflows/`, `standards/`, `.claude/agents/` are empty.

**Cause:** GitHub's CDN cache may be serving an old version of the installer.

**Solution 1 - Use Commit SHA:**
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/ba5c9c7/scripts/install.sh | bash
```

**Solution 2 - Clone directly:**
```bash
git clone https://github.com/korallis/Droidz.git
cd Droidz
bash scripts/install.sh
```

**Solution 3 - Wait:**
GitHub's CDN cache clears within 5-10 minutes. Try again later.

### Permission Denied

**Symptom:** `Permission denied` errors during installation.

**Solution:**
```bash
# Ensure target directory is writable
ls -ld .

# If installing to system directory, use sudo (not recommended)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | sudo bash
```

### Droids Not Loading in Droid CLI

**Symptom:** Custom droids don't appear in Droid CLI.

**Check:**
```bash
# Verify files exist
ls .claude/agents/

# Check file permissions
ls -la .claude/agents/

# Verify YAML frontmatter
head -10 .claude/agents/droidz-orchestrator.md
# Should start with: ---
#                    name: Droidz Orchestrator
#                    ...
```

**Solution:**
- Ensure `.claude/agents/` directory exists
- Verify `.md` files have proper YAML frontmatter
- Restart Droid CLI

### Config File Not Created

**Symptom:** `config.yml` missing after installation.

**This is normal if:**
- You already have a `config.yml` (installer won't overwrite)
- You're running an old cached version

**Solution:**
```bash
# Copy manually from repo
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/config.yml > config.yml
```

---

## Uninstall

To remove Droidz from a project:

```bash
rm -rf .claude/agents/droidz-*.md
rm -rf workflows/ standards/ droidz/
rm config.yml
```

**Note:** This only removes Droidz files, not your project code or specs created during usage.

To keep your specs and products:
```bash
# Backup first
cp -r droidz/ droidz-backup/

# Then uninstall
rm -rf .claude/agents/droidz-*.md workflows/ standards/
```

---

## Upgrading

To upgrade to the latest version:

```bash
# Backup current standards (they may be customized)
cp -r standards/ standards-backup/

# Reinstall
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash

# Review and merge your custom standards
diff standards/ standards-backup/
```

**Note:** `config.yml` won't be overwritten if it exists, so your settings are preserved.

---

## Manual Installation

If automated installation doesn't work, install manually:

1. **Download the repository:**
   ```bash
   curl -L https://github.com/korallis/Droidz/archive/refs/heads/main.zip -o droidz.zip
   unzip droidz.zip
   cd Droidz-main
   ```

2. **Copy files:**
   ```bash
   cp -r workflows ../your-project/
   cp -r standards ../your-project/
   cp -r .claude/agents ../your-project/.claude/
   cp config.yml ../your-project/
   ```

3. **Verify:**
   ```bash
   cd ../your-project
   ls .claude/agents/ workflows/ standards/
   ```

---

## Next Steps

After successful installation:

1. **Customize standards** for your project:
   ```bash
   vi standards/coding-conventions.md
   vi standards/architecture.md
   vi standards/security.md
   ```

2. **Read the workflows** to understand the process:
   ```bash
   cat workflows/planning/create-product-roadmap.md
   ```

3. **Start Droid CLI:**
   ```bash
   droid
   ```

4. **Build something:**
   ```
   @droidz-orchestrator I want to build a task management app
   ```

---

## Support

- **Issues:** https://github.com/korallis/Droidz/issues
- **README:** [README.md](README.md)
- **Workflows:** [workflows/](workflows/)
- **Standards:** [standards/](standards/)

Happy building! 🚀
