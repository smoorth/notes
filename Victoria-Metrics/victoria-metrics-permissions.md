# Victoria Metrics Permission Management

## Overview of Security Models

Victoria Metrics offers different security capabilities depending on whether you're using the open-source single-node version or the enterprise cluster version:

- **Victoria Metrics Single-node**: Basic authentication, TLS/SSL, and external authorization using reverse proxies
- **Victoria Metrics Cluster**: Multi-tenancy, enterprise-grade authentication, and fine-grained authorization controls

This guide covers both scenarios, with a focus on practical permission management strategies.

## Basic Authentication

### Single-node Authentication

Victoria Metrics single-node version supports HTTP Basic Authentication using command-line flags:

| Command Flag | Description | Example |
|---------|-------------|---------|
| `-httpAuth.username` | Username for HTTP Basic Auth | `-httpAuth.username=admin` |
| `-httpAuth.password` | Password for HTTP Basic Auth | `-httpAuth.password=strong-password` |
| `-httpAuth.passwordFile` | Path to file with password | `-httpAuth.passwordFile=/etc/vm/password.txt` |

Example startup command with Basic Auth:

```bash
victoria-metrics -httpAuth.username=admin -httpAuth.password=strong-password
```

### Securing Multiple Endpoints

Victoria Metrics exposes multiple endpoints that might need different authentication:

```bash
# Different auth for write vs read endpoints
victoria-metrics \
  -httpAuth.username=metrics-writer \
  -httpAuth.password=writer-pwd \
  -httpAuth.urlPrefix=/write \
  -httpAuth.username=metrics-reader \
  -httpAuth.password=reader-pwd \
  -httpAuth.urlPrefix=/select \
  -httpAuth.username=admin \
  -httpAuth.password=admin-pwd \
  -httpAuth.urlPrefix=/admin
```

### HTTP Authentication in Clients

When accessing Victoria Metrics with authentication enabled:

```bash
# Using curl
curl -u username:password http://localhost:8428/api/v1/query?query=up

# Using Prometheus configuration
prometheus:
  remote_write:
    - url: "http://localhost:8428/api/v1/write"
      basic_auth:
        username: "metrics-writer"
        password: "writer-pwd"
```

## Multi-Tenancy and Account Management

### Multi-Tenancy Overview

Victoria Metrics cluster version supports multi-tenancy through the concept of "tenants" or "accounts":

1. **Account ID**: Used to separate data from different tenants
2. **Namespace**: Additional separation level within each account (Enterprise feature)

### Setting Up Multi-Tenancy

To enable multi-tenancy in Victoria Metrics cluster:

```bash
# vminsert - multi-tenancy for data ingestion
vminsert -enableTenantID=true

# vmselect - multi-tenancy for querying
vmselect -enableTenantID=true

# vmstorage - multi-tenancy for storage
vmstorage -enableTenantID=true
```

### Tenant Management

| Operation | Description | Example |
|---------|-------------|---------|
| Create Tenant | Implicit creation when first data arrives | Send data with `accountID=tenant1` |
| Isolate Tenant Data | Each tenant has isolated data | Use `accountID` header or URL parameter |
| Restrict Tenant Access | Apply authentication per tenant | Configure in reverse proxy |

### Account ID Specification Methods

There are multiple ways to specify accountID when working with Victoria Metrics:

#### In HTTP Headers

```bash
# Writing data with accountID in header
curl -H "AccountID: tenant1" -X POST http://vminsert:8480/insert/0/prometheus/api/v1/write

# Querying data with accountID in header
curl -H "AccountID: tenant1" http://vmselect:8481/select/0/prometheus/api/v1/query?query=up
```

#### In URL Path

```bash
# Writing data with accountID in URL
curl -X POST http://vminsert:8480/insert/tenant1/prometheus/api/v1/write

# Querying data with accountID in URL
curl http://vmselect:8481/select/tenant1/prometheus/api/v1/query?query=up
```

## Role-Based Access Control (Enterprise)

Victoria Metrics Enterprise offers role-based access control through integration with external authentication providers.

### RBAC Implementation

1. **Define Roles**: Create roles that group permissions
2. **Assign Permissions**: Assign specific actions to roles
3. **Map Users to Roles**: Connect users/groups from auth provider to roles

### Permission Types

| Permission | Description | Example |
|------------|-------------|---------|
| `read` | Read metrics data | Query metrics for specific tenant |
| `write` | Write metrics data | Send metrics for specific tenant |
| `admin` | Administrative operations | Configure retention, view status |

### Authentication Integration

Victoria Metrics Enterprise can integrate with:

1. **OAuth 2.0 / OpenID Connect**
2. **LDAP / Active Directory**
3. **SAML**

Example configuration for OAuth:

