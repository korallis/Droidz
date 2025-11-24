# Claude Code Agents

These agents inherit ALL tools from **Claude Code**, not from parent agents.

## Tool Inheritance

**DO NOT** specify `tools:` in agent YAML frontmatter.

When no `tools:` is specified, agents automatically inherit the complete tool set from Claude Code:
- Read, LS, Execute, Edit, ApplyPatch
- Grep, Glob, Create
- WebSearch, FetchUrl
- TodoWrite, Skill
- And any other tools available in the Claude Code environment

## Why No Tool Specification?

1. **Sub-agent chains**: When agent A calls agent B, and agent B calls agent C, they all need access to the same tools from Claude Code
2. **Future-proof**: New tools added to Claude Code automatically become available
3. **No conflicts**: Prevents "Invalid tools" errors from tool name mismatches
4. **Flexibility**: Agents can use any tool provided by the system

## Example Agent Configuration

```yaml
---
name: my-agent
description: Does something useful
color: blue
model: inherit
---

Agent instructions here...
```

**Note**: No `tools:` line - inherits from Claude Code automatically.
