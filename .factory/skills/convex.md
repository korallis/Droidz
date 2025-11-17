# Convex Best Practices

**Official Convex guidelines from convex.link/convex_rules.txt**

## Core Principles

1. **ALWAYS Use New Function Syntax** - Use object syntax with `args`, `returns`, `handler`
2. **ALWAYS Validate Everything** - Every function MUST have `args` and `returns` validators
3. **Transactions are Atomic** - Queries and mutations are transactional by default
4. **Queries are Reactive** - Queries automatically subscribe to changes
5. **Actions for Side Effects** - Use actions for external APIs, Node.js, non-deterministic code

## Function Syntax (CRITICAL)

### ✅ Good: New Function Syntax
```typescript
import { query, mutation, action } from "./_generated/server";
import { v } from "convex/values";

// Query - read data
export const getUser = query({
  args: { userId: v.id("users") },
  returns: v.union(
    v.object({
      _id: v.id("users"),
      _creationTime: v.number(),
      name: v.string(),
      email: v.string(),
    }),
    v.null()
  ),
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});

// Mutation - write data
export const createUser = mutation({
  args: { name: v.string(), email: v.string() },
  returns: v.id("users"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("users", args);
  },
});

// Action - external APIs, Node.js
export const sendEmail = action({
  args: { to: v.string(), subject: v.string() },
  returns: v.null(),
  handler: async (ctx, args) => {
    await fetch("https://api.sendgrid.com/...");
    return null;
  },
});
```

### ❌ Bad: Old Syntax (Never Use)
```typescript
// ❌ WRONG - Missing validators
export const getUser = query(async (ctx, args) => {
  return await ctx.db.get(args.userId);
});

// ❌ WRONG - No return validator
export const createUser = mutation({
  args: { name: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db.insert("users", args);
  },
});
```

## Validators (Complete Reference)

### ✅ Good: All Convex Types
```typescript
import { v } from "convex/values";

// Primitives
const args = {
  // String - UTF-8, <1MB
  name: v.string(),
  
  // Number - IEEE-754 double precision
  age: v.number(),
  
  // Int64 - BigInt between -2^63 and 2^63-1
  timestamp: v.int64(),
  
  // Boolean
  active: v.boolean(),
  
  // Null - use v.null() for returns
  deleted: v.null(),
  
  // Bytes - ArrayBuffer, <1MB
  data: v.bytes(),
  
  // Id - table ID
  userId: v.id("users"),
  
  // Optional
  bio: v.optional(v.string()),
  
  // Union (discriminated unions)
  status: v.union(
    v.literal("pending"),
    v.literal("active"),
    v.literal("archived")
  ),
  
  // Array - max 8192 items
  tags: v.array(v.string()),
  
  // Nested arrays
  matrix: v.array(v.array(v.number())),
  
  // Object - max 1024 entries
  profile: v.object({
    displayName: v.string(),
    avatarUrl: v.optional(v.string()),
  }),
  
  // Record - dynamic keys (NOT v.map or v.set!)
  metadata: v.record(v.string(), v.number()),
};
```

### ✅ Good: Discriminated Unions in Schema
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  results: defineTable(
    v.union(
      v.object({
        kind: v.literal("error") as const,  // Use 'as const'
        errorMessage: v.string(),
      }),
      v.object({
        kind: v.literal("success") as const,
        value: v.number(),
      })
    )
  ),
});
```

### ✅ Good: Returns Validator for Null
```typescript
// If function returns nothing, use v.null()
export const logEvent = mutation({
  args: { event: v.string() },
  returns: v.null(),
  handler: async (ctx, args) => {
    console.log(args.event);
    return null;  // Explicit null
  },
});
```

### ❌ Bad: Common Validator Mistakes
```typescript
// ❌ WRONG - No v.map() or v.set()
const args = {
  data: v.map(v.string(), v.number()),  // Use v.record() instead
};

// ❌ WRONG - Using v.bigint() (deprecated)
const args = {
  timestamp: v.bigint(),  // Use v.int64() instead
};

// ❌ WRONG - Using undefined
return undefined;  // Use null instead
```

## Function Registration

### ✅ Good: Public vs Internal Functions
```typescript
import { query, mutation, action } from "./_generated/server";
import { internalQuery, internalMutation, internalAction } from "./_generated/server";
import { v } from "convex/values";

// PUBLIC - Exposed to client, part of public API
export const listUsers = query({
  args: {},
  returns: v.array(v.object({
    _id: v.id("users"),
    name: v.string(),
  })),
  handler: async (ctx) => {
    return await ctx.db.query("users").collect();
  },
});

