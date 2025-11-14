# Convex Best Practices

## Core Principles

1. **Functions are Deterministic** - Queries and mutations must be deterministic
2. **Use Validators** - Always validate inputs with `v` validators
3. **Atomic Transactions** - Mutations are automatically transactional
4. **Type Safety** - Leverage TypeScript with Convex's generated types
5. **Real-time by Default** - Queries are reactive and update automatically

## Query Functions

### ✅ Good
```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

// Simple query with validator
export const getUser = query({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});

// Query with complex filtering
export const listTasks = query({
  args: {
    status: v.optional(v.union(v.literal("pending"), v.literal("completed"))),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("tasks");
    
    if (args.status) {
      query = query.filter((q) => q.eq(q.field("status"), args.status));
    }
    
    const limit = args.limit ?? 10;
    return await query.take(limit);
  },
});
```

### ❌ Bad
```typescript
// No validator
export const getUser = query(async (ctx, args) => {
  return await ctx.db.get(args.userId);  // No validation!
});

// Non-deterministic (uses Date.now() in query)
export const getRecentItems = query({
  args: {},
  handler: async (ctx) => {
    const now = Date.now();  // ❌ Non-deterministic!
    return await ctx.db.query("items")
      .filter((q) => q.gt(q.field("createdAt"), now - 86400000))
      .collect();
  },
});
```

## Mutation Functions

### ✅ Good
```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

// Create with full validation
export const createTask = mutation({
  args: {
    title: v.string(),
    description: v.optional(v.string()),
    dueDate: v.optional(v.number()),
    assignedTo: v.optional(v.id("users")),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthorized");
    }
    
    const taskId = await ctx.db.insert("tasks", {
      ...args,
      status: "pending",
      createdBy: identity.subject,
      createdAt: Date.now(),
    });
    
    return taskId;
  },
});

// Update with optimistic checks
export const updateTask = mutation({
  args: {
    taskId: v.id("tasks"),
    title: v.optional(v.string()),
    status: v.optional(v.union(v.literal("pending"), v.literal("completed"))),
  },
  handler: async (ctx, args) => {
    const { taskId, ...updates } = args;
    
    const existing = await ctx.db.get(taskId);
    if (!existing) {
      throw new Error("Task not found");
    }
    
    await ctx.db.patch(taskId, updates);
  },
});
```

### ❌ Bad
```typescript
// Missing validation and auth
export const createTask = mutation(async (ctx, args) => {
  return await ctx.db.insert("tasks", args);  // No validation or auth!
});

// Doesn't check existence
export const deleteTask = mutation({
  args: { taskId: v.id("tasks") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.taskId);  // What if it doesn't exist?
  },
});
```

## Action Functions

### ✅ Good
```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";
import { api } from "./_generated/api";

// Call external APIs in actions
export const sendEmail = action({
  args: {
    to: v.string(),
    subject: v.string(),
    body: v.string(),
  },
  handler: async (ctx, args) => {
    // External API call (OK in actions)
    await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.SENDGRID_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: args.to }] }],
        from: { email: "noreply@example.com" },
        subject: args.subject,
        content: [{ type: "text/plain", value: args.body }],
      }),
    });
    
    // Call mutation to log the email
    await ctx.runMutation(api.emails.logSent, {
      to: args.to,
      subject: args.subject,
      sentAt: Date.now(),
    });
  },
});
```

## Schema Definition

### ✅ Good
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    name: v.string(),
    email: v.string(),
    avatarUrl: v.optional(v.string()),
    role: v.union(v.literal("admin"), v.literal("user")),
    createdAt: v.number(),
  })
    .index("by_email", ["email"])
    .searchIndex("search_name", {
      searchField: "name",
    }),
  
  tasks: defineTable({
    title: v.string(),
    description: v.optional(v.string()),
    status: v.union(v.literal("pending"), v.literal("completed")),
    assignedTo: v.optional(v.id("users")),
    createdBy: v.string(),
    createdAt: v.number(),
    dueDate: v.optional(v.number()),
  })
    .index("by_status", ["status"])
    .index("by_assignedTo", ["assignedTo"])
    .index("by_createdBy", ["createdBy"]),
});
```

## File Storage

### ✅ Good
```typescript
// Upload file
export const generateUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

// Save file reference
export const saveFile = mutation({
  args: {
    storageId: v.id("_storage"),
    filename: v.string(),
    mimeType: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("files", {
      storageId: args.storageId,
      filename: args.filename,
      mimeType: args.mimeType,
      uploadedAt: Date.now(),
    });
  },
});

// Get file URL
export const getFileUrl = query({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

## Authentication

### ✅ Good
```typescript
// Always check auth in sensitive operations
export const updateProfile = mutation({
  args: { name: v.string(), avatarUrl: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthorized");
    }
    
    const user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) => 
        q.eq("tokenIdentifier", identity.tokenIdentifier)
      )
      .unique();
    
    if (!user) {
      throw new Error("User not found");
    }
    
    await ctx.db.patch(user._id, args);
  },
});
```

## Performance Best Practices

1. **Use indexes** - Add indexes for frequently filtered fields
2. **Limit results** - Use `.take(n)` to limit query results  
3. **Avoid N+1** - Use `Promise.all()` for parallel fetches
4. **Paginate** - Use cursor-based pagination for large lists

### ✅ Good
```typescript
// Efficient pagination
export const paginatedTasks = query({
  args: {
    cursor: v.optional(v.id("tasks")),
    pageSize: v.number(),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("tasks").order("desc");
    
    if (args.cursor) {
      query = query.filter((q) => q.lt(q.field("_id"), args.cursor!));
    }
    
    const tasks = await query.take(args.pageSize + 1);
    const hasMore = tasks.length > args.pageSize;
    const page = tasks.slice(0, args.pageSize);
    
    return {
      page,
      cursor: hasMore ? page[page.length - 1]._id : null,
      hasMore,
    };
  },
});
```

**ALWAYS validate inputs, check authentication, use indexes, and keep functions deterministic in Convex.**
