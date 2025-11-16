# PostgreSQL Best Practices

**Official PostgreSQL guidelines - Schema Design, Indexing, Query Optimization, Transactions, Advanced SQL**

## Core Principles

1. **ALWAYS Enable Constraints** - Use PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL for data integrity
2. **Index Strategically** - Choose the right index type (B-tree, GIN, GiST, Hash) based on query patterns
3. **Use EXPLAIN ANALYZE** - Analyze query plans to identify performance bottlenecks
4. **Leverage MVCC** - Understand Multi-Version Concurrency Control for optimal transaction management
5. **Apply Normalization** - Use 3NF for OLTP, denormalize selectively for performance
6. **Connection Pooling** - Use PgBouncer or Supavisor to manage connections efficiently
7. **Monitor Performance** - Track slow queries with pg_stat_statements

## Schema Design - Complete Guide

### Data Types

#### ✅ Good: Use Appropriate Data Types
```sql
-- Use specific data types for better storage and performance
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,                    -- Auto-incrementing 64-bit integer
  email VARCHAR(255) NOT NULL UNIQUE,          -- Variable-length string with limit
  username VARCHAR(50) NOT NULL UNIQUE,        -- Shorter string for usernames
  age INTEGER CHECK (age >= 0 AND age <= 150), -- Integer with range constraint
  balance NUMERIC(10, 2),                      -- Exact decimal for money (10 digits, 2 decimal places)
  is_active BOOLEAN DEFAULT true,              -- Boolean for flags
  metadata JSONB,                               -- Binary JSON for flexible data
  tags TEXT[],                                  -- Array of strings
  created_at TIMESTAMPTZ DEFAULT NOW(),        -- Timestamp with timezone
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Use UUID for distributed systems
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id BIGINT NOT NULL REFERENCES users(id),
  token TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL
);

-- Use ENUM for fixed sets of values
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  status order_status DEFAULT 'pending',
  total NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### ❌ Bad: Inappropriate Data Types
```sql
-- ❌ Using TEXT for everything (wastes storage, slower comparisons)
CREATE TABLE users (
  id TEXT,
  email TEXT,
  age TEXT,        -- Should be INTEGER
  balance TEXT,    -- Should be NUMERIC
  is_active TEXT,  -- Should be BOOLEAN
  created_at TEXT  -- Should be TIMESTAMPTZ
);

-- ❌ Using FLOAT for money (precision errors)
CREATE TABLE transactions (
  amount FLOAT  -- ❌ NEVER use FLOAT for money, use NUMERIC
);

-- ❌ Using VARCHAR without limit
CREATE TABLE posts (
  content VARCHAR  -- ❌ Specify limit or use TEXT
);

-- ❌ Using TIMESTAMP instead of TIMESTAMPTZ
CREATE TABLE events (
  occurred_at TIMESTAMP  -- ❌ No timezone info, use TIMESTAMPTZ
);
```

### Primary Keys and Foreign Keys

#### ✅ Good: Proper Primary and Foreign Keys
```sql
-- Use BIGSERIAL for auto-incrementing IDs
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Foreign key with proper referential actions
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  total NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Foreign key with ON DELETE CASCADE (delete orders when customer is deleted)
  CONSTRAINT fk_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Composite primary key
CREATE TABLE order_items (
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price NUMERIC(10, 2) NOT NULL,
  
  PRIMARY KEY (order_id, product_id),
  
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- Use UUID for distributed systems or multi-tenant apps
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tenant_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  UNIQUE (tenant_id, email)  -- Unique per tenant
);
```

#### ❌ Bad: Missing or Improper Keys
```sql
-- ❌ No primary key
CREATE TABLE logs (
  user_id BIGINT,
  action TEXT,
  created_at TIMESTAMPTZ
);  -- ❌ Should have id or composite key

-- ❌ No foreign key constraint (orphaned records possible)
CREATE TABLE comments (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT,  -- ❌ No REFERENCES constraint
  content TEXT
);

-- ❌ Wrong ON DELETE action
CREATE TABLE invoices (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE
);  -- ❌ CASCADE may not be appropriate for invoices

-- ❌ Using INTEGER for large tables (will overflow at 2.1B)
CREATE TABLE events (
  id SERIAL PRIMARY KEY  -- ❌ Use BIGSERIAL for tables that grow large
);
```

### Constraints

#### ✅ Good: Comprehensive Constraints
```sql
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  cost NUMERIC(10, 2) CHECK (cost >= 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  category VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Table-level constraint
  CONSTRAINT price_greater_than_cost CHECK (price >= cost)
);

-- Email validation constraint
CREATE TABLE subscribers (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  
  CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Date range constraints
CREATE TABLE bookings (
  id BIGSERIAL PRIMARY KEY,
  room_id BIGINT NOT NULL REFERENCES rooms(id),
  check_in DATE NOT NULL,
  check_out DATE NOT NULL,
  
  CONSTRAINT valid_date_range CHECK (check_out > check_in)
);

-- Mutually exclusive columns (use CHECK constraint)
CREATE TABLE payments (
  id BIGSERIAL PRIMARY KEY,
  amount NUMERIC(10, 2) NOT NULL,
  credit_card_id BIGINT REFERENCES credit_cards(id),
  paypal_email VARCHAR(255),
  
  -- Ensure exactly one payment method is provided
  CONSTRAINT one_payment_method CHECK (
    (credit_card_id IS NOT NULL AND paypal_email IS NULL) OR
    (credit_card_id IS NULL AND paypal_email IS NOT NULL)
  )
);
```

#### ❌ Bad: Missing or Weak Constraints
```sql
-- ❌ No constraints, allows invalid data
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),        -- ❌ Should be NOT NULL
  price NUMERIC(10, 2),     -- ❌ Should be NOT NULL and CHECK >= 0
  stock INTEGER             -- ❌ Should have CHECK >= 0
);

-- ❌ Duplicate emails allowed
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL  -- ❌ Missing UNIQUE constraint
);

-- ❌ No validation on enum-like columns
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  status VARCHAR(50)  -- ❌ Should use ENUM or CHECK constraint
);
```

### Normalization

#### ✅ Good: Properly Normalized Schema (3NF)
```sql
-- Third Normal Form (3NF): No transitive dependencies

-- 1. Customers table
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Addresses table (separate from customers)
CREATE TABLE addresses (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL,
  zip_code VARCHAR(20) NOT NULL,
  country VARCHAR(100) NOT NULL,
  is_default BOOLEAN DEFAULT false
);

-- 3. Products table
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(50) NOT NULL UNIQUE,
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  category_id BIGINT NOT NULL REFERENCES categories(id)
);

-- 4. Categories table (no redundancy)
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT
);

-- 5. Orders table
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  shipping_address_id BIGINT NOT NULL REFERENCES addresses(id),
  total NUMERIC(10, 2) NOT NULL CHECK (total >= 0),
  status order_status DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Order items (many-to-many relationship)
