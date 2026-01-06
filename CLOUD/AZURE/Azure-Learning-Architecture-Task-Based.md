# Azure Learning – Architecture / Task Based (with Services)

---

## 1️⃣ Static Website Hosting (Global, Cheap, Secure)

**Task**

* Host static pages
* Global delivery
* Custom domain + HTTPS
* Block direct storage access

**Azure Services**

* Azure Storage Account (Static Website)
* Azure CDN
* Azure DNS
* Azure Certificate (Managed)

---

## 2️⃣ Serverless Backend API (No Servers)

**Task**

* REST API
* Auto-scale
* Pay per request

**Azure Services**

* Azure Functions (HTTP Trigger)
* Azure API Management (optional)
* Azure Application Insights

---

## 3️⃣ Serverless App + Database

**Task**

* Persistent data
* Secure DB access
* No servers

**Azure Services**

* Azure Functions
* Azure Cosmos DB **or** Azure SQL Database
* Azure Key Vault
* Managed Identity

---

## 4️⃣ Full Web Application (Frontend + Backend)

**Task**

* Public frontend
* Private backend
* Secure communication
* CI/CD

**Azure Services**

* Azure Static Web Apps **or** Azure Storage (frontend)
* Azure App Service **or** Azure Functions (backend)
* Azure VNet Integration
* Azure Private Endpoint
* GitHub Actions

---

## 5️⃣ File Upload & Media Platform

**Task**

* Upload images/videos
* Private storage
* Preview via URL
* Time-limited access

**Azure Services**

* Azure Blob Storage
* Azure CDN
* Azure Functions (upload API)
* Shared Access Signatures (SAS)

---

## 6️⃣ Authentication & Authorization

**Task**

* User login
* Role-based access
* Token-based security

**Azure Services**

* Microsoft Entra ID (Azure AD)
* Azure Static Web Apps Auth
* Azure App Service Authentication
* OAuth 2.0 / OpenID Connect

---

## 7️⃣ Private Backend (Zero Public Exposure)

**Task**

* Backend not internet-facing
* Access only from frontend or internal services

**Azure Services**

* Azure App Service (Private)
* Azure VNet
* Azure Private Endpoint
* Network Security Groups (NSG)

---

## 8️⃣ Traditional Server-Based Application

**Task**

* Legacy app
* Full OS access
* Manual configuration

**Azure Services**

* Azure Virtual Machines
* Azure VNet
* Network Security Groups
* Azure Bastion (optional)

---

## 9️⃣ Highly Available Web Application

**Task**

* No single point of failure
* Auto-scaling

**Azure Services**

* Azure Load Balancer (L4)
* Azure Application Gateway (L7)
* Virtual Machine Scale Sets
* Availability Zones

---

## 🔟 Global Application with Failover

**Task**

* Multi-region
* Automatic traffic routing
* Failover on outage

**Azure Services**

* Azure Traffic Manager
* Azure Front Door
* Multi-region App Service / Functions

---

## 1️⃣1️⃣ Background Processing System

**Task**

* Async jobs
* Retry handling
* Dead-letter queue

**Azure Services**

* Azure Storage Queues **or** Service Bus
* Azure Functions (Queue Trigger)
* Application Insights

---

## 1️⃣2️⃣ Secure Secrets Management

**Task**

* No secrets in code
* Identity-based access

**Azure Services**

* Azure Key Vault
* Managed Identity
* Azure RBAC

---

## 1️⃣3️⃣ Observability & Alerting

**Task**

* Central logs
* Metrics
* Alerts

**Azure Services**

* Azure Monitor
* Log Analytics
* Application Insights
* Alert Rules

---

## 1️⃣4️⃣ Disaster Recovery & Backup

**Task**

* Data protection
* Regional recovery

**Azure Services**

* Azure Backup
* Azure Site Recovery
* Geo-redundant Storage (GRS)

---

## 1️⃣5️⃣ Infrastructure as Code

**Task**

* Reproducible infrastructure
* Environment-based deployment

**Azure Services / Tools**

* Bicep
* ARM Templates
* Terraform
* Azure DevOps / GitHub Actions

---

## 1️⃣6️⃣ Cost Optimization Scenario

**Task**

* Reduce cost
* Detect unused resources

**Azure Services**

* Azure Cost Management
* Azure Budgets
* Azure Advisor
* Auto-shutdown (Automation)

---

## 1️⃣7️⃣ Hybrid / On-Prem Integration

**Task**

* Manage on-prem servers from cloud

**Azure Services**

* Azure Arc
* Site-to-Site VPN
* Azure Policy

---

## 1️⃣8️⃣ Containerized Application Platform

**Task**

* Build once, run anywhere
* Secure image storage

**Azure Services**

* Docker
* Azure Container Registry (ACR)
* Azure App Service (Containers)

---

## 1️⃣9️⃣ Kubernetes Platform (Advanced)

**Task**

* Microservices
* Auto-scaling
* Self-healing

**Azure Services**

* Azure Kubernetes Service (AKS)
* Azure Ingress Controller
* Azure Monitor for Containers
* Azure Key Vault CSI Driver

---

## 2️⃣0️⃣ FINAL SOLUTION ARCHITECT CAPSTONE

**Task**

* Secure
* Multi-region
* Automated
* Cost-optimized

**Azure Services**

* Azure Front Door
* Azure Static Web Apps / Storage
* Azure App Service / Functions
* Azure PostgreSQL / Cosmos DB
* Azure VNet + Private Endpoints
* Azure Monitor + Backup
* Bicep / Terraform

---