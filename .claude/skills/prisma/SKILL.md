---
name: prisma
description: Use when user mentions Prisma, schema.prisma, database models, or Prisma migrations. Expert in Prisma ORM including schema design, migrations, query optimization, and relations.
category: database
---

# Prisma ORM Best Practices

**Official Prisma guidelines - Schema, Migrations, Relations, Queries, Transactions**

## Core Principles

1. **ALWAYS Use Type-Safe Queries** - Prisma Client generates fully typed queries from your schema
2. **Schema as Single Source of Truth** - Define models in `schema.prisma`, not directly in database
3. **Migrations for Production** - Use `prisma migrate deploy` in production, never `db push`
4. **Explicit Relation Tables** - Prefer explicit many-to-many over implicit for metadata control
5. **Index Foreign Keys** - Always add indexes on foreign key columns for query performance
6. **Avoid N+1 Queries** - Use `include` or `select` to fetch relations in a single query

## Schema Definition - Complete Guide

### Data Sources

#### ✅ Good: PostgreSQL Configuration with Connection Pooling
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  directUrl = env("DIRECT_DATABASE_URL") // For migrations, bypasses pooler
}

generator client {
  provider = "prisma-client-js"
  previewFeatures = ["fullTextSearch", "postgresqlExtensions"]
}

// Connection string format:
// DATABASE_URL="postgresql://user:password@host:5432/dbname?schema=public&connection_limit=5"
// DIRECT_DATABASE_URL="postgresql://user:password@host:5432/dbname?schema=public"
```

#### ✅ Good: Multiple Database Support
```prisma
// PostgreSQL (recommended for production)
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// MySQL
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// SQLite (development/testing)
datasource db {
  provider = "sqlite"
  url      = "file:./dev.db"
}

// MongoDB
datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}
```

#### ❌ Bad: Hardcoded Credentials
```prisma
// ❌ NEVER hardcode database credentials
datasource db {
  provider = "postgresql"
  url      = "postgresql://admin:password123@localhost:5432/mydb"
}
```

#### ❌ Bad: No Connection Pooling Configuration
```prisma
// ❌ Missing connection_limit for serverless environments
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL") // No ?connection_limit=5
}

// Results in connection pool exhaustion in serverless/edge functions
```

### Generators

#### ✅ Good: Prisma Client with Preview Features
```prisma
generator client {
  provider = "prisma-client-js"
  output   = "./generated/client"
  previewFeatures = [
    "fullTextSearch",
    "postgresqlExtensions",
    "views",
    "relationJoins"
  ]
}
```

#### ✅ Good: Multiple Generators
```prisma
generator client {
  provider = "prisma-client-js"
}

generator json {
  provider = "prisma-json-types-generator"
}

generator docs {
  provider = "prisma-docs-generator"
  output   = "./docs/db"
}
```

#### ❌ Bad: Missing Generator
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ❌ No generator = no Prisma Client!
```

### Models - Complete Field Types

#### ✅ Good: Complete User Model
```prisma
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  name          String?
  role          Role      @default(USER)
  profileViews  Int       @default(0)
  balance       Decimal   @default(0) @db.Decimal(10, 2)
  isActive      Boolean   @default(true)
  metadata      Json?
  avatar        Bytes?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  lastLoginAt   DateTime?
  
  // Relations
  profile       Profile?
  posts         Post[]
  comments      Comment[]
  
  // Indexes
  @@index([email])
  @@index([createdAt])
  @@map("users")
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

**Field Types Reference**:
- `String` - Variable length text (VARCHAR)
- `Int` - 32-bit integer
- `BigInt` - 64-bit integer
- `Float` - Floating point number
- `Decimal` - Precise decimal (for money)
- `Boolean` - true/false
- `DateTime` - Timestamp with timezone
- `Json` - JSON data
- `Bytes` - Binary data
- `Unsupported("type")` - Native database type

#### ✅ Good: Field Attributes
```prisma
model Product {
  id          String   @id @default(uuid())
  sku         String   @unique
  name        String   @db.VarChar(255)
  slug        String   @unique @db.VarChar(100)
  price       Decimal  @db.Decimal(10, 2)
  quantity    Int      @default(0)
  isAvailable Boolean  @default(true)
  tags        String[] // Array type (PostgreSQL only)
  metadata    Json?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  categoryId  String
  category    Category @relation(fields: [categoryId], references: [id], onDelete: Cascade)
  
  @@index([categoryId])
  @@index([sku])
  @@index([slug])
  @@map("products")
}
```

**Key Attributes**:
- `@id` - Primary key
- `@default()` - Default value (now(), uuid(), cuid(), autoincrement())
- `@unique` - Unique constraint
- `@map("column_name")` - Custom database column name
- `@@map("table_name")` - Custom database table name
- `@db.VarChar(255)` - Native database type
- `@updatedAt` - Auto-update on record change
- `?` - Optional field (nullable)

#### ✅ Good: Composite Primary Key and Unique Constraints
```prisma
model UserRole {
  userId    String
  roleId    String
  grantedAt DateTime @default(now())
  grantedBy String
  
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  role Role @relation(fields: [roleId], references: [id], onDelete: Cascade)
  
  @@id([userId, roleId])
  @@index([roleId])
  @@map("user_roles")
}

model Post {
  id       String @id @default(uuid())
  title    String
  slug     String
  tenantId String
  
  @@unique([slug, tenantId]) // Composite unique constraint
  @@index([tenantId])
}
```

#### ❌ Bad: Missing Constraints
```prisma
model User {
  // ❌ No @id attribute
  email    String
  name     String
  password String // ❌ Should be hashed, consider storing hash only
}

