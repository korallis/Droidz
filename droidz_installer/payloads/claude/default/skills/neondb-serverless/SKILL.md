---
name: neondb-serverless
description: Use Neon serverless Postgres with branching, connection pooling, and instant scalability for modern applications with Prisma or Drizzle ORM integration. Use when setting up serverless Postgres databases, implementing database branching for preview environments, configuring connection pooling, optimizing for serverless cold starts, using Prisma with Neon, implementing database migrations, scaling databases automatically, or building applications on Vercel/Netlify with Postgres.
---

# NeonDB Serverless - PostgreSQL for Modern Apps

## When to use this skill

- Setting up serverless Postgres databases
- Implementing database branching for previews
- Configuring connection pooling for serverless
- Optimizing database for cold starts
- Using Prisma or Drizzle ORM with Neon
- Implementing automated database migrations
- Scaling databases without manual intervention
- Building Next.js apps with Postgres on Vercel
- Creating preview databases per Git branch
- Implementing instant database rollbacks
- Using Postgres in serverless functions
- Optimizing connection management for edge functions

## When to use this skill

- Using NeonDB serverless PostgreSQL, implementing connection pooling, or building edge-compatible database apps.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Using NeonDB serverless PostgreSQL, implementing connection pooling, or building edge-compatible database apps.

## Key Patterns

### Connection Pooling (Critical!)
\`\`\`typescript
import { Pool } from '@neondatabase/serverless';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function query(text: string, params: any[]) {
  const client = await pool.connect();
  try {
    return await client.query(text, params);
  } finally {
    client.release();
  }
}
\`\`\`

### Edge Runtime Compatible
\`\`\`typescript
import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.DATABASE_URL!);

export const runtime = 'edge';

export async function GET() {
  const users = await sql`SELECT * FROM users`;
  return Response.json(users);
}
\`\`\`

## Resources
- [NeonDB Docs](https://neon.tech/docs)
