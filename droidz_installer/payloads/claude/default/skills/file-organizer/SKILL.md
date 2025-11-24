---
name: file-organizer
description: Organizing files, finding duplicates, renaming.. Use when file organizer. Use when working with file organizer in your development workflow.
---

# File Organizer - Intelligent File Management

## When to use this skill

- Organizing files, finding duplicates, renaming.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Organizing files, finding duplicates, renaming.

## Pattern
\`\`\`typescript
const groupedFiles = files.reduce((acc, file) => {
  const ext = path.extname(file);
  if (!acc[ext]) acc[ext] = [];
  acc[ext].push(file);
  return acc;
}, {});
\`\`\`
