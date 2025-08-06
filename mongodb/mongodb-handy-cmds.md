# MongoDB Handy Commands

## Table of Contents

- [MongoDB Handy Commands](#mongodb-handy-commands)
  - [Table of Contents](#table-of-contents)
  - [MongoDB Basics](#mongodb-basics)
    - [What is MongoDB?](#what-is-mongodb)
    - [Key Concepts Simplified](#key-concepts-simplified)
    - [How MongoDB Works](#how-mongodb-works)
    - [Tips for Beginners](#tips-for-beginners)
    - [Common Issues to Watch For](#common-issues-to-watch-for)
  - [Listing Collections, Databases, Users and Roles](#listing-collections-databases-users-and-roles)
  - [User and Role Management](#user-and-role-management)
  - [Data Manipulation (CRUD Operations)](#data-manipulation-crud-operations)
  - [Schema and Structure Inspection](#schema-and-structure-inspection)
  - [Backup, Restore, and Migration](#backup-restore-and-migration)
  - [Network Connectivity and Troubleshooting](#network-connectivity-and-troubleshooting)

## MongoDB Basics

### What is MongoDB?

- MongoDB is a **NoSQL database** that stores data differently from traditional SQL databases (like MySQL or PostgreSQL)
- Instead of tables with rows and columns, MongoDB uses **collections** of **documents**
- MongoDB is designed to be flexible, scalable, and handle large amounts of data

### Key Concepts Simplified

- **Document**: A piece of data stored as key-value pairs (like a JSON file). Think of it as a single record.
- **Collection**: A group of related documents (similar to a folder of files or a spreadsheet). Collections don't require all documents to have the same fields.
- **Database**: A container for collections (like a filing cabinet). One MongoDB server can have many databases.
- **BSON**: The format MongoDB uses to store documents. It's like JSON but can handle more data types and is optimized for storage.

### How MongoDB Works

- User information is stored in the `admin` database, specifically in collections called `system.users` and `system.roles`
- MongoDB keeps frequently used data in memory (RAM) for faster access using the **WiredTiger** storage engine
- For handling lots of data, MongoDB can spread data across multiple servers (**sharding**) and make copies for backup (**replication**)
- **Indexes** help MongoDB find data quickly, just like an index in a book. Without indexes, MongoDB has to check every document one by one

### Tips for Beginners

- Create **compound indexes** when you frequently search using multiple fields together
- Be careful with **arrays in documents** that might grow very large over time
- Use **projections** to get only the fields you need (like asking for just a person's name rather than all their details)
- For adding lots of data at once, use **bulk operations** instead of adding one document at a time
- Every document has a unique **_id** field that includes a timestamp showing when it was created
- Even in testing environments, use **multiple MongoDB servers** (called replica sets) to better understand how production will work

### Common Issues to Watch For

- Documents have a **size limit of 16MB** (you can't store very large files directly in MongoDB)
- Search results (**cursors**) disappear after 10 minutes if you don't use them
- Joining data from different collections (**$lookup**) can slow things down significantly
- When logging in, you must use the same database where your user account was created
- MongoDB typically uses port **27017** for connections (good to know for troubleshooting connection problems)

## Listing Collections, Databases, Users and Roles

| Command | Description |
|---------|-------------|
| `db.runCommand({ connectionStatus: 1 })` | Show current user and authentication status |
| `db.getUsers()` | List all users of the current database |
| `db.getRoles()` | List all roles in the current database |
| `show dbs` | Show all databases |
| `show collections` | List all collections in the current database |
| `db.getCollectionNames()` | List all collections in the current database (alternative) |
| `db.getCollectionInfos()` | Get detailed information about collections |
| `db.getCollection('collection_name').stats()` | Get statistics for a collection |
| `show users` | Show all users of the current database |
| `db.serverStatus()` | Get server status information/errors |
| `use admin; db.system.users.find()` | List all users across all databases |
| `db.getCollection('collection_name').getIndexes()` | List indexes for a collection |
| `db.printCollectionStats()` | Print statistics for all collections |
| `use database_name` | Switch to a database |
| `exit` | Exit the MongoDB shell |

## User and Role Management

| Command | Description |
|---------|-------------|
| `db.createUser({user: "username", pwd: "password", roles: ["readWrite", "dbAdmin"]})` | Create a new user |
| `db.dropUser("username")` | Remove a user |
| `db.updateUser("username", {roles: ["read"]})` | Update user roles |
| `db.grantRolesToUser("username", ["readWrite"])` | Grant roles to a user |
| `db.revokeRolesFromUser("username", ["readWrite"])` | Revoke roles from a user |
| `db.createRole({role: "myRole", privileges: [{resource: {db: "database_name", collection: "collection_name"}, actions: ["find", "update"]}], roles: []})` | Create a custom role |
| `db.dropRole("roleName")` | Remove a role |
| `db.grantPrivilegesToRole("roleName", [{resource: {db: "database_name", collection: "collection_name"}, actions: ["insert"]}])` | Grant privileges to a role |
| `db.revokePrivilegesFromRole("roleName", [{resource: {db: "database_name", collection: "collection_name"}, actions: ["insert"]}])` | Revoke privileges from a role |
| `db.auth("username", "password")` | Authenticate as a user |
| `db.changeUserPassword("username", "newpassword")` | Change a user's password |
| `use admin; db.createUser({user: "adminUser", pwd: "password", roles: ["userAdminAnyDatabase"]})` | Create admin user |
| `use admin; db.createUser({user: "readOnlyUser", pwd: "password", roles: [{role: "read", db: "database_name"}]})` | Create read-only user |
| `db.getRole("roleName", {showPrivileges: true})` | Show role details and privileges |

## Data Manipulation (CRUD Operations)

| Command | Description |
|---------|-------------|
| `db.collection_name.insertOne({field1: "value1", field2: "value2"})` | Insert a single document |
| `db.collection_name.insertMany([{field1: "value1"}, {field1: "value2"}])` | Insert multiple documents |
| `db.collection_name.updateOne({filter_field: "value"}, {$set: {field1: "new_value"}})` | Update a single document |
| `db.collection_name.updateMany({filter_field: "value"}, {$set: {field1: "new_value"}})` | Update multiple documents |
| `db.collection_name.deleteOne({filter_field: "value"})` | Delete a single document |
| `db.collection_name.deleteMany({filter_field: "value"})` | Delete multiple documents |
| `db.collection_name.find({filter_field: "value"})` | Query documents |
| `db.collection_name.findOne({filter_field: "value"})` | Query a single document |
| `db.collection_name.find({filter_field: "value"}).sort({sort_field: 1})` | Query with sorting (1 for ascending, -1 for descending) |
| `db.collection_name.find({filter_field: "value"}).limit(10)` | Limit query results |
| `db.collection_name.find({filter_field: "value"}).skip(10)` | Skip results (pagination) |
| `db.collection_name.countDocuments({filter_field: "value"})` | Count documents matching a filter |
| `db.collection_name.distinct("field_name", {filter_field: "value"})` | Get distinct values |
| `db.collection_name.drop()` | Delete a collection |
| `db.dropDatabase()` | Delete the current database |
| `db.collection_name.createIndex({field_name: 1})` | Create an index |
| `db.collection_name.find({field: {$gt: 100}})` | Find documents where field > 100 |
| `db.collection_name.aggregate([{$match: {field: "value"}}, {$group: {_id: "$group_field", total: {$sum: "$amount"}}}])` | Aggregate data |
| `db.collection_name.bulkWrite([{insertOne: {document: {field: "value"}}}, {updateOne: {filter: {field: "value"}, update: {$set: {field: "new_value"}}}}])` | Perform bulk operations |
| `db.collection_name.find({field: {$regex: "pattern", $options: "i"}})` | Find using regex (case-insensitive) |
| `db.collection_name.findOneAndUpdate({filter_field: "value"}, {$set: {field1: "new_value"}}, {returnNewDocument: true})` | Update and return document |
| `db.collection_name.watch()` | Watch for changes to a collection (change streams) |

## Schema and Structure Inspection

| Command | Description |
|---------|-------------|
| `db.collection_name.findOne()` | Show a sample document with its structure |
| `db.collection_name.find().limit(5).pretty()` | Show 5 sample documents with formatted output |
| `Object.keys(db.collection_name.findOne())` | List all fields in a sample document |
| `db.collection_name.aggregate([{$sample: {size: 1}}]).pretty()` | Get a random document sample with formatting |
| `db.collection_name.find().forEach(function(doc) { print(Object.keys(doc)) })` | Print field names from multiple documents |
| `db.getCollectionInfos()` | Get detailed information about collections |
| `db.collection_name.stats()` | Get statistics about a collection including storage and index details |
| `db.collection_name.find({}, {_id: 0}).sort({_id: -1}).limit(1).pretty()` | Show most recent document (excludes _id field) |
| `db.collection_name.aggregate([{$project: {arrayLength: {$size: "$array_field"}}}])` | Check the size of arrays in documents |
| `db.collection_name.find({field_name: {$exists: true}}).count()` | Count documents having a specific field |
| `db.collection_name.findOne(); db.collection_name.findOne({_id: ObjectId("some_id")}, {field_to_examine: 1})` | Examine specific field in a document |
| `db.collection_name.aggregate([{$group: {_id: "$field_name"}}])` | List all unique values for a field |
| `db.collection_name.validate({full: true})` | Validate collection data and structure with detailed output |
| `db.collection_name.aggregate([{$project: {allFields: {$objectToArray: "$$ROOT"}}}, {$unwind: "$allFields"}, {$group: {_id: "$allFields.k"}}])` | List all field names that exist across all documents |
| `db.collection_name.aggregate([{$sample: {size: 100}}, {$project: {keys: {$objectToArray: "$$ROOT"}}}, {$unwind: "$keys"}, {$group: {_id: "$keys.k", count: {$sum: 1}}}, {$sort: {count: -1}}])` | Show field names and how frequently they appear |
| `db.collection_name.aggregate([{$project: {document: "$$ROOT"}}, {$replaceRoot: {newRoot: {_id: "$_id", fieldTypes: {$objectToArray: {$mapValues: {input: "$document", as: "value", in: {$type: "$$value"}}}}}}}, {$unwind: "$fieldTypes"}, {$group: {_id: {field: "$fieldTypes.k", type: "$fieldTypes.v"}, count: {$sum: 1}}}, {$sort: {"_id.field": 1}}])` | List fields with their data types |
| `db.collection_name.aggregate([{$match: {}}, {$limit: 50}, {$project: {nested_field: 1}}, {$unwind: {path: "$nested_field", preserveNullAndEmptyArrays: true}}])` | Explore elements in a nested array field |
| `db.collection_name.find().sort({$natural: -1}).limit(1).pretty()` | Show the most recently inserted document |
| `db.runCommand({dbStats: 1})` | Get database statistics including total collections and indexes |
| `db.adminCommand({listDatabases: 1})` | List all databases with size information |
| `db.getCollectionInfos({name: "collection_name"})` | Get detailed metadata for a specific collection |

## Backup, Restore, and Migration

| Command | Description |
|---------|-------------|
| `mongodump --uri="mongodb://username:password@host:port/dbname"` | Backup a specific database |
| `mongodump --uri="mongodb://username:password@host:port/" --out=/path/to/backup` | Backup all databases |
| `mongorestore --uri="mongodb://username:password@host:port/" /path/to/backup` | Restore all databases from a backup |
| `mongorestore --uri="mongodb://username:password@host:port/dbname" /path/to/backup/dbname` | Restore a specific database from a backup |
| `mongoexport --uri="mongodb://username:password@host:port/dbname" --collection=collection_name --out=/path/to/file.json` | Export a collection to a JSON file |
| `mongoimport --uri="mongodb://username:password@host:port/dbname" --collection=collection_name --file=/path/to/file.json` | Import a JSON file into a collection |
| `mongodump --archive=/path/to/backup.archive --gzip` | Create a compressed backup archive |
| `mongorestore --archive=/path/to/backup.archive --gzip` | Restore from a compressed backup archive |
| `mongo --eval "db.copyDatabase('source_db', 'target_db', 'source_host')" --host target_host` | Migrate a database from one server to another |

## Network Connectivity and Troubleshooting

| Command | Description |
|---------|-------------|
| `ping <mongodb_host>` | Test basic network connectivity to the MongoDB server (ICMP ping) |
| `telnet <mongodb_host> 27017` | Check if the MongoDB port is open and accepting connections |
| `Test-NetConnection -ComputerName <mongodb_host> -Port 27017` | (Windows PowerShell) Test TCP connectivity to MongoDB port |
| `mongo --host <mongodb_host> --port 27017` | Attempt to connect to MongoDB using the shell (shows if connection/auth works) |
| `netstat -an \| find "27017"` | (On server) Check if MongoDB is listening on the expected port |
| `ss -tulnp \| grep 27017` | (Linux) Show processes listening on MongoDB port |
| `mongostat --host <mongodb_host> --port 27017` | Monitor MongoDB server status and connectivity in real time |
| `mongotop --host <mongodb_host> --port 27017` | Monitor MongoDB read/write activity and connectivity |

> **Note:**
> These commands are run from your client machine or the MongoDB server's terminal, not from the MongoDB shell itself. Replace `<mongodb_host>` with your server's hostname or IP address.
