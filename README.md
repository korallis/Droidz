# 🤖 Droidz Instruction Platform

Slim, instruction-only distribution of the Droidz workflow. A single Python installer copies curated command, agent, and prompt bundles straight into the folders expected by your favorite AI coding surfaces (Claude Code, Droid CLI, Cursor, Cline, Codex CLI, and VS Code) so `/commands` and agents are immediately usable.

## What You Get
- `install.py` – zero-interaction CLI that maps payload bundles to each platform’s required directories.
- `droidz_installer/` – manifest-driven engine plus payloads containing the actual instructions.
- `instructions/overview.md` – canonical operating guide mirrored inside every payload.
- `tests/` – pytest coverage for manifest parsing, dry-run safety, and filesystem handling.
- `pyproject.toml` – lightweight toolchain with Ruff + pytest ready to run the Validation Gate.

## Quick Start
1. Ensure Python 3.11+ is available.
2. Clone this repository and stay at the root.
3. Preview targets:
   ```bash
   python install.py --list-platforms
   ```
4. Install for one or more platforms:
   ```bash
   python install.py --platform claude --platform droid_cli --verbose
   ```
5. Or install everything at once:
   ```bash
   python install.py --platform all
   ```
6. Inside each tool, point to the new `droidz` folder (e.g., `~/.claude/droidz/commands`).

### Common Flags
| Flag | Purpose |
|------|---------|
| `--profile <name>` | Loads alternative payload variants (defaults to `default`). |
| `--destination <path>` | Overrides the default root folder for every selected platform. |
| `--dry-run` | Prints the copy plan without touching disk. |
| `--force` | Replaces existing destination folders instead of backing them up. |
| `--payload-source <dir>` | Points to custom payloads you have authored. |

## Platform Reference
| Platform | Default Target | Payload Contents |
|----------|----------------|------------------|
| Claude Code | `~/.claude/droidz` | `/build`, `/parallel`, orchestrator agent briefs, Claude-specific standards. |
| Droid CLI | `~/.factory/droidz` | Factory command prompts, specialist briefs, CLI standards. |
| Cursor | `~/Library/Application Support/Cursor/droidz` | Workflow cards that instruct Cursor to follow the Validation Gate. |
| Cline | `~/.cline/droidz` | Prompt packs guiding Cline through spec-first execution. |
| Codex CLI | `~/.codex/droidz` | Sequential playbooks mirroring Agent OS behavior. |
| VS Code | `~/Library/Application Support/Code/User/droidz` | Snippets and task recipes for validation-first development. |

Every payload ships instructions only—no remote downloads, external URLs, or opaque binaries. Duplicate any payload folder to author your own variants and point the installer to them via `--payload-source`.

## Custom Profiles
1. Copy an existing payload folder, e.g. `cp -R droidz_installer/payloads/claude droidz_installer/payloads/claude/nextjs`.
2. Update the files inside with your custom standards and prompts.
3. Run `python install.py --platform claude --profile nextjs`.
4. The installer attempts profile-specific payloads first, then falls back to the base folder when none exist.

## Validation Gate (Mandatory)
All payloads instruct their host tools to run the same gate:
```bash
ruff check .
pytest
```
Never summarize work or claim success before both commands pass. Tests rely on this gate as well.

## Troubleshooting
- **Existing instructions were replaced** – re-run the installer without `--force`; it creates timestamped backups such as `droidz.backup-20251122-153000`.
- **Need a dry preview** – add `--dry-run` to inspect planned destinations and payloads.
- **Different install roots per platform** – run the installer separately, passing `--destination` each time.
- **Add another IDE** – update `droidz_installer/manifests/platforms.yml` with a new entry and drop a payload folder with the same name.

## Developing the Installer
```bash
pip install -e .
ruff check .
pytest
```
Tests mock filesystem operations to guarantee backups, dry-runs, and copy plans behave consistently.

## 💬 Join Our Discord Community

**Built specifically for Ray Fernando's Discord members!** 🎯

Get early access, share tips, connect with contributors, and influence future development.

**[→ Join Discord Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

---

## 💝 Support This Project

If Droidz saves you time, consider supporting its development!

**[→ Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

Your support helps maintain and improve this framework! 🙏
