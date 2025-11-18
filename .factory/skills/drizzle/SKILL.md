# Drizzle ORM Skill

**Version**: 1.0.0  
**Last Updated**: 2025-11-16  
**Official Docs**: https://orm.drizzle.team

---

## Overview

Drizzle ORM is a lightweight, type-safe TypeScript ORM designed with developer experience and performance in mind. Unlike traditional ORMs, Drizzle embraces SQL rather than abstracting it away, providing a SQL-like query builder that gives you full control while maintaining excellent TypeScript integration.

### Key Features
- **Type-safe**: Full TypeScript support with zero runtime overhead
- **SQL-like syntax**: If you know SQL, you know Drizzle
- **Lightweight**: Minimal bundle size and dependencies
- **Performance-focused**: Direct SQL translation with no hidden queries
- **Flexible migrations**: Multiple migration strategies to fit your workflow
- **Relational queries**: Nested data fetching without manual joins

### Supported Databases
- PostgreSQL (pg, neon, vercel, supabase, xata, etc.)
- MySQL (mysql2, planetscale)
- SQLite (better-sqlite3, libsql, turso, d1)

---

## 1. Schema Definition (Complete Guide)

### 1.1 Basic Table Structure

Every Drizzle schema starts with table definitions. Choose the correct table constructor for your database dialect.

#### ✅ Good: Dialect-Specific Tables

```typescript
// PostgreSQL
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  email: text('email').notNull().unique(),
});
```

```typescript
// MySQL
import { mysqlTable, int, varchar } from 'drizzle-orm/mysql-core';

export const users = mysqlTable('users', {
  id: int('id').primaryKey().autoincrement(),
  name: varchar('name', { length: 255 }),
  email: varchar('email', { length: 255 }).notNull().unique(),
});
```

```typescript
// SQLite
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  name: text('name'),
  email: text('email').notNull().unique(),
});
```

#### ❌ Bad: Wrong Dialect

```typescript
// DON'T mix dialects
import { pgTable } from 'drizzle-orm/pg-core';
import { int } from 'drizzle-orm/mysql-core'; // Wrong!

export const users = pgTable('users', {
  id: int('id').primaryKey(), // Type error!
});
```

### 1.2 Column Types Reference

#### PostgreSQL Column Types

```typescript
import {
  pgTable,
  serial,
  bigserial,
  integer,
  bigint,
  boolean,
  text,
  varchar,
  char,
  numeric,
  real,
  doublePrecision,
  json,
  jsonb,
  timestamp,
  date,
  time,
  interval,
  uuid,
  inet,
  cidr,
  macaddr,
  point,
  line,
  vector,
} from 'drizzle-orm/pg-core';

export const products = pgTable('products', {
  // Integers
  id: serial('id').primaryKey(),
  bigId: bigserial('big_id'),
  count: integer('count'),
  bigCount: bigint('big_count', { mode: 'number' }), // or 'bigint'
  
  // Boolean
  active: boolean('active').default(true),
  
  // Text
  name: text('name'),
  slug: varchar('slug', { length: 255 }),
  code: char('code', { length: 10 }),
  
  // Numbers
  price: numeric('price', { precision: 10, scale: 2 }),
  weight: real('weight'),
  coordinates: doublePrecision('coordinates'),
  
  // JSON
  metadata: json('metadata').$type<{ key: string }>(),
  settings: jsonb('settings').$type<{ theme: string }>(),
  
  // Date/Time
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  publishedDate: date('published_date'),
  openTime: time('open_time'),
  duration: interval('duration'),
  
  // Special Types
  uid: uuid('uid').defaultRandom(),
  ipAddress: inet('ip_address'),
  network: cidr('network'),
  mac: macaddr('mac'),
  location: point('location'),
  path: line('path'),
  embedding: vector('embedding', { dimensions: 1536 }), // for AI/ML
});
```

#### MySQL Column Types

```typescript
import {
  mysqlTable,
  int,
  bigint,
  tinyint,
  boolean,
  varchar,
  text,
  mediumtext,
  longtext,
  decimal,
  float,
  double,
  json,
  datetime,
  timestamp,
  date,
  time,
  year,
  binary,
  varbinary,
} from 'drizzle-orm/mysql-core';

export const products = mysqlTable('products', {
  // Integers
  id: int('id').primaryKey().autoincrement(),
  bigId: bigint('big_id', { mode: 'number' }),
  status: tinyint('status'),
  active: boolean('active').default(true),
  
  // Text
  name: varchar('name', { length: 255 }),
  description: text('description'),
  content: mediumtext('content'),
  fullContent: longtext('full_content'),
  
  // Numbers
  price: decimal('price', { precision: 10, scale: 2 }),
  weight: float('weight'),
  coordinates: double('coordinates'),
  
  // JSON
  metadata: json('metadata').$type<Record<string, unknown>>(),
  
  // Date/Time
  createdAt: datetime('created_at').notNull(),
  updatedAt: timestamp('updated_at').defaultNow().onUpdateNow(),
  publishedDate: date('published_date'),
  openTime: time('open_time'),
  establishedYear: year('established_year'),
  
  // Binary
  hash: binary('hash', { length: 32 }),
  file: varbinary('file', { length: 1024 }),
});
```

#### SQLite Column Types

