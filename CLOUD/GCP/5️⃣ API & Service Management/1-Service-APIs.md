# 1. Service APIs

Understanding Google Cloud Platform APIs and how they enable service functionality.

---

## Overview

```
┌────────────────────────────────────────────────────────┐
│  What is a GCP API?                                    │
├────────────────────────────────────────────────────────┤
│                                                         │
│  An API (Application Programming Interface) is:        │
│  • Interface to interact with GCP services             │
│  • RESTful HTTP or gRPC protocol                       │
│  • Requires enablement per project                     │
│  • Provides programmatic access                        │
│  • Authenticated and authorized                        │
│                                                         │
│  Example: Compute Engine API                           │
│  • Endpoint: compute.googleapis.com                    │
│  • Methods: instances.insert, instances.delete         │
│  • Resources: VMs, disks, networks                     │
│  • Authentication: OAuth 2.0, Service Accounts         │
└────────────────────────────────────────────────────────┘
```

---

## API Architecture

### Request Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  API Request Flow                                                │
└─────────────────────────────────────────────────────────────────┘

Client Application
      │
      ├─ 1. Prepare Request
      │    • API endpoint
      │    • HTTP method (GET, POST, PUT, DELETE)
      │    • Request body (JSON)
      │    • Authentication token
      │
      ▼
┌─────────────────────┐
│  HTTPS Request      │
│  POST https://      │
│  compute.googleapis │
│  .com/compute/v1/   │
│  projects/PROJECT/  │
│  zones/ZONE/        │
│  instances          │
└──────────┬──────────┘
           │
           ├─ 2. Authentication
           │    • Verify credentials
           │    • Check permissions
           │
           ▼
┌─────────────────────┐
│  Google API Gateway │
│  • Rate limiting    │
│  • Request validation│
│  • Routing          │
└──────────┬──────────┘
           │
           ├─ 3. Authorization
           │    • Check IAM permissions
           │    • Verify quotas
           │
           ▼
┌─────────────────────┐
│  Service Backend    │
│  • Process request  │
│  • Perform action   │
│  • Generate response│
└──────────┬──────────┘
           │
           ├─ 4. Response
           │    • HTTP status code
           │    • Response body (JSON)
           │    • Metadata
           │
           ▼
Client Application
```

---

## API Categories

### 1. Compute APIs

```
┌────────────────────────────────────────────────────────┐
│  Compute & Container APIs                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  compute.googleapis.com                                │
│  • Compute Engine (VMs, disks, networks)               │
│  • Instance groups, load balancers                     │
│  • Snapshots, images, machine types                    │
│                                                         │
│  container.googleapis.com                              │
│  • Google Kubernetes Engine (GKE)                      │
│  • Clusters, node pools, operations                    │
│  • Kubernetes API integration                          │
│                                                         │
│  run.googleapis.com                                    │
│  • Cloud Run (serverless containers)                   │
│  • Services, revisions, routes                         │
│  • Automatic scaling                                   │
│                                                         │
│  appengine.googleapis.com                              │
│  • App Engine (PaaS)                                   │
│  • Applications, services, versions                    │
│  • Traffic splitting                                   │
│                                                         │
│  cloudfunctions.googleapis.com                         │
│  • Cloud Functions (FaaS)                              │
│  • Function deployment and invocation                  │
│  • Event triggers                                      │
└────────────────────────────────────────────────────────┘
```

### 2. Storage APIs

```
┌────────────────────────────────────────────────────────┐
│  Storage APIs                                          │
├────────────────────────────────────────────────────────┤
│                                                         │
│  storage.googleapis.com                                │
│  • Cloud Storage (object storage)                      │
│  • Buckets, objects, ACLs                              │
│  • Lifecycle management                                │
│                                                         │
│  file.googleapis.com                                   │
│  • Filestore (managed NFS)                             │
│  • File shares, instances                              │
│  • NFS protocol                                        │
│                                                         │
│  storagetransfer.googleapis.com                        │
│  • Storage Transfer Service                            │
│  • Data migration, backup                              │
│  • Scheduled transfers                                 │
└────────────────────────────────────────────────────────┘
```

### 3. Database APIs

```
┌────────────────────────────────────────────────────────┐
│  Database APIs                                         │
├────────────────────────────────────────────────────────┤
│                                                         │
│  sqladmin.googleapis.com                               │
│  • Cloud SQL (managed MySQL, PostgreSQL, SQL Server)   │
│  • Instances, databases, users                         │
│  • Backups, replicas                                   │
│                                                         │
│  spanner.googleapis.com                                │
│  • Cloud Spanner (global relational database)          │
│  • Instances, databases, sessions                      │
│  • Distributed transactions                            │
│                                                         │
│  firestore.googleapis.com                              │
│  • Firestore (NoSQL document database)                 │
│  • Documents, collections, queries                     │
│  • Real-time updates                                   │
│                                                         │
│  bigtable.googleapis.com                               │
│  • Cloud Bigtable (NoSQL wide-column)                  │
│  • Tables, column families, rows                       │
│  • High throughput                                     │
│                                                         │
│  redis.googleapis.com                                  │
│  • Memorystore for Redis                               │
│  • Instances, operations                               │
│  • In-memory caching                                   │
└────────────────────────────────────────────────────────┘
```

### 4. Networking APIs

```
┌────────────────────────────────────────────────────────┐
│  Networking APIs                                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  compute.googleapis.com (networking components)        │
│  • VPC networks, subnets, routes                       │
│  • Firewall rules, VPN, Cloud NAT                      │
│  • Load balancers, forwarding rules                    │
│                                                         │
│  dns.googleapis.com                                    │
│  • Cloud DNS (managed DNS)                             │
│  • Zones, record sets                                  │
│  • DNSSEC                                              │
│                                                         │
│  servicenetworking.googleapis.com                      │
│  • VPC peering, private services                       │
│  • Service networking connections                      │
│                                                         │
│  networkservices.googleapis.com                        │
│  • Traffic Director, Service Mesh                      │
│  • Advanced networking features                        │
└────────────────────────────────────────────────────────┘
```

### 5. Data & Analytics APIs

```
┌────────────────────────────────────────────────────────┐
│  Data & Analytics APIs                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  bigquery.googleapis.com                               │
│  • BigQuery (data warehouse)                           │
│  • Datasets, tables, jobs                              │
│  • SQL queries, streaming inserts                      │
│                                                         │
│  dataflow.googleapis.com                               │
│  • Dataflow (stream/batch processing)                  │
│  • Jobs, pipelines                                     │
│  • Apache Beam integration                             │
│                                                         │
│  pubsub.googleapis.com                                 │
│  • Pub/Sub (messaging)                                 │
│  • Topics, subscriptions, messages                     │
│  • Real-time event streaming                           │
│                                                         │
│  dataproc.googleapis.com                               │
│  • Dataproc (managed Spark/Hadoop)                     │
│  • Clusters, jobs                                      │
│  • Big data processing                                 │
└────────────────────────────────────────────────────────┘
```

---

## API Versioning

### Version Format

```
┌────────────────────────────────────────────────────────┐
│  API Version Structure                                 │
└────────────────────────────────────────────────────────┘

