# 🔴 Red Hat OpenShift Components (Explained Clearly)

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-3.11-Architecture-en-US/images/77ef0c49ff2c038f43eda51cf99d4598/architecture_overview.png)

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-4.11-Architecture-en-US/images/01a511f42d82a6519a600b5c8e91724f/hosted-control-planes-diagram.png)

![Image](https://access.redhat.com/webassets/avalon/d/OpenShift_Container_Platform-4.11-Nodes-en-US/images/32829db347683a8f7181b419b4657e91/295_OpenShift_Nodes_Overview_1222.png)

![Image](https://www.redhat.com/rhdc/managed-files/ohc/BLOG%20Openshift%20Architectures%20for%20the%20Edge.png)

Since you're already working with AWS infra, think of OpenShift as a **managed Kubernetes control system with extra enterprise layers**.

---

# 🏗️ 1️⃣ Control Plane (Master Nodes)

The brain of the cluster.

Built on top of **Kubernetes**

### Core Kubernetes Components:

| Component          | Purpose                 |
| ------------------ | ----------------------- |
| API Server         | Entry point to cluster  |
| Scheduler          | Decides where Pods run  |
| Controller Manager | Maintains desired state |
| etcd               | Cluster database        |

OpenShift adds:

* Authentication server
* Web Console
* RBAC management
* Security policies

---

# 🖥️ 2️⃣ Worker Nodes

Where your applications run.

Each worker node contains:

* kubelet
* kube-proxy
* Container runtime (CRI-O)
* Pods (your apps)

Example:
Your Medical backend container runs inside a Pod → inside Worker Node.

---

# 🌐 3️⃣ Routing Layer (OpenShift Feature)

Instead of Kubernetes Ingress, OpenShift uses:

## 👉 Routes

* Exposes services to external world
* Uses HAProxy router internally
* Auto generates public URL

Example:

```
backend-medical.apps.sandbox.openshift.com
```

---

# 📦 4️⃣ Image Management

OpenShift has built-in image handling.

### ImageStreams

* Track container images
* Auto redeploy when new image pushed

### Internal Registry

* Stores built images inside cluster

This is powerful for CI/CD.

---

# 🏗️ 5️⃣ Build System

OpenShift supports:

## BuildConfig

Build container images directly from:

* GitHub repo
* Dockerfile
* Source code

No external Docker needed.

---

# 🔐 6️⃣ Security Components (Very Important)

OpenShift is stricter than Kubernetes.

* Security Context Constraints (SCC)
* RBAC
* OAuth authentication
* Project isolation

Containers **don’t run as root by default** (important interview point).

---

# 🔁 7️⃣ CI/CD (Pipelines)

Built using:

## Tekton

OpenShift Pipelines allows:

* Git → Build → Deploy automation
* Full DevOps workflow inside cluster

---

# 🗄️ 8️⃣ Storage Layer

Supports:

* Persistent Volumes (PV)
* Persistent Volume Claims (PVC)
* Dynamic provisioning
* Cloud storage integration (EBS, Azure Disk, etc.)

---

# 🎯 Complete Component Flow

User → Route → Service → Pod → Worker Node
Control Plane manages everything.

---

# 🔥 Interview Summary (Very Important)

OpenShift Components include:

1. Control Plane (API server, Scheduler, etcd)
2. Worker Nodes
3. Routes
4. ImageStreams
5. BuildConfigs
6. Internal Registry
7. Security (SCC, RBAC)
8. Pipelines (Tekton)

---
