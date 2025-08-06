# InfluxDB Backup Strategy & RTO/RPO Planning

## Recovery Time Objective (RTO) & Recovery Point Objective (RPO)

| Environment | Backup Strategy | RTO (Max Downtime) | RPO (Max Data Loss) | Backup Retention | Additional Backup |
|-------------|-----------------|--------------------|---------------------|------------------|-------------------|
| Production (PRD) | - Full backup daily<br>- Incremental backups every 6h<br>- Replication for HA | ≤ 15 minutes | ≤ 6 hours | 14 days retention | Weekly full backup |
| Staging (STG) | - Full backup daily<br>- No incremental backups | ≤ 4 hours | ≤ 24 hours | 7 days retention | Weekly full backup |
| Development (DEV) | - Full backup weekly | ≤ 24 hours | ≤ 1 week | 3 days retention | None |

## Backup Methods Overview

InfluxDB offers several methods for backing up data, each with its own advantages and use cases. This section outlines the available options and provides guidelines for implementing effective backup strategies.

### 1. Built-in Backup Commands

InfluxDB provides the `influxd backup` command for creating backups of your databases. There are two main formats:

#### 1.1 Enterprise-Compatible Format (Default)

This is the default format for InfluxDB Enterprise.

```bash
# Full backup of all databases
influxd backup /path/to/backup

# Backup specific database
influxd backup -database mydb /path/to/backup
```

#### 1.2 Portable Format

Recommended for most users, especially when migrating between InfluxDB versions or editions.

```bash
# Full backup of all databases
influxd backup -portable /path/to/backup

# Backup specific database
influxd backup -portable -database mydb /path/to/backup

# Incremental backup from a specific timestamp
influxd backup -portable -start 2023-01-01T00:00:00Z -database mydb /path/to/backup
```

### 2. Time-Based Backup Strategies

| Backup Type | Description | Command Example | Recommended Frequency |
|-------------|-------------|-----------------|----------------------|
| **Full Backup** | Complete backup of all data | `influxd backup -portable /path/to/backup` | Daily for PRD, Weekly for STG/DEV |
| **Incremental Backup** | Only backs up data since last backup | `influxd backup -portable -start 2023-06-01T00:00:00Z /path/to/backup` | Every 6 hours for PRD |
| **Time Range Backup** | Backs up data in a specific time range | `influxd backup -portable -start 2023-06-01T00:00:00Z -end 2023-06-02T00:00:00Z /path/to/backup` | As needed |

### 3. Backup Storage Considerations

- **Compression**: Backups are automatically compressed to save space
- **Storage Requirements**: Plan for approximately 50% of the original database size for each backup
- **Retention**: Implement an automated rotation strategy to delete old backups
- **Storage Location**: Store backups on a different system or cloud storage
- **Access Control**: Secure backup files with appropriate permissions

### 4. Production Environment (PRD) Backup Implementation

The production environment requires the most robust backup strategy to minimize potential data loss and downtime.

#### 4.1 Daily Full Backup

Schedule a daily full backup during off-peak hours:

```bash
#!/bin/bash
# Daily full backup script
BACKUP_DIR="/mnt/backup/influxdb/full/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR
influxd backup -portable $BACKUP_DIR
```

#### 4.2 Six-Hour Incremental Backups

Supplement with incremental backups every 6 hours:

```bash
#!/bin/bash
# Incremental backup script
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LAST_BACKUP=$(cat /var/log/influxdb/last_backup_time.txt)
BACKUP_DIR="/mnt/backup/influxdb/incremental/$(date +%Y-%m-%d-%H)"
mkdir -p $BACKUP_DIR
influxd backup -portable -start "$LAST_BACKUP" $BACKUP_DIR
echo "$TIMESTAMP" > /var/log/influxdb/last_backup_time.txt
```

#### 4.3 Automated Rotation Policy

Implement a backup rotation policy to maintain 14 days of backups:

```bash
#!/bin/bash
# Backup rotation script
find /mnt/backup/influxdb/full -type d -mtime +14 -exec rm -rf {} \;
find /mnt/backup/influxdb/incremental -type d -mtime +7 -exec rm -rf {} \;
```

### 5. Staging Environment (STG) Backup Implementation

Staging environments require less frequent backups but should still have a reliable strategy.

#### 5.1 Daily Full Backup

