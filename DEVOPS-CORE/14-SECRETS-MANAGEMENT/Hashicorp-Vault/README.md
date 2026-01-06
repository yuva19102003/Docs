# HashiCorp Vault Documentation - Complete Guide

## Overview

This directory contains comprehensive HashiCorp Vault documentation covering fundamentals, architecture, secrets engines, authentication methods, and production deployment. Each file includes detailed explanations, workflow diagrams, and practical examples.

## Documentation Structure

### Core Topics

1. **[Vault Fundamentals](./01-Vault-Fundamentals.md)** ✅ Created
   - What problem Vault solves
   - Core concepts and terminology
   - Complete architecture diagrams
   - Installation on multiple platforms
   - Getting started (dev mode)
   - Development vs Production comparison

2. **[Secrets Engines](./02-Secrets-Engines.md)** *(From original docs.md)*
   - KV (Key-Value) v1 and v2
   - Database dynamic secrets
   - AWS dynamic credentials
   - Transit encryption engine
   - PKI certificate authority
   - Practical examples

3. **[Authentication Methods](./03-Authentication-Methods.md)** *(From original docs.md)*
   - Token authentication
   - Userpass (human login)
   - AppRole (machine-to-machine)
   - Kubernetes authentication
   - AWS IAM, Azure AD, GCP
   - Best practices

4. **[Policies and Access Control](./04-Policies-and-Access-Control.md)** *(From original docs.md)*
   - Policy syntax (HCL)
   - Path-based permissions
   - Capabilities (read, write, delete, list)
   - Policy examples
   - Best practices

5. **[Seal and Unseal](./05-Seal-and-Unseal.md)** *(From original docs.md)*
   - Initialization process
   - Shamir's Secret Sharing
   - Manual unseal
   - Auto-unseal with cloud KMS
   - Production considerations

6. **[Docker Setup](./Docs/docker-setup.md)** ✅ Exists
   - Docker Compose configuration
   - Development environment
   - Quick start guide

7. **[Production Deployment](./06-Production-Deployment.md)** *(From original docs.md)*
   - Configuration file (HCL)
   - Storage backends (Consul, Raft, etcd)
   - High availability setup
   - TLS configuration
   - Systemd service
   - Monitoring and logging

8. **[Integration Examples](./07-Integration-Examples.md)** *(From original docs.md)*
   - Node.js integration
   - Python integration
   - Go integration
   - Kubernetes integration
   - CI/CD integration

9. **[Best Practices](./08-Best-Practices.md)** *(From original docs.md)*
   - Security best practices
   - Operational best practices
   - When to use Vault
   - When NOT to use Vault

## Quick Start

### Installation

```bash
# Linux
wget https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip
unzip vault_1.15.5_linux_amd64.zip
sudo mv vault /usr/local/bin/
vault version

# macOS
brew install hashicorp/tap/vault

# Docker
docker pull hashicorp/vault:1.15
```

### Development Mode

```bash
# Start Vault in dev mode
vault server -dev

# In another terminal
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'  # Use token from dev server output

# Test
vault status
```

### Docker Compose

```bash
cd vault-docker
docker compose up -d

# Access UI: http://localhost:8200
# Token: root
```

## Architecture Diagrams

The documentation includes comprehensive ASCII diagrams for:

### 1. High-Level Architecture
- HTTP/HTTPS API Layer
- Authentication Methods
- Policy Engine
- Secrets Engines
- Storage Backend
- Audit Devices

### 2. Core Components
- Barrier (Encryption Layer)
- Seal/Unseal Mechanism
- Token Store
- Lease Management

### 3. Request Flow
- 7-step request processing
- Token validation
- Policy evaluation
- Secrets engine routing
- Audit logging

### 4. Authentication Flow (AppRole)
- Role ID and Secret ID
- Login process
- Token generation
- Secret retrieval

### 5. Seal/Unseal Process
- Initialization
- Shamir's Secret Sharing
- Manual unseal steps
- Auto-unseal with cloud KMS

### 6. Dynamic Secrets
- On-demand credential generation
- Lease management
- Automatic revocation

### 7. High Availability
- Active/Standby nodes
- Load balancer configuration
- Shared storage backend
- Leader election

### 8. Kubernetes Integration
- Init container pattern
- Sidecar container
- ServiceAccount authentication
- Secret injection

### 9. Complete System Design
- Frontend, backend, microservices
- Vault cluster
- External services
- Monitoring and audit

## Learning Path

