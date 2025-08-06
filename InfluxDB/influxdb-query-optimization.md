# InfluxDB Query Optimization

## Introduction

InfluxDB's time series database architecture requires specific optimization strategies to achieve optimal query performance. This guide covers key techniques for writing efficient queries, indexing strategies, and system-level optimizations that will significantly improve query response times.

## Table of Contents

- [InfluxDB Query Optimization](#influxdb-query-optimization)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Query Structure Optimization](#query-structure-optimization)
    - [Basic Query Principles](#basic-query-principles)
  - [Schema Design for Query Performance](#schema-design-for-query-performance)
    - [Measurement Organization](#measurement-organization)
  - [Time Range Optimization](#time-range-optimization)
  - [Tag and Measurement Strategies](#tag-and-measurement-strategies)
  - [Understanding the Query Planner](#understanding-the-query-planner)
  - [Using EXPLAIN](#using-explain)
  - [Query Optimization Examples](#query-optimization-examples)
    - [Example 1: Optimizing an Aggregation Query](#example-1-optimizing-an-aggregation-query)
    - [Example 2: Replacing OR with Multiple Queries](#example-2-replacing-or-with-multiple-queries)
  - [System-Level Optimizations](#system-level-optimizations)
    - [Hardware Considerations](#hardware-considerations)
    - [Configuration Tuning](#configuration-tuning)
  - [Performance Monitoring](#performance-monitoring)
    - [Key Metrics to Monitor](#key-metrics-to-monitor)
    - [Performance Troubleshooting Tools](#performance-troubleshooting-tools)
  - [Advanced Optimization Techniques](#advanced-optimization-techniques)
    - [Downsampling and Data Retention](#downsampling-and-data-retention)
    - [Query Caching](#query-caching)
    - [Kapacitor for Pre-Processing](#kapacitor-for-pre-processing)
    - [For InfluxDB 2.x Users](#for-influxdb-2x-users)

## Query Structure Optimization

### Basic Query Principles

1. **Always Include Time Constraints**

   Every query should include a time range to limit the data scanned:

   ```sql
   -- Inefficient (no time filter)
   SELECT mean("value") FROM "cpu"

   -- Efficient (with time filter)
   SELECT mean("value") FROM "cpu" WHERE time > now() - 1h
   ```

2. **Filter by Tag Before Field**

   Tags are indexed, fields are not. Always filter by tags when possible:

   ```sql
   -- Inefficient (filtering by field first)
   SELECT "value" FROM "cpu" WHERE "usage_user" > 90 AND "host" = 'server01'

   -- Efficient (filtering by tag first)
   SELECT "value" FROM "cpu" WHERE "host" = 'server01' AND "usage_user" > 90
   ```

3. **Use Specific Field Selection**

   Select only the fields you need instead of using `*`:

   ```sql
   -- Inefficient (selecting all fields)
   SELECT * FROM "cpu"

   -- Efficient (selecting only needed fields)
   SELECT "usage_user", "usage_system" FROM "cpu"
   ```

4. **Limit Result Set Size**

   Add LIMIT clause to large result sets:

   ```sql
   -- Efficiently limit results
   SELECT "value" FROM "cpu" WHERE time > now() - 1h LIMIT 1000
   ```

## Schema Design for Query Performance

### Measurement Organization

1. **Properly Segment Measurements**

   Group related metrics in the same measurement, but avoid measurements that grow too large:

   ```code
   # Good organization
   measurement=cpu, fields=user, system, idle, tags=host, region
   measurement=disk, fields=used, free, inodes, tags=host, path

   # Poor organization (too many fields in one measurement)
   measurement=server_stats, fields=cpu_user, cpu_system, disk_used, disk_free...
   ```

2. **Use Tags for Common Query Dimensions**

   Place attributes you frequently filter or group by into tags:

   ```sql
   -- Efficient querying with proper tag usage
   SELECT mean("value") FROM "cpu" WHERE "datacenter" = 'us-west' GROUP BY "host"
   ```

## Time Range Optimization

1. **Narrow Time Ranges**

   Always use the narrowest possible time range:

   ```sql
   -- More efficient
   SELECT mean("value") FROM "cpu" WHERE time > now() - 1h

   -- Less efficient
   SELECT mean("value") FROM "cpu" WHERE time > now() - 30d
   ```

2. **Time Range Before Other Filters**

   Place time filters before other conditions:

   ```sql
   -- Efficient order
   SELECT "value" FROM "cpu" WHERE time > now() - 1h AND "host" = 'server01'
   ```

## Tag and Measurement Strategies

1. **Use Tag Cardinality Wisely**

   Avoid high cardinality tags (like unique IDs or timestamps):

   ```code
   # Bad - high cardinality tag
   tags: request_id=unique-uuid-per-request

   # Good - use field instead
   fields: request_id=unique-uuid-per-request
   ```

2. **Index Tags That Matter**

   Only use tags for values you query frequently:

   ```code
   # Better as a tag (commonly queried)
   tags: host=server01

   # Better as a field (rarely used in WHERE clauses)
   fields: application_version=1.2.3
   ```

## Understanding the Query Planner

InfluxDB uses a query planner to optimize query execution. Understanding its behavior helps in writing optimized queries:

1. **Filter Push Down**: InfluxDB pushes filtering operations down to the storage layer
2. **Shard Pruning**: Time range filtering eliminates entire shards
3. **Series Filtering**: Tag filtering eliminates entire series

## Using EXPLAIN

Use EXPLAIN to analyze query execution plans:

```sql
EXPLAIN SELECT mean("usage_user") FROM "cpu" WHERE "host" = 'server01' AND time > now() - 1h
```

EXPLAIN output shows:

- Which shards will be queried
- What series will be scanned
- Index usage details
- Estimated memory usage

Analyze this output to identify performance bottlenecks.

## Query Optimization Examples

### Example 1: Optimizing an Aggregation Query

**Original Query:**

```sql
SELECT mean("usage_user") FROM "cpu"
```

**Optimized Query:**

```sql
SELECT mean("usage_user") FROM "cpu" WHERE time > now() - 4h GROUP BY time(10m), "host"
```

**Benefits:**

- Time constraint limits data scanned
- GROUP BY time provides appropriate granularity
- GROUP BY host prevents data skew from combining unrelated servers

### Example 2: Replacing OR with Multiple Queries

**Original Query (Inefficient):**

```sql
SELECT "value" FROM "cpu" WHERE "host" = 'server01' OR "host" = 'server02' OR "host" = 'server03'
```

**Optimized Approach:**

```sql
SELECT "value" FROM "cpu" WHERE "host" =~ /^server0[1-3]$/
```

**Benefits:**

- Regular expression is more efficient than multiple OR conditions
- Reduced query complexity for better execution planning

## System-Level Optimizations

### Hardware Considerations

1. **Memory Allocation**
   - InfluxDB benefits from large amounts of RAM
   - Recommendation: Allocate at least 2-4GB per million series

2. **Storage Type**
   - Use SSDs instead of HDDs
   - NVMe drives provide best performance for high-write environments

3. **CPU Resources**
   - Multiple cores help with concurrent queries
   - Write operations are less CPU-intensive than complex queries

### Configuration Tuning

1. **Cache Settings**

   ```code
   [data]
     cache-max-memory-size = "1g"
     cache-snapshot-memory-size = "256m"
   ```

2. **WAL (Write Ahead Log) Settings**

   ```code
   [data]
     wal-fsync-delay = "100ms"
   ```

3. **Query Management**

   ```code
   [coordinator]
     max-concurrent-queries = 20
     query-timeout = "30s"
   ```

## Performance Monitoring

### Key Metrics to Monitor

1. **System Metrics**
   - Memory usage
   - CPU utilization
   - Disk I/O
   - Network throughput

2. **InfluxDB Internal Metrics**
   - Query performance statistics
   - Write throughput
   - Cardinality growth
   - Compaction activity

3. **Using _internal Database**

   InfluxDB stores self-monitoring metrics in the `_internal` database:

   ```sql
   SELECT mean("queryRespDurationNs") FROM "query_resp_times" WHERE time > now() - 1h GROUP BY time(10m)
   ```

### Performance Troubleshooting Tools

1. **Use built-in `/debug/vars` endpoint**
   - Access at <http://localhost:8086/debug/vars>
   - Provides detailed runtime statistics

2. **SHOW STATS command**

   ```sql
   SHOW STATS
   SHOW STATS FOR 'query'
   ```

## Advanced Optimization Techniques

### Downsampling and Data Retention

Implement continuous queries for downsampling data:

```sql
-- Create continuous query for downsampling
CREATE CONTINUOUS QUERY "cq_30m" ON "telegraf"
BEGIN
  SELECT mean("usage_user") AS "mean_usage_user"
  INTO "telegraf"."autogen"."cpu_30m"
  FROM "telegraf"."autogen"."cpu"
  GROUP BY time(30m), *
END
```

Set appropriate retention policies:

```sql
-- Create retention policy
CREATE RETENTION POLICY "two_weeks" ON "telegraf" DURATION 14d REPLICATION 1

-- Alter default retention
ALTER RETENTION POLICY "autogen" ON "telegraf" DURATION 1d
```

### Query Caching

Implement application-level caching for frequent queries:

1. Cache query results for static dashboards
2. Implement time-based cache invalidation
3. Consider using Redis or Memcached for distributed caching

### Kapacitor for Pre-Processing

Offload calculations to Kapacitor for complex analytics:

1. Use Kapacitor for continuous transformations
2. Implement stream processing for high-cardinality data
3. Pre-aggregate metrics before storage in InfluxDB

### For InfluxDB 2.x Users

1. Take advantage of Flux language capabilities:

   ```flux
   from(bucket: "telegraf")
     |> range(start: -1h)
     |> filter(fn: (r) => r._measurement == "cpu")
     |> filter(fn: (r) => r.host == "server01")
     |> aggregateWindow(every: 5m, fn: mean)
   ```

2. Use tasks for background processing:

   ```flux
   option task = {
     name: "Downsample CPU",
     every: 1h
   }

   data = from(bucket: "telegraf")
     |> range(start: -1h)
     |> filter(fn: (r) => r._measurement == "cpu")
     |> aggregateWindow(every: 5m, fn: mean)
     |> to(bucket: "telegraf_downsampled")
   ```