// INTERNAL - Private, only callable by other Convex functions
export const deleteOldUsers = internalMutation({
  args: { olderThan: v.number() },
  returns: v.null(),
  handler: async (ctx, args) => {
    const oldUsers = await ctx.db
      .query("users")
      .filter((q) => q.lt(q.field("lastActive"), args.olderThan))
      .collect();
    
    for (const user of oldUsers) {
      await ctx.db.delete(user._id);
    }
    
    return null;
  },
});
```

### ❌ Bad: Security Anti-patterns
```typescript
// ❌ WRONG - Sensitive function exposed publicly
export const deleteAllUsers = mutation({  // Should be internalMutation!
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    // Anyone can call this from the client!
    const users = await ctx.db.query("users").collect();
    for (const user of users) {
      await ctx.db.delete(user._id);
    }
    return null;
  },
});

// ❌ WRONG - Can't register via api object
export const createUser = api.users.create;  // Not allowed
```

## Function Calling

### ✅ Good: ctx.runQuery, ctx.runMutation, ctx.runAction
```typescript
import { query, mutation, action } from "./_generated/server";
import { internal, api } from "./_generated/api";
import { v } from "convex/values";

// Helper function in same file (needs type annotation)
export const getUser = query({
  args: { userId: v.id("users") },
  returns: v.union(v.object({
    _id: v.id("users"),
    name: v.string(),
  }), v.null()),
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});

// Calling from same file - add type annotation
export const getUserName = query({
  args: { userId: v.id("users") },
  returns: v.union(v.string(), v.null()),
  handler: async (ctx, args) => {
    // Type annotation to avoid TypeScript circularity
    const user: { name: string } | null = await ctx.runQuery(
      api.users.getUser,
      { userId: args.userId }
    );
    return user?.name ?? null;
  },
});

// From action - call queries and mutations
export const processUser = action({
  args: { userId: v.id("users") },
  returns: v.null(),
  handler: async (ctx, args) => {
    // Call query
    const user = await ctx.runQuery(api.users.getUser, { userId: args.userId });
    
    // Call mutation
    await ctx.runMutation(api.users.updateLastSeen, { userId: args.userId });
    
    return null;
  },
});
```

### ❌ Bad: Function Calling Mistakes
```typescript
// ❌ WRONG - Passing function directly
await ctx.runQuery(getUser, { userId });  // Use api.users.getUser

// ❌ WRONG - Calling action from action for same runtime
export const actionA = action({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    await ctx.runAction(api.actionB, {});  // Pull out shared code instead
    return null;
  },
});
```

## Function References

### ✅ Good: api vs internal
```typescript
// File: convex/users.ts
import { query, internalMutation } from "./_generated/server";
import { api, internal } from "./_generated/api";
import { v } from "convex/values";

// Public function → api.users.list
export const list = query({
  args: {},
  returns: v.array(v.object({ _id: v.id("users"), name: v.string() })),
  handler: async (ctx) => {
    return await ctx.db.query("users").collect();
  },
});

// Internal function → internal.users.cleanup
export const cleanup = internalMutation({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    // Cleanup logic
    return null;
  },
});

// File: convex/messages/chat.ts
// Public function → api.messages.chat.send
export const send = mutation({
  args: { content: v.string() },
  returns: v.id("messages"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("messages", args);
  },
});
```

## Schema Definition

### ✅ Good: Complete Schema
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    name: v.string(),
    email: v.string(),
    role: v.union(v.literal("admin"), v.literal("user")),
    lastActive: v.number(),
  })
    // Index name includes all fields
    .index("by_email", ["email"])
    .index("by_role_and_lastActive", ["role", "lastActive"])
    .searchIndex("search_name", {
      searchField: "name",
    }),
  
  messages: defineTable({
    channelId: v.id("channels"),
    authorId: v.optional(v.id("users")),
    content: v.string(),
  })
    // Query fields in index order
    .index("by_channel", ["channelId"])
    .index("by_channel_and_author", ["channelId", "authorId"]),
  
  // System fields auto-added: _id, _creationTime
});
```

### ✅ Good: Index Naming
```typescript
// ✅ CORRECT - Index name matches fields
.index("by_status", ["status"])
.index("by_userId_and_createdAt", ["userId", "createdAt"])

// ❌ WRONG - Index name doesn't match fields
.index("by_user", ["userId", "createdAt"])  // Should be by_userId_and_createdAt
```

## Queries

