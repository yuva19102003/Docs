# Secret Manager

Secure storage for API keys, passwords, and certificates.

---

## Overview

Secret Manager provides a secure and convenient method for storing API keys, passwords, certificates, and other sensitive data.

---

## Key Features

- Encrypted storage
- Version management
- Access control (IAM)
- Audit logging
- Automatic replication
- Integration with GCP services

---

## Creating Secrets

**Via gcloud:**
```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret \
  --data-file=- \
  --replication-policy="automatic"

# Create secret from file
gcloud secrets create db-password \
  --data-file=password.txt

# Create with specific locations
gcloud secrets create my-secret \
  --data-file=- \
  --replication-policy="user-managed" \
  --locations="us-central1,us-east1"
```

**Via API:**
```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
parent = f"projects/{project_id}"

# Create secret
secret = client.create_secret(
    request={
        "parent": parent,
        "secret_id": "my-secret",
        "secret": {
            "replication": {"automatic": {}}
        }
    }
)

# Add secret version
client.add_secret_version(
    request={
        "parent": secret.name,
        "payload": {"data": b"my-secret-value"}
    }
)
```

---

## Accessing Secrets

**Python:**
```python
from google.cloud import secretmanager

def access_secret(project_id, secret_id, version_id="latest"):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
```

**Node.js:**
```javascript
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const client = new SecretManagerServiceClient();

async function accessSecret(projectId, secretId) {
  const name = `projects/${projectId}/secrets/${secretId}/versions/latest`;
  const [version] = await client.accessSecretVersion({name});
  return version.payload.data.toString();
}
```

**Go:**
```go
import secretmanager "cloud.google.com/go/secretmanager/apiv1"

func accessSecret(projectID, secretID string) (string, error) {
    ctx := context.Background()
    client, _ := secretmanager.NewClient(ctx)
    defer client.Close()

    name := fmt.Sprintf("projects/%s/secrets/%s/versions/latest", projectID, secretID)
    result, _ := client.AccessSecretVersion(ctx, &secretmanagerpb.AccessSecretVersionRequest{
        Name: name,
    })

    return string(result.Payload.Data), nil
}
```

---

## IAM Permissions

```bash
# Grant access to secret
gcloud secrets add-iam-policy-binding my-secret \
  --member=serviceAccount:my-sa@project.iam.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor

# Grant admin access
gcloud secrets add-iam-policy-binding my-secret \
  --member=user:admin@example.com \
  --role=roles/secretmanager.admin
```

**Roles:**
- `roles/secretmanager.admin` - Full access
- `roles/secretmanager.secretAccessor` - Read secrets
- `roles/secretmanager.secretVersionManager` - Manage versions
- `roles/secretmanager.viewer` - View metadata only

---

## Version Management

```bash
# Add new version
echo -n "new-value" | gcloud secrets versions add my-secret \
  --data-file=-

# List versions
gcloud secrets versions list my-secret

# Disable version
gcloud secrets versions disable 1 --secret=my-secret

# Destroy version
gcloud secrets versions destroy 1 --secret=my-secret

# Access specific version
gcloud secrets versions access 2 --secret=my-secret
```

---

## Integration Examples

### Cloud Run

```bash
# Mount secret as environment variable
gcloud run deploy my-service \
  --image=IMAGE_URL \
  --update-secrets=DB_PASSWORD=my-secret:latest

# Mount secret as volume
gcloud run deploy my-service \
  --image=IMAGE_URL \
  --update-secrets=/secrets/db-password=my-secret:latest
```

### GKE

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-ksa
  containers:
  - name: app
    image: my-image
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-password
          key: latest
```

### Cloud Functions

```python
import os
from google.cloud import secretmanager

def my_function(request):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{os.environ['GCP_PROJECT']}/secrets/my-secret/versions/latest"
    response = client.access_secret_version(request={"name": name})
    secret_value = response.payload.data.decode("UTF-8")
    # Use secret_value
```

---

## Best Practices

✓ Use automatic replication for HA  
✓ Implement least privilege access  
✓ Enable audit logging  
✓ Rotate secrets regularly  
✓ Use version management  
✓ Never commit secrets to code  
✓ Use service accounts for applications  
✓ Monitor secret access  

---

## Pricing

```
Storage: $0.06 per secret per month
Access: $0.03 per 10,000 operations
Replication: Additional cost for user-managed
```

---

**Last Updated:** March 2026  
**Status:** ✅ Complete