CREATE TABLE order_items (
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price NUMERIC(10, 2) NOT NULL,  -- Snapshot price at order time
  
  PRIMARY KEY (order_id, product_id)
);
```

#### ❌ Bad: Denormalized Schema with Redundancy
```sql
-- ❌ First Normal Form violation (repeating groups)
CREATE TABLE orders_bad (
  id BIGSERIAL PRIMARY KEY,
  customer_name VARCHAR(255),
  product1_name VARCHAR(255),
  product1_quantity INTEGER,
  product1_price NUMERIC(10, 2),
  product2_name VARCHAR(255),     -- ❌ Repeating groups
  product2_quantity INTEGER,
  product2_price NUMERIC(10, 2)
);

-- ❌ Second Normal Form violation (partial dependencies)
CREATE TABLE order_items_bad (
  order_id BIGINT,
  product_id BIGINT,
  customer_name VARCHAR(255),     -- ❌ Depends on order_id, not full key
  product_name VARCHAR(255),      -- ❌ Depends on product_id, not full key
  quantity INTEGER,
  
  PRIMARY KEY (order_id, product_id)
);

-- ❌ Third Normal Form violation (transitive dependency)
CREATE TABLE employees_bad (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  department_id BIGINT,
  department_name VARCHAR(255),   -- ❌ Depends on department_id, not id
  department_budget NUMERIC(10, 2)  -- ❌ Transitive dependency
);
```

### Strategic Denormalization

#### ✅ Good: Denormalization for Performance
```sql
-- Add calculated/cached columns for frequently accessed data
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  
  -- Denormalized: cache customer name for faster queries
  customer_name VARCHAR(255) NOT NULL,
  
  -- Denormalized: cache total to avoid SUM on order_items
  item_count INTEGER NOT NULL DEFAULT 0,
  total NUMERIC(10, 2) NOT NULL DEFAULT 0,
  
  status order_status DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Update denormalized fields with triggers
CREATE OR REPLACE FUNCTION update_order_totals()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders
  SET 
    item_count = (SELECT COUNT(*) FROM order_items WHERE order_id = NEW.order_id),
    total = (SELECT COALESCE(SUM(quantity * price), 0) FROM order_items WHERE order_id = NEW.order_id)
  WHERE id = NEW.order_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_items_update_totals
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_totals();

-- Materialized views for complex aggregations
CREATE MATERIALIZED VIEW product_sales_summary AS
SELECT 
  p.id,
  p.name,
  p.category_id,
  COUNT(oi.order_id) AS order_count,
  SUM(oi.quantity) AS total_quantity_sold,
  SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category_id;

-- Create index on materialized view
CREATE INDEX idx_product_sales_category ON product_sales_summary(category_id);

-- Refresh periodically (e.g., via cron job)
REFRESH MATERIALIZED VIEW CONCURRENTLY product_sales_summary;
```

#### ❌ Bad: Over-Denormalization
```sql
-- ❌ Too much denormalization, hard to maintain consistency
CREATE TABLE orders_bad (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT REFERENCES customers(id),
  customer_name VARCHAR(255),
  customer_email VARCHAR(255),
  customer_phone VARCHAR(20),
  customer_address TEXT,        -- ❌ Too many duplicated fields
  customer_city VARCHAR(100),
  customer_state VARCHAR(50),
  customer_country VARCHAR(100)
);  -- ❌ Nightmare to keep in sync when customer updates profile
```

## Indexing Strategies - Complete Guide

### B-Tree Indexes (Default)

#### ✅ Good: B-Tree Index Usage
```sql
-- Single-column index for equality and range queries
CREATE INDEX idx_users_email ON users(email);

-- Query benefits from index
SELECT * FROM users WHERE email = 'user@example.com';
SELECT * FROM users WHERE email LIKE 'user%';  -- Prefix search
SELECT * FROM users WHERE created_at > '2024-01-01';
SELECT * FROM users ORDER BY email;  -- Index scan for sorting

-- Multi-column index (order matters!)
CREATE INDEX idx_orders_customer_created ON orders(customer_id, created_at DESC);

-- ✅ Uses index efficiently
SELECT * FROM orders WHERE customer_id = 123 ORDER BY created_at DESC;
SELECT * FROM orders WHERE customer_id = 123 AND created_at > '2024-01-01';

-- Partial index (index subset of rows)
CREATE INDEX idx_active_users ON users(email) WHERE is_active = true;

-- ✅ Uses partial index
SELECT * FROM users WHERE email = 'user@example.com' AND is_active = true;

-- Index on expression
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- ✅ Uses expression index
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- Unique index
CREATE UNIQUE INDEX idx_users_username_unique ON users(LOWER(username));

-- Covering index (includes extra columns to avoid table lookup)
CREATE INDEX idx_orders_customer_covering ON orders(customer_id) INCLUDE (total, created_at);

-- ✅ Index-only scan (no table access needed)
SELECT customer_id, total, created_at FROM orders WHERE customer_id = 123;
```

#### ❌ Bad: Inefficient B-Tree Index Usage
```sql
-- ❌ Index on low-cardinality column (few distinct values)
CREATE INDEX idx_users_is_active ON users(is_active);  -- Only 2 values: true/false

-- ❌ Wrong column order in multi-column index
CREATE INDEX idx_orders_created_customer ON orders(created_at, customer_id);

-- ❌ Doesn't use index efficiently (customer_id not first)
SELECT * FROM orders WHERE customer_id = 123 AND created_at > '2024-01-01';

-- ❌ Index not used for wildcard search
SELECT * FROM users WHERE email LIKE '%@example.com';  -- ❌ Leading wildcard

-- ❌ Index not used for case-insensitive search
SELECT * FROM users WHERE email = 'USER@EXAMPLE.COM';  -- ❌ Case mismatch

-- ❌ Over-indexing (too many indexes slow down writes)
CREATE INDEX idx1 ON products(name);
CREATE INDEX idx2 ON products(sku);
CREATE INDEX idx3 ON products(category);
CREATE INDEX idx4 ON products(price);
CREATE INDEX idx5 ON products(created_at);
-- ❌ Each INSERT/UPDATE now updates 6 indexes!
```

### GIN Indexes (Arrays, JSONB, Full-Text Search)

#### ✅ Good: GIN Index for JSONB and Arrays
```sql
-- GIN index on JSONB column
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  attributes JSONB
);

CREATE INDEX idx_products_attributes ON products USING GIN (attributes);

-- ✅ Efficient JSONB queries
SELECT * FROM products WHERE attributes @> '{"color": "red"}';
SELECT * FROM products WHERE attributes ? 'size';  -- Key exists
SELECT * FROM products WHERE attributes ?| ARRAY['color', 'size'];  -- Any key exists
SELECT * FROM products WHERE attributes ?& ARRAY['color', 'size'];  -- All keys exist

-- GIN index on specific JSONB path
CREATE INDEX idx_products_attributes_color ON products USING GIN ((attributes -> 'color'));

-- GIN index on array column
CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  tags TEXT[]
);

CREATE INDEX idx_posts_tags ON posts USING GIN (tags);

-- ✅ Efficient array queries
SELECT * FROM posts WHERE tags @> ARRAY['postgresql', 'database'];  -- Contains all
SELECT * FROM posts WHERE tags && ARRAY['postgresql', 'sql'];       -- Contains any
SELECT * FROM posts WHERE 'postgresql' = ANY(tags);                 -- Contains element

