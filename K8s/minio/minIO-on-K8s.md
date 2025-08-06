
# Installing MinIO in Kubernetes and Using PostgreSQL Backups

## Introduction

This guide provides detailed steps for installing MinIO within a Kubernetes (K8s) environment. It also covers how to use `pg_basebackup` and `pg_dump` to back up PostgreSQL databases to MinIO, which serves as an S3-compatible object storage.

## Prerequisites

- A running Kubernetes cluster (local or cloud-based).
- `kubectl` installed and configured to interact with your cluster.
- Access to a PostgreSQL database within your cluster.
- Basic knowledge of Kubernetes and PostgreSQL.

## Setting Up MinIO in Kubernetes

### 1. Installing MinIO

You can deploy MinIO in your Kubernetes cluster by creating a YAML configuration file or using the official MinIO Helm chart. Below, we use a simple `StatefulSet` approach.

```yaml
# minio-deployment.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minio
  labels:
    app: minio
spec:
  serviceName: "minio"
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
          - server
          - /data
        ports:
          - containerPort: 9000
        env:
          - name: MINIO_ROOT_USER
            value: "minioadmin"
          - name: MINIO_ROOT_PASSWORD
            value: "minioadmin123"
        volumeMounts:
          - name: minio-data
            mountPath: /data
      volumes:
        - name: minio-data
          persistentVolumeClaim:
            claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
spec:
  type: NodePort
  ports:
    - port: 9000
      targetPort: 9000
      nodePort: 32000
  selector:
    app: minio
```

Deploy MinIO with:

```bash
kubectl create namespace minio

kubectl apply -f minio-deployment.yaml -n minio
```

### 2. Exposing MinIO

The service created in the above configuration will expose MinIO on `NodePort` 32000. You can change this if needed. Access it via `http://<node-ip>:32000`.

### 3. Accessing MinIO

|Port|Service|Access Method|
|---|---|---|
|9000|MinIO API/Web Interface|Accessed directly or via port forwarding|
|32000|MinIO NodePort|Accessed via <node-ip>:32000|

You can use a web browser to access MinIO at:

```code
http://<node-ip>:9000
http://<node-ip>:32000
```

```code
kubectl port-forward service/minio 9000:9000 -n minio
```

>e.g. http://localhost:32000 / e.g. http://localhost:9000

Log in using the credentials:

- **Access Key**: `minioadmin`
- **Secret Key**: `minioadmin123`

## Configuring PostgreSQL for MinIO

### 1. Setting Up PostgreSQL

Ensure you have PostgreSQL running in your Kubernetes cluster. If you don’t have it installed, you can deploy it using the following command:

```bash
kubectl run pg --image=postgres:latest --env POSTGRES_PASSWORD=mysecretpassword --port 5432
```

### 2. Configuring S3-Compatible Storage in PostgreSQL

To use MinIO with PostgreSQL for backups, you need to configure the `postgresql.conf` file to set the `archive_command`. This can be done by connecting to your PostgreSQL instance and executing SQL commands to set the required parameters.

### Example Configuration

Log in to PostgreSQL:

```bash
kubectl exec -it pg -- psql -U postgres
```

Run the following SQL commands:

```sql
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'aws s3 cp %p s3://my-bucket/%f'; -- Use the MinIO S3 endpoint
SELECT pg_reload_conf();
```

Replace `my-bucket` with the name of your MinIO bucket.

## Using `pg_basebackup` with MinIO

### 1. Creating Backups

You can use `pg_basebackup` to create backups of your PostgreSQL database. Run the following command to perform the backup and store it in MinIO:

```bash
pg_basebackup -h <postgres-service-ip> -U postgres -D /tmp/backup -Ft -z -P --no-wal --compress
```

After running the command, upload the backup to MinIO:

```bash
aws --endpoint-url http://<minio-ip>:32000 s3 cp /tmp/backup s3://my-bucket/backup/ --recursive

```

### 2. Restoring from Backups

To restore from the backup stored in MinIO, download it first:

```bash
aws --endpoint-url http://<minio-ip>:32000 s3 cp s3://my-bucket/backup/ /tmp/backup --recursive
```

Then, use `pg_restore` to restore the database from the backup directory:

```bash
pg_restore -h <postgres-service-ip> -U postgres -d <database-name> /tmp/backup/<backup-file>
```

## Using `pg_dump` with MinIO

### 1. Creating Dumps

To create a logical backup using `pg_dump`, you can run the following command:

```bash
pg_dump -h <postgres-service-ip> -U postgres -F c -b -v -f /tmp/db_backup.dump <database-name>
```

Upload the dump to MinIO:

```bash
aws --endpoint-url http://<minio-ip>:32000 s3 cp /tmp/db_backup.dump s3://my-bucket/db_backup.dump
```

### 2. Restoring Dumps

To restore the dump from MinIO, download it first:

```bash
aws --endpoint-url http://<minio-ip>:32000 s3 cp s3://my-bucket/db_backup.dump /tmp/db_backup.dump
```

Then restore it using:

```bash
pg_restore -h <postgres-service-ip> -U postgres -d <database-name> /tmp/db_backup.dump
```

## Conclusion

In this guide, we covered how to install MinIO within a Kubernetes environment and how to configure PostgreSQL to use MinIO for backups. With this setup, you can efficiently manage your PostgreSQL database backups using both `pg_basebackup` and `pg_dump`. Feel free to customize the configurations to fit your environment and backup strategies.
