# Simple Dual Installation Plan

## Goal
Create two **completely separate** installations that don't share any code:
- **Mode 1**: Droid CLI → `.factory/` folder (current)
- **Mode 2**: Claude Code → `.claude/` folder (new, separate files)

## Key Insight from Research

✅ **Confirmed**: Claude Code uses `.claude/` directory structure:
- `.claude/agents/` for subagents (same as Droid CLI droids)
- `.claude/commands/` for slash commands
- `.claude/settings.json` for configuration
- `CLAUDE.md` for root instructions (instead of plugin.json)

## Simple Installer Flow

```bash
echo "Select installation:"
echo "  1) Droid CLI (Factory.ai)"
echo "  2) Claude Code (Anthropic)"
read -p "Choice: " mode

if [ "$mode" = "1" ]; then
    # Download to .factory/
    # Create plugin.json
elif [ "$mode" = "2" ]; then
    # Download to .claude/
    # Create CLAUDE.md
fi
```

## File Mapping: .factory/ → .claude/

| Droid CLI | Claude Code | Notes |
|-----------|-------------|-------|
| `.factory/droids/*.md` | `.claude/agents/*.md` | Same markdown, different folder |
| `.factory/commands/*.md` | `.claude/commands/*.md` | Same slash commands |
| `.factory/skills/*/SKILL.md` | `.claude/skills/*.md` | Refactor for Claude Code skills |
| `plugin.json` | `CLAUDE.md` | Different format: JSON → Markdown |
| `.factory/settings.json` | `.claude/settings.json` | Different schema |

## Mode 2 Structure (Claude Code)

```
.claude/
├── agents/                    # Droids → Agents
│   ├── orchestrator.md
│   ├── codegen.md
│   ├── test.md
│   └── ... (14 more)
├── commands/                  # Slash commands
│   ├── init.md
│   ├── build.md
│   ├── parallel.md
│   └── validate.md
├── skills/                    # Skills (different format)
│   ├── typescript.md
│   ├── react.md
│   └── ... (60 more)
├── hooks/                     # Event hooks
│   └── scripts/
└── settings.json              # Claude Code config

CLAUDE.md                      # Root instructions (replaces plugin.json)
config.yml                     # Shared config (optional)
```

## What Gets Duplicated

**Content to duplicate and refactor:**
1. **15 droids** → `.claude/agents/*.md`
   - Change frontmatter format (YAML keys different)
   - Keep system prompts identical
   
2. **Commands** → `.claude/commands/*.md`
   - Same content, just copy

3. **Skills** → `.claude/skills/*.md`  
   - Major refactor needed (Claude Code skills are different)
   - May skip some skills that don't translate

4. **Hooks** → `.claude/hooks/`
   - Same bash scripts, copy as-is

5. **New file**: `CLAUDE.md`
   - Root configuration file
   - Explains framework to Claude
   - Lists available agents/commands

## Frontmatter Differences

### Droid CLI (plugin.json + .md)
```json
{
  "name": "droidz-orchestrator",
  "model": "inherit"
}
```

### Claude Code (.claude/agents/*.md)
```yaml
---
name: orchestrator
description: Coordinates parallel work streams
model: inherit
tools: Read, Write, Bash, Grep
---
```

## Installation Steps

### Mode 1: Droid CLI (unchanged)
```bash
1. Create .factory/ folders
2. Download 15 droids
3. Download commands
4. Download skills
5. Create plugin.json
6. npm install yaml
7. Show: Enable in /settings
```

### Mode 2: Claude Code (NEW)
```bash
1. Create .claude/ folders
2. Download 15 agents (refactored from droids)
3. Download commands
4. Download skills (Claude Code format)
5. Create CLAUDE.md (root config)
6. Create .claude/settings.json
7. npm install yaml
8. Show: Restart Claude Code
```

## Implementation Checklist

### Phase 1: Create Claude Code Files
- [ ] Duplicate `.factory/droids/*.md` → `.claude/agents/*.md`
- [ ] Refactor frontmatter (YAML format)
- [ ] Create `CLAUDE.md` root config
- [ ] Create `.claude/settings.json`
- [ ] Copy `.factory/commands/*.md` → `.claude/commands/*.md`
- [ ] Copy `.factory/hooks/` → `.claude/hooks/`
- [ ] Refactor skills (different format for Claude Code)

### Phase 2: Update installer.sh
- [ ] Add mode selection menu
- [ ] Branch: Mode 1 → download to `.factory/`
- [ ] Branch: Mode 2 → download to `.claude/`
- [ ] Update next steps instructions

### Phase 3: Documentation
- [ ] Create `CLAUDE_CODE_SETUP.md`
- [ ] Update `README.md` (add Claude Code section)
- [ ] Add comparison table

### Phase 4: Testing
- [ ] Test Mode 1 (fresh install)
- [ ] Test Mode 2 (fresh install)
- [ ] Verify no conflicts
- [ ] Test update from v3.1.6

## Files to Create (New for Claude Code)

1. **`.claude/agents/orchestrator.md`** (x15)
2. **`.claude/agents/codegen.md`** (x15)
3. **... (13 more agents)**
4. **`CLAUDE.md`** - Root config
5. **`.claude/settings.json`** - Claude Code config
6. **`CLAUDE_CODE_SETUP.md`** - Setup guide

## Example: CLAUDE.md

```markdown
# Droidz Framework for Claude Code

You are working with the **Droidz Framework** - a production-grade AI development system.

## Available Agents

You have access to 15 specialist agents in `.claude/agents/`:
- **orchestrator** - Coordinates parallel work streams
- **codegen** - Implements features with comprehensive tests
- **test** - Writes and fixes tests
- ... (list all 15)

## Slash Commands

- **/init** - Initialize project analysis
- **/build** - Generate feature spec from vague idea
- **/parallel** - Execute tasks in parallel
- **/validate** - Run 5-phase validation

## When to Use Agents

Use agents proactively:
- Complex features → orchestrator
- New code → codegen
- Test failures → test
- Security review → security-auditor

## Skills Auto-Activation

61 skills auto-activate based on context:
- TypeScript code → typescript skill
- React components → react skill
- Database queries → postgresql skill

## Memory

Store decisions in `.factory/memory/`:
- Team decisions → `org/`
- Personal notes → `user/`
```

## Breaking Changes

❌ **NONE** for Droid CLI users
- Mode 1 installation unchanged
- All `.factory/` paths same
- Same `/settings` activation
- No impact on existing users

✅ **Completely separate** Claude Code version
- Different folder (`.claude/`)
- Different config files
- Different activation method
- No interaction with Droid CLI

## Benefits

✅ **Simple installer** - just ask: 1 or 2?  
✅ **No shared code** - no MCP bridge needed  
✅ **Independent** - tools don't interfere  
✅ **Clean** - each tool has its own structure  
✅ **Maintainable** - separate update paths  

## Testing Matrix

| Scenario | Expected |
|----------|----------|
| Fresh Mode 1 | `.factory/` + `plugin.json` |
| Fresh Mode 2 | `.claude/` + `CLAUDE.md` |
| Update v3.1.6 (Mode 1) | Unchanged |
| Run both | Both folders coexist |

## Timeline

1. **Phase 1**: Create `.claude/` versions (3-5 hours)
2. **Phase 2**: Update installer (1 hour)
3. **Phase 3**: Documentation (1 hour)
4. **Phase 4**: Testing (1 hour)

**Total**: ~1 day of work

## Summary

Simple approach:
- Two separate installations
- User picks 1 or 2
- No shared code
- No MCP complexity
- Just duplicate and refactor for `.claude/`

Ready to proceed?