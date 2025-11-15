---
description: Live monitoring of Droidz orchestration progress
argument-hint: [session-id]
---

**⚠️ NOTE: This command is for the OLD Droidz orchestration system (tmux + git worktrees).**

**For the current Factory.ai Task tool system**, progress appears directly in the conversation - no separate monitoring needed!

---

If you're using the **old orchestration system** (tmux-based), run:

Execute: `.factory/commands/watch.sh $ARGUMENTS`

This will show real-time progress with:
- Live updates every 2 seconds
- Color-coded task status (✓ done, ⏳ working, ⏸ waiting)
- Progress bars and completion percentages
- Active tmux session information

Press Ctrl+C to stop monitoring.

---

**For `/auto-parallel` (current system):** Just watch this conversation - all progress appears here automatically via Task tool updates!