-- Full-text search with GIN
CREATE TABLE articles (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('english', title || ' ' || content)
  ) STORED
);

CREATE INDEX idx_articles_search ON articles USING GIN (search_vector);

-- ✅ Fast full-text search
SELECT * FROM articles WHERE search_vector @@ to_tsquery('english', 'postgresql & performance');

-- Rank results by relevance
SELECT 
  id,
  title,
  ts_rank(search_vector, to_tsquery('english', 'postgresql & performance')) AS rank
FROM articles
WHERE search_vector @@ to_tsquery('english', 'postgresql & performance')
ORDER BY rank DESC;
```

#### ❌ Bad: Missing or Improper GIN Indexes
```sql
-- ❌ No GIN index on JSONB column
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  attributes JSONB
);
-- ❌ Slow queries on attributes

SELECT * FROM products WHERE attributes @> '{"color": "red"}';  -- Seq scan

-- ❌ Using B-tree index on array (doesn't work well)
CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  tags TEXT[]
);

CREATE INDEX idx_posts_tags ON posts(tags);  -- ❌ B-tree, not GIN

SELECT * FROM posts WHERE tags @> ARRAY['postgresql'];  -- Slow
```

### GiST Indexes (Geometric, Range Types)

#### ✅ Good: GiST Index for Spatial and Range Data
```sql
-- GiST for geometric data (requires PostGIS extension)
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE locations (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  coordinates GEOGRAPHY(POINT, 4326)
);

CREATE INDEX idx_locations_coords ON locations USING GIST (coordinates);

-- ✅ Efficient spatial queries
SELECT * FROM locations 
WHERE ST_DWithin(coordinates, ST_MakePoint(-122.4194, 37.7749)::geography, 5000);  -- Within 5km

-- GiST for range types
CREATE TABLE reservations (
  id BIGSERIAL PRIMARY KEY,
  room_id BIGINT NOT NULL,
  period TSTZRANGE NOT NULL,
  EXCLUDE USING GIST (room_id WITH =, period WITH &&)  -- Prevent overlapping reservations
);

-- ✅ Prevent double-booking
INSERT INTO reservations (room_id, period)
VALUES (1, '[2024-01-01 14:00, 2024-01-01 16:00)');

-- ❌ This will fail due to overlap
INSERT INTO reservations (room_id, period)
VALUES (1, '[2024-01-01 15:00, 2024-01-01 17:00)');  -- ERROR: conflicting key

-- Query overlapping ranges
SELECT * FROM reservations 
WHERE room_id = 1 AND period && '[2024-01-01, 2024-01-02)'::tstzrange;
```

#### ❌ Bad: Missing GiST for Range Data
```sql
-- ❌ No exclusion constraint, allows double-booking
CREATE TABLE reservations (
  id BIGSERIAL PRIMARY KEY,
  room_id BIGINT NOT NULL,
  check_in TIMESTAMPTZ NOT NULL,
  check_out TIMESTAMPTZ NOT NULL
);  -- ❌ Can have overlapping reservations