model Post {
  id       String @id
  // ❌ No @default() for id - manual ID generation required
  title    String
  authorId String
  // ❌ No foreign key relation defined
  // ❌ No indexes on foreign keys
}
```

#### ❌ Bad: Inappropriate Default Values
```prisma
model Order {
  id        String   @id @default(uuid())
  total     Decimal  @default(0) // ❌ Should be calculated, not defaulted
  status    String   @default("pending") // ❌ Use enum instead
  createdAt DateTime // ❌ Missing @default(now())
}
```

### Enums

#### ✅ Good: Enum Definition and Usage
```prisma
enum UserStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
  DELETED
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

enum PaymentMethod {
  CREDIT_CARD
  DEBIT_CARD
  PAYPAL
  CRYPTO
  BANK_TRANSFER
}

model User {
  id     String     @id @default(uuid())
  email  String     @unique
  status UserStatus @default(ACTIVE)
  
  @@map("users")
}

model Order {
  id            String        @id @default(uuid())
  status        OrderStatus   @default(PENDING)
  paymentMethod PaymentMethod
  
  @@index([status])
  @@map("orders")
}
```

#### ❌ Bad: String Instead of Enum
```prisma
model User {
  // ❌ No type safety, allows any string value
  status String @default("active")
  
  // ✅ Should be:
  // status UserStatus @default(ACTIVE)
}
```

#### ❌ Bad: Boolean Cascade Instead of Enum
```prisma
model Order {
  // ❌ Hard to extend, poor readability
  isPending    Boolean @default(true)
  isProcessing Boolean @default(false)
  isShipped    Boolean @default(false)
  isDelivered  Boolean @default(false)
  
  // ✅ Should be:
  // status OrderStatus @default(PENDING)
}
```

## Relations - Complete Guide

### One-to-One Relations

#### ✅ Good: User ↔ Profile (One-to-One)
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  profile   Profile? // Optional: user may not have profile yet
  createdAt DateTime @default(now())
  
  @@map("users")
}

model Profile {
  id        String   @id @default(uuid())
  bio       String?
  avatar    String?
  userId    String   @unique // Required: profile must belong to user
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  
  @@map("profiles")
}
```

**Key Points**:
- `userId` field stores the foreign key
- `@unique` on `userId` enforces one-to-one
- `@relation(fields: [userId], references: [id])` connects them
- `onDelete: Cascade` deletes profile when user is deleted
- `profile Profile?` is optional on User side
- `user User` is required on Profile side

#### ✅ Good: Bidirectional Optional One-to-One
```prisma
model User {
  id        String         @id @default(uuid())
  email     String         @unique
  settings  UserSettings?
}

model UserSettings {
  id                String  @id @default(uuid())
  theme             String  @default("light")
  emailNotifications Boolean @default(true)
  userId            String  @unique
  user              User    @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

#### ❌ Bad: Missing @unique on Foreign Key
```prisma
model User {
  id      String   @id @default(uuid())
  profile Profile?
}

model Profile {
  id     String @id @default(uuid())
  userId String // ❌ Missing @unique - this creates one-to-many, not one-to-one!
  user   User   @relation(fields: [userId], references: [id])
}
```

#### ❌ Bad: Both Sides Optional
```prisma
model User {
  id      String   @id @default(uuid())
  profile Profile?
}

model Profile {
  id     String  @id @default(uuid())
  userId String? @unique // ❌ Profile can exist without user - breaks data integrity
  user   User?   @relation(fields: [userId], references: [id])
}
```

### One-to-Many Relations

#### ✅ Good: User ↔ Posts (One-to-Many)
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  posts     Post[]   // One user has many posts
  createdAt DateTime @default(now())
  
  @@map("users")
}

model Post {
  id          String   @id @default(uuid())
  title       String
  content     String
  published   Boolean  @default(false)
  authorId    String   // Foreign key to User
  author      User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@index([authorId])
  @@index([published])
  @@map("posts")
}
```

#### ✅ Good: Category ↔ Products with Referential Actions
```prisma
model Category {
  id       String    @id @default(uuid())
  name     String    @unique
  slug     String    @unique
  products Product[]
  
  @@map("categories")
}

model Product {
  id         String   @id @default(uuid())
  name       String
  price      Decimal  @db.Decimal(10, 2)
  categoryId String
  category   Category @relation(fields: [categoryId], references: [id], onDelete: Restrict)
  // onDelete: Restrict prevents category deletion if it has products
  
  @@index([categoryId])
  @@map("products")
}
```

**Referential Actions**:
- `Cascade` - Delete related records
- `Restrict` - Prevent deletion if relations exist
- `NoAction` - Database handles it (default)
- `SetNull` - Set foreign key to null
- `SetDefault` - Set foreign key to default value

#### ❌ Bad: Missing Foreign Key Index
```prisma
model Post {
  id       String @id @default(uuid())
  title    String
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
  
  // ❌ Missing @@index([authorId])
  // Queries filtering/joining on authorId will be slow!
}
```

#### ❌ Bad: Wrong Relation Direction
```prisma
model User {
  id       String @id @default(uuid())
  postIds  String[] // ❌ WRONG - arrays of IDs don't work this way
}

model Post {
  id    String @id @default(uuid())
  title String
  // ❌ Missing author relation
}

// ✅ Correct: Foreign key should be on Post (many side), not User (one side)
```

### Many-to-Many Relations