```typescript
import { sqliteTable, integer, text, real, blob } from 'drizzle-orm/sqlite-core';

export const products = sqliteTable('products', {
  // Integer (SQLite stores everything as INTEGER, REAL, TEXT, or BLOB)
  id: integer('id').primaryKey({ autoIncrement: true }),
  count: integer('count'),
  active: integer('active', { mode: 'boolean' }).default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  
  // Text
  name: text('name'),
  description: text('description'),
  
  // Real (floating point)
  price: real('price'),
  weight: real('weight'),
  
  // Blob (binary data)
  file: blob('file', { mode: 'buffer' }),
  
  // JSON (stored as TEXT)
  metadata: text('metadata', { mode: 'json' }).$type<{ key: string }>(),
});
```

### 1.3 Column Modifiers & Constraints

#### ✅ Good: Proper Constraints

```typescript
import { pgTable, serial, text, integer, varchar, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  
  // NOT NULL
  email: text('email').notNull(),
  
  // UNIQUE
  username: text('username').unique(),
  
  // DEFAULT values
  role: text('role').default('user'),
  createdAt: timestamp('created_at').defaultNow(),
  
  // Multiple constraints
  verifiedEmail: text('verified_email')
    .notNull()
    .unique()
    .default('pending'),
  
  // Generated columns (PostgreSQL)
  fullText: text('full_text').generatedAlwaysAs(
    sql`name || ' ' || email`
  ),
  
  // Identity columns (PostgreSQL)
  autoId: integer('auto_id').generatedAlwaysAsIdentity(),
  
  // Custom default with SQL
  uid: varchar('uid', { length: 36 }).default(sql`gen_random_uuid()`),
  
  // Runtime default
  slug: text('slug').$default(() => generateSlug()),
});
```

#### ❌ Bad: Missing Constraints

```typescript
// No constraints = potential data issues
export const users = pgTable('users', {
  id: serial('id'), // No primary key!
  email: text('email'), // Should be NOT NULL and UNIQUE
  role: text('role'), // Should have a default
});
```

### 1.4 Indexes

Indexes dramatically improve query performance. Define them in the second parameter of table definition.

#### ✅ Good: Strategic Indexing

```typescript
import { pgTable, serial, text, integer, index, uniqueIndex } from 'drizzle-orm/pg-core';

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  slug: text('slug').notNull(),
  userId: integer('user_id').notNull(),
  category: text('category'),
  status: text('status'),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  // Simple index
  titleIdx: index('title_idx').on(table.title),
  
  // Unique index
  slugIdx: uniqueIndex('slug_idx').on(table.slug),
  
  // Composite index (order matters!)
  userCategoryIdx: index('user_category_idx').on(table.userId, table.category),
  
  // Partial index (PostgreSQL)
  publishedIdx: index('published_idx')
    .on(table.status)
    .where(sql`${table.status} = 'published'`),
  
  // Expression index
  lowerEmailIdx: index('lower_email_idx').on(sql`lower(${table.title})`),
}));
```

#### ❌ Bad: Over-indexing or No Indexes

```typescript
// Over-indexing (wastes space and slows writes)
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title'),
  content: text('content'),
  createdAt: timestamp('created_at'),
}, (table) => ({
  titleIdx: index('title_idx').on(table.title),
  contentIdx: index('content_idx').on(table.content), // Large text!
  createdIdx: index('created_idx').on(table.createdAt),
  allIdx: index('all_idx').on(table.title, table.content, table.createdAt), // Too many!
}));

// No indexes on frequently queried columns
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(), // No index on email lookups!
  organizationId: integer('organization_id'), // No index for joins!
});
```

### 1.5 Primary Keys & Foreign Keys

#### ✅ Good: Proper Key Definitions

```typescript
import { pgTable, serial, text, integer, primaryKey, foreignKey } from 'drizzle-orm/pg-core';

// Simple primary key
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull(),
});

// Composite primary key
export const userRoles = pgTable('user_roles', {
  userId: integer('user_id').notNull(),
  roleId: integer('role_id').notNull(),
}, (table) => ({
  pk: primaryKey({ columns: [table.userId, table.roleId] }),
}));

// Foreign key with references
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  userId: integer('user_id')
    .notNull()
    .references(() => users.id, { onDelete: 'cascade' }),
});

// Composite foreign key
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postUserId: integer('post_user_id'),
  postId: integer('post_id'),
}, (table) => ({
  postFk: foreignKey({
    columns: [table.postUserId, table.postId],
    foreignColumns: [posts.userId, posts.id],
  }).onDelete('cascade'),
}));
```

#### Foreign Key Actions

```typescript
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  
  // CASCADE: Delete posts when user is deleted
  userId: integer('user_id')
    .references(() => users.id, { onDelete: 'cascade' }),
  
  // SET NULL: Set to null when referenced row is deleted
  categoryId: integer('category_id')
    .references(() => categories.id, { onDelete: 'set null' }),
  
  // RESTRICT: Prevent deletion if referenced
  organizationId: integer('organization_id')
    .references(() => organizations.id, { onDelete: 'restrict' }),
  
  // NO ACTION: Default behavior (similar to RESTRICT)
  authorId: integer('author_id')
    .references(() => users.id, { onDelete: 'no action' }),
  
  // SET DEFAULT: Set to default value
  statusId: integer('status_id')
    .default(1)
    .references(() => statuses.id, { onDelete: 'set default' }),
});
```

### 1.6 Schema Organization Patterns

#### ✅ Good: Organized Schema Files

