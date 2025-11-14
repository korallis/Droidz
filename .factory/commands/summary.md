---
description: Show detailed progress for an orchestration session
argument-hint: [session-id]
---

Please show a detailed summary of the Droidz orchestration session.

**Session ID:** $ARGUMENTS

Look in `.runs/.coordination/orchestration-*.json` files and show me:

1. **Progress**: Overall completion percentage
2. **Completed tasks**: List with checkmarks ✅
3. **In-progress tasks**: Currently working ⏳  
4. **Pending tasks**: Waiting to start ⏸
5. **Estimated completion time** based on remaining tasks

Format the output clearly with task keys, titles, and status symbols.
