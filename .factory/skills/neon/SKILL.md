---
name: neon
description: Auto-activates when user mentions Neon, serverless Postgres, or database branching. Expert in Neon Postgres including branching, connection pooling, and performance optimization.
category: database
---

# Neon Serverless Postgres Best Practices

## Core Principles

1. **Database Branching** - Create branches for dev/preview environments instantly
2. **Serverless Driver** - Use Neon's serverless driver for HTTP/WebSocket connections
3. **Autoscaling** - Leverage scale-to-zero for cost savings
4. **Connection Pooling** - Built-in PgBouncer for connection management
5. **Branching Workflows** - Git-like workflows for your database

## Database Branching

### ✅ Good: Create Branch for Development
```bash
# Install Neon CLI
npm install -g neonctl

# Authenticate
neonctl auth

# Create a development branch
neonctl branches create --name dev/feature-auth

# Get connection string
neonctl connection-string dev/feature-auth

# Reset branch to match parent (like git reset)
neonctl branches reset dev/feature-auth

# Delete branch when done
neonctl branches delete dev/feature-auth
```

### ✅ Good: Preview Environment per PR
```typescript
// .github/workflows/preview.yml
name: Deploy Preview

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Create Neon Branch
        id: create-branch
        run: |
          BRANCH_NAME="preview/pr-${{ github.event.pull_request.number }}"
          neonctl branches create --name $BRANCH_NAME --parent main
          CONNECTION_STRING=$(neonctl connection-string $BRANCH_NAME)
          echo "DATABASE_URL=$CONNECTION_STRING" >> $GITHUB_OUTPUT
        env:
          NEON_API_KEY: ${{ secrets.NEON_API_KEY }}
      
      - name: Run Migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ steps.create-branch.outputs.DATABASE_URL }}
      
      - name: Deploy to Vercel
        run: vercel deploy --build-env DATABASE_URL="${{ steps.create-branch.outputs.DATABASE_URL }}"
```

## Serverless Driver Usage

### ✅ Good: Neon Serverless Driver Setup
```typescript
// lib/db.ts
import { neon, neonConfig, Pool } from '@neondatabase/serverless';
import ws from 'ws';

// Configure for local development
if (process.env.NODE_ENV === 'development') {
  // Use local Neon proxy for development
  const connectionString = 'postgres://postgres:postgres@db.localtest.me:5432/main';
  
  neonConfig.fetchEndpoint = (host) => {
    const [protocol, port] = host === 'db.localtest.me' ? ['http', 4444] : ['https', 443];
    return `${protocol}://${host}:${port}/sql`;
  };
  
  neonConfig.useSecureWebSocket = connectionString.hostname !== 'db.localtest.me';
  neonConfig.wsProxy = (host) => (host === 'db.localtest.me' ? `${host}:4444/v2` : `${host}/v2`);
}

// For environments without WebSocket support (like Node.js)
neonConfig.webSocketConstructor = ws;

// HTTP Client (for serverless functions/edge)
export const sql = neon(process.env.DATABASE_URL!);

// WebSocket Client (for long-running servers)
export const pool = new Pool({ connectionString: process.env.DATABASE_URL });
```

### ✅ Good: Query with HTTP Client
```typescript
// Best for: Serverless functions, Edge Runtime, one-off queries
import { sql } from '@/lib/db';

export async function getUsers() {
  // SQL template tag prevents SQL injection
  const users = await sql`
    SELECT id, name, email 
    FROM users 
    WHERE active = ${true}
    ORDER BY created_at DESC
    LIMIT 10
  `;
  
  return users;
}

// Dynamic WHERE clause
export async function searchUsers(query: string) {
  const users = await sql`
    SELECT id, name, email
    FROM users
    WHERE name ILIKE ${'%' + query + '%'}
       OR email ILIKE ${'%' + query + '%'}
  `;
  
  return users;
}
```

### ✅ Good: Connection Pool Client
```typescript
// Best for: Long-running servers, multiple sequential queries
import { pool } from '@/lib/db';

