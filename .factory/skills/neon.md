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

**ALWAYS use database branching for dev/preview environments, leverage the serverless driver for edge compatibility, and utilize scale-to-zero for cost optimization.**
