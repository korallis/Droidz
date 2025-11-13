# Convex Development Standards

## Project Structure

```
convex/
├── schema.ts            # Database schema definitions
├── _generated/          # Auto-generated types and API
│   ├── api.ts
│   ├── server.ts
│   └── dataModel.ts
├── functions.ts         # Public functions (queries, mutations, actions)
├── lib/                 # Internal helpers
│   └── validators.ts
└── auth.config.ts       # Authentication configuration
```

## Schema Definition

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

// ✅ Good: Well-defined schema with indexes
export default defineSchema({
  users: defineTable({
    name: v.string(),
    email: v.string(),
    imageUrl: v.optional(v.string()),
    clerkId: v.string(),
    createdAt: v.number(),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_email", ["email"]),
  
  messages: defineTable({
    userId: v.id("users"),
    channelId: v.id("channels"),
    content: v.string(),
    createdAt: v.number(),
  })
    .index("by_channel", ["channelId"])
    .index("by_user", ["userId"])
    .index("by_channel_and_time", ["channelId", "createdAt"]),
  
  channels: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    createdBy: v.id("users"),
    createdAt: v.number(),
  }),
});

// ❌ Bad: No indexes, poor performance
export default defineSchema({
  messages: defineTable({
    userId: v.string(), // Should be v.id("users")
    content: v.string(),
  }), // No indexes!
});
```

## Queries (Read Data)

```typescript
// convex/messages.ts
import { query } from "./_generated/server";
import { v } from "convex/values";

// ✅ Good: Query with validation
export const list = query({
  args: {
    channelId: v.id("channels"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const limit = args.limit ?? 100;
    
    // Query with index
    const messages = await ctx.db
      .query("messages")
      .withIndex("by_channel", (q) => q.eq("channelId", args.channelId))
      .order("desc")
      .take(limit);
    
    // Enrich with user data
    const messagesWithUsers = await Promise.all(
      messages.map(async (message) => {
        const user = await ctx.db.get(message.userId);
        return {
          ...message,
          user,
        };
      })
    );
    
    return messagesWithUsers.reverse();
  },
});

// ❌ Bad: Unvalidated arguments, no index usage
export const badList = query({
  handler: async (ctx, args: any) => {
    // No validation!
    const messages = await ctx.db
      .query("messages")
      .collect(); // Fetches ALL messages - performance issue!
    
    return messages;
  },
});
```

## Mutations (Write Data)

```typescript
// convex/messages.ts
import { mutation } from "./_generated/server";
import { v } from "convex/values";

// ✅ Good: Mutation with proper validation and error handling
export const send = mutation({
  args: {
    channelId: v.id("channels"),
    content: v.string(),
  },
  handler: async (ctx, args) => {
    // Get authenticated user
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    
    // Validate content
    if (args.content.trim().length === 0) {
      throw new Error("Message content cannot be empty");
    }
    
    if (args.content.length > 5000) {
      throw new Error("Message too long");
    }
    
    // Get user from database
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();
    
    if (!user) {
      throw new Error("User not found");
    }
    
    // Insert message
    const messageId = await ctx.db.insert("messages", {
      userId: user._id,
      channelId: args.channelId,
      content: args.content,
      createdAt: Date.now(),
    });
    
    return messageId;
  },
});

// ✅ Good: Optimistic mutation pattern
export const deleteMessage = mutation({
  args: {
    id: v.id("messages"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    
    const message = await ctx.db.get(args.id);
    if (!message) {
      throw new Error("Message not found");
    }
    
    // Check ownership
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();
    
    if (message.userId !== user?._id) {
      throw new Error("Unauthorized");
    }
    
    await ctx.db.delete(args.id);
  },
});
```

## Actions (External API Calls)

```typescript
// convex/actions.ts
import { action } from "./_generated/server";
import { api } from "./_generated/api";
import { v } from "convex/values";

// ✅ Good: Action for external API calls
export const sendEmail = action({
  args: {
    to: v.string(),
    subject: v.string(),
    body: v.string(),
  },
  handler: async (ctx, args) => {
    // Actions can make external API calls
    const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.SENDGRID_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: args.to }] }],
        from: { email: "noreply@example.com" },
        subject: args.subject,
        content: [{ type: "text/plain", value: args.body }],
      }),
    });
    
    if (!response.ok) {
      throw new Error("Failed to send email");
    }
    
    // Actions can call queries and mutations
    await ctx.runMutation(api.notifications.create, {
      type: "email_sent",
      recipient: args.to,
    });
    
    return { success: true };
  },
});

// ✅ Good: Action for long-running tasks
export const processUpload = action({
  args: {
    fileId: v.id("files"),
  },
  handler: async (ctx, args) => {
    // Get file info from mutation
    const file = await ctx.runQuery(api.files.get, { id: args.fileId });
    
    // Process file (external API, AI, etc.)
    const processedData = await processWithAI(file.url);
    
    // Store results
    await ctx.runMutation(api.files.update, {
      id: args.fileId,
      status: "processed",
      results: processedData,
    });
  },
});
```

## React Integration

```tsx
// app/components/messages.tsx
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useOptimistic } from "react";

