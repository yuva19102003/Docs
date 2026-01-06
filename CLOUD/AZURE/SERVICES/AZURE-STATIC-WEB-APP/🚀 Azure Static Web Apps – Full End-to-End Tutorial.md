

## 1️⃣ What is Azure Static Web Apps?

**Azure Static Web Apps (SWA)** is a **serverless hosting service** optimized for:

- Frontend apps (React, Vue, Angular, Vite, Next.js static)
    
- Built-in backend APIs (Azure Functions)
    
- Global CDN
    
- Free HTTPS
    
- GitHub Actions CI/CD (auto)
    

👉 Best replacement for **Netlify / Vercel (static)**

---

## 2️⃣ When to Use / Not Use

### ✅ Use SWA when

- SPA or static site
    
- JAMstack architecture
    
- Need auth, APIs, CDN
    
- Want zero infra management
    

### ❌ Do NOT use SWA when

- Full backend server (Express, NestJS)
    
- SSR-heavy apps (use App Service / Vercel)
    
- WebSockets / long-running jobs
    

---

## 3️⃣ Supported Tech Stacks

### Frontend

|Framework|Supported|
|---|---|
|HTML / CSS / JS|✅|
|React (CRA / Vite)|✅|
|Vue|✅|
|Angular|✅|
|Svelte|✅|
|Next.js (Static only)|✅|

### Backend

|Type|Support|
|---|---|
|Azure Functions|✅|
|Node / Python / C#|✅|
|Express server|❌|

---

## 4️⃣ High-Level Architecture

```
GitHub Repo
 ├─ frontend/
 ├─ api/        (Azure Functions)
 └─ staticwebapp.config.json
        ↓
GitHub Actions (Auto)
        ↓
Azure Static Web Apps
        ↓
Global CDN + HTTPS
```

---

## 5️⃣ Create Azure Static Web App

### Step 1: Azure Portal

👉 [https://portal.azure.com](https://portal.azure.com/)

### Step 2: Create Resource

```
Create → Static Web App
```

### Step 3: Basics

|Field|Value|
|---|---|
|Subscription|Your subscription|
|Resource Group|Create new|
|Name|my-static-app|
|Hosting Plan|Free / Standard|
|Source|GitHub|
|Repo|Select repo|
|Branch|main|

Azure will **auto-create GitHub Actions** ✅

---

## 6️⃣ Project Structure (Recommended)

```
repo/
 ├─ frontend/
 │   ├─ src/
 │   ├─ package.json
 │   └─ dist/ or build/
 ├─ api/
 │   ├─ index.js
 │   └─ function.json
 └─ staticwebapp.config.json
```

---

## 7️⃣ Frontend Setup (All Frameworks)

### 🔹 Example: Vite / React

```bash
npm create vite@latest frontend
cd frontend
npm install
npm run build
```

Output folder:

```
frontend/dist
```

---

### 🔹 Example: Plain HTML

```
frontend/
 ├─ index.html
 ├─ style.css
 └─ script.js
```

---

## 8️⃣ Backend API (Azure Functions)

### api/index.js

```js
module.exports = async function (context, req) {
  context.res = {
    body: { message: "Hello from API" }
  };
};
```

### api/function.json

```json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "methods": ["get"],
      "name": "req"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

### Access API

```
/api
/api/index
```

---

## 9️⃣ SWA Configuration File (IMPORTANT)

### staticwebapp.config.json

```json
{
  "routes": [
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html"
  }
}
```

✔ Fixes SPA reload issues  
✔ Required for React / Vue routing

---

## 🔐 10️⃣ Authentication (Built-in)

Azure SWA has **FREE auth**

### Supported Providers

- GitHub
    
- Google
    
- Microsoft
    
- Twitter
    

### Login URL

```
/.login/github
```

### Logout

```
/.logout
```

### Get User Info

```js
fetch("/.auth/me")
```

---

## 11️⃣ Environment Variables

### Azure Portal

```
Static Web App → Configuration
```

Add:

```
VITE_API_URL=https://xxx
```

⚠️ Rebuild required after change

---

## 12️⃣ GitHub Actions (Auto Generated)

Azure creates this automatically:

```yaml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Azure/static-web-apps-deploy@v1
        with:
          app_location: "frontend"
          api_location: "api"
          output_location: "dist"
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
```

⚠️ Key fields:

- `app_location`
    
- `api_location`
    
- `output_location`
    

---

## 🌐 13️⃣ Custom Domain + HTTPS

### Add Domain

```
Static Web App → Custom Domains → Add
```

Azure provides:

- Free SSL
    
- Auto renewal
    
- Global CDN
    

---

## 📈 14️⃣ Performance & Scaling

✔ Auto scaling  
✔ Global CDN  
✔ Edge caching  
✔ No server limits

---

## 🔒 15️⃣ Security Best Practices

- Use SWA auth
    
- Restrict routes via config
    
- Store secrets in Azure config
    
- Use HTTPS only
    
- No backend credentials in frontend
    

---

## 16️⃣ Common Errors & Fixes

|Issue|Fix|
|---|---|
|Page reload 404|Add navigationFallback|
|API not found|Ensure `api/` folder|
|Env var not working|Rebuild app|
|Blank page|Wrong output_location|

---

## 17️⃣ SWA vs App Service

|Feature|Static Web Apps|App Service|
|---|---|---|
|Frontend hosting|✅|⚠️|
|Backend APIs|Azure Functions|Full server|
|SSR|❌|✅|
|Cost|Very low|Higher|
|Scaling|Automatic|Manual/Auto|

---

## 18️⃣ Best Production Architecture

```
Frontend → Azure Static Web Apps
Backend → Azure App Service / Functions
DB → Azure Managed DB
Auth → SWA Auth / Entra ID
CI/CD → GitHub Actions
```

---

## ✅ Final Summary

✔ Perfect for SPA & JAMstack  
✔ Free HTTPS + CDN  
✔ Built-in Auth  
✔ Serverless backend APIs  
✔ Simple & production-ready

---
