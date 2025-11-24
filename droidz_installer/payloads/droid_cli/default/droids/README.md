# Factory Droid CLI Droids

These droids inherit ALL tools from **Factory Droid CLI**, not from parent droids.

## Tool Inheritance

**DO NOT** specify `tools:` in droid YAML frontmatter.

When no `tools:` is specified, droids automatically inherit the complete tool set from Factory Droid CLI:
- Read, LS, Execute, Edit, ApplyPatch
- Grep, Glob, Create
- WebSearch, FetchUrl
- TodoWrite, Skill
- And any other tools available in the Factory.ai environment

## Why No Tool Specification?

1. **Sub-droid chains**: When droid A calls droid B, and droid B calls droid C, they all need access to the same tools from Factory Droid CLI
2. **Future-proof**: New tools added to Factory.ai automatically become available
3. **No conflicts**: Prevents "Invalid tools" errors from tool name mismatches
4. **Flexibility**: Droids can use any tool provided by the system

## Example Droid Configuration

```yaml
---
name: my-droid
description: Does something useful
color: green
model: inherit
---

Droid instructions here...
```

**Note**: No `tools:` line - inherits from Factory Droid CLI automatically.