https://SERVICE.googleapis.com/VERSION/...

Examples:
  https://compute.googleapis.com/compute/v1/projects/...
  https://storage.googleapis.com/storage/v1/b/...
  https://bigquery.googleapis.com/bigquery/v2/projects/...

Version Types:
  • v1, v2, v3: Stable versions (GA)
  • v1beta1, v2beta: Beta versions
  • v1alpha: Alpha versions (experimental)

Version Lifecycle:
  Alpha → Beta → GA (v1) → Deprecated → Shutdown
  
  Alpha: Experimental, may change
  Beta: Feature complete, may have bugs
  GA: Production ready, stable
  Deprecated: Use newer version
  Shutdown: No longer available
```

### Version Selection

```
┌────────────────────────────────────────────────────────┐
│  Choosing API Version                                  │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Production Applications:                              │
│  ✓ Use GA versions (v1, v2)                            │
│  ✓ Stable and supported                                │
│  ✓ Backward compatible                                 │
│  ✓ SLA guarantees                                      │
│                                                         │
│  Testing/Development:                                  │
│  • Beta versions acceptable                            │
│  • Access to new features                              │
│  • May have breaking changes                           │
│                                                         │
│  Experimental:                                         │
│  • Alpha versions only for testing                     │
│  • No production use                                   │
│  • Frequent changes                                    │
│  • No support guarantees                               │
└────────────────────────────────────────────────────────┘
```

---

## API Discovery

### API Library

```bash
# List all available APIs
gcloud services list --available

# Search for specific API
gcloud services list --available --filter="name:compute"

# Get API details
gcloud services describe compute.googleapis.com

# Output:
# name: compute.googleapis.com
# title: Compute Engine API
# documentation: https://cloud.google.com/compute/
# state: ENABLED
```

### API Explorer

```
Console Tool: API Explorer
URL: https://developers.google.com/apis-explorer

Features:
  • Interactive API testing
  • Browse all GCP APIs
  • Try API methods
  • See request/response
  • Generate code samples
  • No coding required

Example Usage:
1. Navigate to API Explorer
2. Select "Compute Engine API"
3. Choose method: compute.instances.list
4. Fill parameters: project, zone
5. Click "Execute"
6. View response
```

---

## API Endpoints

### Regional Endpoints

```
┌────────────────────────────────────────────────────────┐
│  Global vs Regional Endpoints                          │
└────────────────────────────────────────────────────────┘

Global Endpoint (Default):
  https://compute.googleapis.com
  • Routes to nearest Google datacenter
  • Automatic load balancing
  • Best for most use cases

