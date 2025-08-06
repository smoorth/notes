# InfluxDB Handy Commands

## Table of Contents

- [InfluxDB Handy Commands](#influxdb-handy-commands)
  - [Table of Contents](#table-of-contents)
  - [InfluxDB Basics](#influxdb-basics)
    - [What is InfluxDB?](#what-is-influxdb)
    - [Key Concepts Simplified](#key-concepts-simplified)
    - [How InfluxDB Works](#how-influxdb-works)
    - [Tips for Beginners](#tips-for-beginners)
    - [Common Issues to Watch For](#common-issues-to-watch-for)
  - [Basic InfluxDB Commands](#basic-influxdb-commands)
  - [Data Insertion and Queries](#data-insertion-and-queries)
  - [Database and Retention Policy Management](#database-and-retention-policy-management)
  - [Backup and Restore](#backup-and-restore)

## InfluxDB Basics

### What is InfluxDB?

- InfluxDB is an **open-source time series database** designed to handle high write and query loads.
- It's optimized for **storing and analyzing time-stamped data** like metrics, events, and analytics.
- InfluxDB uses a **SQL-like query language called InfluxQL** and a newer language called **Flux**.
- It is part of the **TICK stack** (Telegraf, InfluxDB, Chronograf, Kapacitor) for complete monitoring solutions.

### Key Concepts Simplified

- **Database**: In InfluxDB 1.x, a container for time series data, users, retention policies, and continuous queries. In InfluxDB 2.x, replaced by "bucket".
- **Bucket**: In InfluxDB 2.x, a named location where time series data is stored with a retention period.
- **Measurement**: Similar to a table in relational databases, a container for tags, fields, and timestamps.
- **Tag**: Key-value pairs storing metadata. Tags are indexed, making them efficient for queries.
- **Field**: Key-value pairs storing the actual data. Fields are not indexed.
- **Point**: A single data record with a measurement, tag set, field set, and timestamp.
- **Series**: A collection of data sharing a measurement, tag set, and retention policy.
- **Retention Policy**: Rules for how long InfluxDB keeps data and how many copies to store.

### How InfluxDB Works

- Data is organized into **points with timestamps**, making time-based queries very efficient.
- **Tags are indexed** for fast filtering, while **fields are not indexed** but store the actual values.
- InfluxDB uses a **Time-Structured Merge Tree** (TSM) storage engine optimized for time series data.
- **Continuous queries** automatically compute aggregates in the background.
- **Retention policies** automatically expire and delete old data.

### Tips for Beginners

- Use the `influx` CLI tool for interactive access to InfluxDB.
- Choose tags carefully—they are indexed and good for filtering, but too many unique tags can cause high memory usage.
- Use fields for data you need to store but don't often filter by.
- Leverage retention policies to automatically manage data lifecycle.
- Structure measurement names logically (e.g., `system_cpu`, `system_memory`).

### Common Issues to Watch For

- **High cardinality**: Too many unique tag combinations can degrade performance.
- **Write throughput**: Monitor write performance, especially on resource-constrained systems.
- **Query complexity**: Complex queries across large time ranges can be resource-intensive.
- **Disk space**: Time series data can grow rapidly; set appropriate retention policies.
- **Memory usage**: InfluxDB loads metadata into memory; large tag sets require more RAM.

## Basic InfluxDB Commands

| Command | Description |
|---------|-------------|
| `influx` | Start the InfluxDB CLI |
| `influx -version` | Check InfluxDB version |
| `influx -precision rfc3339` | Start CLI with readable timestamps |
| `SHOW DATABASES` | List all databases |
| `USE database_name` | Select a database to use |
| `SHOW MEASUREMENTS` | List measurements in current database |
| `SHOW SERIES` | Show all series in current database |
| `SHOW TAG KEYS FROM measurement_name` | Show tag keys for a measurement |
| `SHOW FIELD KEYS FROM measurement_name` | Show field keys for a measurement |
| `SHOW RETENTION POLICIES` | Show retention policies for current database |
| `SHOW USERS` | List all users |
| `SHOW QUERIES` | Show currently running queries |
| `KILL QUERY query_id` | Terminate a running query |
| `exit` | Exit the InfluxDB CLI |

## Data Insertion and Queries

| Command | Description |
|---------|-------------|
| `INSERT measurement,tag_key=tag_value field_key=field_value` | Insert a single point |
| `INSERT cpu,host=server01 usage_idle=92.5,usage_user=7.5 1607694499000000000` | Insert with explicit timestamp |
| `SELECT * FROM measurement LIMIT 10` | Query 10 most recent points |
| `SELECT * FROM measurement WHERE time > now() - 1h` | Query data from the last hour |
| `SELECT mean(field_key) FROM measurement GROUP BY time(1m)` | Calculate 1-minute averages |
| `SELECT mean(field_key) FROM measurement GROUP BY tag_key` | Average values by tag |
| `SELECT field1, field2 FROM measurement WHERE tag_key = 'tag_value'` | Query with tag filter |
| `SELECT * FROM /^cpu/` | Query all measurements starting with "cpu" |
| `SELECT count(field_key) FROM measurement` | Count number of points |
| `SELECT distinct(field_key) FROM measurement` | Get distinct field values |
| `SELECT field_key FROM measurement GROUP BY *` | Group by all tags |
| `SELECT field_key FROM measurement WHERE time > now() - 1d AND tag_key = 'tag_value'` | Combine time and tag filters |
| `SELECT sum("field_key") / count("field_key") FROM "measurement" GROUP BY time(5m)` | Calculate average with sum/count |

## Database and Retention Policy Management

| Command | Description |
|---------|-------------|
| `CREATE DATABASE database_name` | Create a new database |
| `DROP DATABASE database_name` | Delete a database |
| `CREATE RETENTION POLICY "rp_name" ON "db_name" DURATION 30d REPLICATION 1` | Create retention policy (30 days) |
| `ALTER RETENTION POLICY "rp_name" ON "db_name" DURATION 90d` | Modify retention duration |
| `DROP RETENTION POLICY "rp_name" ON "db_name"` | Delete retention policy |
| `CREATE USER username WITH PASSWORD 'password'` | Create a new user |
| `GRANT READ ON database_name TO username` | Grant read permissions |
| `REVOKE ALL PRIVILEGES FROM username` | Revoke all user privileges |
| `CREATE CONTINUOUS QUERY "cq_name" ON "db_name" BEGIN SELECT mean("field") INTO "target_measurement" FROM "source_measurement" GROUP BY time(1h) END` | Create continuous query |
| `SHOW CONTINUOUS QUERIES` | List continuous queries |
| `DROP CONTINUOUS QUERY "cq_name" ON "db_name"` | Delete continuous query |

## Backup and Restore

| Command | Description |
|---------|-------------|
| `influxd backup -portable /path/to/backup` | Back up all databases (portable format) |
| `influxd backup -portable -database mydb /path/to/backup` | Back up a specific database |
| `influxd restore -portable /path/to/backup` | Restore all databases |
| `influxd restore -portable -database mydb /path/to/backup` | Restore a specific database |
| `influxd backup -portable -start 2023-01-01T00:00:00Z -end 2023-01-02T00:00:00Z -database mydb /path/to/backup` | Back up data in a time range |
| `influxd restore -portable -database mydb -newdb mydb_restored /path/to/backup` | Restore to a new database |
