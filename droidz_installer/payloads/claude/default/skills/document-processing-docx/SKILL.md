---
name: document-processing-docx
description: Creating, editing Word documents programmatically. Use when processing, generating, or manipulating documents programmatically.
---

# Document Processing - DOCX Files

## When to use this skill

- Creating, editing Word documents programmatically.
- When working on related tasks or features
- During development that requires this expertise

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