```typescript
// Option 1: Single schema file (small projects)
// schema.ts
export const users = pgTable('users', { /* ... */ });
export const posts = pgTable('posts', { /* ... */ });
export const comments = pgTable('comments', { /* ... */ });

// Option 2: Separate files per table (medium projects)
// schema/users.ts
export const users = pgTable('users', { /* ... */ });

// schema/posts.ts
export const posts = pgTable('posts', { /* ... */ });

// schema/index.ts
export * from './users';
export * from './posts';

// Option 3: Grouped by domain (large projects)
// schema/auth/users.ts
// schema/auth/sessions.ts
// schema/blog/posts.ts
// schema/blog/comments.ts
```

#### ✅ Good: Reusable Column Helpers

```typescript
// schema/helpers.ts
import { timestamp, text } from 'drizzle-orm/pg-core';

export const timestamps = {
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
};

export const softDelete = {
  deletedAt: timestamp('deleted_at'),
};

export const auditFields = {
  createdBy: integer('created_by').references(() => users.id),
  updatedBy: integer('updated_by').references(() => users.id),
};

// schema/posts.ts
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title'),
  ...timestamps,
  ...softDelete,
  ...auditFields,
});
```

### 1.7 Enums

#### PostgreSQL Enums

```typescript
import { pgTable, pgEnum, serial, text } from 'drizzle-orm/pg-core';

// Define enum
export const roleEnum = pgEnum('role', ['user', 'admin', 'moderator']);
export const statusEnum = pgEnum('status', ['draft', 'published', 'archived']);

// Use in table
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull(),
  role: roleEnum('role').default('user'),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title'),
  status: statusEnum('status').default('draft'),
});
```

#### MySQL Enums

```typescript
import { mysqlTable, int, mysqlEnum } from 'drizzle-orm/mysql-core';

export const users = mysqlTable('users', {
  id: int('id').primaryKey().autoincrement(),
  role: mysqlEnum('role', ['user', 'admin', 'moderator']).default('user'),
});
```

#### SQLite Type-Safe "Enums"

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

// SQLite doesn't have native enums, use text with $type
export const users = sqliteTable('users', {
  id: integer('id').primaryKey(),
  role: text('role').$type<'user' | 'admin' | 'moderator'>().default('user'),
});
```

### 1.8 Column Naming: Camel vs Snake Case

#### ✅ Good: Automatic Snake Case Mapping

```typescript
// schema.ts
import { pgTable, serial, text } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  firstName: text('first_name'), // Explicit mapping
  lastName: text('last_name'),
});

// db.ts - Automatic mapping
import { drizzle } from 'drizzle-orm/node-postgres';

const db = drizzle({
  connection: process.env.DATABASE_URL,
  casing: 'snake_case', // Auto-converts camelCase to snake_case
});

// Now you can use camelCase in TypeScript
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  firstName: text(), // No need for explicit name!
  lastName: text(),
  emailAddress: text(),
});

// Queries use TypeScript names
await db.select().from(users);
// Generates: SELECT id, first_name, last_name, email_address FROM users
```

### 1.9 Advanced Schema Patterns

#### Self-Referencing Tables

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import type { AnyPgColumn } from 'drizzle-orm/pg-core';

export const categories = pgTable('categories', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  parentId: integer('parent_id').references((): AnyPgColumn => categories.id),
});

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  invitedBy: integer('invited_by').references((): AnyPgColumn => users.id),
});
```

#### Generated Columns

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const products = pgTable('products', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  price: integer('price').notNull(),
  quantity: integer('quantity').notNull(),
  
  // Virtual generated column (computed on read)
  totalValue: integer('total_value').generatedAlwaysAs(
    sql`${products.price} * ${products.quantity}`
  ),
  
  // Stored generated column (computed and stored)
  searchVector: text('search_vector').generatedAlwaysAs(
    sql`to_tsvector('english', ${products.name})`
  ),
});
```

### 1.10 Check Constraints

```typescript
import { pgTable, serial, integer, check } from 'drizzle-orm/pg-core';

export const products = pgTable('products', {
  id: serial('id').primaryKey(),
  price: integer('price').notNull(),
  discountPrice: integer('discount_price'),
  quantity: integer('quantity').notNull(),
}, (table) => ({
  // Price must be positive
  priceCheck: check('price_check', sql`${table.price} > 0`),
  
  // Discount price must be less than regular price
  discountCheck: check('discount_check', 
    sql`${table.discountPrice} IS NULL OR ${table.discountPrice} < ${table.price}`
  ),
  
  // Quantity must be non-negative
  quantityCheck: check('quantity_check', sql`${table.quantity} >= 0`),
}));
```

---

## 2. Relations (Complete Guide)

Relations in Drizzle are defined separately from table schemas using the `relations()` helper. This enables type-safe relational queries without joins.

### 2.1 One-to-Many Relations

The most common relation type where one record relates to many records.

#### ✅ Good: Proper One-to-Many

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Tables
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  userId: integer('user_id')
    .notNull()
    .references(() => users.id),
});

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts), // One user has many posts
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }), // One post belongs to one user
}));

// Usage: Fetch user with all their posts
const userWithPosts = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    posts: true,
  },
});
// Type: { id: number, name: string, posts: Array<{ id: number, title: string, userId: number }> }
```

#### ❌ Bad: Missing Relations or Wrong Setup