#### ✅ Good: Explicit Many-to-Many (Recommended)
```prisma
model Post {
  id        String     @id @default(uuid())
  title     String
  content   String
  tags      PostTag[]  // Join table
  createdAt DateTime   @default(now())
  
  @@map("posts")
}

model Tag {
  id    String    @id @default(uuid())
  name  String    @unique
  slug  String    @unique
  posts PostTag[] // Join table
  
  @@map("tags")
}

// Explicit join table with metadata
model PostTag {
  id         String   @id @default(uuid())
  postId     String
  tagId      String
  addedAt    DateTime @default(now())
  addedById  String
  
  post   Post @relation(fields: [postId], references: [id], onDelete: Cascade)
  tag    Tag  @relation(fields: [tagId], references: [id], onDelete: Cascade)
  addedBy User @relation(fields: [addedById], references: [id])
  
  @@unique([postId, tagId]) // Prevent duplicate tags on same post
  @@index([postId])
  @@index([tagId])
  @@map("post_tags")
}
```

**Why Explicit?**:
- ✅ Store metadata (when, who added)
- ✅ Add additional fields
- ✅ Full control over indexes
- ✅ Composite unique constraints

#### ✅ Good: Implicit Many-to-Many (Simple Cases)
```prisma
model Post {
  id         String     @id @default(uuid())
  title      String
  categories Category[]
  
  @@map("posts")
}

model Category {
  id    String @id @default(uuid())
  name  String @unique
  posts Post[]
  
  @@map("categories")
}

// Prisma creates implicit join table: _CategoryToPost
// Works only with single @id fields (no composite IDs)
```

#### ✅ Good: Many-to-Many with Self-Relations
```prisma
model User {
  id         String   @id @default(uuid())
  email      String   @unique
  name       String
  
  // Self-relation for followers
  following  Follow[] @relation("UserFollowing")
  followers  Follow[] @relation("UserFollowers")
  
  @@map("users")
}

model Follow {
  id          String   @id @default(uuid())
  followerId  String
  followingId String
  createdAt   DateTime @default(now())
  
  follower  User @relation("UserFollowers", fields: [followerId], references: [id], onDelete: Cascade)
  following User @relation("UserFollowing", fields: [followingId], references: [id], onDelete: Cascade)
  
  @@unique([followerId, followingId])
  @@index([followerId])
  @@index([followingId])
  @@map("follows")
}
```

#### ❌ Bad: Missing Indexes on Join Table
```prisma
model PostTag {
  postId String
  tagId  String
  
  post Post @relation(fields: [postId], references: [id])
  tag  Tag  @relation(fields: [tagId], references: [id])
  
  @@id([postId, tagId])
  // ❌ Missing indexes! Queries will be slow
  
  // ✅ Should have:
  // @@index([postId])
  // @@index([tagId])
}
```

#### ❌ Bad: Implicit Many-to-Many with Composite IDs
```prisma
model Post {
  id       String
  tenantId String
  tags     Tag[] // ❌ Won't work with composite ID
  
  @@id([id, tenantId])
}

model Tag {
  id    String @id
  posts Post[]
}

// ✅ Must use explicit join table with composite IDs
```

## Migrations - Complete Workflow

### Development Workflow

#### ✅ Good: Development Migration Flow
```bash
# 1. Update schema.prisma with model changes
# 2. Create and apply migration
npx prisma migrate dev --name add_user_roles

# What it does:
# - Creates SQL migration file in prisma/migrations/
# - Applies migration to development database
# - Regenerates Prisma Client
# - Prompts for data loss warnings

# 3. Review migration file
cat prisma/migrations/20240115_add_user_roles/migration.sql
```

#### ✅ Good: Migration File Structure
```
prisma/
├── schema.prisma
└── migrations/
    ├── 20240115120000_init/
    │   └── migration.sql
    ├── 20240116093000_add_user_roles/
    │   └── migration.sql
    └── migration_lock.toml
```

#### ✅ Good: Reviewing Generated Migration
```sql
-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN', 'MODERATOR');

-- AlterTable
ALTER TABLE "users" ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'USER';

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");
```

#### ❌ Bad: Using `db push` in Development (After Initial Setup)
```bash
# ❌ WRONG - No migration history, can't track changes
npx prisma db push

# ✅ CORRECT - Creates migration file
npx prisma migrate dev --name describe_change
```

**When to use `db push`**:
- ✅ Early prototyping (schema is volatile)
- ✅ First-time setup experiments
- ❌ Never in production
- ❌ Not for permanent schema changes

#### ❌ Bad: Not Reviewing Migrations Before Committing
```bash
# ❌ Blindly accepting migration without review
npx prisma migrate dev --name update_schema
git add .
git commit -m "Updated schema"

# ✅ Always review migration.sql first!
npx prisma migrate dev --name update_schema
cat prisma/migrations/<timestamp>_update_schema/migration.sql
# Review for data loss, performance issues
git add prisma/migrations
git commit -m "feat: add user roles table"
```

### Production Workflow

#### ✅ Good: Production Migration Deployment
```bash
# In CI/CD pipeline or production server

# 1. Deploy new code with migration files
# 2. Run migration (does NOT create new migrations)
npx prisma migrate deploy

# What it does:
# - Applies pending migrations from prisma/migrations/
# - Does NOT prompt for data loss
# - Does NOT create new migrations
# - Fails if migrations conflict with database state

# 3. Generate Prisma Client (if not in postinstall)
npx prisma generate
```

