# 🤖 Droidz

> **Intelligent AI development framework for Factory.ai Droid CLI**

Droidz supercharges Factory.ai's Droid CLI with specialist agents, parallel execution, persistent memory, and intelligent automation for complex software projects.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.3.1--droid-blue.svg)](https://github.com/korallis/Droidz)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=flat&logo=discord&logoColor=white)](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)
[![Donate](https://img.shields.io/badge/PayPal-Donate-00457C?style=flat&logo=paypal&logoColor=white)](https://www.paypal.com/paypalme/gideonapp)

---

## 💬 Join Our Discord Community

**Built specifically for Ray Fernando's Discord members!** 🎯

Join our exclusive community to get early access, share tips, connect with contributors, get priority support, and influence future development.

**[→ Join Discord Community](https://polar.sh/checkout/polar_c_Pse3hFdgwFUqomhsOL8wIN5ETXT6UsxNWTvx11BdyFW)**

---

## 💝 Support This Project

If Droidz saves you time and improves your workflow, consider supporting its development!

**[→ Donate via PayPal](https://www.paypal.com/paypalme/gideonapp)** (@gideonapp)

Your support helps maintain and improve this framework for the entire community! 🙏

---

## What is Droidz?

Droidz is a framework that extends Factory.ai's Droid CLI with:

- **Specialist Agents** - Domain-specific droids (codegen, test, refactor, infra, integration)
- **Parallel Execution** - Run multiple agents simultaneously for 3-5x faster development
- **Active Monitoring** - Real-time progress updates every 60-90 seconds during parallel execution
- **Persistent Memory** - Save architectural decisions, patterns, and context across sessions
- **Smart Skills** - Auto-orchestrator, spec-shaper, memory-manager, and more
- **Standards Enforcement** - Automatic code quality checks and fixes

---

## Quick Start

### Installation

Install Droidz in any project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/korallis/Droidz/main/install.sh
chmod +x install.sh
./install.sh
```

### Setup

1. **Enable Custom Droids and Hooks in Factory.ai:**
   ```bash
   droid
   /settings
   # Toggle "Custom Droids" ON
   # Toggle "Hooks" ON
   ```

2. **Restart Droid CLI:**
   ```bash
   # Exit (Ctrl+C) then restart
   droid
   ```

3. **Verify Installation:**
   ```bash
   /droids
   # Should show: droidz-orchestrator, droidz-codegen, droidz-test, etc.
   ```

4. **Optional - Configure Linear Integration:**
   Edit `config.yml`:
   ```yaml
   linear:
     project_name: "YourProjectName"
   ```

---

## Usage

### Basic Usage

Use the orchestrator for complex tasks:

```bash
droid
> Build an authentication system with JWT tokens
```

The orchestrator will automatically:
- Analyze task complexity
- Break work into parallel streams
- Spawn specialist agents (backend, frontend, tests)
- Monitor progress every 60-90 seconds
- Synthesize results when complete

### Available Commands

| Command | Description |
|---------|-------------|
| `/orchestrate` | Manually trigger parallel orchestration |
| `/spec-shaper` | Create structured specifications for features |
| `/analyze-tech-stack` | Analyze your project's technology stack |
| `/save-decision` | Save architectural decisions to memory |
| `/load-memory` | Load saved decisions and patterns |
| `/graphite` | Manage stacked diffs workflow (if using Graphite) |
| `/commands` | See all available commands |

### Specialist Droids

| Droid | Purpose | Auto-triggers on |
|-------|---------|-----------------|
| **droidz-orchestrator** | Coordinate parallel work | "build [system]", "implement [feature]" |
| **droidz-codegen** | Write features & bugfixes | Feature implementation requests |
| **droidz-test** | Write & fix tests | "write tests", test failures |
| **droidz-refactor** | Code refactoring | "refactor", code cleanup |
| **droidz-infra** | CI/CD & deployment | "setup CI", Docker, GitHub Actions |
| **droidz-integration** | External APIs | "integrate [service]", webhooks |
| **droidz-generalist** | General tasks | Unclear or multi-domain work |

---

## Key Features

### 1. Parallel Execution

Complex tasks are automatically split into parallel work streams:

```
Sequential: 60-80 minutes
Parallel:   20-30 minutes (3x faster!)
```

The orchestrator monitors progress every 60-90 seconds by checking:
- Git status for new/modified files
- File timestamps
- TypeScript compilation status

### 2. Persistent Memory

Save important context that persists across sessions:

- **Architectural Decisions** - Why you chose certain patterns
- **Pattern Library** - Reusable code patterns for your project
- **Tech Stack Context** - Framework versions, conventions, setup

```bash
/save-decision
# Saves current context to .factory/memory/org/

/load-memory
# Loads saved context for current session
```

### 3. Spec-Driven Development

Create structured specifications before building:

```bash
/spec-shaper
# Interactive spec creation with:
# - User stories
# - Technical requirements
# - API contracts
# - Success criteria
```

Specs are saved to `.factory/specs/active/` and can be converted to executable tasks.

### 4. Standards Enforcement

Automatic code quality checks based on your tech stack:

```bash
/check-standards
# Analyzes code against:
# - TypeScript best practices
# - React patterns
# - Next.js conventions
# - Security requirements
```

---

## Configuration

### Minimal Setup

Create `config.yml` (optional):

```yaml
# Linear Integration (optional)
linear:
  project_name: "MyProject"

# Orchestrator Settings (optional)
orchestrator:
  max_parallel_streams: 5
  enable_monitoring: true
  monitoring_interval: 90
```

If `config.yml` doesn't exist, Droidz uses sensible defaults.

---

## Project Structure

After installation, your project will have:

```
.factory/
├── droids/              # Specialist agent definitions
│   ├── droidz-orchestrator.md
│   ├── droidz-codegen.md
│   ├── droidz-test.md
│   └── ...
├── commands/            # Custom slash commands
│   ├── orchestrate.md
│   ├── spec-shaper.md
│   └── ...
├── skills/              # Auto-activated skills
│   ├── auto-orchestrator/
│   ├── memory-manager/
│   └── ...
├── memory/              # Persistent context
│   ├── org/            # Organization-wide decisions
│   └── user/           # User-specific notes
├── specs/               # Feature specifications
│   ├── active/         # Current specs
│   ├── archive/        # Completed specs
│   └── templates/      # Spec templates
└── standards/           # Code quality standards
    └── templates/
        ├── typescript.md
        ├── react.md
        └── ...

config.yml               # Your configuration (gitignored)
config.example.yml       # Template configuration
```

**Note:** `.factory/` and `.droidz/` are automatically added to `.gitignore` to keep user-specific data local.

---

## Examples

### Example 1: Build Authentication System

```bash
droid
> Build a complete authentication system with JWT tokens

# Orchestrator automatically:
# 1. Analyzes complexity (3 parallel streams detected)
# 2. Spawns agents:
#    - droidz-codegen: Backend API (register, login, tokens)
#    - droidz-codegen: Frontend forms (LoginForm, RegisterForm)
#    - droidz-test: Write tests for auth flow
# 3. Monitors progress every 90 seconds:
#    "⏱️ Update (90s): Agent 1 created 4 files, Agents 2-3 still working..."
# 4. Synthesizes results when complete
```

### Example 2: Refactor Module

```bash
droid
> Refactor the payment module to use strategy pattern

# Auto-triggers droidz-refactor:
# - Analyzes current code structure
# - Plans refactoring steps
# - Implements changes incrementally
# - Ensures no behavior changes
# - Runs tests to verify
```

### Example 3: Create Spec First

```bash
droid
/spec-shaper

# Interactive prompts:
# - What feature are you building?
# - Who are the users?
# - What are the success criteria?
# - What's the technical approach?

# Saves structured spec to .factory/specs/active/001-feature-name.md

# Then:
droid
> Implement the spec at .factory/specs/active/001-feature-name.md

# Orchestrator reads spec and executes
```

---

## Troubleshooting

### Droids Not Showing Up

```bash
# 1. Verify custom droids enabled
droid
/settings
# Ensure "Custom Droids" is ON

# 2. Restart Droid CLI
# Exit and run `droid` again

# 3. Check droid list
/droids
```

### Installation Issues

```bash
# View installation logs
cat .droidz-install-*.log

# Re-run installer
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### Orchestrator Not Auto-Triggering

The orchestrator auto-triggers when you say:
- "build [feature/system]"
- "implement [complex feature]"
- "create [application]"
- "add [feature touching 5+ files]"

For manual triggering:
```bash
/orchestrate
```

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `bun test` (if available)
5. Submit a pull request

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

**Current Version:** 2.2.7-droid

**Recent Updates:**
- Active monitoring for parallel agents (60-90 second progress updates)
- Clean UX improvements (removed verbose Execute commands)
- Fixed installer to only download existing files
- Added .droidz/ and .factory/ to .gitignore
- Improved error handling and logging

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Support

- **Issues:** [GitHub Issues](https://github.com/korallis/Droidz/issues)
- **Discussions:** [GitHub Discussions](https://github.com/korallis/Droidz/discussions)
- **Donate:** [PayPal @gideonapp](https://www.paypal.com/paypalme/gideonapp)

---

**Built for Factory.ai Droid CLI** | **Created by the community, for the community** 🚀
