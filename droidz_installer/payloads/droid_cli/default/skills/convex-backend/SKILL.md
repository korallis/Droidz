---
name: convex-backend
description: Building realtime apps with Convex, implementing reactive queries, or managing backend logic with type-safe functions. Use when building real-time applications with Convex, implementing reactive queries, mutations, or managing backend functions.
---

# Convex Backend - Realtime Database & Functions

## When to use this skill

- Building realtime apps with Convex, implementing reactive queries, or managing backend logic with type-safe functions.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Building realtime apps with Convex, implementing reactive queries, or managing backend logic with type-safe functions.

## Core Concepts

### Queries (Read Data)
\`\`\`typescript
import { query } from './_generated/server';
import { v } from 'convex/values';

export const list = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query('users').collect();
  }
});

export const get = query({
  args: { id: v.id('users') },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  }
});
\`\`\`

### Mutations (Write Data)
\`\`\`typescript
import { mutation } from './_generated/server';

export const create = mutation({
  args: { name: v.string(), email: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db.insert('users', args);
  }
});
\`\`\`

## Resources
- [Convex Docs](https://docs.convex.dev/)