#### ✅ Good: CI/CD Pipeline Example (GitHub Actions)
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run migrations
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: npx prisma migrate deploy
      
      - name: Generate Prisma Client
        run: npx prisma generate
      
      - name: Deploy application
        run: npm run deploy
```

#### ✅ Good: Handling Migration Failures in Production
```bash
# Check migration status
npx prisma migrate status

# If migration is in failed state
# Option 1: Fix database manually, then mark as applied
npx prisma migrate resolve --applied "20240115_migration_name"

# Option 2: Roll back database manually, then mark as rolled back
npx prisma migrate resolve --rolled-back "20240115_migration_name"

# Then try again
npx prisma migrate deploy
```

#### ❌ Bad: Running `migrate dev` in Production
```bash
# ❌ NEVER in production - can cause data loss!
npx prisma migrate dev

# ✅ ONLY use in production:
npx prisma migrate deploy
```

#### ❌ Bad: Manual Database Changes in Production
```sql
-- ❌ WRONG - Changes database without Prisma knowing
ALTER TABLE users ADD COLUMN age INT;

-- ✅ CORRECT - Update schema.prisma, create migration locally,
-- commit migration file, deploy via CI/CD
```

### Customizing Migrations

#### ✅ Good: Create Empty Migration for Data Changes
```bash
# Create migration file without applying
npx prisma migrate dev --create-only --name backfill_user_slugs

# Edit migration file to add custom SQL
```

**Migration File**: `prisma/migrations/20240115_backfill_user_slugs/migration.sql`
```sql
-- AlterTable
ALTER TABLE "users" ADD COLUMN "slug" VARCHAR(100);

-- Custom: Backfill slugs from usernames
UPDATE "users"
SET "slug" = LOWER(REPLACE("username", ' ', '-'))
WHERE "slug" IS NULL;

-- AlterTable
ALTER TABLE "users" ALTER COLUMN "slug" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "users_slug_key" ON "users"("slug");
```

```bash
# Apply the customized migration
npx prisma migrate dev
```

#### ✅ Good: Complex Data Migration
```sql
-- Migration: Convert user roles from string to enum

-- 1. Create enum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN', 'MODERATOR');

-- 2. Add new column
ALTER TABLE "users" ADD COLUMN "role_new" "UserRole";

-- 3. Migrate data
UPDATE "users" SET "role_new" = 'ADMIN' WHERE "role_old" = 'admin';
UPDATE "users" SET "role_new" = 'MODERATOR' WHERE "role_old" = 'moderator';
UPDATE "users" SET "role_new" = 'USER' WHERE "role_new" IS NULL;

-- 4. Make new column required
ALTER TABLE "users" ALTER COLUMN "role_new" SET NOT NULL;
ALTER TABLE "users" ALTER COLUMN "role_new" SET DEFAULT 'USER'::"UserRole";

-- 5. Drop old column
ALTER TABLE "users" DROP COLUMN "role_old";

-- 6. Rename new column
ALTER TABLE "users" RENAME COLUMN "role_new" TO "role";
```

#### ❌ Bad: Breaking Migration Without Data Handling
```sql
-- ❌ This will fail if users table has data!
ALTER TABLE "users" ADD COLUMN "email" VARCHAR(255) NOT NULL;

-- ✅ Correct approach:
ALTER TABLE "users" ADD COLUMN "email" VARCHAR(255);
UPDATE "users" SET "email" = CONCAT("username", '@example.com') WHERE "email" IS NULL;
ALTER TABLE "users" ALTER COLUMN "email" SET NOT NULL;
```

### Migration Commands Reference

```bash
# Development
prisma migrate dev                 # Create and apply migration
prisma migrate dev --name <name>   # With descriptive name
prisma migrate dev --create-only   # Create without applying
prisma migrate reset               # Reset DB and apply all migrations (DESTRUCTIVE!)

# Production
prisma migrate deploy              # Apply pending migrations
prisma migrate status              # Check migration status
prisma migrate resolve --applied "migration_name"
prisma migrate resolve --rolled-back "migration_name"

# Utilities
prisma migrate diff                # Preview changes
prisma db push                     # Prototype schema (no migration files)
prisma db pull                     # Introspect database to schema.prisma
prisma db seed                     # Run seed script
```

## Prisma Client Queries - Complete Reference

### CRUD Operations

#### ✅ Good: Create Operations
```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// Create single record
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    name: 'Alice',
    role: 'USER',
  },
})

// Create with relations
const userWithProfile = await prisma.user.create({
  data: {
    email: 'bob@prisma.io',
    name: 'Bob',
    profile: {
      create: {
        bio: 'Software engineer',
        avatar: 'https://example.com/avatar.jpg',
      },
    },
    posts: {
      create: [
        { title: 'First Post', content: 'Hello World' },
        { title: 'Second Post', content: 'Prisma is great!' },
      ],
    },
  },
  include: {
    profile: true,
    posts: true,
  },
})

// Create many (bulk insert)
const users = await prisma.user.createMany({
  data: [
    { email: 'user1@example.com', name: 'User 1' },
    { email: 'user2@example.com', name: 'User 2' },
    { email: 'user3@example.com', name: 'User 3' },
  ],
  skipDuplicates: true, // Skip records with unique constraint violations
})

console.log(`Created ${users.count} users`)
```

#### ✅ Good: Read Operations
```typescript
// Find unique by ID
const user = await prisma.user.findUnique({
  where: { id: 'user_id' },
})

// Find unique by unique field
const userByEmail = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' },
})

