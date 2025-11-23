# 🤖 Droidz Instruction Platform

Agent-aware instruction framework with a two-tier architecture: shared standards in `~/.droidz` plus platform-specific commands and agents for your favorite AI coding tools (Factory AI, Claude Code, Cursor, Cline, Codex CLI, and VS Code).

## What You Get
- `install.py` – zero-interaction CLI that installs both shared framework and agent-specific payloads.
- `droidz_installer/` – manifest-driven engine with profile support for custom workflows.
- **Shared Framework** (`~/.droidz`) – universal standards, validation rules, and version tracking.
- **Agent-Specific Payloads** – commands, agents, and platform-tailored instructions.
- `tests/` – pytest coverage for multi-target installation, backups, and dry-run safety.
- `pyproject.toml` – lightweight toolchain with Ruff + pytest ready to run the Validation Gate.
## 💬 Join Our Discord Community

**Built specifically for Ray Fernando's Discord members!** 🎯

Get early access, share tips, connect with contributors, and influence future development.

**[→ Join Discord Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

---

## 💝 Support This Project

If Droidz saves you time, consider supporting its development!

**[→ Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

Your support helps maintain and improve this framework! 🙏

### With Gratitude
We’re deeply thankful for the generosity of friends who keep this instruction stack alive:

- **Sorennza**
- **Ray Fernando**
- **Douwe de Vries**

Every contribution—large or small—directly fuels new payloads, validation helpers, and continued open distribution. Thank you for believing in Droidz.

## Install Python 3.11+ (macOS)
1. Check whether an acceptable version already exists:
   ```bash
   python3 --version
   ```
   Continue only if the major/minor version is lower than 3.11.
2. **Homebrew path** (fastest for most Macs):
   ```bash
   brew update
   brew install python@3.11
   brew link --overwrite python@3.11
   echo 'export PATH="$(brew --prefix)/opt/python@3.11/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   python3.11 --version
   pip3.11 --version
   ```
3. **Installer path** (when Homebrew isn’t available): download the latest universal2 `.pkg` installer for Python 3.11 from the official Python downloads page, double-click it, and accept the defaults. When it finishes, open `/Applications/Python 3.11/Install Certificates.command` to register SSL certificates, then verify with `python3.11 --version`.

## Install Python 3.11+ (Windows)
1. Open an elevated PowerShell window and see if Python is already new enough:
   ```powershell
   python --version
   ```
2. **Winget path** (auto-manages PATH entries):
   ```powershell
   winget install --id Python.Python.3.11 -e --source winget
   python --version
   ```
3. **Manual installer path** (for offline or scripted setups):
   ```powershell
   $Version = "3.11.8"
   $Installer = "$env:TEMP\python-$Version-amd64.exe"
   Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$Version/python-$Version-amd64.exe" -OutFile $Installer
   Start-Process -FilePath $Installer -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
   Remove-Item $Installer
   python --version
   ```
   Update `$Version` whenever a newer 3.11 maintenance release ships.

## Run the Installer with One Command
Use the bootstrap script to download the latest release, extract it to a temporary directory, and invoke `install.py` in a single shot. Pick the command that matches your tool:

```bash
# Claude Code
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform claude --install-to-project

# Factory.ai Droid CLI (can also use: --platform droid_cli)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform factory --install-to-project

# Cursor
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform cursor --install-to-project

# Cline
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform cline --install-to-project

# Codex CLI (can also use: --platform codex_cli)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform codex --install-to-project

# VS Code
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform vscode --install-to-project
```


- The `--install-to-project` flag installs the entire framework (shared + agent-specific) to your current directory for a self-contained project setup.
- Repeat the `--platform` flag or swap in `--platform all` to install multiple targets in one pass.
- Additional arguments (e.g., `--profile nextjs`, `--dry-run`, `--force`) pass straight through after the `--` separator.
- To install to platform-specific defaults instead (e.g., `~/.factory`, `~/.claude`), remove `--install-to-project` and add `--use-platform-defaults`.
- Verbose progress + a completion summary are enabled by default; add `--quiet` after `--` to suppress them.

### What Gets Installed

After installation, you'll have:

**For Factory AI:**
- `~/.factory/droids/` - 8 custom droids (implementer, spec-writer, product-planner, etc.)
- `~/.factory/commands/` - 20+ slash commands for workflows
- `~/droidz/standards/` - Shared coding standards organized by domain

**For Claude Code:**
- `~/.claude/agents/` - 8 subagents for specialized tasks
- `~/.claude/commands/` - 20+ slash commands
- `~/droidz/standards/` - Shared standards (global, backend, frontend, testing)

**For Other Platforms:**
- Platform-specific directory with agents/commands
- `~/droidz/standards/` - Shared standards library

## Platform Reference
| Platform | Install Location | Content |
|----------|-----------------|---------|
| Claude Code | `~/.claude/` | 8 agents, 20+ commands in flat structure |
| Factory AI | `~/.factory/` | 8 droids (`.factory/droids/`), 20+ commands (`.factory/commands/`) |
| Cursor | `~/Library/Application Support/Cursor/droidz/` | Workflow cards and standards |
| Cline | `~/.cline/` | Prompt packs for spec-first execution |
| Codex CLI | `~/.codex/` | Sequential playbooks for spec-first flow |
| VS Code | `~/Library/Application Support/Code/User/droidz/` | Snippets and task recipes |
| **Shared** | `~/droidz/standards/` | Global, backend, frontend, testing standards |

Every payload ships instructions only—no remote downloads, external URLs, or opaque binaries. Duplicate any payload folder to author your own variants and point the installer to them via `--payload-source`.

## Tool-Agnostic Subagent Guidance
- Prompts and command briefs only refer to “sub agents” generically; whichever IDE or CLI you install handles how many assistants can run at once.
- When a host supports multiple concurrent agents (e.g., orchestrator + specialists), follow the same instructions; tools that lack that feature simply execute the listed tasks one at a time without violating the script.
- Codex CLI and other single-agent runtimes still honor the same prompts—they execute every subtask sequentially while preserving the Validation Gate requirements.

## Custom Profiles
1. Copy an existing profile folder, e.g. `cp -R droidz_installer/payloads/claude/default droidz_installer/payloads/claude/nextjs`.
2. Update the files inside with your custom standards and prompts.
3. Run `python install.py --platform claude --profile nextjs`.
4. The installer attempts profile-specific payloads first, then falls back to the default profile when none exist.

## Validation Gate (Mandatory)
All payloads instruct their host tools to run the same gate:
```bash
ruff check .
pytest
```
Never summarize work or claim success before both commands pass. Tests rely on this gate as well.

## Troubleshooting
- **Existing instructions were replaced** – re-run the installer without `--force`; it creates timestamped backups (e.g., `.factory.backup-20251122-153000`).
- **Need a dry preview** – add `--dry-run` to inspect planned destinations and payloads.
- **Different install locations per platform** – run the installer separately, passing `--destination` each time for agent-specific content.
- **Add another IDE** – update `droidz_installer/manifests/platforms.json` with a new entry and create a payload folder under `droidz_installer/payloads/<platform>/default/`.

## Developing the Installer
```bash
pip install -e .
ruff check .
pytest
```
Tests mock filesystem operations to guarantee backups, dry-runs, and copy plans behave consistently.
