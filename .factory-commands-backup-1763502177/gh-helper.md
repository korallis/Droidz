---
description: GitHub CLI helper with correct JSON field names
argument-hint: <command> [args]
---

Please run the GitHub helper command.

Execute: `.factory/commands/gh-helper.sh $ARGUMENTS`

Available commands:
- `pr-checks <pr-number>` - Show PR checks with correct field names (bucket, not status)
- `pr-status <pr-number>` - Comprehensive PR status including checks
- `pr-list` - List all pull requests

This helper uses the correct GitHub CLI JSON fields to avoid errors.

Examples:
- `/gh-helper pr-checks 10`
- `/gh-helper pr-status 10`
- `/gh-helper pr-list`
