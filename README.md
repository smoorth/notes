# Technical Notes Repository

![Repository](https://img.shields.io/badge/Repository-Technical%20Notes-blue)
![Last Updated](https://img.shields.io/badge/Last%20Updated-January%202025-green)
![Technologies](https://img.shields.io/badge/Technologies-Multi%20Platform-orange)

A comprehensive collection of technical documentation, guides, and best practices covering various technologies and platforms. This repository serves as a centralized knowledge base for DevOps, database administration, cloud computing, and system administration.

## Table of Contents

- [Technical Notes Repository](#technical-notes-repository)
  - [Table of Contents](#table-of-contents)
  - [Contents](#contents)
    - [Cloud Platforms](#cloud-platforms)
    - [Kubernetes \& Orchestration](#kubernetes--orchestration)
    - [Databases](#databases)
      - [PostgreSQL](#postgresql)
      - [MongoDB](#mongodb)
      - [Microsoft SQL Server](#microsoft-sql-server)
    - [Time Series \& Monitoring](#time-series--monitoring)
      - [InfluxDB](#influxdb)
      - [Victoria Metrics](#victoria-metrics)
    - [Caching \& In-Memory](#caching--in-memory)
    - [Linux \& System Administration](#linux--system-administration)
    - [Programming](#programming)
    - [Development Tools](#development-tools)
    - [Performance](#performance)
  - [Quick Start](#quick-start)
  - [How to Use](#how-to-use)
  - [Repository Statistics](#repository-statistics)
  - [Contributing](#contributing)
    - [Ways to Contribute](#ways-to-contribute)
    - [Contribution Guidelines](#contribution-guidelines)
    - [File Naming Convention](#file-naming-convention)

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
  - [Beginner Guide](MSSQL/mssql-beginner-guide.md)
  - [Advanced Guide](MSSQL/mssql-advanced-guide.md)
  - [Best Practices](MSSQL/mssql-best-practices.md)
  - [Handy Commands](MSSQL/mssql-handy-commands.md)
  - [Performance Tuning](MSSQL/mssql-performance-tuning.md)

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
  - [Linux Networking Essentials](Linux/linux-networking-essentials.md)
  - [Linux Performance Tuning](Linux/linux-performance-tuning.md)
  - [Linux Process Management](Linux/linux-process-management.md)
  - [Linux Security Fundamentals](Linux/linux-security-fundamentals.md)
  - [Linux Storage & Filesystems](Linux/linux-storage-filesystems.md)
  - [Linux Text Processing Tools](Linux/linux-text-processing-tools.md)
  - [Shell Scripting Guide](Linux/shell-scripting-guide.md)
  - [Ubuntu Package Management Guide](Linux/ubuntu-package-management-guide.md)
  - [Ubuntu Server Setup & Hardening](Linux/ubuntu-server-setup-hardening.md)
  - [Ubuntu System Administration Guide](Linux/ubuntu-system-administration-guide.md)
  - [Ubuntu Troubleshooting Guide](Linux/ubuntu-troubleshooting-guide.md)

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

- 📋 **Configuration guides** for setting up various systems
- ✅ **Best practices** for optimal performance and security
- 🔧 **Handy commands** for day-to-day operations
- 🔍 **Troubleshooting guides** for common issues
- ⚡ **Performance optimization** tips and techniques
- 🐳 **Containerization** and orchestration guides
- ☁️ **Cloud platform** specific documentation

## How to Use

1. 📁 Navigate to the technology folder you're interested in
2. 📖 Start with the best practices or configuration guide
3. ⚡ Use the handy commands reference for quick operations
4. 🎯 Refer to optimization guides for performance tuning
5. 🛠️ Check troubleshooting guides when issues arise

## Repository Statistics

- **Total Technologies Covered:** 15+
- **Database Systems:** PostgreSQL, MongoDB, MSSQL, InfluxDB, Redis, Victoria Metrics
- **Cloud Platforms:** AWS, Azure
- **Operating Systems:** Linux (Ubuntu focus)
- **Orchestration:** Kubernetes, Helm
- **Programming Languages:** Python, SQL variants

## Contributing

We welcome contributions to improve and expand this technical knowledge base! Here's how you can help:

### Ways to Contribute

- 📝 **Add new notes** for technologies not yet covered
- 🔄 **Update existing documentation** with new features or changes
- 🐛 **Fix errors** or outdated information
- 📚 **Improve organization** and navigation
- 💡 **Share best practices** and lessons learned
- 🔗 **Add cross-references** between related topics

### Contribution Guidelines

1. Keep documentation clear and concise
2. Include practical examples where possible
3. Follow the existing naming conventions
4. Update the README when adding new files
5. Use proper markdown formatting
6. Test commands and configurations before documenting

### File Naming Convention

- Use lowercase with hyphens: `technology-guide.md`
- Be descriptive: `postgres-backup-strategy.md`
- Include technology prefix when relevant

---

**Last updated:** January 2025
