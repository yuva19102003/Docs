
# ✅ **Azure Static Web Apps — Super Simple Tutorial (Step-by-Step)**

This guide assumes you have:

✔ A frontend (React/Vite/Next.js etc.)
✔ A GitHub repo (but you **don’t** have GitHub Owner access)
✔ You just want **auto-deploy** + **environment variables** + **zero downtime**

---

# 🟦 **1. What Is Azure Static Web Apps (SWA)?**

Azure Static Web Apps hosts:

* **Static files** → HTML, CSS, JS
* **Frontend frameworks** → React, Next, Vue, Angular, Svelte
* **Builds automatically** from GitHub
* **Has Global CDN** → super fast
* **Zero downtime deploys**
* **Free SSL** (HTTPS)

---

# 🟩 **2. Very Important: SWA needs GitHub permissions**

When you create a Static Web App, Azure tries to install a **GitHub Action** inside your repo.

This requires:

### ✔ **Repo Write access**

But NOT GitHub Owner access.

If you can **push code**, you are enough.

If your GitHub admin blocked OAuth apps → then SWA cannot create the GitHub Action → use “**Other**” option (manual deploy from CLI).

We cover both methods below.

---

# 🟦 **3. How to Create the Static Web App (UI)**

## 👉 Step 1 — Go to Portal

Search: **Static Web Apps**

Click **Create**.

---

## 👉 Step 2 — Basic Setup

* **Subscription:** your subscription
* **Resource Group:** Create new → `my-static-app-rg`
* **Name:** `my-frontend`
* **Plan Type:** *Free* or *Standard*
* **Region:** choose closest (ex: Central India)

Next → go to **Deployment Details**.

---

# 🟧 **4. Deployment Source (THIS IS THE CONFUSING PART)**

You will see 3 options:

### **① GitHub**

Auto deploy when you push code
✔ automatic builds
✔ recommended
⚠ requires GitHub permission for Azure to install the workflow file
⚠ if your GitHub owner blocks “install app”, this will NOT work

### **② Azure DevOps**

You are not using this → ignore.

### **③ Other (Manual Deploy)**

✔ NO GitHub permissions needed
✔ You deploy using Azure CLI
✔ Auto deploy NOT possible
✘ You must run `az staticwebapp upload` manually or from a GitHub Action you create yourself.

---

# 🟩 **Which should you choose?**

Since you **don’t have GitHub owner access**, choose one of these:

### ✅ **Best Option (easy): Click “GitHub” anyway — it usually works**

You only need **repo write access**.
If allowed → Azure will create the workflow.

### ❌ **If GitHub throws permission error**

Choose **“Other”** and deploy using CLI.

---

# 🟦 **5. If you choose GitHub → These are the settings**

### Build Details:

* **App location:**
  If React/Vite → `/`
  If monorepo → example: `apps/frontend`

* **Build output:**
  Vite → `dist`
  React CRA → `build`
  Next.js → `.next` (but Next.js works better on Azure Static Apps only for static export `next export`)

Then click **Review + Create → Create**.

Azure will automatically add a file in your repo:

```
.github/workflows/azure-static-web-apps.yml
```

This will build + deploy on every push.

---

# 🟩 **6. If GitHub workflow is NOT created because of permissions**

Then do this:

### 1️⃣ Create SWA using “Other”

### 2️⃣ Azure gives you an **API key**

### 3️⃣ Put this key in GitHub Secrets

Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`

### 4️⃣ Create this GitHub Action manually:

```
name: Deploy Static Web App

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Install Node
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install deps
        run: npm install

      - name: Build
        run: npm run build

      - name: Deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          app_location: "/"              # folder
          output_location: "dist"        # Vite build folder
```

This does auto-deploy **without requiring GitHub owner** access.

---

# 🟦 **7. Adding Environment Variables (Important)**

Static Web Apps have **two types** of env:

### **Frontend ENV (Build time only)**

Go to:

```
Static Web App → Configuration → Application Settings
```

Add:

```
VITE_BACKEND_URL = https://api.example.com
```

Azure injects these **during build time on GitHub Actions**.

This means:

✔ No need to store env in GitHub
✔ Secure
✔ You can update env without changing code

---

# 🟦 **8. Custom Domain (your case)**

Go to:

```
Settings → Custom domains → Add
```

Add:

```
pay2chat.summon.fun
```

Azure will give a CNAME:

```
<generated-name>.azurestaticapps.net
```

Add this CNAME in your DNS.

SSL auto-enabled.

---

# 🟦 **9. Zero Downtime? Yes.**

Azure SWA deploys to a staging slot → swaps → no downtime.

---
