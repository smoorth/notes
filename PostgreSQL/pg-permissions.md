# PostgreSQL Permission Management

## Granting Privileges for a Single Table

- Replace your_schema with the schema name (e.g., public for default).
- Replace your_table with the table name.
- Replace your_user with the target user or role.

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON your_schema.your_table TO your_user;
```

## Granting Privileges on an Entire Database

- Replace your_database with your database name.
- Replace your_schema with the schema name.
- Replace your_user with the user.

```sql
GRANT CONNECT ON DATABASE your_database TO your_user;
GRANT USAGE ON SCHEMA your_schema TO your_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA your_schema TO your_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA your_schema GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO your_user;

```

## Granting Privileges to table in a loop

This will:

- Grant SELECT, INSERT, UPDATE, and DELETE on all existing tables.
- Ensure future tables also get these privileges.

### Full Script

```sql
DO $$
DECLARE
    table_record RECORD;
BEGIN
    -- Loop through all tables in the specified schema and grant privileges
    FOR table_record IN
        SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'your_schema'
    LOOP
        EXECUTE format(
            'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE %I.%I TO your_user;',
            table_record.schemaname, table_record.tablename
        );
    END LOOP;

    -- Ensure default privileges for future tables in the schema
    EXECUTE format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO your_user;',
        'your_schema'
    );
END $$;
```

## 🔹 Steps to Use

1. Replace `your_schema` with the actual schema name (e.g., `public` if using the default).
2. Replace `your_user` with the username or role you want to grant permissions to.
3. Execute the script in your PostgreSQL database.

## Alternative Without PL/pgSQL

If you prefer a simple one-liner (without a loop), you can generate SQL statements dynamically:

```sql
SELECT 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || schemaname || '.' || tablename || ' TO your_user;'
FROM pg_tables
WHERE schemaname = 'your_schema';
```

Then, copy and execute the output.

## Viewing Granted Privileges

### To verify the granted permissions

Check permissions on a specific table

```sql
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'your_table' AND grantee = 'your_user';
```

Check all granted privileges for a user

```sql
SELECT * FROM information_schema.role_table_grants WHERE grantee = 'your_user';
```

List all privileges in the database

```sql
SELECT * FROM information_schema.role_table_grants WHERE grantee = 'your_user';
```

## Working with Sequences

Sequences often need their own permissions, especially for tables with SERIAL or IDENTITY columns.

### Grant Usage on a Single Sequence

```sql
GRANT USAGE, SELECT ON SEQUENCE your_schema.your_sequence TO your_user;
```

### Grant Usage on All Sequences in a Schema

```sql
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA your_schema TO your_user;
```

### Set Default Privileges for Future Sequences

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA your_schema
GRANT USAGE, SELECT ON SEQUENCES TO your_user;
```

## Function and Procedure Permissions

### Grant Execute Permission on a Function

```sql
GRANT EXECUTE ON FUNCTION your_schema.your_function(parameter_types) TO your_user;
```

### Grant Execute on All Functions in a Schema

```sql
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA your_schema TO your_user;
```

### Set Default Privileges for Future Functions

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA your_schema
GRANT EXECUTE ON FUNCTIONS TO your_user;
```

## Role Management

### Create a New Role/User

```sql
-- Create a login role (can connect to database)
CREATE ROLE username WITH LOGIN PASSWORD 'secure_password';

-- Create a group role (cannot login)
CREATE ROLE group_name;
```

### Role Inheritance and Group Membership

```sql
-- Add a user to a group
GRANT group_name TO username;

-- Create a role with specific attributes
CREATE ROLE reporting_user WITH
  LOGIN
  PASSWORD 'secure_password'
  CONNECTION LIMIT 5
  VALID UNTIL '2024-12-31';
```

## Revoking Permissions

### Revoke Table Permissions

```sql
REVOKE SELECT, INSERT, UPDATE, DELETE ON your_schema.your_table FROM your_user;
```

### Revoke Schema Permissions

```sql
REVOKE USAGE ON SCHEMA your_schema FROM your_user;
```

### Revoke Default Privileges

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA your_schema
REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM your_user;
```

## Troubleshooting Common Permission Issues

### ERROR: permission denied for relation

This usually means the user lacks proper permissions on the table or the schema.

Solution:

```sql
-- Check if the user has schema usage permission
GRANT USAGE ON SCHEMA your_schema TO your_user;

-- Grant permissions on the specific table
GRANT SELECT, INSERT, UPDATE, DELETE ON your_schema.your_table TO your_user;
```

### ERROR: permission denied for sequence

When your user can't insert into a table with a SERIAL column:

```sql
-- Grant permissions on all sequences in the schema
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA your_schema TO your_user;
```

### Checking if a User Has Permissions

```sql
-- Check effective permissions
SELECT has_table_privilege('your_user', 'your_schema.your_table', 'SELECT');

-- Display all privileges
SELECT table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'your_user';
```

## Security Best Practices

1. **Principle of Least Privilege**: Grant only the permissions needed for each role.
2. **Use Roles**: Create group roles for common permission sets and grant them to users.
3. **Regular Audits**: Periodically review permissions with the information_schema views.
4. **Avoid Public Schema**: Avoid granting permissions on the 'public' schema to PUBLIC role.
5. **Revoke Public Permissions**: Consider `REVOKE ALL ON SCHEMA public FROM PUBLIC;` for sensitive databases.
