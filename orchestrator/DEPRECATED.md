# ⚠️ DEPRECATED

This `orchestrator/` directory is deprecated and will be removed in a future version.

## What Happened?

Droidz has been completely rebuilt using **agent-os principles** with a much simpler architecture:

### Old Approach (DEPRECATED)
- Complex TypeScript orchestrator
- Linear integration coupling
- Manual parallel worker management  
- Bun-only dependency

### New Approach (CURRENT)
- Simple markdown workflows
- Framework agnostic
- Droid CLI native with Task tool for parallelism
- Research-driven with Exa + Ref integration
- Based on proven agent-os patterns

## Migration

**Don't use this orchestrator code anymore.** Instead:

1. **Read the new README.md** for the current architecture
2. **Use the new droids:**
   - `@droidz-orchestrator` - Workflow coordinator
   - `@droidz-planner` - Product planning with Exa
   - `@droidz-spec-writer` - Specifications with Ref
   - `@droidz-implementer` - Parallel workers
   - `@droidz-verifier` - Verification

3. **See `workflows/`** for how the system actually works now
4. **Check `standards/`** for project conventions

## New Installation

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

This installs the new architecture without the old orchestrator complexity.

## Timeline

This directory will be removed in version 2.0.

For now, it remains for historical reference but **should not be used**.