```typescript
// Missing the relations definitions
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').references(() => users.id),
});

// No relations defined! Can't use relational queries
// await db.query.users.findFirst({ with: { posts: true } }); // Error!

// Wrong: Defining one-to-many as one-to-one
export const usersRelations = relations(users, ({ one }) => ({
  posts: one(posts, { /* ... */ }), // Wrong! Should be many()
}));
```

### 2.2 One-to-One Relations

One record relates to exactly one other record.

#### ✅ Good: One-to-One Relations

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Tables
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull(),
});

export const profiles = pgTable('profiles', {
  id: serial('id').primaryKey(),
  bio: text('bio'),
  userId: integer('user_id')
    .notNull()
    .unique() // Important: UNIQUE constraint for one-to-one!
    .references(() => users.id),
});

// Relations
export const usersRelations = relations(users, ({ one }) => ({
  profile: one(profiles, {
    fields: [users.id],
    references: [profiles.userId],
  }),
}));

export const profilesRelations = relations(profiles, ({ one }) => ({
  user: one(users, {
    fields: [profiles.userId],
    references: [users.id],
  }),
}));

// Usage
const userWithProfile = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    profile: true,
  },
});
// Type: { id: number, email: string, profile: { id: number, bio: string, userId: number } | null }
```

### 2.3 Many-to-Many Relations

Records on both sides can have multiple related records. Requires a junction/pivot table.

#### ✅ Good: Many-to-Many with Junction Table

```typescript
import { pgTable, serial, text, integer, primaryKey } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Main tables
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
});

export const groups = pgTable('groups', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
});

// Junction table
export const usersToGroups = pgTable('users_to_groups', {
  userId: integer('user_id')
    .notNull()
    .references(() => users.id),
  groupId: integer('group_id')
    .notNull()
    .references(() => groups.id),
}, (table) => ({
  pk: primaryKey({ columns: [table.userId, table.groupId] }),
}));

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  usersToGroups: many(usersToGroups),
}));

export const groupsRelations = relations(groups, ({ many }) => ({
  usersToGroups: many(usersToGroups),
}));

export const usersToGroupsRelations = relations(usersToGroups, ({ one }) => ({
  user: one(users, {
    fields: [usersToGroups.userId],
    references: [users.id],
  }),
  group: one(groups, {
    fields: [usersToGroups.groupId],
    references: [groups.id],
  }),
}));

// Usage
const userWithGroups = await db.query.users.findFirst({
  with: {
    usersToGroups: {
      with: {
        group: true,
      },
    },
  },
});
// Type: { id: number, name: string, usersToGroups: Array<{ userId: number, groupId: number, group: { id: number, name: string } }> }
```

### 2.4 Self-Referencing Relations

A table that references itself (e.g., user invites user, category has parent category).

#### ✅ Good: Self-Referencing Relations

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';
import type { AnyPgColumn } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  invitedBy: integer('invited_by').references((): AnyPgColumn => users.id),
});

export const usersRelations = relations(users, ({ one, many }) => ({
  inviter: one(users, {
    fields: [users.invitedBy],
    references: [users.id],
    relationName: 'inviter', // Important: name the relation!
  }),
  invitees: many(users, {
    relationName: 'inviter',
  }),
}));

// Usage
const userWithInviter = await db.query.users.findFirst({
  with: {
    inviter: true,
    invitees: true,
  },
});
```

### 2.5 Multiple Relations to Same Table

When you need multiple relations between two tables (e.g., post author and reviewer).

#### ✅ Good: Named Relations

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  authorId: integer('author_id').notNull(),
  reviewerId: integer('reviewer_id'),
});

// Relations with explicit names
export const usersRelations = relations(users, ({ many }) => ({
  authoredPosts: many(posts, { relationName: 'author' }),
  reviewedPosts: many(posts, { relationName: 'reviewer' }),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
    relationName: 'author',
  }),
  reviewer: one(users, {
    fields: [posts.reviewerId],
    references: [users.id],
    relationName: 'reviewer',
  }),
}));

// Usage
const postWithAuthorAndReviewer = await db.query.posts.findFirst({
  with: {
    author: true,
    reviewer: true,
  },
});
```

#### ❌ Bad: Ambiguous Relations

```typescript
// Missing relationName causes ambiguity
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts), // Which posts? Authored or reviewed?
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
    // Missing relationName!
  }),
  reviewer: one(users, {
    fields: [posts.reviewerId],
    references: [users.id],
    // Missing relationName!
  }),
}));
```

### 2.6 Circular Dependencies

When tables reference each other, you need to handle circular imports carefully.

#### ✅ Good: Handling Circular Dependencies

```typescript
// users.ts
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';
import { posts } from './posts'; // Import posts table

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  favoritePostId: integer('favorite_post_id'),
});

export const usersRelations = relations(users, ({ one, many }) => ({
  posts: many(posts),
  favoritePost: one(posts, {
    fields: [users.favoritePostId],
    references: [posts.id],
  }),
}));

// posts.ts
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';
import { users } from './users'; // Import users table

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title'),
  userId: integer('user_id'),
});

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));
```

### 2.7 Nested Relations

Query multiple levels of relations in a single query.

#### ✅ Good: Deep Nested Queries

```typescript
// Fetch user with posts, and each post with its comments
const userWithPostsAndComments = await db.query.users.findFirst({
  with: {
    posts: {
      with: {
        comments: {
          with: {
            author: true, // Comment author
          },
        },
      },
    },
  },
});

