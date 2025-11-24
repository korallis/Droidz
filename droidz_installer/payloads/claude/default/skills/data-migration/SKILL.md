---
name: data-migration
description: Migrating data between schemas, zero-downtime deployments.
---

# Data Migration - Safe Schema Changes

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