export async function createUserWithProfile(email: string, name: string) {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const userResult = await client.query(
      'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id',
      [email, name]
    );
    
    const userId = userResult.rows[0].id;
    
    await client.query(
      'INSERT INTO profiles (user_id, bio) VALUES ($1, $2)',
      [userId, 'New user']
    );
    
    await client.query('COMMIT');
    
    return userId;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
```

## With Prisma

### ✅ Good: Prisma with Neon Serverless
```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';
import { Pool, neon, neonConfig } from '@neondatabase/serverless';
import { PrismaNeon } from '@prisma/adapter-neon';
import ws from 'ws';

neonConfig.webSocketConstructor = ws;

const connectionString = process.env.DATABASE_URL!;

// Use Neon serverless driver as Prisma adapter
const pool = new Pool({ connectionString });
const adapter = new PrismaNeon(pool);

export const prisma = new PrismaClient({ adapter });

// Usage
const users = await prisma.user.findMany({
  where: { active: true },
  include: { posts: true }
});
```

## With Drizzle ORM

### ✅ Good: Drizzle with Neon
```typescript
// lib/db.ts
import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql);

// schema.ts
import { pgTable, serial, text, timestamp, boolean } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  active: boolean('active').default(true).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// queries.ts
import { db } from './db';
import { users } from './schema';
import { eq } from 'drizzle-orm';

export async function getUser(id: number) {
  const [user] = await db
    .select()
    .from(users)
    .where(eq(users.id, id))
    .limit(1);
  
  return user;
}

export async function createUser(email: string, name: string) {
  const [user] = await db
    .insert(users)
    .values({ email, name })
    .returning();
  
  return user;
}
```

## Local Development

### ✅ Good: Docker Compose for Local Neon
```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:17
    command: '-d 1'
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=main
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 10s
      timeout: 5s
      retries: 5

  neon-proxy:
    image: ghcr.io/timowilhelm/local-neon-http-proxy:main
    environment:
      - PG_CONNECTION_STRING=postgres://postgres:postgres@postgres:5432/main
    ports:
      - '4444:4444'
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  db_data:
```

```bash
# Start local Postgres + Neon Proxy
docker-compose up -d

# Use local connection string
# DATABASE_URL=postgres://postgres:postgres@db.localtest.me:5432/main
```

## Branching Workflows

### ✅ Good: Branch per Feature
```bash
#!/bin/bash
# scripts/create-dev-branch.sh

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ./create-dev-branch.sh <feature-name>"
  exit 1
fi

BRANCH_NAME="dev/$FEATURE_NAME"

# Create Neon branch
echo "Creating Neon branch: $BRANCH_NAME"
neonctl branches create --name $BRANCH_NAME --parent main

# Get connection string
CONNECTION_STRING=$(neonctl connection-string $BRANCH_NAME)

# Update .env.local
echo "DATABASE_URL=\"$CONNECTION_STRING\"" > .env.local

echo "✅ Branch created! Connection string saved to .env.local"
echo ""
echo "To delete when done:"
echo "  neonctl branches delete $BRANCH_NAME"
```

### ✅ Good: Schema-only Branch
```bash
# Create branch with schema but no data
neonctl branches create \
  --name dev/schema-test \
  --parent main \
  --type schema-only

# Run migrations on empty database
npx prisma migrate deploy

# Test with fresh data
```

## Preview Environments with Vercel Integration

### ✅ Good: Automatic Branch per PR (GitHub Actions)
```yaml
# .github/workflows/preview.yml
name: Create Preview Environment

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  create-preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Create Neon Branch
        id: create-branch
        uses: neondatabase/create-branch-action@v5
        with:
          project_id: ${{ secrets.NEON_PROJECT_ID }}
          branch_name: preview/pr-${{ github.event.pull_request.number }}
          api_key: ${{ secrets.NEON_API_KEY }}
          username: ${{ secrets.NEON_DB_USER }}
      
      - name: Run Migrations
        run: |
          npm install
          npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ steps.create-branch.outputs.db_url_with_pooler }}
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--build-env DATABASE_URL="${{ steps.create-branch.outputs.db_url_with_pooler }}"'
      
      - name: Comment PR with Preview URL
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `✅ Preview environment ready!\n\n**Database:** \`preview/pr-${{ github.event.pull_request.number }}\`\n**Branch:** ${{ steps.create-branch.outputs.branch_id }}`
            })
```

### ✅ Good: Cleanup on PR Close
```yaml
# .github/workflows/cleanup-preview.yml
name: Delete Preview Environment

on:
  pull_request:
    types: [closed]

