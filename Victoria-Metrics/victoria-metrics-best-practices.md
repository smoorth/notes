# Victoria Metrics Deployment Best Practices

- [Victoria Metrics Deployment Best Practices](#victoria-metrics-deployment-best-practices)
  - [1. Schema Design \& Data Organization](#1-schema-design--data-organization)
    - [1.1 Metric Naming and Label Design](#11-metric-naming-and-label-design)
    - [1.2 Label Management](#12-label-management)
    - [1.3 Handle Cardinality](#13-handle-cardinality)
    - [1.4 Time Series Design](#14-time-series-design)
    - [1.5 Retention Management](#15-retention-management)
  - [2. System Level \& Resource Management](#2-system-level--resource-management)
    - [2.1 Hardware Considerations](#21-hardware-considerations)
    - [2.2 Memory Management](#22-memory-management)
    - [2.3 CPU Optimization](#23-cpu-optimization)
    - [2.4 Disk I/O Tuning](#24-disk-io-tuning)
    - [2.5 Network Configuration](#25-network-configuration)
  - [3. Storage Level](#3-storage-level)
    - [3.1 Storage Type](#31-storage-type)
    - [3.2 Storage Path Planning](#32-storage-path-planning)
    - [3.3 Data Compression](#33-data-compression)
    - [3.4 Index Planning](#34-index-planning)
  - [4. Query Optimization](#4-query-optimization)
    - [4.1 Query Design](#41-query-design)
    - [4.2 Query Patterns to Avoid](#42-query-patterns-to-avoid)
    - [4.3 Using MetricsQL Efficiently](#43-using-metricsql-efficiently)
    - [4.4 Reducing Query Load](#44-reducing-query-load)
  - [5. High Availability \& Clustering](#5-high-availability--clustering)
    - [5.1 Cluster Architecture](#51-cluster-architecture)
    - [5.2 Replication Strategy](#52-replication-strategy)
    - [5.3 Load Balancing](#53-load-balancing)
    - [5.4 Deployment Considerations](#54-deployment-considerations)
  - [6. Monitoring and Operations](#6-monitoring-and-operations)
    - [6.1 Monitoring Victoria Metrics](#61-monitoring-victoria-metrics)
    - [6.2 Alerting on Victoria Metrics Health](#62-alerting-on-victoria-metrics-health)
    - [6.3 Backup and Restore Strategies](#63-backup-and-restore-strategies)
    - [6.4 Upgrading Victoria Metrics](#64-upgrading-victoria-metrics)
  - [Best Practices Summary](#best-practices-summary)

This document outlines best practices for Victoria Metrics deployments, covering schema design, system-level considerations, storage optimization, query tuning, clustering, and operational aspects.

---

## 1. Schema Design & Data Organization

### 1.1 Metric Naming and Label Design

- **Consistent Naming Conventions**: Use snake_case for metric names (e.g., `http_requests_total`, `node_cpu_seconds_total`).
- **Hierarchical Naming**: Structure metrics in a logical hierarchy (e.g., `system_cpu_usage`, `system_memory_usage`).
- **Include Units in Names**: When applicable, include units in the metric name (e.g., `http_request_duration_seconds`).
- **Descriptive Suffixes**: Use suffixes like `_total`, `_count`, `_sum`, `_bucket` for counters, histograms, etc.

```code
# Good metric naming
http_requests_total
process_cpu_seconds_total
node_memory_used_bytes

# Poor metric naming
requests
CPU
memory_used_value
```

### 1.2 Label Management

- **Use Labels Sparingly**: Each additional label increases series cardinality.
- **Consistent Label Names**: Use consistent label names across related metrics (e.g., always `instance`, not sometimes `server` or `host`).
- **Meaningful Labels**: Use labels that are useful for filtering and aggregation (region, datacenter, instance, job).
- **Standard Labels**: Adopt Prometheus standard labels where applicable (`job`, `instance`, `environment`).

```code
# Good label usage
http_requests_total{job="api-server", instance="server01", method="GET", status="200"}

# Poor label usage (too many labels)
http_requests_total{job="api-server", instance="server01", method="GET", status="200",
                    user_id="12345", path="/api/v1/users", user_agent="Mozilla...", request_id="5f4dcc3b..."}
```

### 1.3 Handle Cardinality

- **Monitor Cardinality Growth**: Track active time series count via Victoria Metrics metrics.
- **Avoid High-Cardinality Labels**: Don't use user IDs, session IDs, or precise timestamps as labels.
- **Limit Label Values**: Use enumerated values or buckets instead of continuous values.
- **Pre-aggregate High-Cardinality Data**: Use vmagent for pre-aggregation of problematic metrics.

```code
# Avoid high-cardinality labels
# BAD: One series per user
logins_total{user_id="12345"} 1
logins_total{user_id="12346"} 1

# GOOD: Aggregate by relevant dimension
logins_total{role="admin"} 42
logins_total{role="user"} 5392
```

### 1.4 Time Series Design

- **Limit Number of Active Time Series**: Target < 10 million active time series per node for optimal performance.
- **Choose Counter vs. Gauge Appropriately**: Use counters for accumulating values, gauges for measurements.
- **Use Summary or Histogram Types**: For observing distributions of values (like request duration).
- **Consider Raw Data Aggregation**: Use vmagent's `relabel_config` to aggregate raw data when possible.

### 1.5 Retention Management

- **Define Appropriate Retention**: Configure retention based on data usage patterns.
- **Use Different Retentions When Needed**: Consider running multiple Victoria Metrics instances with different retentions.
- **Match Retention to Query Patterns**: Longer retention for less frequently accessed data.

```bash
# Set 3-month retention period
victoria-metrics -retentionPeriod=3M
```

## 2. System Level & Resource Management

### 2.1 Hardware Considerations

- **RAM**: Victoria Metrics is memory-efficient but benefits from sufficient RAM (8GB+ recommended for production).
- **CPU**: Multi-core processors help with parallel query processing (4+ cores recommended).
- **Disk**: SSDs significantly improve query and write performance.
- **File System**: ext4 or XFS are recommended for Linux deployments.

### 2.2 Memory Management

- **Configure Memory Limits**: Set appropriate memory limits to avoid OOM issues.
- **Monitor Memory Usage**: Watch for consistent high memory utilization.
- **Query Memory Limits**: Set maximum memory per query to prevent resource exhaustion.

```bash
# Memory configuration
victoria-metrics -memory.allowedPercent=75 -search.maxMemoryPerQuery=1000000000
```

### 2.3 CPU Optimization

- **Configure Concurrent Queries**: Adjust based on available CPU resources.
- **Monitor CPU Utilization**: Ensure CPU isn't consistently maxed out.
- **Consider Query Queue Settings**: Adjust queue settings based on workload.

```bash
# CPU optimization settings
victoria-metrics -search.maxConcurrentRequests=8 -search.maxQueueDuration=10s
```

### 2.4 Disk I/O Tuning

- **Separate Storage Volumes**: Consider separating data storage from the operating system.
- **I/O Scheduler**: Use deadline or noop for SSDs.
- **Monitor Disk Activity**: Watch for excessive disk I/O as a sign of problems.

### 2.5 Network Configuration

- **Adjust Buffer Sizes**: Tune network buffer sizes for high-throughput environments.
- **Monitor Network Traffic**: Watch for network bottlenecks.
- **Consider Connection Limits**: Tune connection and request limits based on load.

```bash
# Network settings
victoria-metrics -http.maxConnections=512 -http.maxRequestsPerConn=10000
```

## 3. Storage Level

### 3.1 Storage Type

- **SSD Preference**: SSDs are strongly recommended for production deployments.
- **Capacity Planning**: Plan for data growth based on series cardinality and retention.
- **RAID Considerations**: RAID 10 offers good balance of performance and redundancy.

### 3.2 Storage Path Planning

- **Dedicated Volume**: Store Victoria Metrics data on a dedicated volume.
- **Path Configuration**: Configure appropriate storage paths.
- **Filesystem Recommendations**: ext4 or XFS with noatime option for Linux.

```bash
# Storage path configuration
victoria-metrics -storageDataPath=/var/lib/victoria-metrics
```

### 3.3 Data Compression

- **Victoria Metrics Default Compression**: Victoria Metrics uses efficient compression by default.
- **Monitor Compression Ratio**: Track data size vs. raw ingestion as an indicator of efficiency.

### 3.4 Index Planning

- **Series Limiting**: Consider limiting maximum number of series per database.
- **Tag Value Limiting**: Limit the number of tag values when appropriate.

```bash
# Index planning settings
victoria-metrics -maxHourlySeries=1000000
```

## 4. Query Optimization

### 4.1 Query Design

- **Time Range Optimization**: Always include appropriate time ranges in queries.
- **Label Filtering First**: Filter by labels before applying computations.
- **Use Appropriate Aggregations**: Choose suitable aggregation functions and intervals.
- **Limit Returned Data**: Use `topk`, `bottomk`, or other functions to limit results.

```promql
# Efficient query pattern
sum by(instance) (
  rate(http_requests_total{status=~"5.."}[5m])
) > 0
```

### 4.2 Query Patterns to Avoid

- **Avoid Large Time Ranges**: Don't query months of data at high resolution.
- **Avoid High-Cardinality Group By**: Group by high-cardinality labels can cause performance issues.
- **Minimize Regular Expression Complexity**: Complex regex patterns are CPU intensive.
- **Avoid Unnecessary Subqueries**: Don't nest subqueries unnecessarily.

```promql
# Inefficient query pattern to avoid
sum by(instance, path, method, status, user_id) ( # Too many high-cardinality group by
  rate(http_requests_total[30d]) # Too long time range
) > 0
```

### 4.3 Using MetricsQL Efficiently

Victoria Metrics extends PromQL with MetricsQL, which provides additional functions:

- **Use VM-specific Functions**: Take advantage of functions like `rolling_*`, `range_*`.
- **Leverage Default Aggregations**: MetricsQL's default aggregations can simplify queries.
- **Use Quantile Functions Wisely**: Functions like `quantile_over_time` can be resource-intensive.

```promql
# Efficient use of MetricsQL extensions
rolling_avg_over_time(http_request_duration_seconds[10m], 1h) # Computing rolling average
```

### 4.4 Reducing Query Load

- **Query Caching**: Leverage Victoria Metrics' built-in caching.
- **Dashboard Optimization**: Configure appropriate refresh intervals in Grafana.
- **Pre-computed Views**: Use recording rules for frequently used queries.

## 5. High Availability & Clustering

### 5.1 Cluster Architecture

- **Component Separation**: Deploy vminsert, vmselect, and vmstorage on separate nodes for large deployments.
- **Component Scaling**: Scale components independently based on workload:
  - vminsert: Scale for write throughput
  - vmselect: Scale for query throughput
  - vmstorage: Scale for data volume and retention

```code
# Example cluster architecture
          │ Load Balancer │
          └───────┬───────┘
                  │
         ┌────────┴────────┐
         │                 │
┌────────▼─────┐   ┌───────▼──────┐
│   vminsert   │   │   vmselect   │
│  (multiple)  │   │  (multiple)  │
└──────┬───────┘   └───────┬──────┘
       │                   │
       └───────┬───────────┘
               │
      ┌────────┴────────┐
      │                 │
┌─────▼─────┐   ┌───────▼────┐
│ vmstorage │   │ vmstorage  │
│    #1     │   │    #N      │
└───────────┘   └────────────┘
```

### 5.2 Replication Strategy

- **Set Appropriate Replication Factor**: Based on reliability needs and resource constraints.
- **Monitor Replication Delays**: Watch for replication issues.
- **Data Consistency Checks**: Periodically verify data consistency across replicas.

```bash
# Configure replication factor
vminsert -replicationFactor=2 -storageNode=vmstorage1:8400,vmstorage2:8400
```

### 5.3 Load Balancing

- **Distribute Write Load**: Balance vminsert instances using load balancers.
- **Query Load Distribution**: Balance vmselect instances for query traffic.
- **Consider Stateful Routing**: For some operations, stateful routing might be beneficial.

### 5.4 Deployment Considerations

- **Container Orchestration**: Use Kubernetes for managing Victoria Metrics clusters.
- **Resource Allocation**: Ensure appropriate resource requests and limits.
- **Network Latency**: Keep components close to minimize network latency.
- **Multi-zone Deployment**: Distribute components across availability zones.

## 6. Monitoring and Operations

### 6.1 Monitoring Victoria Metrics

Key metrics to monitor:

- **Active Time Series**: Track the number of active time series.
- **Ingestion Rate**: Monitor the rate of incoming samples.
- **Query Performance**: Track query execution times.
- **Cache Hit Ratio**: Monitor cache effectiveness.
- **Resource Utilization**: CPU, memory, disk, network usage.
- **Storage Growth**: Monitor storage space utilization.

Victoria Metrics exposes metrics at `/metrics` endpoint:

```promql
# Example monitoring queries
sum(vm_active_time_series) # Total active series
rate(vm_rows_inserted_total[5m]) # Ingestion rate
histogram_quantile(0.95, sum(rate(vm_request_duration_seconds_bucket[5m])) by (le, path)) # 95th percentile request duration
```

### 6.2 Alerting on Victoria Metrics Health

Set up alerts for:

- **High Memory Usage**: When memory usage approaches limits.
- **Storage Space**: When storage utilization is high.
- **Query Latency**: When queries take too long.
- **Error Rates**: When error rates increase.
- **Data Staleness**: When data stops ingesting.

```yaml
# Example alerting rule
- alert: VictoriaMetricsHighMemoryUsage
  expr: process_resident_memory_bytes{job="victoria-metrics"} / vm_available_memory_bytes * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High memory usage on {{ $labels.instance }}"
    description: "Victoria Metrics memory usage is above 80% for 5 minutes"
```

### 6.3 Backup and Restore Strategies

- **Regular Snapshots**: Configure regular snapshots or backups.
- **Offsite Storage**: Store backups in a different location/cloud.
- **Backup Verification**: Regularly test backup restoration.
- **Snapshot Management**: Use Victoria Metrics' built-in snapshot functionality.

### 6.4 Upgrading Victoria Metrics

- **Plan Upgrades**: Schedule upgrades during maintenance windows.
- **Backup Before Upgrade**: Always take a backup before upgrading.
- **Test Upgrades**: Test upgrades in a staging environment first.
- **Monitor Post-Upgrade**: Watch for issues after upgrading.

## Best Practices Summary

- **Schema Design**: Use consistent naming and manage cardinality.
- **System Resources**: Optimize memory, CPU, disk, and network settings.
- **Storage**: Use SSDs, plan paths, and monitor compression.
- **Query Optimization**: Design efficient queries and reduce load.
- **Clustering**: Scale components and ensure high availability.
- **Operations**: Monitor metrics, set alerts, and manage backups.
