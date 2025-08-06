# InfluxDB Permission Management

## Overview of Security Models

InfluxDB implements different security models depending on the version:

- **InfluxDB 1.x**: Uses a combination of users, database-level privileges, and authentication/authorization controls
- **InfluxDB 2.x**: Uses a token-based authorization model with more granular permission controls through organizations and buckets

This guide covers both security models, with a focus on proper permission management.

## InfluxDB 1.x Permission Management

### User Management

| Command | Description | Example |
|---------|-------------|---------|
| Create User | Creates a new user | `CREATE USER username WITH PASSWORD 'password'` |
| Create Admin User | Creates a user with admin privileges | `CREATE USER admin WITH PASSWORD 'password' WITH ALL PRIVILEGES` |
| Show Users | Lists all users | `SHOW USERS` |
| Set Password | Changes password for a user | `SET PASSWORD FOR username = 'new_password'` |
| Drop User | Deletes a user | `DROP USER username` |

### Database Privileges

| Command | Description | Example |
|---------|-------------|---------|
| Grant Read | Grants read-only access to a database | `GRANT READ ON database_name TO username` |
| Grant Write | Grants write-only access to a database | `GRANT WRITE ON database_name TO username` |
| Grant All | Grants full access to a database | `GRANT ALL ON database_name TO username` |
| Revoke Read | Removes read access | `REVOKE READ ON database_name FROM username` |
| Revoke Write | Removes write access | `REVOKE WRITE ON database_name FROM username` |
| Revoke All | Removes all privileges | `REVOKE ALL ON database_name FROM username` |
| Show Grants | Shows privileges for a user | `SHOW GRANTS FOR username` |

### Complete Authorization Script Example

```sql
-- Create a database
CREATE DATABASE metrics;

-- Create users with specific roles
CREATE USER readonly WITH PASSWORD 'password123';
CREATE USER writer WITH PASSWORD 'password456';
CREATE USER admin WITH PASSWORD 'password789';

-- Assign appropriate permissions
GRANT READ ON metrics TO readonly;
GRANT WRITE ON metrics TO writer;
GRANT ALL ON metrics TO admin;

-- Verify the permissions
SHOW GRANTS FOR readonly;
SHOW GRANTS FOR writer;
SHOW GRANTS FOR admin;
```

### Authentication Methods in InfluxDB 1.x

#### HTTP Basic Authentication

In HTTP requests, provide credentials in the Authorization header:

```bash
curl -G http://localhost:8086/query \
  -u username:password \
  --data-urlencode "q=SHOW DATABASES"
```

#### Service Authentication

Configure HTTP auth in influxdb.conf:

```toml
[http]
  auth-enabled = true
```

#### JWT Token Authentication (Enterprise)

For InfluxDB Enterprise, JWT tokens provide advanced authentication:

```bash
curl -G http://localhost:8086/query \
  -H "Authorization: Bearer <token>" \
  --data-urlencode "q=SHOW DATABASES"
```

## InfluxDB 2.x Permission Management

InfluxDB 2.x uses a completely revamped security model based on:

- **Organizations**: Top-level containers for users, buckets, and dashboards
- **Buckets**: Storage containers for time series data (replacing databases)
- **Users**: Individual accounts with usernames and passwords
- **API Tokens**: Generated tokens with specific permission sets

### Token-Based Authentication

All interactions with InfluxDB 2.x API require a token:

```bash
curl --request GET \
  "http://localhost:8086/api/v2/buckets" \
  --header "Authorization: Token YourInfluxDBToken"
```

### User and Token Management

#### Using the influx CLI

```bash
# Create a new user
influx user create --name username --password password

# Create an organization
influx org create --name my-org

# Create a bucket
influx bucket create --name my-bucket --org my-org

# Create an API token
influx auth create --org my-org --write-buckets --read-buckets
```

#### Using the API

```bash
# Create a user via API
curl --request POST \
  "http://localhost:8086/api/v2/users" \
  --header "Authorization: Token YourAdminToken" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "newuser",
    "status": "active"
  }'
```

### Permission Types in InfluxDB 2.x

InfluxDB 2.x offers fine-grained permissions through token authorization:

