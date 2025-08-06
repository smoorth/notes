# InfluxDB Configuration Guide

## Overview

This guide covers key configuration options for InfluxDB, allowing you to optimize performance, security, and resource usage. Configuration methods differ between InfluxDB 1.x (using a TOML configuration file) and InfluxDB 2.x (using environment variables or configuration files).

## Configuration Approaches

| InfluxDB Version | Primary Configuration Method | File Location |
|------------------|------------------------------|--------------|
| InfluxDB 1.x | TOML configuration file | `/etc/influxdb/influxdb.conf` |
| InfluxDB 2.x | Environment variables and YAML | `/etc/influxdb2/config.yml` |

## Essential Configuration Categories

- [Meta & Global Settings](#meta--global-settings)
- [Data Storage & Retention](#data-storage--retention)
- [Query & Runtime Configuration](#query--runtime-configuration)
- [HTTP API Settings](#http-api-settings)
- [Security Configuration](#security-configuration)
- [Monitoring & Logging](#monitoring--logging)
- [Advanced Performance Tuning](#advanced-performance-tuning)

## Meta & Global Settings

These settings control basic InfluxDB behavior and service parameters.

### InfluxDB 1.x

```toml
[meta]
  dir = "/var/lib/influxdb/meta"
  retention-autocreate = true
  logging-enabled = true

[global]
  max-select-point = 0         # Maximum points returned by a query (0 = unlimited)
  max-select-series = 0        # Maximum series returned by a query
  max-select-buckets = 0       # Maximum buckets returned by a query
```

### InfluxDB 2.x

```yaml
# config.yml
engine:
  path: /var/lib/influxdb2
  wal-fsync-delay: 0s
  max-concurrent-compactions: 0
  max-series-per-database: 1000000
```

| Environment Variable | Description | Default Value |
|---------------------|-------------|--------------|
| `INFLUXDB_ENGINE_PATH` | Storage engine path | `/var/lib/influxdb2` |
| `INFLUXDB_BOLT_PATH` | Path to boltdb database | `${INFLUXDB_ENGINE_PATH}/influxd.bolt` |
| `INFLUXDB_HTTP_BIND_ADDRESS` | API HTTP bind address | `:8086` |

## Data Storage & Retention

These settings control how InfluxDB stores and manages time series data.

### InfluxDB 1.x

```toml
[data]
  dir = "/var/lib/influxdb/data"
  wal-dir = "/var/lib/influxdb/wal"

  # TSM engine settings
  cache-max-memory-size = "1g"          # Maximum size of cache
  cache-snapshot-memory-size = "25m"    # Flush to disk threshold
  cache-snapshot-write-cold-duration = "10m"  # Flush cache if older than this

  # Compaction settings
  compact-full-write-cold-duration = "4h"    # Trigger full compaction
  max-concurrent-compactions = 0       # 0 = runtime.GOMAXPROCS(0) / 2

  # WAL settings
  wal-fsync-delay = "0s"              # Group of WAL fsync delay
  wal-max-concurrent-writes = 0       # 0 = unlimited concurrent WAL writes
  wal-max-write-delay = "10m"         # Maximum time to hold WAL writes

# Retention policies automatically enforce data retention
[retention]
  enabled = true                      # Enable retention policy enforcement
  check-interval = "30m"              # Frequency of retention policy enforcement
```

### InfluxDB 2.x

Retention is controlled via bucket configurations and APIs rather than the main config file. You can configure retention periods when creating buckets:

```bash
# Create bucket with 14-day retention
influx bucket create \
  --org my-organization \
  --name my-bucket \
  --retention 14d
```

Storage engine configuration:

```yaml
# config.yml
engine:
  cache-max-memory-size: 1073741824  # 1GB
  cache-snapshot-memory-size: 26214400  # 25MB
  tsm-use-madv-willneed: false  # Disk I/O hints
```

## Query & Runtime Configuration

These settings tune how InfluxDB handles queries and manages compute resources.

### InfluxDB 1.x

```toml
[coordinator]
  write-timeout = "10s"              # Write timeout for requests
  max-concurrent-queries = 0         # Maximum concurrent queries (0 = unlimited)
  query-timeout = "0s"               # Maximum time a query may run (0 = unlimited)
  log-queries-after = "0s"           # Log queries taking longer than this
  max-select-point = 0               # Maximum points a SELECT can return (0 = unlimited)

[shard-precreation]
  enabled = true                     # Enable shard pre-creation
  check-interval = "10m"             # Time between pre-creation checks
  advance-period = "30m"             # Create shards this far ahead of time
```

### InfluxDB 2.x

```yaml
query:
  initial-memory-bytes: 9223372036854775807  # Memory allowed for a query
  memory-bytes: 0  # Maximum memory allowed for a query (0 = unlimited)
  queue-size: 10  # Maximum queries allowed in execution queue
  concurrency: 10  # Maximum queries that can execute concurrently
```

| Environment Variable | Description | Default Value |
|---------------------|-------------|--------------|
| `INFLUXDB_QUERY_CONCURRENCY` | Max number of concurrent queries | `10` |
| `INFLUXDB_QUERY_QUEUE_SIZE` | Size of the query queue | `10` |
| `INFLUXDB_QUERY_MEMORY_BYTES` | Maximum memory for a single query | `0` (unlimited) |

## HTTP API Settings

These settings control the HTTP API endpoint behavior.

### InfluxDB 1.x

```toml
[http]
  enabled = true                      # Enable HTTP API
  bind-address = ":8086"              # HTTP API bind address
  auth-enabled = true                 # Enable authentication
  log-enabled = true                  # HTTP request logging
  write-tracing = false               # Log write operations
  pprof-enabled = true                # Enable /debug/pprof endpoint
  https-enabled = false               # Enable HTTPS
  https-certificate = "/etc/ssl/influxdb.pem"  # HTTPS certificate file
  https-private-key = "/etc/ssl/influxdb-key.pem"  # HTTPS private key
  max-row-limit = 0                   # Maximum rows returned (0 = unlimited)
  max-connection-limit = 0            # Max simultaneous connections (0 = unlimited)
  unix-socket-enabled = false         # Enable Unix socket for HTTP API
  unix-socket-permissions = "0777"    # Unix socket permissions
  bind-socket = "/var/run/influxdb.sock"  # Unix socket path
```

### InfluxDB 2.x

```yaml
http:
  bind-address: ":8086"
  idle-timeout: 3m0s
  read-timeout: 0s
  write-timeout: 0s
  max-connection-limit: 0  # 0 = unlimited
  max-header-size: 1048576  # 1MB
  access-log-enabled: false  # Enable HTTP request logging
```

| Environment Variable | Description | Default Value |
|---------------------|-------------|--------------|
| `INFLUXDB_HTTP_BIND_ADDRESS` | API HTTP bind address | `:8086` |
| `INFLUXDB_HTTP_IDLE_TIMEOUT` | Maximum time for idle connections | `3m` |
| `INFLUXDB_HTTP_READ_TIMEOUT` | Maximum time for reading HTTP requests | `0s` (unlimited) |
| `INFLUXDB_HTTP_WRITE_TIMEOUT` | Maximum time for writing HTTP responses | `0s` (unlimited) |

## Security Configuration

These settings control authentication, authorization, and security features.

### InfluxDB 1.x

```toml
# HTTP authentication
[http]
  auth-enabled = true                 # Enable authentication

# Admin user configuration
# Use CREATE USER with GRANT statements via the CLI instead of this
```

### InfluxDB 2.x

```yaml
ui:
  enabled: true

# TLS settings
tls:
  key: /etc/ssl/influxdb-key.pem
  cert: /etc/ssl/influxdb.pem
  strict-ciphers: true
```

| Environment Variable | Description | Default Value |
|---------------------|-------------|--------------|
| `INFLUXDB_TLS_CERT` | TLS certificate file path | `""` |
| `INFLUXDB_TLS_KEY` | TLS private key file path | `""` |
| `INFLUXDB_TLS_MIN_VERSION` | Minimum TLS version | `"1.2"` |
| `INFLUXDB_TLS_STRICT_CIPHERS` | Enable strict cipher suite checking | `false` |

## Monitoring & Logging

These settings control how InfluxDB tracks its own performance and logs activity.

### InfluxDB 1.x

```toml
[monitor]
  store-enabled = true                # Store metrics in `_internal` database
  store-database = "_internal"        # Database name for internal metrics
  store-interval = "10s"              # Frequency to store metrics

[logging]
  format = "auto"                     # Log format: auto, logfmt, or json
  level = "info"                      # Log level: debug, info, warn, error
  suppress-logo = false               # Disable printed logo
```

### InfluxDB 2.x

```yaml
log-level: info  # debug, info, error
tracing:
  type: log  # log, jaeger
metrics:
  disabled: false
  bind-address: ":8086"
  store-interval: 10s
```
