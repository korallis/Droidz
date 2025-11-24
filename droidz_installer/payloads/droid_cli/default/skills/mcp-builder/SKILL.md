---
name: mcp-builder
description: Build Model Context Protocol (MCP) servers and tools that extend Claude's capabilities with custom functions, data sources, and integrations. Use when creating custom MCP servers, implementing tools for Claude, building integrations with external services, creating data source connectors, implementing custom functions, or extending Claude's capabilities with domain-specific tools.
---

# MCP Builder - Model Context Protocol Servers

## When to use this skill

- Creating custom MCP servers for Claude
- Implementing custom tools and functions
- Building integrations with external APIs
- Creating data source connectors
- Implementing domain-specific tools
- Extending Claude with custom capabilities
- Building workflow automation tools
- Creating database query interfaces
- Implementing file system operations
- Building search and retrieval tools
- Creating specialized calculators or converters
- Implementing custom validation logic

## When to use this skill

- Building MCP servers, integrating APIs with LLMs.
- When working on related tasks or features
- During development that requires this expertise

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