jobs:
  delete-preview:
    runs-on: ubuntu-latest
    steps:
      - name: Delete Neon Branch
        uses: neondatabase/delete-branch-action@v3
        with:
          project_id: ${{ secrets.NEON_PROJECT_ID }}
          branch: preview/pr-${{ github.event.pull_request.number }}
          api_key: ${{ secrets.NEON_API_KEY }}
      
      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '🗑️ Preview environment deleted.'
            })
```

### ✅ Good: Vercel + Neon Integration (vercel.json)
```json
{
  "build": {
    "env": {
      "DATABASE_URL": "@database_url"
    }
  },
  "env": {
    "DATABASE_URL": "@database_url"
  },
  "git": {
    "deploymentEnabled": {
      "main": true
    }
  }
}
```

### ❌ Bad: Shared Database for All Previews
```yaml
# ❌ WRONG - All preview environments share production database
- name: Deploy to Vercel
  env:
    DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}  # Dangerous!
```

## Schema Diff & Comparison

### ✅ Good: Compare Schemas Between Branches
```bash
# Install Neon CLI
npm install -g neonctl

# Compare dev branch to main
neonctl branches schema-diff \
  --project-id $PROJECT_ID \
  --branch dev/feature \
  --compare-to main

# Output shows SQL differences
# DROP TABLE old_table;
# CREATE TABLE new_table (...);
# ALTER TABLE users ADD COLUMN email_verified BOOLEAN;
```

### ✅ Good: Schema Diff in CI (GitHub Actions)
```yaml
# .github/workflows/schema-diff.yml
name: Schema Diff on PR

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  schema-diff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Get Schema Diff
        uses: neondatabase/schema-diff-action@v1
        id: schema-diff
        with:
          project_id: ${{ secrets.NEON_PROJECT_ID }}
          branch: preview/pr-${{ github.event.pull_request.number }}
          compare_to: main
          api_key: ${{ secrets.NEON_API_KEY }}
      
      - name: Comment Schema Changes
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🗄️ Schema Changes\n\n\`\`\`sql\n${{ steps.schema-diff.outputs.diff }}\n\`\`\``
            })
```

### ✅ Good: Detect Schema Drift
```typescript
// scripts/check-schema-drift.ts
import { neon } from '@neondatabase/serverless';

async function checkSchemaDrift() {
  const mainDb = neon(process.env.MAIN_DATABASE_URL!);
  const branchDb = neon(process.env.BRANCH_DATABASE_URL!);

  // Get table names from both databases
  const mainTables = await mainDb`
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public'
    ORDER BY tablename
  `;

  const branchTables = await branchDb`
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public'
    ORDER BY tablename
  `;

  const mainTableNames = mainTables.map(t => t.tablename);
  const branchTableNames = branchTables.map(t => t.tablename);

  // Find differences
  const addedTables = branchTableNames.filter(t => !mainTableNames.includes(t));
  const removedTables = mainTableNames.filter(t => !branchTableNames.includes(t));

  if (addedTables.length > 0 || removedTables.length > 0) {
    console.log('⚠️ Schema drift detected!');
    if (addedTables.length > 0) {
      console.log('Added tables:', addedTables);
    }
    if (removedTables.length > 0) {
      console.log('Removed tables:', removedTables);
    }
    process.exit(1);
  }

  console.log('✅ No schema drift detected');
}

checkSchemaDrift().catch(console.error);
```

## Migration Workflows with Branching

### ✅ Good: Test Migrations on Branch First
```bash
#!/bin/bash
# scripts/safe-migration.sh

# 1. Create a test branch
echo "Creating test branch..."
neonctl branches create --name test/migration-$(date +%s) --parent main

# 2. Get connection string
TEST_DB=$(neonctl connection-string test/migration-$(date +%s))

# 3. Run migrations on test branch
echo "Running migrations on test branch..."
DATABASE_URL=$TEST_DB npx prisma migrate deploy

# 4. Verify migrations worked
echo "Testing migrations..."
DATABASE_URL=$TEST_DB npm test

# 5. If tests pass, apply to main
if [ $? -eq 0 ]; then
  echo "✅ Migrations successful! Applying to main..."
  DATABASE_URL=$MAIN_DB npx prisma migrate deploy
  
  # 6. Cleanup test branch
  neonctl branches delete test/migration-$(date +%s)
else
  echo "❌ Migration failed! Check test branch for issues"
  exit 1
