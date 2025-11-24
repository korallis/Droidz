---
name: file-organizer
description: Organize, categorize, rename, and manage files systematically using automated rules, naming conventions, and folder structures for efficient file management. Use when organizing uploaded files, implementing file naming conventions, categorizing files by type or metadata, creating folder structures, cleaning up messy directories, automating file movements, implementing media libraries, or building file management systems.
---

# File Organizer - Intelligent File Management

## When to use this skill

- Organizing large numbers of uploaded files
- Implementing systematic file naming conventions
- Categorizing files by type, date, or metadata
- Creating logical folder structures
- Cleaning up messy or disorganized directories
- Automating file movements based on rules
- Building media libraries with categorization
- Implementing file tagging systems
- Organizing downloads or document repositories
- Creating searchable file systems
- Implementing version control for files
- Building document management workflows

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
