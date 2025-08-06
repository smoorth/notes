# MSSQL Best Practices Guide

## Table of Contents

1. [Database Design Best Practices](#database-design-best-practices)
2. [Performance Best Practices](#performance-best-practices)
3. [Security Best Practices](#security-best-practices)
4. [Backup and Recovery Best Practices](#backup-and-recovery-best-practices)
5. [Maintenance Best Practices](#maintenance-best-practices)
6. [Development Best Practices](#development-best-practices)
7. [Configuration Best Practices](#configuration-best-practices)
8. [Monitoring Best Practices](#monitoring-best-practices)
9. [High Availability Best Practices](#high-availability-best-practices)
10. [Troubleshooting Best Practices](#troubleshooting-best-practices)

## Database Design Best Practices

### Schema Design

```sql
-- Use appropriate data types
-- Good: Use specific data types
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,        -- Not NVARCHAR(MAX)
    Price DECIMAL(10,2) NOT NULL,              -- Not FLOAT for money
    CreatedDate DATETIME2(0) DEFAULT GETDATE(), -- Not DATETIME for new projects
    IsActive BIT NOT NULL DEFAULT 1,           -- Not TINYINT for boolean
    CategoryID INT NOT NULL,

    CONSTRAINT FK_Products_Category
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CHK_Products_Price
        CHECK (Price >= 0),
    CONSTRAINT CHK_Products_ProductName
        CHECK (LEN(TRIM(ProductName)) > 0)
);

-- Bad: Inefficient data types
CREATE TABLE ProductsBad (
    ProductID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY, -- Wide clustered key
    ProductName NVARCHAR(MAX),                              -- Oversized
    Price FLOAT,                                            -- Imprecise for money
    CreatedDate DATETIME,                                   -- Less precise
    IsActive TINYINT,                                       -- Inefficient for boolean
    CategoryID UNIQUEIDENTIFIER                             -- Wide foreign key
);

-- Normalization principles
-- Properly normalized tables
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2(0) NOT NULL,
    ShippingAddressID INT NOT NULL,
    BillingAddressID INT NOT NULL,

    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ShippingAddressID) REFERENCES Addresses(AddressID),
    FOREIGN KEY (BillingAddressID) REFERENCES Addresses(AddressID)
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CHECK (Quantity > 0),
    CHECK (UnitPrice >= 0)
);

-- Avoid denormalization unless performance requires it
-- Only denormalize for read-heavy scenarios with proper justification
```

### Naming Conventions

```sql
-- Consistent naming conventions
-- Tables: PascalCase, plural nouns
CREATE TABLE Customers (...);
CREATE TABLE OrderItems (...);

-- Columns: PascalCase, descriptive names
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    DepartmentID INT NOT NULL
);

-- Indexes: Prefix with type, include table and column names
CREATE NONCLUSTERED INDEX IX_Employees_LastName ON Employees(LastName);
CREATE UNIQUE NONCLUSTERED INDEX UX_Employees_Email ON Employees(Email);

-- Constraints: Descriptive names with prefixes
ALTER TABLE Employees ADD CONSTRAINT PK_Employees_EmployeeID PRIMARY KEY (EmployeeID);
ALTER TABLE Employees ADD CONSTRAINT FK_Employees_DepartmentID FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);
ALTER TABLE Employees ADD CONSTRAINT CHK_Employees_HireDate CHECK (HireDate <= GETDATE());
ALTER TABLE Employees ADD CONSTRAINT DF_Employees_IsActive DEFAULT 1 FOR IsActive;

-- Stored procedures: Prefix with usp_
CREATE PROCEDURE usp_GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    -- Procedure logic
END;

-- Functions: Prefix with fn_ for scalar, tvf_ for table-valued
CREATE FUNCTION dbo.fn_CalculateAge(@BirthDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE());
END;
```

### Data Integrity

```sql
-- Comprehensive constraint strategy
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    CustomerCode CHAR(10) NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactEmail NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NULL,
    CreditLimit DECIMAL(12,2) NOT NULL,
    CreatedDate DATETIME2(0) NOT NULL,
    ModifiedDate DATETIME2(0) NOT NULL,
    IsActive BIT NOT NULL,

    -- Primary key
    CONSTRAINT PK_Customers_CustomerID PRIMARY KEY CLUSTERED (CustomerID),

    -- Unique constraints
    CONSTRAINT UX_Customers_CustomerCode UNIQUE (CustomerCode),
    CONSTRAINT UX_Customers_ContactEmail UNIQUE (ContactEmail),

    -- Check constraints
    CONSTRAINT CHK_Customers_CustomerCode CHECK (CustomerCode LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CHK_Customers_ContactEmail CHECK (ContactEmail LIKE '%@%.%' OR ContactEmail IS NULL),
    CONSTRAINT CHK_Customers_CreditLimit CHECK (CreditLimit >= 0),
    CONSTRAINT CHK_Customers_Phone CHECK (Phone NOT LIKE '%[^0-9\-\(\)\+\. ]%' OR Phone IS NULL),

    -- Default constraints
    CONSTRAINT DF_Customers_CreatedDate DEFAULT GETDATE() FOR CreatedDate,
    CONSTRAINT DF_Customers_ModifiedDate DEFAULT GETDATE() FOR ModifiedDate,
    CONSTRAINT DF_Customers_IsActive DEFAULT 1 FOR IsActive,
    CONSTRAINT DF_Customers_CreditLimit DEFAULT 0 FOR CreditLimit
);

-- Trigger for automatic timestamp updates
CREATE TRIGGER tr_Customers_UpdateModifiedDate
ON Customers
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Customers
    SET ModifiedDate = GETDATE()
    FROM Customers c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID;
END;
```

## Performance Best Practices

### Query Design

```sql
-- Use specific columns instead of SELECT *
-- Good
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE City = 'New York';

-- Bad
SELECT * FROM Customers WHERE City = 'New York';

-- Use SARGABLE predicates
-- Good: Index can be used
SELECT * FROM Orders
WHERE OrderDate >= '2023-01-01' AND OrderDate < '2024-01-01';

-- Bad: Function prevents index usage
SELECT * FROM Orders WHERE YEAR(OrderDate) = 2023;

-- Use appropriate join types
-- Use EXISTS for existence checks
SELECT CustomerID, FirstName, LastName
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.CustomerID = c.CustomerID
    AND o.OrderDate >= '2023-01-01'
);

-- Use IN for small, static lists
SELECT * FROM Products WHERE CategoryID IN (1, 2, 3);

-- Use proper WHERE clause ordering (most selective first)
SELECT * FROM Orders
WHERE Status = 'Shipped'          -- More selective
  AND CustomerID = 123            -- Less selective
  AND OrderDate >= '2023-01-01'; -- Range condition last

-- Avoid correlated subqueries when possible
-- Good: Use JOIN
SELECT c.CustomerID, c.FirstName, c.LastName, o.OrderCount
FROM Customers c
INNER JOIN (
    SELECT CustomerID, COUNT(*) AS OrderCount
    FROM Orders
    GROUP BY CustomerID
) o ON c.CustomerID = o.CustomerID;

-- Bad: Correlated subquery
SELECT CustomerID, FirstName, LastName,
    (SELECT COUNT(*) FROM Orders o WHERE o.CustomerID = c.CustomerID) AS OrderCount
FROM Customers c;
```

### Index Strategy

```sql
-- Create covering indexes for frequently used queries
CREATE NONCLUSTERED INDEX IX_Orders_CustomerDate_Covering
ON Orders (CustomerID, OrderDate)
INCLUDE (TotalAmount, Status, ShippingAddress);

-- Use filtered indexes for subset data
CREATE NONCLUSTERED INDEX IX_Orders_PendingStatus
ON Orders (OrderDate, CustomerID)
WHERE Status = 'Pending';

-- Create composite indexes with proper column order
-- Most selective column first, then by frequency of use
CREATE NONCLUSTERED INDEX IX_Employees_DeptLastFirst
ON Employees (DepartmentID, LastName, FirstName);

-- Avoid over-indexing
-- Monitor index usage and remove unused indexes
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ius.user_seeks + ius.user_scans + ius.user_lookups AS TotalReads,
    ius.user_updates AS TotalWrites,
    CASE
        WHEN ius.user_updates > 0 THEN
            CAST((ius.user_seeks + ius.user_scans + ius.user_lookups) AS FLOAT) / ius.user_updates
        ELSE 0
    END AS ReadWriteRatio
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE OBJECT_SCHEMA_NAME(i.object_id) != 'sys'
    AND i.name IS NOT NULL
ORDER BY TotalReads DESC;
```

## Security Best Practices

### Authentication and Authorization

```sql
-- Use Windows Authentication when possible
-- Create Windows login
CREATE LOGIN [DOMAIN\ServiceAccount] FROM WINDOWS;

-- Create SQL login with strong password policy
CREATE LOGIN AppUser WITH
    PASSWORD = 'ComplexP@ssw0rd123!',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;

-- Principle of least privilege
-- Create custom roles for specific functions
CREATE ROLE db_reporting;
GRANT SELECT ON dbo.Customers TO db_reporting;
GRANT SELECT ON dbo.Orders TO db_reporting;
GRANT SELECT ON dbo.Products TO db_reporting;

CREATE ROLE db_dataentry;
GRANT SELECT, INSERT, UPDATE ON dbo.Orders TO db_dataentry;
GRANT SELECT ON dbo.Customers TO db_dataentry;
GRANT SELECT ON dbo.Products TO db_dataentry;

-- Assign users to roles
ALTER ROLE db_reporting ADD MEMBER [DOMAIN\ReportUser];
ALTER ROLE db_dataentry ADD MEMBER AppUser;
```

### SQL Injection Prevention

```sql
-- Use parameterized queries
-- Good: Parameterized query
CREATE PROCEDURE usp_GetCustomerByEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT CustomerID, FirstName, LastName, Email
    FROM Customers
    WHERE Email = @Email;
END;

-- Bad: Dynamic SQL with concatenation
CREATE PROCEDURE usp_GetCustomerByEmailBad
    @Email NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = 'SELECT CustomerID, FirstName, LastName, Email FROM Customers WHERE Email = ''' + @Email + '''';
    EXEC sp_executesql @SQL;
END;

-- When dynamic SQL is necessary, use sp_executesql
CREATE PROCEDURE usp_GetDataDynamic
    @TableName SYSNAME,
    @WhereClause NVARCHAR(MAX)
AS
BEGIN
    -- Validate table name against whitelist
    IF @TableName NOT IN ('Customers', 'Orders', 'Products')
    BEGIN
        RAISERROR('Invalid table name', 16, 1);
        RETURN;
    END

    DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM ' + QUOTENAME(@TableName) + ' WHERE ' + @WhereClause;
    EXEC sp_executesql @SQL;
END;

-- Input validation
CREATE PROCEDURE usp_GetOrdersByStatus
    @Status NVARCHAR(20)
AS
BEGIN
    -- Validate input against allowed values
    IF @Status NOT IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
    BEGIN
        RAISERROR('Invalid status value', 16, 1);
        RETURN;
    END

    SELECT OrderID, CustomerID, OrderDate, Status
    FROM Orders
    WHERE Status = @Status;
END;
```

## Backup and Recovery Best Practices

### Backup Strategy

```sql
-- Implement comprehensive backup strategy
-- Full backup weekly
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Full_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.bak'
WITH COMPRESSION, CHECKSUM, INIT;

-- Differential backup daily
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Diff_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.bak'
WITH DIFFERENTIAL, COMPRESSION, CHECKSUM, INIT;

-- Transaction log backup every 15 minutes
BACKUP LOG MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Log_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.trn'
WITH COMPRESSION, CHECKSUM, INIT;

-- Verify backups
RESTORE VERIFYONLY FROM DISK = 'C:\Backups\MyDatabase_Full_20231201_090000.bak';

-- Test restore procedures regularly
-- Restore to test environment
RESTORE DATABASE MyDatabase_Test
FROM DISK = 'C:\Backups\MyDatabase_Full_20231201_090000.bak'
WITH MOVE 'MyDatabase' TO 'C:\TestData\MyDatabase_Test.mdf',
     MOVE 'MyDatabase_Log' TO 'C:\TestData\MyDatabase_Test.ldf',
     REPLACE, NORECOVERY;

RESTORE DATABASE MyDatabase_Test
FROM DISK = 'C:\Backups\MyDatabase_Diff_20231201_180000.bak'
WITH NORECOVERY;

RESTORE LOG MyDatabase_Test
FROM DISK = 'C:\Backups\MyDatabase_Log_20231201_181500.trn'
WITH RECOVERY;
```

## Maintenance Best Practices

### Index Maintenance

```sql
-- Automated index maintenance procedure
CREATE PROCEDURE usp_IndexMaintenance
    @DatabaseName SYSNAME = NULL,
    @FragmentationThreshold FLOAT = 10.0,
    @RebuildThreshold FLOAT = 30.0,
    @MinPageCount INT = 1000,
    @OnlineRebuild BIT = 1,
    @UpdateStatistics BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDatabase SYSNAME = ISNULL(@DatabaseName, DB_NAME());
    DECLARE @SQL NVARCHAR(MAX);

    -- Create temporary table for maintenance commands
    CREATE TABLE #MaintenanceCommands (
        ID INT IDENTITY(1,1),
        Command NVARCHAR(MAX),
        ObjectName NVARCHAR(256),
        FragmentationPercent FLOAT
    );

    -- Get fragmented indexes
    SET @SQL = '
    USE ' + QUOTENAME(@CurrentDatabase) + ';
    INSERT INTO #MaintenanceCommands (Command, ObjectName, FragmentationPercent)
    SELECT
        CASE
            WHEN ips.avg_fragmentation_in_percent >= ' + CAST(@RebuildThreshold AS VARCHAR(10)) + ' THEN
                ''ALTER INDEX '' + QUOTENAME(i.name) + '' ON '' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + ''.'' + QUOTENAME(t.name) + '' REBUILD'' +
                CASE WHEN ' + CAST(@OnlineRebuild AS VARCHAR(1)) + ' = 1 THEN '' WITH (ONLINE = ON)'' ELSE '''' END + '';''
            ELSE
                ''ALTER INDEX '' + QUOTENAME(i.name) + '' ON '' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + ''.'' + QUOTENAME(t.name) + '' REORGANIZE;''
        END,
        SCHEMA_NAME(t.schema_id) + ''.'' + t.name + ''.'' + i.name,
        ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, ''LIMITED'') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
    INNER JOIN sys.tables t ON ips.object_id = t.object_id
    WHERE ips.avg_fragmentation_in_percent >= ' + CAST(@FragmentationThreshold AS VARCHAR(10)) + '
        AND ips.page_count >= ' + CAST(@MinPageCount AS VARCHAR(10)) + '
        AND i.name IS NOT NULL
        AND i.is_disabled = 0';

    EXEC sp_executesql @SQL;

    -- Execute maintenance commands
    DECLARE @Command NVARCHAR(MAX), @ObjectName NVARCHAR(256), @FragmentationPercent FLOAT;
    DECLARE maintenance_cursor CURSOR FOR
    SELECT Command, ObjectName, FragmentationPercent
    FROM #MaintenanceCommands
    ORDER BY FragmentationPercent DESC;

    OPEN maintenance_cursor;
    FETCH NEXT FROM maintenance_cursor INTO @Command, @ObjectName, @FragmentationPercent;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            PRINT 'Executing: ' + @Command + ' (Fragmentation: ' + CAST(@FragmentationPercent AS VARCHAR(10)) + '%)';
            EXEC sp_executesql @Command;
            PRINT 'Success: ' + @ObjectName;
        END TRY
        BEGIN CATCH
            PRINT 'Error on ' + @ObjectName + ': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM maintenance_cursor INTO @Command, @ObjectName, @FragmentationPercent;
    END

    CLOSE maintenance_cursor;
    DEALLOCATE maintenance_cursor;

    -- Update statistics if requested
    IF @UpdateStatistics = 1
    BEGIN
        PRINT 'Updating statistics...';
        SET @SQL = 'USE ' + QUOTENAME(@CurrentDatabase) + '; EXEC sp_updatestats;';
        EXEC sp_executesql @SQL;
        PRINT 'Statistics updated.';
    END

    DROP TABLE #MaintenanceCommands;
    PRINT 'Index maintenance completed for database: ' + @CurrentDatabase;
END;
```

## Development Best Practices

### Code Organization

```sql
-- Use consistent formatting and commenting
CREATE PROCEDURE usp_ProcessMonthlyOrders
    @Year INT,
    @Month INT,
    @ProcessedBy NVARCHAR(50)
AS
/*
Purpose: Process all orders for a specific month
Author: [Your Name]
Created: [Date]
Modified: [Date] - [Description of changes]

Parameters:
    @Year - Year to process (YYYY format)
    @Month - Month to process (1-12)
    @ProcessedBy - Name of user processing orders

Returns:
    Result set with processed order counts

Example:
    EXEC usp_ProcessMonthlyOrders @Year = 2023, @Month = 12, @ProcessedBy = 'John Doe';
*/
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;
    DECLARE @ProcessedCount INT = 0;
    DECLARE @ErrorMessage NVARCHAR(2048);

    BEGIN TRY
        -- Validate input parameters
        IF @Year < 1900 OR @Year > YEAR(GETDATE()) + 1
        BEGIN
            RAISERROR('Invalid year parameter', 16, 1);
            RETURN;
        END

        IF @Month < 1 OR @Month > 12
        BEGIN
            RAISERROR('Invalid month parameter', 16, 1);
            RETURN;
        END

        -- Calculate date range
        SET @StartDate = DATEFROMPARTS(@Year, @Month, 1);
        SET @EndDate = EOMONTH(@StartDate);

        -- Begin transaction
        BEGIN TRANSACTION;

        -- Process orders
        UPDATE Orders
        SET
            Status = 'Processed',
            ProcessedDate = GETDATE(),
            ProcessedBy = @ProcessedBy
        WHERE OrderDate >= @StartDate
            AND OrderDate <= @EndDate
            AND Status = 'Pending';

        SET @ProcessedCount = @@ROWCOUNT;

        -- Log processing activity
        INSERT INTO ProcessingLog (ProcessDate, ProcessedBy, RecordsProcessed, StartDate, EndDate)
        VALUES (GETDATE(), @ProcessedBy, @ProcessedCount, @StartDate, @EndDate);

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return results
        SELECT
            @Year AS ProcessedYear,
            @Month AS ProcessedMonth,
            @ProcessedCount AS OrdersProcessed,
            @StartDate AS PeriodStart,
            @EndDate AS PeriodEnd,
            @ProcessedBy AS ProcessedBy;

    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Get error information
        SELECT
            @ErrorMessage = ERROR_MESSAGE();

        -- Log error
        INSERT INTO ErrorLog (ErrorDate, ErrorMessage, ProcedureName, Parameters)
        VALUES (GETDATE(), @ErrorMessage, 'usp_ProcessMonthlyOrders',
                'Year=' + CAST(@Year AS VARCHAR(4)) + ', Month=' + CAST(@Month AS VARCHAR(2)));

        -- Re-raise error
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

### Version Control and Deployment

```sql
-- Database versioning table
CREATE TABLE DatabaseVersion (
    VersionID INT IDENTITY(1,1) PRIMARY KEY,
    VersionNumber NVARCHAR(20) NOT NULL,
    ReleaseDate DATETIME2(0) NOT NULL DEFAULT GETDATE(),
    Description NVARCHAR(500),
    AppliedBy NVARCHAR(100) NOT NULL DEFAULT SUSER_SNAME()
);

-- Migration script template
/*
Migration Script: v1.2.3 to v1.2.4
Date: 2023-12-01
Description: Add new customer segmentation features
*/

-- Check current version
DECLARE @CurrentVersion NVARCHAR(20);
SELECT @CurrentVersion = VersionNumber
FROM DatabaseVersion
WHERE VersionID = (SELECT MAX(VersionID) FROM DatabaseVersion);

IF @CurrentVersion != '1.2.3'
BEGIN
    RAISERROR('Current version must be 1.2.3 to apply this migration', 16, 1);
    RETURN;
END

BEGIN TRANSACTION;

BEGIN TRY
    -- Apply schema changes
    ALTER TABLE Customers ADD CustomerSegment NVARCHAR(50);

    -- Create new indexes
    CREATE NONCLUSTERED INDEX IX_Customers_Segment ON Customers(CustomerSegment);

    -- Update data
    UPDATE Customers
    SET CustomerSegment = CASE
        WHEN TotalPurchases > 10000 THEN 'Premium'
        WHEN TotalPurchases > 1000 THEN 'Standard'
        ELSE 'Basic'
    END;

    -- Create new stored procedures
    EXEC('CREATE PROCEDURE usp_GetCustomersBySegment...');

    -- Record version
    INSERT INTO DatabaseVersion (VersionNumber, Description)
    VALUES ('1.2.4', 'Add customer segmentation features');

    COMMIT TRANSACTION;
    PRINT 'Migration to version 1.2.4 completed successfully';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Migration failed: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
```

## Configuration Best Practices

### Server Configuration

```sql
-- Configure memory settings
-- Set max server memory (leave 2-4GB for OS)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 6144; -- 6GB for 8GB server
RECONFIGURE;

-- Enable optimize for ad hoc workloads
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;

-- Configure backup compression default
EXEC sp_configure 'backup compression default', 1;
RECONFIGURE;

-- Set cost threshold for parallelism
EXEC sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;

-- Set max degree of parallelism (typically number of CPU cores or 8, whichever is smaller)
EXEC sp_configure 'max degree of parallelism', 4;
RECONFIGURE;
```

### Database Configuration

```sql
-- Set database options for optimal performance
ALTER DATABASE MyDatabase SET RECOVERY FULL;
ALTER DATABASE MyDatabase SET AUTO_CLOSE OFF;
ALTER DATABASE MyDatabase SET AUTO_SHRINK OFF;
ALTER DATABASE MyDatabase SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE MyDatabase SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE MyDatabase SET AUTO_UPDATE_STATISTICS_ASYNC ON;
ALTER DATABASE MyDatabase SET PAGE_VERIFY CHECKSUM;

-- Enable Query Store for query performance insights
ALTER DATABASE MyDatabase SET QUERY_STORE = ON (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);
```

## Monitoring Best Practices

### Key Performance Indicators

```sql
-- Create monitoring view for key metrics
CREATE VIEW vw_DatabaseHealth
AS
SELECT
    -- Database information
    DB_NAME() AS DatabaseName,
    GETDATE() AS CheckTime,

    -- Memory metrics
    (SELECT cntr_value FROM sys.dm_os_performance_counters
     WHERE counter_name = 'Page life expectancy') AS PageLifeExpectancy,

    (SELECT cntr_value FROM sys.dm_os_performance_counters
     WHERE counter_name = 'Buffer cache hit ratio') AS BufferCacheHitRatio,

    -- CPU metrics
    (SELECT AVG(avg_cpu_percent) FROM sys.dm_db_resource_stats
     WHERE end_time >= DATEADD(MINUTE, -5, GETDATE())) AS AvgCPUPercent,

    -- Wait statistics
    (SELECT TOP 1 wait_type FROM sys.dm_os_wait_stats
     WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK')
     ORDER BY wait_time_ms DESC) AS TopWaitType,

    -- Connection count
    (SELECT COUNT(*) FROM sys.dm_exec_sessions WHERE is_user_process = 1) AS ActiveConnections,

    -- Blocking sessions
    (SELECT COUNT(*) FROM sys.dm_exec_requests WHERE blocking_session_id != 0) AS BlockedSessions;

-- Create alert for long-running queries
CREATE PROCEDURE usp_CheckLongRunningQueries
    @ThresholdMinutes INT = 5
AS
BEGIN
    DECLARE @LongRunningCount INT;

    SELECT @LongRunningCount = COUNT(*)
    FROM sys.dm_exec_requests
    WHERE total_elapsed_time > (@ThresholdMinutes * 60 * 1000);

    IF @LongRunningCount > 0
    BEGIN
        -- Log or alert about long-running queries
        SELECT
            session_id,
            total_elapsed_time / 1000 / 60 AS elapsed_minutes,
            command,
            wait_type,
            blocking_session_id,
            sql_text = (SELECT text FROM sys.dm_exec_sql_text(sql_handle))
        FROM sys.dm_exec_requests
        WHERE total_elapsed_time > (@ThresholdMinutes * 60 * 1000);
    END
END;
```

This comprehensive MSSQL documentation provides practical guidance for working with SQL Server from beginner to advanced levels, covering essential topics like design, performance, security, maintenance, and best practices. Each guide includes real-world examples and actionable recommendations that can be immediately applied in production environments.