```yaml
# Enterprise authorization configuration
authorization:
  oauth:
    client_id: "victoria-metrics-client"
    client_secret: "client-secret"
    token_url: "https://auth-provider.example.com/oauth/token"
    user_info_url: "https://auth-provider.example.com/oauth/userinfo"
    scopes: ["openid", "profile"]

  roles:
    - name: "reader"
      permissions:
        - action: "read"
          tenant: "*"
    - name: "writer"
      permissions:
        - action: "write"
          tenant: "tenant1"
    - name: "admin"
      permissions:
        - action: "admin"
          tenant: "*"

  mappings:
    - from:
        claim: "groups"
        value: "metrics-readers"
      to:
        role: "reader"
    - from:
        claim: "groups"
        value: "metrics-writers"
      to:
        role: "writer"
    - from:
        claim: "email"
        value: "admin@example.com"
      to:
        role: "admin"
```

## Securing Victoria Metrics with External Authorization

For open-source users without enterprise features, authorization can be implemented using external tools.

### Using a Reverse Proxy for Authentication

1. **Nginx with Basic Auth**:

```nginx
server {
    listen 80;
    server_name metrics.example.com;

    # Readers can only query
    location ~ ^/select/ {
        auth_basic "Metrics Reader Authentication";
        auth_basic_user_file /etc/nginx/htpasswd.reader;

        # Forward to vmselect
        proxy_pass http://vmselect:8481;
    }

    # Writers can only write
    location ~ ^/insert/ {
        auth_basic "Metrics Writer Authentication";
        auth_basic_user_file /etc/nginx/htpasswd.writer;

        # Forward to vminsert
        proxy_pass http://vminsert:8480;
    }

    # Admins can access admin interfaces
    location ~ ^/admin/ {
        auth_basic "Admin Authentication";
        auth_basic_user_file /etc/nginx/htpasswd.admin;

        # Forward to admin endpoints
        proxy_pass http://vmselect:8481;
    }
}
```

2. **Traefik with Forward Auth**:

```yaml
# Traefik configuration
http:
  routers:
    vmselect:
      rule: "Host(`metrics.example.com`) && PathPrefix(`/select`)"
      service: "vmselect"
      middlewares:
        - "reader-auth"

    vminsert:
      rule: "Host(`metrics.example.com`) && PathPrefix(`/insert`)"
      service: "vminsert"
      middlewares:
        - "writer-auth"

  middlewares:
    reader-auth:
      forwardAuth:
        address: "http://auth-service/verify?role=reader"
    writer-auth:
      forwardAuth:
        address: "http://auth-service/verify?role=writer"

  services:
    vmselect:
      loadBalancer:
        servers:
          - url: "http://vmselect:8481"
    vminsert:
      loadBalancer:
        servers:
          - url: "http://vminsert:8480"
```

## TLS/SSL Configuration

### Enabling HTTPS

Victoria Metrics supports TLS/SSL for secure communications:

```bash
victoria-metrics \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem
```

For cluster components, configure each component:

```bash
vminsert \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem

vmselect \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem

vmstorage \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem
```

### Client Certificate Authentication (mTLS)

For mutual TLS authentication:

```bash
victoria-metrics \
  -tls \
  -tlsCertFile=/path/to/cert.pem \
  -tlsKeyFile=/path/to/key.pem \
  -tlsCAFile=/path/to/ca.pem \
  -tlsServerName=vm.example.com
```

## Network Security

### IP Restriction

Limit access by binding to specific network interfaces:

```bash
# Only accept connections from localhost
victoria-metrics -httpListenAddr=127.0.0.1:8428

# Bind to specific network interface
victoria-metrics -httpListenAddr=192.168.1.10:8428
```

### Firewall Configuration

Example of restricting access with iptables:

```bash
# Allow only specific IPs to access VM
iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 8428 -j ACCEPT
iptables -A INPUT -p tcp --dport 8428 -j DROP
```

## Best Practices for Permission Management

1. **Follow the Principle of Least Privilege**
   - Assign only permissions users need to perform their jobs
   - Separate read and write access
   - Use different tenants for different applications or teams

2. **Implement a Strong Authentication Strategy**
   - Use strong passwords or certificate-based authentication
   - Rotate credentials regularly
   - Consider implementing multi-factor authentication through identity providers

3. **Separate Development and Production**
   - Use different tenant IDs for development and production
   - Implement stricter access controls for production environments
   - Never share production credentials with development teams

4. **Automate Permission Management**
   - Use infrastructure-as-code to define authentication settings
   - Integrate with existing identity management systems
   - Document all permission changes through version control

5. **Monitor Access and Usage**
   - Enable audit logging for authentication attempts
   - Monitor for unusual access patterns
   - Review permissions regularly

## Common Security Pitfalls to Avoid

1. **Exposing Victoria Metrics Directly to the Internet**
   - Issue: Allowing direct access without proper authentication
   - Solution: Always place behind a reverse proxy with authentication

2. **Using Same Credentials for All Services**
   - Issue: Compromise of one service affects all services
   - Solution: Use different credentials for different access types

3. **Neglecting TLS/SSL**
   - Issue: Data and credentials transmitted in clear text
   - Solution: Always use TLS, especially in production

4. **Ignoring Multi-Tenancy**
   - Issue: All data accessible to all users
   - Solution: Implement proper tenant isolation
