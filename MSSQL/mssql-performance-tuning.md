# MSSQL Performance Tuning Guide

## Table of Contents

- [MSSQL Performance Tuning Guide](#mssql-performance-tuning-guide)
  - [Table of Contents](#table-of-contents)
  - [Performance Tuning Fundamentals](#performance-tuning-fundamentals)
    - [Performance Baseline](#performance-baseline)
    - [Performance Methodology](#performance-methodology)
    - [Common Performance Bottlenecks](#common-performance-bottlenecks)
  - [Query Optimization](#query-optimization)
    - [Writing Efficient Queries](#writing-efficient-queries)
    - [Query Hints and Optimization](#query-hints-and-optimization)
    - [Parameter Sniffing Solutions](#parameter-sniffing-solutions)
  - [Index Strategy and Optimization](#index-strategy-and-optimization)
    - [Index Design Principles](#index-design-principles)
    - [Index Analysis and Optimization](#index-analysis-and-optimization)
    - [Automated Index Maintenance](#automated-index-maintenance)
  - [Execution Plan Analysis](#execution-plan-analysis)
    - [Reading Execution Plans](#reading-execution-plans)
    - [Plan Analysis Tools](#plan-analysis-tools)
    - [Plan Cache Analysis](#plan-cache-analysis)
  - [Memory Configuration and Optimization](#memory-configuration-and-optimization)
    - [Memory Configuration](#memory-configuration)
    - [Memory Usage Analysis](#memory-usage-analysis)
  - [I/O Performance Optimization](#io-performance-optimization)
    - [I/O Analysis](#io-analysis)
    - [File Configuration Optimization](#file-configuration-optimization)
    - [TempDB Optimization](#tempdb-optimization)

## Performance Tuning Fundamentals

### Performance Baseline

Before optimizing, establish a baseline to measure improvements:

```sql
-- Create performance baseline
SELECT
    GETDATE() AS baseline_date,
    @@SERVERNAME AS server_name,
    DB_NAME() AS database_name;

-- Capture current wait statistics
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
INTO #baseline_waits
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
    'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
    'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT'
);

-- Capture current performance counters
SELECT
    counter_name,
    instance_name,
    cntr_value,
    cntr_type
INTO #baseline_counters
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%SQL Server%'
    AND counter_name IN (
        'Page life expectancy',
        'Buffer cache hit ratio',
        'SQL Compilations/sec',
        'SQL Re-Compilations/sec',
        'Batch Requests/sec',
        'Transactions/sec'
    );
```

### Performance Methodology

1. **Identify the Problem**: Use monitoring tools to find bottlenecks
2. **Isolate the Cause**: Narrow down to specific queries, indexes, or configuration
3. **Test Solutions**: Apply changes in test environment first
4. **Measure Impact**: Compare before and after metrics
5. **Document Changes**: Keep track of what works

### Common Performance Bottlenecks

```sql
-- CPU bottlenecks
SELECT
    scheduler_id,
    cpu_id,
    status,
    is_online,
    is_idle,
    preemptive_switches_count,
    context_switches_count,
    current_tasks_count,
    runnable_tasks_count,
    current_workers_count,
    active_workers_count,
    work_queue_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;

-- Memory pressure indicators
SELECT
    type,
    pages_kb,
    pages_in_use_kb
FROM sys.dm_os_memory_clerks
WHERE type IN (
    'MEMORYCLERK_SQLBUFFERPOOL',
    'MEMORYCLERK_SQLOPTIMIZER',
    'MEMORYCLERK_SQLGENERAL'
)
ORDER BY pages_kb DESC;

-- I/O bottlenecks
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    vfs.io_stall_read_ms / NULLIF(vfs.num_of_reads, 0) AS avg_read_stall_ms,
    vfs.io_stall_write_ms / NULLIF(vfs.num_of_writes, 0) AS avg_write_stall_ms,
    vfs.size_on_disk_bytes / 1024 / 1024 AS size_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
INNER JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
WHERE vfs.io_stall_read_ms + vfs.io_stall_write_ms > 0
ORDER BY vfs.io_stall_read_ms + vfs.io_stall_write_ms DESC;
```

## Query Optimization

### Writing Efficient Queries

```sql
-- Use SARGABLE predicates (Search ARGument ABLE)
-- Good: Index can be used
SELECT * FROM Orders
WHERE OrderDate >= '2023-01-01'
    AND OrderDate < '2024-01-01';

-- Bad: Function prevents index usage
SELECT * FROM Orders
WHERE YEAR(OrderDate) = 2023;

-- Use specific columns instead of SELECT *
-- Good
SELECT CustomerID, OrderDate, TotalAmount
FROM Orders
WHERE Status = 'Completed';

-- Bad
SELECT * FROM Orders
WHERE Status = 'Completed';

-- Use EXISTS instead of IN for large subqueries
-- Good for large subqueries
SELECT CustomerID, FirstName, LastName
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.CustomerID = c.CustomerID
        AND o.OrderDate >= '2023-01-01'
);

-- Use IN for small, static lists
SELECT * FROM Products
WHERE CategoryID IN (1, 2, 3);

-- Avoid unnecessary ORDER BY in subqueries
-- Bad
SELECT CustomerID FROM (
    SELECT CustomerID FROM Orders
    ORDER BY OrderDate  -- Unnecessary
) subquery;

-- Good
SELECT CustomerID FROM Orders;

-- Use UNION ALL instead of UNION when duplicates are acceptable
-- UNION ALL is faster as it doesn't remove duplicates
SELECT CustomerID FROM Orders WHERE OrderDate >= '2023-01-01'
UNION ALL
SELECT CustomerID FROM Orders WHERE TotalAmount > 1000;
```

### Query Hints and Optimization

```sql
-- Force index usage (use sparingly)
SELECT * FROM Orders WITH (INDEX(IX_Orders_OrderDate))
WHERE OrderDate >= '2023-01-01';

-- Force join order
SELECT /*+ USE_HINT('FORCE_ORDER') */
    c.CustomerID, o.OrderID
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Query hints for specific scenarios
SELECT * FROM LargeTable
WHERE ComplexCondition = 1
OPTION (RECOMPILE, MAXDOP 4);

-- Use query store for plan forcing
-- Enable Query Store
ALTER DATABASE MyDatabase
SET QUERY_STORE = ON (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- Find and force good plans
SELECT
    qsq.query_id,
    qst.query_sql_text,
    qsp.plan_id,
    qrs.avg_duration,
    qrs.count_executions
FROM sys.query_store_query qsq
INNER JOIN sys.query_store_query_text qst ON qsq.query_text_id = qst.query_text_id
INNER JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
INNER JOIN sys.query_store_runtime_stats qrs ON qsp.plan_id = qrs.plan_id
WHERE qst.query_sql_text LIKE '%your_query_pattern%'
ORDER BY qrs.avg_duration;

-- Force a specific plan
EXEC sp_query_store_force_plan @query_id = 123, @plan_id = 456;
```

### Parameter Sniffing Solutions

```sql
-- Problem: Parameter sniffing causes plan cache pollution
CREATE PROCEDURE usp_GetOrdersByDate
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Solution 1: Use OPTION (RECOMPILE)
    SELECT CustomerID, OrderDate, TotalAmount
    FROM Orders
    WHERE OrderDate BETWEEN @StartDate AND @EndDate
    OPTION (RECOMPILE);

    -- Solution 2: Use local variables
    DECLARE @LocalStartDate DATE = @StartDate;
    DECLARE @LocalEndDate DATE = @EndDate;

    SELECT CustomerID, OrderDate, TotalAmount
    FROM Orders
    WHERE OrderDate BETWEEN @LocalStartDate AND @LocalEndDate;

    -- Solution 3: Use OPTION (OPTIMIZE FOR)
    SELECT CustomerID, OrderDate, TotalAmount
    FROM Orders
    WHERE OrderDate BETWEEN @StartDate AND @EndDate
    OPTION (OPTIMIZE FOR (@StartDate = '2023-01-01', @EndDate = '2023-12-31'));
END;

-- Solution 4: Dynamic SQL for complex scenarios
CREATE PROCEDURE usp_GetOrdersByDateDynamic
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = '
        SELECT CustomerID, OrderDate, TotalAmount
        FROM Orders
        WHERE OrderDate BETWEEN @StartDate AND @EndDate';

    EXEC sp_executesql @sql,
        N'@StartDate DATE, @EndDate DATE',
        @StartDate, @EndDate;
END;
```

## Index Strategy and Optimization

### Index Design Principles

```sql
-- Clustered index design
-- Good: Narrow, unique, static, ever-increasing
CREATE CLUSTERED INDEX CIX_Orders_OrderID ON Orders (OrderID);

-- Non-clustered index design
-- Include frequently queried columns
CREATE NONCLUSTERED INDEX IX_Orders_CustomerDate
ON Orders (CustomerID, OrderDate)
INCLUDE (TotalAmount, Status);

-- Covering index for specific queries
CREATE NONCLUSTERED INDEX IX_Orders_Status_Covering
ON Orders (Status)
INCLUDE (CustomerID, OrderDate, TotalAmount)
WHERE Status IN ('Pending', 'Processing');

-- Filtered index for subset of data
CREATE NONCLUSTERED INDEX IX_Orders_RecentActive
ON Orders (OrderDate, CustomerID)
WHERE Status = 'Active' AND OrderDate >= '2023-01-01';

-- Columnstore index for analytics
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders_Analytics
ON Orders (CustomerID, OrderDate, TotalAmount, ProductID, Quantity);
```

### Index Analysis and Optimization

```sql
-- Find missing indexes
SELECT
    mid.statement AS table_name,
    migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_user_impact,
    'CREATE INDEX IX_' +
        REPLACE(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), '.', '_') +
        '_Missing ON ' + mid.statement +
        ' (' + ISNULL(mid.equality_columns, '') +
        CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END +
        ISNULL(mid.inequality_columns, '') + ')' +
        ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY improvement_measure DESC;

-- Find unused indexes
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    STATS_DATE(i.object_id, i.index_id) AS stats_last_updated,
    'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + QUOTENAME(OBJECT_NAME(i.object_id)) AS drop_statement
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE i.type_desc != 'HEAP'
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0
    AND ius.index_id IS NULL
    AND OBJECT_SCHEMA_NAME(i.object_id) != 'sys'
ORDER BY schema_name, table_name, index_name;

-- Index fragmentation analysis
SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    ips.record_count,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000 THEN 'REORGANIZE'
        ELSE 'NO ACTION'
    END AS recommended_action,
    CASE
        WHEN ips.avg_fragmentation_in_percent > 30 AND ips.page_count > 1000 THEN
            'ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(ips.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ips.object_id)) + ' REBUILD WITH (ONLINE = ON);'
        WHEN ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000 THEN
            'ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(ips.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ips.object_id)) + ' REORGANIZE;'
    END AS maintenance_command
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5
    AND ips.page_count > 100
    AND i.name IS NOT NULL
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Index usage statistics
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.user_seeks + ius.user_scans + ius.user_lookups AS total_reads,
    CASE
        WHEN ius.user_updates > 0 THEN
            CAST((ius.user_seeks + ius.user_scans + ius.user_lookups) AS FLOAT) / ius.user_updates
        ELSE 0
    END AS read_write_ratio,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_lookup,
    ius.last_user_update
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = DB_ID()
WHERE i.type_desc != 'HEAP'
    AND OBJECT_SCHEMA_NAME(i.object_id) != 'sys'
ORDER BY total_reads DESC;
```

### Automated Index Maintenance

```sql
-- Automated index maintenance script
CREATE PROCEDURE usp_IndexMaintenance
    @FragmentationThreshold FLOAT = 10.0,
    @RebuildThreshold FLOAT = 30.0,
    @MinPageCount INT = 1000,
    @MaxDOP INT = 0,
    @OnlineRebuild BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @SchemaName SYSNAME, @TableName SYSNAME, @IndexName SYSNAME;
    DECLARE @FragmentationPercent FLOAT, @PageCount BIGINT;

    DECLARE index_cursor CURSOR FOR
    SELECT
        OBJECT_SCHEMA_NAME(ips.object_id),
        OBJECT_NAME(ips.object_id),
        i.name,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
    WHERE ips.avg_fragmentation_in_percent >= @FragmentationThreshold
        AND ips.page_count >= @MinPageCount
        AND i.name IS NOT NULL
        AND i.is_disabled = 0
    ORDER BY ips.avg_fragmentation_in_percent DESC;

    OPEN index_cursor;
    FETCH NEXT FROM index_cursor INTO @SchemaName, @TableName, @IndexName, @FragmentationPercent, @PageCount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @FragmentationPercent >= @RebuildThreshold
        BEGIN
            SET @SQL = 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' REBUILD';

            IF @OnlineRebuild = 1
                SET @SQL = @SQL + ' WITH (ONLINE = ON';
            ELSE
                SET @SQL = @SQL + ' WITH (ONLINE = OFF';

            IF @MaxDOP > 0
                SET @SQL = @SQL + ', MAXDOP = ' + CAST(@MaxDOP AS VARCHAR(2));

            SET @SQL = @SQL + ');';

            PRINT 'Rebuilding: ' + @SQL;
        END
        ELSE
        BEGIN
            SET @SQL = 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' REORGANIZE;';
            PRINT 'Reorganizing: ' + @SQL;
        END

        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Success: ' + @SchemaName + '.' + @TableName + '.' + @IndexName;
        END TRY
        BEGIN CATCH
            PRINT 'Error: ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM index_cursor INTO @SchemaName, @TableName, @IndexName, @FragmentationPercent, @PageCount;
    END

    CLOSE index_cursor;
    DEALLOCATE index_cursor;

    -- Update statistics after maintenance
    PRINT 'Updating statistics...';
    EXEC sp_updatestats;
    PRINT 'Index maintenance completed.';
END;

-- Execute the maintenance procedure
EXEC usp_IndexMaintenance
    @FragmentationThreshold = 10.0,
    @RebuildThreshold = 30.0,
    @MinPageCount = 1000,
    @MaxDOP = 4,
    @OnlineRebuild = 1;
```

## Execution Plan Analysis

### Reading Execution Plans

```sql
-- Enable execution plan display
SET SHOWPLAN_ALL ON;
-- Your query here
SELECT * FROM Orders WHERE CustomerID = 123;
SET SHOWPLAN_ALL OFF;

-- Include actual execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS PROFILE ON;

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City = 'New York'
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(o.OrderID) > 5
ORDER BY TotalSpent DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
SET STATISTICS PROFILE OFF;

-- Query execution statistics
SELECT
    qs.execution_count,
    qs.total_worker_time / 1000.0 AS total_cpu_ms,
    qs.total_elapsed_time / 1000.0 AS total_duration_ms,
    qs.total_logical_reads,
    qs.total_physical_reads,
    qs.total_logical_writes,
    qs.creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE st.text LIKE '%your_query_pattern%'
ORDER BY qs.total_worker_time DESC;
```

### Plan Analysis Tools

```sql
-- Expensive operators in execution plans
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT
    qs.execution_count,
    qs.total_worker_time,
    qs.total_logical_reads,
    query_plan,
    n.value('@StatementText', 'VARCHAR(4000)') AS sql_text,
    n.value('@StatementOptmLevel', 'VARCHAR(25)') AS optimization_level,
    n.value('@StatementOptmEarlyAbortReason', 'VARCHAR(25)') AS early_abort_reason
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY query_plan.nodes('//p:StmtSimple') AS q(n)
WHERE n.exist('@StatementOptmEarlyAbortReason[.!="GoodEnoughPlanFound"]') = 1;

-- Find queries with expensive scans
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT
    cp.usecounts,
    cp.size_in_bytes,
    qs.execution_count,
    qs.total_worker_time,
    qs.total_logical_reads,
    n.value('@PhysicalOp', 'VARCHAR(128)') AS physical_operator,
    n.value('@EstimateRows', 'FLOAT') AS estimated_rows,
    n.value('@EstimateIO', 'FLOAT') AS estimated_io,
    n.value('@EstimateCPU', 'FLOAT') AS estimated_cpu,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY sys.dm_exec_query_stats qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY qp.query_plan.nodes('//p:RelOp') AS q(n)
WHERE n.value('@PhysicalOp', 'VARCHAR(128)') IN ('Table Scan', 'Clustered Index Scan', 'Index Scan')
    AND n.value('@EstimateRows', 'FLOAT') > 1000
ORDER BY qs.total_worker_time DESC;
```

### Plan Cache Analysis

```sql
-- Plan cache hit ratio and reuse
SELECT
    cacheobjtype,
    objtype,
    COUNT(*) AS plan_count,
    SUM(usecounts) AS total_use_count,
    AVG(usecounts) AS avg_use_count,
    SUM(size_in_bytes) / 1024 / 1024 AS total_size_mb,
    SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS single_use_plans,
    CAST(SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS single_use_percent
FROM sys.dm_exec_cached_plans
GROUP BY cacheobjtype, objtype
ORDER BY total_size_mb DESC;

-- Ad-hoc queries causing plan cache bloat
SELECT
    cp.size_in_bytes,
    cp.usecounts,
    OBJECT_NAME(st.objectid) AS object_name,
    st.text AS sql_text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = 'Compiled Plan'
    AND cp.objtype = 'Adhoc'
    AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC;

-- Clear plan cache selectively
-- Clear for specific database only
DECLARE @db_id INT = DB_ID('MyDatabase');
DBCC FLUSHPROCINDB(@db_id);

-- Clear single-use plans only
DBCC FREESYSTEMCACHE('SQL Plans') WITH MARK_IN_USE_FOR_REMOVAL;
```

## Memory Configuration and Optimization

### Memory Configuration

```sql
-- Check current memory settings
SELECT
    name,
    value_in_use,
    value,
    description
FROM sys.configurations
WHERE name IN (
    'max server memory (MB)',
    'min server memory (MB)',
    'optimize for ad hoc workloads'
);

-- Set max server memory (reserve memory for OS)
-- For dedicated SQL Server: Total RAM - 2-4GB for OS
-- For shared server: Leave more for other applications
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 6144; -- 6GB
RECONFIGURE;

-- Enable optimize for ad hoc workloads
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
```

### Memory Usage Analysis

```sql
-- Memory usage by clerks
SELECT
    type,
    name,
    pages_kb / 1024 AS pages_mb,
    CAST(pages_kb * 100.0 / SUM(pages_kb) OVER() AS DECIMAL(5,2)) AS percent_total
FROM sys.dm_os_memory_clerks
WHERE pages_kb > 0
ORDER BY pages_kb DESC;

-- Buffer pool usage
SELECT
    database_id,
    DB_NAME(database_id) AS database_name,
    COUNT(*) * 8 / 1024 AS buffer_pool_mb,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sys.dm_os_buffer_descriptors) AS DECIMAL(5,2)) AS percent_buffer_pool
FROM sys.dm_os_buffer_descriptors
WHERE database_id > 4 -- Exclude system databases
GROUP BY database_id
ORDER BY buffer_pool_mb DESC;

-- Page life expectancy
SELECT
    counter_name,
    cntr_value AS page_life_expectancy_seconds,
    cntr_value / 60 AS page_life_expectancy_minutes
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLSERVER:Buffer Manager'
    AND counter_name = 'Page life expectancy';

-- Memory pressure indicators
SELECT
    type,
    name,
    memory_node_id,
    pages_kb,
    virtual_address_space_reserved_kb,
    virtual_address_space_committed_kb,
    awe_allocated_kb
FROM sys.dm_os_memory_clerks
WHERE type IN (
    'MEMORYCLERK_SQLBUFFERPOOL',
    'MEMORYCLERK_SQLOPTIMIZER',
    'MEMORYCLERK_SQLGENERAL',
    'MEMORYCLERK_BACKUP'
)
ORDER BY pages_kb DESC;

-- Query memory usage
SELECT
    session_id,
    request_id,
    scheduler_id,
    dop,
    request_time,
    grant_time,
    requested_memory_kb,
    granted_memory_kb,
    required_memory_kb,
    used_memory_kb,
    max_used_memory_kb,
    query_cost,
    timeout_sec,
    resource_semaphore_id,
    queue_id,
    wait_order,
    is_next_candidate,
    wait_time_ms,
    plan_handle,
    sql_handle,
    group_id,
    pool_id,
    is_small,
    ideal_memory_kb
FROM sys.dm_exec_query_memory_grants;
```

## I/O Performance Optimization

### I/O Analysis

```sql
-- I/O statistics by database file
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_name,
    mf.type_desc AS file_type,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.num_of_bytes_read / 1024 / 1024 AS mb_read,
    vfs.num_of_bytes_written / 1024 / 1024 AS mb_written,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    vfs.io_stall_read_ms / NULLIF(vfs.num_of_reads, 0) AS avg_read_stall_ms,
    vfs.io_stall_write_ms / NULLIF(vfs.num_of_writes, 0) AS avg_write_stall_ms,
    mf.physical_name
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
INNER JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY vfs.io_stall_read_ms + vfs.io_stall_write_ms DESC;

-- I/O pending requests
SELECT
    pending_io_count,
    pending_io_byte_count,
    pending_io_byte_average,
    io_completion_request_address,
    io_type,
    io_pending_ms_ticks,
    scheduler_address
FROM sys.dm_io_pending_io_requests;

-- I/O related waits
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE '%IO%'
    OR wait_type LIKE '%PAGEIO%'
    OR wait_type LIKE '%BACKUPIO%'
ORDER BY wait_time_ms DESC;
```

### File Configuration Optimization

```sql
-- Check file growth settings
SELECT
    DB_NAME(database_id) AS database_name,
    name AS logical_name,
    type_desc,
    size * 8 / 1024 AS current_size_mb,
    CASE
        WHEN max_size = -1 THEN 'Unlimited'
        WHEN max_size = 268435456 THEN 'Unlimited'
        ELSE CAST(max_size * 8 / 1024 AS VARCHAR(20)) + ' MB'
    END AS max_size,
    CASE
        WHEN is_percent_growth = 1 THEN CAST(growth AS VARCHAR(20)) + '%'
        ELSE CAST(growth * 8 / 1024 AS VARCHAR(20)) + ' MB'
    END AS growth_setting,
    physical_name
FROM sys.master_files
WHERE database_id > 4 -- Exclude system databases
ORDER BY database_id, type;

-- Optimize file growth settings
-- Set fixed MB growth instead of percentage
ALTER DATABASE MyDatabase
MODIFY FILE (
    NAME = 'MyDatabase_Data',
    FILEGROWTH = 256MB  -- Fixed growth instead of percentage
);

ALTER DATABASE MyDatabase
MODIFY FILE (
    NAME = 'MyDatabase_Log',
    FILEGROWTH = 64MB
);

-- Add multiple data files for parallel I/O
ALTER DATABASE MyDatabase
ADD FILE (
    NAME = 'MyDatabase_Data2',
    FILENAME = 'C:\Data\MyDatabase_Data2.ndf',
    SIZE = 1GB,
    FILEGROWTH = 256MB
);

-- Separate log files to different drives
ALTER DATABASE MyDatabase
MODIFY FILE (
    NAME = 'MyDatabase_Log',
    FILENAME = 'D:\Logs\MyDatabase_Log.ldf'
);
```

### TempDB Optimization

```sql
-- Check TempDB configuration
SELECT
    name,
    size * 8 / 1024 AS size_mb,
    growth,
    is_percent_growth,
    physical_name
FROM sys.master_files
WHERE database_id = 2; -- TempDB

-- TempDB usage
SELECT
    SUM(unallocated_extent_page_count) AS free_pages,
    SUM(unallocated_extent_page_count) * 8 / 1024 AS free_mb,
    SUM(user_object_reserved_page_count) * 8 / 1024 AS user_objects_mb,
    SUM(internal_object_reserved_page_count) * 8 / 1024 AS internal_objects_mb,
    SUM(version_store_reserved_page_count) * 8 / 1024 AS version_store_mb
FROM sys.dm_db_file_space_usage
WHERE database_id = 2;

-- TempDB configuration script (run at server startup)
-- Create multiple data files equal to CPU cores (up to 8)
USE master;
GO

DECLARE @cpu_count INT = (SELECT cpu_count FROM sys.dm_os_sys_info);
DECLARE @file_count INT = CASE WHEN @cpu_count > 8 THEN 8 ELSE @cpu_count END;
DECLARE @i INT = 1;
DECLARE @sql NVARCHAR(MAX);

-- Resize existing tempdb file
ALTER DATABASE tempdb
MODIFY FILE (NAME = 'tempdev', SIZE = 1024MB, FILEGROWTH = 256MB);

-- Add additional files
WHILE @i < @file_count
BEGIN
    SET @sql = 'ALTER DATABASE tempdb ADD FILE (
        NAME = ''tempdev' + CAST(@i + 1 AS VARCHAR(2)) + ''',
        FILENAME = ''C:\TempDB\tempdev' + CAST(@i + 1 AS VARCHAR(2)) + '.ndf'',
        SIZE = 1024MB,
        FILEGROWTH = 256MB)';

    EXEC sp_executesql @sql;
    SET @i = @i + 1;
END;
```

This concludes the first part of the performance tuning guide. Would you like me to continue with the remaining sections covering CPU optimization, monitoring, stored procedure optimization, and configuration best practices?
