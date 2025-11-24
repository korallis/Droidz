---
name: document-processing-xlsx
description: Creating, parsing Excel spreadsheets. Use when processing, generating, or manipulating documents programmatically.
---

# Document Processing - Excel Files

## When to use this skill

- Creating, parsing Excel spreadsheets.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Creating, parsing Excel spreadsheets.

## Example
\`\`\`typescript
import * as XLSX from 'xlsx';

const ws = XLSX.utils.aoa_to_sheet([[1, 2], [3, 4]]);
const wb = XLSX.utils.book_new();
XLSX.utils.book_append_sheet(wb, ws, "Sheet1");
\`\`\`

## Resources
- [SheetJS](https://docs.sheetjs.com/)
