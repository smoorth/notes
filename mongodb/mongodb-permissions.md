# MongoDB Permission Management

## Overview of Security Models

MongoDB implements a comprehensive security model with role-based access control (RBAC), authentication mechanisms, and encryption options. This guide covers proper permission management for MongoDB deployments.

## Authentication Methods

| Authentication Method | Description | Best Used For |
|---------|-------------|---------|
| SCRAM | Salted Challenge Response Authentication Mechanism | Default method for most deployments |
| x.509 | Certificate-based authentication | Enterprise environments, client-server authentication |
| LDAP | Lightweight Directory Access Protocol | Enterprise environments with existing LDAP directory |
| Kerberos | Network authentication protocol | Enterprise environments with Kerberos infrastructure |

## Role-Based Access Control (RBAC)

MongoDB's access control system is based on roles that grant privileges to perform actions on resources.

### Built-in Roles

| Role Category | Examples | Description |
|--------------|----------|-------------|
| Database User | `read`, `readWrite` | Access to read/write data |
| Database Administration | `dbAdmin`, `userAdmin` | Administrative tasks on databases |
| Cluster Administration | `clusterAdmin`, `clusterManager` | Administrative tasks across the entire cluster |
| Backup/Restore | `backup`, `restore` | Data backup and restoration operations |
| Super User | `root` | All privileges on all resources |
| All-Database | `readAnyDatabase`, `readWriteAnyDatabase` | Access across all databases |

### Role Management Commands

| Command | Description | Example |
|---------|-------------|---------|
| Create User | Creates a new user with specified roles | `db.createUser()` |
| Grant Role | Adds roles to an existing user | `db.grantRolesToUser()` |
| Revoke Role | Removes roles from a user | `db.revokeRolesFromUser()` |
| Update User | Modifies user information | `db.updateUser()` |
| Drop User | Deletes a user | `db.dropUser()` |
| Show Users | Lists all users | `db.getUsers()` |

### User Creation and Role Assignment

```javascript
// Create a read-only user for a specific database
db.createUser({
  user: "readonly",
  pwd: passwordPrompt(),  // Interactive password prompt
  roles: [{ role: "read", db: "reporting" }]
})

// Create a user with write access to one database and read access to another
db.createUser({
  user: "datawriter",
  pwd: passwordPrompt(),
  roles: [
    { role: "readWrite", db: "products" },
    { role: "read", db: "analytics" }
  ]
})

// Create an admin user for a specific database
db.createUser({
  user: "dbadmin",
  pwd: passwordPrompt(),
  roles: [{ role: "dbAdmin", db: "products" }]
})

// Create a user with cluster-wide admin privileges
db.createUser({
  user: "clusteradmin",
  pwd: passwordPrompt(),
  roles: [{ role: "clusterAdmin", db: "admin" }]
})

// Create a superuser
db.createUser({
  user: "rootuser",
  pwd: passwordPrompt(),
  roles: [{ role: "root", db: "admin" }]
})
```

### Custom Roles

Custom roles allow fine-tuning permissions beyond the built-in roles:

```javascript
// Create a custom role for managing a specific collection
db.createRole({
  role: "productsManager",
  privileges: [
    {
      resource: { db: "retail", collection: "products" },
      actions: ["find", "insert", "update"]
    },
    {
      resource: { db: "retail", collection: "product_reviews" },
      actions: ["find"]
    }
  ],
  roles: []
})

// Create a custom role that extends existing roles
db.createRole({
  role: "backupOperator",
  privileges: [
    {
      resource: { cluster: true },
      actions: ["serverStatus"]
    }
  ],
  roles: [
    { role: "backup", db: "admin" }
  ]
})
```

## Authentication Configuration

### Enabling Authentication

In the MongoDB configuration file (mongod.conf):

```yaml
security:
  authorization: enabled
```

Or when starting MongoDB:

```bash
mongod --auth --dbpath /data/db
```

### Connecting with Authentication

```bash
# Connect with username and password
mongo --username myuser --password mypassword --authenticationDatabase admin

# Or within the MongoDB shell
mongo
use admin
db.auth("myuser", "mypassword")
```

### Application Authentication

```javascript
// Node.js example with MongoDB driver
const { MongoClient } = require('mongodb');

const uri = "mongodb://username:password@localhost:27017/mydatabase";
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    const database = client.db("mydatabase");
    const collection = database.collection("documents");
    // Now perform operations with authentication
  } finally {
    await client.close();
  }
}
run().catch(console.dir);
```

## Advanced Authentication Features

### TLS/SSL Client Authentication

Configure MongoDB for TLS/SSL in the configuration file:

```yaml
net:
  ssl:
    mode: requireSSL
    PEMKeyFile: /path/to/mongodb.pem
    CAFile: /path/to/ca.pem
```

Connect using certificates.
