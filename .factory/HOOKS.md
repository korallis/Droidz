# Factory.ai Hooks Documentation

Hooks allow you to inject custom behavior at specific points in the droid lifecycle.

## Available Hook Types

Based on Factory.ai official documentation, these hook types are available:

### 1. **PreToolUse**
Runs before any tool is executed. Useful for validation, logging, or blocking dangerous operations.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|Create",
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/validate-file.sh"
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Prevent editing critical files (.env, package-lock.json)
- Log all tool usage for audit
- Validate inputs before execution

### 2. **PostToolUse**
Runs after a tool completes. Useful for cleanup, validation, or triggering follow-up actions.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/auto-lint.sh"
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Auto-format code after edits
- Run linters/typecheckers
- Update related files
- Trigger build processes

### 3. **Stop**
Runs when the main assistant finishes a session.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Before ending session: summarize work done, note incomplete tasks, and save important decisions to memory."
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Generate session summaries
- Save decisions to memory
- Export conversation logs
- Clean up temporary files

### 4. **SubagentStop**
Runs when a subagent (custom droid) completes its task.

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "After subagent completes: update Linear ticket, save decisions to org memory, and update TodoWrite progress."
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Update ticket status
- Save architectural decisions
- Save code patterns to library
- Log subagent results

### 5. **UserPromptSubmit**
Runs when the user submits a message (before processing).

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/inject-skills.sh"
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Inject relevant skills based on prompt
- Load project context
- Monitor context usage
- Auto-activate specialized droids

### 6. **Notification**
Runs when specific events occur (errors, completions, etc.).

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "error|failed|exception",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "When error notification: analyze error, check memory for similar issues, suggest fix based on standards."
          }
        ]
      }
    ]
  }
}
```

**Use cases:**
- Error analysis and recovery
- Completion notifications
- Alert on critical events

## Hook Configuration

### Hook Types

**1. Command Hooks**
Executes a shell script:

```json
{
  "type": "command",
  "command": ".factory/hooks/my-script.sh",
  "description": "Optional description"
}
```

**2. Prompt Hooks**
Injects a prompt into the conversation:

```json
{
  "type": "prompt",
  "prompt": "Check if this file follows our coding standards..."
}
```

### Matchers

Use matchers to filter when hooks run:

```json
{
  "matcher": "Edit|Write|Create",  // Regex pattern
  "hooks": [...]
}
```

**Common patterns:**
- `"Edit|Write"` - Any file modification
- `"Read|Grep|Glob"` - Any file reading
- `"Execute"` - Shell command execution
- `"error|failed"` - Error notifications

## Complete Example

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json, sys; data=json.load(sys.stdin); path=data.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(p in path for p in ['.env', 'package-lock.json']) else 0)\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".factory/hooks/auto-lint.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Summarize session and save decisions to memory"
          }
        ]
      }
    ]
  }
}
```

## Writing Hook Scripts

### Bash Hook Example

```bash
#!/usr/bin/env bash
# .factory/hooks/validate-file.sh

set -euo pipefail

# Read tool input from stdin (JSON)
INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Block critical files
BLOCKED_FILES=(".env" "package-lock.json" ".git/")

for blocked in "${BLOCKED_FILES[@]}"; do
  if [[ "$FILE_PATH" == *"$blocked"* ]]; then
    echo "ERROR: Cannot modify $FILE_PATH (critical file)" >&2
    exit 2  # Non-zero exits block the tool
  fi
done

# Allow operation
exit 0
```

### Python Hook Example

```python
#!/usr/bin/env python3
# .factory/hooks/check-standards.py

import json
import sys

# Read tool input
data = json.load(sys.stdin)
file_path = data.get('tool_input', {}).get('file_path', '')

# Check for standards violations
if file_path.endswith('.ts'):
    content = data.get('tool_input', {}).get('content', '')
    if 'console.log' in content:
        print("WARNING: console.log detected - should use logger", file=sys.stderr)
        sys.exit(1)  # Exit 1 = warning (allows operation)

# All good
sys.exit(0)
```

## Hook Exit Codes

- **0**: Success - allow operation
- **1**: Warning - allow operation but show warning
- **2**: Block - prevent operation

## Best Practices

### ✅ DO:
- Keep hooks fast (< 100ms ideally)
- Use exit codes correctly
- Log to stderr for debugging
- Make hooks idempotent
- Test hooks thoroughly

### ❌ DON'T:
- Make slow network calls
- Modify files in pre-hooks
- Assume file paths are absolute
- Use interactive prompts
- Rely on specific directory structure

## Debugging Hooks

Enable verbose logging:

```bash
# Set environment variable
export FACTORY_DEBUG_HOOKS=1

# Or in settings.json
{
  "debugHooks": true
}
```

Check hook logs:
```bash
tail -f ~/.factory/logs/hooks.log
```

## Integration with Droidz

Droidz currently includes these hooks in `.factory/hooks/`:

- `inject-skills.sh` - UserPromptSubmit hook
- `inject-file-skills.sh` - PreToolUse hook  
- `load-project-skills.sh` - SessionStart hook
- `auto-lint.sh` - PostToolUse hook (optional)

## Resources

- [Factory.ai Hooks Documentation](https://docs.factory.ai/cli/configuration/hooks-guide)
- [Factory.ai Settings Reference](https://docs.factory.ai/cli/configuration/settings)
- [Droidz Skills System](./SKILLS.md)

---

**Remember**: Hooks are powerful but should be used judiciously. Start simple and add complexity only when needed!