// Find unique or throw error
const userOrThrow = await prisma.user.findUniqueOrThrow({
  where: { email: 'alice@prisma.io' },
})

// Find first matching record
const firstAdmin = await prisma.user.findFirst({
  where: { role: 'ADMIN' },
  orderBy: { createdAt: 'desc' },
})

// Find many
const allUsers = await prisma.user.findMany()

const activeUsers = await prisma.user.findMany({
  where: { isActive: true },
  orderBy: { createdAt: 'desc' },
  take: 10,
})

// Select specific fields
const usersWithSelect = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
    _count: {
      select: { posts: true },
    },
  },
})

// Include relations
const usersWithPosts = await prisma.user.findMany({
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
    profile: true,
  },
})
```

#### ✅ Good: Update Operations
```typescript
// Update single record
const updatedUser = await prisma.user.update({
  where: { id: 'user_id' },
  data: {
    name: 'Alice Smith',
    profileViews: { increment: 1 },
  },
})

// Update many
const result = await prisma.user.updateMany({
  where: {
    email: { endsWith: '@oldcompany.com' },
  },
  data: {
    email: { set: null }, // Set field to null
    isActive: false,
  },
})

console.log(`Updated ${result.count} users`)

// Upsert (update or create)
const upsertedUser = await prisma.user.upsert({
  where: { email: 'alice@prisma.io' },
  update: {
    name: 'Alice Updated',
    profileViews: { increment: 1 },
  },
  create: {
    email: 'alice@prisma.io',
    name: 'Alice',
  },
})

// Update with nested writes
const userWithNewPost = await prisma.user.update({
  where: { id: 'user_id' },
  data: {
    posts: {
      create: {
        title: 'New Post',
        content: 'Content here',
      },
    },
  },
  include: {
    posts: true,
  },
})
```

#### ✅ Good: Delete Operations
```typescript
// Delete single record
const deletedUser = await prisma.user.delete({
  where: { id: 'user_id' },
})

// Delete many
const result = await prisma.user.deleteMany({
  where: {
    createdAt: {
      lt: new Date('2020-01-01'),
    },
    posts: {
      none: {}, // Users with no posts
    },
  },
})

console.log(`Deleted ${result.count} users`)

// Delete all (be careful!)
await prisma.user.deleteMany({})
```

#### ❌ Bad: Not Handling Errors
```typescript
// ❌ No error handling - app will crash on constraint violation
const user = await prisma.user.create({
  data: {
    email: 'duplicate@example.com', // Email already exists!
  },
})

// ✅ Proper error handling
try {
  const user = await prisma.user.create({
    data: {
      email: 'duplicate@example.com',
    },
  })
} catch (error) {
  if (error.code === 'P2002') {
    console.error('Email already exists')
  }
  throw error
}
```

### Filtering and Sorting

#### ✅ Good: Filter Operators
```typescript
// Equals
const users = await prisma.user.findMany({
  where: {
    email: 'alice@prisma.io',
    role: 'ADMIN',
  },
})

// String filters
const filtered = await prisma.user.findMany({
  where: {
    email: {
      endsWith: '@prisma.io',
      not: { contains: 'spam' },
    },
    name: {
      startsWith: 'A',
      mode: 'insensitive', // Case-insensitive
    },
  },
})

// Number filters
const products = await prisma.product.findMany({
  where: {
    price: {
      gte: 10, // Greater than or equal
      lte: 100, // Less than or equal
    },
    quantity: {
      gt: 0, // Greater than
      not: 5, // Not equal to 5
    },
  },
})

// Date filters
const recentPosts = await prisma.post.findMany({
  where: {
    createdAt: {
      gte: new Date('2024-01-01'),
      lt: new Date('2024-02-01'),
    },
  },
})

// Null checks
const usersWithoutProfile = await prisma.user.findMany({
  where: {
    profile: {
      is: null,
    },
  },
})

// Array filters (PostgreSQL)
const posts = await prisma.post.findMany({
  where: {
    tags: {
      has: 'typescript',
      hasEvery: ['typescript', 'prisma'],
      hasSome: ['react', 'vue', 'angular'],
    },
  },
})
```

#### ✅ Good: Logical Operators
```typescript
// AND (implicit)
const users = await prisma.user.findMany({
  where: {
    isActive: true,
    role: 'ADMIN',
  },
})

// AND (explicit)
const usersExplicitAnd = await prisma.user.findMany({
  where: {
    AND: [
      { isActive: true },
      { role: 'ADMIN' },
      { profileViews: { gte: 100 } },
    ],
  },
})

// OR
const usersOr = await prisma.user.findMany({
  where: {
    OR: [
      { email: { endsWith: '@prisma.io' } },
      { role: 'ADMIN' },
    ],
  },
})

// NOT
const usersNot = await prisma.user.findMany({
  where: {
    NOT: {
      email: { endsWith: '@spam.com' },
    },
  },
})

// Complex combination
const complexFilter = await prisma.user.findMany({
  where: {
    AND: [
      {
        OR: [
          { email: { endsWith: '@prisma.io' } },
          { role: 'ADMIN' },
        ],
      },
      {
        isActive: true,
      },
      {
        NOT: {
          email: { contains: 'spam' },
        },
      },
    ],
  },
})
```

#### ✅ Good: Relation Filters
```typescript
// Users with at least one published post
const usersWithPosts = await prisma.user.findMany({
  where: {
    posts: {
      some: {
        published: true,
      },
    },
  },
})

// Users with all posts published
const usersAllPublished = await prisma.user.findMany({
  where: {
    posts: {
      every: {
        published: true,
      },
    },
  },
})

