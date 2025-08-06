# Victoria Metrics Handy Commands

## Table of Contents

- [Victoria Metrics Handy Commands](#victoria-metrics-handy-commands)
  - [Table of Contents](#table-of-contents)
  - [Victoria Metrics Basics](#victoria-metrics-basics)
    - [What is Victoria Metrics?](#what-is-victoria-metrics)
    - [Key Concepts Simplified](#key-concepts-simplified)
    - [How Victoria Metrics Works](#how-victoria-metrics-works)
    - [Tips for Beginners](#tips-for-beginners)
    - [Common Issues to Watch For](#common-issues-to-watch-for)
  - [Basic Victoria Metrics Operations](#basic-victoria-metrics-operations)
  - [Data Insertion and Queries](#data-insertion-and-queries)
  - [Metric and Series Management](#metric-and-series-management)
  - [Backup and Restore](#backup-and-restore)

## Victoria Metrics Basics

### What is Victoria Metrics?

- Victoria Metrics is a **fast, cost-effective, and scalable time series database** and monitoring solution.
- It's optimized for **high-throughput time series data** ingestion, efficient storage, and fast querying.
- Victoria Metrics uses **MetricsQL**, an extended version of PromQL, for querying time series data.
- It is **compatible with Prometheus**, InfluxDB, Graphite, and other protocols, making it easy to integrate with existing monitoring setups.

### Key Concepts Simplified

- **Time Series**: A sequence of data points, typically consisting of measurements over time.
- **Metric**: A named measurement (e.g., `cpu_usage`, `http_requests_total`).
- **Label**: Key-value pairs for additional dimensions (e.g., `instance="server01"`, `job="node_exporter"`).
- **Series**: A unique combination of metric name and label set.
- **Sample**: A value for a specific series at a specific timestamp.
- **Scrape**: The process of collecting metrics from targets.
- **vmagent**: A service for collecting metrics and forwarding them to Victoria Metrics.
- **vminsert**: Component in the cluster version that accepts data writes.
- **vmselect**: Component in the cluster version that handles queries.
- **vmstorage**: Component in the cluster version that stores data.

### How Victoria Metrics Works

- Uses a **custom storage format** optimized for time series data.
- **Automatic downsampling** for efficient storage of historical data.
- Highly **compressed data storage** format requires significantly less disk space.
- Implements **indexing optimization** tailored for time series data.
- Provides automatic **data partitioning** in the cluster version.
- Offers **multi-tenant support** with data isolation between tenants.

### Tips for Beginners

- Start with the **single-node version** to get familiar with concepts.
- Use the **PromQL compatibility** to leverage existing knowledge or tutorials.
- Leverage **MetricsQL extensions** for advanced querying capabilities.
- Utilize **vmagent** for collecting metrics, especially in distributed setups.
- Monitor Victoria Metrics itself via its **exposed metrics** at `/metrics` endpoint.

### Common Issues to Watch For

- **Memory usage**: Victoria Metrics is designed to use less RAM than other solutions, but still requires monitoring.
- **Cardinality explosions**: Too many unique label combinations can impact performance.
- **Query complexity**: Overly complex queries can consume significant CPU resources.
- **Disk space**: While Victoria Metrics is efficient, time series data can still grow rapidly.
- **Backup management**: Ensuring regular backups are crucial for data safety.

## Basic Victoria Metrics Operations

| Command | Description |
|---------|-------------|
| `victoria-metrics` | Start Victoria Metrics single-node instance |
| `victoria-metrics -version` | Check Victoria Metrics version |
| `victoria-metrics -storageDataPath=/path/to/data` | Start with custom storage path |
| `victoria-metrics -retentionPeriod=3M` | Set retention period to 3 months |
| `vmctl --help` | Display help for the vmctl migration tool |
| `vmctl migrate --help` | Display help for migration commands |
| `systemctl status victoria-metrics` | Check status (if installed as systemd service) |
| `systemctl restart victoria-metrics` | Restart service |
| `curl http://localhost:8428/metrics` | Get internal metrics |
| `curl "http://localhost:8428/api/v1/status/tsdb"` | Get TSDB status information |
| `curl "http://localhost:8428/api/v1/export"` | Export data in native format |
| `curl "http://localhost:8428/api/v1/import"` | Import data in native format |
| `vmagent -promscrape.config=/path/to/prometheus.yml` | Start vmagent with Prometheus config |

## Data Insertion and Queries

| Command | Description |
|---------|-------------|
| `curl -d 'metric{label="value"} 123' http://localhost:8428/write` | Insert a single metric using Influx line protocol |
| `curl "http://localhost:8428/api/v1/query?query=up"` | Query for the 'up' metric |
| `curl "http://localhost:8428/api/v1/query_range?query=rate(http_requests_total[5m])&start=1607694498&end=1607695498&step=15"` | Range query with start/end times |
| `curl -d 'cpu_usage,host=server01 value=12.34' http://localhost:8428/write` | Write data using InfluxDB line protocol |
| `curl -H "Content-Type: application/json" -d '{"metric":{"__name__":"test_metric","job":"test_job"},"value":[1607694498,"123.45"]}' http://localhost:8428/api/v1/import/prometheus` | Import Prometheus-formatted metric |
| `curl -X POST -d "target=192.168.1.101:9100" http://localhost:8428/api/v1/targets/insert` | Add a target for scraping (when using service discovery) |
| `curl "http://localhost:8428/api/v1/query?query=sum(rate(http_requests_total[5m]))%20by%20(job)"` | Sum of request rates grouped by job |
| `curl "http://localhost:8428/api/v1/query?query=count_over_time(up[24h])/288"` | Availability percentage over 24h |
| `curl "http://localhost:8428/api/v1/series?match[]=up&match[]=process_cpu_seconds_total"` | List series for specified metrics |
| `curl "http://localhost:8428/api/v1/labels"` | Get all label names |
| `curl "http://localhost:8428/api/v1/label/job/values"` | Get all values for 'job' label |

## Metric and Series Management

| Command | Description |
|---------|-------------|
| `curl "http://localhost:8428/api/v1/series?match[]=metric{label=~\"value.*\"}"` | Find series matching a pattern |
| `curl "http://localhost:8428/api/v1/status/active_queries"` | List currently active queries |
| `curl -X POST "http://localhost:8428/api/v1/admin/tsdb/delete_series?match[]=metric_to_delete"` | Delete series matching the pattern |
| `curl "http://localhost:8428/api/v1/query?query=count({__name__!=\"\"}) by (__name__)"` | Count series per metric name |
| `curl "http://localhost:8428/api/v1/query?query=sort_desc(count by (__name__) ({__name__!=\"\"}))"` | Metrics sorted by series count |
| `curl "http://localhost:8428/api/v1/query?query=topk(10, count by (__name__) ({__name__!=\"\"}))"` | Top 10 metrics by series count |
| `curl -X POST "http://localhost:8428/api/v1/admin/tsdb/delete_series?match[]=up"` | Delete the 'up' metric |
| `curl -X POST "http://localhost:8428/api/v1/admin/tsdb/delete_series?match[]={instance=\"host1\"}"` | Delete all metrics for a specific instance |
| `curl -d 'delete_series{label="value"} 1' http://localhost:8428/delete/prometheus/api/v1/admin/tsdb/delete_series` | Graphite-style deletion |

## Backup and Restore

| Command | Description |
|---------|-------------|
| `victoria-metrics -storageDataPath=/path/to/victoria-metrics-data -snapshot.createURL=http://localhost:8428/snapshot/create` | Create a snapshot |
| `curl -X POST http://localhost:8428/snapshot/create` | Create a snapshot via HTTP API |
| `curl -X POST http://localhost:8428/snapshot/delete?snapshot=SNAPSHOT_NAME` | Delete a specific snapshot |
| `curl http://localhost:8428/snapshot/list` | List available snapshots |
| `vmbackup -storageDataPath=/path/to/victoria-metrics-data -dst=s3://bucket/path/to/backup -credsFilePath=/path/to/creds.env` | Backup to S3 |
| `vmbackup -storageDataPath=/path/to/victoria-metrics-data -dst=gs://bucket/path/to/backup -credsFilePath=/path/to/creds.env` | Backup to Google Cloud Storage |
| `vmbackup -storageDataPath=/path/to/victoria-metrics-data -dst=/path/to/backup/dir` | Backup to local directory |
| `vmrestore -src=/path/to/backup/dir -storageDataPath=/path/to/victoria-metrics-data` | Restore from local backup |
| `vmrestore -src=s3://bucket/path/to/backup -storageDataPath=/path/to/victoria-metrics-data -credsFilePath=/path/to/creds.env` | Restore from S3 backup |
| `vmrestore -src=gs://bucket/path/to/backup -storageDataPath=/path/to/victoria-metrics-data -credsFilePath=/path/to/creds.env` | Restore from Google Cloud Storage backup |
