
# PostgreSQL Extensions: `CREATE EXTENSION` Explained

- [PostgreSQL Extensions: `CREATE EXTENSION` Explained](#postgresql-extensions-create-extension-explained)
  - [Overview](#overview)
    - [What Happens When You Run `CREATE EXTENSION`?](#what-happens-when-you-run-create-extension)
    - [1. **Pre-installed vs. External Extensions**](#1-pre-installed-vs-external-extensions)
      - [Pre-installed Extensions](#pre-installed-extensions)
      - [Third-party Extensions](#third-party-extensions)
    - [2. **Installation via Package Manager (`apt-get`, `yum`, etc.)**](#2-installation-via-package-manager-apt-get-yum-etc)
    - [3. **What Happens When You Run `CREATE EXTENSION`?**](#3-what-happens-when-you-run-create-extension)
    - [4. **Pre-installed Extension Examples**](#4-pre-installed-extension-examples)
    - [5. **Managing Extensions**](#5-managing-extensions)
    - [Summary of the Process](#summary-of-the-process)

## Overview

In PostgreSQL, extensions are collections of SQL objects (functions, types, operators, etc.) that add new functionality to the database. When you run the `CREATE EXTENSION` command, you're essentially activating an extension that is pre-installed on the PostgreSQL server, or installed through other means, such as a package manager.

### What Happens When You Run `CREATE EXTENSION`?

When you execute `CREATE EXTENSION`, you’re not pulling the extension from an external repository (like using `apt-get`), but rather you're loading and activating an extension that is **already installed on the PostgreSQL server**.

Here's what happens step-by-step:

### 1. **Pre-installed vs. External Extensions**

#### Pre-installed Extensions

- PostgreSQL comes with a set of extensions that are **pre-installed** during the PostgreSQL installation process.
- These extensions are stored in PostgreSQL’s installation directory (typically under `share/extension`).
- Examples include: `pg_stat_statements`, `hstore`, `citext`, and `uuid-ossp`.

When you run `CREATE EXTENSION`, PostgreSQL reads the extension's SQL script or shared library and activates it in the current database.

#### Third-party Extensions

- Some extensions are not included by default with PostgreSQL, but can be installed separately via package managers or manually.
- For example, the `pg_partman` extension (for partition management) can be installed on a Debian-based system using `apt-get`:

```bash
sudo apt-get install postgresql-partman
```

Once installed, the extension can be loaded into a specific database using `CREATE EXTENSION`:

```sql
CREATE EXTENSION pg_partman;
```

### 2. **Installation via Package Manager (`apt-get`, `yum`, etc.)**

In cases where the desired extension is not bundled with PostgreSQL, you need to install it using the package manager for your operating system. The process typically involves:

- **Step 1**: Install the extension package. For example, for `pg_partman` on a Debian-based system:

```bash
sudo apt-get install postgresql-partman
```

- **Step 2**: Once installed, activate the extension in the database by running:

```sql
CREATE EXTENSION pg_partman;
```

This makes the extension available for use in that specific database.

> **Note**: The package manager installation places the necessary files (SQL scripts, shared libraries, etc.) on the server, but the extension isn’t activated in any database until you run `CREATE EXTENSION`.

### 3. **What Happens When You Run `CREATE EXTENSION`?**

- **Not Downloading**: When you run `CREATE EXTENSION`, it **does not download** anything from an external source. The necessary files must already be on the server (either installed with PostgreSQL or via a package manager).

- **Loading Pre-installed Code**: PostgreSQL reads the extension's SQL files (or shared libraries) from the server’s file system. It executes these files, which typically create SQL objects (like functions, views, types, etc.) in the current database.

- **Registering the Extension**: PostgreSQL registers the extension in the `pg_extension` system catalog, making it available for future use in that specific database.

### 4. **Pre-installed Extension Examples**

Some common pre-installed extensions include:

- **`pg_stat_statements`**: Tracks execution statistics for SQL statements.
- **`hstore`**: Provides key-value storage within a single column.
- **`citext`**: A case-insensitive text data type.
- **`uuid-ossp`**: Functions for generating UUIDs.

### 5. **Managing Extensions**

Once an extension is activated, you can manage it with the following commands:

- **`ALTER EXTENSION`**: Modify or update the extension, such as upgrading it to a new version.
- **`DROP EXTENSION`**: Uninstall the extension from the current database. This removes all objects created by the extension.

```sql
DROP EXTENSION pg_stat_statements;
```

### Summary of the Process

1. **Install the Extension on the Server (if necessary)**:
    - Pre-installed extensions are already available on the PostgreSQL server.
    - For third-party extensions, you may need to install them via a package manager (e.g., `apt-get install postgresql-<extension>`).

2. **Activate the Extension in the Database**:
    - After the extension is available on the server, run `CREATE EXTENSION <extension_name>;` to activate it in a specific database.

**Important Notes**:

- Extensions are **database-specific**, meaning that `CREATE EXTENSION` needs to be run in each database where the extension will be used.
- Installing an extension via a package manager makes it available to all databases on the PostgreSQL instance, but you still need to activate it in each database individually using `CREATE EXTENSION`.
