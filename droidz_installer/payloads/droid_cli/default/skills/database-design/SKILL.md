---
name: database-design
description: Design scalable, normalized database schemas with proper relationships, indexes, constraints, and migration strategies for relational and NoSQL databases. Use when designing database schemas, planning table relationships and foreign keys, creating indexes for query optimization, defining constraints and validations, designing data models for scalability, planning database migrations, choosing between SQL and NoSQL, implementing sharding strategies, optimizing query performance, or establishing data integrity rules.
---

# Database Design - Schema, Indexes, and Query Optimization

## When to use this skill

- Designing new database schemas and data models
- Planning table relationships and foreign key constraints
- Creating indexes to optimize query performance
- Defining database constraints and validation rules
- Designing for scalability and future growth
- Planning database migration strategies
- Choosing between SQL and NoSQL databases
- Implementing database sharding or partitioning
- Normalizing data to reduce redundancy
- Optimizing slow database queries
- Designing audit trails and soft deletes
- Planning backup and disaster recovery strategies

## When to use this skill

- Designing database schemas, choosing between SQL/NoSQL, optimizing queries, planning migrations, or solving data modeling problems.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Designing database schemas, choosing between SQL/NoSQL, optimizing queries, planning migrations, or solving data modeling problems.

## Core Principles

1. **Normalize First, Denormalize When Needed** - Start with proper normalization
2. **Index Strategically** - Balance query speed vs write overhead
3. **Design for Scale** - Consider growth patterns from day one
4. **Choose the Right Tool** - SQL vs NoSQL depends on use case
5. **Migrations Are Forever** - Plan schema changes carefully

## Schema Design Fundamentals

### 1. **Normalization (Reducing Redundancy)**

```sql
-- ❌ Denormalized - data duplication
CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  customer_address TEXT,  -- Repeated for every order!
  product_name VARCHAR(200),
  product_price DECIMAL(10,2),  -- Duplicated product data
  quantity INT
);

-- ✅ Normalized - separate concerns
CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  address TEXT
);

CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0
);

CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(id),
  created_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE order_items (
  id INT PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(id),
  quantity INT NOT NULL CHECK (quantity > 0),
  price_at_purchase DECIMAL(10,2) NOT NULL  -- Snapshot for history
);
```

### 2. **Primary Keys & Foreign Keys**

```sql
-- ✅ Auto-incrementing integer (traditional)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,  -- PostgreSQL
  -- id INT AUTO_INCREMENT PRIMARY KEY, -- MySQL
  email VARCHAR(255) UNIQUE NOT NULL
);

-- ✅ UUID (distributed systems, no conflicts)
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  title VARCHAR(200) NOT NULL
);

-- ✅ Composite primary key (junction tables)
CREATE TABLE user_roles (
  user_id INT NOT NULL REFERENCES users(id),
  role_id INT NOT NULL REFERENCES roles(id),
  granted_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

-- ✅ Foreign key with cascade options
CREATE TABLE comments (
  id INT PRIMARY KEY,
  post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,  -- Delete comments when post deleted
  user_id INT NOT NULL REFERENCES users(id) ON DELETE SET NULL,  -- Keep comment, nullify user
  content TEXT NOT NULL
);
```

### 3. **Indexes for Performance**

```sql
-- ✅ Single column index (frequently queried)
CREATE INDEX idx_users_email ON users(email);

-- ✅ Composite index (multi-column queries)
CREATE INDEX idx_orders_customer_date 
ON orders(customer_id, created_at DESC);

-- ✅ Partial index (conditional)
CREATE INDEX idx_active_users 
ON users(email) WHERE status = 'active';

-- ✅ Full-text search index
CREATE INDEX idx_posts_search 
ON posts USING GIN(to_tsvector('english', title || ' ' || content));

-- ✅ Unique index (enforce constraint + speed lookups)
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);

-- ❌ Over-indexing (slows writes)
-- Don't index every column blindly
-- Indexes cost disk space and slow INSERT/UPDATE/DELETE
```

**Index Strategy:**
```
Index when:
✓ Frequently used in WHERE clauses
✓ Used in JOIN conditions
✓ Used in ORDER BY / GROUP BY
✓ High cardinality (many unique values)

Don't index when:
✗ Small tables (< 1000 rows)
✗ Low cardinality (e.g., boolean, status with 2-3 values)
✗ Frequently updated columns (unless reads >> writes)
✗ Already covered by composite index
```

### 4. **Relationships**

