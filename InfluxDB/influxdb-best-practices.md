# InfluxDB Deployment Best Practices

- [InfluxDB Deployment Best Practices](#influxdb-deployment-best-practices)
  - [1. Schema Design \& Data Organization](#1-schema-design--data-organization)
    - [1.1 Measurement and Tag Design](#11-measurement-and-tag-design)
    - [1.2 Field Design](#12-field-design)
    - [1.3 Handle Cardinality](#13-handle-cardinality)
    - [1.4 Timestamp Precision](#14-timestamp-precision)
    - [1.5 Retention Policies](#15-retention-policies)
  - [2. System Level \& Resource Management](#2-system-level--resource-management)
    - [2.1 Hardware Considerations](#21-hardware-considerations)
    - [2.2 Memory Management](#22-memory-management)
    - [2.3 CPU Optimization](#23-cpu-optimization)
    - [2.4 Disk I/O Tuning](#24-disk-io-tuning)
    - [2.5 Network Configuration](#25-network-configuration)
  - [3. Storage Level](#3-storage-level)
    - [3.1 Storage Type](#31-storage-type)
    - [3.2 WAL (Write Ahead Log) Configuration](#32-wal-write-ahead-log-configuration)
    - [3.3 TSM (Time Structured Merge Tree) Files](#33-tsm-time-structured-merge-tree-files)
    - [3.4 Storage and Index Planning](#34-storage-and-index-planning)
  - [4. Query Optimization](#4-query-optimization)
    - [4.1 Query Design](#41-query-design)
    - [4.2 Query Patterns to Avoid](#42-query-patterns-to-avoid)
    - [4.3 Using Subqueries and Math](#43-using-subqueries-and-math)
    - [4.4 Continuous Queries](#44-continuous-queries)
  - [5. Monitoring and Operations](#5-monitoring-and-operations)
    - [5.1 Monitoring InfluxDB](#51-monitoring-influxdb)
    - [5.2 High Availability (HA) Setup](#52-high-availability-ha-setup)
    - [5.3 Backup and Restore Strategies](#53-backup-and-restore-strategies)
    - [5.4 Upgrading InfluxDB](#54-upgrading-influxdb)
  - [Best Practices Summary](#best-practices-summary)

This document outlines best practices for InfluxDB deployments, covering schema design, system-level considerations, storage optimization, query tuning, and operational aspects.

---

## 1. Schema Design & Data Organization

### 1.1 Measurement and Tag Design

- **Normalize Measurement Names**: Use consistent naming patterns (e.g., `system_cpu`, `system_memory`).
- **Limit Tag Cardinality**: Keep unique tag combinations under control to prevent memory issues.
- **Choose Tags Strategically**: Use tags for frequently queried dimensions (host, region, service).
- **Tag Consistency**: Maintain consistent tag keys across related measurements.

```code
# Good tag design
measurement: cpu_usage
tags: host=server01, region=us-west, service=api
fields: value=72.5

# Poor tag design (too much cardinality)
measurement: cpu_usage
tags: host=server01, region=us-west, service=api, timestamp=2023-01-01T12:00:00, user_id=12345
fields: value=72.5
```

### 1.2 Field Design

- **Field Types**: Choose appropriate field types (float, integer, string, boolean).
- **Avoid String Fields** when possible (higher storage requirements).
- **Normalize Field Names** across similar measurements for consistent queries.
- **Group Related Fields** within the same measurement.

```code
# Good field design
measurement: system
tags: host=server01
fields: cpu_usage=72.5, memory_used=8.2, disk_free=512.3

# Less optimal design (separating related metrics)
measurement: cpu
tags: host=server01
fields: usage=72.5

measurement: memory
tags: host=server01
fields: used=8.2

measurement: disk
tags: host=server01
fields: free=512.3
```

### 1.3 Handle Cardinality

- **Monitor Series Cardinality**: Use `SHOW STATS` to check series count.
- **Avoid High-Cardinality Tags**: Don't use user IDs, timestamps, or unique identifiers as tags.
- **Combine Tags** when they're always used together.
- **Move High-Cardinality Values to Fields** if you don't need to filter on them.

### 1.4 Timestamp Precision

- **Use Appropriate Precision**: Match precision to your needs (s, ms, us, ns).
- **Consistent Timestamps**: Use consistent timestamp precision across similar data.
- **Consider Time Zones**: Be aware of time zone implications; UTC is recommended.

### 1.5 Retention Policies

- **Define Appropriate Retention**: Balance data value against storage costs.
- **Multiple Retention Policies**: Consider different retention periods for different data.
- **Downsampling**: Use continuous queries to downsample older data.

```sql
# Create retention policy with 30-day retention
CREATE RETENTION POLICY "one_month" ON "database_name" DURATION 30d REPLICATION 1 DEFAULT

# Create continuous query for downsampling to hourly data
CREATE CONTINUOUS QUERY "cq_hourly" ON "database_name"
BEGIN
  SELECT mean("value") AS "value"
  INTO "database_name"."long_term"."measurement_hourly"
  FROM "database_name"."one_month"."measurement"
  GROUP BY time(1h), *
END
```

## 2. System Level & Resource Management

### 2.1 Hardware Considerations

- **RAM**: 8GB minimum for small instances, 32GB+ for production.
- **CPU**: Multi-core processors (4+ cores recommended for production).
- **Disk**: SSDs strongly recommended; NVMe for high-throughput workloads.
- **File System**: ext4 or XFS recommended for Linux.

### 2.2 Memory Management

- **cache-max-memory-size**: Limit to 50-75% of total system memory.
- **Monitor Memory Usage**: Watch for OOM events in logs.
- **Series Cardinality**: High cardinality increases memory requirements.

```toml
[data]
  cache-max-memory-size = "16g"  # For a server with 32GB RAM
```

### 2.3 CPU Optimization

- **max-concurrent-compactions**: Set to number of available CPUs minus 1.
- **max-series-per-database**: Limit based on memory and CPU capacity.
- **Avoid CPU throttling** in virtualized or containerized environments.

```toml
[data]
  max-concurrent-compactions = 7  # For an 8-core server
```

### 2.4 Disk I/O Tuning

- **WAL Settings**: Configure WAL flush intervals based on durability needs.
- **compaction-threshold**: Tune based on write load and disk performance.
- **I/O Scheduling**: Use deadline or noop for SSDs.

```toml
[data]
  wal-fsync-delay = "100ms"  # Balance between performance and durability

[disk]
  max-concurrent-compactions = 3  # For systems with good I/O
```

### 2.5 Network Configuration

- **HTTP Settings**: Adjust timeouts for long-running queries.
- **Bind Address**: Configure for security in production environments.
- **TLS**: Enable for production deployments.

```toml
[http]
  bind-address = "127.0.0.1:8086"  # Restrict to localhost if using reverse proxy
  https-enabled = true
  https-certificate = "/etc/ssl/influxdb.crt"
  https-private-key = "/etc/ssl/influxdb.key"
```

## 3. Storage Level

### 3.1 Storage Type

- **SSD/NVMe**: Strongly recommended for all InfluxDB deployments.
- **RAID Considerations**: RAID 0 for performance, RAID 10 for balance of performance and redundancy.
- **Avoid Network Storage**: Local storage preferred for TSM and WAL files.

### 3.2 WAL (Write Ahead Log) Configuration

- **wal-dir**: Consider placing on separate disk from data for performance.
- **wal-fsync-delay**: Adjust based on durability requirements.
- **wal-max-size**: Tune based on write load and memory.

```toml
[data]
  wal-dir = "/mnt/fast_disk/influxdb/wal"
  wal-fsync-delay = "100ms"
  wal-max-size = "1073741824"  # 1GB
```

### 3.3 TSM (Time Structured Merge Tree) Files

- **cache-snapshot-memory-size**: Control when memory data is flushed to disk.
- **cache-snapshot-write-cold-duration**: Force flush inactive data to disk.
- **compact-full-write-cold-duration**: Control when full compaction occurs.

```toml
[data]
  cache-snapshot-memory-size = "256m"
  cache-snapshot-write-cold-duration = "10m"
  compact-full-write-cold-duration = "4h"
```

### 3.4 Storage and Index Planning

- **index-version**: Use TSI (Time Series Index) for high cardinality workloads.
- **max-index-log-file-size**: Tune based on write load and memory.
- **series-id-set-cache-size**: Adjust for high cardinality workloads.

```toml
[data]
  index-version = "tsi1"  # Use TSI for high cardinality
  max-index-log-file-size = "1m"
  series-id-set-cache-size = 100
```

## 4. Query Optimization

### 4.1 Query Design

- **Leverage Tags for Filtering**: Pre-filter data using tags instead of fields.
- **Time Ranges**: Always include time ranges in queries.
- **Group By Time**: Use appropriate time buckets for aggregation.
- **Limit Results**: Use `LIMIT` or time constraints to avoid excessive memory usage.

```sql
# Efficient query
SELECT mean("value") FROM "cpu"
WHERE "host" = 'server01' AND time > now() - 1h
GROUP BY time(1m)

# Inefficient query (no time range, using fields for filtering)
SELECT * FROM "cpu"
WHERE "usage_value" > 90
```

### 4.2 Query Patterns to Avoid

- **Avoid Unbounded Time Ranges**: Always include a time filter.
- **Limit DISTINCT and GROUP BY**: These can be resource-intensive.
- **Avoid Complex Regex**: Regular expressions can be slow.
- **Beware of JOIN Queries**: Especially across large measurements.

```sql
# Avoid (unbounded time range, regex)
SELECT * FROM /^cpu.*/
WHERE "region" =~ /us-.*/

# Better
SELECT * FROM "cpu"
WHERE "region" = 'us-west' AND time > now() - 1h
```

### 4.3 Using Subqueries and Math

- **Pre-aggregate in Subqueries**: Reduce data before complex operations.
- **Use Math Functions Efficiently**: Apply them after aggregation when possible.
- **Consider Preprocessing**: Use continuous queries for common calculations.

```sql
# Efficient subquery approach
SELECT mean("usage_rate") FROM
  (SELECT "value" * 100 AS "usage_rate" FROM "cpu"
   WHERE time > now() - 1h)
GROUP BY time(5m)
```

### 4.4 Continuous Queries

- **Automate Downsampling**: Set up continuous queries for common aggregations.
- **Balance Execution Frequency**: Align with data ingestion patterns.
- **Group Multiple Measurements**: Create efficient CQs covering related metrics.

```sql
# Efficient continuous query for downsampling
CREATE CONTINUOUS QUERY "downsample_cpu" ON "database_name"
RESAMPLE EVERY 10m FOR 12m
BEGIN
  SELECT mean("usage_user") AS "usage_user",
         mean("usage_system") AS "usage_system"
  INTO "long_term_storage"."cpu_hourly"
  FROM "cpu"
  GROUP BY time(1h), *
END
```

## 5. Monitoring and Operations

### 5.1 Monitoring InfluxDB

- **Internal Metrics**: Monitor InfluxDB metrics using `_internal` database.
- **Key Metrics to Watch**:
  - Memory usage and garbage collection
  - Queries per second and query performance
  - Write throughput and errors
  - TSM compaction activity
  - Series cardinality

```sql
# Query internal metrics
SELECT mean("queryDurationNs") FROM "_internal"."monitor"."runtime" WHERE time > now() - 1h GROUP BY time(5m)
```

### 5.2 High Availability (HA) Setup

- **Enterprise Clustering**: For mission-critical deployments (commercial).
- **Replication**: Set up multiple instances with data replication.
- **Load Balancing**: Distribute read queries across instances.

### 5.3 Backup and Restore Strategies

- **Regular Backups**: Schedule using `influxd backup`.
- **Test Restore Process**: Periodically verify restoration works.
- **Consider Data Volumes**: Full backups can be large; use incremental backups.

```bash
# Portable backup example
influxd backup -portable /path/to/backup

# Restore example
influxd restore -portable -database mydatabase /path/to/backup
```

### 5.4 Upgrading InfluxDB

- **Test in Non-Production**: Always test upgrades in staging first.
- **Backup Before Upgrade**: Create a full backup before upgrading.
- **Read Release Notes**: Pay attention to breaking changes.
- **Plan for Downtime**: Some upgrades require downtime.

## Best Practices Summary

| Area | Key Best Practices |
|------|-------------------|
| Schema Design | Use tags strategically, control cardinality, normalize naming conventions |
| System Resources | Right-size RAM and CPU, use SSDs, tune memory limits |
| Storage | Configure WAL and TSM settings, use TSI for high cardinality, monitor disk usage |
| Queries | Include time ranges, use tags for filtering, leverage continuous queries |
| Operations | Monitor internal metrics, regular backups, test restore procedures |