```bash
#!/bin/bash
# Daily full backup for staging
BACKUP_DIR="/mnt/backup/influxdb-staging/full/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR
influxd backup -portable $BACKUP_DIR
```

#### 5.2 Automated Rotation Policy (7 days)

```bash
#!/bin/bash
# Backup rotation script for staging
find /mnt/backup/influxdb-staging/full -type d -mtime +7 -exec rm -rf {} \;
```

### 6. Development Environment (DEV) Backup Implementation

Development environments require minimal backup strategies.

#### 6.1 Weekly Full Backup

```bash
#!/bin/bash
# Weekly full backup for dev
BACKUP_DIR="/mnt/backup/influxdb-dev/full/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR
influxd backup -portable $BACKUP_DIR
```

#### 6.2 Automated Rotation Policy (3 days)

```bash
#!/bin/bash
# Backup rotation script for dev
find /mnt/backup/influxdb-dev/full -type d -mtime +3 -exec rm -rf {} \;
```

## Restoration Procedures

### Restore from Full Backup

```bash
# Restore all databases
influxd restore -portable /path/to/backup

# Restore specific database
influxd restore -portable -database mydb /path/to/backup

# Restore to a new database
influxd restore -portable -database mydb -newdb mydb_restored /path/to/backup
```

### Restore from Incremental Backup

When restoring from incremental backups, you must first restore the full backup and then apply each incremental backup in chronological order.

```bash
# 1. Restore the full backup
influxd restore -portable /path/to/full-backup

# 2. Apply each incremental backup in order
influxd restore -portable /path/to/incremental-backup-1
influxd restore -portable /path/to/incremental-backup-2
# ... and so on
```

### Disaster Recovery Procedure

1. **Stop InfluxDB service**

   ```bash
   sudo systemctl stop influxdb
   ```

2. **Clear existing data** (if necessary)

   ```bash
   sudo rm -rf /var/lib/influxdb/data/*
   sudo rm -rf /var/lib/influxdb/meta/*
   ```

3. **Restore metadata and data from backup**

   ```bash
   sudo influxd restore -portable /path/to/backup
   ```

4. **Update permissions**

   ```bash
   sudo chown -R influxdb:influxdb /var/lib/influxdb
   ```

5. **Start InfluxDB service**

   ```bash
   sudo systemctl start influxdb
   ```

6. **Verify restoration**

   ```bash
   influx -execute "SHOW DATABASES"
   ```

## Testing and Verification

### Backup Verification Schedule

| Environment | Verification Frequency | Type of Test |
|-------------|------------------------|--------------|
| Production (PRD) | Monthly | Full restore to test environment |
| Staging (STG) | Quarterly | Full restore test |
| Development (DEV) | On major version upgrades | Basic restore test |

### Verification Procedure

1. **Create a test backup**

   ```bash
   influxd backup -portable /tmp/test-backup
   ```

2. **Restore to a test instance**

   ```bash
   docker run -v /tmp/test-backup:/backup influxdb:latest influxd restore -portable /backup
   ```

3. **Run verification queries**

   ```bash
   influx -host test-instance -execute "SELECT count(*) FROM database.measurement WHERE time > now() - 1d"
   ```

4. **Document results and any issues encountered**

## Monitoring Backup Success

### Backup Success Metrics

- **Backup Size**: Monitor for unexpected changes in backup size
- **Backup Duration**: Track how long backups take to complete
- **Backup Success Rate**: Track successful vs. failed backups

### Alert Configuration

Set up alerts for:

- Failed backup jobs
- Backups exceeding expected duration
- Backup size anomalies
- Insufficient backup storage space

### Example Monitoring Script

```bash
#!/bin/bash
# Monitor backup completion and size

BACKUP_DIR="/mnt/backup/influxdb/full/$(date +%Y-%m-%d)"
EXPECTED_MIN_SIZE=1000000  # 1MB minimum expected size

if [ ! -d "$BACKUP_DIR" ]; then
  echo "CRITICAL: Backup directory does not exist. Backup likely failed."
  exit 2
fi

SIZE=$(du -s "$BACKUP_DIR" | cut -f1)
if [ $SIZE -lt $EXPECTED_MIN_SIZE ]; then
  echo "WARNING: Backup size ($SIZE KB) is smaller than expected ($EXPECTED_MIN_SIZE KB)"
  exit 1
fi

echo "OK: Backup completed successfully. Size: $SIZE KB"
exit 0
```
