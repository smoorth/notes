
# PostgreSQL Backup and Restore Plan Using `pg_basebackup`, `pg_dump` with MinIO

This plan details how to perform physical and logical backups of a PostgreSQL (CNPG) cluster, store them in MinIO, and restore them to a new or existing cluster, all in a WSL Ubuntu environment.

## Prerequisites

Ensure the following are installed:

- PostgreSQL client and server (CNPG in your WSL environment)
- MinIO installed and configured as an object store
- `pg_basebackup` and `pg_dump` tools (part of PostgreSQL)
- Access to your CNPG cluster

---

## 1. Set Up MinIO for Object Storage

1. **Install MinIO**:

   ```bash
   wget https://dl.min.io/server/minio/release/linux-amd64/minio
   chmod +x minio
   sudo mv minio /usr/local/bin/
   ```

2. **Run MinIO**:

   ```bash
   mkdir -p ~/minio/data
   export MINIO_ROOT_USER=minioadmin
   export MINIO_ROOT_PASSWORD=minioadmin
   minio server ~/minio/data
   ```

3. **Access MinIO Web UI**:
   - Go to `http://localhost:9000`
   - Login with `minioadmin:minioadmin`
   - Create a bucket called `postgres-backups`.

---

## 2. Perform a Physical Backup with `pg_basebackup`

1. **Run `pg_basebackup`**:

   ```bash
   pg_basebackup -D ~/minio/data/basebackup -Ft -z -P -h localhost -p 5432 -U postgres
   ```

   - `-D ~/minio/data/basebackup`: Directory for the backup.
   - `-Ft`: Format as tar.
   - `-z`: Compress the backup.
   - `-P`: Show progress.
   - `-h localhost`: PostgreSQL host.
   - `-p 5432`: PostgreSQL port.
   - `-U postgres`: PostgreSQL username.

2. **Upload the Backup to MinIO**:

   ```bash
   mc alias set myminio http://localhost:9000 minioadmin minioadmin
   mc cp ~/minio/data/basebackup.tar.gz myminio/postgres-backups/basebackup.tar.gz
   ```

---

## 3. Perform a Logical Backup with `pg_dump`

1. **Run `pg_dump`**:

   ```bash
   pg_dump -h localhost -p 5432 -U postgres -F c -b -v -f ~/minio/data/mydb.dump mydb
   ```

   - `-F c`: Custom format.
   - `-b`: Include large objects.
   - `-v`: Verbose output.
   - `-f ~/minio/data/mydb.dump`: Backup file path.

2. **Upload the Backup to MinIO**:

   ```bash
   mc cp ~/minio/data/mydb.dump myminio/postgres-backups/mydb.dump
   ```

---

## 4. Restoring from `pg_basebackup` (Physical Backup)

1. **Stop PostgreSQL**:

   ```bash
   sudo systemctl stop postgresql
   ```

2. **Remove Old Data** (optional):

   ```bash
   rm -rf /var/lib/postgresql/data/*
   ```

3. **Download and Extract Backup from MinIO**:

   ```bash
   mc cp myminio/postgres-backups/basebackup.tar.gz ~/minio/data/basebackup.tar.gz
   tar -xvf ~/minio/data/basebackup.tar.gz -C /var/lib/postgresql/data/
   ```

4. **Start PostgreSQL**:

   ```bash
   sudo systemctl start postgresql
   ```

---

## 5. Restoring from `pg_dump` (Logical Backup)

1. **Create a New Database**:

   ```bash
   createdb -h localhost -p 5432 -U postgres mydb_restored
   ```

2. **Restore the Logical Backup**:

   ```bash
   pg_restore -h localhost -p 5432 -U postgres -d mydb_restored -v ~/minio/data/mydb.dump
   ```

---

## 6. Verify Restored Data

1. **Connect to the Restored Database**:

   ```bash
   psql -h localhost -p 5432 -U postgres -d mydb_restored
   ```

2. **Run Queries** to verify the data and ensure that the restored database is functioning as expected.

---

## 7. Automate Backups with Cron Jobs (Optional)

To automate backups, you can schedule cron jobs. For example, to run a backup every day at midnight:

1. **Edit Cron Jobs**:

   ```bash
   crontab -e
   ```

2. **Add a Cron Job**:

   ```bash
   0 0 * * * pg_dump -h localhost -p 5432 -U postgres -F c -b -v -f ~/minio/data/mydb_$(date +\%F).dump mydb
   ```

---

## Summary

This plan covers:

- Setting up MinIO for object storage.
- Taking physical and logical backups with `pg_basebackup` and `pg_dump`.
- Storing backups in MinIO and restoring them to new or existing PostgreSQL clusters.
- Verifying the restored data.

By following these steps, you will gain hands-on experience with both backup and restore methods and learn how to integrate MinIO as a storage solution for PostgreSQL backups.
