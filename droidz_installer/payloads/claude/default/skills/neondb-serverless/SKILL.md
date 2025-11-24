---
name: neondb-serverless
description: Using NeonDB serverless PostgreSQL, implementing connection pooling, or building edge-compatible database apps. Use when working with neondb serverless in your development workflow.
---

# NeonDB Serverless - PostgreSQL for Modern Apps

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
