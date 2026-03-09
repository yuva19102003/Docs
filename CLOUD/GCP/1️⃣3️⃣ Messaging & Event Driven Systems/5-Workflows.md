# Workflows

Orchestrate and automate Google Cloud and HTTP-based API services.

---

## Overview

Workflows is a fully managed orchestration platform that executes services in an order that you define: a workflow.

---

## Key Features

- YAML-based workflow definition
- Service orchestration
- Error handling
- Conditional logic
- Parallel execution
- Built-in connectors
- Serverless

---

## Workflow Syntax

**Basic Workflow:**
```yaml
# workflow.yaml
main:
  steps:
    - step1:
        call: http.get
        args:
          url: https://api.example.com/data
        result: apiResponse
    - step2:
        return: ${apiResponse.body}
```

**Sequential Steps:**
```yaml
main:
  steps:
    - fetchData:
        call: http.get
        args:
          url: https://api.example.com/users
        result: users
    - processData:
        call: processUsers
        args:
          users: ${users.body}
        result: processed
    - saveData:
        call: http.post
        args:
          url: https://api.example.com/save
          body: ${processed}
```

---

## Conditional Logic

```yaml
main:
  params: [order]
  steps:
    - checkAmount:
        switch:
          - condition: ${order.amount > 1000}
            next: requireApproval
          - condition: ${order.amount > 100}
            next: standardProcess
        next: fastTrack
    
    - requireApproval:
        call: http.post
        args:
          url: https://api.example.com/approval
          body: ${order}
        next: end
    
    - standardProcess:
        call: processOrder
        args:
          order: ${order}
        next: end
    
    - fastTrack:
        call: fastProcessOrder
        args:
          order: ${order}
```

---

## Parallel Execution

```yaml
main:
  steps:
    - parallelStep:
        parallel:
          branches:
            - branch1:
                steps:
                  - callService1:
                      call: http.get
                      args:
                        url: https://api1.example.com/data
                      result: result1
            - branch2:
                steps:
                  - callService2:
                      call: http.get
                      args:
                        url: https://api2.example.com/data
                      result: result2
            - branch3:
                steps:
                  - callService3:
                      call: http.get
                      args:
                        url: https://api3.example.com/data
                      result: result3
        result: allResults
    
    - combineResults:
        return: ${allResults}
```

---

## Error Handling

```yaml
main:
  steps:
    - tryStep:
        try:
          steps:
            - callAPI:
                call: http.get
                args:
                  url: https://api.example.com/data
                result: apiResult
        retry:
          predicate: ${http.default_retry}
          max_retries: 3
          backoff:
            initial_delay: 1
            max_delay: 60
            multiplier: 2
        except:
          as: e
          steps:
            - logError:
                call: sys.log
                args:
                  text: ${"Error: " + e.message}
            - returnError:
                return: ${"Failed: " + e.message}
```

---

## Loops

**For Loop:**
```yaml
main:
  steps:
    - processItems:
        for:
          value: item
          in: ${items}
          steps:
            - processItem:
                call: http.post
                args:
                  url: https://api.example.com/process
                  body: ${item}
```

**While Loop:**
```yaml
main:
  steps:
    - initialize:
        assign:
          - counter: 0
          - maxRetries: 5
    
    - retryLoop:
        steps:
          - checkCondition:
              switch:
                - condition: ${counter < maxRetries}
                  next: tryOperation
              next: failed
          
          - tryOperation:
              try:
                call: http.get
                args:
                  url: https://api.example.com/data
                result: data
              except:
                as: e
                steps:
                  - incrementCounter:
                      assign:
                        - counter: ${counter + 1}
                  - wait:
                      call: sys.sleep
                      args:
                        seconds: ${counter * 2}
                  next: retryLoop
```

---

## Subworkflows

```yaml
main:
  steps:
    - callSubworkflow:
        call: processOrder
        args:
          orderId: "12345"
        result: orderResult
    - returnResult:
        return: ${orderResult}

processOrder:
  params: [orderId]
  steps:
    - fetchOrder:
        call: http.get
        args:
          url: ${"https://api.example.com/orders/" + orderId}
        result: order
    - validateOrder:
        call: validateOrderData
        args:
          order: ${order.body}
        result: isValid
    - returnOrder:
        return: ${order.body}

validateOrderData:
  params: [order]
  steps:
    - checkFields:
        switch:
          - condition: ${order.amount > 0 AND order.customerId != null}
            return: true
        return: false
```

---

## Built-in Connectors

**Cloud Functions:**
```yaml
- callFunction:
    call: googleapis.cloudfunctions.v1.projects.locations.functions.call
    args:
      name: projects/PROJECT/locations/REGION/functions/FUNCTION
      body:
        data: ${inputData}
    result: functionResult
```

**BigQuery:**
```yaml
- queryBigQuery:
    call: googleapis.bigquery.v2.jobs.query
    args:
      projectId: PROJECT_ID
      body:
        query: "SELECT * FROM dataset.table LIMIT 10"
        useLegacySql: false
    result: queryResult
```

**Cloud Storage:**
```yaml
- uploadToGCS:
    call: googleapis.storage.v1.objects.insert
    args:
      bucket: my-bucket
      name: output.json
      body:
        data: ${data}
```

---

## Deploying Workflows

```bash
# Deploy workflow
gcloud workflows deploy my-workflow \
  --source=workflow.yaml \
  --location=us-central1 \
  --service-account=workflow-sa@project.iam.gserviceaccount.com

# Execute workflow
gcloud workflows execute my-workflow \
  --location=us-central1 \
  --data='{"orderId":"12345"}'

# List executions
gcloud workflows executions list my-workflow \
  --location=us-central1

# Describe execution
gcloud workflows executions describe EXECUTION_ID \
  --workflow=my-workflow \
  --location=us-central1
```

---

## Integration Examples

**Triggered by Cloud Scheduler:**
```bash
# Create scheduler job to trigger workflow
gcloud scheduler jobs create http trigger-workflow \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://workflowexecutions.googleapis.com/v1/projects/PROJECT/locations/us-central1/workflows/my-workflow/executions" \
  --oauth-service-account-email=scheduler@project.iam.gserviceaccount.com \
  --oauth-token-scope="https://www.googleapis.com/auth/cloud-platform" \
  --http-method=POST \
  --message-body='{"argument":"{\"orderId\":\"12345\"}"}'
```

**Triggered by Pub/Sub:**
```yaml
# workflow.yaml
main:
  params: [event]
  steps:
    - decodeMessage:
        assign:
          - message: ${base64.decode(event.data)}
    - processMessage:
        call: http.post
        args:
          url: https://api.example.com/process
          body: ${message}
```

---

## Best Practices

✓ Implement error handling  
✓ Use retries appropriately  
✓ Keep workflows simple  
✓ Monitor execution  
✓ Use variables effectively  
✓ Implement timeouts  
✓ Use subworkflows for reusability  
✓ Document workflow logic  

---

## Pricing

```
First 5,000 internal steps/month: Free
Additional internal steps: $0.01 per 1,000 steps
External HTTP calls: Standard rates apply
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