### ✅ Good: Use withIndex, Not filter
```typescript
// ✅ CORRECT - Use withIndex for performance
export const getUserMessages = query({
  args: { userId: v.id("users") },
  returns: v.array(v.object({
    _id: v.id("messages"),
    content: v.string(),
  })),
  handler: async (ctx, args) => {
    return await ctx.db
      .query("messages")
      .withIndex("by_userId", (q) => q.eq("userId", args.userId))
      .order("desc")
      .take(100);
  },
});

// Use .unique() for single results
export const getUserByEmail = query({
  args: { email: v.string() },
  returns: v.union(v.object({ _id: v.id("users"), name: v.string() }), v.null()),
  handler: async (ctx, args) => {
    return await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .unique();  // Throws if multiple matches
  },
});
```

### ✅ Good: Pagination with paginationOptsValidator
```typescript
import { paginationOptsValidator } from "convex/server";

export const listMessages = query({
  args: {
    paginationOpts: paginationOptsValidator,
    channelId: v.id("channels"),
  },
  returns: v.object({
    page: v.array(v.object({
      _id: v.id("messages"),
      content: v.string(),
    })),
    isDone: v.boolean(),
    continueCursor: v.string(),
  }),
  handler: async (ctx, args) => {
    return await ctx.db
      .query("messages")
      .withIndex("by_channel", (q) => q.eq("channelId", args.channelId))
      .order("desc")
      .paginate(args.paginationOpts);
  },
});

// Client usage:
// { page, isDone, continueCursor } = await ctx.runQuery(api.messages.list, {
//   paginationOpts: { numItems: 20, cursor: null }
// });
```

### ✅ Good: Async Iteration (No collect/take)
```typescript
export const processAllUsers = internalMutation({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    // Use async iteration for large datasets
    for await (const user of ctx.db.query("users")) {
      await ctx.db.patch(user._id, { processed: true });
    }
    return null;
  },
});
```

### ❌ Bad: Query Anti-patterns
```typescript
// ❌ WRONG - Using filter instead of withIndex
const messages = await ctx.db
  .query("messages")
  .filter((q) => q.eq(q.field("userId"), userId))  // Slow table scan!
  .collect();

// ❌ WRONG - Using .delete() on query
await ctx.db.query("messages").delete();  // Not supported

// Instead:
const messages = await ctx.db.query("messages").collect();
for (const msg of messages) {
  await ctx.db.delete(msg._id);
}
```

## Mutations

### ✅ Good: patch vs replace
```typescript
// patch - shallow merge (preferred for updates)
export const updateUser = mutation({
  args: { userId: v.id("users"), name: v.optional(v.string()) },
  returns: v.null(),
  handler: async (ctx, args) => {
    const { userId, ...updates } = args;
    await ctx.db.patch(userId, updates);  // Merges updates
    return null;
  },
});

// replace - full replacement
export const replaceUser = mutation({
  args: {
    userId: v.id("users"),
    name: v.string(),
    email: v.string(),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    const { userId, ...userData } = args;
    await ctx.db.replace(userId, userData);  // Replaces entire document
    return null;
  },
});
```

## Actions

### ✅ Good: Use "use node" for Node.js
```typescript
"use node";  // At top of file for Node.js built-ins

import { action } from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";
import OpenAI from "openai";

export const generateResponse = action({
  args: { prompt: v.string() },
  returns: v.string(),
  handler: async (ctx, args) => {
    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    
    const response = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [{ role: "user", content: args.prompt }],
    });
    
    const content = response.choices[0].message.content ?? "";
    
    // Save to database via mutation
    await ctx.runMutation(internal.ai.saveResponse, {
      prompt: args.prompt,
      response: content,
    });
    
    return content;
  },
});
```

### ❌ Bad: Action Mistakes
```typescript
// ❌ WRONG - Using ctx.db in action
export const badAction = action({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    await ctx.db.insert("users", { name: "test" });  // ctx.db doesn't exist!
    return null;
  },
});

// ❌ WRONG - Missing "use node"
import fs from "fs";  // Needs "use node" at top of file

export const readFile = action({...});
```

## Full Text Search

### ✅ Good: withSearchIndex
```typescript
export const searchMessages = query({
  args: {
    searchQuery: v.string(),
    channelId: v.id("channels"),
  },
  returns: v.array(v.object({
    _id: v.id("messages"),
    content: v.string(),
  })),
  handler: async (ctx, args) => {
    return await ctx.db
      .query("messages")
      .withSearchIndex("search_body", (q) =>
        q.search("body", args.searchQuery)
         .eq("channelId", args.channelId)
      )
      .take(10);
  },
});

// In schema.ts:
messages: defineTable({
  channelId: v.id("channels"),
  body: v.string(),
})
  .index("by_channel", ["channelId"])
  .searchIndex("search_body", {
    searchField: "body",
    filterFields: ["channelId"],
  }),
```

## File Storage