export function MessageList({ channelId }: { channelId: Id<"channels"> }) {
  // ✅ Good: Real-time query with live updates
  const messages = useQuery(api.messages.list, { channelId });
  const sendMessage = useMutation(api.messages.send);
  
  // Optimistic UI
  const [optimisticMessages, addOptimisticMessage] = useOptimistic(
    messages ?? [],
    (state, newMessage: string) => [
      ...state,
      {
        _id: `temp-${Date.now()}` as Id<"messages">,
        _creationTime: Date.now(),
        userId: "" as Id<"users">,
        channelId,
        content: newMessage,
        createdAt: Date.now(),
        user: null,
        pending: true,
      },
    ]
  );
  
  const handleSubmit = async (formData: FormData) => {
    const content = formData.get("content") as string;
    addOptimisticMessage(content);
    await sendMessage({ channelId, content });
  };
  
  if (messages === undefined) {
    return <div>Loading...</div>;
  }
  
  return (
    <div>
      {optimisticMessages.map((msg) => (
        <div key={msg._id}>
          <strong>{msg.user?.name ?? "Unknown"}</strong>
          {msg.content}
          {msg.pending && <span> (Sending...)</span>}
        </div>
      ))}
      
      <form action={handleSubmit}>
        <input name="content" required />
        <button type="submit">Send</button>
      </form>
    </div>
  );
}
```

## Authentication

```typescript
// convex/auth.config.ts
export default {
  providers: [
    {
      domain: process.env.CLERK_FRONTEND_API_URL!,
      applicationID: "convex",
    },
  ],
};

// convex/users.ts
import { mutation, query } from "./_generated/server";

// ✅ Good: Get or create user pattern
export const getOrCreate = mutation({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    
    const existing = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();
    
    if (existing) {
      return existing._id;
    }
    
    // Create new user
    const userId = await ctx.db.insert("users", {
      name: identity.name ?? "Anonymous",
      email: identity.email ?? "",
      imageUrl: identity.pictureUrl,
      clerkId: identity.subject,
      createdAt: Date.now(),
    });
    
    return userId;
  },
});
```

## Pagination

```typescript
// convex/posts.ts
import { query } from "./_generated/server";
import { paginationOptsValidator } from "convex/server";
import { v } from "convex/values";

// ✅ Good: Paginated query
export const list = query({
  args: {
    paginationOpts: paginationOptsValidator,
    status: v.optional(v.union(v.literal("draft"), v.literal("published"))),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("posts");
    
    // Apply filter if provided
    if (args.status) {
      query = query.withIndex("by_status", (q) => q.eq("status", args.status));
    }
    
    // Paginate
    const result = await query.order("desc").paginate(args.paginationOpts);
    
    return result;
  },
});

// Client usage
const { results, status, loadMore } = usePaginatedQuery(
  api.posts.list,
  { status: "published" },
  { initialNumItems: 20 }
);
```

## Internal Functions

```typescript
// convex/lib/internal.ts
import { internalMutation, internalQuery } from "../_generated/server";
import { v } from "convex/values";

// ✅ Good: Internal functions not exposed to clients
export const cleanupOldMessages = internalMutation({
  args: {
    olderThan: v.number(),
  },
  handler: async (ctx, args) => {
    const oldMessages = await ctx.db
      .query("messages")
      .withIndex("by_created_at", (q) =>
        q.lt("createdAt", args.olderThan)
      )
      .collect();
    
    await Promise.all(
      oldMessages.map((msg) => ctx.db.delete(msg._id))
    );
    
    return oldMessages.length;
  },
});

// Schedule cleanup (convex/crons.ts)
import { cronJobs } from "convex/server";
import { internal } from "./_generated/api";

const crons = cronJobs();

crons.daily(
  "cleanup old messages",
  { hourUTC: 2 }, // 2 AM UTC
  internal.lib.internal.cleanupOldMessages,
  { olderThan: Date.now() - 30 * 24 * 60 * 60 * 1000 } // 30 days
);

export default crons;
```

## File Storage

```typescript
// convex/files.ts
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// ✅ Good: File upload pattern
export const generateUploadUrl = mutation(async (ctx) => {
  return await ctx.storage.generateUploadUrl();
});

export const saveFile = mutation({
  args: {
    storageId: v.id("_storage"),
    name: v.string(),
    type: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();
    
    if (!user) {
      throw new Error("User not found");
    }
    
    const fileId = await ctx.db.insert("files", {
      storageId: args.storageId,
      name: args.name,
      type: args.type,
      userId: user._id,
      createdAt: Date.now(),
    });
    
    return fileId;
  },
});

export const getUrl = query({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

## Best Practices

```typescript
// ✅ Good: Error handling
try {
  const result = await someOperation();
  return result;
} catch (error) {
  console.error("Operation failed:", error);
  throw new Error("Failed to process request");
}

// ✅ Good: Input validation
if (!args.email.includes("@")) {
  throw new Error("Invalid email format");
}

// ✅ Good: Use transactions implicitly
// All mutations are automatically transactional
await ctx.db.insert("users", userData);
await ctx.db.insert("profiles", profileData);
// Both succeed or both fail

// ✅ Good: Optimize queries with indexes
const messages = await ctx.db
  .query("messages")
  .withIndex("by_channel_and_time", (q) =>
    q.eq("channelId", channelId).gt("createdAt", timestamp)
  )
  .collect();
```

## Never

- ❌ Never expose internal functions to clients
- ❌ Never forget to validate arguments with `v.*` validators
- ❌ Never skip authentication checks in mutations/queries
- ❌ Never query without indexes for filtered data
- ❌ Never use `.collect()` on large tables without filters
- ❌ Never store sensitive data unencrypted
- ❌ Never forget to handle pagination for large result sets
- ❌ Never make external API calls in queries or mutations (use actions)
- ❌ Never use `any` type for arguments
- ❌ Never forget to add indexes for commonly queried fields
