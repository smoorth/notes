
# MinIO Client (`mc`) Installation and Backup Creation Guide

## 1. Install MinIO Client (`mc`)

The MinIO Client (`mc`) is a command-line tool to manage MinIO and other compatible cloud storage services. Below are the steps to install it in your WSL environment and configure it to interact with the MinIO server running in your Kubernetes cluster.

### 1.1 Download and Install MinIO Client

- Open your terminal in your WSL environment and run the following commands to download the MinIO Client:

```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
--create-dirs \
-o $HOME/minio-binaries/mc
```

- After downloading, set the executable permission:

```bash
chmod +x $HOME/minio-binaries/mc
```

- Add the following line to your `~/.bashrc` and run `source ~/.bashrc`.

```bash
export PATH=$PATH:$HOME/minio-binaries/
```

- Move the `minio` executable to `/usr/local/bin` to make it accessible globally:

```bash
sudo mv minio /usr/local/bin/
```

- Verify the installation by checking the version of the MinIO Client:

```bash
minio --version
```

You should see the MinIO version output.

## 2. Configure MinIO Client to Connect to the MinIO Server

### 2.1 Set Up Access to MinIO Server

- Run the following command to configure the MinIO client and connect to the MinIO server running in your Kubernetes cluster:

```bash
mc alias set myminio http://localhost:9000 YOUR_ACCESS_KEY YOUR_SECRET_KEY
```

Replace `YOUR_ACCESS_KEY` and `YOUR_SECRET_KEY` with the access and secret keys you used in your MinIO deployment.

Example:

```bash
mc alias set myminio http://localhost:9000 minioadmin minioadmin123
```

- After setting up the alias, verify the connection by listing the available buckets:

```bash
mc ls myminio
```

If there are no buckets, you will not see any output, but if you encounter an error, double-check your access credentials.

## 3. Create a Bucket for Backups

To store PostgreSQL backups (via `pg_basebackup` or `pg_dump`), you can create a new bucket using the MinIO client (`mc`).

### 3.1 Create a Bucket

- Use the following command to create a new bucket in MinIO. This bucket will be used to store your PostgreSQL backups:

```bash
mc mb myminio/postgres-backups
```

Replace `postgres-backups` with the name of the bucket you want to create.

- Verify that the bucket was created by listing the available buckets again:

```bash
mc ls myminio
```

You should now see the `postgres-backups` bucket listed.

## 4. Uploading PostgreSQL Backups to MinIO

You can now use the MinIO client (`mc`) to upload your PostgreSQL backups into the newly created bucket.

### 4.1 Backup with `pg_dump`

To take a PostgreSQL backup with `pg_dump` and upload it to the MinIO bucket:

- First, create a backup using `pg_dump`:

```bash
pg_dump -U <db_user> -d <db_name> -F c -f /path/to/backup/db_backup.dump
```

Replace `<db_user>` with your PostgreSQL username, `<db_name>` with the name of the database you want to back up, and specify the output file path for the backup (`/path/to/backup/db_backup.dump`).

- Upload the backup file to MinIO:

```bash
mc cp /path/to/backup/db_backup.dump myminio/postgres-backups/db_backup.dump
```

This command copies the local backup file (`db_backup.dump`) into the `postgres-backups` bucket in MinIO.

### 4.2 Backup with `pg_basebackup`

You can also use `pg_basebackup` for a complete base backup of your PostgreSQL cluster.

- Run `pg_basebackup` to create a backup of your entire PostgreSQL data directory:

```bash
pg_basebackup -U <db_user> -D /path/to/backup/pg_basebackup -Fp -Xs -P
```

This will create a base backup at `/path/to/backup/pg_basebackup`.

- Upload the base backup directory to MinIO:

```bash
mc cp --recursive /path/to/backup/pg_basebackup myminio/postgres-backups/pg_basebackup
```

This will recursively upload the entire base backup directory to MinIO.

## 5. Automating Backups Using Cron Jobs (Optional)

You can automate backups by setting up a cron job in your WSL environment to periodically run the PostgreSQL backup commands and upload them to MinIO.

### 5.1 Setting up a Cron Job

- Open the crontab configuration for editing:

```bash
crontab -e
```

- Add a new cron job to run `pg_dump` daily at 2 AM and upload the backup to MinIO:

```bash
0 2 * * * pg_dump -U <db_user> -d <db_name> -F c -f /path/to/backup/db_backup.dump && mc cp /path/to/backup/db_backup.dump myminio/postgres-backups/db_backup-$(date +\%F).dump
```

This command takes a PostgreSQL dump at 2 AM and uploads it to the MinIO bucket with the date appended to the file name.

- Save and exit the crontab editor.

## 6. Restoring from a Backup

### 6.1 Download the Backup from MinIO

To restore from a backup, you first need to download the backup file from the MinIO bucket.

- Use the `mc` command to copy the backup file from MinIO to your local system:

```bash
mc cp myminio/postgres-backups/db_backup.dump /path/to/restore/db_backup.dump
```

- Restore the backup using `pg_restore` (for `pg_dump` backups):

```bash
pg_restore -U <db_user> -d <db_name> /path/to/restore/db_backup.dump
```

Or, for `pg_basebackup` backups, you can restore by copying the base backup directory back to the PostgreSQL data directory.

## 7. Managing backups/WALs in the bucket

List objects in the bucket

```bash
mc ls myminio/pgbackupbucket/pg_wal/
```

Delete specific WAL files in the bucket

```bash
mc rm myminio/pgbackupbucket/pg_wal/000000010000000000000037
```

Delete multiple files, you can use wildcards

```bash
mc rm --recursive --force myminio/pgbackupbucket/pg_wal/
```

>NOTE: This command will recursively delete all files in the pg_wal/ folder.