-- Manual check required (race conditions possible)
```

### Hash Indexes

#### ✅ Good: Hash Index for Equality Queries
```sql
-- Hash index for exact equality (since PostgreSQL 10: crash-safe, replicable)
CREATE TABLE sessions (
  id UUID PRIMARY KEY,
  token TEXT NOT NULL,
  user_id BIGINT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_sessions_token ON sessions USING HASH (token);

-- ✅ Fast equality lookup
SELECT * FROM sessions WHERE token = 'abc123def456';

-- ✅ Use hash index for large text columns with equality queries
CREATE INDEX idx_files_hash ON files USING HASH (sha256_hash);
```

#### ❌ Bad: Hash Index Misuse
```sql
-- ❌ Hash index doesn't support range queries
CREATE INDEX idx_users_created ON users USING HASH (created_at);

-- ❌ Index not used
SELECT * FROM users WHERE created_at > '2024-01-01';  -- Seq scan

-- ❌ Hash index on low-cardinality column
CREATE INDEX idx_users_active ON users USING HASH (is_active);  -- Use B-tree or skip
```

### Index Maintenance

#### ✅ Good: Regular Index Maintenance
```sql
-- Reindex to rebuild bloated indexes (offline operation)
REINDEX INDEX idx_users_email;
REINDEX TABLE users;  -- Reindex all indexes on table
REINDEX DATABASE mydb;  -- Reindex entire database

-- Concurrent reindex (online, no locks)
REINDEX INDEX CONCURRENTLY idx_users_email;

-- Vacuum to reclaim space and update statistics
VACUUM ANALYZE users;  -- Vacuum and update stats
VACUUM FULL users;     -- Aggressive vacuum (locks table)

-- Monitor index usage
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,  -- Number of index scans
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;  -- Find unused indexes

-- Drop unused indexes
SELECT 
  schemaname || '.' || tablename AS table,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'  -- Keep primary keys
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index bloat
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Auto-vacuum configuration (postgresql.conf)
-- autovacuum = on  (default)
-- autovacuum_max_workers = 3
-- autovacuum_naptime = 1min
```

#### ❌ Bad: No Index Maintenance
```sql
-- ❌ Never reindexing or vacuuming
-- Results in:
-- - Index bloat (wasted disk space)
-- - Slower queries (bloated indexes)
-- - Outdated statistics (poor query plans)
-- - Dead tuples accumulating

-- ❌ Disabling autovacuum
ALTER TABLE large_table SET (autovacuum_enabled = false);  -- ❌ Don't do this
```

## Query Optimization - Complete Guide

### EXPLAIN and EXPLAIN ANALYZE

#### ✅ Good: Using EXPLAIN ANALYZE
```sql
-- EXPLAIN shows the query plan (doesn't execute)
EXPLAIN
SELECT * FROM users WHERE email = 'user@example.com';

/*
Output:
Index Scan using idx_users_email on users  (cost=0.42..8.44 rows=1 width=100)
  Index Cond: (email = 'user@example.com')
*/

-- EXPLAIN ANALYZE executes and shows actual performance
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE customer_id = 123 
  AND created_at > '2024-01-01'
ORDER BY created_at DESC;

/*
Output:
Index Scan using idx_orders_customer_created on orders  
  (cost=0.42..123.45 rows=50 width=100) 
  (actual time=0.012..0.234 rows=42 loops=1)
  Index Cond: ((customer_id = 123) AND (created_at > '2024-01-01'))
Planning Time: 0.123 ms
Execution Time: 0.456 ms
*/

-- EXPLAIN with additional options
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, COSTS, TIMING)
SELECT 
  o.id,
  o.total,
  c.name
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.created_at > NOW() - INTERVAL '30 days';

-- Interpret key metrics:
-- - cost: estimated startup/total cost (lower is better)
-- - rows: estimated/actual row count
-- - width: average row size in bytes
-- - actual time: actual startup/total time in ms
-- - loops: number of times node was executed
```

#### ❌ Bad: Ignoring Query Plans
```sql
-- ❌ Writing queries without checking execution plan
SELECT * FROM orders WHERE EXTRACT(YEAR FROM created_at) = 2024;  
-- ❌ Function on column prevents index usage

-- ✅ Better: Use range query
SELECT * FROM orders WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01';

-- ❌ Slow query without investigation
SELECT * FROM large_table WHERE status = 'active';  -- Seq scan on 10M rows
-- ✅ Check with EXPLAIN ANALYZE and add index if needed
```

### Reading Query Plans

#### ✅ Good: Understanding Scan Types
```sql
-- Sequential Scan (reads entire table)
EXPLAIN ANALYZE
SELECT * FROM users WHERE last_login < NOW() - INTERVAL '1 year';
/*
Seq Scan on users  (cost=0.00..1234.56 rows=100 width=100)
  Filter: (last_login < (now() - '1 year'))
  Rows Removed by Filter: 9900
-- ✅ Seq scan OK for small tables or when returning most rows
*/

-- Index Scan (uses index to find rows, then fetches from table)
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user@example.com';
/*
Index Scan using idx_users_email on users  (cost=0.42..8.44 rows=1 width=100)
  Index Cond: (email = 'user@example.com')
-- ✅ Efficient for selective queries
*/

-- Index Only Scan (all data in index, no table access)
EXPLAIN ANALYZE
SELECT email FROM users WHERE email LIKE 'user%';
/*
Index Only Scan using idx_users_email on users  (cost=0.42..12.34 rows=10 width=50)
  Index Cond: (email >= 'user' AND email < 'usfs')
  Heap Fetches: 0
-- ✅ Most efficient: no table access needed
*/

-- Bitmap Index Scan (combines multiple indexes)
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE category_id = 5 AND price > 100;
/*
Bitmap Heap Scan on products  (cost=12.34..234.56 rows=50 width=100)
  Recheck Cond: ((category_id = 5) AND (price > 100))
  ->  BitmapAnd  (cost=12.34..12.34 rows=50 width=0)
        ->  Bitmap Index Scan on idx_products_category  (cost=0.00..4.56 rows=100 width=0)
        ->  Bitmap Index Scan on idx_products_price  (cost=0.00..7.78 rows=200 width=0)
-- ✅ Combines two indexes efficiently
*/
```

#### ❌ Bad: Ignoring Plan Warnings
```sql
-- ❌ Large estimated vs actual row mismatch (outdated statistics)
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'pending';
/*
Seq Scan on orders  (cost=0.00..1234.56 rows=100 width=100) 
                    (actual time=0.123..45.678 rows=50000 loops=1)
-- ❌ Estimated 100 rows, actual 50000! Run ANALYZE
*/

-- ✅ Update statistics
ANALYZE orders;

-- ❌ High "Rows Removed by Filter" (missing index)
EXPLAIN ANALYZE
SELECT * FROM users WHERE username = 'john';
/*
Seq Scan on users  (cost=0.00..1234.56 rows=1 width=100)
  Filter: (username = 'john')
  Rows Removed by Filter: 99999
-- ❌ Scanned 100K rows to find 1! Add index on username
*/
```

### Join Optimization

#### ✅ Good: Efficient Joins
```sql
-- Nested Loop Join (small result sets, indexed join column)
EXPLAIN ANALYZE
SELECT 
  o.id,
  c.name,
  o.total
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.created_at > NOW() - INTERVAL '7 days';
/*
Nested Loop  (cost=0.42..123.45 rows=10 width=100)
  ->  Index Scan using idx_orders_created on orders o  (cost=0.42..45.67 rows=10 width=100)
  ->  Index Scan using customers_pkey on customers c  (cost=0.42..7.78 rows=1 width=50)
-- ✅ Efficient for small result sets
*/

-- Hash Join (large result sets, equality conditions)
EXPLAIN ANALYZE
SELECT 
  o.id,
  c.name,
  SUM(oi.quantity * oi.price) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
WHERE o.created_at > '2024-01-01'
GROUP BY o.id, c.name;
/*
Hash Join  (cost=1234.56..5678.90 rows=1000 width=100)
  Hash Cond: (o.customer_id = c.id)
  ->  Seq Scan on orders o  (cost=0.00..1234.56 rows=1000 width=100)
  ->  Hash  (cost=234.56..234.56 rows=5000 width=50)
        ->  Seq Scan on customers c  (cost=0.00..234.56 rows=5000 width=50)
-- ✅ Builds hash table in memory for fast lookups
*/

-- Merge Join (both inputs sorted, equality conditions)
EXPLAIN ANALYZE
SELECT 
  a.id,
  b.value
FROM large_table_a a
JOIN large_table_b b ON a.key = b.key
ORDER BY a.key;
/*
Merge Join  (cost=1234.56..5678.90 rows=10000 width=100)
  Merge Cond: (a.key = b.key)
  ->  Index Scan using idx_a_key on large_table_a a  (cost=0.42..2345.67 rows=10000 width=100)
  ->  Index Scan using idx_b_key on large_table_b b  (cost=0.42..2345.67 rows=10000 width=50)
-- ✅ Efficient when both sides are sorted by join key
*/

-- Use JOIN instead of subquery for better optimization
-- ✅ Good: JOIN
SELECT 
  c.name,
  COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- ❌ Bad: Correlated subquery (executes once per row)
SELECT 
  c.name,
  (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c;
```

#### ❌ Bad: Inefficient Joins
```sql
-- ❌ Cross join (Cartesian product)
SELECT * FROM customers, orders;  -- ❌ Returns customers * orders rows

-- ❌ Missing join condition
SELECT * FROM customers c
JOIN orders o ON true  -- ❌ Cross join
WHERE c.id = 123;

-- ❌ Join on non-indexed column
SELECT * FROM orders o
JOIN customers c ON LOWER(o.customer_email) = LOWER(c.email);  
-- ❌ Function prevents index usage

-- ✅ Better: Index expression
CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));
```

### Subqueries vs CTEs vs JOINs

#### ✅ Good: Choosing the Right Approach
```sql
-- ✅ CTE for readability and reuse
WITH active_customers AS (
  SELECT id, name, email
  FROM customers
  WHERE is_active = true
),
recent_orders AS (
  SELECT customer_id, COUNT(*) AS order_count, SUM(total) AS total_spent
  FROM orders
  WHERE created_at > NOW() - INTERVAL '30 days'
  GROUP BY customer_id
)
SELECT 
  ac.name,
  ac.email,
  COALESCE(ro.order_count, 0) AS order_count,
  COALESCE(ro.total_spent, 0) AS total_spent
FROM active_customers ac
LEFT JOIN recent_orders ro ON ac.id = ro.customer_id
ORDER BY ro.total_spent DESC NULLS LAST;

-- ✅ JOIN for simple relationships
SELECT 
  o.id,
  c.name,
  o.total
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.created_at > '2024-01-01';

-- ✅ IN with subquery (for small result sets)
SELECT * FROM products
WHERE category_id IN (
  SELECT id FROM categories WHERE name LIKE 'Electronics%'
);

-- ✅ EXISTS for checking existence (stops at first match)
SELECT c.name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.id AND o.total > 1000
);

-- ✅ NOT EXISTS (more efficient than NOT IN with NULLs)
SELECT c.name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.id
);

