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
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform claude

# Factory.ai Droid CLI (can also use: --platform droid_cli)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform factory

# Cursor
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform cursor

# Cline
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform cline

# Codex CLI (can also use: --platform codex_cli)
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform codex

# VS Code
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/bootstrap.sh | bash -s -- --platform vscode
```


- Repeat the `--platform` flag or swap in `--platform all` to install multiple targets in one pass.
- Additional arguments (e.g., `--profile nextjs`, `--dry-run`, `--destination "$PWD"`) pass straight through after the `--` separator.
- By default, agent-specific instructions land in your current directory, while the shared framework installs to `~/.droidz`. Add `--use-platform-defaults` to install agent-specific content to platform defaults (e.g., `~/.factory`, `~/.claude`).
- Verbose progress + a completion summary are enabled by default; add `--quiet` after `--` to suppress them.
- After the script completes, you'll have both shared framework standards in `~/.droidz` and agent-specific content in your chosen location.

### Common Flags
| Flag | Purpose |
|------|---------|
| `--profile <name>` | Loads alternative payload variants (defaults to `default`). |
| `--destination <path>` | Overrides agent-specific install location (defaults to current directory). Shared framework always installs to `~/.droidz`. |
| `--use-platform-defaults` | Install agent-specific content into platform defaults (e.g., `~/.factory`, `~/.claude`). |
| `--dry-run` | Prints the copy plan without touching disk. |
| `--force` | Replaces existing destination folders instead of backing them up. |
| `--quiet` | Suppresses verbose progress + completion summaries (default is verbose). |
| `--payload-source <dir>` | Points to custom payloads you have authored. |

## Platform Reference
| Platform | Agent-Specific Target | Shared Framework | Payload Contents |
|----------|----------------------|------------------|------------------|
| Claude Code | Current directory (or `~/.claude` with `--use-platform-defaults`) | `~/.droidz` | Commands, agents, Claude-specific standards. |
| Factory/Droid CLI | Current directory (or `~/.factory` with `--use-platform-defaults`) | `~/.droidz` | Factory command prompts, specialist agents, CLI standards. |
| Cursor | Current directory (or `~/Library/Application Support/Cursor/droidz` with `--use-platform-defaults`) | `~/.droidz` | Workflow cards and standards. |
| Cline | Current directory (or `~/.cline` with `--use-platform-defaults`) | `~/.droidz` | Prompt packs for spec-first execution. |
| Codex CLI | Current directory (or `~/.codex` with `--use-platform-defaults`) | `~/.droidz` | Sequential playbooks for spec-first flow. |
| VS Code | Current directory (or `~/Library/Application Support/Code/User/droidz` with `--use-platform-defaults`) | `~/.droidz` | Snippets and task recipes. |

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
