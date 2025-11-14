---
description: Attach to a task's tmux session to watch it work
argument-hint: [task-key]
---

I need to attach to a Droidz task session.

**Task:** $ARGUMENTS

Please help me:

1. List available tmux sessions with `tmux ls | grep droidz`
2. Find the session for task: droidz-$ARGUMENTS
3. Show me the command to attach: `tmux attach -t droidz-$ARGUMENTS`

If the session doesn't exist, show me which sessions are available.

**To detach later:** Press `Ctrl+B` then `D`
