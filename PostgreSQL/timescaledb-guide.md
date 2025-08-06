# TimescaleDB: Comprehensive Guide for PostgreSQL Time-Series Data

- [TimescaleDB: Comprehensive Guide for PostgreSQL Time-Series Data](#timescaledb-comprehensive-guide-for-postgresql-time-series-data)
  - [1. Introduction to TimescaleDB](#1-introduction-to-timescaledb)
    - [1.1 What is TimescaleDB?](#11-what-is-timescaledb)
    - [1.2 Key Features and Benefits](#12-key-features-and-benefits)
    - [1.3 When to Use TimescaleDB vs. Standard PostgreSQL](#13-when-to-use-timescaledb-vs-standard-postgresql)
  - [2. Installation and Setup](#2-installation-and-setup)
    - [2.1 Installing the Extension](#21-installing-the-extension)
    - [2.2 Creating Your First Hypertable](#22-creating-your-first-hypertable)
    - [2.3 Basic Configuration](#23-basic-configuration)
  - [3. Core Concepts](#3-core-concepts)
    - [3.1 Hypertables vs. Regular Tables](#31-hypertables-vs-regular-tables)
    - [3.2 Chunks and Chunk Time Intervals](#32-chunks-and-chunk-time-intervals)
    - [3.3 Time and Space Partitioning](#33-time-and-space-partitioning)
  - [4. Data Management](#4-data-management)
    - [4.1 Efficient Data Insertion](#41-efficient-data-insertion)
    - [4.2 Time-Series Query Optimization](#42-time-series-query-optimization)
    - [4.3 Time Bucketing and Aggregation](#43-time-bucketing-and-aggregation)
    - [4.4 Continuous Aggregates](#44-continuous-aggregates)
  - [5. Performance Optimization](#5-performance-optimization)
    - [5.1 Native Compression](#51-native-compression)
    - [5.2 Data Retention Policies](#52-data-retention-policies)
    - [5.3 Indexing Strategies](#53-indexing-strategies)
    - [5.4 Query Optimization Techniques](#54-query-optimization-techniques)
  - [6. Administration and Maintenance](#6-administration-and-maintenance)
    - [6.1 Monitoring TimescaleDB](#61-monitoring-timescaledb)
    - [6.2 Backup and Restore](#62-backup-and-restore)
    - [6.3 High Availability Setup](#63-high-availability-setup)
    - [6.4 Scaling Considerations](#64-scaling-considerations)
  - [7. Advanced Features](#7-advanced-features)
    - [7.1 Hyperfunctions](#71-hyperfunctions)
    - [7.2 Distributed Hypertables](#72-distributed-hypertables)
    - [7.3 Multi-Node Deployments](#73-multi-node-deployments)
    - [7.4 Integration with other PostgreSQL Extensions](#74-integration-with-other-postgresql-extensions)
  - [8. Best Practices](#8-best-practices)
    - [8.1 Schema Design](#81-schema-design)
    - [8.2 Chunk Sizing](#82-chunk-sizing)
    - [8.3 Resource Management](#83-resource-management)
    - [8.4 Common Pitfalls to Avoid](#84-common-pitfalls-to-avoid)
  - [9. Example Use Cases](#9-example-use-cases)
    - [9.1 IoT Sensor Data](#91-iot-sensor-data)
    - [9.2 Application Monitoring and Metrics](#92-application-monitoring-and-metrics)
    - [9.3 Financial Time-Series Analysis](#93-financial-time-series-analysis)
  - [10. Troubleshooting Common Issues](#10-troubleshooting-common-issues)

## 1. Introduction to TimescaleDB

### 1.1 What is TimescaleDB?

TimescaleDB is an open-source time-series database built as an extension to PostgreSQL. It provides specialized features for time-series data while maintaining full SQL compatibility and leveraging PostgreSQL's reliability and ecosystem.

TimescaleDB transforms PostgreSQL into a robust time-series platform by adding:

- Automatic time-based partitioning
- Optimized time-series queries
- Advanced features like continuous aggregates and compression

### 1.2 Key Features and Benefits

- **Hypertables**: Abstraction that provides a single table interface to access many individual partitions (chunks)
- **SQL Support**: Full SQL interface with time-series specific functions
- **Scalability**: Horizontal scaling through multi-node architecture
- **Compression**: Up to 95% compression for time-series data
- **Continuous Aggregates**: Materialized views that automatically update as new data arrives
- **Data Retention**: Automated policies to manage the data lifecycle
- **JIT Compilation**: Just-in-time compilation for query performance
- **PostgreSQL Compatibility**: Works with existing PostgreSQL tools, drivers, and extensions

### 1.3 When to Use TimescaleDB vs. Standard PostgreSQL

Use TimescaleDB when:

- Handling large volumes of time-series data (metrics, events, sensor readings)
- Requiring both recent data access and historical analysis
- Needing time-based aggregations and downsampling
- Balancing write and read performance for time-oriented data
- Wanting PostgreSQL compatibility with time-series optimizations

Use standard PostgreSQL when:

- Working with primarily relational data without a strong time component
- Managing small to moderate data volumes
- Not requiring specialized time-series functions or optimizations
- Having simple, infrequent aggregation needs

## 2. Installation and Setup

### 2.1 Installing the Extension

**On Debian/Ubuntu:**

```bash
# Add TimescaleDB repository
sudo sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ $(lsb_release -c -s) main' > /etc/apt/sources.list.d/timescaledb.list"
wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
sudo apt update

# Install TimescaleDB
sudo apt install timescaledb-postgresql-16  # Replace 16 with your PostgreSQL version
```

**Configure PostgreSQL:**

```bash
# Run the TimescaleDB setup scr
sudo timescaledb-tune

# Restart PostgreSQL
sudo systemctl restart postgresql
```

**Create the extension in your database:**

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb;
```

### 2.2 Creating Your First Hypertable

Create a regular table with a timestamp column:

```sql
CREATE TABLE sensor_data (
    time        TIMESTAMPTZ       NOT NULL,
    sensor_id   TEXT              NOT NULL,
    temperature DOUBLE PRECISION  NULL,
    humidity    DOUBLE PRECISION  NULL
);
```

Convert to a hypertable:

```sql
SELECT create_hypertable('sensor_data', 'time');
```

Optional: Add indexes for better query performance:

```sql
CREATE INDEX ON sensor_data (sensor_id, time DESC);
```

### 2.3 Basic Configuration

**Chunk Time Interval:**

The default chunk interval is 7 days. You can customize this:

```sql
-- Set a different interval when creating the hypertable
SELECT create_hypertable('sensor_data', 'time', chunk_time_interval => INTERVAL '1 day');

-- Or modify an existing hypertable
SELECT set_chunk_time_interval('sensor_data', INTERVAL '24 hours');
```

**Space Partitioning:**

```sql
-- Create a hypertable with space partitioning
SELECT create_hypertable('sensor_data', 'time',
    partitioning_column => 'sensor_id',
    number_partitions => 4
);
```

## 3. Core Concepts

### 3.1 Hypertables vs. Regular Tables

**Hypertables** are the primary abstraction in TimescaleDB, representing a virtual table across many physical chunks:

- **Logical View**: Single table interface for queries and inserts
- **Physical Storage**: Multiple chunks based on time (and optionally space)
- **Transparency**: SQL operations work identically as on regular tables
- **Performance**: Optimized for time-based access patterns

**Comparison with Regular Tables:**

| Feature | Regular PostgreSQL Table | TimescaleDB Hypertable |
|---------|--------------------------|------------------------|
| Query Interface | Standard SQL | Standard SQL + time functions |
| Partitioning | Manual via table inheritance | Automatic time-based |
| Query Planning | Single table | Chunk exclusion optimization |
| Index Management | Manual per table | Automatic per chunk |
| Scale Limitations | Limited by single table size | Scales across many chunks |

### 3.2 Chunks and Chunk Time Intervals

**Chunks** are the physical tables that store hypertable data:

- Each chunk contains data for a specific time range
- TimescaleDB automatically creates new chunks as data arrives
- Chunk size is determined by the chunk time interval
- Smaller chunks improve insert performance and query efficiency for recent data
- Larger chunks can be more efficient for historical analysis

**Inspecting Chunks:**

```sql
-- View all chunks for a hypertable
SELECT show_chunks('sensor_data');

-- View chunk time ranges and sizes
SELECT chunk_name, range_start, range_end, pg_size_pretty(pg_total_relation_size(chunk_name::regclass))
FROM timescaledb_information.chunks
WHERE hypertable_name = 'sensor_data';
```

### 3.3 Time and Space Partitioning

**Time Partitioning:**

- Primary partitioning dimension in TimescaleDB
- Automatic based on the specified time column
- Enables efficient data retention and query performance
- Optimizes for time-series query patterns

**Space Partitioning:**

- Optional secondary partitioning
- Based on a categorical column (e.g., device_id, location)
- Useful for distributing data across physical storage
- Improves query performance when filtering on partition column

**Visualization of Partitioning:**

```code
Time Partitioning Only:
┌─────────────┐┌─────────────┐┌─────────────┐
│ Jan 1-7     ││ Jan 8-14    ││ Jan 15-21   │
└─────────────┘└─────────────┘└─────────────┘

Time + Space Partitioning:
┌─────────────┐┌─────────────┐┌─────────────┐
│ Jan 1-7     ││ Jan 8-14    ││ Jan 15-21   │
│ (Region A)  ││ (Region A)  ││ (Region A)  │
└─────────────┘└─────────────┘└─────────────┘
┌─────────────┐┌─────────────┐┌─────────────┐
│ Jan 1-7     ││ Jan 8-14    ││ Jan 15-21   │
│ (Region B)  ││ (Region B)  ││ (Region B)  │
└─────────────┘└─────────────┘└─────────────┘
```

## 4. Data Management

### 4.1 Efficient Data Insertion

**Batch Inserts:**

Batch inserts improve performance by reducing transaction overhead:

```sql
-- Instead of individual inserts, use multi-row syntax
INSERT INTO sensor_data (time, sensor_id, temperature, humidity) VALUES
    ('2023-01-01 00:01:00', 'sensor1', 22.5, 45.8),
    ('2023-01-01 00:01:00', 'sensor2', 21.2, 47.3),
    ('2023-01-01 00:01:00', 'sensor3', 23.1, 44.9),
    -- more rows...
;
```

**COPY Command for Bulk Loading:**

```sql
COPY sensor_data FROM '/path/to/data.csv' WITH CSV HEADER;
```

**TimescaleDB-Specific Insert Optimization:**

- TimescaleDB efficiently routes inserts to the correct chunks
- Uses in-memory "tuplestore" for improved insertion performance
- Maintains indexes efficiently per chunk

### 4.2 Time-Series Query Optimization

**Time-Constrained Queries:**

Always include time predicates to leverage chunk exclusion:

```sql
-- Good: TimescaleDB can exclude irrelevant chunks
SELECT time, temperature
FROM sensor_data
WHERE time >= '2023-01-01' AND time < '2023-01-02'
AND sensor_id = 'sensor1';

-- Less efficient: Must scan all chunks
SELECT time, temperature
FROM sensor_data
WHERE sensor_id = 'sensor1';
```

**Using Latest() Function:**

```sql
-- Get the latest reading for each sensor
SELECT * FROM latest('sensor_data', 'time', 'sensor_id');
```

### 4.3 Time Bucketing and Aggregation

The `time_bucket` function groups data into time intervals:

```sql
-- Hourly average temperatures
SELECT
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    AVG(temperature) AS avg_temp
FROM sensor_data
WHERE time >= '2023-01-01' AND time < '2023-01-08'
GROUP BY bucket, sensor_id
ORDER BY bucket, sensor_id;
```

**Advanced Time Bucketing:**

```sql
-- With offset (e.g., for 15-minute intervals starting at :05)
SELECT time_bucket('15 minutes', time, INTERVAL '5 minutes') AS bucket,
    AVG(temperature) AS avg_temp
FROM sensor_data
GROUP BY bucket
ORDER BY bucket;

-- With timezone conversion
SELECT time_bucket('1 day', time, 'UTC') AS day,
    AVG(temperature) AS avg_temp
FROM sensor_data
GROUP BY day
ORDER BY day;
```

### 4.4 Continuous Aggregates

Continuous aggregates are materialized views that automatically update as new data arrives:

```sql
-- Create a continuous aggregate for hourly average temperature
CREATE MATERIALIZED VIEW sensor_hourly_avg
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    AVG(temperature) AS avg_temp
FROM sensor_data
GROUP BY bucket, sensor_id;
```

**Configuring Refresh Policy:**

```sql
-- Auto-refresh data older than 1 hour, every 30 minutes
SELECT add_continuous_aggregate_policy('sensor_hourly_avg',
    start_offset => INTERVAL '1 month',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '30 minutes');
```

**Querying Continuous Aggregates:**

```sql
-- Much faster than computing aggregates on-the-fly
SELECT bucket, sensor_id, avg_temp
FROM sensor_hourly_avg
WHERE bucket >= '2023-01-01' AND bucket < '2023-01-02'
ORDER BY bucket, sensor_id;
```

## 5. Performance Optimization

### 5.1 Native Compression

TimescaleDB offers built-in compression to reduce storage requirements:

```sql
-- Enable compression for a hypertable
ALTER TABLE sensor_data SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'sensor_id',
    timescaledb.compress_orderby = 'time DESC'
);

-- Create a compression policy (compress data older than 7 days)
SELECT add_compression_policy('sensor_data', INTERVAL '7 days');
```

**Compression Benefits:**

- 90-95% reduction in storage for time-series data
- Improved query performance for historical data
- Reduced I/O and memory utilization

**Manual Compression Management:**

```sql
-- Manually compress specific chunks
SELECT compress_chunk(chunk)
FROM show_chunks('sensor_data', older_than => INTERVAL '7 days');

-- Decompress if needed
SELECT decompress_chunk(chunk)
FROM show_chunks('sensor_data', older_than => INTERVAL '30 days');
```

### 5.2 Data Retention Policies

Automatically remove old data to maintain performance:

```sql
-- Drop chunks older than 3 months
SELECT add_retention_policy('sensor_data', INTERVAL '3 months');

-- For continuous aggregates, retain longer periods
SELECT add_retention_policy('sensor_hourly_avg', INTERVAL '1 year');
```

**Combining Retention with Compression:**

Best practice is to compress older data and only drop very old data:

```sql
-- First compress data older than 1 week
SELECT add_compression_policy('sensor_data', INTERVAL '7 days');

-- Then drop data older than 1 year
SELECT add_retention_policy('sensor_data', INTERVAL '1 year');
```

### 5.3 Indexing Strategies

**Time-Based Indexes:**

```sql
-- Index for time-based queries (automatically created)
CREATE INDEX ON sensor_data (time DESC);
```

**Compound Indexes:**

```sql
-- For queries filtering on both time and sensor_id
CREATE INDEX ON sensor_data (sensor_id, time DESC);
```

**Partial Indexes:**

```sql
-- For queries on specific sensors and recent data
CREATE INDEX ON sensor_data (time DESC)
WHERE sensor_id IN ('sensor1', 'sensor2', 'sensor3');
```

**Index Recommendations:**

1. Always include the time column in indexes
2. Put commonly filtered dimensions first, followed by time
3. Use partial indexes for frequently queried subsets
4. Remember that each index increases write overhead

### 5.4 Query Optimization Techniques

**Leverage Chunk Exclusion:**

```sql
-- Use time constraints for better performance
EXPLAIN SELECT * FROM sensor_data
WHERE time >= '2023-01-01' AND time < '2023-01-02';
```

**Optimize Aggregation Queries:**

```sql
-- Use continuous aggregates for common aggregations
-- Use appropriate time_bucket intervals
-- Consider pre-filtering data
```

**Parallel Queries:**

```sql
-- Enable parallel query execution
SET max_parallel_workers_per_gather = 4;
```

## 6. Administration and Maintenance

### 6.1 Monitoring TimescaleDB

**Hypertable Size and Chunk Distribution:**

```sql
-- Total size of a hypertable including indexes
SELECT hypertable_name, pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass))
FROM timescaledb_information.hypertables;

-- Size per chunk
SELECT chunk_name, pg_size_pretty(pg_total_relation_size(chunk_name::regclass))
FROM timescaledb_information.chunks
ORDER BY chunk_name;
```

**Compression Ratio:**

```sql
-- Check compression status and savings
SELECT
    hypertable_name,
    pg_size_pretty(before_compression_total_bytes) AS before_compression,
    pg_size_pretty(after_compression_total_bytes) AS after_compression,
    round(100 * (before_compression_total_bytes - after_compression_total_bytes)
        / before_compression_total_bytes::numeric, 2) AS compression_ratio
FROM timescaledb_information.compression_stats;
```

**Performance Diagnostics:**

```sql
-- Check for slow queries
SELECT * FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

### 6.2 Backup and Restore

TimescaleDB is compatible with standard PostgreSQL backup tools:

**Using pg_dump:**

```bash
# Back up a specific database with TimescaleDB
pg_dump -h localhost -U postgres -d mydatabase -F c -f backup.dump

# Restore
pg_restore -h localhost -U postgres -d mydatabase backup.dump
```

**Continuous Archiving (WAL):**

Configure PostgreSQL's Write-Ahead Log (WAL) archiving for point-in-time recovery.

### 6.3 High Availability Setup

TimescaleDB supports standard PostgreSQL replication methods:

1. **Streaming Replication**:
   - Primary/standby configuration
   - Synchronous or asynchronous replication

2. **Logical Replication** (PostgreSQL 10+):
   - Selective table replication
   - Multi-master capabilities with conflict resolution

3. **TimescaleDB Multi-Node**:
   - Commercial feature for distributed hypertables
   - Access nodes and data nodes architecture

### 6.4 Scaling Considerations

**Vertical Scaling:**

- Increase RAM for larger query working sets
- Faster CPUs for better query performance
- SSD/NVMe storage for I/O performance

**Horizontal Scaling (Enterprise):**

- TimescaleDB Multi-Node for distributed hypertables
- Sharding across multiple data nodes
- Query federation across the cluster

**Database Tuning:**

```sql
-- Suggested PostgreSQL settings for TimescaleDB
ALTER SYSTEM SET shared_buffers = '4GB';
ALTER SYSTEM SET effective_cache_size = '12GB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';
ALTER SYSTEM SET max_parallel_workers = 8;
ALTER SYSTEM SET max_worker_processes = 16;
```

## 7. Advanced Features

### 7.1 Hyperfunctions

TimescaleDB provides specialized time-series functions:

**Time-Weighted Averages:**

```sql
-- Calculate time-weighted average
SELECT time_weight('2023-01-01', '2023-01-02', 1, 10, 'linear');
```

**Gap Filling:**

```sql
-- Fill in missing data points in time series
SELECT time, coalesce(temperature, 0)
FROM time_bucket_gapfill('1 hour', time, '2023-01-01', '2023-01-02')
LEFT JOIN sensor_data USING (time);
```

**Percentile Approximation:**

```sql
-- Fast approximate percentile calculation
SELECT time_bucket('1 day', time) AS day,
    approximate_percentile(0.95, percentile_agg(temperature))
FROM sensor_data
GROUP BY day
ORDER BY day;
```

### 7.2 Distributed Hypertables

Available in TimescaleDB Enterprise:

```sql
-- Create a distributed hypertable
SELECT create_distributed_hypertable(
    'sensor_data', 'time',
    'sensor_id',
    replication_factor => 2
);
```

**Key Benefits:**

- Horizontal scaling across multiple nodes
- Increased query parallelism
- Higher ingest rates
- Improved fault tolerance

### 7.3 Multi-Node Deployments

**Architecture Components:**

- **Access Node**: Entry point for queries and writes
- **Data Nodes**: Store chunks of distributed hypertables
- **Distributed Chunks**: Spread across data nodes

**Adding Data Nodes:**

```sql
-- Add a new data node
SELECT add_data_node('data_node_1', host => 'node1.example.com');

-- Attach a new table to distributed hypertable
SELECT attach_data_node('data_node_1', 'sensor_data');
```

### 7.4 Integration with other PostgreSQL Extensions

TimescaleDB works seamlessly with many PostgreSQL extensions:

**PostGIS Integration:**

```sql
-- Create extension
CREATE EXTENSION postgis;

-- Create geospatial time-series table
CREATE TABLE geo_readings (
    time TIMESTAMPTZ NOT NULL,
    location GEOGRAPHY(POINT),
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION
);

-- Convert to hypertable
SELECT create_hypertable('geo_readings', 'time');

-- Geospatial query
SELECT time, temperature
FROM geo_readings
WHERE time > now() - INTERVAL '1 day'
AND ST_DWithin(location, ST_MakePoint(-122.4, 37.8)::geography, 1000);
```

**PG_Cron for Scheduled Tasks:**

```sql
-- Create extension
CREATE EXTENSION pg_cron;

-- Schedule maintenance tasks
SELECT cron.schedule('0 0 * * *', 'SELECT drop_chunks(''sensor_data'', INTERVAL ''90 days'');');
```

## 8. Best Practices

### 8.1 Schema Design

**Time Column:**

- Use `TIMESTAMPTZ` for time columns to handle time zones properly
- Consider microsecond precision for high-frequency data

**Dimensional Model:**

- Include relevant dimensions directly in the hypertable for filtering
- Consider normalizing rarely used dimensions to separate tables

**Example Schema for IoT Use Case:**

```sql
-- Normalized schema for IoT sensors
CREATE TABLE sensors (
    sensor_id TEXT PRIMARY KEY,
    location TEXT,
    model TEXT,
    installation_date DATE
);

CREATE TABLE sensor_data (
    time TIMESTAMPTZ NOT NULL,
    sensor_id TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    battery_level DOUBLE PRECISION,
    FOREIGN KEY (sensor_id) REFERENCES sensors (sensor_id)
);

SELECT create_hypertable('sensor_data', 'time');
```

### 8.2 Chunk Sizing

**Optimal Chunk Size:**

- Target 25-50 chunks per queries' average time range
- Aim for approximately 250MB to 1GB chunks (uncompressed)
- Consider write/insert patterns and query patterns

**Rules of Thumb:**

- High ingest rate → smaller chunks
- Large scans of historical data → larger chunks
- When in doubt, start with 1-day chunks and adjust

**Setting Chunk Interval:**

```sql
-- For 1 million rows per day at ~100 bytes per row
SELECT set_chunk_time_interval('sensor_data', INTERVAL '1 day');

-- For lower volume data
SELECT set_chunk_time_interval('monthly_reports', INTERVAL '1 month');
```

### 8.3 Resource Management

**Memory Configuration:**

- `shared_buffers`: 25-40% of system RAM
- `work_mem`: Depends on typical query complexity
- `maintenance_work_mem`: Higher for compression operations

**Disk Management:**

- Use fast storage (SSD/NVMe) for recent chunks
- Consider tiered storage (Enterprise) for historical data
- Monitor disk usage and set appropriate retention policies

**Background Workers:**

```sql
-- Adjust number of background workers
ALTER SYSTEM SET max_worker_processes = 16;
ALTER SYSTEM SET max_parallel_workers = 12;
ALTER SYSTEM SET max_parallel_workers_per_gather = 6;
```

### 8.4 Common Pitfalls to Avoid

1. **Missing Time Predicates**:
   - Always include time constraints in queries

2. **Over-Indexing**:
   - Each index adds write overhead
   - Focus on indexes that support common query patterns

3. **Inappropriate Chunk Sizes**:
   - Too small: excessive metadata overhead
   - Too large: reduced chunk exclusion benefits

4. **Neglecting Compression**:
   - Enable compression for significant storage savings
   - Set appropriate compression policies

5. **Ignoring Maintenance**:
   - Set up retention policies
   - Monitor chunk distribution
   - Schedule VACUUM and ANALYZE operations

## 9. Example Use Cases

### 9.1 IoT Sensor Data

**Schema and Setup:**

```sql
CREATE TABLE iot_sensors (
    time TIMESTAMPTZ NOT NULL,
    device_id TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    pressure DOUBLE PRECISION,
    battery_level INTEGER
);

SELECT create_hypertable('iot_sensors', 'time',
    partitioning_column => 'device_id',
    number_partitions => 4);
```

**Useful Queries:**

```sql
-- Get latest readings per device
SELECT DISTINCT ON (device_id)
    time, device_id, temperature, battery_level
FROM iot_sensors
WHERE time > now() - INTERVAL '1 day'
ORDER BY device_id, time DESC;

-- Identify devices with low battery
SELECT device_id, min(time) as first_low_battery
FROM iot_sensors
WHERE battery_level < 20
AND time > now() - INTERVAL '1 week'
GROUP BY device_id;
```

**Continuous Aggregates:**

```sql
-- Hourly averages by device
CREATE MATERIALIZED VIEW device_hourly AS
SELECT
    time_bucket('1 hour', time) AS hour,
    device_id,
    AVG(temperature) AS avg_temperature,
    AVG(humidity) AS avg_humidity
FROM iot_sensors
GROUP BY hour, device_id;
```

### 9.2 Application Monitoring and Metrics

**Schema and Setup:**

```sql
CREATE TABLE app_metrics (
    time TIMESTAMPTZ NOT NULL,
    service TEXT NOT NULL,
    host TEXT NOT NULL,
    cpu_usage DOUBLE PRECISION,
    memory_usage DOUBLE PRECISION,
    request_count INTEGER,
    error_count INTEGER,
    latency_ms DOUBLE PRECISION
);

SELECT create_hypertable('app_metrics', 'time');
```

**Useful Queries:**

```sql
-- Service availability (error rate)
SELECT
    time_bucket('5 minutes', time) AS interval,
    service,
    SUM(error_count)::float / NULLIF(SUM(request_count), 0) * 100 AS error_rate
FROM app_metrics
WHERE time > now() - INTERVAL '24 hours'
GROUP BY interval, service
ORDER BY interval DESC, error_rate DESC;

-- p95 latency by service using percentile_cont
SELECT
    time_bucket('15 minutes', time) AS interval,
    service,
    percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95_latency
FROM app_metrics
WHERE time > now() - INTERVAL '3 hours'
GROUP BY interval, service
ORDER BY interval DESC, p95_latency DESC;
```

### 9.3 Financial Time-Series Analysis

**Schema and Setup:**

```sql
CREATE TABLE stock_prices (
    time TIMESTAMPTZ NOT NULL,
    symbol TEXT NOT NULL,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    volume INTEGER
);

SELECT create_hypertable('stock_prices', 'time',
    partitioning_column => 'symbol',
    number_partitions => 8);
```

**Useful Queries:**

```sql
-- Daily OHLC candlestick data
SELECT
    time_bucket('1 day', time) AS day,
    symbol,
    first(open, time) AS open,
    max(high) AS high,
    min(low) AS low,
    last(close, time) AS close,
    sum(volume) AS volume
FROM stock_prices
WHERE time > now() - INTERVAL '30 days'
AND symbol IN ('AAPL', 'MSFT', 'GOOG')
GROUP BY day, symbol
ORDER BY symbol, day;

-- Moving averages
SELECT
    time,
    symbol,
    close,
    AVG(close) OVER (
        PARTITION BY symbol
        ORDER BY time
        ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
    ) AS moving_avg_20
FROM stock_prices
WHERE time > now() - INTERVAL '90 days'
AND symbol = 'AAPL'
ORDER BY time;
```

## 10. Troubleshooting Common Issues

**Slow Inserts:**

- Check indexes (too many can slow inserts)
- Verify appropriate chunk sizes
- Use batch inserts where possible
- Consider increasing `maintenance_work_mem`

**Slow Queries:**

- Verify use of time predicates
- Check `EXPLAIN ANALYZE` output for sequential scans
- Review index usage and add appropriate indexes
- Consider continuous aggregates for common queries

**High Disk Usage:**

- Enable compression
- Set up appropriate retention policies
- Check for unused indexes
- Monitor index and table bloat

**Memory Pressure:**

- Adjust `shared_buffers` and `work_mem`
- Consider using continuous aggregates to pre-compute results
- Ensure queries have time constraints to leverage chunk exclusion

**Chunks Not Being Compressed:**

- Verify compression policy is correctly configured
- Check that chunks meet the age requirement
