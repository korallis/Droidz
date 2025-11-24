---
name: document-processing-docx
description: Creating, editing Word documents programmatically.
---

# Document Processing - DOCX Files

**Use when**: Creating, editing Word documents programmatically.

## Example
\`\`\`typescript
import { Document, Packer, Paragraph } from 'docx';

const doc = new Document({
  sections: [{
    children: [new Paragraph("Hello World")]
  }]
});
\`\`\`

## Resources
- [docx npm package](https://www.npmjs.com/package/docx)