fi
```

### ✅ Good: Zero-Downtime Migration Strategy
```typescript
// migrations/add-email-verified.ts
import { neon } from '@neondatabase/serverless';

async function migrateWithZeroDowntime() {
  const sql = neon(process.env.DATABASE_URL!);

  // Step 1: Add column as nullable
  await sql`
    ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS email_verified BOOLEAN
  `;

  // Step 2: Backfill data
  await sql`
    UPDATE users 
    SET email_verified = (email IS NOT NULL)
    WHERE email_verified IS NULL
  `;

  // Step 3: Make NOT NULL after backfill
  await sql`
    ALTER TABLE users 
    ALTER COLUMN email_verified SET NOT NULL
  `;

  // Step 4: Add default for new rows
  await sql`
    ALTER TABLE users 
    ALTER COLUMN email_verified SET DEFAULT false
  `;

  console.log('✅ Migration complete with zero downtime');
}

migrateWithZeroDowntime().catch(console.error);
```

### ❌ Bad: Risky Direct Migration on Production
```bash
# ❌ WRONG - No testing, direct to production
DATABASE_URL=$PRODUCTION_DB npx prisma migrate deploy
# What if it fails? No rollback plan!
```

## Rollback Strategies

### ✅ Good: Point-in-Time Recovery (PITR)
```bash
# Restore database to specific timestamp
neonctl branches restore \
  --project-id $PROJECT_ID \
  --branch main \
  --timestamp "2024-01-15 10:30:00"

# Or restore to before a bad migration
neonctl branches restore \
  --project-id $PROJECT_ID \
  --branch main \
  --lsn "0/1A2B3C4D"  # Log Sequence Number
```

### ✅ Good: Create Backup Branch Before Migration
```bash
# Before risky migration, create backup
neonctl branches create \
  --name backup/before-migration-$(date +%s) \
  --parent main

# Run migration on main
npx prisma migrate deploy

# If migration fails, reset main to backup
neonctl branches reset main --parent backup/before-migration-*
```

### ✅ Good: Blue-Green Deployment with Branches
```bash
# Current production: main
# Create new "green" branch
neonctl branches create --name green --parent main

# Apply migrations to green
DATABASE_URL=$(neonctl connection-string green) npx prisma migrate deploy

# Test green environment
DATABASE_URL=$(neonctl connection-string green) npm test

# If tests pass, swap: rename green to main
# (In practice, update connection string in production to point to green)
```

## CI/CD Complete Workflows

### ✅ Good: Full CI/CD Pipeline with Neon
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:

jobs:
  # Run tests on PR with dedicated branch
  test:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Create Test Database Branch
        id: create-test-db
        uses: neondatabase/create-branch-action@v5
        with:
          project_id: ${{ secrets.NEON_PROJECT_ID }}
          branch_name: test/pr-${{ github.event.pull_request.number }}
          api_key: ${{ secrets.NEON_API_KEY }}
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ steps.create-test-db.outputs.db_url }}
      
      - name: Run Tests
        run: npm test
        env:
          DATABASE_URL: ${{ steps.create-test-db.outputs.db_url }}
      
      - name: Cleanup Test Branch
        if: always()
        uses: neondatabase/delete-branch-action@v3
        with:
          project_id: ${{ secrets.NEON_PROJECT_ID }}
          branch: test/pr-${{ github.event.pull_request.number }}
          api_key: ${{ secrets.NEON_API_KEY }}

  # Deploy to production on main push
  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Migrations on Production
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## Connection Management

### ✅ Good: Connection String Format
```bash
# Pooled connection (uses PgBouncer - for serverless)
DATABASE_URL="postgres://user:pass@ep-xxx.region.aws.neon.tech/db?sslmode=require&pgbouncer=true"

# Direct connection (for long-running apps, migrations)
DATABASE_URL="postgres://user:pass@ep-xxx.region.aws.neon.tech/db?sslmode=require"

# With connection limit for serverless
DATABASE_URL="postgres://user:pass@ep-xxx.region.aws.neon.tech/db?sslmode=require&pgbouncer=true&connection_limit=1"
```

## Performance Optimization

### ✅ Good: Efficient Queries
```typescript
// Use projection to fetch only needed columns
const users = await sql`
  SELECT id, name, email
  FROM users
  WHERE active = true
`;