// Users with no posts
const usersNoPosts = await prisma.user.findMany({
  where: {
    posts: {
      none: {},
    },
  },
})

// Nested relation filters
const posts = await prisma.post.findMany({
  where: {
    author: {
      email: { endsWith: '@prisma.io' },
      profile: {
        isNot: null,
      },
    },
    comments: {
      some: {
        content: { contains: 'great' },
      },
    },
  },
})
```

#### ✅ Good: Sorting (orderBy)
```typescript
// Single field
const users = await prisma.user.findMany({
  orderBy: {
    createdAt: 'desc',
  },
})

// Multiple fields
const sortedUsers = await prisma.user.findMany({
  orderBy: [
    { role: 'asc' },
    { createdAt: 'desc' },
  ],
})

// Sort by relation count
const usersByPostCount = await prisma.user.findMany({
  orderBy: {
    posts: {
      _count: 'desc',
    },
  },
})

// Sort by relation field
const posts = await prisma.post.findMany({
  orderBy: {
    author: {
      name: 'asc',
    },
  },
})
```

#### ❌ Bad: Over-fetching Data
```typescript
// ❌ Fetching all fields when only needing a few
const users = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
    comments: true,
  },
})

// ✅ Select only what you need
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
  },
})
```

### Pagination

#### ✅ Good: Offset Pagination
```typescript
const pageSize = 10
const page = 2

const users = await prisma.user.findMany({
  skip: (page - 1) * pageSize,
  take: pageSize,
  orderBy: { createdAt: 'desc' },
})

// Get total count for pagination UI
const totalUsers = await prisma.user.count()
const totalPages = Math.ceil(totalUsers / pageSize)
```

#### ✅ Good: Cursor-Based Pagination (Recommended for Performance)
```typescript
// First page
const firstPage = await prisma.user.findMany({
  take: 10,
  orderBy: { id: 'asc' },
})

// Next page using last item as cursor
const lastUser = firstPage[firstPage.length - 1]
const nextPage = await prisma.user.findMany({
  take: 10,
  skip: 1, // Skip the cursor itself
  cursor: {
    id: lastUser.id,
  },
  orderBy: { id: 'asc' },
})

// Previous page
const firstUserOfPage = nextPage[0]
const previousPage = await prisma.user.findMany({
  take: -10, // Negative take for backwards pagination
  skip: 1,
  cursor: {
    id: firstUserOfPage.id,
  },
  orderBy: { id: 'asc' },
})
```

#### ❌ Bad: Loading All Records for Pagination
```typescript
// ❌ Terrible performance - loads ALL records into memory!
const allUsers = await prisma.user.findMany()
const page = allUsers.slice((page - 1) * pageSize, page * pageSize)

// ✅ Let database handle pagination
const page = await prisma.user.findMany({
  skip: (pageNumber - 1) * pageSize,
  take: pageSize,
})
```

### Aggregations

#### ✅ Good: Count, Sum, Avg, Min, Max
```typescript
// Count all records
const userCount = await prisma.user.count()

// Count with filters
const adminCount = await prisma.user.count({
  where: { role: 'ADMIN' },
})

// Aggregations
const stats = await prisma.product.aggregate({
  _count: { id: true },
  _sum: { quantity: true },
  _avg: { price: true },
  _min: { price: true },
  _max: { price: true },
  where: {
    isAvailable: true,
  },
})

console.log(`Total products: ${stats._count.id}`)
console.log(`Total quantity: ${stats._sum.quantity}`)
console.log(`Average price: ${stats._avg.price}`)
console.log(`Min price: ${stats._min.price}`)
console.log(`Max price: ${stats._max.price}`)

// Group by
const ordersByStatus = await prisma.order.groupBy({
  by: ['status'],
  _count: { id: true },
  _sum: { total: true },
  orderBy: {
    _count: {
      id: 'desc',
    },
  },
})

// Group by multiple fields
const salesByCategory = await prisma.product.groupBy({
  by: ['categoryId', 'isAvailable'],
  _count: { id: true },
  _sum: { quantity: true },
  having: {
    quantity: {
      _sum: {
        gt: 100,
      },
    },
  },
})
```

## Transactions

### Sequential Transactions

#### ✅ Good: $transaction Array Syntax
```typescript
// All queries must succeed, or all fail (atomic)
const [deletedPosts, deletedUser] = await prisma.$transaction([
  prisma.post.deleteMany({ where: { authorId: userId } }),
  prisma.user.delete({ where: { id: userId } }),
])

// Transfer money between accounts
const [senderUpdate, receiverUpdate] = await prisma.$transaction([
  prisma.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  }),
  prisma.account.update({
    where: { id: receiverId },
    data: { balance: { increment: amount } },
  }),
])
```

#### ❌ Bad: Operations Without Transaction
```typescript
// ❌ NOT atomic - if second operation fails, first still committed!
await prisma.account.update({
  where: { id: senderId },
  data: { balance: { decrement: amount } },
})

// If this fails, money disappeared!
await prisma.account.update({
  where: { id: receiverId },
  data: { balance: { increment: amount } },
})

