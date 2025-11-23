# Droidz Framework Architecture Redesign

## Problem Statement
Current installer installs everything into a single agent-specific subfolder (e.g., `~/.claude/droidz`). This doesn't reflect the multi-layered nature of the framework where:
- Some components are **shared** across all agents (standards, core configs)
- Some components are **agent-specific** (commands, agents)

## Proposed Architecture

### Directory Structure After Installation

When installing for a specific agent (e.g., `factory`):

```
~/.droidz/                          # Shared framework (platform-agnostic)
├── standards/
│   ├── coding-standards.md
│   ├── validation-requirements.md
│   └── best-practices.md
├── shared/
│   └── common-utils.md
└── framework-version.txt

~/.factory/                         # Agent-specific (Factory AI)
├── commands/
│   ├── droidz-plan.md
│   ├── droidz-build.md
│   └── droidz-test.md
├── agents/
│   ├── orchestrator.md
│   ├── codegen.md
│   └── reviewer.md
└── agent-config.json

~/.claude/                          # Agent-specific (Claude Code)
├── commands/
│   ├── /plan
│   ├── /build
│   └── /review
├── agents/
│   ├── orchestrator.md
│   └── specialist.md
└── agent-config.json
```

### Payload Structure Reorganization

```
droidz_installer/payloads/
├── shared/                         # Platform-agnostic content
│   ├── default/                    # Default profile
│   │   ├── standards/
│   │   │   ├── coding-standards.md
│   │   │   └── validation.md
│   │   └── framework-version.txt
│   └── advanced/                   # Advanced profile
│       └── standards/
│           └── ...
│
├── factory/                        # Factory.ai specific
│   ├── default/
│   │   ├── commands/
│   │   │   ├── droidz-plan.md
│   │   │   └── droidz-build.md
│   │   └── agents/
│   │       ├── orchestrator.md
│   │       └── codegen.md
│   └── advanced/
│       └── ...
│
├── claude/                         # Claude Code specific
│   ├── default/
│   │   ├── commands/
│   │   │   └── plan.md
│   │   └── agents/
│   │       └── orchestrator.md
│   └── advanced/
│       └── ...
│
└── cursor/                         # Cursor specific
    ├── default/
    │   └── workflows/
    │       └── accelerator.md
    └── advanced/
        └── ...
```

## Manifest Changes

The `platforms.json` needs to support **multiple installation targets**:

```json
{
  "platforms": {
    "factory": {
      "label": "Factory AI",
      "description": "Factory.ai CLI commands and agents",
      "agent_path": "~/.factory",
      "shared_path": "~/.droidz",
      "payload": "factory",
      "install_targets": [
        {
          "type": "shared",
          "source": "shared",
          "destination": "~/.droidz",
          "description": "Shared framework standards"
        },
        {
          "type": "agent",
          "source": "factory",
          "destination": "~/.factory",
          "description": "Factory-specific commands and agents",
          "chmod": ["commands/*"]
        }
      ]
    },
    "claude": {
      "label": "Claude Code",
      "description": "Claude desktop commands, agents, standards",
      "agent_path": "~/.claude",
      "shared_path": "~/.droidz",
      "payload": "claude",
      "install_targets": [
        {
          "type": "shared",
          "source": "shared",
          "destination": "~/.droidz",
          "description": "Shared framework standards"
        },
        {
          "type": "agent",
          "source": "claude",
          "destination": "~/.claude",
          "description": "Claude-specific commands and agents",
          "chmod": ["commands/*"]
        }
      ]
    }
  }
}
```

## Installer Logic Changes

### Core Installation Flow

1. **User runs:** `python install.py --platform factory`
2. **Installer:**
   - Reads manifest for "factory" platform
   - Identifies 2 install targets:
     - **Shared**: `payloads/shared/default/` → `~/.droidz/`
     - **Agent**: `payloads/factory/default/` → `~/.factory/`
   - Backs up existing directories if they exist
   - Copies both targets
   - Sets permissions (chmod) as specified

### Key Updates Needed

#### 1. `core.py` - InstallResult and PlatformSpec
```python
@dataclass
class InstallTarget:
    type: str  # "shared" or "agent"
    source: str  # payload subdirectory
    destination: str  # installation path
    description: str
    chmod: List[str]

@dataclass
class PlatformSpec:
    name: str
    label: str
    description: str
    agent_path: str  # Agent-specific path
    shared_path: str  # Shared framework path
    payload: str
    install_targets: List[InstallTarget]
```

#### 2. Installation Loop
```python
for target in spec.install_targets:
    # Resolve source payload
    payload_dir = resolve_payload_dir(
        options.payload_source,
        target.source,
        options.profile
    )
    
    # Resolve destination
    destination = fs.expand_path(target.destination)
    
    # Install
    backup = fs.prepare_destination(destination, force, dry_run)
    fs.copy_tree(payload_dir, destination, dry_run)
    
    if target.chmod:
        fs.chmod_targets(destination, target.chmod, dry_run)
```

## CLI Changes

### New Options
```bash
# Install for specific agent (installs shared + agent-specific)
python install.py --platform factory

# Install for multiple agents
python install.py --platform factory --platform claude

# Install all agents
python install.py --platform all

# List available agents
python install.py --list-platforms

# Install with custom profile
python install.py --platform factory --profile advanced
```

## Migration Path

### For Existing Users
1. Run new installer
2. Old `~/.factory/droidz/` content moves to:
   - Standards → `~/.droidz/standards/`
   - Commands → `~/.factory/commands/`
   - Agents → `~/.factory/agents/`

### Backward Compatibility
- Installer checks for old structure
- Offers to migrate automatically
- Creates backup before migration

## Benefits

1. **Clear Separation**: Shared vs agent-specific content is obvious
2. **DRY Principle**: Standards only need to be maintained once
3. **Multi-Agent Support**: Install for multiple agents without duplication
4. **Scalability**: Easy to add new agents without copying shared content
5. **Clarity**: Users understand where to look for different types of content

## Implementation Checklist

- [ ] Create new payload structure (`shared/`, restructured agent folders)
- [ ] Update `platforms.json` manifest with `install_targets`
- [ ] Modify `PlatformSpec` dataclass for multi-target support
- [ ] Update `install()` function to loop through targets
- [ ] Add migration logic for existing installations
- [ ] Update CLI help text and examples
- [ ] Add validation for new structure
- [ ] Write tests for multi-target installation
- [ ] Update README with new architecture
- [ ] Update bootstrap script

## Example Usage

```bash
# Install full framework for Factory AI
$ python install.py --platform factory

# Output:
# Installing Factory AI (shared framework + agent-specific)
#   [1/2] Shared Framework → ~/.droidz/
#     Using payload: .../payloads/shared/default/
#     ✓ Installed standards, configs
#   [2/2] Factory Agent → ~/.factory/
#     Using payload: .../payloads/factory/default/
#     ✓ Installed commands, agents
# Installation complete!

# Install for multiple agents
$ python install.py --platform factory --platform claude

# Output:
#   [1/3] Shared Framework → ~/.droidz/
#   [2/3] Factory Agent → ~/.factory/
#   [3/3] Claude Agent → ~/.claude/
```
