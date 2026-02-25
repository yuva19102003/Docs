# OpenShift

## Overview

Red Hat OpenShift is an enterprise Kubernetes platform that provides developer and operational tools for building, deploying, and managing containerized applications at scale.

## What is OpenShift?

OpenShift is a comprehensive container application platform built on Kubernetes that adds:
- Developer-friendly tools and workflows
- Enhanced security features
- Built-in CI/CD capabilities
- Enterprise support and lifecycle management
- Integrated monitoring and logging
- Multi-tenancy and project management

## Key Features

### Developer Experience
- Source-to-Image (S2I) builds
- Built-in CI/CD with Tekton Pipelines
- Developer console and CLI tools
- Application templates and catalogs
- Hot reload and live debugging

### Operations
- Automated installation and updates
- Cluster management and scaling
- Built-in monitoring with Prometheus
- Centralized logging
- Backup and disaster recovery

### Security
- Security Context Constraints (SCC)
- Role-Based Access Control (RBAC)
- Network policies and isolation
- Image scanning and signing
- Secrets management

### Networking
- Software-Defined Networking (SDN)
- Routes for external access
- Service mesh integration (Istio)
- Load balancing
- Network policies

## OpenShift vs Kubernetes

| Feature | Kubernetes | OpenShift |
|---------|-----------|-----------|
| Installation | Manual/Complex | Automated installer |
| Updates | Manual | Automated over-the-air |
| Security | Basic RBAC | SCC + Enhanced RBAC |
| Networking | Requires CNI plugin | Built-in SDN |
| Routing | Ingress controller | Routes + Ingress |
| CI/CD | External tools | Built-in Tekton |
| Monitoring | Manual setup | Built-in Prometheus |
| Registry | External | Integrated registry |
| Console | Basic dashboard | Full-featured web console |
| Support | Community | Enterprise support |

## OpenShift Editions

### OpenShift Container Platform (OCP)
- Self-managed on-premises or cloud
- Full control over infrastructure
- Enterprise support from Red Hat

### OpenShift Dedicated
- Managed service on AWS or GCP
- Red Hat manages control plane
- Customer manages applications

### Azure Red Hat OpenShift (ARO)
- Jointly managed by Microsoft and Red Hat
- Native Azure integration
- Simplified billing

### Red Hat OpenShift Service on AWS (ROSA)
- Managed service on AWS
- Native AWS integration
- Pay-as-you-go pricing

## Architecture Components

### Control Plane
- API Server
- etcd
- Controller Manager
- Scheduler
- Cloud Controller Manager

### Worker Nodes
- Kubelet
- Container Runtime (CRI-O)
- Kube Proxy
- Node Agent

### OpenShift-Specific Components
- OpenShift API Server
- OpenShift Controller Manager
- OAuth Server
- Image Registry
- Router (HAProxy)
- Monitoring Stack
- Logging Stack

## Getting Started

### Prerequisites
- Understanding of containers and Kubernetes
- Linux command line knowledge
- Basic networking concepts
- YAML syntax familiarity

### Installation Options
1. **OpenShift Local** (formerly CodeReady Containers)
   - Local development environment
   - Single-node cluster on laptop

2. **Installer-Provisioned Infrastructure (IPI)**
   - Automated installation
   - Supports AWS, Azure, GCP, VMware

3. **User-Provisioned Infrastructure (UPI)**
   - Manual infrastructure setup
   - More control over configuration

4. **Managed Services**
   - ROSA, ARO, OpenShift Dedicated
   - No installation required

## Core Concepts

### Projects
OpenShift projects extend Kubernetes namespaces with additional features:
- Multi-tenancy
- Resource quotas
- Network isolation
- RBAC integration

### BuildConfigs
Define how to build container images:
- Source-to-Image (S2I)
- Docker builds
- Custom builds
- Pipeline builds

### DeploymentConfigs
Extend Kubernetes Deployments with:
- Deployment strategies (Rolling, Recreate, Custom)
- Lifecycle hooks
- Automatic rollbacks
- Triggers

### Routes
Expose services externally:
- Hostname-based routing
- Path-based routing
- TLS termination options
- Load balancing

### ImageStreams
Manage container images:
- Image versioning
- Automatic updates
- Image promotion
- Trigger deployments

## Use Cases

### Application Development
- Rapid prototyping
- Microservices development
- CI/CD automation
- Multi-environment deployments

### Enterprise Applications
- Legacy application modernization
- Hybrid cloud deployments
- Multi-tenancy
- Compliance and security

### DevOps and Platform Engineering
- Self-service developer platforms
- Standardized deployment pipelines
- Infrastructure as Code
- GitOps workflows

## Learning Path

1. **Fundamentals**
   - Kubernetes basics
   - Container concepts
   - YAML configuration

2. **OpenShift Basics**
   - Installation and setup
   - Projects and applications
   - CLI and web console

3. **Development**
   - Building applications
   - Deployment strategies
   - Routes and services

4. **Operations**
   - Monitoring and logging
   - Security and RBAC
   - Storage management

5. **Advanced Topics**
   - CI/CD pipelines
   - Service mesh
   - Operators
   - Multi-cluster management

## Resources

### Official Documentation
- [OpenShift Documentation](https://docs.openshift.com/)
- [OpenShift Blog](https://www.openshift.com/blog)
- [Red Hat Developer](https://developers.redhat.com/)

### Training
- Red Hat OpenShift Administration (DO280)
- Red Hat OpenShift Development (DO288)
- Red Hat Certified Specialist in OpenShift

### Community
- [OpenShift Commons](https://commons.openshift.org/)
- [GitHub - OpenShift](https://github.com/openshift)
- [Stack Overflow - OpenShift](https://stackoverflow.com/questions/tagged/openshift)

## Next Steps

1. Review the [Overview](0-Overview.md) for detailed introduction
2. Learn about [Components](1-Components.md) and [Architecture](2-Architecture.md)
3. Get hands-on with [OpenShift CLI](3-OC.md)
4. Deploy your first [Web Service](4-Deploy-Web-service.md)
5. Explore [Projects & Namespaces](5-Projects-Namespaces.md)
6. Configure [Routes & Ingress](6-Routes-Ingress.md)
7. Manage [Storage](7-Storage.md)
8. Implement [Security](8-Security.md)
9. Set up [Monitoring & Logging](9-Monitoring-Logging.md)
10. Build [CI/CD Pipelines](10-CI-CD.md)
