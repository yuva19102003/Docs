# 🔴 What is `oc`?

`oc` is the OpenShift CLI tool (similar to `kubectl` but with OpenShift features).

It allows you to:

* Login to cluster
* Deploy apps
* Create projects
* Manage routes
* Scale deployments
* Debug pods

---

# ✅ Step 1: Check if Chocolatey is Installed

Open **PowerShell as Administrator** and run:

```powershell
choco -v
```

If version shows → good.

If not installed, install Chocolatey first:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Restart PowerShell after installation.

---

# ✅ Step 2: Install OpenShift CLI (`oc`)

Run:

```powershell
choco install openshift-cli -y
```

Wait for installation to complete.

---

# ✅ Step 3: Verify Installation

```powershell
oc version
```

If installed correctly, you’ll see:

```
Client Version: x.x.x
```

---

# ✅ Step 4: Login to Your Sandbox

Since you're already using OpenShift Sandbox:

1. Go to your OpenShift web console
2. Click top right → your username
3. Click **Copy Login Command**
4. Choose `oc`
5. Copy the command

It will look like:

```powershell
oc login --token=sha256~xxxxx --server=https://api.sandbox....
```

Paste in PowerShell.

---

# ✅ Step 5: Test Commands

```powershell
oc get projects
oc get pods
oc get svc
```

---

# 🔥 Pro Tip (DevOps Style)

Add this alias for easier typing:

```powershell
Set-Alias k oc
```

Now you can use:

```powershell
k get pods
```

---

# 🧠 How `oc` is Different from `kubectl`

| kubectl            | oc                          |
| ------------------ | --------------------------- |
| Kubernetes CLI     | OpenShift CLI               |
| Generic K8s        | OpenShift specific features |
| No project command | `oc new-project`            |
| No build configs   | Supports BuildConfig        |

OpenShift CLI is built on top of **Kubernetes** CLI.

---
