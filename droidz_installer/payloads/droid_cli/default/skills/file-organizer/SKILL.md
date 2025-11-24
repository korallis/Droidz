# File Organizer - Intelligent File Management

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
