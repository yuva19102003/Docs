# HashiCorp Vault Fundamentals - Complete Guide

## Overview

HashiCorp Vault is a secrets management tool that provides secure storage, access control, and distribution of sensitive data such as passwords, API keys, and certificates.

## Table of Contents

1. [What Problem Vault Solves](#what-problem-vault-solves)
2. [Core Concepts](#core-concepts)
3. [Vault Architecture](#vault-architecture)
4. [Installation](#installation)
5. [Getting Started](#getting-started)

---

## What Problem Vault Solves

### Without Vault ❌

```
┌─────────────────────────────────────────────────────────────────┐
│              Traditional Secrets Management                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Problems:                                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Secrets in .env files                                │  │
│  │     DATABASE_PASSWORD=supersecret123                     │  │
│  │     API_KEY=abc123xyz                                    │  │
│  │                                                           │  │
│  │  2. Hardcoded in source code                             │  │
│  │     const password = "hardcoded_password";               │  │
│  │                                                           │  │
│  │  3. Stored in CI/CD systems                              │  │
│  │     GitHub Secrets, Jenkins credentials                  │  │
│  │                                                           │  │
│  │  4. Long-lived credentials                               │  │
│  │     Same password for months/years                       │  │
│  │                                                           │  │
│  │  5. Manual rotation                                      │  │
│  │     Update password → Update everywhere                  │  │
│  │                                                           │  │
│  │  6. No audit trail                                       │  │
│  │     Who accessed what? When? Unknown.                    │  │
│  │                                                           │  │
│  │  7. Shared credentials                                   │  │
│  │     Same password across multiple apps                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Risks:                                                          │
│  • Secrets leaked in Git history                                │
│  • Exposed in logs                                              │
│  • Difficult to rotate                                          │
│  • No access control                                            │
│  • Compliance violations                                        │
└─────────────────────────────────────────────────────────────────┘
```

### With Vault ✅

```
┌─────────────────────────────────────────────────────────────────┐
│              Vault Secrets Management                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Solutions:                                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  1. Central Secret Store                                 │  │
│  │     ┌──────────────────────────────────────────────┐     │  │
│  │     │         HashiCorp Vault                      │     │  │
│  │     │  • All secrets in one place                  │     │  │
│  │     │  • Encrypted at rest                         │     │  │
│  │     │  • Single source of truth                    │     │  │
│  │     └──────────────────────────────────────────────┘     │  │
│  │                                                           │  │
│  │  2. Fine-grained Access Control                          │  │
│  │     • Policy-based permissions                           │  │
│  │     • Role-based access (RBAC)                           │  │
│  │     • Least privilege principle                          │  │
│  │                                                           │  │
│  │  3. Dynamic Secrets                                      │  │
│  │     • Generate credentials on-demand                     │  │
│  │     • Short-lived (TTL: 1 hour)                          │  │
│  │     • Auto-revoked after expiry                          │  │
│  │                                                           │  │
│  │  4. Automatic Rotation                                   │  │
│  │     • Secrets rotated automatically                      │  │
│  │     • No manual intervention                             │  │
│  │     • Zero downtime                                      │  │
│  │                                                           │  │
│  │  5. Complete Audit Trail                                 │  │
│  │     • Who accessed what                                  │  │
│  │     • When and from where                                │  │
│  │     • All actions logged                                 │  │
│  │                                                           │  │
│  │  6. Encryption as a Service                              │  │
│  │     • Encrypt/decrypt data                               │  │
│  │     • Key management                                     │  │
│  │     • No keys in application                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Benefits:                                                       │
│  ✅ Single source of truth for secrets                          │
│  ✅ Reduced attack surface                                      │
│  ✅ Compliance ready (SOC 2, PCI-DSS, HIPAA)                   │
│  ✅ Automated secret lifecycle                                  │
│  ✅ Zero-trust security model                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### Essential Terminology

| Concept | Explanation | Example |
|---------|-------------|---------|
| **Secret** | Sensitive data that needs protection | Password, API key, certificate |
| **Secret Engine** | Component that stores or generates secrets | KV (Key-Value), Database, AWS |
| **Auth Method** | How users/applications authenticate | Token, AppRole, Kubernetes |
| **Policy** | Defines what access is allowed | Read secret/data/db, Write secret/data/app |
| **Token** | Temporary access credential | s.1234abcd (client token) |
| **Seal** | Protects master encryption key | Vault starts in sealed state |
| **Unseal** | Unlocks Vault for operation | Requires unseal keys |
| **Lease** | Expiry time of a secret | TTL: 3600s (1 hour) |
| **Path** | Location of secret in Vault | secret/data/myapp/db |
| **Role** | Named set of permissions | database/roles/readonly |

### Vault Concepts Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Vault Core Concepts                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Authentication                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  User/App → Auth Method → Token                          │  │
│  │                                                           │  │
│  │  Examples:                                                │  │
│  │  • Username/Password → Token                             │  │
│  │  • AppRole (Role ID + Secret ID) → Token                 │  │
│  │  • Kubernetes ServiceAccount → Token                     │  │
│  │  • AWS IAM → Token                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Authorization (Policy)                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Token → Policies → Permissions                          │  │
│  │                                                           │  │
│  │  Policy Example:                                          │  │
│  │  path "secret/data/myapp/*" {                            │  │
│  │    capabilities = ["read", "list"]                       │  │
│  │  }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Secrets Engine                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Token + Policy → Access Secret                          │  │
│  │                                                           │  │
│  │  Types:                                                   │  │
│  │  • KV: Static secrets (passwords, keys)                  │  │
│  │  • Database: Dynamic DB credentials                      │  │
│  │  • AWS: Dynamic AWS credentials                          │  │
│  │  • Transit: Encryption as a service                      │  │
│  │  • PKI: Certificate generation                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Lease Management                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Secret + Lease (TTL) → Auto-revocation                  │  │
│  │                                                           │  │
│  │  • Secret valid for TTL duration                         │  │
│  │  • Can be renewed before expiry                          │  │
│  │  • Auto-revoked after expiry                             │  │
│  │  • Manual revocation possible                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▼                                      │
│  Audit Logging                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  All operations logged                                    │  │
│  │  • Request details                                        │  │
│  │  • Response (secrets redacted)                           │  │
│  │  • Timestamp, source IP                                  │  │
│  │  • User/token identity                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Vault Architecture

### High-Level Architecture

The architecture diagram from the original file has been preserved and is already comprehensive. Here's the component breakdown:

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    Vault Server Components                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. HTTP/HTTPS API Layer (Port 8200)                            │
│     • RESTful API interface                                     │
│     • TLS encryption                                            │
│     • Client communication endpoint                             │
│                                                                  │
│  2. Authentication Layer                                         │
│     • Token Auth (default)                                      │
│     • AppRole (machine-to-machine)                              │
│     • Kubernetes (K8s ServiceAccount)                           │
│     • LDAP/Active Directory                                     │
│     • AWS IAM, Azure AD, GCP IAM                                │
│     • GitHub, JWT, OIDC                                         │
│                                                                  │
│  3. Policy Engine (ACL)                                          │
│     • Path-based permissions                                    │
│     • Capability-based (read, write, delete, list)              │
│     • Policy inheritance                                        │
│     • Deny by default                                           │
│                                                                  │
│  4. Secrets Engines                                              │
│     • KV v1/v2 (Key-Value store)                                │
│     • Database (dynamic credentials)                            │
│     • AWS, Azure, GCP (cloud credentials)                       │
│     • Transit (encryption as a service)                         │
│     • PKI (certificate authority)                               │
│     • SSH (SSH key signing)                                     │
│                                                                  │
│  5. Storage Backend (Encrypted)                                  │
│     • Consul (recommended for HA)                               │
│     • etcd                                                      │
│     • Amazon S3                                                 │
│     • File system                                               │
│     • Raft (integrated storage)                                 │
│                                                                  │
│  6. Audit Devices                                                │
│     • File audit                                                │
│     • Syslog audit                                              │
│     • Socket audit                                              │
│     • All requests/responses logged                             │
│                                                                  │
│  7. Barrier (Encryption Layer)                                   │
│     • AES-256-GCM encryption                                    │
│     • All data encrypted at rest                                │
│     • Master key protection                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  Vault Request/Response Flow                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Client Request                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  curl -H "X-Vault-Token: s.xxx" \                        │  │
│  │       https://vault:8200/v1/secret/data/myapp            │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         │                                       │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 1: TLS Termination                                 │  │
│  │  • Decrypt HTTPS traffic                                 │  │
│  │  • Validate certificate                                  │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 2: Token Validation                                │  │
│  │  • Verify token exists                                   │  │
│  │  • Check token TTL                                       │  │
│  │  • Ensure not revoked                                    │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 3: Policy Evaluation                               │  │
│  │  • Load policies for token                               │  │
│  │  • Check path permissions                                │  │
│  │  • Verify capabilities (read/write/delete)               │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 4: Route to Secrets Engine                         │  │
│  │  • Identify target engine (KV, Database, etc.)           │  │
│  │  • Execute engine logic                                  │  │
│  │  • Generate or retrieve secret                           │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 5: Storage Backend Access                          │  │
│  │  • Decrypt data from storage                             │  │
│  │  • Apply barrier encryption                              │  │
│  │  • Return decrypted secret                               │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 6: Lease Assignment                                │  │
│  │  • Assign TTL to secret                                  │  │
│  │  • Create lease ID                                       │  │
│  │  • Schedule auto-revocation                              │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Step 7: Audit Logging                                   │  │
│  │  • Log request (path, method, token)                     │  │
│  │  • Log response (status, lease)                          │  │
│  │  • Secrets redacted in logs                              │  │
│  └──────────────────────┬───────────────────────────────────┘  │
│                         ▼                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Response to Client                                      │  │
│  │  {                                                        │  │
│  │    "data": { "password": "secret123" },                  │  │
│  │    "lease_id": "secret/data/myapp/abc123",               │  │
│  │    "lease_duration": 3600                                │  │
│  │  }                                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Installation

### Prerequisites

- Linux, macOS, or Windows
- 1GB RAM minimum (2GB+ recommended)
- Network access to download Vault binary

### Installation Methods

#### 1. Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install -y unzip wget

# Download Vault (check latest version at releases.hashicorp.com)
wget https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip

# Extract binary
unzip vault_1.15.5_linux_amd64.zip

# Move to system path
sudo mv vault /usr/local/bin/

# Verify installation
vault version

# Output: Vault v1.15.5
```

#### 2. macOS

```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/vault

# Verify installation
vault version
```

#### 3. Windows

```powershell
# Download from https://www.vaultproject.io/downloads
# Extract to C:\vault\
# Add to PATH environment variable

# Verify
vault version
```

#### 4. Docker

```bash
# Pull Vault image
docker pull hashicorp/vault:1.15

# Run in dev mode
docker run --cap-add=IPC_LOCK -d --name=vault -p 8200:8200 hashicorp/vault:1.15

# Verify
docker ps
```

---

## Getting Started

### Development Mode (Learning)

**⚠️ Warning**: Dev mode is for learning only. Data is not persisted and Vault is auto-unsealed.

```bash
# Start Vault in dev mode
vault server -dev

# Output shows:
# - Root Token: hvs.xxxxx
# - Unseal Key: (not needed in dev mode)
# - Address: http://127.0.0.1:8200
```

### Set Environment Variables

```bash
# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Set root token (from dev server output)
export VAULT_TOKEN='hvs.xxxxx'

# Verify connection
vault status
```

### Expected Output

```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.15.5
Storage Type    inmem
Cluster Name    vault-cluster-xxxxx
Cluster ID      xxxxx-xxxxx-xxxxx
HA Enabled      false
```

### Access Vault UI

```bash
# Open browser
http://127.0.0.1:8200

# Login with root token
Token: hvs.xxxxx
```

### First Commands

```bash
# Check status
vault status

# List enabled secrets engines
vault secrets list

# List enabled auth methods
vault auth list

# Get help
vault --help
vault kv --help
```

---

## Development vs Production

### Development Mode

```
┌─────────────────────────────────────────────────────────────────┐
│                    Development Mode                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Characteristics:                                                │
│  ✅ Auto-initialized                                            │
│  ✅ Auto-unsealed                                               │
│  ✅ In-memory storage                                           │
│  ✅ Root token provided                                         │
│  ✅ HTTP (no TLS)                                               │
│  ✅ Single command to start                                     │
│                                                                  │
│  ❌ Data not persisted                                          │
│  ❌ Not secure                                                  │
│  ❌ No HA support                                               │
│  ❌ Lost on restart                                             │
│                                                                  │
│  Use For:                                                        │
│  • Learning Vault                                               │
│  • Testing configurations                                       │
│  • Development                                                  │
│  • Proof of concepts                                            │
└─────────────────────────────────────────────────────────────────┘
```

### Production Mode

```
┌─────────────────────────────────────────────────────────────────┐
│                    Production Mode                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Requirements:                                                   │
│  ✅ Configuration file (HCL)                                    │
│  ✅ Persistent storage backend                                  │
│  ✅ TLS certificates                                            │
│  ✅ Manual initialization                                       │
│  ✅ Manual unsealing (or auto-unseal)                           │
│  ✅ High availability setup                                     │
│  ✅ Audit logging enabled                                       │
│  ✅ Backup strategy                                             │
│                                                                  │
│  Features:                                                       │
│  • Data persisted to storage                                    │
│  • Encrypted at rest                                            │
│  • TLS encryption in transit                                    │
│  • Multiple Vault nodes (HA)                                    │
│  • Auto-unseal with cloud KMS                                   │
│  • Complete audit trail                                         │
│                                                                  │
│  Use For:                                                        │
│  • Production workloads                                         │
│  • Sensitive data                                               │
│  • Compliance requirements                                      │
│  • Enterprise deployments                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Summary

- **Vault** solves secrets management problems
- **Central store** for all sensitive data
- **Dynamic secrets** with automatic rotation
- **Fine-grained access control** with policies
- **Complete audit trail** for compliance
- **Multiple auth methods** for different use cases
- **Encryption as a service** for data protection
- **Dev mode** for learning, **Production mode** for real workloads

HashiCorp Vault is the industry standard for secrets management in modern cloud-native applications.
