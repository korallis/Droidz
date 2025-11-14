---
description: Live monitoring of Droidz orchestration progress
argument-hint: [session-id]
---

Please run the Droidz live monitoring command.

Execute: `.factory/commands/watch.sh $ARGUMENTS`

This will show real-time progress with:
- Live updates every 2 seconds
- Color-coded task status (✓ done, ⏳ working, ⏸ waiting)
- Progress bars and completion percentages
- Active tmux session information

Press Ctrl+C to stop monitoring.

If no session ID provided, it will monitor the latest orchestration automatically.