```sql
-- ✅ One-to-Many: User has many posts
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE posts (
  id INT PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id),
  title VARCHAR(200)
);

-- ✅ Many-to-Many: Users ↔ Roles (junction table)
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE roles (id INT PRIMARY KEY, name VARCHAR(50));
CREATE TABLE user_roles (
  user_id INT REFERENCES users(id),
  role_id INT REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);

-- ✅ One-to-One: User has one profile
CREATE TABLE users (id INT PRIMARY KEY, email VARCHAR(255));
CREATE TABLE profiles (
  id INT PRIMARY KEY,
  user_id INT UNIQUE NOT NULL REFERENCES users(id),  -- UNIQUE enforces 1:1
  bio TEXT,
  avatar_url VARCHAR(500)
);

-- ✅ Self-referencing: Tree structure
CREATE TABLE categories (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  parent_id INT REFERENCES categories(id)  -- Points to itself
);
```

### 5. **Data Types**

```sql
-- ✅ Choose appropriate types
CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,           -- Variable length string
  description TEXT,                     -- Long text
  price DECIMAL(10,2) NOT NULL,         -- Exact precision for money
  stock INT DEFAULT 0,                  -- Whole number
  weight FLOAT,                         -- Approximate number
  is_active BOOLEAN DEFAULT true,       -- True/false
  created_at TIMESTAMP DEFAULT NOW(),   -- Date + time
  metadata JSONB,                       -- JSON data (PostgreSQL)
  tags TEXT[]                           -- Array (PostgreSQL)
);

-- ❌ Wrong types
-- price FLOAT - ❌ Floating point errors for money
-- created_at VARCHAR(50) - ❌ Use proper datetime types
-- status INT - ❌ Use ENUM or VARCHAR for readability
```

## SQL vs NoSQL Choice

### When to Use SQL (PostgreSQL, MySQL)

```
✓ Complex relationships and joins
✓ ACID transactions required
✓ Structured, predictable data
✓ Complex queries with aggregations
✓ Strong consistency needed
✓ Examples: Financial systems, e-commerce, CRM
```

### When to Use NoSQL

**Document Stores (MongoDB, Firestore):**
```
✓ Flexible, evolving schema
✓ Nested/hierarchical data
✓ Rapid prototyping
✓ Document-centric access patterns
✓ Examples: CMS, catalogs, user profiles
```

**Key-Value Stores (Redis, DynamoDB):**
```
✓ Simple key lookups
✓ Caching layer
✓ Session storage
✓ Rate limiting counters
✓ Examples: Cache, sessions, real-time leaderboards
```

**Time-Series (InfluxDB, TimescaleDB):**
```
✓ Time-stamped data
✓ High write throughput
✓ Aggregations over time
✓ Examples: Metrics, logs, IoT sensors
```

## Query Optimization

### 1. **Identify Slow Queries**

```sql
-- PostgreSQL - explain query plan
EXPLAIN ANALYZE
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.name;

/*
Output shows:
- Seq Scan (bad) vs Index Scan (good)
- Execution time
- Rows scanned vs returned
*/
```

### 2. **Avoid N+1 Queries**

```typescript
// ❌ N+1 Problem - 1 query + N queries for each user
const users = await db.query('SELECT * FROM users');
for (const user of users) {
  const posts = await db.query(
    'SELECT * FROM posts WHERE user_id = ?', 
    [user.id]
  ); // N queries!
}

// ✅ Single query with JOIN
const results = await db.query(`
  SELECT 
    u.id, u.name, u.email,
    p.id as post_id, p.title as post_title
  FROM users u
  LEFT JOIN posts p ON p.user_id = u.id
`);

// ✅ Using Prisma ORM with eager loading
const users = await prisma.user.findMany({
  include: {
    posts: true  // Efficiently loads related posts
  }
});
```

### 3. **Use Efficient Joins**

```sql
-- ✅ INNER JOIN - only matching rows
SELECT u.name, p.title
FROM users u
INNER JOIN posts p ON p.user_id = u.id;

-- ✅ LEFT JOIN - all users, even without posts
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.name;

-- ❌ Avoid subqueries in SELECT when possible
SELECT 
  u.name,
  (SELECT COUNT(*) FROM posts WHERE user_id = u.id) as post_count  -- Slow!
FROM users u;

-- ✅ Better: use JOIN
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.name;
```

### 4. **Pagination**

```sql
-- ✅ Offset pagination (simple but slower for deep pages)
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;  -- Page 3

-- ✅ Cursor pagination (faster for deep pages)
SELECT * FROM posts
WHERE created_at < '2024-01-01 12:00:00'
ORDER BY created_at DESC
LIMIT 20;
```

### 5. **Aggregations**

