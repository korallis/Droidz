---
description: Analyze and optimize context window usage
argument-hint: "[--analyze-only] [--aggressive] [--checkpoint]"
allowed-tools: Read, Create, Edit
---

# /optimize-context

Analyzes current context window usage and applies intelligent optimization to reduce token count while preserving conversation quality.

## Usage

```bash
# Show analysis only (no optimization)
/optimize-context --analyze-only

# Standard optimization (60-70% reduction)
/optimize-context

# Aggressive optimization (70-80% reduction)
/optimize-context --aggressive

# Create checkpoint before optimizing
/optimize-context --checkpoint
```

## What It Does

1. **Analyzes Current Context**
   - Total token count and percentage used
   - Breakdown by category (conversation, files, standards, tools)
   - Identifies optimization opportunities

2. **Creates Backup** (if --checkpoint)
   - Saves full conversation state to `.factory/.checkpoints/`
   - Enables recovery if needed

3. **Applies Hierarchical Optimization**
   - **Keep verbatim:** Last 10 turns, current task, all standards
   - **Summarize:** Turns 11-50 (brief summaries)
   - **Compress:** Turns 50+ (one-line summaries)
   - **Archive:** Important decisions to `.factory/memory/`

4. **Optimizes File Context**
   - Keeps top 5 most relevant files
   - Compresses next 5 to signatures (types, exports)
   - Removes rest (can be re-read)

5. **Compacts Tool Results**
   - Keeps recent tool outputs (last 5 turns)
   - Summarizes older results
   - Removes redundant outputs

## Example Output

### Analysis Mode

```
📊 Context Window Analysis

Current Usage: 142,847 / 200,000 tokens (71.4%) ⚠️

Breakdown:
├─ System Prompt: 8,234 tokens (5.8%)
│  ├─ CLAUDE.md files: 6,120 tokens
│  └─ Standards: 2,114 tokens
│  
├─ Conversation History: 89,456 tokens (62.6%)
│  ├─ Recent (turns 43-52): 15,234 tokens
│  ├─ Medium (turns 11-42): 52,180 tokens ← Can summarize
│  └─ Old (turns 1-10): 22,042 tokens ← Can compress
│  
├─ Code Context: 38,291 tokens (26.8%)
│  ├─ Recently accessed (5 files): 18,456 tokens
│  ├─ Medium age (7 files): 14,223 tokens ← Can compress
│  └─ Old (6 files): 5,612 tokens ← Can remove
│  
└─ Tool Results: 6,866 tokens (4.8%)
   ├─ Recent (last 5 turns): 2,340 tokens
   └─ Old (38 calls): 4,526 tokens ← Can compress

⚡ Optimization Opportunities:

1. Summarize conversation (turns 11-42) → Save ~35k tokens
2. Compress old conversation (turns 1-10) → Save ~18k tokens
3. Remove old files (6 files) → Save ~5k tokens
4. Compress file signatures (7 files) → Save ~8k tokens
5. Compress tool results → Save ~3k tokens

Estimated Savings: ~69k tokens (48.3% reduction)
New Estimated Usage: ~74k tokens (37.0%)

Apply optimizations? (y/n)
```

### Optimization Mode

```
🔧 Optimizing Context...

1. Creating checkpoint...
   ✅ Saved to .factory/.checkpoints/optimization-2025-11-11-21-30-45.json

2. Summarizing conversation (turns 11-42)...
   ✅ 32 turns → 6 phase summaries (35,180 tokens saved)

3. Compressing old conversation (turns 1-10)...
   ✅ 10 turns → 2 one-liners (17,850 tokens saved)

4. Optimizing file context...
   ✅ 5 files kept verbatim
   ✅ 7 files compressed to signatures
   ✅ 6 files removed (can re-read)
   ✅ 13,241 tokens saved

5. Compacting tool results...
   ✅ Recent results preserved
   ✅ Old results summarized
   ✅ 2,980 tokens saved

6. Archiving to memory...
   ✅ 3 decisions → .factory/memory/org/decisions.json
   ✅ 2 patterns → .factory/memory/org/patterns.json

✨ Optimization Complete!

Before: 142,847 tokens (71.4%)
After:  73,596 tokens (36.8%)
Saved:  69,251 tokens (48.5% reduction)

Quality Check:
✅ Recent conversation intact (last 10 turns)
✅ Current task preserved
✅ All standards preserved (8,234 tokens)
✅ Most relevant files retained
✅ Critical decisions archived to memory

Continue working! Context is now optimized. 🚀
```

## Arguments

- `--analyze-only`: Show analysis without optimizing
- `--aggressive`: More aggressive optimization (70-80% reduction)
- `--checkpoint`: Create backup before optimizing

## Aggressive Mode

Uses more compression:
- Keeps only last 5 turns verbatim (vs 10)
- Compresses turns 6-20 more heavily
- Keeps only top 3 files (vs 5)
- More aggressive tool result compression

**When to use:**
- Context >90% full (emergency)
- Very long sessions (100+ turns)
- Not concerned about losing some detail

## Recovery

If optimization removed something you need:

```bash
# List checkpoints
ls .factory/.checkpoints/

# Load from checkpoint
/load-checkpoint optimization-2025-11-11-21-30-45.json

# Or just re-read files
Read('src/components/UserProfile.tsx')
```

## Auto-Optimization

The `context-optimizer` skill automatically optimizes when context >70% full. This command provides manual control.

## Implementation

**Inputs:**
- `$1`: Optional flag (`--analyze-only`, `--aggressive`, `--checkpoint`)

**Outputs:**
- `STATUS=OPTIMIZED`
- `TOKENS_SAVED=${saved}`
- `NEW_USAGE=${usage}`

## Notes

- Always preserves CLAUDE.md standards files
- Never removes current task context
- Creates checkpoints for safety
- Archived decisions can be loaded with `/load-memory`
