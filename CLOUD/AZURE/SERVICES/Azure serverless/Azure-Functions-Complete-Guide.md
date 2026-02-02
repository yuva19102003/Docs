# Azure Functions - Complete End-to-End Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Getting Started](#getting-started)
4. [Tutorial 1: HTTP Trigger Function](#tutorial-1-http-trigger-function)
5. [Tutorial 2: Timer Trigger Function](#tutorial-2-timer-trigger-function)
6. [Tutorial 3: Blob Storage Trigger](#tutorial-3-blob-storage-trigger)
7. [Tutorial 4: Queue Trigger Function](#tutorial-4-queue-trigger-function)
8. [Tutorial 5: Cosmos DB Integration](#tutorial-5-cosmos-db-integration)
9. [Tutorial 6: Durable Functions](#tutorial-6-durable-functions)
10. [Deployment Strategies](#deployment-strategies)
11. [Monitoring and Debugging](#monitoring-and-debugging)
12. [Best Practices](#best-practices)

---

## Overview

Azure Functions is a serverless compute service that enables you to run event-driven code without managing infrastructure.

### Key Features
- **Event-driven**: Respond to events from various Azure services
- **Serverless**: No infrastructure management required
- **Pay-per-execution**: Only pay for compute time used
- **Multiple languages**: C#, JavaScript, Python, Java, PowerShell, TypeScript
- **Flexible deployment**: Portal, CLI, VS Code, CI/CD pipelines

### Hosting Plans
1. **Consumption Plan**: Pay-per-execution, auto-scaling
2. **Premium Plan**: Pre-warmed instances, VNet connectivity
3. **Dedicated (App Service) Plan**: Run on dedicated VMs

---

## Prerequisites

### Required Tools
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Install VS Code Azure Functions Extension
code --install-extension ms-azuretools.vscode-azurefunctions
```

### Login to Azure
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

---

## Getting Started

### Create Resource Group
```bash
az group create \
  --name rg-functions-demo \
  --location eastus
```

### Create Storage Account (Required for Functions)
```bash
az storage account create \
  --name stfunctionsdemo001 \
  --resource-group rg-functions-demo \
  --location eastus \
  --sku Standard_LRS
```

### Create Function App
```bash
az functionapp create \
  --resource-group rg-functions-demo \
  --consumption-plan-location eastus \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name func-demo-app-001 \
  --storage-account stfunctionsdemo001
```

---

## Tutorial 1: HTTP Trigger Function

### Step 1: Initialize Local Project
```bash
# Create project directory
mkdir azure-functions-demo
cd azure-functions-demo

# Initialize Functions project
func init --worker-runtime node --language javascript

# Create HTTP trigger function
func new --name HttpTriggerDemo --template "HTTP trigger"
```

### Step 2: Function Code (JavaScript)
```javascript
// HttpTriggerDemo/index.js
module.exports = async function (context, req) {
    context.log('HTTP trigger function processed a request.');

    const name = (req.query.name || (req.body && req.body.name));
    const responseMessage = name
        ? `Hello, ${name}! This HTTP triggered function executed successfully.`
        : "Pass a name in the query string or request body for a personalized response.";

    context.res = {
        status: 200,
        body: responseMessage,
        headers: {
            'Content-Type': 'application/json'
        }
    };
};
```

### Step 3: Function Configuration
```json
// HttpTriggerDemo/function.json
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

### Step 4: Test Locally
```bash
# Start the function locally
func start

# Test with curl (in another terminal)
curl http://localhost:7071/api/HttpTriggerDemo?name=Azure
```

### Step 5: Deploy to Azure
```bash
func azure functionapp publish func-demo-app-001
```

### Step 6: Test Deployed Function
```bash
# Get function URL
FUNCTION_URL=$(az functionapp function show \
  --resource-group rg-functions-demo \
  --name func-demo-app-001 \
  --function-name HttpTriggerDemo \
  --query invokeUrlTemplate -o tsv)

# Get function key
FUNCTION_KEY=$(az functionapp keys list \
  --resource-group rg-functions-demo \
  --name func-demo-app-001 \
  --query functionKeys.default -o tsv)

# Test the function
curl "${FUNCTION_URL}?name=Azure&code=${FUNCTION_KEY}"
```

---

## Tutorial 2: Timer Trigger Function

### Step 1: Create Timer Function
```bash
func new --name TimerTriggerDemo --template "Timer trigger"
```

### Step 2: Function Code
```javascript
// TimerTriggerDemo/index.js
module.exports = async function (context, myTimer) {
    const timeStamp = new Date().toISOString();
    
    if (myTimer.isPastDue) {
        context.log('Timer function is running late!');
    }
    
    context.log('Timer trigger function ran at:', timeStamp);
    
    // Example: Cleanup old data, send reports, etc.
    await performScheduledTask(context);
};

async function performScheduledTask(context) {
    // Your scheduled logic here
    context.log('Performing scheduled maintenance task...');
    
    // Example: Query database, send emails, cleanup storage
    return { success: true, timestamp: new Date() };
}
```

### Step 3: Configure Schedule (CRON Expression)
```json
// TimerTriggerDemo/function.json
{
  "bindings": [
    {
      "name": "myTimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 */5 * * * *"
    }
  ]
}
```

### CRON Expression Examples
```
0 */5 * * * *     - Every 5 minutes
0 0 * * * *       - Every hour
0 0 9 * * *       - Every day at 9:00 AM
0 0 9 * * 1-5     - Every weekday at 9:00 AM
0 0 0 1 * *       - First day of every month at midnight
```

### Step 4: Test and Deploy
```bash
# Test locally
func start

# Deploy
func azure functionapp publish func-demo-app-001
```

---

## Tutorial 3: Blob Storage Trigger

### Step 1: Create Blob Trigger Function
```bash
func new --name BlobTriggerDemo --template "Blob trigger"
```

### Step 2: Function Code
```javascript
// BlobTriggerDemo/index.js
module.exports = async function (context, myBlob) {
    context.log("Blob trigger function processed blob \n Name:", context.bindingData.name, "\n Size:", myBlob.length, "Bytes");
    
    // Process the blob content
    const blobContent = myBlob.toString('utf8');
    context.log("Blob content:", blobContent);
    
    // Example: Parse CSV, process images, extract text
    const result = await processBlobData(blobContent, context);
    
    context.log("Processing result:", result);
};

async function processBlobData(content, context) {
    // Your blob processing logic
    try {
        // Example: Parse JSON
        const data = JSON.parse(content);
        context.log("Parsed data:", data);
        return { success: true, recordCount: data.length };
    } catch (error) {
        context.log.error("Error processing blob:", error);
        return { success: false, error: error.message };
    }
}
```

### Step 3: Configure Blob Trigger
```json
// BlobTriggerDemo/function.json
{
  "bindings": [
    {
      "name": "myBlob",
      "type": "blobTrigger",
      "direction": "in",
      "path": "uploads/{name}",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

### Step 4: Add Storage Connection String
```bash
# Get storage connection string
STORAGE_CONNECTION=$(az storage account show-connection-string \
  --name stfunctionsdemo001 \
  --resource-group rg-functions-demo \
  --query connectionString -o tsv)

# Add to local.settings.json for local testing
# Add to Function App settings for production
az functionapp config appsettings set \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo \
  --settings "AzureWebJobsStorage=${STORAGE_CONNECTION}"
```

### Step 5: Test with Blob Upload
```bash
# Create container
az storage container create \
  --name uploads \
  --account-name stfunctionsdemo001

# Upload test file
echo '{"name": "test", "value": 123}' > test.json
az storage blob upload \
  --account-name stfunctionsdemo001 \
  --container-name uploads \
  --name test.json \
  --file test.json
```

---

## Tutorial 4: Queue Trigger Function

### Step 1: Create Queue Trigger Function
```bash
func new --name QueueTriggerDemo --template "Queue trigger"
```

### Step 2: Function Code
```javascript
// QueueTriggerDemo/index.js
module.exports = async function (context, myQueueItem) {
    context.log('Queue trigger function processed work item:', myQueueItem);
    
    try {
        // Parse queue message
        const message = typeof myQueueItem === 'string' 
            ? JSON.parse(myQueueItem) 
            : myQueueItem;
        
        context.log('Processing message:', message);
        
        // Process the message
        await processQueueMessage(message, context);
        
        context.log('Message processed successfully');
    } catch (error) {
        context.log.error('Error processing queue message:', error);
        throw error; // Message will be retried
    }
};

async function processQueueMessage(message, context) {
    // Your message processing logic
    switch (message.type) {
        case 'email':
            await sendEmail(message.data, context);
            break;
        case 'notification':
            await sendNotification(message.data, context);
            break;
        default:
            context.log('Unknown message type:', message.type);
    }
}

async function sendEmail(data, context) {
    context.log('Sending email to:', data.recipient);
    // Email sending logic
}

async function sendNotification(data, context) {
    context.log('Sending notification:', data.message);
    // Notification logic
}
```

### Step 3: Configure Queue Trigger
```json
// QueueTriggerDemo/function.json
{
  "bindings": [
    {
      "name": "myQueueItem",
      "type": "queueTrigger",
      "direction": "in",
      "queueName": "workitems",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

### Step 4: Create Queue and Send Messages
```bash
# Create queue
az storage queue create \
  --name workitems \
  --account-name stfunctionsdemo001

# Send test message
az storage message put \
  --queue-name workitems \
  --account-name stfunctionsdemo001 \
  --content '{"type":"email","data":{"recipient":"user@example.com","subject":"Test"}}'
```

### Step 5: Queue Output Binding
```javascript
// Example: Function that writes to queue
module.exports = async function (context, req) {
    const message = {
        type: 'email',
        data: {
            recipient: req.body.email,
            subject: 'Welcome',
            body: 'Thank you for signing up!'
        }
    };
    
    // Output to queue
    context.bindings.outputQueueItem = JSON.stringify(message);
    
    context.res = {
        status: 200,
        body: 'Message queued successfully'
    };
};
```

```json
// function.json with output binding
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    },
    {
      "type": "queue",
      "direction": "out",
      "name": "outputQueueItem",
      "queueName": "workitems",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

---

## Tutorial 5: Cosmos DB Integration

### Step 1: Create Cosmos DB Account
```bash
# Create Cosmos DB account
az cosmosdb create \
  --name cosmos-functions-demo \
  --resource-group rg-functions-demo \
  --kind GlobalDocumentDB \
  --locations regionName=eastus failoverPriority=0

# Create database
az cosmosdb sql database create \
  --account-name cosmos-functions-demo \
  --resource-group rg-functions-demo \
  --name FunctionsDB

# Create container
az cosmosdb sql container create \
  --account-name cosmos-functions-demo \
  --resource-group rg-functions-demo \
  --database-name FunctionsDB \
  --name Items \
  --partition-key-path "/category"
```

### Step 2: Install Cosmos DB Extension
```bash
# Add to package.json or install
npm install @azure/cosmos
```

### Step 3: HTTP Trigger with Cosmos DB Output
```javascript
// CreateItem/index.js
module.exports = async function (context, req) {
    const item = {
        id: req.body.id || generateId(),
        name: req.body.name,
        category: req.body.category,
        description: req.body.description,
        createdAt: new Date().toISOString()
    };
    
    // Output to Cosmos DB
    context.bindings.outputDocument = item;
    
    context.res = {
        status: 201,
        body: { message: 'Item created', item: item }
    };
};

function generateId() {
    return `item-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}
```

### Step 4: Cosmos DB Bindings Configuration
```json
// CreateItem/function.json
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    },
    {
      "type": "cosmosDB",
      "direction": "out",
      "name": "outputDocument",
      "databaseName": "FunctionsDB",
      "collectionName": "Items",
      "createIfNotExists": true,
      "connectionStringSetting": "CosmosDBConnection"
    }
  ]
}
```

### Step 5: Cosmos DB Trigger Function
```javascript
// CosmosDBTrigger/index.js
module.exports = async function (context, documents) {
    if (!!documents && documents.length > 0) {
        context.log('Document count:', documents.length);
        
        for (const doc of documents) {
            context.log('Processing document:', doc.id);
            
            // React to changes in Cosmos DB
            await processDocumentChange(doc, context);
        }
    }
};

async function processDocumentChange(doc, context) {
    // Example: Send notification, update cache, trigger workflow
    context.log('Document changed:', {
        id: doc.id,
        category: doc.category,
        name: doc.name
    });
    
    // Add your business logic here
}
```

```json
// CosmosDBTrigger/function.json
{
  "bindings": [
    {
      "type": "cosmosDBTrigger",
      "name": "documents",
      "direction": "in",
      "leaseCollectionName": "leases",
      "connectionStringSetting": "CosmosDBConnection",
      "databaseName": "FunctionsDB",
      "collectionName": "Items",
      "createLeaseCollectionIfNotExists": true
    }
  ]
}
```

### Step 6: Configure Connection String
```bash
# Get Cosmos DB connection string
COSMOS_CONNECTION=$(az cosmosdb keys list \
  --name cosmos-functions-demo \
  --resource-group rg-functions-demo \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" -o tsv)

# Add to Function App settings
az functionapp config appsettings set \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo \
  --settings "CosmosDBConnection=${COSMOS_CONNECTION}"
```

---

## Tutorial 6: Durable Functions

Durable Functions enable stateful workflows in serverless environments.

### Step 1: Install Durable Functions Extension
```bash
npm install durable-functions
```

### Step 2: Create Orchestrator Function
```javascript
// DurableOrchestrator/index.js
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const outputs = [];
    
    // Sequential execution
    outputs.push(yield context.df.callActivity("ActivityFunction", "Step 1"));
    outputs.push(yield context.df.callActivity("ActivityFunction", "Step 2"));
    outputs.push(yield context.df.callActivity("ActivityFunction", "Step 3"));
    
    // Parallel execution
    const parallelTasks = [];
    parallelTasks.push(context.df.callActivity("ActivityFunction", "Parallel 1"));
    parallelTasks.push(context.df.callActivity("ActivityFunction", "Parallel 2"));
    parallelTasks.push(context.df.callActivity("ActivityFunction", "Parallel 3"));
    
    const parallelResults = yield context.df.Task.all(parallelTasks);
    outputs.push(...parallelResults);
    
    return outputs;
});
```

### Step 3: Create Activity Function
```javascript
// ActivityFunction/index.js
module.exports = async function (context) {
    const input = context.bindings.name;
    context.log(`Processing: ${input}`);
    
    // Simulate work
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return `Completed: ${input}`;
};
```

### Step 4: Create HTTP Starter
```javascript
// DurableHttpStart/index.js
const df = require("durable-functions");

module.exports = async function (context, req) {
    const client = df.getClient(context);
    const instanceId = await client.startNew("DurableOrchestrator", undefined, req.body);
    
    context.log(`Started orchestration with ID = '${instanceId}'.`);
    
    return client.createCheckStatusResponse(context.bindingData.req, instanceId);
};
```

### Step 5: Configuration Files
```json
// DurableOrchestrator/function.json
{
  "bindings": [
    {
      "name": "context",
      "type": "orchestrationTrigger",
      "direction": "in"
    }
  ]
}
```

```json
// ActivityFunction/function.json
{
  "bindings": [
    {
      "name": "name",
      "type": "activityTrigger",
      "direction": "in"
    }
  ]
}
```

```json
// DurableHttpStart/function.json
{
  "bindings": [
    {
      "authLevel": "function",
      "name": "req",
      "type": "httpTrigger",
      "direction": "in",
      "methods": ["post"]
    },
    {
      "name": "$return",
      "type": "http",
      "direction": "out"
    },
    {
      "name": "starter",
      "type": "durableClient",
      "direction": "in"
    }
  ]
}
```

### Step 6: Test Durable Function
```bash
# Start orchestration
curl -X POST https://func-demo-app-001.azurewebsites.net/api/DurableHttpStart \
  -H "Content-Type: application/json" \
  -d '{"input": "test data"}'

# Response includes status URLs:
# - statusQueryGetUri: Check status
# - sendEventPostUri: Send events
# - terminatePostUri: Terminate instance
```

---

## Deployment Strategies

### Method 1: Azure CLI Deployment
```bash
# Deploy from local project
func azure functionapp publish func-demo-app-001

# Deploy with specific settings
func azure functionapp publish func-demo-app-001 \
  --build remote \
  --publish-local-settings
```

### Method 2: ZIP Deployment
```bash
# Create deployment package
zip -r function-app.zip .

# Deploy ZIP
az functionapp deployment source config-zip \
  --resource-group rg-functions-demo \
  --name func-demo-app-001 \
  --src function-app.zip
```

### Method 3: GitHub Actions CI/CD
```yaml
# .github/workflows/deploy-function.yml
name: Deploy Azure Function

on:
  push:
    branches: [ main ]

env:
  AZURE_FUNCTIONAPP_NAME: func-demo-app-001
  AZURE_FUNCTIONAPP_PACKAGE_PATH: '.'
  NODE_VERSION: '18.x'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}

    - name: Install dependencies
      run: npm ci

    - name: Run tests
      run: npm test

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to Azure Functions
      uses: Azure/functions-action@v1
      with:
        app-name: ${{ env.AZURE_FUNCTIONAPP_NAME }}
        package: ${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}
        publish-profile: ${{ secrets.AZURE_FUNCTIONAPP_PUBLISH_PROFILE }}
```

### Method 4: Azure DevOps Pipeline
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  azureSubscription: 'Azure-Service-Connection'
  functionAppName: 'func-demo-app-001'
  workingDirectory: '$(System.DefaultWorkingDirectory)'

stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
      displayName: 'Install Node.js'

    - script: |
        npm install
        npm run build --if-present
        npm run test --if-present
      displayName: 'Install and Build'
      workingDirectory: $(workingDirectory)

    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: '$(workingDirectory)'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
      displayName: 'Archive files'

    - publish: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
      artifact: drop

- stage: Deploy
  dependsOn: Build
  jobs:
  - deployment: Deploy
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureFunctionApp@1
            inputs:
              azureSubscription: '$(azureSubscription)'
              appType: 'functionApp'
              appName: '$(functionAppName)'
              package: '$(Pipeline.Workspace)/drop/$(Build.BuildId).zip'
```

### Method 5: Terraform Deployment
```hcl
# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "functions" {
  name     = "rg-functions-demo"
  location = "East US"
}

resource "azurerm_storage_account" "functions" {
  name                     = "stfunctionsdemo001"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functions" {
  name                = "asp-functions-demo"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "functions" {
  name                       = "func-demo-app-001"
  resource_group_name        = azurerm_resource_group.functions.name
  location                   = azurerm_resource_group.functions.location
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}
```

---

## Monitoring and Debugging

### Enable Application Insights
```bash
# Create Application Insights
az monitor app-insights component create \
  --app func-insights-demo \
  --location eastus \
  --resource-group rg-functions-demo \
  --application-type web

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app func-insights-demo \
  --resource-group rg-functions-demo \
  --query instrumentationKey -o tsv)

# Configure Function App
az functionapp config appsettings set \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo \
  --settings "APPINSIGHTS_INSTRUMENTATIONKEY=${INSTRUMENTATION_KEY}"
```

### Custom Logging
```javascript
module.exports = async function (context, req) {
    // Different log levels
    context.log('Information message');
    context.log.warn('Warning message');
    context.log.error('Error message');
    context.log.verbose('Verbose message');
    
    // Structured logging
    context.log({
        level: 'info',
        message: 'User action',
        userId: req.body.userId,
        action: 'login',
        timestamp: new Date().toISOString()
    });
    
    // Track custom metrics
    const startTime = Date.now();
    await performOperation();
    const duration = Date.now() - startTime;
    
    context.log.metric('OperationDuration', duration);
};
```

### Query Application Insights
```kusto
// Function execution times
requests
| where cloud_RoleName == "func-demo-app-001"
| summarize avg(duration), percentile(duration, 95) by name
| order by avg_duration desc

// Failed requests
requests
| where cloud_RoleName == "func-demo-app-001" and success == false
| project timestamp, name, resultCode, duration
| order by timestamp desc

// Custom logs
traces
| where cloud_RoleName == "func-demo-app-001"
| where message contains "User action"
| project timestamp, message, severityLevel
| order by timestamp desc

// Dependencies (external calls)
dependencies
| where cloud_RoleName == "func-demo-app-001"
| summarize count() by name, type
| order by count_ desc
```

### Local Debugging with VS Code
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to Node Functions",
      "type": "node",
      "request": "attach",
      "port": 9229,
      "preLaunchTask": "func: host start"
    }
  ]
}
```

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "type": "func",
      "command": "host start",
      "problemMatcher": "$func-node-watch",
      "isBackground": true
    }
  ]
}
```

### View Logs in Real-Time
```bash
# Stream logs
az webapp log tail \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo

# Download logs
az webapp log download \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo \
  --log-file function-logs.zip
```

---

## Best Practices

### 1. Function Design
```javascript
// ✅ Good: Single responsibility
module.exports = async function (context, req) {
    const userId = req.body.userId;
    const user = await getUserById(userId);
    context.res = { body: user };
};

// ❌ Bad: Multiple responsibilities
module.exports = async function (context, req) {
    // Don't mix concerns in one function
    await processPayment();
    await sendEmail();
    await updateInventory();
    await generateReport();
};
```

### 2. Error Handling
```javascript
module.exports = async function (context, req) {
    try {
        const result = await riskyOperation();
        
        context.res = {
            status: 200,
            body: { success: true, data: result }
        };
    } catch (error) {
        context.log.error('Operation failed:', error);
        
        // Return appropriate error response
        context.res = {
            status: error.statusCode || 500,
            body: {
                success: false,
                error: error.message,
                requestId: context.invocationId
            }
        };
    }
};
```

### 3. Connection Management
```javascript
// ✅ Good: Reuse connections
let cosmosClient;

module.exports = async function (context, req) {
    // Initialize once, reuse across invocations
    if (!cosmosClient) {
        cosmosClient = new CosmosClient(process.env.CosmosDBConnection);
    }
    
    const database = cosmosClient.database('FunctionsDB');
    const container = database.container('Items');
    
    const { resources } = await container.items.readAll().fetchAll();
    context.res = { body: resources };
};

// ❌ Bad: Create new connection every time
module.exports = async function (context, req) {
    const client = new CosmosClient(process.env.CosmosDBConnection);
    // This creates overhead on every invocation
};
```

### 4. Environment Variables
```javascript
// ✅ Good: Use environment variables
const config = {
    apiKey: process.env.API_KEY,
    endpoint: process.env.API_ENDPOINT,
    timeout: parseInt(process.env.TIMEOUT || '30000')
};

// ❌ Bad: Hardcode sensitive data
const apiKey = "sk-1234567890abcdef"; // Never do this!
```

### 5. Async/Await Patterns
```javascript
// ✅ Good: Proper async handling
module.exports = async function (context, req) {
    const results = await Promise.all([
        fetchUserData(userId),
        fetchOrderData(orderId),
        fetchInventory(productId)
    ]);
    
    return { body: results };
};

// ❌ Bad: Blocking operations
module.exports = function (context, req) {
    // Missing async/await
    fetchData().then(result => {
        context.res = { body: result };
    });
    // Function may complete before promise resolves
};
```

### 6. Cold Start Optimization
```javascript
// Initialize outside handler for warm starts
const dependencies = require('./dependencies');
const config = loadConfiguration();

module.exports = async function (context, req) {
    // Handler code executes faster on warm starts
    const result = await processRequest(req, config);
    context.res = { body: result };
};
```

### 7. Timeout Configuration
```json
// host.json
{
  "version": "2.0",
  "functionTimeout": "00:05:00",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "maxTelemetryItemsPerSecond": 20
      }
    }
  },
  "extensions": {
    "http": {
      "routePrefix": "api",
      "maxOutstandingRequests": 200,
      "maxConcurrentRequests": 100,
      "dynamicThrottlesEnabled": true
    }
  }
}
```

### 8. Security Best Practices
```javascript
// Input validation
module.exports = async function (context, req) {
    // Validate input
    if (!req.body || !req.body.email) {
        context.res = {
            status: 400,
            body: { error: 'Email is required' }
        };
        return;
    }
    
    // Sanitize input
    const email = sanitizeEmail(req.body.email);
    
    // Validate format
    if (!isValidEmail(email)) {
        context.res = {
            status: 400,
            body: { error: 'Invalid email format' }
        };
        return;
    }
    
    // Process validated input
    await processEmail(email);
};

function sanitizeEmail(email) {
    return email.trim().toLowerCase();
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}
```

### 9. Managed Identity
```bash
# Enable system-assigned managed identity
az functionapp identity assign \
  --name func-demo-app-001 \
  --resource-group rg-functions-demo

# Grant access to Key Vault
az keyvault set-policy \
  --name kv-functions-demo \
  --object-id <MANAGED_IDENTITY_PRINCIPAL_ID> \
  --secret-permissions get list
```

```javascript
// Use managed identity to access Key Vault
const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");

const credential = new DefaultAzureCredential();
const vaultUrl = `https://kv-functions-demo.vault.azure.net`;
const client = new SecretClient(vaultUrl, credential);

module.exports = async function (context, req) {
    const secret = await client.getSecret("DatabasePassword");
    // Use secret.value securely
};
```

### 10. Testing
```javascript
// function.test.js
const httpFunction = require('./HttpTriggerDemo');

describe('HTTP Trigger Function', () => {
    test('should return greeting with name', async () => {
        const context = {
            log: jest.fn(),
            res: {}
        };
        
        const req = {
            query: { name: 'Azure' },
            body: {}
        };
        
        await httpFunction(context, req);
        
        expect(context.res.status).toBe(200);
        expect(context.res.body).toContain('Hello, Azure');
    });
    
    test('should return default message without name', async () => {
        const context = {
            log: jest.fn(),
            res: {}
        };
        
        const req = {
            query: {},
            body: {}
        };
        
        await httpFunction(context, req);
        
        expect(context.res.status).toBe(200);
        expect(context.res.body).toContain('Pass a name');
    });
});
```

---

## Additional Resources

### Official Documentation
- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure Functions Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
- [Durable Functions Documentation](https://docs.microsoft.com/azure/azure-functions/durable/)

### Pricing Calculator
- [Azure Functions Pricing](https://azure.microsoft.com/pricing/details/functions/)

### Sample Projects
- [Azure Functions Samples](https://github.com/Azure/Azure-Functions)
- [Serverless Community Library](https://serverlesslibrary.net/)

### Monitoring and Troubleshooting
- [Monitor Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-monitoring)
- [Diagnose and solve problems](https://docs.microsoft.com/azure/azure-functions/functions-diagnostics)

---

## Summary

This guide covered:
- ✅ HTTP, Timer, Blob, and Queue triggers
- ✅ Cosmos DB integration
- ✅ Durable Functions for workflows
- ✅ Multiple deployment strategies
- ✅ Monitoring with Application Insights
- ✅ Security and best practices
- ✅ Testing and debugging

You now have a complete foundation for building production-ready Azure Functions!
