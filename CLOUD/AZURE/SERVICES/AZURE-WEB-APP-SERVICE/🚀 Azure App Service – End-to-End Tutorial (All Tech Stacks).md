
## 1️⃣ What is Azure App Service?

Azure App Service is a **PaaS (Platform as a Service)** to host:

- Web apps
    
- REST APIs
    
- Backend services
    
- Frontend apps (SPA)
    
- Containers
    

👉 **No server management** (OS, patching, scaling handled by Azure)

---

## 2️⃣ Supported Tech Stacks (Official)

|Category|Tech Stack|
|---|---|
|Frontend|React, Vue, Angular, Vite, Next.js (static or SSR*)|
|Backend|Node.js, Python, Java, .NET, PHP|
|APIs|Express, FastAPI, Spring Boot|
|Containers|Docker (any language)|
|Static|HTML, CSS, JS|
|Monorepo|Supported (with config)|

---

## 3️⃣ Core Concepts (Must Know)

### 🔹 App Service Plan

Defines:

- **OS** (Linux / Windows)
    
- **CPU & RAM**
    
- **Pricing Tier**
    

|Tier|Use|
|---|---|
|Free / Shared|Testing|
|Basic|Small prod|
|Standard|Most apps|
|Premium|High traffic|
|Isolated|Enterprise|

---

### 🔹 Web App

- Your **actual application**
    
- Runs inside App Service Plan
    

---

## 4️⃣ Architecture Overview

```
GitHub Repo
   ↓
GitHub Actions (CI/CD)
   ↓
Azure App Service
   ↓
HTTPS (Managed by Azure)
   ↓
Users
```

---

## 5️⃣ Create Azure App Service (UI Method)

### Step 1: Azure Portal

👉 [https://portal.azure.com](https://portal.azure.com/)

### Step 2: Create Resource

```
Create Resource → Web App
```

### Step 3: Basics

|Field|Value|
|---|---|
|Subscription|Your subscription|
|Resource Group|Create new|
|Name|my-app-service|
|Publish|Code / Docker|
|Runtime|Node / Python / Java / .NET|
|OS|Linux (recommended)|
|Region|Nearest|
|Plan|Basic / Standard|

Click **Review + Create**

---

## 6️⃣ Deployment Methods (Choose One)

|Method|Best For|
|---|---|
|GitHub Actions|Production|
|ZIP Deploy|Quick|
|FTP|Legacy|
|Azure CLI|Automation|
|Docker|Any language|

---

# 🔹 METHOD 1: GitHub Actions (RECOMMENDED)

## 7️⃣ GitHub Actions – General Flow

Azure generates a workflow file for you.

```
Repo → Actions → Azure Web App → Configure
```

Azure will create:

- Service Principal
    
- Publish Profile
    
- `.github/workflows/deploy.yml`
    

---

## 8️⃣ Tech Stack–Wise Deployment

---

## 🟢 A) Node.js / Express Backend

### Project Structure

```
backend/
 ├─ src/
 ├─ package.json
 └─ server.js
```

### server.js

```js
const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("App running on Azure");
});

app.listen(PORT, () => {
  console.log("Server started");
});
```

⚠️ **IMPORTANT**

- ❌ Do NOT hardcode port
    
- ✅ Use `process.env.PORT`
    

---

### package.json

```json
{
  "scripts": {
    "start": "node server.js"
  }
}
```

---

### GitHub Actions (Node.js)

```yaml
name: Deploy Node App

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 18

      - run: npm install
      - run: npm run build --if-present

      - uses: azure/webapps-deploy@v2
        with:
          app-name: my-app-service
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
          package: .
```

---

## 🟢 B) Python (FastAPI / Flask)

### app.py

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello Azure"}
```

### requirements.txt

```
fastapi
uvicorn
```

### Startup Command (Azure)

```
uvicorn app:app --host 0.0.0.0 --port 8000
```

Set in:

```
App Service → Configuration → General settings
```

---

## 🟢 C) Java (Spring Boot)

### application.properties

```
server.port=8080
```

Azure auto-detects port.

### GitHub Actions

```yaml
- run: mvn clean package
- uses: azure/webapps-deploy@v2
  with:
    app-name: my-java-app
    package: target/*.jar
```

---

## 🟢 D) React / Vite Frontend

### Build

```
npm run build
```

### App Service Type

- Use **Azure Static Web Apps** (BEST)  
    OR
    
- App Service + Nginx
    

### For App Service

Set:

```
Startup Command:
pm2 serve /home/site/wwwroot --spa
```

---

## 🟢 E) Next.js

|Mode|Azure Support|
|---|---|
|Static|Static Web Apps|
|SSR|App Service (Node)|

### SSR Startup

```
npm run start
```

---

## 🟢 F) Docker (ANY STACK)

### Dockerfile

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm","start"]
```

### Azure Settings

- Publish: Docker Container
    
- Image Source: GitHub / ACR / DockerHub
    

---

## 9️⃣ Environment Variables (.env)

### Azure Way

```
App Service → Configuration → Application Settings
```

Example:

```
MONGO_URL=xxx
JWT_SECRET=yyy
```

👉 Automatically injected into runtime

---

## 🔐 10️⃣ HTTPS & SSL

✅ Azure provides **FREE HTTPS**

- No cert files needed
    
- Auto-renewed
    

### Custom Domain

```
App Service → Custom domains → Add
```

---

## 📈 11️⃣ Scaling

### Vertical (Scale Up)

- Change pricing tier
    

### Horizontal (Scale Out)

```
App Service → Scale out
```

- Auto-scale rules
    
- CPU / Memory / Requests
    

---

## 📊 12️⃣ Logs & Monitoring

### Enable Logs

```
App Service → Logs → Enable Application Logs
```

### View Logs

```
Log stream
```

### Advanced

- Azure Monitor
    
- Application Insights
    

---

## 🔁 13️⃣ Zero Downtime Deployments

Azure uses:

- **Slot deployment**
    

### Flow

```
staging slot → test → swap with production
```

---

## 🔒 14️⃣ Security Best Practices

- Use Managed Identity
    
- Do not store secrets in repo
    
- Enable HTTPS only
    
- Restrict inbound IPs
    
- Use Private DB endpoints
    

---

## 15️⃣ Common Mistakes ❌

|Mistake|Fix|
|---|---|
|Hardcoded port|Use env PORT|
|Local HTTPS cert|Remove|
|No start command|Define startup|
|Using Free tier in prod|Upgrade|

---

## 16️⃣ When NOT to Use App Service

❌ Heavy background jobs  
❌ Complex microservices  
❌ High-performance real-time systems

👉 Use **AKS / VMs** instead

---

## 17️⃣ Best Practice Architecture

```
Frontend → Azure Static Web Apps
Backend → Azure App Service
DB → Azure Managed DB
Cache → Azure Redis
CI/CD → GitHub Actions
```

---

## ✅ Final Summary

✔ Supports **almost every stack**  
✔ No server maintenance  
✔ Easy CI/CD  
✔ Built-in SSL & scaling  
✔ Ideal for **startups & production**

---