| Permission | Description | API Scope |
|------------|-------------|-----------|
| `read` | Read data or metadata | `/api/v2/read` |
| `write` | Write data or metadata | `/api/v2/write` |
| `buckets read` | View bucket metadata | `/api/v2/buckets/*/` |
| `buckets write` | Create/modify buckets | `/api/v2/buckets/*` |
| `orgs read` | View organization metadata | `/api/v2/orgs/*/` |
| `orgs write` | Create/modify organizations | `/api/v2/orgs/*` |
| `tasks read` | View tasks | `/api/v2/tasks/` |
| `tasks write` | Create/modify tasks | `/api/v2/tasks/*` |
| `users read` | View user metadata | `/api/v2/users/` |
| `users write` | Create/modify users | `/api/v2/users/*` |
| `telegrafs read` | View Telegraf configs | `/api/v2/telegrafs/` |
| `telegrafs write` | Create/modify Telegraf configs | `/api/v2/telegrafs/*` |
| `dashboards read` | View dashboards | `/api/v2/dashboards/` |
| `dashboards write` | Create/modify dashboards | `/api/v2/dashboards/*` |
| `annotations read` | View annotations | `/api/v2/annotations/` |
| `annotations write` | Create/modify annotations | `/api/v2/annotations/*` |
| `all access` | Full admin permissions | All endpoints |

### Token Management and Security

```bash
# Generate a read-only token for a specific bucket
influx auth create \
  --org my-organization \
  --read-buckets \
  --resource-id $(influx bucket find --name my-bucket --json | jq -r '.[0].id')

# Generate a write-only token for a specific bucket
influx auth create \
  --org my-organization \
  --write-buckets \
  --resource-id $(influx bucket find --name my-bucket --json | jq -r '.[0].id')

# Delete a token
influx auth delete --id tokenID
```

## Securing the InfluxDB API

### TLS/SSL Configuration

#### InfluxDB 1.x

Edit influxdb.conf:

```toml
[http]
  https-enabled = true
  https-certificate = "/etc/ssl/influxdb-cert.pem"
  https-private-key = "/etc/ssl/influxdb-key.pem"
```

#### InfluxDB 2.x

Edit config.yml:

```yaml
tls:
  cert: /etc/ssl/influxdb-cert.pem
  key: /etc/ssl/influxdb-key.pem
```

### IP Restriction

#### InfluxDB 1.x

```toml
[http]
  bind-address = "127.0.0.1:8086"  # Only accept local connections
```

#### InfluxDB 2.x

Use a reverse proxy or firewall rules to restrict IP access.

## Best Practices for Permission Management

1. **Follow the Principle of Least Privilege**
   - Assign only permissions users need to perform their jobs
   - Regularly audit and revoke unnecessary permissions
   - Use read-only tokens by default, only grant write when necessary

2. **Implement a Token Rotation Strategy**
   - Change service account tokens periodically
   - Revoke tokens when employees change roles or leave
   - Set up monitoring for unexpected token usage patterns

3. **Separate Development and Production Environments**
   - Use different organizations for development and production
   - Never share production tokens with development teams
   - Implement stricter access controls on production environments

4. **Automate Permission Management**
   - Use infrastructure-as-code to define permissions
   - Implement automated token provisioning with least privilege
   - Document all permission changes through version control

5. **Monitor Permission Usage**
   - Enable audit logging
   - Set up alerts for failed authentication attempts
   - Review permission changes regularly

## Common Security Pitfalls to Avoid

1. **Using Admin Tokens Everywhere**
   - Issue: Using admin tokens for normal operations gives excessive privileges
   - Solution: Create scoped tokens for specific operations

2. **Sharing Tokens Between Services**
   - Issue: When a token needs to be revoked, all services are affected
   - Solution: Create dedicated tokens for each service or integration

3. **Manually Managing Permissions**
   - Issue: Manual permission changes lead to inconsistency and human error
   - Solution: Automate permission management through scripts or tools

4. **Neglecting Token Expiration**
   - Issue: Perpetual tokens can be compromised and used indefinitely
   - Solution: Set token expiration dates, especially for temporary access
