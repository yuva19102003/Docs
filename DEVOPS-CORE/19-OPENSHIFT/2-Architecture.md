# 🏗️ 1️⃣ OpenShift Architecture

OpenShift is built on top of **Kubernetes** but adds enterprise layers.

It has **4 main layers**:

---

## 🧠 A. Control Plane (Master Layer)

Brain of the cluster.

### Core Components:

* API Server → Entry point (kubectl / oc talk here)
* Scheduler → Decides where Pods run
* Controller Manager → Maintains desired state
* etcd → Stores cluster data

### OpenShift Adds:

* OAuth Server (authentication)
* Web Console
* RBAC policies
* Security Context Constraints (SCC)

👉 If API server is down → cluster is unusable.

---

## 🖥️ B. Worker Nodes (Application Layer)

Where your containers run.

Each worker node has:

* kubelet
* kube-proxy
* CRI-O (container runtime)
* Pods

Your:

* Backend container
* Frontend container
* MongoDB container

All run inside Pods here.

---

## 🌐 C. Routing Layer (OpenShift Special)

Instead of Kubernetes Ingress, OpenShift uses:

## Routes

* Exposes application externally
* Uses HAProxy router
* Auto creates public URL

Example:

```
backend.apps.sandbox.openshift.com
```

Flow:
User → Route → Service → Pod

---

## 📦 D. Image & Build Layer

OpenShift includes built-in CI/CD components:

### ImageStreams

Tracks image versions.

### BuildConfigs

Build image from:

* Git repo
* Dockerfile
* Source code

### Internal Registry

Stores images inside cluster.

No need for external Docker registry (optional).

---

# 🔄 2️⃣ OpenShift Workflow (End-to-End)

Let’s simulate real DevOps workflow (like your medical project).

---

## 🚀 Step 1: Developer Pushes Code

Developer pushes code to GitHub.

---

## 🏗️ Step 2: Build Trigger

OpenShift detects change via:

* Webhook
* Manual trigger
* Pipeline trigger

It starts build using BuildConfig.

---

## 📦 Step 3: Image Creation

Build process:

* Pull source code
* Build container image
* Push to internal registry
* Update ImageStream

---

## 🚀 Step 4: Deployment

Deployment object:

* Pulls new image
* Creates new Pods
* Performs rolling update

Old pods → terminated gradually.

---

## 🌐 Step 5: Expose via Route

Route exposes service externally.

User accesses:

```
https://app.apps.cluster.com
```

---

## 🔁 Step 6: Scaling & Self Healing

If Pod crashes:

* Controller recreates it

If load increases:

* Scale replicas

```bash
oc scale deployment backend --replicas=3
```

---

# 🧭 Complete Request Flow (Runtime)

When a user opens your app:

1. DNS resolves
2. Route receives request
3. Router forwards to Service
4. Service load balances to Pod
5. Pod runs container
6. Response sent back

---

# 🔐 Security Workflow

When user logs in:

* OAuth server validates identity
* RBAC checks permissions
* SCC validates container security

OpenShift is stricter than vanilla Kubernetes.

---

# 🏢 Deployment Models

OpenShift can run as:

* On-prem
* On AWS
* On Azure
* On GCP
* Managed services like
  **Red Hat OpenShift Service on AWS**

---

# 🧠 Architecture Summary (Interview Ready)

OpenShift architecture consists of:

1. Control Plane (API server, Scheduler, etcd)
2. Worker Nodes (Run Pods)
3. Routing Layer (Routes + HAProxy)
4. Build & Image Layer (ImageStreams, BuildConfigs)
5. Security Layer (OAuth, RBAC, SCC)

Workflow:
Code → Build → Image → Deploy → Route → User → Monitor → Scale

---
