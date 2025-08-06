# Microsoft SQL Server (MSSQL) - Advanced Guide

## Table of Contents

1. [Advanced T-SQL Features](#advanced-t-sql-features)
2. [Performance Tuning and Optimization](#performance-tuning-and-optimization)
3. [Advanced Indexing Strategies](#advanced-indexing-strategies)
4. [Query Execution Plans](#query-execution-plans)
5. [Stored Procedures and Functions](#stored-procedures-and-functions)
6. [Triggers and Constraints](#triggers-and-constraints)
7. [Transactions and Concurrency](#transactions-and-concurrency)
8. [Database Administration](#database-administration)
9. [High Availability and Disaster Recovery](#high-availability-and-disaster-recovery)
10. [Security and Compliance](#security-and-compliance)
11. [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
12. [Advanced Data Types and Features](#advanced-data-types-and-features)

## Advanced T-SQL Features

### Common Table Expressions (CTEs)

```sql
-- Basic CTE
WITH CustomerOrders AS (
    SELECT
        CustomerID,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS TotalSpent
    FROM Orders
    GROUP BY CustomerID
)
SELECT
    c.FirstName,
    c.LastName,
    co.OrderCount,
    co.TotalSpent
FROM Customers c
INNER JOIN CustomerOrders co ON c.CustomerID = co.CustomerID
WHERE co.OrderCount > 5;

-- Recursive CTE - Employee Hierarchy
WITH EmployeeHierarchy AS (
    -- Anchor member: Top-level managers
    SELECT
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        1 AS Level
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive member
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID,
        eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT
    REPLICATE('  ', Level - 1) + FirstName + ' ' + LastName AS Hierarchy,
    Level
FROM EmployeeHierarchy
ORDER BY Level, LastName;

-- Multiple CTEs
WITH
HighValueCustomers AS (
    SELECT CustomerID, SUM(TotalAmount) AS TotalSpent
    FROM Orders
    GROUP BY CustomerID
    HAVING SUM(TotalAmount) > 10000
),
RecentOrders AS (
    SELECT CustomerID, COUNT(*) AS RecentOrderCount
    FROM Orders
    WHERE OrderDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY CustomerID
)
SELECT
    c.FirstName,
    c.LastName,
    hvc.TotalSpent,
    ISNULL(ro.RecentOrderCount, 0) AS RecentOrders
FROM Customers c
INNER JOIN HighValueCustomers hvc ON c.CustomerID = hvc.CustomerID
LEFT JOIN RecentOrders ro ON c.CustomerID = ro.CustomerID;
```

### Window Functions

```sql
-- ROW_NUMBER, RANK, DENSE_RANK
SELECT
    FirstName,
    LastName,
    Salary,
    DepartmentID,
    ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS RowNum,
    RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank,
    DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS DenseSalaryRank
FROM Employees;

-- LEAD and LAG
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate,
    TotalAmount - LAG(TotalAmount) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS AmountDifference
FROM Orders;

-- Running totals and moving averages
SELECT
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal,
    AVG(TotalAmount) OVER (ORDER BY OrderDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Moving7DayAvg,
    COUNT(*) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS CumulativeOrderCount
FROM Orders
ORDER BY OrderDate;

-- FIRST_VALUE and LAST_VALUE
SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    Salary,
    FIRST_VALUE(Salary) OVER (PARTITION BY DepartmentID ORDER BY HireDate) AS FirstHiredSalary,
    LAST_VALUE(Salary) OVER (
        PARTITION BY DepartmentID
        ORDER BY HireDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LastHiredSalary
FROM Employees;

-- Percentiles
SELECT
    FirstName,
    LastName,
    Salary,
    PERCENT_RANK() OVER (ORDER BY Salary) AS PercentRank,
    CUME_DIST() OVER (ORDER BY Salary) AS CumulativeDistribution,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) OVER () AS MedianSalary,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Salary) OVER () AS DiscreteMedianSalary
FROM Employees;
```

### PIVOT and UNPIVOT

```sql
-- PIVOT Example
SELECT *
FROM (
    SELECT
        Year,
        Quarter,
        SalesAmount
    FROM QuarterlySales
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR Quarter IN ([Q1], [Q2], [Q3], [Q4])
) AS PivotTable;

-- Dynamic PIVOT
DECLARE @columns NVARCHAR(MAX) = '';
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @columns = COALESCE(@columns + ',', '') + QUOTENAME(Quarter)
FROM (SELECT DISTINCT Quarter FROM QuarterlySales) AS quarters;

SET @sql = '
SELECT *
FROM (
    SELECT Year, Quarter, SalesAmount
    FROM QuarterlySales
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR Quarter IN (' + @columns + ')
) AS PivotTable';

EXEC sp_executesql @sql;

-- UNPIVOT Example
SELECT
    Year,
    Quarter,
    SalesAmount
FROM (
    SELECT Year, Q1, Q2, Q3, Q4
    FROM YearlySalesData
) AS SourceTable
UNPIVOT (
    SalesAmount FOR Quarter IN (Q1, Q2, Q3, Q4)
) AS UnpivotTable;
```

### Advanced Joins and Set Operations

```sql
-- CROSS APPLY and OUTER APPLY
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ot.OrderID,
    ot.OrderDate,
    ot.TotalAmount
FROM Customers c
CROSS APPLY (
    SELECT TOP 3 OrderID, OrderDate, TotalAmount
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID
    ORDER BY OrderDate DESC
) ot;

-- OUTER APPLY for all customers including those without orders
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ot.OrderID,
    ot.OrderDate,
    ot.TotalAmount
FROM Customers c
OUTER APPLY (
    SELECT TOP 3 OrderID, OrderDate, TotalAmount
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID
    ORDER BY OrderDate DESC
) ot;

-- MERGE Statement
MERGE TargetTable AS target
USING SourceTable AS source
ON target.ID = source.ID
WHEN MATCHED THEN
    UPDATE SET
        target.Name = source.Name,
        target.Value = source.Value,
        target.ModifiedDate = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ID, Name, Value, CreatedDate)
    VALUES (source.ID, source.Name, source.Value, GETDATE())
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT
    $action AS Action,
    deleted.ID AS DeletedID,
    inserted.ID AS InsertedID;

-- EXCEPT and INTERSECT
-- Find customers who exist in Table1 but not in Table2
SELECT CustomerID, FirstName, LastName
FROM Customers_Table1
EXCEPT
SELECT CustomerID, FirstName, LastName
FROM Customers_Table2;

-- Find customers who exist in both tables
SELECT CustomerID, FirstName, LastName
FROM Customers_Table1
INTERSECT
SELECT CustomerID, FirstName, LastName
FROM Customers_Table2;
```

## Performance Tuning and Optimization

### Query Optimization Techniques

```sql
-- Use SARGABLE predicates (Search ARGument ABLE)
-- Good: Index can be used
SELECT * FROM Orders WHERE OrderDate >= '2023-01-01';

-- Bad: Function on column prevents index usage
SELECT * FROM Orders WHERE YEAR(OrderDate) = 2023;

-- Better: Rewrite to be SARGABLE
SELECT * FROM Orders
WHERE OrderDate >= '2023-01-01' AND OrderDate < '2024-01-01';

-- Use EXISTS instead of IN for better performance with large datasets
-- Good for large subqueries
SELECT * FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.CustomerID = c.CustomerID
);

-- Use appropriate data types
-- Bad: Using VARCHAR for numeric data
SELECT * FROM Products WHERE ProductID = '123';

-- Good: Using proper numeric type
SELECT * FROM Products WHERE ProductID = 123;

-- Limit result sets
SELECT TOP 1000 * FROM LargeTable
ORDER BY CreatedDate DESC;

-- Use specific columns instead of SELECT *
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE City = 'New York';
```

### Query Hints and Plan Forcing

```sql
-- Index hints
SELECT *
FROM Customers WITH (INDEX(IX_Customers_LastName))
WHERE LastName = 'Smith';

-- Join hints
SELECT c.FirstName, c.LastName, o.OrderDate
FROM Customers c
INNER HASH JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Query hints
SELECT *
FROM Orders
WHERE OrderDate >= '2023-01-01'
OPTION (RECOMPILE);

-- Force parallel execution
SELECT COUNT(*)
FROM LargeTable
OPTION (MAXDOP 4);

-- Use query store to force plans
-- Enable Query Store
ALTER DATABASE MyDatabase
SET QUERY_STORE = ON;

-- Force a specific plan
EXEC sp_query_store_force_plan
    @query_id = 123,
    @plan_id = 456;
```

### Statistics and Query Store

```sql
-- Update statistics manually
UPDATE STATISTICS Customers;
UPDATE STATISTICS Customers IX_Customers_LastName;

-- Create statistics on specific columns
CREATE STATISTICS STAT_Orders_CustomerID_OrderDate
ON Orders (CustomerID, OrderDate);

-- Query Store monitoring
-- Find expensive queries
SELECT
    qsq.query_id,
    qst.query_sql_text,
    qrs.avg_duration / 1000.0 AS avg_duration_ms,
    qrs.avg_cpu_time / 1000.0 AS avg_cpu_time_ms,
    qrs.avg_logical_io_reads,
    qrs.count_executions
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qst ON qsq.query_text_id = qst.query_text_id
JOIN sys.query_store_runtime_stats qrs ON qsq.query_id = qrs.query_id
WHERE qrs.avg_duration > 100000 -- More than 100ms average
ORDER BY qrs.avg_duration DESC;

-- Query Store plan comparison
SELECT
    qsq.query_id,
    qsp.plan_id,
    qsp.query_plan,
    qrs.avg_duration,
    qrs.count_executions
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
JOIN sys.query_store_runtime_stats qrs ON qsp.plan_id = qrs.plan_id
WHERE qsq.query_id = 123
ORDER BY qrs.avg_duration;
```

## Advanced Indexing Strategies

### Covering Indexes

```sql
-- Covering index includes all columns needed for a query
CREATE NONCLUSTERED INDEX IX_Orders_Covering
ON Orders (CustomerID, OrderDate)
INCLUDE (TotalAmount, Status);

-- Query fully satisfied by the covering index
SELECT CustomerID, OrderDate, TotalAmount, Status
FROM Orders
WHERE CustomerID = 123
AND OrderDate >= '2023-01-01';
```

### Filtered Indexes

```sql
-- Index only active records
CREATE NONCLUSTERED INDEX IX_Orders_Active
ON Orders (OrderDate, CustomerID)
WHERE Status = 'Active';

-- Index for non-NULL values only
CREATE NONCLUSTERED INDEX IX_Customers_Email
ON Customers (Email)
WHERE Email IS NOT NULL;

-- Index for recent data
CREATE NONCLUSTERED INDEX IX_Orders_Recent
ON Orders (OrderDate DESC, CustomerID)
WHERE OrderDate >= '2023-01-01';
```

### Columnstore Indexes

```sql
-- Clustered columnstore index (for data warehouse workloads)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_SalesData
ON SalesData;

-- Non-clustered columnstore index
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders_Analytics
ON Orders (CustomerID, OrderDate, TotalAmount, ProductID);

-- Columnstore with filtered condition
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders_Historical
ON Orders (CustomerID, OrderDate, TotalAmount)
WHERE OrderDate < '2022-01-01';
```

### Index Maintenance

```sql
-- Check index fragmentation
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Rebuild vs Reorganize decision
-- Rebuild index (5-30% fragmentation)
ALTER INDEX IX_Orders_CustomerID ON Orders REBUILD
WITH (ONLINE = ON, MAXDOP = 4);

-- Reorganize index (10-30% fragmentation)
ALTER INDEX IX_Orders_CustomerID ON Orders REORGANIZE;

-- Automated maintenance script
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql +
    CASE
        WHEN avg_fragmentation_in_percent > 30 THEN
            'ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(ips.object_id) + ' REBUILD WITH (ONLINE = ON);' + CHAR(13)
        WHEN avg_fragmentation_in_percent > 10 THEN
            'ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(ips.object_id) + ' REORGANIZE;' + CHAR(13)
    END
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
    AND i.name IS NOT NULL;

EXEC sp_executesql @sql;
```

## Query Execution Plans

### Reading Execution Plans

```sql
-- Display estimated execution plan
SET SHOWPLAN_ALL ON;
SELECT * FROM Orders WHERE CustomerID = 123;
SET SHOWPLAN_ALL OFF;

-- Include actual execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT c.FirstName, c.LastName, COUNT(*) as OrderCount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(*) > 5;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Live query statistics (SQL Server 2014+)
SET STATISTICS XML ON;
-- Run your query
SET STATISTICS XML OFF;
```

### Plan Cache Analysis

```sql
-- Find expensive queries in plan cache
SELECT
    cp.objtype,
    cp.cacheobjtype,
    cp.size_in_bytes / 1024 AS size_kb,
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads,
    qs.total_physical_reads,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_cached_plans cp
JOIN sys.dm_exec_query_stats qs ON cp.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE cp.objtype = 'Adhoc'
ORDER BY qs.total_worker_time DESC;

-- Clear plan cache (use with caution)
DBCC FREEPROCCACHE; -- Clears entire plan cache
-- OR clear specific database plan cache
DBCC FLUSHPROCINDB(database_id);
```

### Plan Guides

```sql
-- Create plan guide to force specific plan
EXEC sp_create_plan_guide
    @name = 'MyPlanGuide',
    @stmt = 'SELECT * FROM Orders WHERE CustomerID = @CustomerID',
    @type = 'SQL',
    @module_or_batch = NULL,
    @params = '@CustomerID INT',
    @hints = 'OPTION (TABLE HINT(Orders, INDEX(IX_Orders_CustomerID)))';

-- Create plan guide for stored procedure
EXEC sp_create_plan_guide
    @name = 'ProcPlanGuide',
    @stmt = 'SELECT CustomerID, COUNT(*) FROM Orders GROUP BY CustomerID',
    @type = 'OBJECT',
    @module_or_batch = 'dbo.GetCustomerOrderCounts',
    @params = NULL,
    @hints = 'OPTION (MAXDOP 1)';
```

## Stored Procedures and Functions

### Advanced Stored Procedures

```sql
-- Stored procedure with error handling and transactions
CREATE PROCEDURE usp_TransferFunds
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(10,2),
    @TransactionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(2048);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate accounts exist
        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @FromAccountID)
        BEGIN
            RAISERROR('Source account does not exist', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Accounts WHERE AccountID = @ToAccountID)
        BEGIN
            RAISERROR('Destination account does not exist', 16, 1);
            RETURN;
        END

        -- Check sufficient funds
        IF (SELECT Balance FROM Accounts WHERE AccountID = @FromAccountID) < @Amount
        BEGIN
            RAISERROR('Insufficient funds', 16, 1);
            RETURN;
        END

        -- Perform transfer
        UPDATE Accounts
        SET Balance = Balance - @Amount,
            LastModified = GETDATE()
        WHERE AccountID = @FromAccountID;

        UPDATE Accounts
        SET Balance = Balance + @Amount,
            LastModified = GETDATE()
        WHERE AccountID = @ToAccountID;

        -- Log transaction
        INSERT INTO TransactionLog (FromAccountID, ToAccountID, Amount, TransactionDate)
        VALUES (@FromAccountID, @ToAccountID, @Amount, GETDATE());

        SET @TransactionID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
```

### User-Defined Functions

```sql
-- Scalar function
CREATE FUNCTION dbo.CalculateAge(@BirthDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE()) -
           CASE
               WHEN MONTH(@BirthDate) > MONTH(GETDATE()) OR
                    (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
               THEN 1
               ELSE 0
           END;
END;

-- Table-valued function
CREATE FUNCTION dbo.GetCustomerOrders(@CustomerID INT, @StartDate DATE, @EndDate DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT
        OrderID,
        OrderDate,
        TotalAmount,
        Status
    FROM Orders
    WHERE CustomerID = @CustomerID
        AND OrderDate BETWEEN @StartDate AND @EndDate
);

-- Multi-statement table-valued function
CREATE FUNCTION dbo.GetSalesReport(@Year INT)
RETURNS @SalesReport TABLE
(
    Month INT,
    TotalSales DECIMAL(12,2),
    OrderCount INT,
    AvgOrderValue DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @SalesReport
    SELECT
        MONTH(OrderDate) AS Month,
        SUM(TotalAmount) AS TotalSales,
        COUNT(*) AS OrderCount,
        AVG(TotalAmount) AS AvgOrderValue
    FROM Orders
    WHERE YEAR(OrderDate) = @Year
    GROUP BY MONTH(OrderDate);

    RETURN;
END;

-- Usage examples
SELECT FirstName, LastName, dbo.CalculateAge(BirthDate) AS Age
FROM Customers;

SELECT * FROM dbo.GetCustomerOrders(123, '2023-01-01', '2023-12-31');

SELECT * FROM dbo.GetSalesReport(2023) ORDER BY Month;
```

## Triggers and Constraints

### Advanced Triggers

```sql
-- Audit trigger
CREATE TRIGGER tr_Customers_Audit
ON Customers
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERTS
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO CustomerAudit (CustomerID, Action, FieldName, OldValue, NewValue, AuditDate, AuditUser)
        SELECT
            i.CustomerID,
            'INSERT',
            'NEW_RECORD',
            NULL,
            CONCAT('FirstName:', i.FirstName, '; LastName:', i.LastName, '; Email:', i.Email),
            GETDATE(),
            SUSER_SNAME()
        FROM inserted i;
    END

    -- Handle UPDATES
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        -- Track specific field changes
        INSERT INTO CustomerAudit (CustomerID, Action, FieldName, OldValue, NewValue, AuditDate, AuditUser)
        SELECT
            i.CustomerID,
            'UPDATE',
            'FirstName',
            d.FirstName,
            i.FirstName,
            GETDATE(),
            SUSER_SNAME()
        FROM inserted i
        INNER JOIN deleted d ON i.CustomerID = d.CustomerID
        WHERE i.FirstName != d.FirstName;

        INSERT INTO CustomerAudit (CustomerID, Action, FieldName, OldValue, NewValue, AuditDate, AuditUser)
        SELECT
            i.CustomerID,
            'UPDATE',
            'Email',
            d.Email,
            i.Email,
            GETDATE(),
            SUSER_SNAME()
        FROM inserted i
        INNER JOIN deleted d ON i.CustomerID = d.CustomerID
        WHERE ISNULL(i.Email, '') != ISNULL(d.Email, '');
    END

    -- Handle DELETES
    IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO CustomerAudit (CustomerID, Action, FieldName, OldValue, NewValue, AuditDate, AuditUser)
        SELECT
            d.CustomerID,
            'DELETE',
            'DELETED_RECORD',
            CONCAT('FirstName:', d.FirstName, '; LastName:', d.LastName, '; Email:', d.Email),
            NULL,
            GETDATE(),
            SUSER_SNAME()
        FROM deleted d;
    END
END;

-- INSTEAD OF trigger for view
CREATE VIEW vw_CustomerSummary
AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    COUNT(o.OrderID) AS OrderCount,
    ISNULL(SUM(o.TotalAmount), 0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email;

CREATE TRIGGER tr_CustomerSummary_InsteadOfUpdate
ON vw_CustomerSummary
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only update base table fields that can be updated
    UPDATE Customers
    SET
        FirstName = i.FirstName,
        LastName = i.LastName,
        Email = i.Email
    FROM Customers c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID
    WHERE c.FirstName != i.FirstName
       OR c.LastName != i.LastName
       OR ISNULL(c.Email, '') != ISNULL(i.Email, '');
END;
```

### Advanced Constraints

```sql
-- Check constraint with function
CREATE FUNCTION dbo.IsValidEmail(@Email NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    RETURN CASE
        WHEN @Email LIKE '%@%.%' AND
             @Email NOT LIKE '%..%' AND
             @Email NOT LIKE '.%' AND
             @Email NOT LIKE '%.' AND
             LEN(@Email) > 5
        THEN 1
        ELSE 0
    END;
END;

ALTER TABLE Customers
ADD CONSTRAINT CHK_Customers_ValidEmail
CHECK (dbo.IsValidEmail(Email) = 1);

-- Complex business rule constraint
ALTER TABLE Orders
ADD CONSTRAINT CHK_Orders_BusinessRules
CHECK (
    (Status = 'Pending' AND PaymentDate IS NULL) OR
    (Status = 'Paid' AND PaymentDate IS NOT NULL) OR
    (Status = 'Cancelled')
);

-- Temporal constraint
ALTER TABLE Employees
ADD CONSTRAINT CHK_Employees_DateLogic
CHECK (HireDate <= GETDATE() AND (TerminationDate IS NULL OR TerminationDate >= HireDate));
```

## Transactions and Concurrency

### Transaction Isolation Levels

```sql
-- Read Uncommitted (allows dirty reads)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Accounts WHERE AccountID = 123;
COMMIT;

-- Read Committed (default, prevents dirty reads)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Accounts WHERE AccountID = 123;
COMMIT;

-- Repeatable Read (prevents dirty and non-repeatable reads)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT * FROM Accounts WHERE AccountID = 123;
-- Data won't change if read again in same transaction
SELECT * FROM Accounts WHERE AccountID = 123;
COMMIT;

-- Serializable (prevents all phenomena)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT COUNT(*) FROM Accounts WHERE Balance > 1000;
-- No new records can be inserted that would affect this count
COMMIT;

-- Snapshot isolation (requires database setting)
ALTER DATABASE MyDatabase SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE MyDatabase SET READ_COMMITTED_SNAPSHOT ON;

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
SELECT * FROM Accounts WHERE AccountID = 123;
-- Sees consistent snapshot from transaction start time
COMMIT;
```

### Deadlock Handling

```sql
-- Deadlock retry logic
CREATE PROCEDURE usp_TransferWithRetry
    @FromAccount INT,
    @ToAccount INT,
    @Amount DECIMAL(10,2),
    @MaxRetries INT = 3
AS
BEGIN
    DECLARE @RetryCount INT = 0;
    DECLARE @Success BIT = 0;

    WHILE @RetryCount < @MaxRetries AND @Success = 0
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            -- Always access accounts in same order to prevent deadlocks
            IF @FromAccount < @ToAccount
            BEGIN
                UPDATE Accounts SET Balance = Balance - @Amount
                WHERE AccountID = @FromAccount;

                UPDATE Accounts SET Balance = Balance + @Amount
                WHERE AccountID = @ToAccount;
            END
            ELSE
            BEGIN
                UPDATE Accounts SET Balance = Balance + @Amount
                WHERE AccountID = @ToAccount;

                UPDATE Accounts SET Balance = Balance - @Amount
                WHERE AccountID = @FromAccount;
            END

            COMMIT TRANSACTION;
            SET @Success = 1;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            IF ERROR_NUMBER() = 1205 -- Deadlock
            BEGIN
                SET @RetryCount = @RetryCount + 1;
                WAITFOR DELAY '00:00:01'; -- Wait 1 second before retry
            END
            ELSE
            BEGIN
                THROW; -- Re-throw non-deadlock errors
            END
        END CATCH
    END

    IF @Success = 0
        RAISERROR('Transaction failed after maximum retries', 16, 1);
END;
```

### Lock Hints and Optimization

```sql
-- Lock hints
SELECT * FROM Accounts WITH (NOLOCK) WHERE Balance > 1000;
SELECT * FROM Accounts WITH (READPAST) WHERE Balance > 1000;
SELECT * FROM Accounts WITH (UPDLOCK) WHERE AccountID = 123;
SELECT * FROM Accounts WITH (XLOCK) WHERE AccountID = 123;

-- Row versioning
-- Enable row versioning for better concurrency
ALTER DATABASE MyDatabase SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE MyDatabase SET READ_COMMITTED_SNAPSHOT ON;

-- Monitor locks and blocking
SELECT
    r.session_id,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS database_name,
    r.wait_type,
    r.wait_time,
    r.command,
    s.text AS sql_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.blocking_session_id != 0;

-- Kill blocking session (use with extreme caution)
-- KILL 53; -- Replace 53 with actual session_id
```

This concludes the first part of the advanced guide. Would you like me to continue with the remaining sections covering Database Administration, High Availability, Security, Monitoring, and Advanced Data Types?