// Fetch post with author's profile
const postWithAuthorProfile = await db.query.posts.findFirst({
  with: {
    author: {
      with: {
        profile: true,
      },
    },
  },
});
```

### 2.8 Relation Filters

Filter related records in relational queries.

#### ✅ Good: Filtering Relations

```typescript
import { eq, gt } from 'drizzle-orm';

// Get user with only published posts
const userWithPublishedPosts = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    posts: {
      where: eq(posts.status, 'published'),
      orderBy: (posts, { desc }) => [desc(posts.createdAt)],
      limit: 10,
    },
  },
});

// Get posts with comments having more than 5 likes
const postsWithPopularComments = await db.query.posts.findMany({
  with: {
    comments: {
      where: gt(comments.likes, 5),
    },
  },
});
```

---

## 3. Query Builder (Complete Guide)

Drizzle's query builder provides a type-safe, SQL-like syntax for all database operations.

### 3.1 Select Queries

#### Basic Select

```typescript
import { db } from './db';
import { users } from './schema';

// Select all columns
const allUsers = await db.select().from(users);

// Select specific columns
const userEmails = await db
  .select({
    id: users.id,
    email: users.email,
  })
  .from(users);

// Select first record
const firstUser = await db.select().from(users).limit(1);

// Using relational queries
const user = await db.query.users.findFirst({
  where: eq(users.id, 1),
});

const allUsers = await db.query.users.findMany();
```

### 3.2 Filtering with WHERE

#### ✅ Good: Type-Safe Filters

```typescript
import { eq, ne, gt, gte, lt, lte, like, ilike, inArray, isNull, isNotNull, and, or, not, between } from 'drizzle-orm';

// Equality
const user = await db.select().from(users).where(eq(users.id, 1));

// Not equal
const activeUsers = await db.select().from(users).where(ne(users.status, 'deleted'));

// Comparisons
const adults = await db.select().from(users).where(gte(users.age, 18));
const seniors = await db.select().from(users).where(gt(users.age, 65));

// String matching
const gmailUsers = await db.select().from(users).where(like(users.email, '%@gmail.com'));
const iGmailUsers = await db.select().from(users).where(ilike(users.email, '%@GMAIL.COM')); // case-insensitive

// IN clause
const specificUsers = await db.select().from(users).where(inArray(users.id, [1, 2, 3, 4]));

// NULL checks
const usersWithoutBio = await db.select().from(users).where(isNull(users.bio));
const usersWithBio = await db.select().from(users).where(isNotNull(users.bio));

// BETWEEN
const teenAgeUsers = await db.select().from(users).where(between(users.age, 13, 19));

// Combining conditions
const activeAdmins = await db
  .select()
  .from(users)
  .where(
    and(
      eq(users.role, 'admin'),
      eq(users.status, 'active')
    )
  );

const adminsOrModerators = await db
  .select()
  .from(users)
  .where(
    or(
      eq(users.role, 'admin'),
      eq(users.role, 'moderator')
    )
  );

// NOT operator
const nonAdmins = await db.select().from(users).where(not(eq(users.role, 'admin')));
```

#### ❌ Bad: String-Based Queries

```typescript
// DON'T do this - no type safety, SQL injection risk
const users = await db.execute(
  sql`SELECT * FROM users WHERE email = ${email}` // Unsafe!
);
```

### 3.3 Joins

#### ✅ Good: Type-Safe Joins

```typescript
import { eq } from 'drizzle-orm';
import { users, posts, comments } from './schema';

// INNER JOIN
const usersWithPosts = await db
  .select()
  .from(users)
  .innerJoin(posts, eq(users.id, posts.userId));

// LEFT JOIN
const allUsersWithPosts = await db
  .select()
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId));

// RIGHT JOIN
const allPostsWithUsers = await db
  .select()
  .from(users)
  .rightJoin(posts, eq(users.id, posts.userId));

// FULL JOIN (PostgreSQL only)
const fullOuterJoin = await db
  .select()
  .from(users)
  .fullJoin(posts, eq(users.id, posts.userId));

// Multiple joins
const postsWithAuthorsAndComments = await db
  .select()
  .from(posts)
  .innerJoin(users, eq(posts.userId, users.id))
  .leftJoin(comments, eq(posts.id, comments.postId));

// Select specific columns from joins
const customJoin = await db
  .select({
    postId: posts.id,
    postTitle: posts.title,
    authorName: users.name,
    authorEmail: users.email,
  })
  .from(posts)
  .innerJoin(users, eq(posts.userId, users.id));
```

#### ✅ Good: Using Relational Queries (Simpler!)

```typescript
// Instead of manual joins, use relational queries
const postsWithAuthors = await db.query.posts.findMany({
  with: {
    author: true,
  },
});

// Much cleaner than joins!
const postsWithCommentsAndAuthors = await db.query.posts.findMany({
  with: {
    author: true,
    comments: {
      with: {
        author: true,
      },
    },
  },
});
```

### 3.4 Ordering

#### ✅ Good: Order By

```typescript
import { asc, desc, sql } from 'drizzle-orm';

// Ascending order
const usersByNameAsc = await db.select().from(users).orderBy(asc(users.name));

// Descending order
const newestPosts = await db.select().from(posts).orderBy(desc(posts.createdAt));

// Multiple order columns
const sortedUsers = await db
  .select()
  .from(users)
  .orderBy(desc(users.createdAt), asc(users.name));

// Order by expression
const usersByEmailDomain = await db
  .select()
  .from(users)
  .orderBy(sql`split_part(${users.email}, '@', 2)`);

