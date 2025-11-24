---
name: invoice-organizer
description: Organizing invoices, extracting metadata.. Use when invoice organizer. Use when working with invoice organizer in your development workflow.
---

# Invoice Organizer - Receipt Management

## When to use this skill

- Organizing invoices, extracting metadata.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Organizing invoices, extracting metadata.

## Pattern
\`\`\`typescript
const invoiceDate = extractDate(filename);
const newName = `${invoiceDate}_${vendor}_${amount}.pdf`;
fs.renameSync(oldPath, newPath);
\`\`\`