-- ✅ Recursive CTE for hierarchical data
WITH RECURSIVE org_chart AS (
  -- Base case: top-level managers
  SELECT id, name, manager_id, 1 AS level
  FROM employees
  WHERE manager_id IS NULL
  
  UNION ALL
  
  -- Recursive case: employees under managers
  SELECT e.id, e.name, e.manager_id, oc.level + 1
  FROM employees e
  JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart ORDER BY level, name;
```

#### ❌ Bad: Inefficient Subqueries
```sql
-- ❌ Correlated subquery in SELECT (executes for each row)
SELECT 
  c.name,
  (SELECT COUNT(*) FROM orders WHERE customer_id = c.id) AS order_count,
  (SELECT SUM(total) FROM orders WHERE customer_id = c.id) AS total_spent
FROM customers c;

-- ✅ Better: Single JOIN
SELECT 
  c.name,
  COUNT(o.id) AS order_count,
  COALESCE(SUM(o.total), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- ❌ NOT IN with nullable column (performance issue + wrong results)
SELECT * FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders);  
-- ❌ Returns no rows if any customer_id IS NULL

-- ✅ Better: NOT EXISTS or LEFT JOIN
SELECT c.*
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);
```

## Transactions & Concurrency - Complete Guide

### ACID Properties

#### ✅ Good: Understanding ACID
```sql
-- Atomicity: All or nothing
BEGIN;

-- Transfer money between accounts
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- Both updates succeed or both fail
COMMIT;  -- Or ROLLBACK if error

-- Consistency: Constraints enforced
BEGIN;

INSERT INTO orders (customer_id, total) 
VALUES (999, -100);  -- ❌ Violates CHECK constraint

-- Transaction automatically rolled back on error

-- Isolation: Concurrent transactions don't interfere (see isolation levels)

-- Durability: Committed data survives crashes (Write-Ahead Logging)
```

### Transaction Isolation Levels

#### ✅ Good: Choosing the Right Isolation Level
```sql
-- Read Committed (PostgreSQL default)
-- - Prevents dirty reads
-- - Allows non-repeatable reads and phantom reads
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE id = 1;  -- Returns 100
-- Another transaction commits: UPDATE accounts SET balance = 200 WHERE id = 1
SELECT balance FROM accounts WHERE id = 1;  -- Returns 200 (non-repeatable read)

COMMIT;

-- Repeatable Read (most common for application logic)
-- - Prevents dirty reads and non-repeatable reads
-- - Still allows phantom reads
-- - Uses snapshot isolation (sees snapshot at transaction start)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM products WHERE price > 100;  -- Returns 10 rows
-- Another transaction inserts: INSERT INTO products VALUES (..., 150)
SELECT * FROM products WHERE price > 100;  -- Still returns 10 rows (phantom prevented)

COMMIT;

-- Serializable (strictest, may cause serialization failures)
-- - Prevents all anomalies (dirty, non-repeatable, phantom reads)
-- - May abort transactions to prevent write skew
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Transfer logic
SELECT balance FROM accounts WHERE id = 1;  -- 100
SELECT balance FROM accounts WHERE id = 2;  -- 50

-- If another transaction modifies these rows concurrently:
-- ERROR: could not serialize access due to concurrent update

UPDATE accounts SET balance = balance - 50 WHERE id = 1;
UPDATE accounts SET balance = balance + 50 WHERE id = 2;

COMMIT;  -- May fail with serialization error

-- ✅ Set default isolation level in postgresql.conf
-- default_transaction_isolation = 'repeatable read'
```

#### ❌ Bad: Wrong Isolation Level
```sql
-- ❌ Using Read Committed for financial transactions (race conditions)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Check balance
SELECT balance FROM accounts WHERE id = 1;  -- Returns 100

-- Another transaction withdraws $50 (balance now 50)

-- Withdraw $60 (overdraft!)
UPDATE accounts SET balance = balance - 60 WHERE id = 1;  -- Balance now -10

COMMIT;  -- ❌ Overdraft!

-- ✅ Better: Use Repeatable Read or Serializable with constraint
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE accounts SET balance = balance - 60 WHERE id = 1;

-- ❌ If concurrent transaction modified balance, this will fail
-- Or use CHECK constraint: CHECK (balance >= 0)

COMMIT;
```

### MVCC (Multi-Version Concurrency Control)

#### ✅ Good: Understanding MVCC
```sql
-- PostgreSQL creates new row versions instead of locking
-- Each transaction sees a snapshot of data

-- Transaction 1 (reads don't block writes)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM products WHERE id = 1;  -- Version 1, price = 100
-- ... long-running transaction

-- Transaction 2 (writes don't block reads)
BEGIN;
UPDATE products SET price = 120 WHERE id = 1;  -- Creates version 2
COMMIT;

-- Transaction 1 continues
SELECT * FROM products WHERE id = 1;  -- Still sees version 1, price = 100
COMMIT;

-- ✅ No locks needed for reads (except SERIALIZABLE)
-- ✅ Reads don't block writes, writes don't block reads
-- ✅ Each transaction sees consistent snapshot

-- Dead tuples cleanup (old versions)
VACUUM products;  -- Reclaims space from old row versions
```

#### ❌ Bad: Ignoring MVCC Implications
```sql
-- ❌ Long-running transactions prevent VACUUM
BEGIN;
SELECT * FROM large_table WHERE id = 1;
-- ... transaction open for hours
COMMIT;

-- ❌ Table bloat: old row versions can't be reclaimed
-- ❌ Performance degrades over time

-- ✅ Keep transactions short
-- ✅ Use connection pooling to avoid idle transactions
```

### Locking

#### ✅ Good: Explicit Locking When Needed
```sql
-- SELECT FOR UPDATE (locks rows for update)
BEGIN;

SELECT * FROM inventory 
WHERE product_id = 123 
FOR UPDATE;  -- Locks row, prevents other updates

-- Check stock
UPDATE inventory SET quantity = quantity - 1 
WHERE product_id = 123 AND quantity > 0;

COMMIT;

-- SELECT FOR SHARE (locks rows for read, allows other readers)
BEGIN;

SELECT * FROM orders WHERE id = 456 FOR SHARE;  -- Shared lock

-- Other transactions can read but not update

COMMIT;

-- SKIP LOCKED (skip locked rows, useful for job queues)
BEGIN;

SELECT * FROM jobs 
WHERE status = 'pending' 
ORDER BY created_at 
LIMIT 1 
FOR UPDATE SKIP LOCKED;  -- Skip if locked by another worker

-- Process job
UPDATE jobs SET status = 'processing' WHERE id = ...;

COMMIT;

-- NOWAIT (fail immediately if locked)
BEGIN;

SELECT * FROM accounts WHERE id = 1 FOR UPDATE NOWAIT;
-- ERROR: could not obtain lock on row in relation "accounts"

COMMIT;

-- Advisory locks (application-level locking)
-- Lock on arbitrary ID (e.g., user ID)
SELECT pg_advisory_lock(12345);  -- Blocks until lock acquired

-- Do work...

SELECT pg_advisory_unlock(12345);  -- Release lock

-- Try lock (non-blocking)
SELECT pg_try_advisory_lock(12345);  -- Returns true/false
```

#### ❌ Bad: Deadlocks and Lock Contention
```sql
-- ❌ Deadlock scenario

-- Transaction 1
BEGIN;
UPDATE accounts SET balance = balance - 10 WHERE id = 1;  -- Locks row 1
-- ... waiting
UPDATE accounts SET balance = balance + 10 WHERE id = 2;  -- Waits for row 2 lock
COMMIT;

-- Transaction 2 (concurrent)
BEGIN;
UPDATE accounts SET balance = balance - 5 WHERE id = 2;   -- Locks row 2
UPDATE accounts SET balance = balance + 5 WHERE id = 1;   -- Waits for row 1 lock (DEADLOCK!)
-- ERROR: deadlock detected

-- ✅ Prevention: Always acquire locks in the same order
BEGIN;
UPDATE accounts SET balance = balance - 10 WHERE id = LEAST(1, 2);
UPDATE accounts SET balance = balance + 10 WHERE id = GREATEST(1, 2);
COMMIT;

-- ❌ Too coarse-grained locking
LOCK TABLE products IN EXCLUSIVE MODE;  -- ❌ Locks entire table
-- ✅ Use row-level locking instead
```

### Best Practices

#### ✅ Good: Transaction Best Practices
```sql
-- ✅ Keep transactions short
BEGIN;
-- Quick operations only
UPDATE users SET last_login = NOW() WHERE id = 123;
COMMIT;

-- ❌ Don't do this
BEGIN;
-- Slow external API call
-- Long computation
-- User input
COMMIT;  -- ❌ Transaction open too long

-- ✅ Use appropriate isolation level
-- Read Committed: default, good for most cases
-- Repeatable Read: financial transactions, reports
-- Serializable: strict consistency requirements

-- ✅ Handle serialization failures
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Retry logic
DECLARE
  max_retries INT := 3;
  retry_count INT := 0;
BEGIN
  LOOP
    BEGIN
      -- Transaction logic
      UPDATE accounts SET balance = balance - 100 WHERE id = 1;
      EXIT;  -- Success
    EXCEPTION
      WHEN serialization_failure THEN
        retry_count := retry_count + 1;
        IF retry_count >= max_retries THEN
          RAISE;
        END IF;
    END;
  END LOOP;
END;

COMMIT;

-- ✅ Use savepoints for partial rollback
BEGIN;

INSERT INTO orders (customer_id, total) VALUES (123, 100);

SAVEPOINT before_items;

INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 1, 5);
-- Error occurs
ROLLBACK TO SAVEPOINT before_items;  -- Undo items, keep order

INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 2, 3);

