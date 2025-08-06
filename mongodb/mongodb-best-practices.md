# MongoDB Deployment Best Practices

- [MongoDB Deployment Best Practices](#mongodb-deployment-best-practices)
  - [1. Schema Design \& Data Modeling](#1-schema-design--data-modeling)
    - [1.1 Document Structure](#11-document-structure)
    - [1.2 Relationship Patterns](#12-relationship-patterns)
    - [1.3 Schema Versioning](#13-schema-versioning)
    - [1.4 Indexing Strategy](#14-indexing-strategy)
    - [1.5 Handling Large Documents](#15-handling-large-documents)
  - [2. System Level \& Resource Management](#2-system-level--resource-management)
    - [2.1 Hardware Considerations](#21-hardware-considerations)
    - [2.2 Memory Management](#22-memory-management)
    - [2.3 CPU Optimization](#23-cpu-optimization)
    - [2.4 Disk I/O Tuning](#24-disk-io-tuning)
    - [2.5 Network Configuration](#25-network-configuration)
  - [3. Data Organization \& Storage](#3-data-organization--storage)
    - [3.1 Collection Organization](#31-collection-organization)
    - [3.2 Storage Engine Configuration](#32-storage-engine-configuration)
    - [3.3 Time Series Collections](#33-time-series-collections)
    - [3.4 Data Lifecycle Management](#34-data-lifecycle-management)
  - [4. Query Optimization](#4-query-optimization)
    - [4.1 Index Utilization](#41-index-utilization)
    - [4.2 Query Patterns to Avoid](#42-query-patterns-to-avoid)
    - [4.3 Aggregation Pipeline Optimization](#43-aggregation-pipeline-optimization)
    - [4.4 Read/Write Operation Tuning](#44-readwrite-operation-tuning)
  - [5. Monitoring and Operations](#5-monitoring-and-operations)
    - [5.1 Monitoring MongoDB](#51-monitoring-mongodb)
    - [5.2 High Availability Setup](#52-high-availability-setup)

This document outlines best practices for MongoDB deployments, covering schema design, system-level considerations, storage optimization, query tuning, and operational aspects.

---

## 1. Schema Design & Data Modeling

### 1.1 Document Structure

- **Follow the Principle of Locality**: Store data that's accessed together in the same document.
- **Balance Document Size**: Keep documents reasonably sized (preferably under 1MB).
- **Use Descriptive Field Names**: Choose clear, consistent field names.
- **Apply Consistent Data Types**: Use the same data type for a field across all documents.

```javascript
// Good document design
{
  "_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "user_id": 12345,
  "name": "John Smith",
  "email": "john@example.com",
  "shipping_addresses": [
    {
      "type": "home",
      "street": "123 Main St",
      "city": "New York",
      "state": "NY",
      "zip": "10001"
    },
    {
      "type": "work",
      "street": "456 Market St",
      "city": "San Francisco",
      "state": "CA",
      "zip": "94105"
    }
  ],
  "payment_methods": [
    {
      "type": "credit",
      "last_four": "1234",
      "expiry": "01/2025"
    }
  ]
}
```

### 1.2 Relationship Patterns

- **Embedding vs. Referencing**: Choose based on access patterns and data size.
- **One-to-Few**: Embed directly within the document.
- **One-to-Many**: Use array of references or child-references.
- **Many-to-Many**: Use references in both directions or a separate relationship collection.

```javascript
// One-to-few (embedded)
{
  "_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "name": "John Smith",
  "addresses": [
    { "street": "123 Main St", "city": "New York" },
    { "street": "456 Market St", "city": "San Francisco" }
  ]
}

// One-to-many (references)
// Parent document
{
  "_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "name": "John Smith"
}
// Child documents
{
  "_id": ObjectId("5f8d0f21b2ca7532b8eee8b3"),
  "user_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "content": "First post"
}
{
  "_id": ObjectId("5f8d0f45b2ca7532b8eee8b4"),
  "user_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "content": "Second post"
}

// Many-to-many (separate collection)
// Users
{
  "_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "name": "John Smith"
}
// Products
{
  "_id": ObjectId("5f8e1c84b2ca7532b8eee8c5"),
  "name": "Premium Widget"
}
// Relationships
{
  "_id": ObjectId("5f8e1d02b2ca7532b8eee8d1"),
  "user_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "product_id": ObjectId("5f8e1c84b2ca7532b8eee8c5"),
  "purchase_date": ISODate("2023-05-10")
}
```

### 1.3 Schema Versioning

- **Document Versioning**: Include a schema version field for evolutionary changes.
- **Handle Migration Gracefully**: Use background processes to update documents.
- **Support Multiple Versions**: Ensure application code can handle different schema versions.

```javascript
// Document with schema version
{
  "_id": ObjectId("5f8d0d55b2ca7532b8eee8b1"),
  "schemaVersion": 2,
  "name": "John Smith",
  "contactInfo": {  // Changed in v2 - previously was flat fields
    "email": "john@example.com",
    "phone": "555-123-4567"
  }
}

// Migration script example
db.users.find({ schemaVersion: { $lt: 2 } }).forEach(function(doc) {
  db.users.updateOne(
    { _id: doc._id },
    {
      $set: {
        schemaVersion: 2,
        contactInfo: {
          email: doc.email,
          phone: doc.phone || ""
        }
      },
      $unset: {
        email: "",
        phone: ""
      }
    }
  );
});
```

### 1.4 Indexing Strategy

- **Index for Query Patterns**: Create indexes that support your application's query patterns.
- **Compound Indexes**: Use compound indexes for queries with multiple conditions.
- **Limit Index Count**: Keep the number of indexes per collection manageable (typically under 10).
- **Consider Index Size**: Be mindful of index memory consumption.

```javascript
// Create appropriate indexes
db.users.createIndex({ "email": 1 }, { unique: true });
db.orders.createIndex({ "user_id": 1, "order_date": -1 });
db.products.createIndex({ "categories": 1, "price": 1 });
```

### 1.5 Handling Large Documents

- **Avoid Unbounded Arrays**: Limit array sizes to prevent document growth.
- **Use Grid FS for Large Binary Data**: Store files > 16MB using GridFS.
- **Consider Data Splitting**: Split very large documents across multiple collections.

```javascript
// GridFS usage example
const bucket = new mongodb.GridFSBucket(db);

// To upload a file
fs.createReadStream('/path/to/file.pdf').
  pipe(bucket.openUploadStream('file.pdf')).
  on('error', function(error) {
    console.error("Error uploading:", error);
  }).
  on('finish', function() {
    console.log('File uploaded');
  });

// To download a file
bucket.openDownloadStreamByName('file.pdf').
  pipe(fs.createWriteStream('/path/to/download/file.pdf')).
  on('error', function(error) {
    console.error("Error downloading:", error);
  }).
  on('finish', function() {
    console.log('File downloaded');
  });
```

## 2. System Level & Resource Management

### 2.1 Hardware Considerations

- **RAM**: Allocate enough RAM to hold working set (frequently accessed data and indexes).
- **CPU**: Multi-core processors benefit MongoDB's concurrency model.
- **Disk**: SSDs strongly recommended; NVMe for high-throughput workloads.
- **RAID**: Use RAID-10 for production environments requiring redundancy.

| Deployment Type | Recommended RAM | CPU | Storage |
|----------------|----------------|-----|---------|
| Development | 4GB+ | 2+ cores | SSD |
| Production (small) | 16GB+ | 4+ cores | SSD/NVMe |
| Production (medium) | 32GB+ | 8+ cores | NVMe |
| Production (large) | 64GB+ | 16+ cores | NVMe, RAID 10 |

### 2.2 Memory Management

- **WiredTiger Cache**: Set to 50% of available RAM (minus 1GB for OS) for dedicated servers.
- **Monitor Working Set**: Ensure frequently accessed data fits in memory.
- **Avoid Swapping**: Configure system to prevent memory swapping.

```yaml
# mongod.conf
storage:
  wiredTiger:
    engineConfig:
      cacheSizeGB: 8  # For a server with 16GB RAM
```

### 2.3 CPU Optimization

- **Connection Pooling**: Use connection pools in application code.
- **Write Concern Tuning**: Balance between throughput and durability.
- **Read Preference Configuration**: Distribute reads to secondary nodes in replicated environments.

```javascript
// Node.js connection pooling example
const client = new MongoClient(uri, {
  maxPoolSize: 100,
  minPoolSize: 10,
  maxIdleTimeMS: 30000
});
```

### 2.4 Disk I/O Tuning

- **Separate Disk Volumes**: Place data, journal, and logs on separate volumes if possible.
- **Disable Access Time Updates**: Use "noatime" mount option for data directories.
- **Appropriate Filesystem**: XFS or ext4 recommended for Linux.
- **I/O Scheduler**: Use "deadline" or "noop" for SSDs.

```bash
# Linux mount options for MongoDB data directory
mount -o noatime,nodiratime /dev/nvme0n1 /var/lib/mongodb

# Set I/O scheduler for SSD
echo 'deadline' > /sys/block/nvme0n1/queue/scheduler
```

### 2.5 Network Configuration

- **Network Bandwidth**: Ensure sufficient bandwidth, especially for replica sets and sharded clusters.
- **Connection Limits**: Adjust system limits for maximum connections.
- **Firewall Rules**: Allow necessary MongoDB ports (27017 default, 27018 for shards, 27019 for config servers).
- **Use TLS/SSL**: Encrypt network traffic in production environments.

```bash
# Adjust Linux connection limits for MongoDB
cat > /etc/security/limits.d/mongodb.conf << EOF
mongodb soft nofile 64000
mongodb hard nofile 64000
mongodb soft nproc 64000
mongodb hard nproc 64000
EOF
```

## 3. Data Organization & Storage

### 3.1 Collection Organization

- **Purpose-Based Collections**: Organize collections based on access patterns.
- **Collection Naming**: Use descriptive, consistent naming conventions.
- **Shard Key Selection**: Choose shard keys that distribute data evenly and localize queries.
- **Time-Based Collections**: Consider time-based collection partitioning for log data.

```javascript
// Time-based collection partitioning example
function getLogCollection() {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const collectionName = `logs_${year}_${month}`;

  return db.collection(collectionName);
}

// Usage
const logCollection = getLogCollection();
await logCollection.insertOne({ timestamp: new Date(), action: "login", user: "john" });
```

### 3.2 Storage Engine Configuration

- **WiredTiger Engine**: Default and recommended for most workloads.
- **Compression Settings**: Choose appropriate compression for your data type.
- **Journal Configuration**: Balance between performance and durability.

```yaml
# mongod.conf
storage:
  wiredTiger:
    collectionConfig:
      blockCompressor: zstd  # Options: none, snappy, zlib, zstd
    engineConfig:
      journalCompressor: snappy
```

### 3.3 Time Series Collections

- **Use Specialized Collections**: For time series data, use time series collections (MongoDB 5.0+).
- **Select Appropriate Granularity**: Choose granularity based on query patterns.
- **Set Expiration Policies**: Implement automatic expiration for time series data.

```javascript
// Create a time series collection
db.createCollection(
  "deviceMetrics",
  {
    timeseries: {
      timeField: "timestamp",
      metaField: "metadata",
      granularity: "minutes"
    },
    expireAfterSeconds: 2592000  // 30 days
  }
);

// Insert data
db.deviceMetrics.insertOne({
  metadata: { device_id: "D1234", device_type: "sensor" },
  timestamp: ISODate("2023-06-10T12:00:00Z"),
  temp: 28.5,
  humidity: 45
});
```

### 3.4 Data Lifecycle Management

- **TTL Indexes**: Create TTL indexes for automatic document expiration.
- **Collection Capping**: Use capped collections for limited-size use cases.
- **Archiving Strategy**: Develop a strategy for archiving cold data.

```javascript
// TTL index for automatic document expiration
db.sessions.createIndex({ "lastActivity": 1 }, { expireAfterSeconds: 3600 }); // Expire after 1 hour

// Create a capped collection (fixed size)
db.createCollection("recentLogs", { capped: true, size: 1048576, max: 1000 });
```

## 4. Query Optimization

### 4.1 Index Utilization

- **Analyze Query Performance**: Use `explain()` to understand query execution.
- **Cover Queries When Possible**: Design indexes that cover common queries.
- **Use Projections**: Only request fields you need.
- **Monitor Index Usage**: Periodically review and remove unused indexes.

```javascript
// Analyze query performance
db.users.find({ age: { $gt: 21 }, status: "active" }).explain("executionStats");

// Create covering index
db.users.createIndex({ age: 1, status: 1, name: 1, email: 1 });

// Query with projection that can use covering index
db.users.find(
  { age: { $gt: 21 }, status: "active" },
  { name: 1, email: 1, _id: 0 }
).hint({ age: 1, status: 1, name: 1, email: 1 });

// Check index usage statistics
db.users.aggregate([{ $indexStats: {} }]);
```

### 4.2 Query Patterns to Avoid

- **Avoid Negation Operators**: Operators like `$ne`, `$not`, and `$nin` typically cannot use indexes efficiently.
- **Limit Regex Queries**: Use anchored regex patterns when possible.
- **Avoid Large Skip Values**: Implement alternative pagination strategies.
- **Beware of In-Memory Sorts**: Large sorts can exceed memory limits.

```javascript
// Instead of this (inefficient)
db.products.find({ category: { $ne: "electronics" } });

// Do this (more efficient)
db.products.distinct("category").then(categories => {
  const nonElectronics = categories.filter(cat => cat !== "electronics");
  return db.products.find({ category: { $in: nonElectronics } });
});

// Efficient regex (anchored at start)
db.users.find({ email: /^john/ }).explain("executionStats");

// Efficient pagination with _id
let lastId = ObjectId("5f8d0d55b2ca7532b8eee8b1");
db.users.find({ _id: { $gt: lastId } }).limit(100);
```

### 4.3 Aggregation Pipeline Optimization

- **Filter Early**: Place `$match` stages early in pipelines to reduce documents.
- **Project Only Needed Fields**: Use `$project` to reduce document size.
- **Use Indexes**: Ensure initial `$match` and `$sort` operations use indexes.
- **Avoid Memory-Intensive Stages**: Be careful with `$group`, `$sort`, and `$unwind` on large data sets.

```javascript
// Optimized aggregation pipeline
db.orders.aggregate([
  // Early filtering reduces documents processed by later stages
  { $match: { orderDate: { $gte: ISODate("2023-01-01") } } },

  // Project only needed fields
  { $project: {
      customer: 1,
      items: 1,
      total: 1,
      _id: 0
  } },

  // Group after reducing the dataset
  { $group: {
      _id: "$customer",
      orderCount: { $sum: 1 },
      totalSpent: { $sum: "$total" }
  } },

  // Sort results (smaller dataset by now)
  { $sort: { totalSpent: -1 } },

  // Limit results
  { $limit: 100 }
]);
```

### 4.4 Read/Write Operation Tuning

- **Write Concern**: Balance between performance and durability.
- **Bulk Operations**: Use bulk write operations for multiple documents.
- **Read Preference**: Configure appropriate read preferences for your workload.
- **Transactions**: Use transactions only when necessary.

```javascript
// Bulk write operations
const operations = [
  { insertOne: { document: { name: "Product 1", price: 29.99 } } },
  { insertOne: { document: { name: "Product 2", price: 39.99 } } },
  { updateOne: {
      filter: { _id: ObjectId("5f8e1c84b2ca7532b8eee8c5") },
      update: { $set: { price: 49.99 } }
  } },
  { deleteOne: { filter: { _id: ObjectId("5f8e1d02b2ca7532b8eee8d1") } } }
];

db.products.bulkWrite(operations);

// Read preference configuration
db.collection.find().readPreference("secondaryPreferred");

// Transaction example
const session = client.startSession();
try {
  session.startTransaction();

  await db.accounts.updateOne(
    { _id: fromAccountId },
    { $inc: { balance: -amount } },
    { session }
  );

  await db.accounts.updateOne(
    { _id: toAccountId },
    { $inc: { balance: amount } },
    { session }
  );

  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
} finally {
  await session.endSession();
}
```

## 5. Monitoring and Operations

### 5.1 Monitoring MongoDB

- **Key Metrics to Monitor**:
  - Query performance and throughput
  - Memory usage (WiredTiger cache)
  - Connection count
  - Replication lag
  - Document operation rates

- **Monitoring Tools**:
  - MongoDB Atlas (cloud monitoring)
  - MongoDB Ops Manager (on-premises)
  - Prometheus with MongoDB exporter
  - mongostat and mongotop utilities

```bash
# Basic monitoring with mongostat
mongostat --port 27017

# Collection-level statistics with mongotop
mongotop --port 27017
```

- **Database Profiler**: Enable for troubleshooting performance issues.

```javascript
// Enable profiler for slow operations
db.setProfilingLevel(1, { slowms: 100 });

// Query profiler data
db.system.profile.find().sort({ ts: -1 }).limit(10);
```

### 5.2 High Availability Setup

- **Replica Sets**: Deploy MongoDB in replica sets for high availability.
- **Proper Election Configuration**: Configure priority and voting members.
- **Read/Write Distribution**: Configure read preferences to distribute load.
- **Monitoring Replication Health**: Track replication lag and status.

```javascript
// Replica set configuration example
rsconf = {
  _id: "rs0",
  members: [
    { _id: 0, host: "mongodb0.example.net:27017", priority: 2 },
    { _id: 1, host: "mongodb1.example.net:27017", priority: 1 },
    { _id: 2, host: "mongodb2.example.net:27017", priority: 0, hidden: true, slaveDelay: 3600 }
  ]
}

rs.initiate(rsconf);

// Check replica set
