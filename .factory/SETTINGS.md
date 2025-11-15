# Factory.ai Settings Documentation

The `.factory/settings.json` file configures how droids behave in your project.

## Quick Start

1. Copy the example below to `.factory/settings.json`
2. Customize for your project
3. Restart droid to apply changes

## Complete Example

```json
{
  "hooks": {
    "SessionStart": [
      {
        "name": "load-project-skills",
        "hooks": [
          {
            "type": "command",
            "command": "$FACTORY_PROJECT_DIR/.factory/hooks/load-project-skills.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$FACTORY_PROJECT_DIR/.factory/hooks/inject-file-skills.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Create|Edit|Write",
        "hooks": [
          {
            "name": "auto-lint",
            "type": "command",
            "command": ".factory/hooks/auto-lint.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$FACTORY_PROJECT_DIR/.factory/hooks/inject-skills.sh"
          }
        ]
      }
    ]
  },
  "contextManagement": {
    "autoOptimize": true,
    "optimizationThreshold": 0.70,
    "aggressiveThreshold": 0.90,
    "createCheckpoints": true
  },
  "standards": {
    "enforcement": {
      "security": "block",
      "typescript": "warn",
      "performance": "suggest",
      "style": "auto-fix"
    },
    "autoFix": {
      "enabled": true,
      "requireApproval": false
    }
  },
  "memory": {
    "autoSave": true,
    "saveDecisions": true,
    "savePatterns": true,
    "savePreferences": true
  },
  "enableCustomDroids": true
}
```

## Configuration Options

### Hooks System

Configure lifecycle hooks to inject custom behavior. See [HOOKS.md](./HOOKS.md) for details.

**Available hook types:**
- `SessionStart` - When droid starts
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `UserPromptSubmit` - When user submits message
- `Stop` - When session ends
- `SubagentStop` - When subagent completes
- `Notification` - On specific events

### Context Management

Control how droid manages context window:

```json
{
  "contextManagement": {
    "autoOptimize": true,           // Auto-compress when needed
    "optimizationThreshold": 0.70,  // Trigger at 70% capacity
    "aggressiveThreshold": 0.90,    // Aggressive compression at 90%
    "createCheckpoints": true       // Save context snapshots
  }
}
```

**Options:**
- `autoOptimize` (boolean): Enable automatic context compression
- `optimizationThreshold` (0-1): When to start optimization
- `aggressiveThreshold` (0-1): When to aggressively compress
- `createCheckpoints` (boolean): Save context restore points

### Standards Enforcement

Configure how coding standards are enforced:

```json
{
  "standards": {
    "enforcement": {
      "security": "block",      // Block unsafe operations
      "typescript": "warn",     // Warn about type issues
      "performance": "suggest", // Suggest optimizations
      "style": "auto-fix"       // Automatically fix style
    },
    "autoFix": {
      "enabled": true,          // Enable auto-fixing
      "requireApproval": false  // Fix without asking
    }
  }
}
```

**Enforcement levels:**
- `block` - Prevent operation
- `warn` - Allow with warning
- `suggest` - Provide suggestions
- `auto-fix` - Fix automatically
- `off` - Disable

### Memory Management

Configure persistent memory:

```json
{
  "memory": {
    "autoSave": true,         // Save context automatically
    "saveDecisions": true,    // Remember decisions
    "savePatterns": true,     // Remember code patterns
    "savePreferences": true   // Remember preferences
  }
}
```

### Custom Droids

Enable custom droid (subagent) support:

```json
{
  "enableCustomDroids": true
}
```

Droids defined in `.factory/droids/*.md` become available as subagents.

## Advanced Configuration

### Model Selection

Configure default model and reasoning:

```json
{
  "model": "sonnet",
  "reasoningEffort": "low"
}
```

**Models:** `sonnet`, `opus`, `haiku`, `gpt-5`, `custom:model-name`
**Reasoning:** `off`, `low`, `medium`, `high`

### Diff Mode

Configure how changes are displayed:

```json
{
  "diffMode": "github"
}
```

**Options:** `github`, `unified`, `split`

### Cloud Sync

Sync sessions across devices:

```json
{
  "cloudSessionSync": true
}
```

### Audio Feedback

Play sound on completion:

```json
{
  "completionSound": "bell"
}
```

**Options:** `bell`, `chime`, `none`

### Debug Mode

Enable verbose logging:

```json
{
  "debugHooks": true,
  "debugTools": true,
  "verboseLogging": true
}
```

## Environment Variables

Some settings can be overridden with environment variables:

```bash
# Factory API key
export FACTORY_API_KEY=fk-...

# Project directory
export FACTORY_PROJECT_DIR=/path/to/project

# Debug hooks
export FACTORY_DEBUG_HOOKS=1

# Disable telemetry
export FACTORY_TELEMETRY=0
```

## Configuration Locations

Settings are loaded in this order (later overrides earlier):

1. Global: `~/.factory/settings.json`
2. Project: `.factory/settings.json`
3. Environment variables

## Minimal Configuration

Don't need all features? Start minimal:

```json
{
  "enableCustomDroids": true,
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/load-project-skills.sh"
          }
        ]
      }
    ]
  }
}
```

## Recommended Configurations

### For Solo Developers

```json
{
  "enableCustomDroids": true,
  "contextManagement": {
    "autoOptimize": true,
    "optimizationThreshold": 0.80
  },
  "memory": {
    "autoSave": true,
    "saveDecisions": true
  }
}
```

### For Teams

```json
{
  "enableCustomDroids": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/validate-standards.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/auto-lint.sh"
          }
        ]
      }
    ]
  },
  "standards": {
    "enforcement": {
      "security": "block",
      "style": "auto-fix"
    }
  },
  "memory": {
    "autoSave": true,
    "saveDecisions": true,
    "savePatterns": true
  }
}
```

### For CI/CD

```json
{
  "enableCustomDroids": true,
  "contextManagement": {
    "autoOptimize": false
  },
  "standards": {
    "enforcement": {
      "security": "block",
      "typescript": "block",
      "style": "block"
    }
  }
}
```

## Validation

Validate your settings:

```bash
# Using jq
jq empty .factory/settings.json

# Using python
python3 -m json.tool .factory/settings.json
```

## Troubleshooting

**Hooks not running?**
- Check `debugHooks: true` in settings
- Verify hook scripts are executable: `chmod +x .factory/hooks/*.sh`
- Check logs: `~/.factory/logs/hooks.log`

**Settings not applied?**
- Restart droid session
- Check for JSON syntax errors
- Verify file location (`.factory/settings.json`)

**Performance issues?**
- Lower `optimizationThreshold` to 0.60
- Disable heavy hooks
- Reduce checkpoint frequency

## Resources

- [Factory.ai Settings Reference](https://docs.factory.ai/cli/configuration/settings)
- [Hooks Documentation](./HOOKS.md)
- [Skills System](./SKILLS.md)
- [Custom Droids](https://docs.factory.ai/cli/configuration/custom-droids)

---

**Tip**: Start with minimal settings and add features as needed. Too many hooks can slow down your workflow!
