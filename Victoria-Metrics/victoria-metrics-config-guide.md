# Victoria Metrics Configuration Guide

## Overview

This guide covers key configuration options for Victoria Metrics, allowing you to optimize performance, security, and resource usage. Configuration in Victoria Metrics is primarily done through command-line flags, with different options available for single-node deployment versus cluster deployment.

## Configuration Methods

| Deployment Type | Primary Configuration Method | How to Apply |
|------------------|------------------------------|--------------|
| Single-node | Command-line flags | Pass flags directly to `victoria-metrics` binary |
| Cluster | Component-specific flags | Configure each component (vminsert, vmselect, vmstorage) separately |
| Docker/Kubernetes | Environment variables | Set variables in deployment manifests |

## Essential Configuration Categories

- [Storage & Data Retention](#storage--data-retention)
- [Memory & Resource Management](#memory--resource-management)
- [HTTP & Network Settings](#http--network-settings)
- [Query & Runtime Parameters](#query--runtime-parameters)
- [Security Configuration](#security-configuration)
- [Cluster Configuration](#cluster-configuration)
- [Integration Settings](#integration-settings)

## Storage & Data Retention

These settings control how Victoria Metrics stores and manages time series data.

### Single-node Victoria Metrics

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-storageDataPath` | Path to store data | `victoria-metrics-data` | `-storageDataPath=/var/lib/victoria-metrics` |
| `-retentionPeriod` | Data retention period | `1` (1 month) | `-retentionPeriod=3M` (3 months) |
| `-dedup.minScrapeInterval` | Deduplication interval | `0` (disabled) | `-dedup.minScrapeInterval=15s` |
| `-snapshotAuthKey` | Auth key for snapshots | empty | `-snapshotAuthKey=mysecretkey` |
| `-snapshot.createURL` | URL to create snapshot | empty | `-snapshot.createURL=http://localhost:8428/snapshot/create` |
| `-maxHourlySeries` | Max new series per hour | `0` (unlimited) | `-maxHourlySeries=1000000` |

Example startup command with storage settings:

```bash
victoria-metrics \
  -storageDataPath=/var/lib/victoria-metrics \
  -retentionPeriod=6M \
  -dedup.minScrapeInterval=15s
```

### Cluster Mode Storage (vmstorage)

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-storageDataPath` | Path to store data | `vmstorage-data` | `-storageDataPath=/var/lib/vmstorage` |
| `-retentionPeriod` | Data retention period | `1` (1 month) | `-retentionPeriod=3M` (3 months) |
| `-vminsertAddr` | Address for vminsert | `:8400` | `-vminsertAddr=:8400` |
| `-vmselectAddr` | Address for vmselect | `:8401` | `-vmselectAddr=:8401` |

Example vmstorage command:

```bash
vmstorage \
  -storageDataPath=/var/lib/vmstorage \
  -retentionPeriod=6M \
  -vminsertAddr=:8400 \
  -vmselectAddr=:8401
```

## Memory & Resource Management

These settings tune how Victoria Metrics uses system resources.

### Single-node Victoria Metrics

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-memory.allowedPercent` | Max memory usage percent | `60` | `-memory.allowedPercent=75` |
| `-memory.allowedBytes` | Max memory usage in bytes | `0` (auto) | `-memory.allowedBytes=16000000000` (16GB) |
| `-search.maxMemoryPerQuery` | Max memory per query | `0` (auto) | `-search.maxMemoryPerQuery=1000000000` (1GB) |
| `-search.maxConcurrentRequests` | Max concurrent queries | `8` | `-search.maxConcurrentRequests=16` |
| `-search.maxQueueDuration` | Max wait time in queue | `10s` | `-search.maxQueueDuration=30s` |
| `-search.maxQueryDuration` | Max query execution time | `30s` | `-search.maxQueryDuration=60s` |

Example startup command with memory settings:

```bash
victoria-metrics \
  -memory.allowedPercent=70 \
  -search.maxMemoryPerQuery=2000000000 \
  -search.maxConcurrentRequests=12
```

### Cluster Mode Resource Settings

For vmselect:

```bash
vmselect \
  -memory.allowedPercent=70 \
  -search.maxMemoryPerQuery=2000000000 \
  -search.maxConcurrentRequests=16 \
  -search.maxQueueDuration=20s
```

For vminsert:

```bash
vminsert \
  -memory.allowedPercent=60 \
  -maxLabelsPerTimeseries=30
```

## HTTP & Network Settings

These settings control the HTTP API endpoint behavior and networking options.

### Single-node Victoria Metrics

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-httpListenAddr` | HTTP server address | `:8428` | `-httpListenAddr=127.0.0.1:8428` |
| `-http.pathPrefix` | URL prefix for all endpoints | empty | `-http.pathPrefix=/vm` |
| `-http.connTimeout` | Incoming connection timeout | `2m` | `-http.connTimeout=5m` |
| `-http.disableResponseCompression` | Disable gzip compression | `false` | `-http.disableResponseCompression` |
| `-http.maxRequestsPerConn` | Max requests per conn | `1000` | `-http.maxRequestsPerConn=10000` |
| `-tls` | Whether to enable HTTPS | `false` | `-tls` |
| `-tlsCertFile` | Path to TLS cert file | empty | `-tlsCertFile=/path/to/cert.pem` |
| `-tlsKeyFile` | Path to TLS key file | empty | `-tlsKeyFile=/path/to/key.pem` |

Example startup command with HTTP settings:

```bash
victoria-metrics \
  -httpListenAddr=:8428 \
  -http.connTimeout=3m \
  -tls \
  -tlsCertFile=/etc/ssl/victoria-metrics.crt \
  -tlsKeyFile=/etc/ssl/victoria-metrics.key
```

### Cluster Mode HTTP Settings

For vmselect:

```bash
vmselect \
  -httpListenAddr=:8481 \
  -http.pathPrefix=/select \
  -selectNode=vmstorage1:8401,vmstorage2:8401
```

For vminsert:

```bash
vminsert \
  -httpListenAddr=:8480 \
  -http.pathPrefix=/insert \
  -storageNode=vmstorage1:8400,vmstorage2:8400
```

## Query & Runtime Parameters

These settings tune how Victoria Metrics handles queries and processes data.

### Single-node Victoria Metrics

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-search.cacheTimestampOffset` | Lookback for cache | `5m` | `-search.cacheTimestampOffset=10m` |
| `-search.latencyOffset` | Extra time for slow queries | `30s` | `-search.latencyOffset=1m` |
| `-search.logSlowQueryDuration` | Log threshold for slow queries | `0` (disabled) | `-search.logSlowQueryDuration=5s` |
| `-search.maxPointsPerTimeseries` | Max points returned per series | `30e3` | `-search.maxPointsPerTimeseries=50000` |
| `-search.maxSeries` | Max series to process | `30e6` | `-search.maxSeries=60000000` |
| `-search.maxStepForPointsAdjustment` | Max step for Points adjustment | `1m` | `-search.maxStepForPointsAdjustment=2m` |

Example startup command with query settings:

```bash
victoria-metrics \
  -search.cacheTimestampOffset=10m \
  -search.maxSeries=50000000 \
  -search.logSlowQueryDuration=3s
```

### Cluster Mode Query Settings

For vmselect:

```bash
vmselect \
  -search.cacheTimestampOffset=10m \
  -search.maxSeries=50000000 \
  -search.logSlowQueryDuration=3s
```

## Security Configuration

These settings control authentication, authorization, and security features.

### Single-node Victoria Metrics

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-httpAuth.username` | Username for HTTP Auth | empty | `-httpAuth.username=admin` |
| `-httpAuth.password` | Password for HTTP Auth | empty | `-httpAuth.password=password` |
| `-httpAuth.passwordFile` | Path to password file | empty | `-httpAuth.passwordFile=/etc/vm/password` |
| `-httpAuth.urlPrefix` | URL prefix for HTTP Auth | empty | `-httpAuth.urlPrefix=/select` |
| `-tls` | Enable HTTPS | `false` | `-tls` |
| `-tlsCAFile` | Path to CA file for client certs | empty | `-tlsCAFile=/path/to/ca.pem` |
| `-denyQueryTracing` | Disable query tracing | `false` | `-denyQueryTracing` |

Example startup command with security settings:

```bash
victoria-metrics \
  -httpAuth.username=admin \
  -httpAuth.password=strong-password \
  -denyQueryTracing
```

### Cluster Mode Security Settings

For each component (vminsert, vmselect, vmstorage):

```bash
vmselect \
  -httpAuth.username=admin \
  -httpAuth.password=strong-password \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem
```

## Cluster Configuration

These settings are specific to Victoria Metrics cluster deployment.

### vmselect Configuration

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-selectNode` | vmstorage nodes | empty | `-selectNode=vmstorage1:8401,vmstorage2:8401` |
| `-replicationFactor` | Data replication factor | `1` | `-replicationFactor=2` |
| `-dedup.minScrapeInterval` | Deduplication interval | `0` (disabled) | `-dedup.minScrapeInterval=15s` |
| `-cacheDataPath` | Path to cache data | empty | `-cacheDataPath=/var/lib/vmselect-cache` |
| `-enableTenantID` | Enable multi-tenancy | `false` | `-enableTenantID` |

Example vmselect command:

```bash
vmselect \
  -selectNode=vmstorage1:8401,vmstorage2:8401 \
  -replicationFactor=2 \
  -dedup.minScrapeInterval=15s \
  -cacheDataPath=/var/lib/vmselect-cache \
  -enableTenantID
```

### vminsert Configuration

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-storageNode` | vmstorage nodes | empty | `-storageNode=vmstorage1:8400,vmstorage2:8400` |
| `-replicationFactor` | Data replication factor | `1` | `-replicationFactor=2` |
| `-maxLabelsPerTimeseries` | Max labels per series | `30` | `-maxLabelsPerTimeseries=20` |
| `-enableTenantID` | Enable multi-tenancy | `false` | `-enableTenantID` |

Example vminsert command:

```bash
vminsert \
  -storageNode=vmstorage1:8400,vmstorage2:8400 \
  -replicationFactor=2 \
  -maxLabelsPerTimeseries=25 \
  -enableTenantID
```

## Integration Settings

These settings configure how Victoria Metrics integrates with other systems.

### Prometheus Integration

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-promscrape.config` | Prometheus config file | empty | `-promscrape.config=/path/to/prometheus.yml` |
| `-promscrape.configCheckInterval` | Config check interval | `0s` (disabled) | `-promscrape.configCheckInterval=1m` |
| `-promscrape.discovery.concurrency` | Service discovery concurrency | `100` | `-promscrape.discovery.concurrency=200` |
| `-promscrape.maxScrapeSize` | Max scrape size | `16MB` | `-promscrape.maxScrapeSize=32MB` |
| `-promscrape.seriesLimitPerTarget` | Max series per target | `0` (unlimited) | `-promscrape.seriesLimitPerTarget=100000` |

Example integration settings:

```bash
victoria-metrics \
  -promscrape.config=/path/to/prometheus.yml \
  -promscrape.configCheckInterval=1m
```

### InfluxDB Integration

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-influxListenAddr` | InfluxDB ingestion addr | empty | `-influxListenAddr=:8089` |
| `-influxMeasurementFieldSeparator` | Separator between field and measurement | `_` | `-influxMeasurementFieldSeparator=.` |
| `-influxSkipSingleField` | Skip single field names | `false` | `-influxSkipSingleField` |
| `-influxTrimTimestamp` | Trim timestamps | `false` | `-influxTrimTimestamp` |
| `-influxDBName` | InfluxDB database name | empty | `-influxDBName=metrics` |

Example InfluxDB integration:

```bash
victoria-metrics \
  -influxListenAddr=:8089 \
  -influxDBName=metrics
```

### Graphite Integration

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `-graphiteListenAddr` | Graphite ingestion addr | empty | `-graphiteListenAddr=:2003` |
| `-graphiteAllowedLabels` | Labels for Graphite metrics | empty | `-graphiteAllowedLabels=host,datacenter` |
| `-graphiteSkipSingleField` | Skip single field names | `false` | `-graphiteSkipSingleField` |