COMMIT;
```

## Advanced SQL Features - Complete Guide

### Common Table Expressions (CTEs)

#### ✅ Good: Using CTEs Effectively
```sql
-- Basic CTE for readability
WITH high_value_customers AS (
  SELECT 
    customer_id,
    SUM(total) AS total_spent
  FROM orders
  WHERE created_at > NOW() - INTERVAL '1 year'
  GROUP BY customer_id
  HAVING SUM(total) > 10000
)
SELECT 
  c.name,
  c.email,
  hvc.total_spent
FROM high_value_customers hvc
JOIN customers c ON hvc.customer_id = c.id
ORDER BY hvc.total_spent DESC;

-- Multiple CTEs
WITH 
category_sales AS (
  SELECT 
    c.id AS category_id,
    c.name AS category_name,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity * oi.price) AS revenue
  FROM categories c
  JOIN products p ON c.id = p.category_id
  JOIN order_items oi ON p.id = oi.product_id
  JOIN orders o ON oi.order_id = o.id
  WHERE o.created_at > NOW() - INTERVAL '30 days'
  GROUP BY c.id, c.name
),
top_categories AS (
  SELECT category_id
  FROM category_sales
  ORDER BY revenue DESC
  LIMIT 5
)
SELECT 
  cs.category_name,
  cs.order_count,
  cs.revenue
FROM category_sales cs
JOIN top_categories tc ON cs.category_id = tc.category_id
ORDER BY cs.revenue DESC;

