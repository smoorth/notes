# MongoDB Configuration Guide

## Overview

This guide covers key configuration options for MongoDB, allowing you to optimize performance, security, and resource usage. Configuration is typically done through a YAML configuration file (mongod.conf) and can be supplemented with command-line arguments.

## Configuration File Locations

| Operating System | Default Configuration Path |
|------------------|----------------------------|
| Linux | `/etc/mongod.conf` |
| Windows | `<install directory>\bin\mongod.cfg` |
| macOS | `/usr/local/etc/mongod.conf` |

## Essential Configuration Categories

- [File Format & Structure](#file-format--structure)
- [Process Management](#process-management)
- [Network Configuration](#network-configuration)
- [Storage Configuration](#storage-configuration)
- [Memory & Resource Allocation](#memory--resource-allocation)
- [Security Configuration](#security-configuration)
- [Replication Configuration](#replication-configuration)
- [Sharding Configuration](#sharding-configuration)
- [Logging & Auditing](#logging--auditing)
- [Operational Parameters](#operational-parameters)

## File Format & Structure

MongoDB configuration files use YAML format, with key configuration sections organized hierarchically.

### Basic Configuration Structure

```yaml
# Basic mongod.conf structure
systemLog:
  destination: file
  path: "/var/log/mongodb/mongod.log"
  logAppend: true

storage:
  dbPath: "/var/lib/mongodb"
  journal:
    enabled: true

processManagement:
  fork: true
  pidFilePath: "/var/run/mongodb/mongod.pid"

net:
  port: 27017
  bindIp: "127.0.0.1,192.168.0.10"

security:
  authorization: enabled
```

### Command-Line Options to Configuration Mapping

| Command-Line Option | Configuration File Setting |
|---------------------|----------------------------|
| `--dbpath` | `storage.dbPath` |
| `--port` | `net.port` |
| `--bind_ip` | `net.bindIp` |
| `--logpath` | `systemLog.path` |
| `--auth` | `security.authorization: enabled` |
| `--replSet` | `replication.replSetName` |

## Process Management

Control how the MongoDB service runs and interacts with the operating system.

```yaml
processManagement:
  fork: true                       # Run process in background (Linux/Unix)
  pidFilePath: "/var/run/mongodb/mongod.pid"  # File for tracking process ID
  timeZoneInfo: "/usr/share/zoneinfo"  # Path to time zone database
```

Windows-specific options:

```yaml
processManagement:
  windowsService:
    serviceName: "MongoDB"         # Windows service name
    displayName: "MongoDB"         # Display name in services console
    description: "MongoDB Server"  # Service description
```

## Network Configuration

Control how MongoDB listens for connections and network security settings.

```yaml
net:
  port: 27017                      # Port to listen on
  bindIp: "127.0.0.1,192.168.1.10"  # IP addresses to bind to
  maxIncomingConnections: 65536    # Maximum concurrent connections
  wireObjectCheck: true            # Validate BSON during network operations

  # Compression settings
  compression:
    compressors: "snappy,zlib,zstd" # Available compression providers

  # SSL/TLS configuration
  tls:
    mode: "requireTLS"             # TLS mode: disabled, allowTLS, preferTLS, requireTLS
    certificateKeyFile: "/etc/ssl/mongodb.pem"  # PEM file with certificate and key
    CAFile: "/etc/ssl/ca.pem"      # Certificate Authority file
    allowInvalidCertificates: false  # Allow invalid certificates
    allowInvalidHostnames: false   # Allow invalid hostnames
```

## Storage Configuration

Control data storage options, including storage engine selection and journal settings.

```yaml
storage:
  dbPath: "/var/lib/mongodb"        # Data directory
  journal:
    enabled: true                   # Enable write-ahead journaling
    commitIntervalMs: 100           # Commit interval in milliseconds

  # Engine-specific options
  wiredTiger:
    engineConfig:
      cacheSizeGB: 2               # Size of WiredTiger cache
      journalCompressor: "snappy"  # Compression algorithm for journal
      directoryForIndexes: false   # Store indexes in separate directory

    collectionConfig:
      blockCompressor: "snappy"    # Default compression for collections

    indexConfig:
      prefixCompression: true      # Enable prefix compression for indexes
```

## Memory & Resource Allocation

Configure how MongoDB utilizes system memory and other resources.

```yaml
wiredTiger:
  engineConfig:
    cacheSizeGB: 4                 # WiredTiger cache size in GB

operationProfiling:
  slowOpThresholdMs: 100           # Time threshold for slow operations
  mode: "slowOp"                   # Profiling mode: off, slowOp, all

setParameter:
  cursorTimeoutMillis: 600000      # Cursor timeout in milliseconds (10 minutes)
  maxTransactionLockRequestTimeoutMillis: 5000  # Lock request timeout
```

For memory calculation, a common guideline is:

1. For dedicated MongoDB servers: set cacheSizeGB to 60-80% of available RAM
2. For shared servers: set cacheSizeGB to 30-40% of available RAM
3. Always leave RAM for OS cache and other processes

## Security Configuration

Control authentication, authorization, and other security features.

```yaml
security:
  authorization: enabled           # Enable role-based access control
  javascriptEnabled: true          # Enable JavaScript execution

  # KeyFile for replica set and sharded cluster authentication
  keyFile: "/etc/mongodb/keyfile"

  # LDAP configuration (Enterprise Edition)
  ldap:
    servers: "ldap.example.com"
    userToDNMapping:
      '[
        {
          match: "(.+)",
          ldapQuery: "ou=Users,dc=example,dc=com??sub?(uid={0})"
        }
      ]'
    authz:
      queryTemplate: "{USER}?memberOf?base"

  # Encryption at rest (Enterprise Edition)
  enableEncryption: true
  encryptionKeyFile: "/etc/mongodb/encryptionKey"
  encryptionCipherMode: "AES256-CBC"
```

## Replication Configuration

Settings for configuring replica sets for high availability.

```yaml
replication:
  replSetName: "rs0"              # Name of the replica set
  enableMajorityReadConcern: true # Enable majority read concern
  oplogSizeMB: 2048               # Size of the operations log in MB
```

For replica set members with specific roles:

```yaml
replication:
  replSetName: "rs0"

# For secondary-only members
setParameter:
  enableElectionHandoff: false    # Disable election handoff (for hidden members)

# For hidden members or delayed secondaries
replication:
  secondaryDelaySecs: 3600        # Delay replication by 1 hour
  hidden: true                    # Hide from client applications
  priority: 0                     # Never eligible for primary
  buildIndexes: true              # Build indexes on this member
  votes: 1                        # Vote in elections
```

## Sharding Configuration

Settings for MongoDB sharded clusters.

For mongos (router) instances:

```yaml
sharding:
  configDB: "configReplSet/cfgsrv1.example.com:27019,cfgsrv2.example.com:27019"
```

For shard servers:

```yaml
sharding:
  clusterRole: shardsvr          # Role: configsvr or shardsvr

net:
  port: 27018                    # Default port for shard servers
```

For config servers:

```yaml
sharding:
  clusterRole: configsvr         # Identifies as config server

net:
  port: 27019                    # Default port for config servers
```

## Logging & Auditing

Control how MongoDB logs operations and system events.

```yaml
systemLog:
  destination: file               # Log to file
  path: "/var/log/mongodb/mongod.log"  # Log file path
  logAppend: true                 # Append to log file on restart
  verbosity: 0                    # Log verbosity level (0-5)

  component:
    accessControl:
      verbosity: 1                # Auth logging verbosity
    command:
      verbosity: 1                # Command logging verbosity
    query:
      verbosity: 1                # Query logging verbosity
    replication:
      verbosity: 1                # Replication logging verbosity

# Auditing (Enterprise Edition)
auditLog:
  destination: file
  format: JSON
  path: "/var/log/mongodb/audit.log"
  filter: '{ atype: { $in: ["authCheck", "authenticate"] } }'
```

## Operational Parameters

Fine-tune MongoDB's behavior through operational parameters.

```yaml
setParameter:
  # Transaction settings
  transactionLifetimeLimitSeconds: 60  # Transaction lifetime in seconds

  # Connection management
  maxNumActiveUserThreads: 100         # Max active client threads
  serverGlobalParams.maxNumActiveUserThreads: 100  # New syntax in 4.4+

  # Memory and cache
  wiredTigerConcurrentReadTransactions: 128  # Concurrent read transactions
  wiredTigerConcurrentWriteTransactions: 32  # Concurrent write transactions

  # Performance tuning
  internalQueryExecMaxBlockingSortBytes: 33554432  # Max memory for in-memory sorts (32MB)
```

## Environment-Specific Configurations

### Development Environment

```yaml
systemLog:
  verbosity: 2                    # More verbose logging for debugging

storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 0.5            # Smaller cache for dev environments

net:
  bindIp: "127.0.0.1"             # Localhost only for security

security:
  authorization: disabled         # Optional: disable auth for easier development
```

### Production Environment

```yaml
systemLog:
  verbosity: 0                    # Minimal logging for performance

storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 16             # Larger cache for production (adjust as needed)

net:
  bindIp: "127.0.0.1,192.168.1.10"  # Restrict to specific interfaces
  maxIncomingConnections: 2000     # Adjust based on expected load

security:
  authorization: enabled          # Enable authentication

operationProfiling:
  slowOpThresholdMs: 100          # Log slow operations over 100ms
  mode: "slowOp"                  # Only log slow operations
```

### High-Traffic Production

```yaml
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 50             # Large cache for high traffic (adjust for your server)

    collectionConfig:
      blockCompressor: "zstd"     # Better compression ratio (MongoDB 4.2+)

net:
  maxIncomingConnections: 10000   # Higher connection limit

setParameter:
  wiredTigerConcurrentReadTransactions: 256  # More concurrent reads
  wiredTigerConcurrentWriteTransactions: 64   # More concurrent writes
```

## Dynamic Configuration

Some settings can be modified at runtime without restarting MongoDB.

```javascript
// Example: Change the profiling level at runtime
db.setProfilingLevel(1, { slowms: 200 })

// Example: Modify log verbosity
db.adminCommand( { setParameter: 1, logComponentVerbosity: { query: { verbosity: 2 } } } )

// Example: Modify cursor timeout
db.adminCommand( { setParameter: 1, cursorTimeoutMillis: 300000 } )
```

## Viewing Current Configuration

```javascript
// View current configuration
db.adminCommand({ getCmdLineOpts: 1 })

// View server status (includes some configuration parameters)
db.serverStatus()
```

## Validation and Testing

Before implementing configuration changes in production:

1. Use `mongod --config <path_to_config_file> --validate` to check syntax
2. Test in a development/staging environment
3. Monitor system behavior after changes
4. Have a rollback plan

```bash
# Validate configuration file
mongod --config /etc/mongod.conf --validate

# Start with new configuration for testing
mongod --config /etc/mongod.conf