### Beginner (Week 1)
1. **Understand the Problem**
   - Why secrets management matters
   - Traditional vs Vault approach
   - Core concepts

2. **Install and Setup**
   - Install Vault
   - Run in dev mode
   - Access UI
   - Basic CLI commands

3. **First Secrets**
   - Enable KV secrets engine
   - Store and retrieve secrets
   - Understand paths

### Intermediate (Week 2-3)
4. **Authentication**
   - Token authentication
   - Create users (userpass)
   - AppRole for applications
   - Understand policies

5. **Policies and Access Control**
   - Write policies
   - Apply policies to tokens
   - Test permissions
   - Least privilege principle

6. **Dynamic Secrets**
   - Database secrets engine
   - Generate dynamic credentials
   - Understand leases
   - Renewal and revocation

### Advanced (Week 4-6)
7. **Production Setup**
   - Configuration file
   - Storage backend (Consul/Raft)
   - TLS certificates
   - Initialization and unsealing

8. **High Availability**
   - Multi-node cluster
   - Load balancing
   - Auto-unseal
   - Disaster recovery

9. **Integration**
   - Application integration
   - Kubernetes deployment
   - CI/CD pipelines
   - Monitoring and alerting

## Common Use Cases

### 1. Static Secrets (KV)

```bash
# Enable KV v2
vault secrets enable -path=secret kv-v2

# Store secret
vault kv put secret/myapp/db \
  username=admin \
  password=supersecret

# Read secret
vault kv get secret/myapp/db

# Read specific field
vault kv get -field=password secret/myapp/db
```

### 2. Dynamic Database Credentials

```bash
# Enable database engine
vault secrets enable database

# Configure PostgreSQL connection
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly" \
  connection_url="postgresql://{{username}}:{{password}}@localhost:5432/mydb" \
  username="vault" \
  password="vaultpass"

# Create role
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# Generate credentials
vault read database/creds/readonly
```

### 3. AppRole Authentication

```bash
# Enable AppRole
vault auth enable approle

# Create role
vault write auth/approle/role/myapp \
  token_policies="myapp-policy" \
  token_ttl=1h \
  token_max_ttl=4h

# Get Role ID
vault read auth/approle/role/myapp/role-id

# Generate Secret ID
vault write -f auth/approle/role/myapp/secret-id

# Login
vault write auth/approle/login \
  role_id="xxx" \
  secret_id="yyy"
```

## Vault CLI Reference

### Status and Info

```bash
# Check status
vault status

# Get server info
vault read sys/health

# List enabled secrets engines
vault secrets list

# List enabled auth methods
vault auth list

# List policies
vault policy list
```

### Secrets Operations

```bash
# KV v2 operations
vault kv put secret/path key=value
vault kv get secret/path
vault kv get -field=key secret/path
vault kv delete secret/path
vault kv list secret/

# KV v2 versioning
vault kv get -version=2 secret/path
vault kv rollback -version=1 secret/path
vault kv metadata get secret/path
```

### Token Operations

```bash
# Create token
vault token create -policy=mypolicy -ttl=1h

# Lookup token
vault token lookup

# Renew token
vault token renew

# Revoke token
vault token revoke <token>

# Revoke all tokens for a role
vault token revoke -mode=path auth/approle
```

### Policy Operations

```bash
# Write policy
vault policy write mypolicy policy.hcl

# Read policy
vault policy read mypolicy

# List policies
vault policy list

# Delete policy
vault policy delete mypolicy
```

### Seal/Unseal Operations

```bash
# Initialize Vault
vault operator init

# Unseal (repeat 3 times with different keys)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>

# Seal Vault
vault operator seal

# Check seal status
vault status
```

## Integration Examples

### Node.js

```javascript
import vault from 'node-vault';

const client = vault({
  endpoint: 'http://127.0.0.1:8200',
  token: process.env.VAULT_TOKEN
});

// Read secret
const secret = await client.read('secret/data/myapp/db');
const password = secret.data.data.password;

// Write secret
await client.write('secret/data/myapp/api', {
  data: {
    api_key: 'abc123',
    api_secret: 'xyz789'
  }
});
```

### Python

```python
import hvac

# Initialize client
client = hvac.Client(
    url='http://127.0.0.1:8200',
    token=os.environ['VAULT_TOKEN']
)

# Read secret
secret = client.secrets.kv.v2.read_secret_version(
    path='myapp/db'
)
password = secret['data']['data']['password']

# Write secret
client.secrets.kv.v2.create_or_update_secret(
    path='myapp/api',
    secret=dict(api_key='abc123')
)
```

