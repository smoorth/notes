# PostgreSQL Database Design Best Practices: Handling Keys, Constraints, and Data Integrity

## Table of Contents

1. [Introduction](#introduction)
2. [Primary Keys and Unique Identifiers](#primary-keys-and-unique-identifiers)
3. [Handling Missing Primary Keys](#handling-missing-primary-keys)
4. [Identifying and Removing Duplicate Workload IDs](#identifying-and-removing-duplicate-workload-ids)
5. [Designing Effective Constraints](#designing-effective-constraints)
6. [Testing Database Integrity](#testing-database-integrity)
7. [API-Specific Considerations](#api-specific-considerations)
8. [Maintenance and Performance](#maintenance-and-performance)

## Introduction

A well-designed PostgreSQL database is crucial for the reliability, performance, and maintainability of your API. This guide focuses on best practices for handling primary keys, unique constraints, and data integrity to build robust PostgreSQL databases for API environments.

## Primary Keys and Unique Identifiers

### Importance of Primary Keys

Primary keys serve several critical functions:

- Ensure each row in a table can be uniquely identified
- Improve query performance through clustered indexes
- Enable relationships between tables
- Prevent duplicate data entry

### Types of Primary Keys

1. **Natural Keys**: Values that naturally exist in your data and are inherently unique
    - Examples: SSN, ISBN, product codes
    - Pros: Meaningful, no additional storage
    - Cons: May change, may be complex

2. **Surrogate Keys**: Artificially generated unique values
    - Examples: Auto-incrementing integers, UUIDs
    - Pros: Never change, simple
    - Cons: No business meaning, additional storage

### Recommended Approaches for API Environments

For API-centric applications:

- Use `BIGSERIAL` for internal services with predictable scaling
- Use `UUID` for distributed systems, microservices, or public-facing APIs:

```sql
CREATE TABLE api_users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## Handling Missing Primary Keys

### Identifying Tables Without Primary Keys

```sql
SELECT
    c.table_schema,
    c.table_name
FROM
    information_schema.tables c
WHERE
    c.table_schema NOT IN ('pg_catalog', 'information_schema')
    AND c.table_type = 'BASE TABLE'
    AND NOT EXISTS (
        SELECT 1
        FROM information_schema.key_column_usage k
        JOIN information_schema.table_constraints tc
            ON k.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'PRIMARY KEY'
            AND k.table_name = c.table_name
            AND k.table_schema = c.table_schema
    )
ORDER BY c.table_schema, c.table_name;
```

### Adding Primary Keys to Existing Tables

**When a natural unique column exists**:

```sql
-- First, verify uniqueness
SELECT column_name, COUNT(*)
FROM table_name
GROUP BY column_name
HAVING COUNT(*) > 1;

-- If no duplicates, add primary key
ALTER TABLE table_name ADD PRIMARY KEY (column_name);
```

**When no natural unique column exists**:

```sql
-- Add a surrogate key
ALTER TABLE table_name ADD COLUMN id SERIAL PRIMARY KEY;
```

**When there's a composite natural key**:

```sql
ALTER TABLE table_name ADD PRIMARY KEY (column1, column2);
```

### Dealing with Duplicate Data When Adding a Primary Key

If duplicates exist, you'll need to decide how to handle them:

```sql
-- Option 1: Keep the first occurrence of each duplicate and delete the rest
DELETE FROM table_name
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
        ROW_NUMBER() OVER (PARTITION BY column_with_dupes ORDER BY id) as row_num
        FROM table_name
    ) t
    WHERE t.row_num > 1
);

-- Option 2: Merge data from duplicate rows if needed
-- (This is highly specific to your data model and business logic)
```

## Identifying and Removing Duplicate Workload IDs

### Finding Duplicates

```sql
SELECT workload_id, COUNT(*)
FROM workloads
GROUP BY workload_id
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
```

### Analyzing Duplicates

```sql
-- Get complete information about duplicates
SELECT *
FROM workloads
WHERE workload_id IN (
    SELECT workload_id
    FROM workloads
    GROUP BY workload_id
    HAVING COUNT(*) > 1
)
ORDER BY workload_id;
```

### Removing Duplicates

Approach 1: Keep the latest record (or any other criteria-based selection)

```sql
DELETE FROM workloads
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
        ROW_NUMBER() OVER (PARTITION BY workload_id ORDER BY created_at DESC) as row_num
        FROM workloads
    ) t
    WHERE t.row_num > 1
);
```

Approach 2: Backup and recreate with unique constraints

```sql
-- 1. Create backup
CREATE TABLE workloads_backup AS SELECT * FROM workloads;

-- 2. Create new table with constraint
CREATE TABLE workloads_new (
    id SERIAL PRIMARY KEY,
    workload_id VARCHAR(50) UNIQUE NOT NULL,
    -- other columns...
);

-- 3. Insert unique rows
INSERT INTO workloads_new (workload_id, ...)
SELECT DISTINCT ON (workload_id) workload_id, ...
FROM workloads
ORDER BY workload_id, created_at DESC;

-- 4. Verify and swap
ALTER TABLE workloads RENAME TO workloads_old;
ALTER TABLE workloads_new RENAME TO workloads;
```

## Designing Effective Constraints

### Types of Constraints

1. **PRIMARY KEY**: Uniquely identifies each row
2. **FOREIGN KEY**: Ensures referential integrity between tables
3. **UNIQUE**: Ensures no duplicates in specific column(s)
4. **CHECK**: Validates data against specific conditions
5. **NOT NULL**: Ensures column doesn't contain null values
6. **EXCLUSION**: Ensures no two rows satisfy a condition

### Constraint Naming Convention

Use descriptive names for easier maintenance:

```sql
ALTER TABLE users ADD CONSTRAINT pk_users PRIMARY KEY (user_id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_user_id FOREIGN KEY (user_id) REFERENCES users(user_id);
ALTER TABLE products ADD CONSTRAINT uq_products_sku UNIQUE (sku);
ALTER TABLE age_groups ADD CONSTRAINT chk_age_groups_range CHECK (min_age < max_age);
```

### Foreign Key Best Practices

```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- ON DELETE options depend on business requirements
    CONSTRAINT fk_orders_user_id FOREIGN KEY (user_id)
        REFERENCES users(user_id) ON DELETE RESTRICT
);
```

Choose the appropriate action clause:

- `ON DELETE RESTRICT` - Prevent deletion of referenced row
- `ON DELETE CASCADE` - Delete dependent rows
- `ON DELETE SET NULL` - Set foreign key to NULL
- `ON DELETE SET DEFAULT` - Set foreign key to default value

### Partial and Deferred Constraints

For API-specific needs:

```sql
-- Allow nulls in unique constraint
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY,
    external_id VARCHAR(100),
    CONSTRAINT uq_user_profiles_external_id UNIQUE (external_id)
    DEFERRABLE INITIALLY IMMEDIATE
);

-- Partial unique constraint
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id UUID NOT NULL,
    draft BOOLEAN DEFAULT TRUE,
    external_ref VARCHAR(50),
    CONSTRAINT uq_orders_external_ref UNIQUE (external_ref)
    WHERE draft = FALSE
);
```

## Testing Database Integrity

### Automated Testing Strategies

1. **Schema Verification Tests**:
   - Check constraint existence
   - Verify column data types
   - Validate default values

2. **CRUD Operation Tests**:
   - Test constraint violations
   - Validate cascading behaviors
   - Verify transaction rollbacks

3. **Example Test for Primary Key**:

```sql
-- Test function
CREATE OR REPLACE FUNCTION test_primary_key_constraint()
RETURNS BOOLEAN AS $$
DECLARE
    result BOOLEAN;
BEGIN
    -- Try to insert duplicate primary key
    BEGIN
        INSERT INTO users (user_id, username) VALUES
        ('12345678-1234-1234-1234-123456789012', 'testuser');

        INSERT INTO users (user_id, username) VALUES
        ('12345678-1234-1234-1234-123456789012', 'testuser2');

        -- If we get here, the constraint failed
        RETURN FALSE;
    EXCEPTION WHEN unique_violation THEN
        -- This is expected
        RETURN TRUE;
    END;
END;
$$ LANGUAGE plpgsql;

-- Run test
SELECT test_primary_key_constraint();
```

### Tools for Database Testing

1. **pgTAP**: PostgreSQL unit testing
2. **pytest-postgresql**: Python testing for PostgreSQL
3. **Liquibase/Flyway**: Test schema changes before deployment

## API-Specific Considerations

### Optimizing for API Workloads

**Connection Pooling**:

- Use PgBouncer for high-concurrency APIs
- Configure appropriate pool sizes based on workload

**Indexing Strategy**:

- Index columns used in API filters
- Consider partial indexes for common query patterns

```sql
-- Index for common API queries
CREATE INDEX idx_products_category_status ON products(category_id) WHERE status = 'active';
```

**JSON/JSONB for Flexible Schemas**:

```sql
CREATE TABLE api_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    payload JSONB NOT NULL,
    -- Index specific JSON paths for queries
    CONSTRAINT chk_valid_payload CHECK (jsonb_typeof(payload) = 'object')
);

CREATE INDEX idx_api_events_payload_customer ON api_events ((payload->>'customer_id'));
```

### API Versioning and Database Evolution

1. **Schema Versioning**:
   - Use schema prefixes for API versions
   - Consider views for backward compatibility

2. **Gradual Migration**:
   - Add constraints in multiple deployments
   - Use deferrable constraints during transition

## Maintenance and Performance

### Monitoring Constraint Health

```sql
-- Find unused indexes (potentially including constraint indexes)
SELECT
    indexrelid::regclass AS index_name,
    relid::regclass AS table_name,
    idx_scan AS index_scans
FROM
    pg_stat_user_indexes
WHERE
    idx_scan = 0
ORDER BY
    table_name, index_name;

-- Find missing indexes (high seq scans)
SELECT
    relname AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM
    pg_stat_user_tables
WHERE
    seq_scan > 0
ORDER BY
    seq_tup_read DESC;
```

### Regular Health Checks

Implement periodic verification of database constraints:

1. Run ANALYZE to update statistics
2. Check for orphaned records (foreign key issues)
3. Verify uniqueness constraints still hold
4. Look for tables missing primary keys

```sql
-- Sample script to find potential foreign key violations
SELECT c.conname AS constraint_name,
       c.conrelid::regclass AS table_name,
       a.attname AS column_name,
       c.confrelid::regclass AS referenced_table,
       af.attname AS referenced_column,
       v.violations
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = ANY(c.confkey)
JOIN LATERAL (
    SELECT COUNT(*) AS violations
    FROM (
        SELECT a.attname::text AS col
        FROM pg_attribute a
        WHERE a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
    ) cols,
    LATERAL (
        SELECT t.*
        FROM c.conrelid::regclass AS t(id)
        LIMIT 1
    ) r
    WHERE NOT EXISTS (
        SELECT 1
        FROM c.confrelid::regclass AS ref
        WHERE ref.id = r.id
    )
) v ON true
WHERE c.contype = 'f'
AND v.violations > 0;
```

## Conclusion

A well-designed PostgreSQL database is essential for building reliable, maintainable API services. By implementing proper primary keys, unique constraints, and following these best practices, you can create a solid foundation that prevents data integrity issues, simplifies debugging, and enhances overall system performance.

Remember that database design decisions should always be guided by your specific API requirements, expected traffic patterns, and business rules. Regular testing and maintenance of your constraints will help ensure continued data integrity as your application evolves.
