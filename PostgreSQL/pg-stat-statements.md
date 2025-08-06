# Using `pg_stat_statements.save` and `pg_stat_statements.track` in PostgreSQL

## Overview

The `pg_stat_statements` extension in PostgreSQL allows you to track execution statistics for SQL queries. By default, these statistics are stored in memory and reset on server restarts. However, the `pg_stat_statements.save` option enables persisting these statistics across restarts by saving them to disk.

### Key Parameters

1. **`pg_stat_statements.track`**

   - Controls which statements are tracked by `pg_stat_statements`.
   - Possible values:
     - `all`: Track all statements (default).
     - `top`: Track only top-level statements (not nested ones).
     - `none`: Disable tracking.
   - Example: To track only top-level statements, set:

     ```code
     pg_stat_statements.track = 'top'
     ```

2. **`pg_stat_statements.save`**
   - If enabled (`on`), saves statistics to disk so they persist across server restarts.
   - If disabled (`off`), statistics are cleared on restart.

---

## Setting Up `pg_stat_statements`

### Step 1: Enable the Extension

1. Edit the `postgresql.conf` file to load the `pg_stat_statements` module by adding or modifying:

   ```code
   shared_preload_libraries = 'pg_stat_statements'
   ```

   > Note: Restart the PostgreSQL server for this change to take effect.

2. Create the extension in your database:

   ```sql
   CREATE EXTENSION pg_stat_statements;
   ```

### Step 2: Configure Parameters

- Set the following parameters in `postgresql.conf`:

  ```code
  pg_stat_statements.track = 'all'     # Track all statements
  pg_stat_statements.save = on         # Persist statistics across restarts
  ```

- Reload the configuration:

  ```bash
  SELECT pg_reload_conf();
  ```

### Step 3: Verify Setup

- Confirm the extension is enabled:

  ```sql
  SELECT * FROM pg_extension WHERE extname = 'pg_stat_statements';
  ```

- Query the `pg_stat_statements` view for statistics:

  ```sql
  SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;
  ```

---

## Workaround for Retention Control

Since `pg_stat_statements` lacks a built-in retention feature, you can archive statistics periodically. Below is an example workaround:

### Archiving Statistics

1. Create an archive table to store historical statistics:

   ```sql
   CREATE TABLE pg_stat_statements_archive AS TABLE pg_stat_statements WITH NO DATA;
   ```

2. Periodically insert data into the archive table:

   ```sql
   INSERT INTO pg_stat_statements_archive
   SELECT * FROM pg_stat_statements WHERE query NOT LIKE '%pg_stat_statements_archive%';
   ```

3. Schedule the archiving process using `pg_cron` or an external scheduler:

   ```sql
   SELECT cron.schedule(
       'archive_pg_stat_statements',
       '0 0 * * *',  -- Every day at midnight
       $$ INSERT INTO pg_stat_statements_archive
          SELECT * FROM pg_stat_statements WHERE query NOT LIKE '%pg_stat_statements_archive%'; $$
   );
   ```

### Reset Statistics

- To clear statistics periodically (e.g., after archiving), use:

  ```sql
  SELECT pg_stat_statements_reset();
  ```

---

## Best Practices

- Monitor the size of the `pg_stat_statements` view to prevent excessive memory usage. Adjust the `pg_stat_statements.max` parameter as needed (default is 5000).
- Use tools like `pgBadger` or `Prometheus` to complement `pg_stat_statements` for long-term analysis and visualization.

---

## Troubleshooting

- If `pg_stat_statements` is not working, verify that `shared_preload_libraries` includes `pg_stat_statements` and that the server was restarted after changes.
- Ensure sufficient privileges to create extensions and execute maintenance commands.

---

For further details, consult the [PostgreSQL Documentation on pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html).
