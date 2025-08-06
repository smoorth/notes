# Microsoft SQL Server (MSSQL) - Beginner's Guide

## Table of Contents
1. [Introduction to MSSQL](#introduction-to-mssql)
2. [Installation and Setup](#installation-and-setup)
3. [Basic Concepts](#basic-concepts)
4. [Getting Started with SQL Server Management Studio (SSMS)](#getting-started-with-ssms)
5. [Basic Database Operations](#basic-database-operations)
6. [Basic SQL Commands](#basic-sql-commands)
7. [Data Types](#data-types)
8. [Working with Tables](#working-with-tables)
9. [Basic Queries](#basic-queries)
10. [Indexes - Introduction](#indexes-introduction)
11. [Backup and Restore Basics](#backup-and-restore-basics)
12. [Security Basics](#security-basics)
13. [Best Practices for Beginners](#best-practices-for-beginners)

## Introduction to MSSQL

Microsoft SQL Server (MSSQL) is a relational database management system (RDBMS) developed by Microsoft. It's designed to store, retrieve, and manage data efficiently for applications ranging from small desktop applications to large enterprise systems.

### Key Features
- **Relational Database**: Organizes data in tables with relationships
- **ACID Compliance**: Ensures data integrity through Atomicity, Consistency, Isolation, and Durability
- **Scalability**: Can handle small to very large databases
- **Security**: Built-in security features and encryption
- **Integration**: Works well with other Microsoft products
- **Business Intelligence**: Built-in reporting and analytics tools

### Editions
- **Express**: Free, limited edition for small applications
- **Standard**: Mid-range edition for departmental applications
- **Enterprise**: Full-featured edition for large-scale applications
- **Developer**: Full-featured edition for development (free)

## Installation and Setup

### SQL Server Express (Free Edition)
1. Download SQL Server Express from Microsoft's website
2. Run the installer and choose "Basic" installation
3. Follow the installation wizard
4. Note the server name (usually `localhost\SQLEXPRESS` or `.\SQLEXPRESS`)

### SQL Server Management Studio (SSMS)
1. Download SSMS separately from Microsoft's website
2. Install SSMS after SQL Server installation
3. Launch SSMS and connect to your SQL Server instance

### First Connection
```sql
-- Server name examples:
-- localhost\SQLEXPRESS
-- .\SQLEXPRESS
-- (local)\SQLEXPRESS
-- For default instance: localhost or .
```

## Basic Concepts

### Database
A database is a collection of related tables and other objects that store data for a specific application or purpose.

### Table
A table is a collection of rows and columns that stores data. Each row represents a record, and each column represents a field.

### Schema
A schema is a logical container for database objects. The default schema is `dbo` (database owner).

### Primary Key
A column or combination of columns that uniquely identifies each row in a table.

### Foreign Key
A column that references the primary key of another table, establishing a relationship.

### Index
A database object that improves query performance by creating shortcuts to data.

## Getting Started with SSMS

### Connecting to SQL Server
1. Open SSMS
2. In the "Connect to Server" dialog:
   - Server type: Database Engine
   - Server name: Your SQL Server instance name
   - Authentication: Windows Authentication (recommended) or SQL Server Authentication
3. Click "Connect"

### SSMS Interface Overview
- **Object Explorer**: Browse databases, tables, and other objects
- **Query Editor**: Write and execute SQL commands
- **Results Pane**: View query results
- **Messages Pane**: View system messages and errors

### Navigation Tips
```sql
-- Use Ctrl+N for new query window
-- Use F5 or Ctrl+E to execute query
-- Use Ctrl+Shift+R to refresh IntelliSense
-- Use Ctrl+L to display execution plan
```

## Basic Database Operations

### Creating a Database
```sql
-- Create a new database
CREATE DATABASE MyFirstDatabase;

-- Create database with specific settings
CREATE DATABASE MyDatabase
ON (
    NAME = 'MyDatabase_Data',
    FILENAME = 'C:\Data\MyDatabase.mdf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 10MB
)
LOG ON (
    NAME = 'MyDatabase_Log',
    FILENAME = 'C:\Data\MyDatabase.ldf',
    SIZE = 10MB,
    FILEGROWTH = 10%
);
```

### Using a Database
```sql
-- Switch to a specific database
USE MyFirstDatabase;

-- Check current database
SELECT DB_NAME() AS CurrentDatabase;
```

### Dropping a Database
```sql
-- Delete a database (be careful!)
DROP DATABASE MyFirstDatabase;
```

## Data Types

### Numeric Types
```sql
-- Integer types
INT             -- 4 bytes, -2,147,483,648 to 2,147,483,647
BIGINT          -- 8 bytes, very large integers
SMALLINT        -- 2 bytes, -32,768 to 32,767
TINYINT         -- 1 byte, 0 to 255

-- Decimal types
DECIMAL(10,2)   -- 10 total digits, 2 after decimal
NUMERIC(10,2)   -- Same as DECIMAL
FLOAT           -- Floating point number
REAL            -- Smaller floating point

-- Money types
MONEY           -- Currency values
SMALLMONEY      -- Smaller currency values
```

### String Types
```sql
-- Character types
CHAR(10)        -- Fixed length, padded with spaces
VARCHAR(50)     -- Variable length, up to 50 characters
VARCHAR(MAX)    -- Variable length, up to 2GB

-- Unicode types
NCHAR(10)       -- Fixed length Unicode
NVARCHAR(50)    -- Variable length Unicode
NVARCHAR(MAX)   -- Variable length Unicode, up to 2GB

-- Text types (deprecated, use VARCHAR(MAX))
TEXT            -- Large text data (deprecated)
NTEXT           -- Large Unicode text (deprecated)
```

### Date and Time Types
```sql
DATE            -- Date only (YYYY-MM-DD)
TIME            -- Time only (HH:MM:SS.nnnnnnn)
DATETIME        -- Date and time
DATETIME2       -- More precise date and time
SMALLDATETIME   -- Less precise date and time
DATETIMEOFFSET  -- Date and time with timezone
```

### Other Common Types
```sql
BIT             -- Boolean (0 or 1)
UNIQUEIDENTIFIER -- GUID
XML             -- XML data
VARBINARY(MAX)  -- Binary data
IMAGE           -- Binary data (deprecated)
```

## Working with Tables

### Creating Tables
```sql
-- Basic table creation
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Table with foreign key
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
```

### Modifying Tables
```sql
-- Add a column
ALTER TABLE Customers
ADD City NVARCHAR(50);

-- Modify a column
ALTER TABLE Customers
ALTER COLUMN Phone NVARCHAR(25);

-- Drop a column
ALTER TABLE Customers
DROP COLUMN City;

-- Add a constraint
ALTER TABLE Customers
ADD CONSTRAINT CHK_Email CHECK (Email LIKE '%@%.%');
```

### Dropping Tables
```sql
-- Drop a table
DROP TABLE Orders;
DROP TABLE Customers;
```

## Basic SQL Commands

### INSERT - Adding Data
```sql
-- Insert single row
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ('John', 'Doe', 'john.doe@email.com', '555-1234');

-- Insert multiple rows
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES
    ('Jane', 'Smith', 'jane.smith@email.com', '555-5678'),
    ('Bob', 'Johnson', 'bob.johnson@email.com', '555-9012'),
    ('Alice', 'Williams', 'alice.williams@email.com', '555-3456');

-- Insert with specific columns
INSERT INTO Customers (FirstName, LastName)
VALUES ('Mike', 'Brown');
```

### SELECT - Querying Data
```sql
-- Select all columns
SELECT * FROM Customers;

-- Select specific columns
SELECT FirstName, LastName, Email FROM Customers;

-- Select with WHERE clause
SELECT * FROM Customers
WHERE LastName = 'Smith';

-- Select with multiple conditions
SELECT * FROM Customers
WHERE FirstName = 'John' AND LastName = 'Doe';

-- Select with OR condition
SELECT * FROM Customers
WHERE FirstName = 'John' OR FirstName = 'Jane';
```

### UPDATE - Modifying Data
```sql
-- Update single record
UPDATE Customers
SET Phone = '555-0000'
WHERE CustomerID = 1;

-- Update multiple columns
UPDATE Customers
SET FirstName = 'Jonathan', Phone = '555-1111'
WHERE CustomerID = 1;

-- Update with condition
UPDATE Customers
SET Email = LOWER(Email)
WHERE Email IS NOT NULL;
```

### DELETE - Removing Data
```sql
-- Delete specific record
DELETE FROM Customers
WHERE CustomerID = 5;

-- Delete with condition
DELETE FROM Customers
WHERE CreatedDate < '2020-01-01';

-- Delete all records (use with caution!)
DELETE FROM Customers;
```

## Basic Queries

### Filtering Data
```sql
-- WHERE clause examples
SELECT * FROM Customers WHERE FirstName = 'John';
SELECT * FROM Customers WHERE CustomerID > 10;
SELECT * FROM Customers WHERE Email IS NOT NULL;
SELECT * FROM Customers WHERE Email IS NULL;
SELECT * FROM Customers WHERE FirstName LIKE 'J%';  -- Starts with J
SELECT * FROM Customers WHERE FirstName LIKE '%n';  -- Ends with n
SELECT * FROM Customers WHERE FirstName LIKE '%oh%'; -- Contains 'oh'

-- IN clause
SELECT * FROM Customers
WHERE FirstName IN ('John', 'Jane', 'Bob');

-- BETWEEN clause
SELECT * FROM Orders
WHERE OrderDate BETWEEN '2023-01-01' AND '2023-12-31';
```

### Sorting Data
```sql
-- ORDER BY clause
SELECT * FROM Customers ORDER BY LastName;
SELECT * FROM Customers ORDER BY LastName DESC;
SELECT * FROM Customers ORDER BY LastName, FirstName;
SELECT * FROM Orders ORDER BY OrderDate DESC, TotalAmount DESC;
```

### Limiting Results
```sql
-- TOP clause
SELECT TOP 10 * FROM Customers;
SELECT TOP 5 * FROM Orders ORDER BY TotalAmount DESC;

-- OFFSET and FETCH (SQL Server 2012+)
SELECT * FROM Customers
ORDER BY CustomerID
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY;
```

### Aggregate Functions
```sql
-- COUNT
SELECT COUNT(*) FROM Customers;
SELECT COUNT(Email) FROM Customers; -- Excludes NULL values

-- SUM, AVG, MIN, MAX
SELECT SUM(TotalAmount) FROM Orders;
SELECT AVG(TotalAmount) FROM Orders;
SELECT MIN(OrderDate) FROM Orders;
SELECT MAX(TotalAmount) FROM Orders;

-- GROUP BY
SELECT CustomerID, COUNT(*) as OrderCount, SUM(TotalAmount) as TotalSpent
FROM Orders
GROUP BY CustomerID;

-- HAVING (filter groups)
SELECT CustomerID, COUNT(*) as OrderCount
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) > 2;
```

### Basic Joins
```sql
-- INNER JOIN
SELECT c.FirstName, c.LastName, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- LEFT JOIN
SELECT c.FirstName, c.LastName, o.OrderDate, o.TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Count orders per customer
SELECT c.FirstName, c.LastName, COUNT(o.OrderID) as OrderCount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
```

## Indexes - Introduction

### What are Indexes?
Indexes are database objects that improve query performance by creating shortcuts to data, similar to an index in a book.

### Types of Indexes
- **Clustered Index**: Physically sorts the data (one per table)
- **Non-Clustered Index**: Creates a separate structure pointing to data

### Creating Indexes
```sql
-- Create non-clustered index
CREATE INDEX IX_Customers_LastName ON Customers(LastName);

-- Create composite index
CREATE INDEX IX_Customers_Name ON Customers(LastName, FirstName);

-- Create unique index
CREATE UNIQUE INDEX IX_Customers_Email ON Customers(Email);
```

### When to Use Indexes
- Columns frequently used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY
- Foreign key columns

## Backup and Restore Basics

### Creating Backups
```sql
-- Full backup
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Full.bak';

-- Backup with compression
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH COMPRESSION;
```

### Restoring Databases
```sql
-- Restore database
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH REPLACE;

-- Restore to different name
RESTORE DATABASE MyDatabase_Copy
FROM DISK = 'C:\Backups\MyDatabase_Full.bak'
WITH MOVE 'MyDatabase_Data' TO 'C:\Data\MyDatabase_Copy.mdf',
     MOVE 'MyDatabase_Log' TO 'C:\Data\MyDatabase_Copy.ldf';
```

## Security Basics

### Authentication
- **Windows Authentication**: Uses Windows credentials (recommended)
- **SQL Server Authentication**: Uses SQL Server username/password

### Creating Logins and Users
```sql
-- Create SQL Server login
CREATE LOGIN MyUser WITH PASSWORD = 'StrongPassword123!';

-- Create database user
USE MyDatabase;
CREATE USER MyUser FOR LOGIN MyUser;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON Customers TO MyUser;
```

### Basic Security Principles
- Use Windows Authentication when possible
- Follow principle of least privilege
- Use strong passwords
- Regularly update SQL Server
- Monitor access and activity

## Best Practices for Beginners

### Database Design
1. **Use appropriate data types**: Don't use VARCHAR(MAX) for short strings
2. **Define primary keys**: Every table should have a primary key
3. **Use foreign keys**: Maintain referential integrity
4. **Normalize your data**: Avoid data duplication
5. **Use meaningful names**: Clear table and column names

### Query Writing
1. **Use specific column names**: Avoid SELECT *
2. **Use WHERE clauses**: Filter data efficiently
3. **Use appropriate indexes**: Index frequently queried columns
4. **Avoid cursors**: Use set-based operations instead
5. **Test with sample data**: Always test queries before production

### Performance
1. **Monitor query execution**: Use execution plans
2. **Index strategically**: Don't over-index
3. **Update statistics**: Keep statistics current
4. **Regular maintenance**: Update indexes and statistics

### Security
1. **Use least privilege**: Grant minimum necessary permissions
2. **Regular backups**: Implement backup strategy
3. **Keep updated**: Apply security patches
4. **Monitor access**: Review security logs

### Development
1. **Use transactions**: For data consistency
2. **Handle errors**: Implement proper error handling
3. **Document your code**: Comment complex queries
4. **Version control**: Track database changes
5. **Test thoroughly**: Test in development environment first

## Common Beginner Mistakes to Avoid

1. **Not using transactions for multiple operations**
2. **Using SELECT * in production code**
3. **Not backing up databases regularly**
4. **Using wrong data types (like VARCHAR for numbers)**
5. **Not understanding NULL values**
6. **Creating too many or too few indexes**
7. **Not using parameterized queries (SQL injection risk)**
8. **Not testing on realistic data volumes**
9. **Ignoring execution plans and performance**
10. **Not documenting database schema and business rules**

## Next Steps

After mastering these basics, consider learning:
- Advanced SQL queries (CTEs, Window functions)
- Stored procedures and functions
- Triggers and constraints
- Advanced indexing strategies
- Performance tuning
- Database administration
- Reporting Services (SSRS)
- Integration Services (SSIS)
- Analysis Services (SSAS)

## Useful Resources

- **Microsoft Documentation**: Official SQL Server documentation
- **SQL Server Management Studio**: Practice environment
- **Sample Databases**: AdventureWorks, Northwind
- **Online Communities**: Stack Overflow, Reddit r/SQLServer
- **Books**: "T-SQL Fundamentals" by Itzik Ben-Gan

Remember: Practice is key to mastering SQL Server. Start with simple queries and gradually work your way up to more complex scenarios.
