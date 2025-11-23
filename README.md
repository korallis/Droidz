# 🤖 Droidz Framework

A complete spec-driven development framework for AI coding agents. Get 8 specialized agents, 20+ workflow commands, and comprehensive coding standards—all installed with one command.

## What You Get

- **8 Specialized Agents/Droids** – implementer, spec-writer, product-planner, spec-verifier, and more
- **20+ Workflow Commands** – plan-product, shape-spec, implement-tasks, create-tasks, orchestrate-tasks
- **Comprehensive Standards** – organized by domain (global, backend, frontend, testing)
- **Safe Updates** – preserves your custom standards and specs during framework upgrades
- **Multi-Platform** – works with Factory AI, Claude Code, Cursor, Cline, Codex CLI, and VS Code

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
We're deeply thankful for the generosity of friends who keep this instruction stack alive:

- **Sorennza**
- **Ray Fernando**
- **Douwe de Vries**

Every contribution—large or small—directly fuels new payloads, validation helpers, and continued open distribution. Thank you for believing in Droidz.

---

## Installation

**Important:** Navigate to your project directory first!

```bash
cd /path/to/your/project
```

Then run one of these commands:

**Recommended (most reliable):**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh)
```

**Alternative (if above doesn't work):**
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/install.sh | bash
```

### How It Works

The installer installs everything to your **current project directory** in a **namespaced structure** (just like agent-os):

**Factory AI:**
- `./.factory/droids/droidz/` - Custom droids (namespaced)
- `./.factory/commands/droidz/` - Slash commands (namespaced)

**Claude Code:**
- `./.claude/agents/droidz/` - Subagents (namespaced)
- `./.claude/commands/droidz/` - Slash commands (namespaced)

**Cursor:**
- `./.cursor/workflows/droidz/` - Workflows (namespaced)

**Cline:**
- `./.cline/prompts/droidz/` - Custom prompts (namespaced)

**Codex CLI:**
- `./.codex/playbooks/droidz/` - Playbooks (namespaced)

**VS Code:**
- `./.vscode/droidz/snippets/droidz/` - Code snippets (namespaced)

**All platforms also install:**
- `./droidz/standards/` - Shared coding standards (backend, frontend, testing, global)

The namespaced structure prevents conflicts with other tools and keeps everything organized!

Everything is **checked into git** and **shared with your team**.

The installer will:
1. Show you a menu with all supported platforms
2. Let you select your AI tool (Claude Code, Factory AI, Cursor, Cline, Codex CLI, or VS Code)
3. Install everything to the correct location
4. Preserve your existing customizations if updating

That's it! No arguments, no complex flags, just one command.

## What Gets Installed

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

## Framework Overview

### Agents/Droids

Each agent is a specialized AI assistant for specific tasks:

- **implementer** - Implements features by following task lists and specs
- **spec-writer** - Creates detailed specifications from requirements
- **spec-shaper** - Researches and shapes specifications with requirements
- **spec-verifier** - Reviews and validates specifications
- **spec-initializer** - Creates initial spec folder structure
- **product-planner** - Creates product documentation, mission, and roadmap
- **tasks-list-creator** - Breaks down specs into actionable task lists
- **implementation-verifier** - Verifies implementations and runs tests

### Commands

Workflow commands for common development tasks:

- **plan-product** - Create product mission, roadmap, and tech stack
- **shape-spec** - Initialize and research a specification
- **write-spec** - Write a complete specification
- **create-tasks** - Generate task lists from specs
- **implement-tasks** - Implement features from task lists
- **orchestrate-tasks** - Coordinate multi-agent task execution
- **improve-skills** - Enhance and customize agent skills

### Standards

Comprehensive coding standards organized by domain:

**Global Standards:**
- Coding style and conventions
- Error handling patterns
- Code commenting guidelines
- Tech stack documentation
- Validation requirements

**Backend Standards:**
- API design patterns
- Database models and migrations
- Query optimization
- Data layer best practices

**Frontend Standards:**
- Component architecture
- CSS organization
- Responsive design
- Accessibility requirements

**Testing Standards:**
- Test writing guidelines
- Coverage requirements
- Testing patterns