// ✅ Use transaction
```

### Interactive Transactions

#### ✅ Good: $transaction Callback Syntax
```typescript
// Complex logic with conditional queries
const result = await prisma.$transaction(async (tx) => {
  // Get current balance
  const sender = await tx.account.findUnique({
    where: { id: senderId },
  })

  if (!sender || sender.balance < amount) {
    throw new Error('Insufficient funds')
  }

  // Deduct from sender
  const updatedSender = await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  })

  // Add to receiver
  const updatedReceiver = await tx.account.update({
    where: { id: receiverId },
    data: { balance: { increment: amount } },
  })

  // Create transaction record
  const transactionRecord = await tx.transaction.create({
    data: {
      fromId: senderId,
      toId: receiverId,
      amount: amount,
      status: 'COMPLETED',
    },
  })

  return { sender: updatedSender, receiver: updatedReceiver, transaction: transactionRecord }
})
```

#### ✅ Good: Transaction Isolation Levels
```typescript
import { Prisma } from '@prisma/client'

// Serializable isolation
const result = await prisma.$transaction(
  async (tx) => {
    // Critical operations here
    const account = await tx.account.findUnique({ where: { id } })
    return account
  },
  {
    isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
    maxWait: 5000, // Max wait time to acquire connection (ms)
    timeout: 10000, // Max time transaction can run (ms)
  }
)
```

#### ❌ Bad: Long-Running Transactions
```typescript
// ❌ Holding transaction open during external API call
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } })
  
  // ❌ External API call inside transaction!
  const emailSent = await sendEmail(user.email) // Takes 5+ seconds
  
  await tx.user.update({
    where: { id },
    data: { emailSent: true },
  })
})

// ✅ Move external calls outside transaction
const user = await prisma.user.findUnique({ where: { id } })
await sendEmail(user.email)
await prisma.user.update({
  where: { id },
  data: { emailSent: true },
})
```

### Nested Writes

#### ✅ Good: Create with Nested Relations
```typescript
// Create user with profile and posts in single operation
const user = await prisma.user.create({
  data: {
    email: 'bob@example.com',
    name: 'Bob',
    profile: {
      create: {
        bio: 'Developer',
        avatar: 'https://example.com/avatar.jpg',
      },
    },
    posts: {
      create: [
        {
          title: 'First Post',
          content: 'Hello',
          tags: {
            connectOrCreate: [
              {
                where: { name: 'typescript' },
                create: { name: 'typescript', slug: 'typescript' },
              },
            ],
          },
        },
      ],
    },
  },
  include: {
    profile: true,
    posts: {
      include: {
        tags: true,
      },
    },
  },
})
```

## Performance Optimization

### Indexes

#### ✅ Good: Strategic Index Placement
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  username  String   @unique
  role      Role     @default(USER)
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  
  posts Post[]
  
  // Composite index for common query pattern
  @@index([role, isActive])
  @@index([createdAt])
  @@map("users")
}

model Post {
  id          String   @id @default(uuid())
  title       String
  slug        String
  published   Boolean  @default(false)
  publishedAt DateTime?
  authorId    String
  categoryId  String
  
  author   User     @relation(fields: [authorId], references: [id])
  category Category @relation(fields: [categoryId], references: [id])
  
  // Single-column indexes on foreign keys
  @@index([authorId])
  @@index([categoryId])
  
  // Composite index for common queries
  @@index([published, publishedAt])
  @@index([categoryId, published])
  
  // Unique constraint on slug per author
  @@unique([slug, authorId])
  @@map("posts")
}
```

#### ❌ Bad: No Indexes on Foreign Keys
```prisma
model Post {
  id       String @id @default(uuid())
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
  
  // ❌ Missing @@index([authorId])
  // Queries joining User and Post will be slow!
}
```

#### ❌ Bad: Over-Indexing
```prisma
model User {
  id        String @id
  email     String @unique
  firstName String
  lastName  String
  
  // ❌ Too many indexes slow down writes
  @@index([firstName])
  @@index([lastName])
  @@index([firstName, lastName])
  @@index([lastName, firstName])
  // Only create indexes for actual query patterns!
}
```

### Connection Pooling

#### ✅ Good: Connection Pool Configuration
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // connection_limit in URL: postgresql://...?connection_limit=10&pool_timeout=20
}
```

```typescript
// Singleton pattern for Prisma Client (Next.js/serverless)
import { PrismaClient } from '@prisma/client'

const globalForPrisma = global as unknown as { prisma: PrismaClient }

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

#### ❌ Bad: Creating New Client Per Request
```typescript
// ❌ Connection pool exhaustion!
export async function GET() {
  const prisma = new PrismaClient() // ❌ New client every request!
  const users = await prisma.user.findMany()
  return Response.json(users)
}

// ✅ Reuse singleton client
import { prisma } from '@/lib/prisma'

export async function GET() {
  const users = await prisma.user.findMany()
  return Response.json(users)
}
```

### Query Optimization

#### ✅ Good: Select Only Needed Fields
```typescript
// ✅ Select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true,
  },
})

// ✅ Avoid N+1 with include
const usersWithPosts = await prisma.user.findMany({
  include: {
    posts: {
      where: { published: true },
      select: {
        id: true,
        title: true,
      },
    },
  },
})
```

#### ❌ Bad: N+1 Query Problem
```typescript
// ❌ N+1 queries - 1 query for users, then N queries for posts
const users = await prisma.user.findMany()

for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id },
  })
  console.log(`${user.name} has ${posts.length} posts`)
}

// ✅ Single query with include
const users = await prisma.user.findMany({
  include: {
    _count: {
      select: { posts: true },
    },
  },
})
```

### Batch Operations

