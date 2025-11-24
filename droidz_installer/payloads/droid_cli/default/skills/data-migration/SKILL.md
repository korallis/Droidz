---
name: data-migration
description: Migrating data between schemas, zero-downtime deployments.. Use when data migration. Use when migrating data, upgrading dependencies, or transforming database schemas.
---

# Data Migration - Safe Schema Changes

## When to use this skill

- Migrating data between schemas, zero-downtime deployments.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Migrating data between schemas, zero-downtime deployments.

## Process
1. Add new column
2. Dual-write to old & new
3. Backfill historical data
4. Switch reads to new column
5. Remove old column

## Example
\`\`\`sql
-- Step 1: Add column
ALTER TABLE users ADD COLUMN email_new VARCHAR(255);

-- Step 2: Backfill
UPDATE users SET email_new = email WHERE email_new IS NULL;

-- Step 3: Swap
ALTER TABLE users DROP COLUMN email;
ALTER TABLE users RENAME COLUMN email_new TO email;
\`\`\`

## Resources
- [Database Migrations](https://www.prisma.io/docs/concepts/components/prisma-migrate)
