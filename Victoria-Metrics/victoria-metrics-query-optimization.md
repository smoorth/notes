# Victoria Metrics Query Optimization

## Introduction

Victoria Metrics is a fast, cost-effective, and scalable time series database and monitoring solution. This guide covers key techniques for optimizing queries in Victoria Metrics to achieve better performance, reduced resource consumption, and faster response times.

## Table of Contents

- [Victoria Metrics Query Optimization](#victoria-metrics-query-optimization)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Query Structure Optimization](#query-structure-optimization)
    - [Basic Query Principles](#basic-query-principles)
  - [Schema Design for Query Performance](#schema-design-for-query-performance)
    - [Metric and Label Organization](#metric-and-label-organization)
  - [Time Range Optimization](#time-range-optimization)
  - [Label and Metric Strategies](#label-and-metric-strategies)
  - [Using MetricsQL Efficiently](#using-metricsql-efficiently)
  - [Query Optimization Examples](#query-optimization-examples)
    - [Example 1: Optimizing an Aggregation Query](#example-1-optimizing-an-aggregation-query)
    - [Example 2: Replacing OR with Regular Expressions](#example-2-replacing-or-with-regular-expressions)
  - [System-Level Optimizations](#system-level-optimizations)
    - [Hardware Considerations](#hardware-considerations)
    - [Configuration Tuning](#configuration-tuning)
  - [Performance Monitoring](#performance-monitoring)
    - [Key Metrics to Monitor](#key-metrics-to-monitor)
    - [Performance Troubleshooting](#performance-troubleshooting)
  - [Advanced Optimization Techniques](#advanced-optimization-techniques)
    - [Downsampling and Data Retention](#downsampling-and-data-retention)
    - [Query Caching](#query-caching)
    - [Using vmagent for Pre-Processing](#using-vmagent-for-pre-processing)

## Query Structure Optimization

### Basic Query Principles

1. **Always Include Time Constraints**

   Every query should include a time range to limit the data scanned:

   ```promql
   # Inefficient (no time filter)
   sum(cpu_usage_total)

   # Efficient (with time filter)
   sum(cpu_usage_total{__timeFilter__="1h"})
   # or using Grafana's time range automatically
   ```

2. **Filter by Label Before Aggregation**

   Apply label filters before aggregation operations for better performance:

   ```promql
   # Inefficient (aggregating before filtering)
   sum(cpu_usage_total) > 90

   # Efficient (filtering before aggregation)
   sum(cpu_usage_total{instance="server01"})
   ```

3. **Use Specific Metric Selection**

   Select only the metrics you need instead of wildcard matching when possible:

   ```promql
   # Inefficient (selecting all metrics matching pattern)
   {__name__=~"cpu.*"}

   # Efficient (selecting only needed metrics)
   cpu_usage_idle or cpu_usage_system
   ```

4. **Limit Result Set Size**

   Use `topk` or `bottomk` to limit large result sets:

   ```promql
   # Efficiently limit results to top 10 CPU consumers
   topk(10, cpu_usage_system)
   ```

## Schema Design for Query Performance

### Metric and Label Organization

1. **Properly Structure Metrics**

   Group related metrics with consistent naming patterns:

   ```code
   # Good organization
   cpu_usage_user
   cpu_usage_system
   cpu_usage_idle

   # Poor organization
   server_cpu_user_percent
   system_cpu_usage
   idle_cpu
   ```

2. **Use Labels for Common Query Dimensions**

   Place attributes you frequently filter or group by into labels:

   ```promql
   # Efficient querying with proper label usage
   sum(node_cpu_seconds_total{mode="idle"}) by (instance)
   ```

## Time Range Optimization

1. **Narrow Time Ranges**

   Always use the narrowest possible time range:

   ```promql
   # More efficient - last hour
   rate(http_requests_total[1h])

   # Less efficient - last 30 days
   rate(http_requests_total[30d])
   ```

2. **Appropriate Rate/Increase Intervals**

   Match rate intervals to your scrape interval and query needs:

   ```promql
   # For 15s scrape interval, 5m might be appropriate
   rate(http_requests_total[5m])

   # For 15s scrape interval, this is usually wasteful
   rate(http_requests_total[1h])
   ```

## Label and Metric Strategies

1. **Use Label Cardinality Wisely**

   Avoid high cardinality labels (like unique IDs or timestamps):

   ```code
   # Bad - high cardinality label
   http_requests_total{request_id="unique-uuid-per-request"}

   # Good - avoid high cardinality labels
   http_requests_total{endpoint="/api/v1/users", method="GET"}
   ```

2. **Index Labels That Matter**

   Only use labels for values you query frequently:

   ```promql
   # Better as a label (commonly queried)
   http_requests_total{status="500"}

   # Consider as a separate metric (rarely filtered)
   http_requests_version{version="1.2.3"}
   ```

## Using MetricsQL Efficiently

Victoria Metrics extends PromQL with its own dialect called MetricsQL, which has additional functions and capabilities:

1. **Use Victoria Metrics-Specific Functions**

   ```promql
   # VM-specific: Moving average over the last 60 points
   moving_average(cpu_usage_idle, 60)

   # VM-specific: Histogram quantiles with automatic bucket detection
   histogram_quantile(0.9, sum(rate(response_time_bucket[5m])) by (le))
   ```

2. **Subquery Optimization**

   Use subqueries efficiently to pre-aggregate data:

   ```promql
   # Extract the max rate over the past day at 1h resolution
   max_over_time(rate(http_requests_total[5m])[1d:1h])
   ```

## Query Optimization Examples

### Example 1: Optimizing an Aggregation Query

**Original Query:**

```promql
avg(node_cpu_seconds_total)
```

**Optimized Query:**

```promql
avg(node_cpu_seconds_total{mode="idle"}) by (instance)
```

**Benefits:**

- Filtered to specific CPU mode before aggregation
- Groups by instance for more meaningful results
- Implicitly uses time range from Grafana or UI

### Example 2: Replacing OR with Regular Expressions

**Original Query (Inefficient):**

```promql
sum(node_cpu_seconds_total{instance="server01"}) or
sum(node_cpu_seconds_total{instance="server02"}) or
sum(node_cpu_seconds_total{instance="server03"})
```

**Optimized Approach:**

```promql
sum(node_cpu_seconds_total{instance=~"server0[1-3]"})
```

**Benefits:**

- Regular expression is more efficient than multiple OR conditions
- Reduced query complexity for better execution planning

## System-Level Optimizations

### Hardware Considerations

1. **Memory Allocation**
   - Victoria Metrics is optimized for lower RAM usage compared to other TSDB solutions
   - Recommendation: At least 1-2GB RAM for smaller instances, 8GB+ for production

2. **Storage Type**
   - Use SSDs for better performance with high query loads
   - Victoria Metrics is optimized for commodity storage (unlike some other TSDBs)

3. **CPU Resources**
   - Multiple cores help with concurrent queries and ingestion
   - VM effectively utilizes multiple CPU cores for parallel processing

### Configuration Tuning

1. **Cache Settings**

   ```code
   -search.cacheTimestampOffset=5m
   -search.maxUniqueTimeseries=1000000
   ```

2. **Query Limits for Protection**

   ```code
   -search.maxQueryDuration=30s
   -search.maxQueryLen=16384
   -search.maxConcurrentRequests=8
   ```

## Performance Monitoring

### Key Metrics to Monitor

1. **System Metrics**
   - Memory usage
   - CPU utilization
   - Disk I/O
   - Network throughput

2. **Victoria Metrics Internal Metrics**
   - Ingestion rate
   - Query latencies
   - Storage growth
   - Cache hit/miss ratio

3. **Using /metrics Endpoint**

   Victoria Metrics exposes its own metrics at `/metrics` endpoint:

   ```promql
   # Monitor query latencies
   histogram_quantile(0.9, sum(rate(vm_request_duration_seconds_bucket{path="/api/v1/query_range"}[5m])) by (le))
   ```

### Performance Troubleshooting

1. **Use built-in `/metrics` endpoint**
   - Access at <http://localhost:8428/metrics>
   - Provides detailed runtime statistics

2. **Examine slow queries**

   Enable slow query logging:

   ```code
   -search.logSlowQueryDuration=5s
   ```

## Advanced Optimization Techniques

### Downsampling and Data Retention

Victoria Metrics handles data retention natively:

```code
# Set retention period to 3 months
-retentionPeriod=3M
```

For downsampling, you can use recording rules:

```yaml
groups:
  - name: downsampling
    interval: 5m
    rules:
      - record: cpu_usage_user:5m
        expr: avg_over_time(cpu_usage_user[5m])
```

### Query Caching

Victoria Metrics caches query results by default. Tune cache parameters:

```code
# Increase cache size
-search.cacheSize=1024MB
```

### Using vmagent for Pre-Processing

Offload preprocessing to vmagent:

1. Configure relabeling to optimize data before storage
2. Use filtering to reduce unnecessary metrics
3. Implement multiple remote write endpoints for redundancy

Example vmagent configuration:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
