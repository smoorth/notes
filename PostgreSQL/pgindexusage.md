# PostgreSQL Index usage and performance tuning

- [PostgreSQL Index usage and performance tuning](#postgresql-index-usage-and-performance-tuning)
  - [1. Get Index Usage (pg\_stat\_user\_indexes)](#1-get-index-usage-pg_stat_user_indexes)
  - [2. Get Number of Reads and Writes (pg\_stat\_all\_tables)](#2-get-number-of-reads-and-writes-pg_stat_all_tables)
  - [3. Get Index Suggestions (Using pg\_stat\_statements and EXPLAIN)](#3-get-index-suggestions-using-pg_stat_statements-and-explain)
    - [Step 1: Enable the pg\_stat\_statements extension](#step-1-enable-the-pg_stat_statements-extension)
    - [Step 2: Query slow-running or heavily used queries](#step-2-query-slow-running-or-heavily-used-queries)
    - [Step 3: Use EXPLAIN or EXPLAIN ANALYZE to check the query execution plan and see if an index can help improve performance](#step-3-use-explain-or-explain-analyze-to-check-the-query-execution-plan-and-see-if-an-index-can-help-improve-performance)
    - [Step 4: Create the Suggested Index](#step-4-create-the-suggested-index)
  - [4. Optional Tools for Index Optimization](#4-optional-tools-for-index-optimization)

To extract index usage, track the number of reads and writes, and view index suggestions in PostgreSQL, you can leverage PostgreSQL's system views and extensions like pg_stat_user_indexes, pg_stat_all_tables, and pg_stat_statements. Additionally, EXPLAIN and EXPLAIN ANALYZE are useful for getting insights into query performance.

## 1. Get Index Usage (pg_stat_user_indexes)

PostgreSQL keeps statistics on the usage of indexes in the system catalog pg_stat_user_indexes. This includes information on index scans, tuples fetched, etc.

Index usage statistics:

```sql
SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS index_scans,         -- Number of index scans
    idx_tup_read AS tuples_read,     -- Number of tuples read using index
    idx_tup_fetch AS tuples_fetched  -- Number of tuples fetched using index
FROM
    pg_stat_user_indexes
ORDER BY
    idx_scan DESC;  -- Ordered by most used index
```

## 2. Get Number of Reads and Writes (pg_stat_all_tables)

Query the pg_stat_all_tables view to see the number of reads and writes per table.

```sql
SELECT
    schemaname,
    relname AS table_name,
    seq_scan,          -- Number of sequential scans
    seq_tup_read,      -- Number of tuples read in sequential scans
    idx_scan,          -- Number of index scans
    idx_tup_fetch,     -- Number of tuples fetched by index
    n_tup_ins AS inserts,  -- Number of rows inserted
    n_tup_upd AS updates,  -- Number of rows updated
    n_tup_del AS deletes   -- Number of rows deleted
FROM
    pg_stat_all_tables
ORDER BY
    seq_scan DESC;  -- Ordered by most read/written table
```

## 3. Get Index Suggestions (Using pg_stat_statements and EXPLAIN)

### Step 1: Enable the pg_stat_statements extension

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

### Step 2: Query slow-running or heavily used queries

```sql
SELECT
    query,
    calls,                -- Number of times query was executed
    total_time,           -- Total time spent on query
    rows,                 -- Number of rows retrieved
    shared_blks_hit,      -- Number of shared blocks read from cache
    shared_blks_read      -- Number of blocks fetched from disk (higher is worse)
FROM
    pg_stat_statements
ORDER BY
    total_time DESC       -- Show most time-consuming queries
LIMIT 10;
```

### Step 3: Use EXPLAIN or EXPLAIN ANALYZE to check the query execution plan and see if an index can help improve performance

```sql
EXPLAIN ANALYZE
SELECT *
FROM your_table
WHERE some_column = some_value;
```

This will show if the query uses an index, and how efficient the plan is. If you see sequential scans (Seq Scan) on large tables, it might be a good idea to create an index.

### Step 4: Create the Suggested Index

If you find a query that performs poorly and could benefit from an index, you can create one:

```sql
CREATE INDEX idx_your_table_some_column
ON your_table (some_column);
```

You can also test the impact of index creation using **EXPLAIN ANALYZE** again after creating the index to see if query performance improves.

## 4. Optional Tools for Index Optimization

There are third-party tools and extensions for PostgreSQL that can help with index optimization:

- **pg_hint_plan**: Allows you to provide hints for query execution, suggesting the use of particular indexes.
- **pg_repack**: Helps you with removing bloat from indexes and tables, which can improve performance.

By combining these views and methods, you can monitor and optimize index usage, track reads and writes, and identify queries that would benefit from additional indexing.
