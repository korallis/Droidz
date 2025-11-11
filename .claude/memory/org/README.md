# Organization Memory

This directory stores team-wide knowledge that persists across sessions.

## Files

- **decisions.json** - Architectural and technical decisions
- **patterns.json** - Code patterns and conventions discovered
- **standards.json** - Team standards and preferences

## How It Works

Skills and agents automatically save important decisions and patterns here:

```json
// decisions.json example
{
  "decisions": [
    {
      "timestamp": "2025-11-11T20:00:00Z",
      "category": "architecture",
      "title": "State Management Choice",
      "decision": "Use Zustand for client state",
      "rationale": "Simpler API than Redux, better TypeScript support",
      "alternatives": ["Redux", "Jotai", "Context API"],
      "participants": ["team"]
    }
  ]
}
```

These decisions are automatically loaded into context when relevant to the current task.

## Privacy

Organization memory is shared with all team members working on this project.
Personal preferences are stored in `.claude/memory/user/` instead.