```sql
-- ✅ Efficient counting
SELECT COUNT(*) FROM users WHERE status = 'active';

-- ✅ Grouping with aggregates
SELECT 
  category,
  COUNT(*) as total,
  AVG(price) as avg_price,
  MAX(price) as max_price
FROM products
GROUP BY category
HAVING COUNT(*) > 10;  -- HAVING filters groups, WHERE filters rows

-- ✅ Window functions (PostgreSQL)
SELECT 
  name,
  salary,
  AVG(salary) OVER (PARTITION BY department) as dept_avg_salary
FROM employees;
```

## Migration Strategies

### 1. **Schema Migrations with Prisma**

```typescript
// schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
  createdAt DateTime @default(now())
  
  @@index([authorId])
}
```

```bash
# Generate migration
npx prisma migrate dev --name add_post_table

# Apply to production
npx prisma migrate deploy
```

### 2. **Safe Migration Patterns**

```sql
-- ✅ Add column (safe - doesn't lock table)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- ✅ Add index concurrently (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ❌ Risky - locks entire table
ALTER TABLE users ALTER COLUMN email TYPE TEXT;

-- ✅ Better: Multi-step migration
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_new TEXT;

-- Step 2: Backfill data
UPDATE users SET email_new = email;

-- Step 3: Swap columns (in separate deployment)
ALTER TABLE users DROP COLUMN email;
ALTER TABLE users RENAME COLUMN email_new TO email;
```

### 3. **Data Migrations**

```typescript
// migration-001-backfill-slugs.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function up() {
  const posts = await prisma.post.findMany({
    where: { slug: null }
  });
  
  for (const post of posts) {
    await prisma.post.update({
      where: { id: post.id },
      data: { slug: generateSlug(post.title) }
    });
  }
}

function generateSlug(title: string) {
  return title.toLowerCase().replace(/\s+/g, '-');
}
```

## Advanced Patterns

### 1. **Soft Deletes**

```sql
-- ✅ Keep deleted records
CREATE TABLE posts (
  id INT PRIMARY KEY,
  title VARCHAR(200),
  deleted_at TIMESTAMP NULL  -- NULL = not deleted
);

-- Query only active records
SELECT * FROM posts WHERE deleted_at IS NULL;

-- "Delete" record (soft delete)
UPDATE posts SET deleted_at = NOW() WHERE id = 123;

-- Create view for convenience
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;
```

### 2. **Audit Trails**

```sql
-- ✅ Track all changes
CREATE TABLE users_audit (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  field_changed VARCHAR(50),
  old_value TEXT,
  new_value TEXT,
  changed_by INT REFERENCES users(id),
  changed_at TIMESTAMP DEFAULT NOW()
);

-- Trigger to auto-populate
CREATE OR REPLACE FUNCTION audit_user_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO users_audit (user_id, field_changed, old_value, new_value)
  VALUES (OLD.id, 'email', OLD.email, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_email_audit
AFTER UPDATE OF email ON users
FOR EACH ROW
EXECUTE FUNCTION audit_user_changes();
```

### 3. **Polymorphic Associations**

```sql
-- ✅ Comments on multiple resource types
CREATE TABLE comments (
  id INT PRIMARY KEY,
  commentable_type VARCHAR(50) NOT NULL,  -- 'Post', 'Photo', 'Video'
  commentable_id INT NOT NULL,
  content TEXT NOT NULL,
  
  -- Composite index for polymorphic lookup
  INDEX idx_commentable (commentable_type, commentable_id)
);

-- Query comments for a post
SELECT * FROM comments 
WHERE commentable_type = 'Post' AND commentable_id = 123;
```

## Database Checklist

```
Schema Design:
□ Properly normalized (3NF minimum)
□ Primary keys on all tables
□ Foreign keys with appropriate CASCADE/SET NULL
□ Check constraints for data validation
□ NOT NULL constraints where appropriate
□ UNIQUE constraints for business rules

Indexes:
□ Foreign keys indexed
□ WHERE clause columns indexed
□ JOIN columns indexed
□ Composite indexes for multi-column queries
□ Partial indexes for filtered queries
□ No redundant indexes

Performance:
□ EXPLAIN ANALYZE on slow queries
□ N+1 queries eliminated
□ Proper use of JOINs vs subqueries
□ Pagination implemented
□ Connection pooling configured

Migrations:
□ All changes in migration files
□ Rollback capability tested
□ Safe column additions/removals
□ Data backfilled before constraints
□ Zero-downtime migrations for production

Monitoring:
□ Slow query log enabled
□ Connection pool metrics tracked
□ Disk usage monitored
□ Replication lag checked (if applicable)
□ Regular VACUUM (PostgreSQL)
```

## Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Use The Index, Luke!](https://use-the-index-luke.com/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Database Design Patterns](https://www.oreilly.com/library/view/sql-antipatterns/9781680500073/)

---

**Remember**: Good database design is the foundation of scalable applications. Invest time upfront in proper schema design and indexing.
