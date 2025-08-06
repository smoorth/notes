# AWS RDS vs Azure SQL Database: Feature Comparison Cheatsheet

---

## **Security Features**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Transparent Data Encryption (TDE)** | Available for SQL Server, Oracle, and RDS Custom. | Built-in, enabled by default for all databases. |
| **Encryption in Transit**     | TLS/SSL for encrypted connections.           | TLS/SSL for encrypted connections.            |
| **Encryption at Rest**        | AWS KMS for key management and storage encryption. | AES-256 encryption using Azure Key Vault.    |
| **Always Encrypted**          | Not supported.                               | Supported for protecting sensitive columns.   |
| **Database-Level Firewall**   | Security groups and IAM for network-level control. | Server-level and database-level firewalls.    |
| **Vulnerability Assessment**  | Manual processes or third-party tools like AWS Inspector. | Built-in vulnerability assessment feature.    |

---

## **Performance and Optimization**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Index Auto-Tuning**          | Not natively supported.                      | Built-in: Automatically creates/drops indexes to optimize performance. |
| **Query Performance Insights** | AWS Performance Insights provides insights into query performance. | Query Performance Insights included natively. |
| **Automatic Query Optimization** | Requires manual setup via tools like Query Plan Management. | Automatically suggests query improvements.    |
| **In-Memory Optimization**    | Available for SQL Server instances only.     | Fully supported with in-memory tables and OLTP. |
| **Scale-Out Read Replicas**    | Supported (Aurora offers faster scaling).    | Supported natively with Hyperscale and geo-replicas. |

---

## **Scalability and High Availability**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Read Replicas**              | Supported with up to 5 replicas (Aurora supports up to 15). | Supported with up to 30 read replicas in Hyperscale. |
| **Geo-Replication**            | Global Database for cross-region replication (Aurora). | Built-in active geo-replication.              |
| **High Availability (HA)**     | Multi-AZ deployments with synchronous replication. | Built-in HA with automatic failover.          |
| **Auto-Scaling**               | Aurora Auto-Scaling for compute and storage. | Hyperscale supports automatic compute scaling. |
| **Max Storage**                | Up to 128TB (Aurora).                        | Up to 100TB (Hyperscale).                     |

---

## **Backup and Restore**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Automated Backups**          | Automatic backups with customizable retention periods. | Automatic backups with up to 35-day retention. |
| **Point-in-Time Restore**      | Available for all supported engines.         | Available for all tiers (up to the retention period). |
| **Geo-Backups**                | Available for cross-region backups (Aurora). | Built-in geo-redundant backups.               |
| **Snapshot Sharing**           | Snapshots can be shared across AWS accounts. | Not natively supported.                       |

---

## **Management and Automation**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Automated Patching**         | Fully managed by AWS with configurable maintenance windows. | Automatic patching with minimal downtime.    |
| **Monitoring**                 | Amazon CloudWatch and Performance Insights.  | Azure Monitor and Query Performance Insights. |
| **Auto-Index Management**      | Not natively available.                      | Automatically creates, drops, and tunes indexes. |
| **Custom Maintenance Windows** | Supported.                                   | Supported for planned updates.                |

---

## **Integration Features**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Integration with Big Data**  | Amazon EMR, Redshift, and Athena integration. | Azure Synapse and Data Factory integration.   |
| **ETL and Data Migration**     | AWS Database Migration Service (DMS).        | Azure Database Migration Service.             |
| **Serverless Option**          | Aurora Serverless (scalable and pay-per-use). | Serverless tier for dynamic scaling and cost-efficiency. |
| **Support for PolyBase**       | Not supported.                               | PolyBase for querying external data sources.  |

---

## **Compliance and Certifications**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **HIPAA Compliance**           | Supported for all HIPAA-eligible services.   | Fully HIPAA-compliant.                        |
| **SOC 1, SOC 2, SOC 3**        | Supported.                                   | Supported.                                    |
| **GDPR Compliance**            | Supported.                                   | Supported.                                    |
| **PCI-DSS Certification**      | Supported.                                   | Supported.                                    |

---

## **Pricing and Licensing**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Licensing Model**            | BYOL (Bring Your Own License) or License Included. | Pay-as-you-go or Bring Your Own License (BYOL). |
| **Reserved Instances**         | Discounts for long-term commitments.         | Discounts with Reserved Capacity pricing.     |
| **Free Tier**                  | Free usage tier available for 12 months (750 hours/month). | Free tier available for small workloads.      |

---

## **Key Differentiators**

| **Feature**                   | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Built-In Intelligence**      | Limited to monitoring tools (manual tuning). | Automatic performance tuning and intelligence. |
| **Database Engine Support**    | Multiple engines: MySQL, PostgreSQL, SQL Server, Oracle, MariaDB, Aurora. | Limited to Microsoft SQL Server.             |
| **Global Reach**               | Global Database (Aurora) for ultra-low-latency, multi-region deployments. | Geo-replication for low-latency, multi-region deployments. |
| **Scalability**                | Aurora offers massive scaling for MySQL/PostgreSQL. | Hyperscale offers large scaling for SQL workloads. |

---

## **Use Cases**

### **AWS RDS**

- Ideal for **multi-engine support** (MySQL, PostgreSQL, Oracle, MariaDB, SQL Server).
- Use Aurora for **massive scalability** and advanced HA.
- Best suited for apps that require **specific database engines** or hybrid setups.

### **Azure SQL Database**

- Ideal for **Microsoft-centric environments**.
- Use Hyperscale for **large-scale databases** requiring dynamic scaling.
- Best for apps requiring **built-in intelligence** and optimization (e.g., auto-tuning).

---

## **Summary of Key Differences**

| **Category**                  | **AWS RDS**                                  | **Azure SQL Database**                         |
|--------------------------------|----------------------------------------------|-----------------------------------------------|
| **Index Tuning**               | Requires manual tuning or third-party tools. | Fully automated with Index Auto-Tuning.       |
| **Scalability**                | Aurora provides scalability for supported engines. | Hyperscale designed for large-scale SQL apps. |
| **Encryption**                 | TDE optional for some engines.               | TDE enabled by default.                       |
| **Database Engines**           | Supports multiple engines.                   | SQL Server only.                              |

---