-- Recursive CTE for hierarchical data
WITH RECURSIVE category_tree AS (
  -- Base: top-level categories
  SELECT 
    id,
    name,
    parent_id,
    1 AS level,
    name::TEXT AS path
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  -- Recursive: child categories
  SELECT 
    c.id,
    c.name,
    c.parent_id,
    ct.level + 1,
    ct.path || ' > ' || c.name
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT 
  id,
  REPEAT('  ', level - 1) || name AS indented_name,
  level,
  path
FROM category_tree
ORDER BY path;

-- Recursive CTE for graph traversal (find all dependencies)
WITH RECURSIVE dependency_tree AS (
  -- Base: direct dependencies
  SELECT 
    package_id,
    dependency_id,
    1 AS depth
  FROM package_dependencies
  WHERE package_id = 123
  
  UNION ALL
  
  -- Recursive: transitive dependencies
  SELECT 
    pd.package_id,
    pd.dependency_id,
    dt.depth + 1
  FROM package_dependencies pd
  JOIN dependency_tree dt ON pd.package_id = dt.dependency_id
  WHERE dt.depth < 10  -- Prevent infinite loops
)
SELECT DISTINCT
  p.name,
  dt.depth
FROM dependency_tree dt
JOIN packages p ON dt.dependency_id = p.id
ORDER BY dt.depth, p.name;
```

#### ❌ Bad: CTE Misuse
```sql
-- ❌ Unnecessary CTE (adds overhead)
WITH all_users AS (
  SELECT * FROM users
)
SELECT * FROM all_users WHERE id = 123;

-- ✅ Better: Direct query
SELECT * FROM users WHERE id = 123;

-- ❌ CTE used only once (no benefit)
WITH recent_orders AS (
  SELECT * FROM orders WHERE created_at > NOW() - INTERVAL '7 days'
)
SELECT COUNT(*) FROM recent_orders;

-- ✅ Better: Subquery or direct query
SELECT COUNT(*) FROM orders WHERE created_at > NOW() - INTERVAL '7 days';
```

### Window Functions

#### ✅ Good: Window Function Patterns
```sql
-- ROW_NUMBER: Assign unique sequential numbers
SELECT 
  customer_id,
  order_id,
  total,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS row_num
FROM orders;

-- RANK and DENSE_RANK: Handle ties
SELECT 
  name,
  score,
  RANK() OVER (ORDER BY score DESC) AS rank,        -- 1, 2, 2, 4
  DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank  -- 1, 2, 2, 3
FROM students;

-- LAG and LEAD: Access previous/next row
SELECT 
  date,
  revenue,
  LAG(revenue, 1) OVER (ORDER BY date) AS prev_day_revenue,
  LEAD(revenue, 1) OVER (ORDER BY date) AS next_day_revenue,
  revenue - LAG(revenue, 1) OVER (ORDER BY date) AS day_over_day_change
FROM daily_sales
ORDER BY date;

-- FIRST_VALUE and LAST_VALUE
SELECT 
  product_id,
  date,
  price,
  FIRST_VALUE(price) OVER (PARTITION BY product_id ORDER BY date) AS initial_price,
  LAST_VALUE(price) OVER (
    PARTITION BY product_id 
    ORDER BY date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS final_price
FROM price_history;

-- Running totals and moving averages
SELECT 
  date,
  revenue,
  SUM(revenue) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
  AVG(revenue) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM daily_sales
ORDER BY date;

-- Percentiles and NTile
SELECT 
  name,
  salary,
  NTILE(4) OVER (ORDER BY salary) AS quartile,
  PERCENT_RANK() OVER (ORDER BY salary) AS percent_rank,
  CUME_DIST() OVER (ORDER BY salary) AS cumulative_dist
FROM employees;

-- Top N per group
SELECT *
FROM (
  SELECT 
    category_id,
    product_id,
    name,
    sales,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY sales DESC) AS rank
  FROM products
) ranked
WHERE rank <= 3;  -- Top 3 products per category
```

#### ❌ Bad: Window Function Misuse
```sql
-- ❌ Using window function when simple aggregate suffices
SELECT 
  customer_id,
  SUM(total) OVER (PARTITION BY customer_id) AS total_spent
FROM orders;

-- ✅ Better: GROUP BY
SELECT 
  customer_id,
  SUM(total) AS total_spent
FROM orders
GROUP BY customer_id;

-- ❌ Missing PARTITION BY (operates on entire result set)
SELECT 
  product_id,
  date,
  price,
  AVG(price) OVER (ORDER BY date)  -- ❌ Global average, not per product
FROM prices;

-- ✅ Better: Add PARTITION BY
SELECT 
  product_id,
  date,
  price,
  AVG(price) OVER (PARTITION BY product_id ORDER BY date) AS avg_price
FROM prices;
```

### JSONB Operations

#### ✅ Good: Working with JSONB
```sql
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  event_type VARCHAR(50) NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_events_data ON events USING GIN (data);

-- Insert JSONB data
INSERT INTO events (event_type, data) VALUES
('page_view', '{"user_id": 123, "page": "/products", "duration": 45}'),
('purchase', '{"user_id": 123, "product_id": 456, "amount": 99.99, "currency": "USD"}');

-- Query JSONB fields
SELECT * FROM events WHERE data @> '{"user_id": 123}';  -- Contains
SELECT * FROM events WHERE data ? 'product_id';          -- Key exists
SELECT * FROM events WHERE data ->> 'page' = '/products';  -- Extract text

-- Extract JSONB values
SELECT 
  id,
  data -> 'user_id' AS user_id_json,        -- Returns JSONB
  data ->> 'user_id' AS user_id_text,       -- Returns text
  (data ->> 'user_id')::BIGINT AS user_id,  -- Cast to integer
  data -> 'metadata' -> 'ip' AS ip_address  -- Nested access
FROM events;

-- Update JSONB fields
UPDATE events
SET data = jsonb_set(data, '{amount}', '149.99')
WHERE id = 1;

-- Add new field
UPDATE events
SET data = data || '{"processed": true}'::jsonb
WHERE event_type = 'purchase';

-- Remove field
UPDATE events
SET data = data - 'temporary_field'
WHERE id = 1;

-- Array operations
SELECT * FROM events WHERE data -> 'tags' @> '["urgent"]';  -- Array contains

-- Aggregate JSONB
SELECT 
  event_type,
  jsonb_agg(data) AS all_events,
  jsonb_object_agg(id::text, data) AS events_by_id
FROM events
GROUP BY event_type;
```

### Array Operations

#### ✅ Good: Working with Arrays
```sql
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  tags TEXT[],
  prices NUMERIC[]
);

CREATE INDEX idx_products_tags ON products USING GIN (tags);

-- Insert array data
INSERT INTO products (name, tags, prices) VALUES
('Laptop', ARRAY['electronics', 'computers', 'portable'], ARRAY[999.99, 1299.99, 1599.99]);

-- Query arrays
SELECT * FROM products WHERE 'electronics' = ANY(tags);        -- Contains element
SELECT * FROM products WHERE tags @> ARRAY['electronics'];     -- Contains all
SELECT * FROM products WHERE tags && ARRAY['computers', 'mobile'];  -- Overlaps

-- Array functions
SELECT 
  name,
  array_length(tags, 1) AS tag_count,
  array_upper(prices, 1) AS price_count,
  prices[1] AS lowest_price,
  prices[array_upper(prices, 1)] AS highest_price
FROM products;

-- Unnest array to rows
SELECT 
  p.id,
  p.name,
  unnest(p.tags) AS tag
FROM products p;

-- Array aggregation
SELECT 
  category_id,
  array_agg(name ORDER BY name) AS product_names,
  array_agg(DISTINCT tag) AS all_tags
FROM products
CROSS JOIN unnest(tags) AS tag
GROUP BY category_id;
```

## Performance Tuning - Complete Guide

### Connection Pooling

#### ✅ Good: PgBouncer Configuration
```ini
# /etc/pgbouncer/pgbouncer.ini

[databases]
mydb = host=localhost port=5432 dbname=mydb

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt

# Pool mode
pool_mode = transaction  # transaction (recommended) | session | statement

# Connection limits
max_client_conn = 1000   # Max client connections
default_pool_size = 25   # Connections per user/database
reserve_pool_size = 5    # Extra connections for emergencies
reserve_pool_timeout = 3  # Seconds

# Timeouts
server_idle_timeout = 600    # Close idle server connections after 10 min
server_lifetime = 3600       # Close server connections after 1 hour
query_timeout = 0            # No query timeout
```

```typescript
// Application connection string
const DATABASE_URL = 'postgresql://user:password@localhost:6432/mydb';
```

#### ✅ Good: Supavisor (Supabase Connection Pooler)
```typescript
// Transaction mode (recommended for serverless)
const DATABASE_URL = 'postgresql://postgres.xxxxx.supabase.co:6543/postgres';

// Session mode (for long-lived connections)
const DATABASE_URL = 'postgresql://postgres.xxxxx.supabase.co:5432/postgres';
```

#### ❌ Bad: No Connection Pooling
```typescript
// ❌ Each request creates new connection (slow, exhausts connections)
async function handler(req, res) {
  const client = new Client({
    connectionString: 'postgresql://localhost:5432/mydb'
  });
  await client.connect();  // ❌ Expensive operation
  const result = await client.query('SELECT * FROM users');
  await client.end();
  res.json(result.rows);
}

// ✅ Better: Use connection pool
const pool = new Pool({
  connectionString: 'postgresql://localhost:6432/mydb',  // PgBouncer
  max: 20  // Application-side pool
});

async function handler(req, res) {
  const result = await pool.query('SELECT * FROM users');
  res.json(result.rows);
}
```

### PostgreSQL Configuration

#### ✅ Good: Performance-Oriented postgresql.conf
```ini
# Memory Configuration
shared_buffers = 4GB             # 25% of RAM for dedicated server
effective_cache_size = 12GB      # 75% of RAM (OS + PG cache)
work_mem = 64MB                  # Per operation (sort, hash)
maintenance_work_mem = 1GB       # VACUUM, CREATE INDEX

# Query Planner
random_page_cost = 1.1           # For SSD (default 4 for HDD)
effective_io_concurrency = 200   # For SSD (default 1 for HDD)

