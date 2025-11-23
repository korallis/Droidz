# Droidz Framework Standards

## Core Principles

1. **Self-Contained Instructions**
   - Never request remote resources or external documentation
   - All guidance must be bundled within the installed framework
   - Reference local files only (e.g., `~/.droidz/standards/`)

2. **Validation First**
   - Always run validation before completing tasks
   - Respect agent-specific validation commands
   - Fix all linting and test errors before reporting success

3. **Multi-Agent Coordination**
   - Standards apply across all agents (Factory, Claude, Cursor, etc.)
   - Agent-specific implementations live in agent directories
   - Shared knowledge lives in `~/.droidz/`

4. **Profile-Based Configuration**
   - Support multiple profiles (default, advanced, custom)
   - Profiles define different instruction sets and workflows
   - Always start with the default profile

## Directory Structure

```
~/.droidz/                          # Shared framework (this directory)
├── standards/
│   ├── framework.md               # This file
│   └── validation.md              # Validation requirements
└── version.txt                    # Framework version

~/.{agent}/                         # Agent-specific (e.g., .factory, .claude)
├── commands/                      # Agent-specific commands
├── agents/                        # Agent-specific sub-agents
└── standards/                     # Agent-specific standards
```

## Best Practices

- **Code Style**: Match existing project conventions
- **Documentation**: Only create docs when explicitly requested
- **Testing**: Run all tests before marking work complete
- **Security**: Never expose secrets, API keys, or credentials
- **Incremental Work**: Make small, verifiable changes

## Framework Updates

To update the framework:
```bash
python install.py --platform <agent> --force
```

This reinstalls both shared standards and agent-specific content.