#### ✅ Good: Using Batch Operations
```typescript
// Bulk create
await prisma.user.createMany({
  data: [
    { email: 'user1@example.com', name: 'User 1' },
    { email: 'user2@example.com', name: 'User 2' },
  ],
})

// Bulk update
await prisma.user.updateMany({
  where: { isActive: false },
  data: { deletedAt: new Date() },
})

// Bulk delete
await prisma.user.deleteMany({
  where: { createdAt: { lt: new Date('2020-01-01') } },
})
```

#### ❌ Bad: Individual Operations in Loop
```typescript
// ❌ Slow - individual database round trips
for (const email of emails) {
  await prisma.user.create({
    data: { email, name: email.split('@')[0] },
  })
}

// ✅ Batch operation
await prisma.user.createMany({
  data: emails.map(email => ({
    email,
    name: email.split('@')[0],
  })),
})
```

## TypeScript Integration

### Generated Types

#### ✅ Good: Using Prisma-Generated Types
```typescript
import { Prisma, User, Post, Role } from '@prisma/client'

// Model types
const user: User = {
  id: '1',
  email: 'alice@prisma.io',
  name: 'Alice',
  role: 'ADMIN',
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date(),
}

// CreateInput types
const userCreateInput: Prisma.UserCreateInput = {
  email: 'bob@prisma.io',
  name: 'Bob',
  posts: {
    create: {
      title: 'My Post',
      content: 'Content',
    },
  },
}

// UpdateInput types
const userUpdateInput: Prisma.UserUpdateInput = {
  name: 'Bob Updated',
  profileViews: { increment: 1 },
}

// WhereInput types
const userWhereInput: Prisma.UserWhereInput = {
  role: 'ADMIN',
  posts: {
    some: {
      published: true,
    },
  },
}

// Type-safe function
async function getUserByEmail(email: string): Promise<User | null> {
  return prisma.user.findUnique({ where: { email } })
}
```

#### ✅ Good: Prisma.validator for Custom Types
```typescript
import { Prisma } from '@prisma/client'

// Create reusable query snippets
const userWithPosts = Prisma.validator<Prisma.UserDefaultArgs>()({
  include: {
    posts: {
      include: {
        tags: true,
      },
    },
  },
})

// Get type from validator
type UserWithPosts = Prisma.UserGetPayload<typeof userWithPosts>

// Use in functions
async function getUserWithPosts(id: string): Promise<UserWithPosts | null> {
  return prisma.user.findUnique({
    where: { id },
    ...userWithPosts,
  })
}
```

#### ✅ Good: Custom Return Types
```typescript
import { Prisma } from '@prisma/client'

// Type for user with post count
const userWithPostCount = Prisma.validator<Prisma.UserDefaultArgs>()({
  select: {
    id: true,
    email: true,
    name: true,
    _count: {
      select: {
        posts: true,
      },
    },
  },
})

type UserWithPostCount = Prisma.UserGetPayload<typeof userWithPostCount>

const users: UserWithPostCount[] = await prisma.user.findMany(userWithPostCount)
```

#### ❌ Bad: Losing Type Safety
```typescript
// ❌ Using 'any' defeats Prisma's type safety
async function getUser(id: string): Promise<any> {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ Proper typing
async function getUser(id: string): Promise<User | null> {
  return prisma.user.findUnique({ where: { id } })
}
```

## Best Practices

### Schema Organization
- ✅ Group related models together
- ✅ Use consistent naming (camelCase for fields, PascalCase for models)
- ✅ Add `@@map()` for database table names (snake_case)
- ✅ Always define foreign key indexes
- ✅ Use enums for fixed value sets
- ❌ Don't use abbreviations in model names

### Migration Workflow
- ✅ Always review generated migration SQL
- ✅ Customize migrations for data transformations
- ✅ Commit migration files to version control
- ✅ Use `migrate deploy` in production
- ✅ Test migrations on staging before production
- ❌ Never run `migrate dev` in production
- ❌ Don't modify applied migration files

### Error Handling
- ✅ Handle Prisma error codes (P2002, P2025, etc.)
- ✅ Wrap database operations in try-catch
- ✅ Use transactions for multi-step operations
- ✅ Validate input before database queries
- ❌ Don't expose raw Prisma errors to users

### Testing Strategies
- ✅ Use separate test database
- ✅ Reset database between tests
- ✅ Mock Prisma Client in unit tests
- ✅ Use transactions for test isolation
- ✅ Seed test data consistently

### Seeding Data
```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Delete existing data
  await prisma.post.deleteMany()
  await prisma.user.deleteMany()

  // Create seed data
  const alice = await prisma.user.create({
    data: {
      email: 'alice@prisma.io',
      name: 'Alice',
      posts: {
        create: [
          {
            title: 'First Post',
            content: 'This is my first post',
            published: true,
          },
        ],
      },
    },
  })

  console.log({ alice })
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

```json
// package.json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

### Environment-Specific Configurations
```bash
# .env.development
DATABASE_URL="postgresql://user:password@localhost:5432/dev_db"

# .env.test
DATABASE_URL="postgresql://user:password@localhost:5432/test_db"

# .env.production
DATABASE_URL="postgresql://user:password@prod-host:5432/prod_db?connection_limit=10"
DIRECT_DATABASE_URL="postgresql://user:password@prod-host:5432/prod_db"
```

## Additional Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/orm/reference/prisma-schema-reference)
- [Prisma Client API Reference](https://www.prisma.io/docs/orm/reference/prisma-client-reference)
- [Prisma Migrate Reference](https://www.prisma.io/docs/orm/prisma-migrate)
- [Prisma Error Reference](https://www.prisma.io/docs/orm/reference/error-reference)
