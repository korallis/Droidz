---
name: document-processing-xlsx
description: Creating, parsing Excel spreadsheets.
---

# Document Processing - Excel Files

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