// Relational query ordering
const posts = await db.query.posts.findMany({
  orderBy: (posts, { desc }) => [desc(posts.createdAt)],
});
```

### 3.5 Pagination

#### ✅ Good: Limit & Offset

```typescript
// Limit
const first10Users = await db.select().from(users).limit(10);

// Offset
const usersPage2 = await db.select().from(users).limit(10).offset(10);

// Pagination helper
async function getPaginatedUsers(page: number, pageSize: number = 10) {
  const offset = (page - 1) * pageSize;
  
  const results = await db
    .select()
    .from(users)
    .limit(pageSize)
    .offset(offset)
    .orderBy(desc(users.createdAt));
  
  const [{ count }] = await db
    .select({ count: sql<number>`count(*)` })
    .from(users);
  
  return {
    data: results,
    total: count,
    page,
    pageSize,
    totalPages: Math.ceil(count / pageSize),
  };
}

// Usage
const page1 = await getPaginatedUsers(1, 20);
```

#### ✅ Good: Cursor-Based Pagination (Better for Performance)

```typescript
import { gt, desc } from 'drizzle-orm';

async function getCursorPaginatedPosts(cursor?: number, limit: number = 20) {
  const query = db
    .select()
    .from(posts)
    .orderBy(desc(posts.id))
    .limit(limit + 1); // Fetch one extra to check if there's a next page
  
  if (cursor) {
    query.where(gt(posts.id, cursor));
  }
  
  const results = await query;
  const hasNextPage = results.length > limit;
  const data = hasNextPage ? results.slice(0, -1) : results;
  const nextCursor = hasNextPage ? data[data.length - 1].id : null;
  
  return {
    data,
    nextCursor,
    hasNextPage,
  };
}

// Usage
const firstPage = await getCursorPaginatedPosts();
const secondPage = await getCursorPaginatedPosts(firstPage.nextCursor);
```

### 3.6 Aggregations

#### ✅ Good: Aggregate Functions

```typescript
import { sql, count, sum, avg, min, max } from 'drizzle-orm';

// COUNT
const [{ userCount }] = await db
  .select({ userCount: count() })
  .from(users);

// COUNT with condition
const [{ activeUsers }] = await db
  .select({ activeUsers: count() })
  .from(users)
  .where(eq(users.status, 'active'));

// COUNT DISTINCT
const [{ uniqueEmails }] = await db
  .select({ uniqueEmails: sql<number>`count(distinct ${users.email})` })
  .from(users);

// SUM
const [{ totalRevenue }] = await db
  .select({ totalRevenue: sum(orders.amount) })
  .from(orders);

// AVG
const [{ avgAge }] = await db
  .select({ avgAge: avg(users.age) })
  .from(users);

// MIN & MAX
const [{ oldestUser, youngestUser }] = await db
  .select({
    oldestUser: max(users.age),
    youngestUser: min(users.age),
  })
  .from(users);

// GROUP BY with aggregation
const postCountsByUser = await db
  .select({
    userId: posts.userId,
    postCount: count(),
  })
  .from(posts)
  .groupBy(posts.userId);

// HAVING clause
const activeAuthors = await db
  .select({
    userId: posts.userId,
    postCount: count(),
  })
  .from(posts)
  .groupBy(posts.userId)
  .having(({ postCount }) => gt(postCount, 5));
```

### 3.7 Subqueries

#### ✅ Good: Using Subqueries

```typescript
import { sql } from 'drizzle-orm';

// Subquery in SELECT
const usersWithPostCount = await db
  .select({
    id: users.id,
    name: users.name,
    postCount: sql<number>`(
      SELECT COUNT(*)
      FROM ${posts}
      WHERE ${posts.userId} = ${users.id}
    )`,
  })
  .from(users);

// Subquery with .as()
const averagePostCount = db
  .select({ avg: sql<number>`avg(post_count)` })
  .from(
    db
      .select({ postCount: count().as('post_count') })
      .from(posts)
      .groupBy(posts.userId)
      .as('post_counts')
  );

// Subquery in WHERE
const activeUsersSubquery = db
  .select({ id: users.id })
  .from(users)
  .where(eq(users.status, 'active'));

const postsFromActiveUsers = await db
  .select()
  .from(posts)
  .where(inArray(posts.userId, activeUsersSubquery));
```

### 3.8 Distinct

```typescript
// SELECT DISTINCT
const uniqueCategories = await db.selectDistinct({ category: posts.category }).from(posts);

// DISTINCT ON (PostgreSQL only)
const latestPostPerCategory = await db
  .selectDistinctOn([posts.category], {
    category: posts.category,
    title: posts.title,
    createdAt: posts.createdAt,
  })
  .from(posts)
  .orderBy(posts.category, desc(posts.createdAt));
```

---

## 4. Mutations (Complete Guide)

### 4.1 Insert

#### ✅ Good: Inserting Data

```typescript
// Insert single record
const newUser = await db.insert(users).values({
  name: 'John Doe',
  email: 'john@example.com',
}).returning();

// Insert multiple records
const newUsers = await db.insert(users).values([
  { name: 'Alice', email: 'alice@example.com' },
  { name: 'Bob', email: 'bob@example.com' },
]).returning();

// Insert with specific columns returned
const user = await db.insert(users).values({
  name: 'Jane',
  email: 'jane@example.com',
}).returning({ id: users.id, email: users.email });

