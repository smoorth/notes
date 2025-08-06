# Technical Notes Repository

A comprehensive collection of technical documentation, guides, and best practices covering various technologies and platforms.

## Contents

### Cloud Platforms

- **[AWS & Azure](Cloud/)**
  - [AWS vs Azure Abbreviations](Cloud/aws-azure-abbreviations.md)
  - [AWS RDS vs Azure Database](Cloud/aws-rds-vs-azure-db.md)
  - [General AWS Concepts](Cloud/general-aws-concepts.md)
  - [AWS Journey Tips & Tricks](Cloud/tips-tricks-aws-journey.md)
  - [Azure Journey Tips & Tricks](Cloud/tips-tricks-azure-journey.md)
  - [Tools for AWS & Azure](Cloud/tools-for-aws-azure.md)

### Kubernetes & Orchestration

- **[Kubernetes](K8s/)**
  - [CKA Study Guide](K8s/cka-study-guide.md)
  - [K8s Cheatsheet](K8s/K8s-cheatsheet.md)
  - [The K8s Kitchen](K8s/The-K8s-kitchen.md)
  - [PV & PVC Cleanup](K8s/pv&pvc-cleanup.md)
  - **[Helm](K8s/helm/)**
    - [Helm Cheatsheet](K8s/helm/helm-cheatsheet.md)
  - **[MinIO](K8s/minio/)**
    - [MinIO Guide](K8s/minio/minIO.md)
    - [MinIO on K8s](K8s/minio/minIO-on-K8s.md)
    - [MinIO Client (mc)](K8s/minio/minIO-client-mc.md)

### Databases

#### PostgreSQL

- **[PostgreSQL](PostgreSQL/)**
  - [What is PostgreSQL](PostgreSQL/What%20is%20PostgreSQL.md)
  - [Best Practices](PostgreSQL/pgbestpractices.md)
  - [Handy Commands](PostgreSQL/pg-handy-cmds.md)
  - [Database Design](PostgreSQL/pg-db-design.md)
  - [Permissions](PostgreSQL/pg-permissions.md)
  - [Backup Strategy](PostgreSQL/pgbackup-strategy.md)
  - [Replication](PostgreSQL/pg-replication.md)
  - [Extensions](PostgreSQL/pgextensions.md)
  - [Performance & Optimization](PostgreSQL/pg-stat-statements.md)
  - [Index Usage](PostgreSQL/pgindexusage.md)
  - [Auto-vacuum Guide](PostgreSQL/auto-vacuum-guide.md)
  - [WAL Configuration](PostgreSQL/wal-config.md)
  - [TimescaleDB Guide](PostgreSQL/timescaledb-guide.md)
  - **[pgvector](PostgreSQL/pgvector/)**
    - [Vector Guide](PostgreSQL/pgvector/vector-guide.md)
    - [Vector Testing](PostgreSQL/pgvector/vector-testing.sql)
  - **[Postgres on K8s](PostgreSQL/Postgres-on-K8s/)**
    - [Helm PG Cluster Installation](PostgreSQL/Postgres-on-K8s/helm-pgcluster-installation.md)
    - [K8s vs DB RACI](PostgreSQL/Postgres-on-K8s/k8s-vs-db-raci.md)

#### MongoDB

- **[MongoDB](mongodb/)**
  - [Best Practices](mongodb/mongodb-best-practices.md)
  - [Configuration Guide](mongodb/mongodb-config-guide.md)
  - [Handy Commands](mongodb/mongodb-handy-cmds.md)
  - [Permissions](mongodb/mongodb-permissions.md)
  - [Data Modeling](mongodb/mongodb-datamodeling.md)
  - [CMDB Data Model](mongodb/mongodb-data-model-cmdb.md)
  - [Query Optimization](mongodb/mongodb-query-optimization.md)

#### Microsoft SQL Server

- **[MSSQL](MSSQL/)**

### Time Series & Monitoring

#### InfluxDB

- **[InfluxDB](InfluxDB/)**
  - [Best Practices](InfluxDB/influxdb-best-practices.md)
  - [Configuration Guide](InfluxDB/influxdb-config-guide.md)
  - [Handy Commands](InfluxDB/influxdb-handy-cmds.md)
  - [Permissions](InfluxDB/influxdb-permissions.md)
  - [Backup Strategy](InfluxDB/influxdb-backup-strategy.md)
  - [Query Optimization](InfluxDB/influxdb-query-optimization.md)

#### Victoria Metrics

- **[Victoria Metrics](Victoria-Metrics/)**
  - [Best Practices](Victoria-Metrics/victoria-metrics-best-practices.md)
  - [Configuration Guide](Victoria-Metrics/victoria-metrics-config-guide.md)
  - [Handy Commands](Victoria-Metrics/victoria-metrics-handy-cmds.md)
  - [Permissions](Victoria-Metrics/victoria-metrics-permissions.md)
  - [Query Optimization](Victoria-Metrics/victoria-metrics-query-optimization.md)

### Caching & In-Memory

- **[Redis](Redis/)**
  - [Redis Guide](Redis/redis-guide.md)
  - [Load Testing Script](Redis/test-redis-loadv2.py)

### Linux & System Administration

- **[Linux](Linux/)**
  - [Common Linux Commands Reference](Linux/Common%20Linux%20Commands%20Reference.md)

### Programming

- **[Python](python/)**
  - [30 Days Learning Journey](python/30days-learning-journey.md)
  - [Python Functions Guide](python/python-functions-guide.md)

### Development Tools

- **[VS Code](vscode/)**
  - [Beginner Guide](vscode/beginner-guide.md)

### Performance

- **[Performance](Performance/)**
  - [T-SQL vs PL/pgSQL Performance Cheatsheet](Performance/tsql-vs-psql-perfromance-cheatsheet.md)

## Quick Start

This repository is organized by technology and includes:

- **Configuration guides** for setting up various systems
- **Best practices** for optimal performance and security
- **Handy commands** for day-to-day operations
- **Troubleshooting guides** for common issues
- **Performance optimization** tips and techniques

## How to Use

1. Navigate to the technology folder you're interested in
2. Start with the best practices or configuration guide
3. Use the handy commands reference for quick operations
4. Refer to optimization guides for performance tuning

## Contributing

Feel free to add new notes, update existing documentation, or improve the organization of this repository.

---

**Last updated:** August 2025
