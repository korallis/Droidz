# User Memory

This directory stores personal preferences that persist across sessions.

## Files

- **{username}.json** - Your personal preferences and work history

## How It Works

The memory-manager skill automatically remembers your preferences:

```json
{
  "preferences": {
    "codeStyle": {
      "functionStyle": "arrow-functions",
      "componentStyle": "functional",
      "importOrganization": "absolute-first"
    },
    "testing": {
      "approach": "tdd",
      "framework": "vitest",
      "coverageThreshold": 80
    },
    "git": {
      "commitStyle": "conventional-commits",
      "branchNaming": "feature/{ticket}-{description}"
    }
  },
  "workHistory": {
    "commonPatterns": [
      "Prefers custom hooks over inline logic",
      "Uses Zod for all input validation",
      "Follows Repository pattern for data access"
    ],
    "frequentlyUsedTools": [
      "React Query",
      "Tailwind CSS",
      "Zod"
    ]
  }
}
```

## Privacy

User memory is private to you and doesn't sync with the team.
