# AWS Cheat Sheet for Azure Users (With Focus on Databases)

---

## General AWS Concepts

| **AWS Term**                 | **Description**                                                                                     | **Azure Equivalent**              |
|-------------------------------|-----------------------------------------------------------------------------------------------------|------------------------------------|
| **Region**                   | Geographical area hosting multiple Availability Zones (data centers).                              | Azure Region                      |
| **Availability Zone (AZ)**   | Isolated data center within a region.                                                              | Azure Availability Zones          |
| **Edge Location**            | Points of presence for content delivery via CloudFront.                                            | Azure Edge Zones                  |
| **IAM (Identity & Access)**  | Service to manage users, roles, and permissions.                                                   | Azure Active Directory / IAM      |
| **EC2 (Elastic Compute)**    | Virtual servers in the cloud.                                                                      | Azure Virtual Machines            |
| **S3 (Simple Storage)**      | Scalable object storage.                                                                           | Azure Blob Storage                |
| **CloudFormation**           | Infrastructure-as-code tool for automating deployments.                                           | Azure Resource Manager Templates  |
| **VPC (Virtual Private Cloud)** | Virtual network for provisioning resources.                                                        | Azure Virtual Network (VNet)      |

---

## Database Services

| **AWS Service**                  | **Description**                                                                                      | **Azure Equivalent**                  |
|-----------------------------------|------------------------------------------------------------------------------------------------------|----------------------------------------|
| **RDS (Relational Database Service)** | Managed relational database service supporting multiple engines like MySQL, PostgreSQL, and SQL Server. | Azure SQL Database / Azure Database for MySQL/PostgreSQL |
| **Aurora**                       | High-performance managed relational database compatible with MySQL and PostgreSQL.                  | Azure Database for PostgreSQL Flexible Server |
| **DynamoDB**                     | Fully managed NoSQL database with key-value and document data models.                               | Azure Cosmos DB (with NoSQL APIs)     |
| **ElastiCache**                  | In-memory caching service supporting Redis and Memcached.                                           | Azure Cache for Redis                 |
| **DocumentDB**                   | Managed NoSQL document database compatible with MongoDB.                                            | Azure Cosmos DB (with MongoDB API)    |
| **Redshift**                     | Managed data warehousing solution for analytics.                                                    | Azure Synapse Analytics               |
| **Neptune**                      | Managed graph database for relationships and network-oriented data.                                 | Azure Cosmos DB (Graph API)           |
| **Timestream**                   | Time-series database for IoT and operational data.                                                  | Azure Data Explorer                   |
| **Keyspaces (for Cassandra)**    | Managed Cassandra-compatible NoSQL database.                                                       | Azure Managed Instance for Apache Cassandra |
| **Glue**                         | Data integration and ETL service for preparing data for analytics.                                 | Azure Data Factory                    |
| **Athena**                       | Query S3 data using SQL without a database.                                                         | Azure Synapse (serverless SQL pools)  |

---

## Storage & Backup

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **S3 (Simple Storage)**       | Scalable object storage for any type of data.                                   | Azure Blob Storage                     |
| **EBS (Elastic Block Store)** | Block storage for use with EC2.                                                 | Azure Managed Disks                    |
| **EFS (Elastic File System)** | Managed file storage for use with EC2, auto-scaling.                            | Azure Files                            |
| **Backup**                    | Centralized backup service for AWS resources.                                   | Azure Backup                           |
| **Glacier**                   | Long-term archival storage with low cost.                                       | Azure Blob Storage (Cool and Archive tiers) |

---

## Analytics & Big Data

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **EMR (Elastic MapReduce)**   | Managed Hadoop, Spark, and Presto for big data processing.                       | Azure HDInsight / Azure Databricks    |
| **Kinesis**                   | Real-time streaming data ingestion and processing.                              | Azure Event Hubs / Azure Stream Analytics |
| **QuickSight**                | BI and analytics service for dashboards.                                        | Power BI Embedded                      |
| **Data Pipeline**             | Data workflows and movement between services.                                   | Azure Data Factory                     |

---

## AI/ML (Artificial Intelligence & Machine Learning)

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **SageMaker**                 | Platform for building, training, and deploying ML models.                       | Azure Machine Learning                 |
| **Rekognition**               | Image and video analysis service.                                               | Azure Computer Vision / Azure Video Indexer |
| **Comprehend**                | Natural language processing service.                                            | Azure Text Analytics                   |
| **Polly**                     | Text-to-speech service.                                                         | Azure Speech Services                  |
| **Lex**                       | Service for building conversational interfaces (chatbots).                      | Azure Bot Service                      |

---

## Networking & Content Delivery

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **Route 53**                  | Scalable DNS and domain name registration.                                      | Azure DNS                              |
| **CloudFront**                | Content delivery network (CDN) for static and dynamic content.                  | Azure Front Door / Azure CDN           |
| **Direct Connect**            | Dedicated network connections to AWS.                                           | Azure ExpressRoute                     |
| **API Gateway**               | Manage and host APIs at scale.                                                  | Azure API Management                   |
| **Elastic Load Balancing (ELB)** | Load balancing for EC2 instances, containers, and more.                        | Azure Load Balancer / App Gateway      |

---

## Developer & DevOps Tools

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **CodeCommit**                | Managed Git repositories.                                                       | Azure Repos                            |
| **CodeBuild**                 | Continuous integration build service.                                           | Azure Pipelines                        |
| **CodeDeploy**                | Automated application deployment.                                               | Azure DevOps Services                  |
| **CodePipeline**              | Continuous delivery and release automation.                                     | Azure Pipelines                        |
| **CloudWatch**                | Monitoring and observability for AWS resources and applications.                | Azure Monitor                          |
| **X-Ray**                     | Distributed tracing for debugging applications.                                 | Azure Application Insights             |

---

## Security & Identity

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **IAM (Identity & Access)**   | Manage access and permissions for AWS resources.                                | Azure Active Directory / RBAC          |
| **Cognito**                   | User authentication and management for applications.                           | Azure AD B2C                           |
| **KMS (Key Management Service)** | Securely manage cryptographic keys.                                            | Azure Key Vault                        |
| **Secrets Manager**           | Store and retrieve application secrets securely.                                | Azure Key Vault (Secrets)              |
| **GuardDuty**                 | Threat detection service for AWS resources.                                     | Azure Security Center                  |

---

## Migration & Hybrid Solutions

| **AWS Service**               | **Description**                                                                 | **Azure Equivalent**                  |
|--------------------------------|---------------------------------------------------------------------------------|----------------------------------------|
| **Migration Hub**             | Central hub to track application migrations.                                    | Azure Migrate                          |
| **DMS (Database Migration Service)** | Migrate databases to AWS.                                                     | Azure Database Migration Service       |
| **Outposts**                  | Run AWS services on-premises.                                                   | Azure Stack                            |

---

## Key Tips for AWS Navigation

1. **AWS Management Console**: Use the search bar in the console to quickly find services.
2. **CLI & SDKs**: AWS CLI and SDKs allow you to interact with services programmatically.
3. **Cost Management**: Use AWS Cost Explorer and Budgets to track spending, similar to Azure Cost Management.
4. **Marketplace**: Browse pre-configured solutions and services from third parties in the AWS Marketplace.

---