// Use pagination
const limit = 20;
const offset = (page - 1) * limit;

const users = await sql`
  SELECT id, name, email
  FROM users
  ORDER BY created_at DESC
  LIMIT ${limit} OFFSET ${offset}
`;

// Use indexes
// In migration:
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_published_created ON posts(published, created_at) WHERE published = true;
```

## Autoscaling & Cost Optimization

### ✅ Good: Scale to Zero for Dev
```bash
# Configure branch to scale to zero after 5 minutes
neonctl branches set-default \
  --name dev/my-feature \
  --suspend-timeout 300

# For production, keep alive
neonctl branches set-default \
  --name main \
  --suspend-timeout 0
```

## Migrations

### ✅ Good: Run Migrations on Branch
```bash
# Create migration locally
npx prisma migrate dev --name add_users_table

# Apply to specific branch
DATABASE_URL=$(neonctl connection-string dev/my-feature) \
  npx prisma migrate deploy

# Test on branch before applying to main
# Then apply to main when ready
DATABASE_URL=$(neonctl connection-string main) \
  npx prisma migrate deploy
```

## Error Handling

### ✅ Good: Handle Connection Errors
```typescript
import { sql } from '@/lib/db';

export async function getUsers() {
  try {
    const users = await sql`SELECT * FROM users`;
    return users;
  } catch (error) {
    // Handle specific Postgres errors
    if (error.code === '42P01') {
      throw new Error('Users table does not exist');
    }
    
    if (error.code === '57014') {
      throw new Error('Query was cancelled (timeout)');
    }
    
    // Connection error
    if (error.message?.includes('connection')) {
      throw new Error('Database connection failed');
    }
    
    throw error;
  }
}
```

## Advanced Performance Optimization

### ✅ Good: Query Optimization with Indexes
```sql
-- Analyze query performance
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user@example.com';

-- Add indexes for frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite index for multiple columns
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);

-- Partial index for specific conditions
CREATE INDEX idx_posts_published ON posts(published_at) 
WHERE published = true;

-- Full-text search index
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || content));
```

### ✅ Good: Connection Pooling Best Practices
```typescript
// For serverless functions - use pooled connection
const DATABASE_URL = process.env.DATABASE_URL + '?pgbouncer=true&connection_limit=1';

export const sql = neon(DATABASE_URL);

// For long-running servers - use pool
import { Pool } from '@neondatabase/serverless';

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,  // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### ✅ Good: Batch Operations
```typescript
// Efficient batch insert
import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!);

async function batchInsertUsers(users: Array<{email: string, name: string}>) {
  // Single query with multiple values
  const values = users.map(u => `('${u.email}', '${u.name}')`).join(',');
  
  await sql`
    INSERT INTO users (email, name)
    VALUES ${sql.unsafe(values)}
  `;
}

// Better: Use Prisma createMany for type safety
async function batchInsertWithPrisma(users: Array<{email: string, name: string}>) {
  await prisma.user.createMany({
    data: users,
    skipDuplicates: true,
  });
}
```

### ❌ Bad: N+1 Query Problem
```typescript
// ❌ WRONG - Makes N+1 queries
async function getUsersWithPosts() {
  const users = await sql`SELECT * FROM users`;
  
  for (const user of users) {
    user.posts = await sql`SELECT * FROM posts WHERE user_id = ${user.id}`;
  }
  
  return users;
}

// ✅ GOOD - Single query with JOIN
async function getUsersWithPostsOptimized() {
  const result = await sql`
    SELECT 
      u.id, u.name, u.email,
      json_agg(json_build_object('id', p.id, 'title', p.title)) as posts
    FROM users u
    LEFT JOIN posts p ON p.user_id = u.id
    GROUP BY u.id, u.name, u.email
  `;
  
  return result;
}
```

### ✅ Good: Query Caching Strategies
```typescript
// App-level caching with React Query
import { useQuery } from '@tanstack/react-query';
import { sql } from '@/lib/db';

function usePosts() {
  return useQuery({
    queryKey: ['posts'],
    queryFn: async () => {
      return await sql`SELECT * FROM posts ORDER BY created_at DESC LIMIT 20`;
    },
    staleTime: 5 * 60 * 1000,  // 5 minutes
  });
}

// Database-level caching with materialized views
// In migration:
CREATE MATERIALIZED VIEW popular_posts AS
SELECT p.*, COUNT(l.id) as like_count
FROM posts p
LEFT JOIN likes l ON l.post_id = p.id
GROUP BY p.id
ORDER BY like_count DESC
LIMIT 100;

// Refresh periodically
REFRESH MATERIALIZED VIEW popular_posts;
```