// Insert without returning (faster for MySQL/SQLite)
await db.insert(users).values({ name: 'Test', email: 'test@example.com' });
```

#### ❌ Bad: Missing Required Fields

```typescript
// Error: email is NOT NULL
await db.insert(users).values({
  name: 'John',
  // email is missing!
});
```

### 4.2 Update

#### ✅ Good: Updating Records

```typescript
// Update with WHERE
await db
  .update(users)
  .set({ name: 'John Updated' })
  .where(eq(users.id, 1));

// Update multiple fields
await db
  .update(users)
  .set({
    name: 'John Doe',
    email: 'newemail@example.com',
    updatedAt: new Date(),
  })
  .where(eq(users.id, 1));

// Update with returning
const updatedUser = await db
  .update(users)
  .set({ name: 'Updated Name' })
  .where(eq(users.id, 1))
  .returning();

// Increment value
await db
  .update(posts)
  .set({ views: sql`${posts.views} + 1` })
  .where(eq(posts.id, 1));

// Update based on another column
await db
  .update(products)
  .set({ finalPrice: sql`${products.price} * 0.9` }) // 10% discount
  .where(eq(products.onSale, true));
```

#### ❌ Bad: Update Without WHERE

```typescript
// Dangerous: Updates ALL records!
await db.update(users).set({ role: 'admin' });
// Always use WHERE clause unless you really want to update everything
```

### 4.3 Delete

#### ✅ Good: Deleting Records

```typescript
// Delete with WHERE
await db.delete(users).where(eq(users.id, 1));

// Delete with multiple conditions
await db
  .delete(users)
  .where(
    and(
      eq(users.status, 'inactive'),
      lt(users.lastLogin, sql`NOW() - INTERVAL '1 year'`)
    )
  );

// Delete with returning
const deletedUsers = await db
  .delete(users)
  .where(eq(users.status, 'deleted'))
  .returning();

// Soft delete (recommended)
await db
  .update(users)
  .set({ deletedAt: new Date() })
  .where(eq(users.id, 1));
```

#### ❌ Bad: Delete Without WHERE

```typescript
// Catastrophic: Deletes ALL records!
await db.delete(users);
// Always use WHERE clause
```

### 4.4 Upsert (Insert or Update)

#### ✅ Good: Upsert Operations

```typescript
// PostgreSQL: ON CONFLICT DO UPDATE
await db
  .insert(users)
  .values({ email: 'test@example.com', name: 'Test User' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'Updated Name' },
  });

// MySQL: ON DUPLICATE KEY UPDATE
await db
  .insert(users)
  .values({ email: 'test@example.com', name: 'Test' })
  .onDuplicateKeyUpdate({ set: { name: 'Updated' } });

// SQLite: ON CONFLICT DO UPDATE
await db
  .insert(users)
  .values({ email: 'test@example.com', name: 'Test' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: sql`excluded.name` },
  });

// Upsert with condition
await db
  .insert(users)
  .values({ email: 'test@example.com', name: 'Test', version: 1 })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: sql`excluded.name`, version: sql`${users.version} + 1` },
    where: sql`${users.version} < excluded.version`,
  });
```

### 4.5 Batch Operations

#### ✅ Good: Efficient Batch Inserts

```typescript
// Batch insert
const userData = Array.from({ length: 1000 }, (_, i) => ({
  name: `User ${i}`,
  email: `user${i}@example.com`,
}));

await db.insert(users).values(userData);

// Batch insert in chunks (for very large datasets)
async function batchInsert<T>(data: T[], chunkSize: number = 500) {
  for (let i = 0; i < data.length; i += chunkSize) {
    const chunk = data.slice(i, i + chunkSize);
    await db.insert(users).values(chunk);
  }
}

await batchInsert(userData, 500);
```

### 4.6 Transactions

#### ✅ Good: Using Transactions

```typescript
// Basic transaction
await db.transaction(async (tx) => {
  const user = await tx.insert(users).values({ name: 'John', email: 'john@example.com' }).returning();
  
  await tx.insert(profiles).values({
    userId: user[0].id,
    bio: 'Hello world',
  });
  
  // If any query fails, all changes are rolled back
});

// Transaction with error handling
try {
  await db.transaction(async (tx) => {
    await tx.update(accounts).set({ balance: sql`${accounts.balance} - 100` }).where(eq(accounts.id, 1));
    await tx.update(accounts).set({ balance: sql`${accounts.balance} + 100` }).where(eq(accounts.id, 2));
  });
} catch (error) {
  console.error('Transaction failed:', error);
}

// Manual transaction control
const tx = await db.transaction(async (tx) => {
  return tx; // Return transaction object
});

try {
  await tx.insert(users).values({ name: 'Test' });
  await tx.commit();
} catch (error) {
  await tx.rollback();
}
```

---

## 5. Migrations (Complete Guide)

Drizzle Kit provides multiple migration strategies to fit your workflow.

### 5.1 Setup & Configuration

#### drizzle.config.ts

```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts', // Path to schema
  out: './drizzle', // Output folder for migrations
  dialect: 'postgresql', // 'postgresql' | 'mysql' | 'sqlite'
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### 5.2 Migration Commands

#### Generate Migrations

```bash
# Generate SQL migration files from schema changes
bun drizzle-kit generate

# Generate with custom name
bun drizzle-kit generate --name add_users_table
```

#### Push Schema

```bash
# Push schema changes directly to database (no migration files)
bun drizzle-kit push

# Best for: Development, prototyping
```

