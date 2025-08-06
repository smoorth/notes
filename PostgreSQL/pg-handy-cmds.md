# PostgreSQL Handy Commands

## Table of Contents

- [PostgreSQL Handy Commands](#postgresql-handy-commands)
  - [Table of Contents](#table-of-contents)
  - [PostgreSQL Basics](#postgresql-basics)
    - [What is PostgreSQL?](#what-is-postgresql)
    - [Key Concepts Simplified](#key-concepts-simplified)
    - [How PostgreSQL Works](#how-postgresql-works)
    - [Tips for Beginners](#tips-for-beginners)
    - [Common Issues to Watch For](#common-issues-to-watch-for)
  - [Listing Tables, Databases, Permissions and Users](#listing-tables-databases-permissions-and-users)
  - [Permission Management (GRANT/REVOKE)](#permission-management-grantrevoke)
  - [Data Manipulation (INSERT, UPDATE, DELETE)](#data-manipulation-insert-update-delete)
  - [Backup, Restore, and Migration](#backup-restore-and-migration)
    - [Backup Commands](#backup-commands)
    - [Restore Commands](#restore-commands)
    - [Migration Tools and Commands](#migration-tools-and-commands)

## PostgreSQL Basics

### What is PostgreSQL?

- PostgreSQL is a **relational database management system (RDBMS)** that uses SQL for querying and managing data.
- It is known for being **open-source**, **extensible**, and **highly reliable**.
- PostgreSQL supports advanced features like **ACID compliance**, **JSON/JSONB data types**, and **full-text search**.

### Key Concepts Simplified

- **Database**: A container for organizing and storing data. Each PostgreSQL instance can have multiple databases.
- **Schema**: A namespace within a database that contains tables, views, functions, etc. The default schema is `public`.
- **Table**: A collection of rows and columns where data is stored.
- **Row**: A single record in a table.
- **Column**: A field in a table that defines the type of data stored.
- **Index**: A data structure that improves the speed of data retrieval operations.
- **Role**: A user or group of users with specific permissions.

### How PostgreSQL Works

- PostgreSQL uses a **client-server model**, where the client sends SQL queries to the server, and the server processes and returns results.
- Data is stored in **tables** within schemas, and schemas are part of a database.
- PostgreSQL supports **transactions**, ensuring that a series of operations either all succeed or all fail.
- **Extensions** can be added to enhance PostgreSQL's functionality, such as `PostGIS` for geospatial data.

### Tips for Beginners

- Use `\?` in the `psql` shell to see a list of available commands.
- Use `\h` followed by a SQL command (e.g., `\h SELECT`) to get help on syntax.
- Always back up your database using tools like `pg_dump` before making significant changes.
- Use `EXPLAIN` or `EXPLAIN ANALYZE` to understand and optimize query performance.
- Leverage **roles and permissions** to control access to your database.

### Common Issues to Watch For

- Ensure the PostgreSQL server is running before attempting to connect.
- Use the correct **host**, **port**, **username**, and **password** when connecting to the database.
- Be cautious with **case sensitivity** in object names; unquoted names are converted to lowercase.
- Watch out for **locks** on tables during long-running transactions.
- PostgreSQL typically uses port **5432** for connections (useful for troubleshooting).

## Listing Tables, Databases, Permissions and Users

| Command | Description |
|---------|-------------|
| `SELECT current_user;` | Show current user |
| `\du` | List all users/roles |
| `\l+` | Show all databases & privileges |
| `\dp users` | Check table permissions |
| `\dt` | List tables in the current schema |
| `\dt+` | List tables in the current schema and additional info |
| `\dit` | List tables and indexes in the current schema |
| `\dp` | Show table permissions |
| `\dn+` | List schemas & permissions & description |
| `q` | Brings you back to the prompt after e.g. running a SELECT |
| `exit` | exits the psql |
| `SELECT * FROM information_schema.role_table_grants;` | Detailed table permissions |
| `SELECT * FROM pg_roles WHERE rolname = current_user;` | See role permissions |
| `SELECT datname, datacl FROM pg_database WHERE datname = 'mydatabase';` | Show database privileges |
| `SELECT tablename, tableowner FROM pg_catalog.pg_tables WHERE schemaname = 'public';` | List all tables and owners |

## Permission Management (GRANT/REVOKE)

| Command | Description |
|---------|-------------|
| `app=# ALTER TABLE users OWNER TO app;` | Grant owner permissions to 'users' table in the app database, to the 'app' user |
| `postgres=# ALTER DATABASE app OWNER TO app;` | Grant owner permissions to the app database, to the 'app' user |
| `GRANT SELECT ON table_name TO role_name;` | Grant read permission on a table |
| `REVOKE SELECT ON table_name FROM role_name;` | Revoke read permission on a table |
| `GRANT INSERT, UPDATE, DELETE ON table_name TO role_name;` | Grant write permissions on a table |
| `REVOKE INSERT, UPDATE, DELETE ON table_name FROM role_name;` | Revoke write permissions on a table |
| `GRANT ALL PRIVILEGES ON table_name TO role_name;` | Grant all permissions on a table |
| `REVOKE ALL PRIVILEGES ON table_name FROM role_name;` | Revoke all permissions on a table |
| `GRANT SELECT (column1, column2) ON table_name TO role_name;` | Grant read permission on specific columns |
| `GRANT USAGE ON SCHEMA schema_name TO role_name;` | Grant usage permission on a schema |
| `GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA schema_name TO role_name;` | Grant all permissions on all tables in a schema |
| `GRANT ALL PRIVILEGES ON DATABASE database_name TO role_name;` | Grant all permissions on a database |
| `GRANT role_name TO another_role;` | Grant role permissions to another role |
| `CREATE ROLE read_only WITH LOGIN PASSWORD 'password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;` | Create a read-only role |
| `GRANT CONNECT ON DATABASE database_name TO read_only_role;` | Allow role to connect to database |
| `ALTER DEFAULT PRIVILEGES IN SCHEMA schema_name GRANT SELECT ON TABLES TO role_name;` | Grant SELECT on future tables |

## Data Manipulation (INSERT, UPDATE, DELETE)

| Command | Description |
|---------|-------------|
| `INSERT INTO table_name (column1, column2) VALUES ('value1', 'value2');` | Insert a new row into a table |
| `UPDATE table_name SET column1 = 'value1' WHERE condition;` | Update existing data in a table |
| `DELETE FROM table_name WHERE condition;` | Delete rows from a table |
| `SELECT * FROM table_name WHERE condition;` | Query data from a table |
| `TRUNCATE TABLE table_name;` | Remove all rows from a table |
| `BEGIN;` | Start a transaction |
| `COMMIT;` | Commit a transaction |
| `ROLLBACK;` | Rollback a transaction |
| `CREATE TABLE table_name (column1 datatype, column2 datatype);` | Create a new table |
| `ALTER TABLE table_name ADD COLUMN new_column datatype;` | Add a column to existing table |
| `DROP TABLE table_name;` | Delete a table |
| `WITH old_records AS (SELECT id FROM users WHERE last_login < '2020-01-01') DELETE FROM users WHERE id IN (SELECT id FROM old_records);` | Delete using a CTE |
| `INSERT INTO table_name (column1, column2) VALUES ('value1', 'value2') RETURNING id, column1;` | Insert and return values from the new row |
| `UPDATE employees SET salary = salary * 1.1 FROM departments WHERE employees.dept_id = departments.id AND departments.name = 'Sales';` | Update with a join |
| `INSERT INTO table_name VALUES (1, 'value') ON CONFLICT (id) DO UPDATE SET column = 'new_value';` | Upsert - insert or update if exists |
| `SELECT name, salary, AVG(salary) OVER (PARTITION BY department) FROM employees;` | Select with window function |
| `WITH RECURSIVE subordinates AS (SELECT id, name, manager_id FROM employees WHERE id = 2 UNION ALL SELECT e.id, e.name, e.manager_id FROM employees e JOIN subordinates s ON s.id = e.manager_id) SELECT * FROM subordinates;` | Recursive CTE to traverse hierarchical data |
| `DELETE FROM orders WHERE id IN (WITH old_orders AS (SELECT id FROM orders WHERE created_at < NOW() - INTERVAL '1 year' AND status = 'completed') SELECT id FROM old_orders);` | Delete with subquery CTE |
| `EXPLAIN ANALYZE SELECT * FROM users WHERE email LIKE '%example.com';` | Analyze query performance |
| `SELECT id, headline, news_date, link, sample_date FROM public.news_articles WHERE sample_date < NOW() - INTERVAL '1 day';` | Select records older than 1 day |

## Backup, Restore, and Migration

### Backup Commands

| Command | Description |
|---------|-------------|
| `pg_dump database_name > backup.sql` | Create a plain-text SQL backup of a database |
| `pg_dump -Fc database_name > backup.dump` | Create a custom-format backup (recommended for large databases) |
| `pg_dumpall > all_databases.sql` | Backup all databases in the PostgreSQL instance |
| `pg_basebackup -D /backup/dir -Fp -Xs -P` | Perform a physical backup of the entire PostgreSQL cluster |
| `pg_dumpall --globals-only > globals.sql` | Backup roles and global objects (e.g., roles, tablespaces) |
| `pg_dumpall --roles-only -h <server> -p 5432 -U <username> -f roles.sql` | Backup roles objects |

### Restore Commands

| Command | Description |
|---------|-------------|
| `psql database_name < backup.sql` | Restore a plain-text SQL backup |
| `pg_restore -d database_name backup.dump` | Restore a custom-format backup |
| `pg_restore -d database_name --clean --if-exists backup.dump` | Restore and clean existing objects before restoring |
| `psql -f all_databases.sql postgres` | Restore all databases from a `pg_dumpall` backup |
| `psql -f globals.sql postgres` | Restore roles and global objects |

### Migration Tools and Commands

| Tool/Command | Description |
|--------------|-------------|
| `pg_upgrade` | Upgrade PostgreSQL to a newer version in-place |
| `pg_restore` | Restore a database to a new server or instance |
| `psql -c "COPY table_name TO STDOUT WITH CSV HEADER" > data.csv` | Export table data to a CSV file |
| `psql -c "COPY table_name FROM STDIN WITH CSV HEADER" < data.csv` | Import table data from a CSV file |
| `pglogical` | Logical replication extension for PostgreSQL |
| `wal-g` | Tool for continuous archiving and point-in-time recovery |
| `pgbackrest` | Reliable backup and restore tool for PostgreSQL |
| `barman` | Backup and recovery manager for PostgreSQL |
| `repmgr` | Tool for managing replication and failover in PostgreSQL |
