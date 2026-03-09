# Cloud Scheduler

Fully managed cron job service.

---

## Overview

Cloud Scheduler is a fully managed enterprise-grade cron job scheduler that allows you to schedule virtually any job, including batch, big data jobs, cloud infrastructure operations, and more.

---

## Key Features

- Cron syntax
- Multiple targets (HTTP, Pub/Sub, App Engine)
- Retry configuration
- Time zones
- Monitoring and logging
- Fully managed

---

## Creating Jobs

**HTTP Target:**
```bash
# Create HTTP job
gcloud scheduler jobs create http my-job \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://example.com/endpoint" \
  --http-method=POST \
  --headers="Content-Type=application/json" \
  --message-body='{"action":"daily_report"}' \
  --time-zone="America/New_York"
```

**Pub/Sub Target:**
```bash
# Create Pub/Sub job
gcloud scheduler jobs create pubsub my-pubsub-job \
  --location=us-central1 \
  --schedule="*/5 * * * *" \
  --topic=my-topic \
  --message-body='{"type":"health_check"}' \
  --attributes=priority=high,source=scheduler
```

**App Engine Target:**
```bash
# Create App Engine job
gcloud scheduler jobs create app-engine my-app-job \
  --location=us-central1 \
  --schedule="0 0 * * 0" \
  --relative-url="/tasks/weekly-cleanup" \
  --http-method=POST \
  --service=default \
  --version=v1
```

---

## Cron Syntax

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
* * * * *
```

**Common Patterns:**
```bash
# Every minute
"* * * * *"

# Every 5 minutes
"*/5 * * * *"

# Every hour at minute 0
"0 * * * *"

# Every day at 9 AM
"0 9 * * *"

# Every Monday at 9 AM
"0 9 * * 1"

# First day of month at midnight
"0 0 1 * *"

# Every weekday at 6 PM
"0 18 * * 1-5"

# Every 15 minutes during business hours
"*/15 9-17 * * 1-5"
```

---

## Authentication

**OIDC Token:**
```bash
# Create job with OIDC authentication
gcloud scheduler jobs create http secure-job \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://example.com/secure-endpoint" \
  --oidc-service-account-email=scheduler@project.iam.gserviceaccount.com \
  --oidc-token-audience="https://example.com"
```

**OAuth Token:**
```bash
# Create job with OAuth token
gcloud scheduler jobs create http oauth-job \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://example.com/endpoint" \
  --oauth-service-account-email=scheduler@project.iam.gserviceaccount.com \
  --oauth-token-scope="https://www.googleapis.com/auth/cloud-platform"
```

---

## Retry Configuration

```bash
# Configure retry policy
gcloud scheduler jobs update http my-job \
  --location=us-central1 \
  --attempt-deadline=320s \
  --max-retry-attempts=5 \
  --max-retry-duration=3600s \
  --min-backoff-duration=5s \
  --max-backoff-duration=3600s \
  --max-doublings=5
```

---

## Time Zones

```bash
# Create job with specific timezone
gcloud scheduler jobs create http timezone-job \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://example.com/endpoint" \
  --time-zone="America/New_York"

# Common time zones
# America/New_York (EST/EDT)
# America/Los_Angeles (PST/PDT)
# Europe/London (GMT/BST)
# Asia/Tokyo (JST)
# UTC
```

---

## Job Management

```bash
# List jobs
gcloud scheduler jobs list --location=us-central1

# Describe job
gcloud scheduler jobs describe my-job --location=us-central1

# Update job
gcloud scheduler jobs update http my-job \
  --location=us-central1 \
  --schedule="0 10 * * *"

# Pause job
gcloud scheduler jobs pause my-job --location=us-central1

# Resume job
gcloud scheduler jobs resume my-job --location=us-central1

# Run job immediately
gcloud scheduler jobs run my-job --location=us-central1

# Delete job
gcloud scheduler jobs delete my-job --location=us-central1
```

---

## Integration Examples

**Trigger Cloud Function:**
```bash
# Create Pub/Sub topic
gcloud pubsub topics create function-trigger

# Create Cloud Function triggered by Pub/Sub
gcloud functions deploy my-function \
  --runtime=python39 \
  --trigger-topic=function-trigger

# Create scheduler job
gcloud scheduler jobs create pubsub trigger-function \
  --location=us-central1 \
  --schedule="0 * * * *" \
  --topic=function-trigger \
  --message-body='{"action":"process"}'
```

**Trigger Cloud Run:**
```bash
# Create scheduler job for Cloud Run
gcloud scheduler jobs create http trigger-cloud-run \
  --location=us-central1 \
  --schedule="0 9 * * *" \
  --uri="https://my-service-abc123-uc.a.run.app/process" \
  --oidc-service-account-email=scheduler@project.iam.gserviceaccount.com \
  --oidc-token-audience="https://my-service-abc123-uc.a.run.app"
```

**Trigger Dataflow:**
```bash
# Create job to trigger Dataflow
gcloud scheduler jobs create http trigger-dataflow \
  --location=us-central1 \
  --schedule="0 2 * * *" \
  --uri="https://dataflow.googleapis.com/v1b3/projects/PROJECT/locations/REGION/templates:launch?gcsPath=gs://dataflow-templates/latest/Word_Count" \
  --oauth-service-account-email=scheduler@project.iam.gserviceaccount.com \
  --oauth-token-scope="https://www.googleapis.com/auth/cloud-platform" \
  --http-method=POST \
  --headers="Content-Type=application/json" \
  --message-body='{"jobName":"scheduled-job","parameters":{}}'
```

---

## Monitoring

**View Logs:**
```bash
# View job execution logs
gcloud logging read \
  'resource.type="cloud_scheduler_job" AND resource.labels.job_id="my-job"' \
  --limit=50 \
  --format=json
```

**Create Alert:**
```bash
# Alert on job failures
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Scheduler Job Failures" \
  --condition-display-name="Job failed" \
  --condition-filter='resource.type="cloud_scheduler_job" AND metric.type="logging.googleapis.com/user/scheduler_job_failed"'
```

---

## Best Practices

✓ Use appropriate time zones  
✓ Implement idempotent jobs  
✓ Monitor job execution  
✓ Set retry configuration  
✓ Use Pub/Sub for fan-out  
✓ Test schedules before production  
✓ Document job purposes  
✓ Use descriptive job names  

---

## Common Use Cases

**Daily Reports:**
```bash
gcloud scheduler jobs create http daily-report \
  --schedule="0 9 * * *" \
  --uri="https://example.com/reports/daily" \
  --time-zone="America/New_York"
```

**Hourly Health Checks:**
```bash
gcloud scheduler jobs create http health-check \
  --schedule="0 * * * *" \
  --uri="https://example.com/health"
```

**Weekly Cleanup:**
```bash
gcloud scheduler jobs create pubsub weekly-cleanup \
  --schedule="0 0 * * 0" \
  --topic=cleanup-topic \
  --message-body='{"action":"cleanup"}'
```

**Monthly Billing:**
```bash
gcloud scheduler jobs create http monthly-billing \
  --schedule="0 0 1 * *" \
  --uri="https://example.com/billing/process"
```

---

## Pricing

```
First 3 jobs per month: Free
Additional jobs: $0.10 per job per month
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