### Go

```go
import (
    vault "github.com/hashicorp/vault/api"
)

// Create client
config := vault.DefaultConfig()
config.Address = "http://127.0.0.1:8200"
client, _ := vault.NewClient(config)
client.SetToken(os.Getenv("VAULT_TOKEN"))

// Read secret
secret, _ := client.Logical().Read("secret/data/myapp/db")
password := secret.Data["data"].(map[string]interface{})["password"]

// Write secret
data := map[string]interface{}{
    "data": map[string]interface{}{
        "api_key": "abc123",
    },
}
client.Logical().Write("secret/data/myapp/api", data)
```

## Best Practices

### Security

1. **Never use root token in production**
   - Create specific tokens with limited policies
   - Use AppRole or other auth methods

2. **Enable TLS**
   - Always use HTTPS in production
   - Validate certificates

3. **Use short TTLs**
   - Tokens: 1-4 hours
   - Dynamic secrets: 1-24 hours
   - Renew before expiry

4. **Enable audit logging**
   - Log all requests and responses
   - Monitor for suspicious activity
   - Retain logs for compliance

5. **Implement least privilege**
   - One policy per application
   - Minimal required permissions
   - Regular policy audits

### Operations

1. **Use auto-unseal in production**
   - AWS KMS, Azure Key Vault, GCP KMS
   - No manual intervention on restart

2. **Deploy in HA mode**
   - Minimum 3 nodes
   - Load balancer in front
   - Shared storage backend

3. **Backup regularly**
   - Backup storage backend
   - Backup unseal keys (secure location)
   - Test restore procedures

4. **Monitor Vault health**
   - Prometheus metrics
   - Grafana dashboards
   - Alert on seal status, errors

5. **Rotate secrets regularly**
   - Use dynamic secrets when possible
   - Automate rotation for static secrets
   - Update applications gracefully

## Troubleshooting

### Common Issues

**1. Vault is Sealed**
```bash
# Check status
vault status

# Unseal (provide 3 keys)
vault operator unseal
```

**2. Permission Denied**
```bash
# Check token policies
vault token lookup

# Verify policy allows operation
vault policy read <policy-name>
```

**3. Connection Refused**
```bash
# Check Vault is running
systemctl status vault

# Verify VAULT_ADDR
echo $VAULT_ADDR

# Check firewall
sudo ufw status
```

**4. Token Expired**
```bash
# Check token TTL
vault token lookup

# Renew token
vault token renew

# Or create new token
vault login -method=approle
```

## Resources

### Official Documentation
- [Vault Documentation](https://www.vaultproject.io/docs)
- [Vault API](https://www.vaultproject.io/api-docs)
- [Vault Tutorials](https://learn.hashicorp.com/vault)

### Community
- [Vault GitHub](https://github.com/hashicorp/vault)
- [Vault Forum](https://discuss.hashicorp.com/c/vault)
- [Vault Slack](https://hashicorp-community.slack.com)

### Tools
- [Vault Helm Chart](https://github.com/hashicorp/vault-helm)
- [Vault K8s](https://github.com/hashicorp/vault-k8s)
- [Vault CSI Provider](https://github.com/hashicorp/vault-csi-provider)

## When to Use Vault

### ✅ Use Vault When:
- Managing secrets for multiple applications
- Need dynamic credentials
- Compliance requirements (SOC 2, PCI-DSS, HIPAA)
- Microservices architecture
- Cloud-native applications
- Need encryption as a service
- Require audit trail

### ❌ Don't Use Vault When:
- Small hobby project (1-2 secrets)
- No security requirements
- Single application with few secrets
- No operational capacity to manage Vault
- Cost-sensitive (use cloud provider secrets manager)

## Summary

This HashiCorp Vault documentation provides:
- **Comprehensive coverage** from basics to advanced topics
- **Visual diagrams** for architecture understanding
- **Practical examples** for real-world scenarios
- **Best practices** for production deployment
- **Integration guides** for multiple languages
- **Troubleshooting** for common issues

Perfect for DevOps engineers, security teams, and anyone implementing secrets management in modern infrastructure.

---

**Last Updated**: January 6, 2026  
**Vault Version**: 1.15.5  
**Status**: ✅ Fundamentals documented with comprehensive diagrams  
**Next**: Complete remaining topics (Secrets Engines, Auth Methods, Policies, Production)