### ✅ Good: Complete File Upload Flow
```typescript
// 1. Generate upload URL
export const generateUploadUrl = mutation({
  args: {},
  returns: v.string(),
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

// 2. Save file metadata
export const saveFile = mutation({
  args: {
    storageId: v.id("_storage"),
    filename: v.string(),
  },
  returns: v.id("files"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("files", {
      storageId: args.storageId,
      filename: args.filename,
      uploadedAt: Date.now(),
    });
  },
});

// 3. Get file URL
export const getFileUrl = query({
  args: { storageId: v.id("_storage") },
  returns: v.union(v.string(), v.null()),
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);  // Returns null if not exists
  },
});

// 4. Get file metadata (NOT ctx.storage.getMetadata!)
export const getFileMetadata = query({
  args: { fileId: v.id("_storage") },
  returns: v.union(v.object({
    _id: v.id("_storage"),
    _creationTime: v.number(),
    contentType: v.optional(v.string()),
    sha256: v.string(),
    size: v.number(),
  }), v.null()),
  handler: async (ctx, args) => {
    // Query _storage system table
    return await ctx.db.system.get(args.fileId);
  },
});
```

## Cron Jobs

### ✅ Good: crons.interval and crons.cron
```typescript
// File: convex/crons.ts
import { cronJobs } from "convex/server";
import { internal } from "./_generated/api";
import { internalAction } from "./_generated/server";
import { v } from "convex/values";

// Define cron function in same file
const cleanupOldMessages = internalAction({
  args: {},
  returns: v.null(),
  handler: async (ctx) => {
    console.log("Cleaning up old messages...");
    await ctx.runMutation(internal.messages.deleteOld, {
      olderThan: Date.now() - 30 * 24 * 60 * 60 * 1000,
    });
    return null;
  },
});

const crons = cronJobs();

// Run every 2 hours
crons.interval(
  "cleanup old messages",
  { hours: 2 },
  internal.crons.cleanupOldMessages,
  {}
);

// Run daily at midnight UTC
crons.cron(
  "daily report",
  "0 0 * * *",
  internal.reports.generate,
  {}
);

export default crons;
```

### ❌ Bad: Cron Mistakes
```typescript
// ❌ WRONG - Using deprecated helpers
crons.hourly("task", internal.task, {});  // Use crons.interval({ hours: 1 })
crons.daily("task", internal.task, {});   // Use crons.cron("0 0 * * *", ...)

// ❌ WRONG - Passing function directly
crons.interval("task", { hours: 1 }, cleanupOldMessages, {});  // Use internal.crons.cleanupOldMessages
```

## HTTP Endpoints

### ✅ Good: httpRouter and httpAction
```typescript
// File: convex/http.ts
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

http.route({
  path: "/webhook/stripe",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    
    // Process webhook
    await ctx.runMutation(internal.stripe.processWebhook, {
      event: body,
    });
    
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Exact path registration - /api/users not /users
http.route({
  path: "/api/users",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const users = await ctx.runQuery(api.users.list, {});
    return new Response(JSON.stringify(users), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }),
});

export default http;
```

## TypeScript Best Practices

### ✅ Good: Id<"table"> and Doc<"table">
```typescript
import { Id, Doc } from "./_generated/dataModel";

// Use Id<"table"> for strong typing
export const getUser = query({
  args: { userId: v.id("users") },
  returns: v.union(v.object({
    _id: v.id("users"),
    name: v.string(),
  }), v.null()),
  handler: async (ctx, args: { userId: Id<"users"> }) => {
    return await ctx.db.get(args.userId);
  },
});

// Use Record<Id<"table">, T> for maps
export const getUsernames = query({
  args: { userIds: v.array(v.id("users")) },
  returns: v.record(v.id("users"), v.string()),
  handler: async (ctx, args) => {
    const idToUsername: Record<Id<"users">, string> = {};
    
    for (const userId of args.userIds) {
      const user = await ctx.db.get(userId);
      if (user) {
        idToUsername[user._id] = user.name;
      }
    }
    
    return idToUsername;
  },
});

// Use 'as const' for literals
type Status = "pending" | "active" | "archived";

const status = "pending" as const;
```

### ✅ Good: Strict Types
```typescript
// ✅ CORRECT - Array<T> with explicit type
const users: Array<Id<"users">> = [userId1, userId2];

// ✅ CORRECT - Record<K, V> with explicit types
const metadata: Record<string, number> = { views: 100, likes: 50 };

// ❌ WRONG - Using string for Id
function getUser(userId: string) {}  // Should be Id<"users">

// ❌ WRONG - Not using 'as const' for literals
const role = v.union(
  v.literal("admin"),  // Missing 'as const'
  v.literal("user")
);
```

**CRITICAL: ALWAYS use new function syntax with args/returns validators, use withIndex for queries, internal* for private functions, and "use node" for Node.js in actions.**
