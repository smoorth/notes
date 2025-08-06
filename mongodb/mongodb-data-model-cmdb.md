# MongoDB CMDB Data Model Standard

This document outlines a standardized Configuration Management Database (CMDB) data model implemented in MongoDB. It highlights design choices, their pros and cons, and guidelines on why and when to choose one option over another.

## Table of Contents

1. [Overview](#1-overview)
2. [CI Types & Collections](#2-ci-types--collections)
3. [Common Field Conventions & JSON Schema](#3-common-field-conventions--json-schema)
4. [Indexing Strategy](#4-indexing-strategy)
5. [Relationship Modeling](#5-relationship-modeling)
6. [Ensuring Consistent and Unique Data](#6-ensuring-consistent-and-unique-data)
7. [Best Practices](#7-best-practices)
8. [API Integration & Real-Time Workloads](#8-api-integration--real-time-workloads)
9. [Performance Tuning: Sharding and Scaling](#9-performance-tuning-sharding-and-scaling)
10. [Backup & Disaster Recovery](#10-backup--disaster-recovery)
11. [Migration & Versioning](#11-migration--versioning)

## 1. Overview

**Goal**: Centralize and store configuration items (CIs) and their relationships in a flexible, scalable document store.

### Approach Options

- **Separate Collections per CI Type**: One collection each for servers, applications, networks, etc.
- **Single Collection with Discriminator Field**: One `cis` collection where each document has a `type` field.

### Pros & Cons

| Approach | Pros | Cons | When to Use |
|----------|------|------|------------|
| **Separate Collections** | - Clear separation of concerns<br>- Tailored schema validation per CI type<br>- Smaller indexes (per collection) | - More collections to manage<br>- Harder to run cross-type queries without union operations | Large teams with clear domain ownership over CI types. |
| **Single Collection (Discriminator)** | - Easier to query across all CIs<br>- Fewer collections and setup tasks | - Larger, sparse indexes<br>- Complex validation logic per type<br>- Potential for documents with many unused fields | Smaller environments or when CIs share most fields. |

## 2. CI Types & Collections

Standard CI types and their collections:

| CI Type | Collection Name | Purpose |
|---------|----------------|---------|
| Server | `servers` | Physical and virtual machines |
| Application | `applications` | Deployed software components |
| Network | `networks` | Network devices and segments |
| Database | `databases` | DB instances and clusters |
| Service | `services` | Business services |
| Location | `locations` | Data center locations |
| Relationship | `relations` | CI-to-CI relationship graph |

No notable tradeoffs here beyond collection count; refer to Section 1 for design rationale.

## 3. Common Field Conventions & JSON Schema

We enforce structure via JSON Schema validation.

**Recommended Common Fields for All CI Documents:**

| Field         | Type        | Purpose                                         |
|---------------|-------------|-------------------------------------------------|
| `ci_id`       | string      | Unique CI identifier (business key)             |
| `created_at`  | datetime    | Creation timestamp                              |
| `updated_at`  | datetime    | Last modification timestamp                     |
| `created_by`  | string      | User/service that created the CI                |
| `updated_by`  | string      | User/service that last modified the CI          |
| `version`     | integer     | Incremented on each update (optimistic locking) |
| `deleted_at`  | datetime    | Soft delete marker (null if active)             |
| `tenant_id`   | string      | (Optional) Tenant or organization ID            |

> **Tip:** Including `created_by`, `updated_by`, and `version` fields enables robust audit trails and supports optimistic concurrency control. The `deleted_at` field allows for soft deletion and recovery.

| Pros | Cons | When to Use |
|------|------|-------------|
| - Early error detection on invalid CI writes<br>- Self-documenting schemas in the database<br>- Control over required vs optional fields<br>- Built-in audit and change tracking | - Slight write performance overhead due to validation<br>- Schema migrations can be more complex to roll out in prod<br>- More fields to maintain | - Always for critical environments where CI integrity and traceability matter.<br>- Consider moderate or off validation levels in development or POC clusters. |

```javascript
// Example: strict validation on servers collection
db.createCollection("servers", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ci_id", "name", "type", "created_at", "updated_at", "version"],
      properties: {
        ci_id: { bsonType: "string" },
        name: { bsonType: "string" },
        type: { bsonType: "string" },
        created_at: { bsonType: "date" },
        updated_at: { bsonType: "date" },
        created_by: { bsonType: "string" },
        updated_by: { bsonType: "string" },
        version: { bsonType: "int" },
        deleted_at: { bsonType: ["date", "null"] },
        tenant_id: { bsonType: "string" }
        // ...other CI-specific fields...
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});
```

## 4. Indexing Strategy

MongoDB indexing offers performance improvements at the cost of storage and write overhead.

| Index Type | Pros | Cons | Use Case |
|------------|------|------|----------|
| Unique Index on `ci_id` | Guarantees no duplicates, fast lookups | Additional storage; write penalty | Always recommended for CI identity |
| Compound Index on `type` + `status` | Efficient filtering when querying by type and status | Index size grows with cardinality | Dashboards and filtered CI listings |
| Text Index on `name` + `tags` | Full-text search across multiple fields | Cannot mix with other text indexes; slower indexing | User-driven search interfaces |
| TTL Index on `expireAt` | Automatic removal of temporary/ephemeral CIs | Irrecoverable deletion; limited to date fields | Ephemeral testing CIs or temporary resources |

## 5. Relationship Modeling

Two main approaches for modeling relationships between CIs:

### A. Referencing (Graph Collection)

**Structure**: Dedicated `relations` collection with `from_ci`, `to_ci`, and `relation_type`.

**Pros**: Flexible graph traversal; independent of CI document size.

**Cons**: Requires additional joins (`$lookup`) or multiple queries; writes require two operations (CI + relation).

**When to Use**: Complex networks of dependencies or highly connected CIs.

### B. Embedding (Array of References or Subdocuments)

**Structure**: Within each CI document, an array field (e.g., `depends_on: [ObjectId,...]`).

**Pros**: Single-document reads; simpler queries for direct dependencies.

**Cons**: Potential document growth beyond 16 MB limit; less flexible for many-to-many relations.

**When to Use**: Limited, predictable number of relationships, and performance-critical lookup paths.

**Relationship Example Document (`relations` collection):**

```json
{
  "from_ci": "SVR-0001",
  "to_ci": "APP-1234",
  "relation_type": "hosts",
  "created_at": "2024-06-01T12:00:00Z",
  "created_by": "automation-bot",
  "metadata": {
    "description": "Server hosts the application"
  }
}
```

> **Note:** Use `ci_id` or MongoDB `_id` as references. Consider enforcing referential integrity at the application layer, as MongoDB does not support foreign keys.

## 6. Ensuring Consistent and Unique Data

Keeping your data clean and free of duplicates is important for any database. Here are some simple ways to make sure your MongoDB CMDB stays consistent and avoids duplicate records.

### Why Uniqueness Matters

If you have two records for the same server or application, it can cause confusion, errors, and wasted time. For example, if "web-01" is listed twice, you might update the wrong one or miss important changes.

### How to Avoid Duplicate Data

**1. Unique Indexes (Database Rules)**
Tell MongoDB that certain fields must be unique. For example, every `ci_id` (like a serial number) must be different.

*Example:*
```javascript
// Make sure no two servers have the same ci_id
db.servers.createIndex({ ci_id: 1 }, { unique: true });
```

**2. Check Before You Add (Application Logic)**
Before adding a new item, check if it already exists.

*Example:*
- Before adding a server with `ci_id: "SVR-0001"`, search for that ID first. If it exists, update it instead of adding a new one.

**3. Use Upserts (Update or Insert in One Step)**
An "upsert" means: if the item exists, update it; if not, add it.

*Example:*
```javascript
db.servers.updateOne(
  { ci_id: "SVR-0001" },
  { $set: { name: "web-01", type: "server" } },
  { upsert: true }
);
```

**4. Reference, Don’t Copy**
If two items are related, store the ID of the other item instead of copying all its details.
*Example:*
A server document can have a field like `"application_id": "APP-1234"` instead of copying the whole application record.

**5. Normalize Data**
Keep information in one place. For example, store a server's IP address only in the server record, not in multiple places.

**6. Merge on Import**
When importing data, match on unique fields (like `ci_id`) and update existing records instead of creating new ones.

**7. Monitor for Duplicates**
Run regular checks to find duplicates.
*Example:*
```javascript
// Find ci_id values that appear more than once
db.servers.aggregate([
  { $group: { _id: "$ci_id", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
]);
```

### Summary Table

| What to Do                | Why It Helps                        | Example                                  |
|---------------------------|-------------------------------------|------------------------------------------|
| Use unique indexes        | Stops duplicates at the database    | Unique `ci_id` for each server           |
| Check before adding       | Prevents accidental duplicates      | Search for `ci_id` before insert         |
| Use upserts               | Handles add-or-update in one step   | `updateOne(..., { upsert: true })`       |
| Reference, don’t copy     | Keeps data in sync, saves space     | Store `application_id` not full details  |
| Normalize data            | Avoids conflicting information      | IP address only in one place             |
| Merge on import           | Keeps database tidy                 | Match on `ci_id` during bulk load        |
| Monitor for duplicates    | Catch problems early                | Aggregation query for duplicate `ci_id`  |

> **Tip:** The best way to avoid duplicates is to use unique indexes in MongoDB, but also check in your application before adding new data.

### In Plain Language

- **Always give each item a unique ID.**
- **Let MongoDB enforce uniqueness for you.**
- **Don’t add the same thing twice—check first!**
- **If you need to update, use upsert so you don’t accidentally create a copy.**
- **Keep related data linked by ID, not by copying everything.**
- **Check your database now and then for duplicates, just in case.**

### Things to Avoid

- **Don’t skip unique indexes:** Without them, duplicates can sneak in even if you’re careful.
- **Don’t copy the same information into multiple places:** This leads to conflicting data and makes updates harder.
- **Don’t ignore errors about duplicate keys:** Fix the cause instead of just deleting one of the records.
- **Don’t use natural keys (like names or emails) as the only unique identifier:** These can change or be reused; always use a generated unique ID.
- **Don’t bulk import data without checking for existing records:** This is a common way duplicates are created.
- **Don’t rely only on application checks:** Bugs or race conditions can still create duplicates if the database isn’t enforcing uniqueness.
- **Don’t embed large or frequently changing related documents:** Reference by ID instead, to avoid data getting out of sync.

> **Tip:** If you’re unsure, always ask: “Could this create a duplicate or conflicting record?” If yes, rethink your approach.

## 7. Best Practices

| Practice | Benefit | Caveat |
|----------|---------|--------|
| Central Schema Repository (Git) | Versioned, peer-reviewed schema updates | Requires governance process |
| CI/CD for Schema & Index Deployments | Automated, consistent changes across environments | Investment in tooling |
| Naming Conventions (lower_snake_case) | Predictability, easier automation | Enforce via linter or pre-commit hooks |
| Change History & Audit Logs | Track CI evolution; support compliance | Storage overhead; design of audit schema |
| Field-level Security & Multi-tenancy | Enforce access control and data isolation | Requires application logic and careful schema design |
| Aggregation Pipelines for Reporting | Real-time insights without ETL | Complex pipelines can be hard to optimize |

## 8. API Integration & Real-Time Workloads

In scenarios where an API layer sits in front of the CMDB and the database state drives rapid workload triggering (e.g., automated deployments, scaling events), you'll want to optimize for low‑latency reads, consistent state, and efficient updates.

### A. Data Modeling Adjustments

| Consideration | Technique | Pros | Cons |
|---------------|-----------|------|------|
| Read‑Optimized Documents | Embed frequently accessed fields (e.g., current state, parameters) directly in the CI document | Fewer lookups, single‑document fetch | Document size growth, update hotspots |
| Precomputed Materialized Views | Create dedicated "view" collections or fields containing aggregated or joined data (via change‑streams/ETL) | Ultra‑fast queries for API responses | Extra storage and write complexity |
| Versioned Configurations | Store each state change as a new version or snapshot (e.g., versions subcollection) | Complete history, safe rollbacks | Additional storage, more complex reads for latest state |

### B. Indexing & Caching

- **Hot‑path Indexes**: Build single‑field or compound indexes on API query patterns (e.g., `ci_id` + `state`), and consider covering indexes to return only projected fields.
- **In‑Memory Caching**: Use Redis or in‑app caches for the most frequently read configurations; invalidate on `updated_at` changes.
- **TTL or LRU Caches**: For ephemeral workloads, set short‑lived caches to reduce database load while ensuring fresh state.

### C. Concurrency & Consistency

- **Optimistic Concurrency**: Add a version or etag field. On API updates, require the matching version to detect conflicting writes.
- **Transactions**: Where multiple CIs or relations must update atomically, use multi‑document transactions (MongoDB 4.0+).
- **Change Streams & Eventing**: Leverage MongoDB change streams to trigger downstream jobs or event handlers when a CI's state changes.

### D. API Best Practices

- **Idempotent Endpoints**: Ensure PUT and PATCH operations can safely retry without side‑effects.
- **Bulk Writes**: For large state updates, use `bulkWrite` with ordered/unordered operations for efficiency.
- **Field Projections**: Return only necessary fields to minimize payload size and serialization overhead.
- **Error Handling & Backoff**: Implement retries with exponential backoff on transient failures (e.g., network partitions).

## 9. Performance Tuning: Sharding and Scaling

As your CMDB grows to millions of configuration items, single-server performance may degrade. Here's how to scale effectively with MongoDB's distributed architecture.

### A. Sharding Strategy

Sharding distributes your data across multiple servers, allowing horizontal scaling.

| Shard Key Selection | Pros | Cons | Recommendation |
|---------------------|------|------|----------------|
| `ci_id` | Even distribution for sequential IDs | Poor for range-based queries | Good for workloads with random access by ID |
| `tenant_id` + `ci_id` | Data locality by tenant | Potential for "hot" tenants | Best for multi-tenant CMDBs |
| Hashed `ci_id` | Excellent distribution | Cannot do efficient range queries | Use when data access is primarily by exact ID |

**Example: Setting up a sharded collection:**

```javascript
// Step 1: Enable sharding on the database
sh.enableSharding("cmdb")

// Step 2: Create indexes to support the shard key
db.servers.createIndex({ "tenant_id": 1, "ci_id": 1 })

// Step 3: Shard the collection
sh.shardCollection("cmdb.servers", { "tenant_id": 1, "ci_id": 1 })
```

### B. Working with Large Datasets

| Technique | When to Use | Example |
|-----------|------------|---------|
| Chunking Aggregations | For operations on millions of records | Process in batches using `$match` with range queries |
| Projection | When documents have many fields | `db.servers.find({}, {name: 1, status: 1})` |
| Read Preference | For analytics workloads | `db.servers.find().readPref("secondary")` |
| Time-Series Collections | For temporal metrics and events | Use for CI state history or metric collection |
| Atlas Data Lake | For cold/historical data | Tier old CI versions to cheaper storage |

### C. Monitoring and Optimization

- **Profile slow queries**: `db.setProfilingLevel(1, { slowms: 100 })`
- **Index utilization**: `db.servers.aggregate([{$indexStats:{}}])`
- **Index size impact**: `db.servers.stats().indexSizes`
- **Working Set**: Ensure frequently accessed data fits in RAM
- **Query targeting**: Use `explain()` to verify queries use indexes

> **Tip:** In large CMDBs, avoid unbounded table scans. Every query should use an index, especially in production.

## 10. Backup & Disaster Recovery

Protecting your CMDB data is crucial as it often becomes a central source of truth for your infrastructure.

### A. Backup Strategies

| Backup Method | Pros | Cons | When to Use |
|---------------|------|------|------------|
| MongoDB Atlas Continuous Backup | Point-in-time recovery, minimal impact | Subscription cost | Production environments |
| Mongodump | Simple, scriptable | Performance impact, point-in-time only | Small datasets, dev environments |
| Filesystem Snapshots | Low overhead, fast | Storage cost, requires specialized knowledge | Large datasets with snapshot-capable storage |
| Replica Set Snapshot | No production impact | Requires extra capacity | Critical systems needing minimal impact |

**Example: Mongodump with retention policy:**

```bash
# Daily backup with 7-day retention
mongodump --uri="mongodb://your-cmdb-host:27017" --db=cmdb --out=/backup/cmdb-$(date +%Y%m%d)
find /backup -name "cmdb-*" -type d -mtime +7 -exec rm -rf {} \;
```

### B. Recovery Time Objectives (RTO)

| RTO Strategy | Implementation | Required Resources |
|--------------|----------------|-------------------|
| < 15 minutes | Multi-region replica sets with automated failover | 5+ nodes across 3+ regions |
| < 1 hour | Single-region replica set with automated failover | 3+ nodes in one region |
| < 24 hours | Regular backups with manual restore procedure | Backup storage + restore procedure |

### C. Recovery Testing

- **Quarterly recovery drills**: Restore to test environment from production backup
- **Failover testing**: Simulate primary node failures to verify automatic failover
- **Data integrity checks**: Validate restored data with aggregation queries

> **Important:** Document your recovery procedures and test them regularly. An untested backup is not a reliable backup.

## 11. Migration & Versioning

Evolving your CMDB schema safely requires planning for backward compatibility and seamless transitions.

### A. Schema Evolution Patterns

| Pattern | Description | Best Used For |
|---------|-------------|--------------|
| Expansion | Add new fields without removing old ones | Most schema changes |
| Builder | Create new collection, migrate data, then switch | Breaking changes |
| Versioned Documents | Include schema version in documents | Complex multi-step migrations |

### B. Managing Schema Changes

**Progressive Migration Approach:**

1. **Add support for new schema in application code**
   - Make code read both old and new formats
   - Write in new format

2. **Update existing documents through background job**
   ```javascript
   // Background migration job
   db.servers.find({schemaVersion: {$lt: 2}})
     .forEach(doc => {
       // Transform document
       doc.ipAddress = doc.ip; // New field name
       doc.schemaVersion = 2;
       db.servers.updateOne(
         {_id: doc._id},
         {$set: doc}
       );
     });
   ```

3. **Remove support for old format after completion**

### C. Breaking Changes

When you must make incompatible changes:

| Approach | Pros | Cons | Example Use Case |
|----------|------|------|------------------|
| Dual-write period | No downtime | Complex application logic | Renaming or restructuring fields |
| Read-only maintenance window | Clean cutover | Service interruption | Major data model changes |
| Blue-green deployment | Minimal risk | Resource intensive | Complete CMDB redesign |

### D. Schema Version Control

- **Document schema history in version control**: Store JSON Schema definitions in Git
- **Include migration scripts in same repository**: Pair schema changes with migration code
- **Automate schema upgrades in CI/CD pipeline**: Test migrations on copies of production data

> **Best Practice:** Always provide a downgrade path for any schema change. This allows you to roll back if problems are discovered after deployment.

### E. Field Deprecation Process

1. Mark field as deprecated in documentation
2. Add logging when deprecated fields are accessed
3. After monitoring period, stop writing to deprecated field
4. Eventually remove field from schema and application logic

```javascript
// Example schema with deprecated field marker
db.createCollection("servers", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        // ... existing fields ...
        ip: {
          bsonType: "string",
          description: "DEPRECATED: Use ipAddress instead"
        },
        ipAddress: {
          bsonType: "string"
        }
      }
    }
  }
});
```

> **Advice:** For critical CMDBs, never delete fields without a deprecation period. This prevents breaking integrations that might still rely on the old schema.
