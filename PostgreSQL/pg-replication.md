
# PostgreSQL Logical Replication Setup with CloudNativePG

---

## Overview

This guide explains how to configure logical replication between two PostgreSQL clusters managed by CloudNativePG in Kubernetes. It covers:

- Prerequisites and environment setup
- Creating a publication on the publisher cluster
- Creating a replication user and setting permissions
- Configuring the subscriber cluster with an external cluster reference and secret
- Creating a subscription on the subscriber cluster
- Verifying replication status
- Troubleshooting common issues

---

## 1. Prerequisites

- Two PostgreSQL clusters running CloudNativePG operator in Kubernetes, e.g., `postgres-cluster` (publisher) and `postgres02-cluster` (subscriber).
- `helm` [installed](https://helm.sh/docs/intro/install/). For testing, easy install of the postgres clusters:

  ```yaml
  helm install postgres cnpg/cluster -n yournamespace
  ```

- `kubectl` and `k` (CloudNativePG CLI) installed and configured to your cluster context.
- Basic understanding of Kubernetes secrets, Postgres roles, and replication concepts, and [cnpg plugin](https://cloudnative-pg.io/documentation/1.20/kubectl-plugin/) install.

---

## 2. Setup Replication User on Publisher

Connect to the publisher cluster:

```bash
kubectl cnpg psql postgres-cluster
```

Create a replication user with login and replication privileges:

```sql
CREATE ROLE repluser WITH REPLICATION LOGIN PASSWORD 'YourStrongPassword';
```

Verify the user:

```sql
SELECT rolname, rolreplication, rolcanlogin FROM pg_roles WHERE rolname='repluser';
```

Grant `CONNECT` to the publication database and `SELECT` on published tables:

```sql
GRANT CONNECT ON DATABASE app TO repluser;
GRANT SELECT ON TABLE repltable TO repluser;
--If all tables:
GRANT SELECT ON ALL TABLES IN SCHEMA public TO repluser;
```

---

## 3. Create Publication on Publisher

Connect to your application database on the publisher side and create a publication for your tables:

```sql
CREATE PUBLICATION replpub FOR ALL TABLES;
```

You can specify tables explicitly if needed:

```sql
CREATE PUBLICATION replpub FOR TABLE repltable, othertable;
```

---

## 4. Create Kubernetes Secret for Replication User Password

Create a Kubernetes secret with the replication user's password, base64 encoded:

```bash
echo -n "YourStrongPassword" | base64
```

Example YAML (replace `<base64-password>`):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: replsecret
  namespace: dbms
type: Opaque
data:
  password: <base64-password>
```

Apply it with:

```bash
kubectl apply -f replsecret.yaml
```

---

## 5. Add External Cluster Reference to Subscriber Cluster Spec

Edit your subscriber cluster CR to add an external cluster reference with connection details and the secret name:

```yaml
kubectl edit cluster postgres02-cluster
```
Add externalCluster under 'spec:'

```yaml
externalClusters:
  - name: postgres-cluster
    connectionParameters:
      host: postgres-cluster-rw.dbms.svc
      port: "5432"
      dbname: app
      user: repluser
      sslmode: require
    password:
      name: replsecret
      key: password
```

Apply the updated subscriber cluster spec:

```bash
kubectl apply -f subscriber-cluster.yaml
```

---

## 6. Create Subscription on Subscriber

Use `kubectl cnpg` to create the subscription referencing the external cluster and publication:

```bash
kubectl cnpg subscription create postgres02-cluster --publication replpub --subscription replsub --dbname app --external-cluster postgres-cluster
```

This command internally creates a subscription on the subscriber PostgreSQL cluster connecting to the publisher.

Subscription created manually, without using cnpg:

```yaml
DROP SUBSCRIPTION replsub;

CREATE SUBSCRIPTION replsub
  CONNECTION 'dbname=app host=postgres-cluster-rw.dbms.svc port=5432 user=repluser password=YourStrongPassword sslmode=require'
  PUBLICATION replpub
  WITH (copy_data = true);
```

---

## 7. Verify Replication Status

On subscriber, check subscriptions:

```sql
SELECT subname, subenabled, subsynccommit FROM pg_subscription;
```

Check active replication slots on publisher:

```sql
SELECT * FROM pg_replication_slots;
```

Check ongoing logical replication activity on subscriber:

```sql
SELECT pid, query, state FROM pg_stat_activity WHERE query LIKE '%replication%';
```

---

## 8. Troubleshooting

### Common Issues and Fixes

- **Password authentication failed**
  - Ensure the secret password matches the replication user password exactly.
  - Check the secret is correctly referenced in subscriber spec (`name` and `key`).
  - Validate `/controller/external/<external-cluster>/pgpass` contents inside subscriber pod.

- If needing to restart the subscriber, then use:

```yaml
kubectl cnpg restart postgres02-cluster
```


- **Replication connection refused**
  - Confirm network connectivity between subscriber and publisher services.
  - Verify SSL mode and port settings.

- **Tables not syncing**
  - Confirm publication includes the tables.
  - Check subscriber subscription status and logs for errors.
  - Verify `SELECT` permissions for replication user on publisher tables.

### Useful Commands

- Check roles and permissions on publisher:

```sql
SELECT rolname, rolsuper, rolreplication, rolcanlogin FROM pg_roles WHERE rolname='repluser';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO repluser;
```

- View subscription status:

```sql
SELECT * FROM pg_stat_subscription;
```

- See replication logs in subscriber pods:

```bash
kubectl -n dbms logs <subscriber-pod-name> -c postgres
```

- Check replication slots on publisher:

```sql
SELECT * FROM pg_replication_slots;
```

---

## 9. Testing Replication

- Create table and insert data on publisher:

```sql
CREATE TABLE repltable (id SERIAL PRIMARY KEY, value TEXT NOT NULL);
INSERT INTO repltable (value) VALUES ('Hello'), ('World');
```

- On subscriber, after initial sync, query the replicated table:

```sql
SELECT * FROM repltable;
```

You should see the inserted rows replicated.

---

## 10. Additional Notes

- Logical replication only replicates data changes; schema creation or changes must be managed separately.
- Use `WITH (copy_data = true)` in subscription creation if you want an initial data copy.
- Keep user passwords and secrets secure.
- Monitor replication lag and status regularly.

---
