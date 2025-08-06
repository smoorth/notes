# PostgreSQL Deployment Best Practices

- [PostgreSQL Deployment Best Practices](#postgresql-deployment-best-practices)
  - [1. Database Level](#1-database-level)
    - [1.1 Proper Configuration of PostgreSQL Parameters](#11-proper-configuration-of-postgresql-parameters)
    - [1.2 Indexes and Query Optimization](#12-indexes-and-query-optimization)
    - [1.3 Autovacuum and Bloat Management](#13-autovacuum-and-bloat-management)
    - [1.4 Partitioning Large Tables](#14-partitioning-large-tables)
    - [1.5 Backup and Disaster Recovery](#15-backup-and-disaster-recovery)
    - [1.6 Security Best Practices](#16-security-best-practices)
  - [2. Operating System Level](#2-operating-system-level)
    - [2.1 Choice of OS](#21-choice-of-os)
    - [2.2 Resource Limits (`ulimits`)](#22-resource-limits-ulimits)
    - [2.3 I/O Scheduler Tuning](#23-io-scheduler-tuning)
    - [2.4 Swappiness](#24-swappiness)
    - [2.5 Transparent Huge Pages (THP)](#25-transparent-huge-pages-thp)
    - [2.6 CPU Tuning](#26-cpu-tuning)
  - [3. Storage Level](#3-storage-level)
    - [3.1 Storage Type](#31-storage-type)
    - [3.2 Filesystem Tuning](#32-filesystem-tuning)
    - [3.3 WAL Storage](#33-wal-storage)
    - [3.4 I/O Throughput](#34-io-throughput)
    - [3.5 Backup Storage](#35-backup-storage)
  - [4. Cloud-Native PostgreSQL (CNPG) Specific Best Practices](#4-cloud-native-postgresql-cnpg-specific-best-practices)
    - [4.1 Kubernetes and CNPG Setup](#41-kubernetes-and-cnpg-setup)
    - [4.2 High Availability (HA)](#42-high-availability-ha)
    - [4.3 Storage Class and Persistent Volumes](#43-storage-class-and-persistent-volumes)
    - [4.4 Network Policies](#44-network-policies)
    - [4.5 Monitoring and Logging](#45-monitoring-and-logging)
  - [Best practices summary](#best-practices-summary)

This document outlines best practices for PostgreSQL deployments, covering considerations from the **database level** down to the **operating system** and **storage level**. It also includes specific guidelines for **Cloud-Native PostgreSQL (CNPG)** setups.

---

## 1. Database Level

### 1.1 Proper Configuration of PostgreSQL Parameters

- **Memory Settings**:
  - **shared_buffers**: Set to 25-40% of available memory.
  - **work_mem**: Adjust for sorting/joining operations (per query).
  - **maintenance_work_mem**: Allocate more memory for maintenance tasks like `VACUUM`.

- **Checkpoint and WAL Tuning**:
  - **checkpoint_timeout**: Set to 15-30 minutes to avoid frequent checkpoints.
  - **wal_buffers**: Increase to 16-64MB to prevent write bottlenecks.
  - **max_wal_size**: Increase to 1-2GB for high-write environments.

- **Connection Pooling**:
  - Use **PgBouncer** to prevent connection overload.
  - Keep `max_connections` reasonable (use pooling for excess).

### 1.2 Indexes and Query Optimization

- **Create appropriate indexes** for frequently queried columns but avoid over-indexing.
- Use **`EXPLAIN ANALYZE`** to analyze and optimize slow queries.
- Use **`pg_stat_statements`** for query statistics to identify and optimize long-running queries.

### 1.3 Autovacuum and Bloat Management

- **Autovacuum**: Tune aggressively for large or frequently updated tables.
- Use **pg_repack** or **cluster** to manage index/table bloat.

### 1.4 Partitioning Large Tables

- Use **partitioning** (by time, range, or list) for large tables (e.g., logs, events).

### 1.5 Backup and Disaster Recovery

- Use **pgBackRest** or **Barman** for physical backups and PITR (Point-In-Time Recovery).
- Schedule **pg_dump** for logical backups as needed.
- Implement **offsite backups** and test recovery procedures regularly.

### 1.6 Security Best Practices

- Use **SSL** for encrypted connections and enforce **SSL certificates**.
- Apply **least privilege** principles for user roles.
- Enable **SQL statement logging** for auditing.
- Use the **pgAudit** extension for advanced auditing.

---

## 2. Operating System Level

### 2.1 Choice of OS

- Use **Linux** (e.g., Ubuntu, Debian, CentOS) for PostgreSQL production deployments.
- Preferred filesystems: **ZFS**, **ext4**, or **XFS**.

### 2.2 Resource Limits (`ulimits`)

- Set file descriptor limits appropriately:

```bash
  ulimit -n 65536
```

Adjust kernel parameters (sysctl.conf):

```bash
vm.swappiness = 1
kernel.shmmax = <set to 50% of RAM>
vm.overcommit_memory = 2
```

### 2.3 I/O Scheduler Tuning

For SSDs/NVMe, switch to noop or deadline scheduler:

```bash
echo noop > /sys/block/sdX/queue/scheduler
```

### 2.4 Swappiness

- Set vm.swappiness to a low value (e.g., 1-10) to minimize swapping:

```bash
vm.swappiness = 1
```

### 2.5 Transparent Huge Pages (THP)

Disable **Transparent Huge Pages (THP)** for better PostgreSQL performance:

```bash
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

### 2.6 CPU Tuning

- Use processors with **high clock speeds** and fast cores.
- For **NUMA** systems, bind PostgreSQL to memory-local CPU cores.

## 3. Storage Level

### 3.1 Storage Type

- **SSD/NVMe**: Prefer high-performance SSDs or NVMe drives for performance-critical databases.
- **RAID 10**: Use for balancing redundancy and performance.
- Avoid **RAID 5/6** due to poor write performance.

### 3.2 Filesystem Tuning

- Use **ext4** or **XFS**.
- Mount PostgreSQL data directory with noatime and nodiratime to reduce unnecessary writes:

```bash
mount -o noatime,nodiratime /dev/sdX /var/lib/postgresql/data
```

### 3.3 WAL Storage

- Place **WAL logs** on separate high-speed storage (e.g., SSD/NVMe).

### 3.4 I/O Throughput

- Use tools like fio to benchmark disk I/O:

```bash
fio --name=random-write --ioengine=libaio --rw=randwrite --bs=4k --numjobs=8 --size=4G --runtime=60 --group_reporting
```

### 3.5 Backup Storage

- Use separate, redundant storage (e.g., cloud storage like AWS S3) for backups.

## 4. Cloud-Native PostgreSQL (CNPG) Specific Best Practices

### 4.1 Kubernetes and CNPG Setup

- Use PostgreSQL Operators like **CloudNativePG, Zalando Postgres Operator**, or **Crunchy Data Postgres Operator**.
  - Configure for automated backups, failover, and replication.
  - Use **horizontal scaling** of read replicas.

### 4.2 High Availability (HA)

- Use **Patroni** for HA in a Kubernetes environment (automates leader election and failover).
- Configure **Pod anti-affinity** to distribute pods across failure domains or availability zones.

### 4.3 Storage Class and Persistent Volumes

- Use **fast persistent storage** (e.g., AWS EBS io1/gp3, GCP Persistent SSD) for PostgreSQL PVCs.
- Set up **PV snapshots** for disaster recovery.

### 4.4 Network Policies

- Apply **Kubernetes Network Policies** to control pod-to-pod communication and limit access to the PostgreSQL cluster.

### 4.5 Monitoring and Logging

- Use **Prometheus** and **Grafana** for monitoring PostgreSQL metrics (via **pgMonitor**).
- Set up **Fluentd** or **EFK (Elasticsearch, Fluentd, Kibana)** for centralized log management.

## Best practices summary

|Layer|Best Practices|
|--|--|
|Database Level|Configure memory/WAL settings, connection pooling, autovacuum, partitioning, security, and backups.|
|OS Level|Optimize Linux settings (ulimits, vm.swappiness), use SSD/NVMe, choose ext4/XFS, disable THP.|
|Storage Level|Use RAID 10 for redundancy, separate WAL and data storage, ensure high I/O throughput, use fio for benchmarking.|
|CNPG Setup|Use PostgreSQL Operators, configure HA with Patroni, fast persistent storage (e.g., provisioned IOPS), zone-aware deployments.|
