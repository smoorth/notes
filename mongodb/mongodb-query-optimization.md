# MongoDB Query Optimization

## Introduction

MongoDB's document database architecture requires specific optimization strategies to achieve optimal query performance. This guide covers key techniques for writing efficient queries, indexing strategies, and system-level optimizations that will significantly improve query response times.

## Table of Contents

- [MongoDB Query Optimization](#mongodb-query-optimization)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Query Structure Optimization](#query-structure-optimization)
    - [Basic Query Principles](#basic-query-principles)
  - [Schema Design for Query Performance](#schema-design-for-query-performance)
    - [Document Organization](#document-organization)
  - [Indexing Strategies](#indexing-strategies)
  - [Field and Operator Selection](#field-and-operator-selection)
  - [Understanding the Query Planner](#understanding-the-query-planner)

## Query Structure Optimization

### Basic Query Principles

1. **Project Only the Fields You Need**

   Only request the fields your application needs to reduce network transfer and memory usage:

   ```javascript
   // Inefficient (returns all fields)
   db.users.find({ status: "active" })

   // Efficient (returns only needed fields)
   db.users.find({ status: "active" }, { name: 1, email: 1, lastLogin: 1 })
   ```

2. **Use Query Predicates Properly**

   Ensure your query predicates leverage indexes effectively:

   ```javascript
   // Inefficient (can't use index effectively with $ne)
   db.products.find({ category: { $ne: "electronics" } })

   // More efficient (uses index)
   db.products.find({ category: "clothing" })
   ```

3. **Limit Results for Pagination**

   Use limit() and skip() for pagination to avoid large result sets:

   ```javascript
   // Efficiently limit results
   db.products.find().sort({ createDate: -1 }).limit(20).skip(40)
   ```

4. **Use Covered Queries When Possible**

   Design queries that can be satisfied entirely from indexes:

   ```javascript
   // With an index on {email: 1, name: 1}
   db.users.find(
     { email: "user@example.com" },
     { _id: 0, name: 1, email: 1 }
   )
   ```

## Schema Design for Query Performance

### Document Organization

1. **Embed Related Data**

   For one-to-few relationships, embedding documents improves read performance:

   ```javascript
   // Better for frequent reads (embedded approach)
   {
     "_id": ObjectId("5ad88534e3832320ae471fd5"),
     "name": "John Smith",
     "addresses": [
       { "type": "home", "street": "123 Main St", "city": "New York", "state": "NY" },
       { "type": "work", "street": "456 Market St", "city": "San Francisco", "state": "CA" }
     ]
   }

   // Better for frequent updates to addresses (normalized approach)
   // User document
   { "_id": ObjectId("5ad88534e3832320ae471fd5"), "name": "John Smith" }

   // Addresses collection
   { "userId": ObjectId("5ad88534e3832320ae471fd5"), "type": "home", "street": "123 Main St", "city": "New York", "state": "NY" }
   { "userId": ObjectId("5ad88534e3832320ae471fd5"), "type": "work", "street": "456 Market St", "city": "San Francisco", "state": "CA" }
   ```

2. **Avoid Deep Nesting**

   Keep document nesting to a reasonable level to avoid complexity:

   ```javascript
   // Too deeply nested (avoid)
   {
     "name": "Product",
     "categories": {
       "main": {
         "name": "Electronics",
         "subcategories": {
           "level1": {
             "name": "Computers",
             "subcategories": {
               "level2": { "name": "Laptops" }
             }
           }
         }
       }
     }
   }

   // Better approach (flatter structure)
   {
     "name": "Product",
     "categoryPath": ["Electronics", "Computers", "Laptops"],
     "mainCategory": "Electronics",
     "subCategory": "Computers",
     "leafCategory": "Laptops"
   }
   ```

## Indexing Strategies

1. **Create Selective Indexes**

   Indexes on fields with higher cardinality provide better performance:

   ```javascript
   // Better selectivity (many distinct values)
   db.users.createIndex({ email: 1 })

   // Worse selectivity (few distinct values)
   db.users.createIndex({ active: 1 })
   ```

2. **Compound Indexes for Query Patterns**

   Order matters in compound indexes - match your query patterns:

   ```javascript
   // For queries that filter on status then sort by date
   db.orders.createIndex({ status: 1, orderDate: -1 })

   // The corresponding efficient query
   db.orders.find({ status: "pending" }).sort({ orderDate: -1 })
   ```

3. **Use Covered Indexes**

   Design indexes that can fully satisfy queries:

   ```javascript
   // Create index to cover the query
   db.products.createIndex({ category: 1, name: 1, price: 1 }, { _id: 0 })

   // Query that can be covered by the index
   db.products.find(
     { category: "electronics" },
     { name: 1, price: 1, _id: 0 }
   )
   ```

4. **Avoid Indexing Low-Selectivity Fields**

   Don't create indexes on fields with few distinct values unless they're always used together with other fields:

   ```javascript
   // Not very useful on its own (if most users are active)
   db.users.createIndex({ active: 1 })

   // More useful compound index
   db.users.createIndex({ active: 1, lastLoginDate: -1 })
   ```

## Field and Operator Selection

1. **Avoid Negation Operators When Possible**

   Operators like `$ne`, `$not`, and `$nin` are less efficient:

   ```javascript
   // Less efficient (can't use index effectively)
   db.inventory.find({ qty: { $ne: 20 } })

   // More efficient alternatives (if possible)
   db.inventory.find({ qty: { $lt: 20, $gt: 20 } })
   ```

2. **Use Equality Operators First in Compound Indexes**

   Equality conditions on the prefix fields of a compound index are most efficient:

   ```javascript
   // Index
   db.products.createIndex({ category: 1, price: 1 })

   // Most efficient query (equality on first field)
   db.products.find({ category: "electronics", price: { $gt: 100 } })

   // Less efficient query
   db.products.find({ price: { $gt: 100 }, category: "electronics" })
   ```

3. **Avoid Large Arrays in Documents**

   Arrays with hundreds or thousands of elements slow down queries and updates:

   ```javascript
   // Problematic (large array)
   {
     "_id": ObjectId("..."),
     "productName": "Popular Widget",
     "tags": [ /* thousands of tags */ ]
   }

   // Better approach (separate collection)
   // Products collection
   { "_id": ObjectId("..."), "productName": "Popular Widget" }

   // Tags collection
   { "productId": ObjectId("..."), "tag": "durable" }
   { "productId": ObjectId("..."), "tag": "metal" }
   // ...etc
   ```

## Understanding the Query Planner

MongoDB uses a query optimizer to select the most efficient
