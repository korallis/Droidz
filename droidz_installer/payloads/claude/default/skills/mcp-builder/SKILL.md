---
name: mcp-builder
description: Building MCP servers, integrating APIs with LLMs.
---

# MCP Builder - Model Context Protocol Servers

**Use when**: Building MCP servers, integrating APIs with LLMs.

## Basic MCP Server
\`\`\`typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';

const server = new Server({
  name: 'my-server',
  version: '1.0.0'
});

server.setRequestHandler('tools/list', async () => ({
  tools: [{ name: 'search', description: 'Search data' }]
}));
\`\`\`

## Resources
- [MCP Docs](https://modelcontextprotocol.io/)