#### Apply Migrations

```bash
# Apply pending migrations to database
bun drizzle-kit migrate

# Best for: Production deployments
```

#### Pull Schema

```bash
# Pull existing database schema to TypeScript
bun drizzle-kit pull

# Best for: Database-first workflows
```

### 5.3 Migration Workflow Options

#### Option 1: Push (Rapid Development)

✅ Best for: Solo development, prototyping, non-production

```typescript
// 1. Update schema.ts
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  email: text('email').unique(), // Added column
});

// 2. Push to database
// $ bun drizzle-kit push
```

#### Option 2: Generate + Migrate (Team Development)

✅ Best for: Team projects, production, version control

```bash
# 1. Update schema
# 2. Generate migration
$ bun drizzle-kit generate

# 3. Review generated SQL
# drizzle/0001_add_email_column.sql

# 4. Apply migration
$ bun drizzle-kit migrate
```

#### Option 3: Runtime Migrations

✅ Best for: Serverless, containerized apps

```typescript
// migrate.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const db = drizzle(pool);

async function runMigrations() {
  await migrate(db, { migrationsFolder: './drizzle' });
  await pool.end();
}

runMigrations();
```

### 5.4 Migration File Structure

```
📂 drizzle/
├── 📂 0000_initial_schema/
│   ├── snapshot.json
│   └── migration.sql
├── 📂 0001_add_users_table/
│   ├── snapshot.json
│   └── migration.sql
└── 📂 0002_add_email_column/
    ├── snapshot.json
    └── migration.sql
```

### 5.5 Custom Migrations

#### Adding Custom SQL

```typescript
// After generating migration, edit the .sql file

-- drizzle/0003_custom_function.sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### 5.6 Migration Best Practices

#### ✅ Good Migration Practices

```typescript
// 1. Always review generated migrations before applying
// 2. Test migrations on staging first
// 3. Backup database before migrations
// 4. Use transactions for migration scripts

// 5. Handle renames properly
// When renaming, Drizzle will ask:
// "Is 'new_column' a rename of 'old_column'? (y/n)"
// Answer correctly to avoid data loss

// 6. Make migrations reversible when possible

-- Up migration
ALTER TABLE users ADD COLUMN email TEXT;

-- Down migration (for rollbacks)
ALTER TABLE users DROP COLUMN email;
```

#### ❌ Bad Migration Practices

```typescript
// DON'T:
// - Skip migration testing
// - Manually edit snapshot.json files
// - Delete migration files after applying
// - Run migrations without backups
// - Mix push and generate workflows
```

---

## 6. TypeScript Integration

### 6.1 Inferred Types

#### ✅ Good: Type Inference

```typescript
import { InferSelectModel, InferInsertModel } from 'drizzle-orm';
import { users } from './schema';

// Infer select type (what you get from DB)
type User = InferSelectModel<typeof users>;
// { id: number, name: string | null, email: string }

// Infer insert type (what you insert)
type NewUser = InferInsertModel<typeof users>;
// { id?: number, name?: string | null, email: string }

// Use in functions
function createUser(data: NewUser): Promise<User> {
  return db.insert(users).values(data).returning();
}

function getUser(id: number): Promise<User | undefined> {
  return db.query.users.findFirst({ where: eq(users.id, id) });
}
```

### 6.2 Type-Safe Queries

```typescript
// TypeScript knows the shape of the result
const user = await db.query.users.findFirst({
  columns: {
    id: true,
    email: true,
    // name: true, // Can uncomment to include
  },
});
// Type: { id: number, email: string } | undefined

// With relations
const userWithPosts = await db.query.users.findFirst({
  with: {
    posts: {
      columns: {
        id: true,
        title: true,
      },
    },
  },
});
// Type: { id: number, name: string | null, email: string, posts: Array<{ id: number, title: string }> }
```

### 6.3 Zod Integration

#### ✅ Good: Schema Validation with Zod

```typescript
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { users } from './schema';

// Auto-generate Zod schemas
const insertUserSchema = createInsertSchema(users);
const selectUserSchema = createSelectSchema(users);

// Refine schemas
const customInsertUserSchema = createInsertSchema(users, {
  email: (schema) => schema.email.email(),
  name: (schema) => schema.name.min(2).max(50),
});

// Use in API validation
async function createUser(data: unknown) {
  const validatedData = customInsertUserSchema.parse(data);
  return db.insert(users).values(validatedData).returning();
}
```

### 6.4 Type Safety Benefits

```typescript
// ✅ TypeScript catches errors at compile time
const user = await db.select().from(users).where(eq(users.id, '1'));
// Error: Type 'string' is not assignable to type 'number'

// ✅ Autocomplete for columns
const result = await db.select({
  id: users.id,
  email: users.email,
  // TypeScript suggests: name, id, email, etc.
}).from(users);

// ✅ Type-safe joins
const data = await db
  .select({
    userName: users.name,
    postTitle: posts.title,
  })
  .from(users)
  .innerJoin(posts, eq(users.id, posts.userId));
// Type: Array<{ userName: string | null, postTitle: string }>
```

---

## Resources

- **Official Docs**: https://orm.drizzle.team
- **GitHub**: https://github.com/drizzle-team/drizzle-orm
- **Discord**: https://driz.link/discord
- **Examples**: https://github.com/drizzle-team/drizzle-orm/tree/main/examples

---

**End of Drizzle ORM Skill**
