# Droidz v4.0 Python Installer Guide

## 🎯 Overview

The new Python-based installer replaces the bash installer with a robust, interactive installation experience.

## ✨ Features

- ✅ Interactive TUI with component selection
- ✅ Smart platform detection (Claude Code, Codex CLI, Droid CLI)
- ✅ Dependency checking and validation
- ✅ Automatic component conversion for Codex CLI
- ✅ Cross-platform support (macOS, Linux, WSL2)
- ✅ No more bash parsing errors!

## 📦 Installation

### Prerequisites

- **Python 3.7+** (3.9+ recommended)
- **pip** or **pipx**

### Quick Install

```bash
# Clone or download Droidz
git clone https://github.com/korallis/Droidz.git
cd Droidz

# Install dependencies (one-time)
pip install --user inquirer rich click pyyaml requests

# Or use pipx (recommended)
pipx install --pip-args="-r requirements.txt" .

# Run installer
python3 install.py
```

### Direct Install (from GitHub)

```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/v4.0.0/install.py | python3
```

## 🎮 Usage

### Interactive Mode (Recommended)

```bash
python3 install.py
```

This launches the interactive TUI where you can:
1. See detected platforms
2. Select target platform (Claude Code, Codex CLI, Droid CLI, or All)
3. Choose components to install
4. Review installation plan
5. Confirm and install

### Command Line Mode

```bash
# Install for specific platform
python3 install.py --platform codex-cli

# Install with specific components
python3 install.py --platform codex-cli --components commands,agents

# Install everything
python3 install.py --platform all --all-components

# Dry run (see what would be installed)
python3 install.py --dry-run
```

## 📋 Installation Flow

```
┌─────────────────────────────────────┐
│  Droidz v4.0 Installer              │
└─────────────────────────────────────┘

🔍 Detecting environment...
  ✓ OS: macOS 15.1
  ✓ Shell: zsh
  ✓ Python: 3.14.0
  ✓ Node.js: v20.10.0
  ✓ Codex CLI: installed (v0.63.0)
  ✓ Claude Code: not found
  ✓ Droid CLI: installed (v0.26.0)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

? Select installation target:
  › Claude Code
    Codex CLI (installed ✓)
    Droid CLI (installed ✓)
    All platforms

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

? Select components:
  ◉ ✅ Core Commands (5) - Compatible
  ◉ ✅ Specialist Agents (15) - Will convert
  ◯ ⚠️  Skills (60+) - Embed in AGENTS.md
  ◉ ✅ Validation Pipeline - Will adapt
  ◉ ✅ Specs System - Fully compatible

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Installation Plan

Target: Codex CLI
Components: 4 groups

  Commands: 5
    • /build
    • /validate
    • /validate-init
    • /parallel
    • /init

  Agents: 15
    • Orchestrator
    • Code Generator
    • Test Specialist
    ...

? Proceed with installation? Yes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Installing for Codex CLI...

  ✓ Created ~/.codex/prompts/
  ✓ Converting commands → prompts (5)
  ✓ Converting agents → prompts (15)
  ✓ Created AGENTS.md
  ✓ Created .droidz/specs/

✨ Installation complete!
```

## 🔧 Troubleshooting

### Missing Dependencies

```bash
# Install missing Python packages
pip install --user -r requirements.txt

# Or use system package manager
brew install python-inquirer  # macOS
apt install python3-inquirer  # Ubuntu/Debian
```

### Permission Errors

```bash
# Use --user flag for pip
pip install --user inquirer rich

# Or use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 install.py
```

### Platform Not Detected

The installer detects platforms by checking for CLI commands:
- **Codex CLI**: `codex --version`
- **Claude Code**: `claude --version`
- **Droid CLI**: `factory --version`

If your platform isn't detected, install it first or use `--platform` flag to force installation.

## 📊 Component Compatibility

| Component | Claude Code | Codex CLI | Notes |
|-----------|-------------|-----------|-------|
| Commands (5) | ✅ Full | ⚠️ Adapted | Converts to instructions |
| Agents (15) | ✅ Full | ✅ Full | Maps to prompts |
| Skills (60+) | ✅ Full | ⚠️ Embedded | Goes in AGENTS.md |
| Validation | ✅ Full | ⚠️ Adapted | Descriptive workflow |
| Specs | ✅ Full | ✅ Full | File system, identical |
| Hooks | ✅ Full | ❌ No | Not supported |

## 🚀 Next Steps

After installation:

### For Codex CLI

```bash
# Start Codex
codex

# Try commands
/prompts:build FEATURE="user auth"
/prompts:validate
/prompts:codegen FEATURE="login"
```

### For Claude Code

```bash
# Start Claude Code
claude

# Try commands
/build
/validate
/parallel
```

## 📚 Documentation

- **Codex CLI Guide**: [docs/CODEX_CLI.md](./CODEX_CLI.md)
- **Migration Guide**: [docs/CODEX_MIGRATION.md](./CODEX_MIGRATION.md)
- **Compatibility**: [docs/CODEX_COMPATIBILITY_BREAKDOWN.md](./CODEX_COMPATIBILITY_BREAKDOWN.md)

## 🐛 Reporting Issues

Found a bug? [Open an issue on GitHub](https://github.com/korallis/Droidz/issues)

Include:
- Python version (`python3 --version`)
- OS and platform
- Full error output
- Installation command used