Regional Endpoints:
  https://us-central1-compute.googleapis.com
  https://europe-west1-compute.googleapis.com
  https://asia-southeast1-compute.googleapis.com
  
  Benefits:
  • Lower latency (closer to resources)
  • Data residency compliance
  • Explicit region control
  
  Use Cases:
  • Latency-sensitive applications
  • Regulatory requirements
  • Regional failover

Example:
  # Global endpoint
  curl https://compute.googleapis.com/compute/v1/projects/PROJECT/zones
  
  # Regional endpoint
  curl https://us-central1-compute.googleapis.com/compute/v1/projects/PROJECT/zones
```

---

## API Protocols

### REST API

```
┌────────────────────────────────────────────────────────┐
│  RESTful API Characteristics                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Protocol: HTTPS                                       │
│  Format: JSON                                          │
│  Methods: GET, POST, PUT, PATCH, DELETE                │
│                                                         │
│  Example: Create VM Instance                           │
│  POST https://compute.googleapis.com/compute/v1/       │
│       projects/PROJECT/zones/ZONE/instances            │
│                                                         │
│  Request Body:                                         │
│  {                                                     │
│    "name": "web-server-1",                            │
│    "machineType": "zones/ZONE/machineTypes/e2-medium",│
│    "disks": [...],                                    │
│    "networkInterfaces": [...]                         │
│  }                                                     │
│                                                         │
│  Response:                                             │
│  {                                                     │
│    "kind": "compute#operation",                       │
│    "id": "123456789",                                 │
│    "status": "RUNNING",                               │
│    "operationType": "insert"                          │
│  }                                                     │
└────────────────────────────────────────────────────────┘
```

### gRPC API

```
┌────────────────────────────────────────────────────────┐
│  gRPC API Characteristics                              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Protocol: HTTP/2                                      │
│  Format: Protocol Buffers (binary)                     │
│  Features: Streaming, bidirectional                    │
│                                                         │
│  Benefits:                                             │
│  • Faster than REST (binary format)                    │
│  • Smaller payload size                                │
│  • Built-in streaming                                  │
│  • Strong typing                                       │
│  • Better for microservices                            │
│                                                         │
│  Use Cases:                                            │
│  • High-performance applications                       │
│  • Real-time data streaming                            │
│  • Microservice communication                          │
│  • Mobile applications                                 │
│                                                         │
│  Example Services with gRPC:                           │
│  • Cloud Spanner                                       │
│  • Cloud Bigtable                                      │
│  • Pub/Sub                                             │
│  • Firestore                                           │
└────────────────────────────────────────────────────────┘
```

---

## API Authentication

### Methods

```
┌────────────────────────────────────────────────────────┐
│  Authentication Methods                                │
└────────────────────────────────────────────────────────┘

1. API Keys
├─ Simple string token
├─ For public APIs only
├─ No user context
└─ Example: Maps API, Translation API

  curl "https://translation.googleapis.com/language/translate/v2?key=API_KEY"

2. OAuth 2.0
├─ User authentication
├─ Delegated access
├─ Access tokens
└─ For user-facing applications

  Authorization: Bearer ya29.a0AfH6SMBx...

3. Service Accounts
├─ Application identity
├─ JSON key file or Workload Identity
├─ Server-to-server
└─ Most common for GCP services

  gcloud auth activate-service-account --key-file=key.json

4. Application Default Credentials (ADC)
├─ Automatic credential discovery
├─ Environment-aware
├─ Recommended approach
└─ Works everywhere

  export GOOGLE_APPLICATION_CREDENTIALS="key.json"
```

---

## API Rate Limits

### Understanding Limits

```
┌────────────────────────────────────────────────────────┐
│  Rate Limit Types                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Per-User Limits:                                      │
│  • Requests per user per second                        │
│  • Prevents single user abuse                          │
│  • Example: 10 requests/second                         │
│                                                         │
│  Per-Project Limits:                                   │
│  • Total requests per project                          │
│  • Shared across all users                             │
│  • Example: 1,000 requests/second                      │
│                                                         │
│  Quota Limits:                                         │
│  • Daily/monthly limits                                │
│  • Resource allocation limits                          │
│  • Example: 1M requests/day                            │
│                                                         │
│  Handling Rate Limits:                                 │
│  • Implement exponential backoff                       │
│  • Cache responses when possible                       │
│  • Use batch operations                                │
│  • Request quota increases                             │
└────────────────────────────────────────────────────────┘
```

---

## Best Practices

```
✓ Use latest stable API version (v1, v2)
✓ Implement proper error handling
✓ Use exponential backoff for retries
✓ Cache API responses when appropriate
✓ Use batch operations for multiple requests
✓ Monitor API usage and costs
✓ Use service accounts for applications
✓ Implement request timeouts
✓ Use regional endpoints for lower latency
✓ Keep API credentials secure
```

---

## Next Steps

- **Enabling APIs** → [2-Enabling-APIs.md](./2-Enabling-APIs.md)
- **Service Quotas** → [3-Service-Quotas.md](./3-Service-Quotas.md)
- **API Gateway** → [4-API-Gateway.md](./4-API-Gateway.md)

---