## Using the Framework

### For Factory AI

After installation:
1. Restart your droid session
2. Run `/droids` to see available custom droids
3. Run `/commands` to see available slash commands

Example usage:
```
> Use the spec-writer droid to create a spec for user authentication
> /plan-product to start product planning
> /implement-tasks for the login feature
```

### For Claude Code

After installation:
1. Restart Claude Code
2. Run `/agents` to see available subagents
3. Run `/commands` to see available slash commands

Example usage:
```
> Use the implementer agent to build the authentication module
> /shape-spec to research and plan a new feature
> /create-tasks for the user profile spec
```

## Customization

**Modify Standards:** Edit files in `~/droidz/standards/` to match your team's coding conventions. The installer preserves your modifications during updates.

**Create Custom Droids/Agents:** Add your own `.md` files to the platform-specific directories:
- Factory: `~/.factory/droids/`
- Claude: `~/.claude/agents/`

**Create Custom Commands:** Add command files to:
- Factory: `~/.factory/commands/`
- Claude: `~/.claude/commands/`

**Customize Product Docs:** Add your product documentation:
- `~/droidz/product/mission.md` - Product vision and strategy
- `~/droidz/product/roadmap.md` - Development roadmap
- `~/droidz/product/tech-stack.md` - Technology choices

**Create Specs:** Store your specifications:
- `~/droidz/specs/[spec-name]/spec.md` - Main specification
- `~/droidz/specs/[spec-name]/tasks.md` - Task breakdown
- `~/droidz/specs/[spec-name]/planning/` - Requirements and research

## Workflow Example

Here's how to use Droidz for a complete feature development cycle:

1. **Plan the Product** (if starting new)
   ```
   /plan-product
   ```
   Creates mission, roadmap, and tech stack documentation.

2. **Shape the Specification**
   ```
   /shape-spec
   ```
   Initializes spec folder and researches requirements.

3. **Write the Specification**
   ```
   /write-spec
   ```
   Creates a detailed, implementable specification.

4. **Create Task List**
   ```
   /create-tasks
   ```
   Breaks down the spec into concrete implementation tasks.

5. **Implement the Feature**
   ```
   /implement-tasks
   ```
   Implements the tasks, following the spec and standards.

6. **Verify Implementation**
   The implementation-verifier agent runs tests and creates verification reports.

## Troubleshooting

**Want to reinstall?** Just run the installer again. It will detect the existing installation and offer to update while preserving your data.

**Lost your customizations?** The installer backs up to a temp directory during updates. Check `/tmp/` for recent backup folders.

**Commands not working?** Make sure you've restarted your AI tool after installation. Run `/droids` or `/agents` to verify installation.

**Need support?** Open an issue on [GitHub](https://github.com/korallis/Droidz/issues) or join the Discord community.

## Development

For contributors working on the installer or framework:

```bash
# Clone the repository
git clone https://github.com/korallis/Droidz.git
cd Droidz

# Test the installer locally
bash install.sh

# Framework files are in
# - droidz_installer/payloads/droid_cli/default/ (Factory AI)
# - droidz_installer/payloads/claude/default/ (Claude Code)
# - droidz_installer/payloads/shared/default/ (Shared standards)
```

### Project Structure

```
Droidz/
├── install.sh                    # Interactive bash installer
├── droidz_installer/
│   ├── payloads/
│   │   ├── droid_cli/default/   # Factory AI content
│   │   │   ├── droids/          # Agent definitions
│   │   │   └── commands/        # Slash commands
│   │   ├── claude/default/      # Claude Code content
│   │   │   ├── agents/          # Subagent definitions
│   │   │   └── commands/        # Slash commands
│   │   └── shared/default/      # Shared standards
│   │       ├── global/
│   │       ├── backend/
│   │       ├── frontend/
│   │       └── testing/
│   └── manifests/
│       └── platforms.json       # Platform configurations
└── README.md
```

## License

MIT License - see LICENSE file for details

## Credits

Created by the Droidz community with special thanks to Ray Fernando and all our supporters.

Built on the foundation of spec-driven development principles, adapted for modern AI coding agents.
