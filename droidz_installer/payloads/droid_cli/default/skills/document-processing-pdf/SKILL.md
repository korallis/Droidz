---
name: document-processing-pdf
description: Generating, extracting data from PDFs.
---

# Document Processing - PDF Files

**Use when**: Generating, extracting data from PDFs.

## Example
\`\`\`typescript
import PDFDocument from 'pdfkit';

const doc = new PDFDocument();
doc.text('Hello World');
doc.end();
\`\`\`

## Resources
- [PDFKit](https://pdfkit.org/)