## Branch Management Best Practices

### ✅ Good: Branch Naming Conventions
```bash
# Production
main

# Development environments
dev/feature-name
dev/user-authentication
dev/payment-integration

# Preview environments
preview/pr-123
preview/pr-456

# Testing
test/migration-1234567890
test/load-testing

# Staging
staging

# Backup branches
backup/before-migration-1234567890
backup/pre-deploy-2024-01-15
```

### ✅ Good: Automated Branch Cleanup
```yaml
# .github/workflows/cleanup-stale-branches.yml
name: Cleanup Stale Neon Branches

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: List All Branches
        id: list-branches
        run: |
          BRANCHES=$(neonctl branches list --project-id ${{ secrets.NEON_PROJECT_ID }} --json)
          echo "branches=$BRANCHES" >> $GITHUB_OUTPUT
        env:
          NEON_API_KEY: ${{ secrets.NEON_API_KEY }}
      
      - name: Delete Stale Preview Branches
        run: |
          # Delete preview branches older than 7 days
          neonctl branches list --project-id ${{ secrets.NEON_PROJECT_ID }} \
            | grep 'preview/' \
            | while read branch; do
              AGE=$(neonctl branches get $branch --project-id ${{ secrets.NEON_PROJECT_ID }} --json | jq '.created_at')
              if [ $AGE -gt $((7 * 24 * 60 * 60)) ]; then
                echo "Deleting stale branch: $branch"
                neonctl branches delete $branch --project-id ${{ secrets.NEON_PROJECT_ID }}
              fi
            done
        env:
          NEON_API_KEY: ${{ secrets.NEON_API_KEY }}
```

### ✅ Good: Branch Quotas and Limits
```typescript
// Monitor branch count and clean up automatically
import { NeonClient } from '@neondatabase/api-client';

const client = new NeonClient({
  apiKey: process.env.NEON_API_KEY!,
});

async function checkBranchLimits() {
  const project = await client.projects.get(process.env.NEON_PROJECT_ID!);
  const branches = await client.branches.list(process.env.NEON_PROJECT_ID!);

  console.log(`Branches: ${branches.length} / ${project.quotas.max_branches}`);

  if (branches.length >= project.quotas.max_branches * 0.9) {
    console.warn('⚠️ Approaching branch limit! Consider cleanup.');
    
    // Auto-delete oldest preview branches
    const previewBranches = branches
      .filter(b => b.name.startsWith('preview/'))
      .sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
    
    for (const branch of previewBranches.slice(0, 5)) {
      await client.branches.delete(process.env.NEON_PROJECT_ID!, branch.id);
      console.log(`Deleted old preview branch: ${branch.name}`);
    }
  }
}
```

## Troubleshooting Common Issues

### ✅ Good: Handle Connection Timeouts
```typescript
import { neon, NeonDbError } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!, {
  fetchConnectionCache: true,
  fullResults: true,
});

async function queryWithRetry<T>(
  query: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await query();
    } catch (error) {
      if (error instanceof NeonDbError && error.code === 'ECONNREFUSED') {
        console.warn(`Connection failed, retrying... (${i + 1}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        continue;
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}

// Usage
const users = await queryWithRetry(() => 
  sql`SELECT * FROM users WHERE active = true`
);
```

### ✅ Good: Debug Query Performance
```typescript
// Enable query logging
import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!, {
  fullResults: true,
});

async function debugQuery() {
  const start = Date.now();
  
  const result = await sql`
    SELECT * FROM users 
    WHERE email ILIKE '%@example.com%'
  `;
  
  const duration = Date.now() - start;
  
  console.log(`Query took ${duration}ms`);
  console.log(`Rows returned: ${result.length}`);
  
  if (duration > 1000) {
    console.warn('⚠️ Slow query detected! Consider adding an index.');
  }
  
  return result;
}
```

### ✅ Good: Handle Migration Conflicts
```bash
# If migration fails due to conflict
# 1. Check current schema state
neonctl branches schema-diff \
  --project-id $PROJECT_ID \
  --branch main \
  --compare-to backup/before-migration

