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
