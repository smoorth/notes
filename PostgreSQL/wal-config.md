# PostgreSQL WAL Settings in CloudNativePG (CNPG)

This guide covers the key WAL-related settings in PostgreSQL that are relevant to CloudNativePG (CNPG), including their default values, explanations, how to check them inside the pod, and how to modify them.

## WAL Settings Overview

| Setting                      | Default Value | Description                                                                 | Where to Check                     | How to Modify                                                                 |
|------------------------------|---------------|-----------------------------------------------------------------------------|------------------------------------|------------------------------------------------------------------------------|
| wal_level                    | replica       | Determines the amount of information written to the WAL. Enables replication and PITR. | `SHOW wal_level;` in psql          | Modify `postgresql.parameters.wal_level` in PostgreSQLCluster YAML           |
| archive_mode                 | off           | Enables or disables WAL archiving. Required for PITR.                       | `SHOW archive_mode;` in psql       | Modify `postgresql.parameters.archive_mode` in PostgreSQLCluster YAML        |
| archive_timeout              | 0             | Forces WAL archiving every specified number of seconds.                     | `SHOW archive_timeout;` in psql    | Modify `postgresql.parameters.archive_timeout` in PostgreSQLCluster YAML     |
| max_wal_size                 | 1GB           | The maximum size of WAL before a checkpoint is triggered.                   | `SHOW max_wal_size;` in psql       | Modify `postgresql.parameters.max_wal_size` in PostgreSQLCluster YAML        |
| min_wal_size                 | 80MB          | The minimum size of WAL to be maintained between checkpoints.               | `SHOW min_wal_size;` in psql       | Modify `postgresql.parameters.min_wal_size` in PostgreSQLCluster YAML        |
| checkpoint_timeout           | 5min          | Time between automatic checkpoints.                                         | `SHOW checkpoint_timeout;` in psql | Modify `postgresql.parameters.checkpoint_timeout` in PostgreSQLCluster YAML  |
| checkpoint_completion_target | 0.5           | Controls how much of the checkpoint is completed during each cycle.         | `SHOW checkpoint_completion_target;` in psql | Modify `postgresql.parameters.checkpoint_completion_target` in PostgreSQLCluster YAML |
| wal_compression              | off           | Determines if WAL segments are compressed before archiving.                 | `SHOW wal_compression;` in psql    | Modify `postgresql.parameters.wal_compression` in PostgreSQLCluster YAML     |
| fsync                        | on            | Ensures data is written to disk to provide durability.                      | `SHOW fsync;` in psql              | Cannot be changed in CNPG, always on                                         |
| synchronous_commit           | on            | Determines if the database waits for WAL writes to be committed before responding to the transaction. | `SHOW synchronous_commit;` in psql | Modify `postgresql.parameters.synchronous_commit` in PostgreSQLCluster YAML  |

## Detailed Guide for Each Setting

### 1. wal_level

**Description:**

Determines how much information PostgreSQL writes to the WAL. This is critical for replication and PITR. The default is `replica`, which supports streaming replication and Point-in-Time Recovery (PITR).

**Where to Check:**
Run `SHOW wal_level;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    wal_level: "replica"  # Options: replica, logical, minimal
```

### 2. archive_mode

**Description:**

Enables WAL archiving. Required for PITR and storing WAL segments in external storage. `off` by default, so you need to explicitly enable it for backups.

**Where to Check:**
Run `SHOW archive_mode;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    archive_mode: "on"  # Turns on WAL archiving
```

### 3. archive_timeout

**Description:**

Forces PostgreSQL to archive WAL segments if no new segments are written within the specified time (in seconds). `0` means no forced archive (archiving occurs when a segment fills).

**Where to Check:**
Run `SHOW archive_timeout;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    archive_timeout: "60"  # Forces archive every 60 seconds
```

### 4. max_wal_size

**Description:**

Controls the maximum size of WAL files before PostgreSQL triggers a checkpoint. Larger sizes reduce the frequency of checkpoints. `1GB` by default, which is a reasonable balance for most workloads.

**Where to Check:**
Run `SHOW max_wal_size;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    max_wal_size: "2GB"  # Increases the max WAL size before checkpoint
```

### 5. min_wal_size

**Description:**

Controls the minimum WAL size to maintain. It helps prevent frequent recycling of WAL files and reduces disk I/O. `80MB` by default.

**Where to Check:**
Run `SHOW min_wal_size;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    min_wal_size: "512MB"  # Increases minimum size of WAL to maintain
```

### 6. checkpoint_timeout

**Description:**

Controls the time between automatic checkpoints. A shorter timeout increases disk writes and checkpoint frequency. `5min` by default.

**Where to Check:**
Run `SHOW checkpoint_timeout;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    checkpoint_timeout: "10min"  # Increases time between checkpoints
```

### 7. checkpoint_completion_target

**Description:**

Controls how aggressively PostgreSQL spreads out the checkpoint process. A value of `1.0` will attempt to complete the checkpoint all at once, while `0.5` will spread it out more evenly. `0.5` by default.

**Where to Check:**
Run `SHOW checkpoint_completion_target;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    checkpoint_completion_target: "0.9"  # Spreads checkpoints over a longer period
```

### 8. wal_compression

**Description:**

Determines whether WAL files are compressed before archiving. This reduces storage space but may impact performance. `off` by default.

**Where to Check:**
Run `SHOW wal_compression;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    wal_compression: "on"  # Enables compression for WAL files
```

### 9. fsync

**Description:**

Ensures data durability by forcing writes to disk. It is always enabled to ensure proper ACID compliance. `on` by default (cannot be changed in CNPG).

**Where to Check:**
Run `SHOW fsync;` inside the pod via psql.

**How to Modify:**
This setting is immutable in CNPG and always on.

### 10. synchronous_commit

**Description:**

Determines if the database waits for the WAL write to be confirmed before responding to the transaction. If `off`, it allows transactions to be considered committed before the WAL is written. `on` by default.

**Where to Check:**
Run `SHOW synchronous_commit;` inside the pod via psql.

**How to Modify:**
```yaml
postgresql:
  parameters:
    synchronous_commit: "off"  # Allows transactions to commit without waiting for WAL writes
```

## How to Access and Modify CNPG Configuration

### Access the CNPG Pod:
```sh
kubectl exec -it <your-pod-name> -- bash
```

### Check Settings in PostgreSQL:
Run SQL queries via psql to view the current values:
```sh
psql -U postgres -c "SHOW <setting_name>;"
```

### Modify Settings via PostgreSQLCluster YAML:
Edit the PostgreSQLCluster CR to change WAL settings:
```yaml
postgresql:
  parameters:
    wal_level: "replica"
    archive_mode: "on"
```

### Apply Changes:
```sh
kubectl apply -f postgresql-cluster.yaml
```
