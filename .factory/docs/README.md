# Droidz Documentation

## Quick Links

- **[Symlink Workaround](./SYMLINK_WORKAROUND.md)** - Fix for Factory.ai droid loading bug
- **[Project-Specific Install](./PROJECT_SPECIFIC_INSTALL.md)** - Understanding per-project installation
- **[../scripts/](../scripts/)** - Automation scripts

## Factory.ai Bug Workaround

Factory.ai CLI has a bug where it looks for `.json` droids during parallel execution, but the official format is `.md`.

**Solution:** Symlinks (`.json → .md`)

**How to apply:** Just run `/droidz-init` - it's automatic! ✨

## Scripts

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `apply-droid-workaround.sh` | Create symlinks automatically | Called by `/droidz-init` |
| `create-droid-symlinks.sh` | Create symlinks interactively | Manual fix if needed |
| `diagnose-droid-issue.sh` | Diagnose droid loading problems | When debugging |

## Typical User Journey

1. **Install Droidz**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
   ```

2. **Enable in Factory.ai**
   ```
   droid
   /settings → Custom Droids → ON
   ```

3. **Initialize (AUTOMATIC FIX)**
   ```
   /droidz-init
   ```

4. **Start Building**
   ```
   Use droidz-orchestrator to build [feature]
   ```

That's it! The symlink workaround is applied automatically in step 3.