# 2. Revert to backup if needed
neonctl branches reset main --parent backup/before-migration

# 3. Fix migration locally
npx prisma migrate dev --name fix-migration

# 4. Test on branch before production
neonctl branches create --name test/fixed-migration --parent main
DATABASE_URL=$(neonctl connection-string test/fixed-migration) \
  npx prisma migrate deploy
```

### ✅ Good: Monitor Database Size and Limits
```typescript
// Check database size
import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!);

async function checkDatabaseSize() {
  const result = await sql`
    SELECT 
      pg_size_pretty(pg_database_size(current_database())) as size,
      pg_database_size(current_database()) as bytes
  `;
  
  console.log(`Database size: ${result[0].size}`);
  
  const sizeGB = result[0].bytes / (1024 ** 3);
  if (sizeGB > 9) {  // Assuming 10GB limit
    console.warn('⚠️ Approaching storage limit!');
  }
  
  // Check table sizes
  const tableSizes = await sql`
    SELECT 
      schemaname,
      tablename,
      pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
    FROM pg_tables
    WHERE schemaname = 'public'
    ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
    LIMIT 10
  `;
  
  console.table(tableSizes);
}
```

### ❌ Bad: Ignoring Error Codes
```typescript
// ❌ WRONG - Generic error handling
try {
  await sql`INSERT INTO users (email) VALUES (${email})`;
} catch (error) {
  console.error('Error:', error);  // Not helpful!
}

// ✅ GOOD - Handle specific errors
try {
  await sql`INSERT INTO users (email) VALUES (${email})`;
} catch (error) {
  if (error.code === '23505') {  // Unique constraint violation
    throw new Error('Email already exists');
  } else if (error.code === '23502') {  // NOT NULL violation
    throw new Error('Required field missing');
  } else if (error.code === '42P01') {  // Table doesn't exist
    throw new Error('Database table not found - run migrations');
  }
  throw error;
}
```

## Cost Optimization Strategies

### ✅ Good: Configure Auto-suspend for Dev Branches
```bash
# Set suspend timeout for development branches
neonctl branches update \
  --project-id $PROJECT_ID \
  --branch dev/feature \
  --suspend-timeout 300  # 5 minutes of inactivity

# Keep production always active
neonctl branches update \
  --project-id $PROJECT_ID \
  --branch main \
  --suspend-timeout 0  # Never suspend
```

### ✅ Good: Use Pooled Connections in Serverless
```typescript
// Always use ?pgbouncer=true for serverless to reduce connection overhead
const DATABASE_URL = process.env.DATABASE_URL + '?pgbouncer=true&connection_limit=1';

// This reduces costs by minimizing active connections
```

### ✅ Good: Delete Unused Branches Regularly
```bash
# List all branches
neonctl branches list --project-id $PROJECT_ID

# Delete finished feature branches
neonctl branches delete dev/old-feature --project-id $PROJECT_ID

# Automate with GitHub Actions (see cleanup workflow above)
```

## Security Best Practices with Neon

### ✅ Good: Rotate Database Passwords
```bash
# Generate new password
neonctl branches password-reset \
  --project-id $PROJECT_ID \
  --branch main

# Update connection string in secrets
# Use environment variables, never commit
```

### ✅ Good: Use Read-Only Connections for Analytics
```typescript
// Create read-only user in migration
await sql`
  CREATE USER analytics_readonly WITH PASSWORD 'secure_password';
  GRANT CONNECT ON DATABASE neondb TO analytics_readonly;
  GRANT USAGE ON SCHEMA public TO analytics_readonly;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_readonly;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT ON TABLES TO analytics_readonly;
`;

// Use separate connection string for analytics
const ANALYTICS_DATABASE_URL = process.env.ANALYTICS_DATABASE_URL;
```

### ✅ Good: Enable SSL/TLS
```typescript
// Neon enforces SSL by default
const DATABASE_URL = process.env.DATABASE_URL + '?sslmode=require';

// For maximum security
const DATABASE_URL = process.env.DATABASE_URL + '?sslmode=verify-full';
```

**ALWAYS use database branching for dev/preview environments, leverage the serverless driver for edge compatibility, utilize scale-to-zero for cost optimization, and implement proper monitoring and error handling for production reliability.**