# Write-Ahead Log (WAL)
wal_buffers = 16MB
min_wal_size = 2GB
max_wal_size = 8GB
checkpoint_completion_target = 0.9

# Autovacuum (critical for MVCC)
autovacuum = on
autovacuum_max_workers = 4
autovacuum_naptime = 1min
autovacuum_vacuum_scale_factor = 0.1
autovacuum_analyze_scale_factor = 0.05

# Connection Settings
max_connections = 200
```

#### ❌ Bad: Default Configuration for Production
```ini
# ❌ Default settings (designed for minimal systems)
shared_buffers = 128MB           # ❌ Too small for production
work_mem = 4MB                   # ❌ Causes disk sorts
effective_cache_size = 4GB       # ❌ Underestimates available cache
random_page_cost = 4.0           # ❌ Wrong for SSD
```

### Monitoring and Analysis

#### ✅ Good: Essential Monitoring Queries
```sql
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top 10 slowest queries
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time,
  rows
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Most frequently executed queries
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
  pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS table_size,
  pg_size_pretty(pg_indexes_size(schemaname || '.' || tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Index usage statistics
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC;

-- Cache hit ratio (should be > 99%)
SELECT 
  'index hit rate' AS name,
  (sum(idx_blks_hit)) / nullif(sum(idx_blks_hit + idx_blks_read),0) AS ratio
FROM pg_statio_user_indexes
UNION ALL
SELECT 
  'table hit rate' AS name,
  sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0) AS ratio
FROM pg_statio_user_tables;

-- Long-running queries
SELECT 
  pid,
  now() - query_start AS duration,
  state,
  query
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - query_start > interval '5 minutes'
ORDER BY duration DESC;

-- Blocking queries
SELECT 
  blocked_locks.pid AS blocked_pid,
  blocked_activity.usename AS blocked_user,
  blocking_locks.pid AS blocking_pid,
  blocking_activity.usename AS blocking_user,
  blocked_activity.query AS blocked_statement,
  blocking_activity.query AS blocking_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks 
  ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
  AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
  AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
  AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
  AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
  AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
  AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
  AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
  AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

## Best Practices - Complete Guide

### Naming Conventions

#### ✅ Good: Consistent Naming
```sql
-- Tables: plural, snake_case
CREATE TABLE customers (...);
CREATE TABLE order_items (...);

-- Columns: snake_case
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email_address VARCHAR(255),
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- Indexes: idx_table_column(s)
CREATE INDEX idx_users_email ON users(email_address);
CREATE INDEX idx_orders_customer_created ON orders(customer_id, created_at);

-- Foreign keys: fk_table_referenced_table
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers 
  FOREIGN KEY (customer_id) REFERENCES customers(id);

-- Unique constraints: uq_table_column(s)
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email_address);

-- Check constraints: ck_table_description
ALTER TABLE products ADD CONSTRAINT ck_products_price_positive 
  CHECK (price >= 0);
```

#### ❌ Bad: Inconsistent Naming
```sql
-- ❌ Mixed naming conventions
CREATE TABLE Customer (...);           -- ❌ Uppercase
CREATE TABLE order_item (...);         -- ❌ Singular
CREATE TABLE "user-profiles" (...);    -- ❌ Hyphens require quotes

-- ❌ Unclear abbreviations
CREATE TABLE usr (id BIGINT, nm VARCHAR(100), em VARCHAR(255));
```

### Migration Strategies

#### ✅ Good: Safe Migrations
```sql
-- Add column with default (safe in PostgreSQL 11+)
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active' NOT NULL;

-- Add index concurrently (no table lock)
CREATE INDEX CONCURRENTLY idx_users_status ON users(status);

-- Add constraint with NOT VALID (fast), then validate (can be interrupted)
ALTER TABLE orders ADD CONSTRAINT ck_orders_total_positive 
  CHECK (total >= 0) NOT VALID;
  
ALTER TABLE orders VALIDATE CONSTRAINT ck_orders_total_positive;

-- Rename column (atomic, but breaks dependent code)
ALTER TABLE users RENAME COLUMN email TO email_address;

-- Drop column (use after code deployed)
ALTER TABLE users DROP COLUMN deprecated_field;

-- Large data migration in batches
DO $$
DECLARE
  batch_size INT := 1000;
  rows_updated INT;
BEGIN
  LOOP
    UPDATE products
    SET normalized_name = LOWER(name)
    WHERE normalized_name IS NULL
    LIMIT batch_size;
    
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    EXIT WHEN rows_updated = 0;
    
    COMMIT;  -- Release locks between batches
  END LOOP;
END $$;
```

#### ❌ Bad: Dangerous Migrations
```sql
-- ❌ Adding NOT NULL without default (locks table, fails if NULLs exist)
ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL;

-- ❌ Creating index without CONCURRENTLY (locks table for reads/writes)
CREATE INDEX idx_users_email ON users(email);  -- ❌ Locks table

-- ❌ Changing column type (rewrites entire table)
ALTER TABLE users ALTER COLUMN id TYPE BIGINT;  -- ❌ Long lock
```

### Security

#### ✅ Good: Row-Level Security (RLS)
```sql
-- Enable RLS on table
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Users can only see their own documents
CREATE POLICY documents_select_own ON documents
  FOR SELECT
  TO authenticated_users
  USING (user_id = current_user_id());

-- Users can only update their own documents
CREATE POLICY documents_update_own ON documents
  FOR UPDATE
  TO authenticated_users
  USING (user_id = current_user_id())
  WITH CHECK (user_id = current_user_id());

-- Admins can see all documents
CREATE POLICY documents_select_admin ON documents
  FOR SELECT
  TO admin_users
  USING (true);

-- Function to get current user ID (from Supabase auth)
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS BIGINT AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::json->>'sub',
    '0'
  )::BIGINT;
$$ LANGUAGE SQL STABLE;
```

#### ❌ Bad: No Access Control
```sql
-- ❌ No RLS, relying on application code
CREATE TABLE documents (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  content TEXT
);  -- ❌ Anyone can query all documents

-- ✅ Enable RLS for defense in depth
```

### Backup and Recovery

#### ✅ Good: Regular Backups
```bash
# Logical backup (pg_dump)
pg_dump -h localhost -U postgres -d mydb -F c -f mydb_backup.dump

# Restore
pg_restore -h localhost -U postgres -d mydb -c mydb_backup.dump

# Continuous archiving (WAL)
# postgresql.conf
archive_mode = on
archive_command = 'cp %p /path/to/archive/%f'

# Point-in-time recovery (PITR)
pg_basebackup -h localhost -U postgres -D /path/to/backup -Fp -Xs -P
```

### Links and References

- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/current/)
- [PostgreSQL Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
- [PostgreSQL Query Planning](https://www.postgresql.org/docs/current/performance-tips.html)
- [PostgreSQL Transaction Isolation](https://www.postgresql.org/docs/current/transaction-iso.html)
- [PostgreSQL MVCC](https://www.postgresql.org/docs/current/mvcc.html)
- [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html)
- [PgBouncer Documentation](https://www.pgbouncer.org/)
