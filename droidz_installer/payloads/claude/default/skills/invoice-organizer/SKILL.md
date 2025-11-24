# Invoice Organizer - Receipt Management

**Use when**: Organizing invoices, extracting metadata.

## Pattern
\`\`\`typescript
const invoiceDate = extractDate(filename);
const newName = `${invoiceDate}_${vendor}_${amount}.pdf`;
fs.renameSync(oldPath, newPath);
\`\`\`
