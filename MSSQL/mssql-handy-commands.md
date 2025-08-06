# MSSQL Handy Commands and Quick Reference

## Table of Contents

1. [Database Management Commands](#database-management-commands)
2. [Table Operations](#table-operations)
3. [Data Manipulation](#data-manipulation)
4. [Index Management](#index-management)
5. [Performance and Monitoring](#performance-and-monitoring)
6. [Backup and Restore](#backup-and-restore)
7. [Security and Permissions](#security-and-permissions)
8. [System Information](#system-information)
9. [Maintenance Commands](#maintenance-commands)
10. [Troubleshooting Commands](#troubleshooting-commands)

## Database Management Commands

### Create and Manage Databases

```sql
-- Create database
CREATE DATABASE MyDatabase;

-- Create database with custom settings
CREATE DATABASE MyDatabase
ON (
    NAME = 'MyDatabase_Data',
    FILENAME = 'C:\Data\MyDatabase.mdf',
    SIZE = 500MB,
    MAXSIZE = 5GB,
    FILEGROWTH = 50MB
)
LOG ON (
    NAME = 'MyDatabase_Log',
    FILENAME = 'C:\Data\MyDatabase.ldf',
    SIZE = 50MB,
    FILEGROWTH = 10%
);

-- Switch to database
USE MyDatabase;

-- Check current database
SELECT DB_NAME() AS CurrentDatabase;

-- List all databases
SELECT name FROM sys.databases;

-- Get database information
SELECT
    name,
    database_id,
    create_date,
    collation_name,
    state_desc,
    recovery_model_desc
FROM sys.databases;

-- Database size information
SELECT
    DB_NAME() AS DatabaseName,
    SUM(CASE WHEN type = 0 THEN size END) * 8 / 1024 AS DataSizeMB,
    SUM(CASE WHEN type = 1 THEN size END) * 8 / 1024 AS LogSizeMB
FROM sys.master_files
WHERE database_id = DB_ID()
GROUP BY database_id;

-- Drop database
DROP DATABASE MyDatabase;

-- Set database options
ALTER DATABASE MyDatabase SET RECOVERY FULL;
ALTER DATABASE MyDatabase SET AUTO_SHRINK OFF;
ALTER DATABASE MyDatabase SET AUTO_CLOSE OFF;
```

## Table Operations

### Create Tables

```sql
-- Basic table
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    HireDate DATE DEFAULT GETDATE(),
    Salary DECIMAL(10,2),
    DepartmentID INT
);

-- Table with foreign key
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Temporary table
CREATE TABLE #TempTable (
    ID INT,
    Name NVARCHAR(50)
);

-- Table variable
DECLARE @TableVar TABLE (
    ID INT,
    Name NVARCHAR(50)
);
```

### Modify Tables

```sql
-- Add column
ALTER TABLE Employees ADD MiddleName NVARCHAR(50);

-- Modify column
ALTER TABLE Employees ALTER COLUMN MiddleName NVARCHAR(100);

-- Drop column
ALTER TABLE Employees DROP COLUMN MiddleName;

-- Add constraint
ALTER TABLE Employees ADD CONSTRAINT CHK_Salary CHECK (Salary > 0);

-- Drop constraint
ALTER TABLE Employees DROP CONSTRAINT CHK_Salary;

-- Rename table
EXEC sp_rename 'OldTableName', 'NewTableName';

-- Rename column
EXEC sp_rename 'TableName.OldColumnName', 'NewColumnName', 'COLUMN';
```

### Table Information

```sql
-- List all tables
SELECT name FROM sys.tables ORDER BY name;

-- Table structure
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'Employees'
ORDER BY c.ORDINAL_POSITION;

-- Table constraints
SELECT
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    ON ccu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
WHERE ccu.TABLE_NAME = 'Employees';

-- Foreign key relationships
SELECT
    FK.name AS ForeignKeyName,
    TP.name AS ParentTable,
    CP.name AS ParentColumn,
    TR.name AS ReferencedTable,
    CR.name AS ReferencedColumn
FROM sys.foreign_keys FK
INNER JOIN sys.foreign_key_columns FKC ON FK.object_id = FKC.constraint_object_id
INNER JOIN sys.tables TP ON FKC.parent_object_id = TP.object_id
INNER JOIN sys.columns CP ON FKC.parent_object_id = CP.object_id AND FKC.parent_column_id = CP.column_id
INNER JOIN sys.tables TR ON FKC.referenced_object_id = TR.object_id
INNER JOIN sys.columns CR ON FKC.referenced_object_id = CR.object_id AND FKC.referenced_column_id = CR.column_id;

-- Table row counts
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS TableName,
    SUM(rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
GROUP BY SCHEMA_NAME(schema_id), name
ORDER BY SchemaName, TableName;
```

## Data Manipulation

### Insert Data

```sql
-- Single row insert
INSERT INTO Employees (FirstName, LastName, Email, HireDate, Salary)
VALUES ('John', 'Doe', 'john.doe@company.com', '2023-01-15', 75000);

-- Multiple rows insert
INSERT INTO Employees (FirstName, LastName, Email, Salary)
VALUES
    ('Jane', 'Smith', 'jane.smith@company.com', 80000),
    ('Bob', 'Johnson', 'bob.johnson@company.com', 70000),
    ('Alice', 'Brown', 'alice.brown@company.com', 85000);

-- Insert from SELECT
INSERT INTO EmployeeBackup (FirstName, LastName, Email, Salary)
SELECT FirstName, LastName, Email, Salary
FROM Employees
WHERE DepartmentID = 1;

-- Insert with OUTPUT
INSERT INTO Employees (FirstName, LastName, Email, Salary)
OUTPUT inserted.EmployeeID, inserted.FirstName, inserted.LastName
VALUES ('Mike', 'Wilson', 'mike.wilson@company.com', 72000);
```

### Update Data

```sql
-- Basic update
UPDATE Employees
SET Salary = 80000
WHERE EmployeeID = 1;

-- Update with JOIN
UPDATE e
SET Salary = e.Salary * 1.1
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Sales';

-- Update with OUTPUT
UPDATE Employees
SET Salary = Salary * 1.05
OUTPUT deleted.EmployeeID, deleted.Salary AS OldSalary, inserted.Salary AS NewSalary
WHERE DepartmentID = 2;

-- Conditional update
UPDATE Employees
SET Salary = CASE
    WHEN Salary < 50000 THEN Salary * 1.15
    WHEN Salary BETWEEN 50000 AND 75000 THEN Salary * 1.10
    ELSE Salary * 1.05
END
WHERE HireDate < '2022-01-01';
```

### Delete Data

```sql
-- Basic delete
DELETE FROM Employees WHERE EmployeeID = 5;

-- Delete with JOIN
DELETE e
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Temp';

-- Delete with OUTPUT
DELETE FROM Employees
OUTPUT deleted.*
WHERE HireDate < '2020-01-01';

-- Truncate table (faster for all rows)
TRUNCATE TABLE TempTable;
```

### Query Data

```sql
-- Basic SELECT with common clauses
SELECT TOP 10
    FirstName,
    LastName,
    Salary,
    HireDate
FROM Employees
WHERE Salary > 70000
    AND HireDate >= '2022-01-01'
ORDER BY Salary DESC, HireDate;

-- SELECT with aggregation
SELECT
    DepartmentID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AvgSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary,
    SUM(Salary) AS TotalSalary
FROM Employees
WHERE Salary IS NOT NULL
GROUP BY DepartmentID
HAVING COUNT(*) > 5
ORDER BY AvgSalary DESC;

-- Pagination
SELECT *
FROM Employees
ORDER BY EmployeeID
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;

-- CASE statement
SELECT
    FirstName,
    LastName,
    Salary,
    CASE
        WHEN Salary < 50000 THEN 'Entry Level'
        WHEN Salary BETWEEN 50000 AND 80000 THEN 'Mid Level'
        WHEN Salary > 80000 THEN 'Senior Level'
        ELSE 'Not Specified'
    END AS SalaryLevel
FROM Employees;
```

## Index Management

### Create Indexes

```sql
-- Clustered index (reorganizes table data)
CREATE CLUSTERED INDEX CIX_Employees_EmployeeID
ON Employees (EmployeeID);

-- Non-clustered index
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName);

-- Composite index
CREATE NONCLUSTERED INDEX IX_Employees_Name
ON Employees (LastName, FirstName);

-- Covering index
CREATE NONCLUSTERED INDEX IX_Employees_DeptID_Covering
ON Employees (DepartmentID)
INCLUDE (FirstName, LastName, Salary);

-- Unique index
CREATE UNIQUE NONCLUSTERED INDEX IX_Employees_Email
ON Employees (Email);

-- Filtered index
CREATE NONCLUSTERED INDEX IX_Employees_ActiveEmail
ON Employees (Email)
WHERE Email IS NOT NULL;

-- Index with options
CREATE NONCLUSTERED INDEX IX_Employees_HireDate
ON Employees (HireDate)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);
```

### Index Maintenance

```sql
-- Check index fragmentation
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    ips.record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 5
    AND ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Rebuild index
ALTER INDEX IX_Employees_LastName ON Employees REBUILD;

-- Reorganize index
ALTER INDEX IX_Employees_LastName ON Employees REORGANIZE;

-- Rebuild all indexes on table
ALTER INDEX ALL ON Employees REBUILD;

-- Update statistics
UPDATE STATISTICS Employees;
UPDATE STATISTICS Employees IX_Employees_LastName;

-- Drop index
DROP INDEX IX_Employees_LastName ON Employees;
```

### Index Usage Statistics

```sql
-- Index usage statistics
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_lookup
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE OBJECT_NAME(i.object_id) = 'Employees'
ORDER BY (ius.user_seeks + ius.user_scans + ius.user_lookups) DESC;

-- Missing indexes
SELECT
    mid.statement AS TableName,
    migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    'CREATE INDEX IX_' + REPLACE(REPLACE(REPLACE(mid.statement, '[', ''), ']', ''), '.', '_') + '_Missing ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY improvement_measure DESC;
```

## Performance and Monitoring

### Query Performance

```sql
-- Enable query execution statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Your query here
SELECT * FROM Employees WHERE LastName = 'Smith';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Show execution plan
SET SHOWPLAN_ALL ON;
SELECT * FROM Employees WHERE LastName = 'Smith';
SET SHOWPLAN_ALL OFF;

-- Find expensive queries
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_time_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_time_ms,
    qs.total_logical_reads,
    qs.total_physical_reads,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;

-- Currently running queries
SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.logical_reads,
    r.reads,
    r.writes,
    r.command,
    s.text AS sql_text,
    p.query_plan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE r.session_id != @@SPID;
```

### Wait Statistics

```sql
-- Wait statistics
SELECT TOP 20
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms,
    CAST(100.0 * wait_time_ms / SUM(wait_time_ms) OVER() AS DECIMAL(5,2)) AS percent_total_waits
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
    'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE',
    'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP',
    'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
    'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
ORDER BY wait_time_ms DESC;

-- Clear wait statistics
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
```

### Blocking and Deadlocks

```sql
-- Check for blocking
SELECT
    blocking.session_id AS blocking_session_id,
    blocked.session_id AS blocked_session_id,
    blocking_sql.text AS blocking_sql,
    blocked_sql.text AS blocked_sql,
    blocked.wait_type,
    blocked.wait_time,
    blocked.wait_resource
FROM sys.dm_exec_requests blocked
INNER JOIN sys.dm_exec_requests blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocking.sql_handle) AS blocking_sql
CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) AS blocked_sql;

-- Enable deadlock monitoring
DBCC TRACEON(1222, -1);

-- View deadlock information (from error log)
EXEC xp_readerrorlog 0, 1, 'deadlock';

-- Extended events for deadlock monitoring
CREATE EVENT SESSION DeadlockMonitoring ON SERVER
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename='C:\Temp\DeadlockMonitoring.xel')
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS,
      MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=OFF);

ALTER EVENT SESSION DeadlockMonitoring ON SERVER STATE = START;
```

## Backup and Restore

### Backup Commands

```sql
-- Full backup
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH FORMAT, INIT, COMPRESSION;

-- Differential backup
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Diff.bak'
WITH DIFFERENTIAL, COMPRESSION;

-- Transaction log backup
BACKUP LOG MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Log.trn';

-- Backup to multiple files
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_1.bak',
   DISK = 'C:\Backups\MyDatabase_2.bak',
   DISK = 'C:\Backups\MyDatabase_3.bak'
WITH FORMAT, INIT, COMPRESSION;

-- Backup specific filegroups
BACKUP DATABASE MyDatabase
FILEGROUP = 'PRIMARY'
TO DISK = 'C:\Backups\MyDatabase_Primary.bak';

-- Copy-only backup (doesn't affect backup chain)
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_CopyOnly.bak'
WITH COPY_ONLY, COMPRESSION;
```

### Restore Commands

```sql
-- Restore full backup
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH REPLACE;

-- Restore with different name and location
RESTORE DATABASE MyDatabase_Test
FROM DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH MOVE 'MyDatabase' TO 'C:\Data\MyDatabase_Test.mdf',
     MOVE 'MyDatabase_Log' TO 'C:\Data\MyDatabase_Test.ldf',
     REPLACE;

-- Point-in-time restore
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH NORECOVERY, REPLACE;

RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Diff.bak'
WITH NORECOVERY;

RESTORE LOG MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Log.trn'
WITH STOPAT = '2023-12-01 14:30:00';

-- Restore filegroup
RESTORE DATABASE MyDatabase
FILEGROUP = 'PRIMARY'
FROM DISK = 'C:\Backups\MyDatabase_Primary.bak'
WITH NORECOVERY;

-- Get backup information
RESTORE HEADERONLY FROM DISK = 'C:\Backups\MyDatabase_Full.bak';
RESTORE FILELISTONLY FROM DISK = 'C:\Backups\MyDatabase_Full.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\Backups\MyDatabase_Full.bak';
```

### Backup History

```sql
-- Backup history
SELECT
    database_name,
    backup_start_date,
    backup_finish_date,
    type,
    CASE type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
    END AS backup_type,
    backup_size / 1024 / 1024 AS backup_size_mb,
    physical_device_name
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE database_name = 'MyDatabase'
ORDER BY backup_start_date DESC;

-- Last backup dates
SELECT
    d.name AS database_name,
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS last_full_backup,
    MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS last_diff_backup,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS last_log_backup
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b ON d.name = b.database_name
WHERE d.database_id > 4 -- Exclude system databases
GROUP BY d.name
ORDER BY d.name;
```

## Security and Permissions

### Login and User Management

```sql
-- Create SQL Server login
CREATE LOGIN MyUser WITH PASSWORD = 'StrongPassword123!';

-- Create Windows login
CREATE LOGIN [DOMAIN\User] FROM WINDOWS;

-- Create database user
USE MyDatabase;
CREATE USER MyUser FOR LOGIN MyUser;

-- Create user without login (contained database)
CREATE USER MyContainedUser WITH PASSWORD = 'StrongPassword123!';

-- Drop login
DROP LOGIN MyUser;

-- Drop user
DROP USER MyUser;

-- Change password
ALTER LOGIN MyUser WITH PASSWORD = 'NewStrongPassword123!';

-- Disable/Enable login
ALTER LOGIN MyUser DISABLE;
ALTER LOGIN MyUser ENABLE;
```

### Permissions Management

```sql
-- Grant permissions
GRANT SELECT ON Employees TO MyUser;
GRANT INSERT, UPDATE ON Employees TO MyUser;
GRANT EXECUTE ON dbo.MyStoredProcedure TO MyUser;

-- Grant permissions on schema
GRANT SELECT ON SCHEMA::dbo TO MyUser;

-- Grant database-level permissions
GRANT CREATE TABLE TO MyUser;
GRANT VIEW DEFINITION TO MyUser;

-- Revoke permissions
REVOKE SELECT ON Employees FROM MyUser;
REVOKE CREATE TABLE FROM MyUser;

-- Deny permissions (explicit deny)
DENY DELETE ON Employees TO MyUser;

-- Role management
CREATE ROLE MyCustomRole;
ALTER ROLE MyCustomRole ADD MEMBER MyUser;
ALTER ROLE MyCustomRole DROP MEMBER MyUser;
DROP ROLE MyCustomRole;

-- Built-in database roles
ALTER ROLE db_datareader ADD MEMBER MyUser;
ALTER ROLE db_datawriter ADD MEMBER MyUser;
ALTER ROLE db_owner ADD MEMBER MyUser;

-- Server roles
ALTER SERVER ROLE sysadmin ADD MEMBER MyUser;
ALTER SERVER ROLE dbcreator ADD MEMBER MyUser;
```

### Security Information

```sql
-- List logins
SELECT
    name,
    type_desc,
    is_disabled,
    create_date,
    modify_date,
    default_database_name
FROM sys.server_principals
WHERE type IN ('S', 'U', 'G')
ORDER BY name;

-- List users in current database
SELECT
    name,
    type_desc,
    create_date,
    modify_date,
    default_schema_name
FROM sys.database_principals
WHERE type IN ('S', 'U', 'G')
ORDER BY name;

-- Check permissions for current user
SELECT
    class_desc,
    permission_name,
    state_desc,
    OBJECT_SCHEMA_NAME(major_id) AS schema_name,
    OBJECT_NAME(major_id) AS object_name
FROM sys.database_permissions
WHERE grantee_principal_id = USER_ID();

-- Check permissions for specific user
SELECT
    dp.class_desc,
    dp.permission_name,
    dp.state_desc,
    pr.name AS principal_name,
    OBJECT_SCHEMA_NAME(dp.major_id) AS schema_name,
    OBJECT_NAME(dp.major_id) AS object_name
FROM sys.database_permissions dp
INNER JOIN sys.database_principals pr ON dp.grantee_principal_id = pr.principal_id
WHERE pr.name = 'MyUser';

-- Role membership
SELECT
    r.name AS role_name,
    m.name AS member_name
FROM sys.database_role_members rm
INNER JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY r.name, m.name;
```

## System Information

### Server Information

```sql
-- SQL Server version and edition
SELECT
    @@VERSION AS version_info,
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('ProductVersion') AS product_version,
    SERVERPROPERTY('Edition') AS edition,
    SERVERPROPERTY('EngineEdition') AS engine_edition;

-- Server configuration
SELECT
    name,
    value,
    value_in_use,
    description
FROM sys.configurations
ORDER BY name;

-- Database information
SELECT
    name,
    database_id,
    create_date,
    collation_name,
    state_desc,
    recovery_model_desc,
    page_verify_option_desc,
    is_auto_close_on,
    is_auto_shrink_on
FROM sys.databases;

-- File information
SELECT
    DB_NAME(database_id) AS database_name,
    name AS logical_name,
    physical_name,
    type_desc,
    size * 8 / 1024 AS size_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.master_files
ORDER BY database_id, type;
```

### Performance Counters

```sql
-- CPU usage
SELECT
    record_id,
    EventTime,
    SQLProcessUtilization,
    SystemIdle,
    100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
FROM (
    SELECT
        record.value('(./Record/@id)[1]', 'int') AS record_id,
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
        timestamp AS EventTime
    FROM (
        SELECT timestamp, CONVERT(xml, record) AS record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
    ) AS x
) AS y
ORDER BY record_id DESC;

-- Memory usage
SELECT
    total_physical_memory_kb / 1024 AS total_physical_memory_mb,
    available_physical_memory_kb / 1024 AS available_physical_memory_mb,
    total_page_file_kb / 1024 AS total_page_file_mb,
    available_page_file_kb / 1024 AS available_page_file_mb,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;

-- SQL Server memory usage
SELECT
    type,
    pages_kb / 1024 AS pages_mb
FROM sys.dm_os_memory_clerks
WHERE type IN ('MEMORYCLERK_SQLBUFFERPOOL', 'MEMORYCLERK_SQLOPTIMIZER', 'MEMORYCLERK_SQLGENERAL')
ORDER BY pages_kb DESC;

-- Database space usage
SELECT
    DB_NAME() AS database_name,
    SUM(CASE WHEN type = 0 THEN size END) * 8 / 1024 AS data_size_mb,
    SUM(CASE WHEN type = 1 THEN size END) * 8 / 1024 AS log_size_mb,
    SUM(size) * 8 / 1024 AS total_size_mb
FROM sys.database_files;
```

### Session Information

```sql
-- Active sessions
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    cpu_time,
    memory_usage,
    total_elapsed_time,
    reads,
    writes,
    logical_reads,
    login_time,
    last_request_start_time,
    last_request_end_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY last_request_start_time DESC;

-- Connection counts
SELECT
    login_name,
    COUNT(*) AS connection_count
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY login_name
ORDER BY connection_count DESC;

-- Kill session (use with caution)
-- KILL 53; -- Replace with actual session_id
```

## Maintenance Commands

### Database Maintenance

```sql
-- Update statistics for all tables
EXEC sp_updatestats;

-- Update statistics for specific table
UPDATE STATISTICS Employees;

-- Check database consistency
DBCC CHECKDB('MyDatabase');

-- Check table consistency
DBCC CHECKTABLE('Employees');

-- Shrink database (use sparingly)
DBCC SHRINKDATABASE(MyDatabase, 10);

-- Shrink log file
DBCC SHRINKFILE('MyDatabase_Log', 100);

-- Reindex all tables in database
EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REBUILD';

-- Reorganize all indexes
EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REORGANIZE';
```

### Automated Maintenance

```sql
-- Create maintenance plan for index optimization
DECLARE @sql NVARCHAR(MAX) = '';

-- Generate dynamic SQL for index maintenance
SELECT @sql = @sql +
    CASE
        WHEN avg_fragmentation_in_percent > 30 THEN
            'ALTER INDEX [' + i.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + '] REBUILD WITH (ONLINE = ON);' + CHAR(13)
        WHEN avg_fragmentation_in_percent > 10 THEN
            'ALTER INDEX [' + i.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + '] REORGANIZE;' + CHAR(13)
    END
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
INNER JOIN sys.tables t ON ips.object_id = t.object_id
WHERE ips.avg_fragmentation_in_percent > 10
    AND i.name IS NOT NULL
    AND ips.page_count > 100;

-- Execute the maintenance commands
IF LEN(@sql) > 0
    EXEC sp_executesql @sql;

-- Update statistics after maintenance
EXEC sp_updatestats;
```

## Troubleshooting Commands

### Error Information

```sql
-- Recent errors from error log
EXEC xp_readerrorlog 0, 1, 'Error';

-- Specific error patterns
EXEC xp_readerrorlog 0, 1, 'deadlock';
EXEC xp_readerrorlog 0, 1, 'timeout';
EXEC xp_readerrorlog 0, 1, 'failed';

-- Error log file list
EXEC xp_enumerrorlogs;

-- System health information
SELECT
    sqlserver_start_time,
    cpu_count,
    physical_memory_kb / 1024 AS physical_memory_mb,
    virtual_memory_kb / 1024 AS virtual_memory_mb,
    committed_kb / 1024 AS committed_mb,
    committed_target_kb / 1024 AS committed_target_mb
FROM sys.dm_os_sys_info;
```

### Connection Issues

```sql
-- Check connection limits
SELECT
    @@MAX_CONNECTIONS AS max_connections,
    COUNT(*) AS current_connections
FROM sys.dm_exec_sessions;

-- Failed login attempts
SELECT
    event_time,
    object_name,
    file_name,
    offset_in_file
FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
WHERE object_name = 'login_failed';

-- Connection endpoints
SELECT
    name,
    protocol_desc,
    type_desc,
    state_desc,
    is_admin_endpoint
FROM sys.endpoints;
```

### Performance Issues

```sql
-- Long running queries
SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    r.command,
    s.text AS sql_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.total_elapsed_time > 10000 -- More than 10 seconds
ORDER BY r.total_elapsed_time DESC;

-- Resource usage by session
SELECT TOP 10
    session_id,
    login_name,
    host_name,
    program_name,
    cpu_time,
    memory_usage * 8 AS memory_usage_kb,
    total_elapsed_time,
    reads,
    writes,
    logical_reads
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY cpu_time DESC;

-- Database file I/O statistics
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    vfs.io_stall_read_ms / NULLIF(vfs.num_of_reads, 0) AS avg_read_stall_ms,
    vfs.io_stall_write_ms / NULLIF(vfs.num_of_writes, 0) AS avg_write_stall_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
INNER JOIN sys.master_files mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY vfs.io_stall_read_ms + vfs.io_stall_write_ms DESC;
```

## Quick Reference Commands

```sql
-- Current date and time
SELECT GETDATE(), GETUTCDATE();

-- Current user and database
SELECT USER_NAME(), DB_NAME(), @@SERVERNAME;

-- Row count for all tables
SELECT
    SCHEMA_NAME(schema_id) AS schema_name,
    name AS table_name,
    SUM(rows) AS row_count
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
GROUP BY SCHEMA_NAME(schema_id), name
ORDER BY row_count DESC;

-- Database sizes
SELECT
    name AS database_name,
    (SELECT SUM(size) * 8 / 1024 FROM sys.master_files WHERE database_id = d.database_id AND type = 0) AS data_size_mb,
    (SELECT SUM(size) * 8 / 1024 FROM sys.master_files WHERE database_id = d.database_id AND type = 1) AS log_size_mb
FROM sys.databases d
WHERE database_id > 4
ORDER BY data_size_mb DESC;

-- Last backup dates for all databases
SELECT
    d.name AS database_name,
    ISNULL(MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END), 'Never') AS last_full_backup,
    ISNULL(MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END), 'Never') AS last_diff_backup,
    ISNULL(MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END), 'Never') AS last_log_backup
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b ON d.name = b.database_name
WHERE d.database_id > 4
GROUP BY d.name
ORDER BY d.name;

-- Check database recovery model
SELECT name, recovery_model_desc FROM sys.databases;

-- Current SQL Server settings
SELECT
    @@SERVERNAME AS server_name,
    @@VERSION AS version_info,
    @@LANGUAGE AS language,
    @@DATEFIRST AS date_first,
    @@LOCK_TIMEOUT AS lock_timeout;
```

This handy commands reference provides quick access to the most commonly used MSSQL commands for database administration, performance monitoring, and troubleshooting.
