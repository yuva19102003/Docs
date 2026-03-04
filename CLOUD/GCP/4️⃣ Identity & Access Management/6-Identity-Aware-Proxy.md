# Identity-Aware Proxy (IAP)

Complete guide to Identity-Aware Proxy - application-level access control without VPNs in Google Cloud Platform.

---

## 📚 Overview

Identity-Aware Proxy (IAP) lets you establish a central authorization layer for applications accessed by HTTPS, enabling you to adopt an application-level access control model instead of relying on network-level firewalls.

**Key Benefits:**
- **Zero Trust Security**: Verify identity and context for every request
- **No VPN Required**: Access internal apps from anywhere securely
- **Centralized Access Control**: Manage access in one place
- **Context-Aware**: Consider device, location, and other factors
- **Easy Integration**: Works with existing applications

---

## 🎯 What is IAP?

```
┌────────────────────────────────────────────────────────┐
│  Traditional Access vs IAP                             │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Traditional VPN Model:                                │
│  User → VPN → Network → Application                    │
│  • Network-level trust                                 │
│  • Once inside, access everything                      │
│  • Complex VPN management                              │
│  • Poor user experience                                │
│                                                         │
│  IAP Model:                                            │
│  User → IAP → Application                              │
│  • Application-level trust                             │
│  • Per-app access control                              │
│  • No VPN needed                                       │
│  • Better user experience                              │
│  • Context-aware decisions                             │
│                                                         │
│  IAP Verifies:                                         │
│  ✓ User identity (who)                                 │
│  ✓ User authorization (what they can access)           │
│  ✓ Context (device, location, time)                    │
│  ✓ Request validity                                    │
└────────────────────────────────────────────────────────┘
```

---

## 🏗️ IAP Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  IAP Request Flow                                                │
└─────────────────────────────────────────────────────────────────┘

Step 1: User Request
┌─────────────────────┐
│  User Browser       │
│  https://app.com    │
└──────────┬──────────┘
           │
           ▼
Step 2: IAP Authentication
┌─────────────────────┐
│  Identity-Aware     │
│  Proxy              │
│  • Check auth       │
│  • Verify identity  │
└──────────┬──────────┘
           │
           ▼
Step 3: Authorization Check
┌─────────────────────┐
│  IAM Policy         │
│  • Check IAP access │
│  • Verify role      │
└──────────┬──────────┘
           │
           ▼
Step 4: Context Evaluation (Optional)
┌─────────────────────┐
│  Access Context     │
│  Manager            │
│  • Device policy    │
│  • IP range         │
│  • Access level     │
└──────────┬──────────┘
           │
           ▼
Step 5: Forward Request
┌─────────────────────┐
│  Backend            │
│  Application        │
│  • Receives request │
│  • With IAP headers │
└─────────────────────┘

IAP adds headers:
  X-Goog-IAP-JWT-Assertion: <signed JWT>
  X-Goog-Authenticated-User-Email: user@company.com
  X-Goog-Authenticated-User-ID: 123456789
```

---

## 🚀 Setting Up IAP

### 1. Enable IAP for App Engine

```bash
# Enable IAP API
gcloud services enable iap.googleapis.com

# Enable IAP for App Engine
gcloud app services update default \
  --ingress=internal-and-cloud-load-balancing

# Grant IAP access to users
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --service=default \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor'

# Grant access to group
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --service=default \
  --member='group:developers@company.com' \
  --role='roles/iap.httpsResourceAccessor'
```

### 2. Enable IAP for Compute Engine

```bash
# Create backend service with IAP
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=web-health-check \
  --global \
  --iap=enabled

# Configure OAuth consent screen (one-time setup)
# Go to: APIs & Services → OAuth consent screen
# Configure: App name, support email, authorized domains

# Create OAuth credentials
gcloud iap oauth-brands create \
  --application_title="My Application" \
  --support_email="support@company.com"

# Enable IAP
gcloud iap web enable \
  --resource-type=backend-services \
  --service=web-backend

# Grant access
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service=web-backend \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor'
```

### 3. Enable IAP for GKE

```yaml
# Create BackendConfig with IAP
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: iap-backendconfig
  namespace: default
spec:
  iap:
    enabled: true
    oauthclientCredentials:
      secretName: oauth-client-secret
---
# Create OAuth secret
apiVersion: v1
kind: Secret
metadata:
  name: oauth-client-secret
  namespace: default
type: Opaque
stringData:
  client_id: YOUR_CLIENT_ID
  client_secret: YOUR_CLIENT_SECRET
---
# Service with BackendConfig annotation
apiVersion: v1
kind: Service
metadata:
  name: web-service
  annotations:
    cloud.google.com/backend-config: '{"default": "iap-backendconfig"}'
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

```bash
# Grant IAP access for GKE service
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service=SERVICE_NAME \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor'
```

---

## 🔐 IAP for SSH and TCP

### 1. Enable IAP for SSH

```bash
# Enable IAP for TCP forwarding
gcloud services enable iap.googleapis.com

# Grant IAP tunnel user role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/iap.tunnelResourceAccessor'

# Also need compute instance access
gcloud compute instances add-iam-policy-binding my-vm \
  --zone=us-central1-a \
  --member='user:alice@company.com' \
  --role='roles/compute.instanceAdmin.v1'

# SSH via IAP tunnel (no external IP needed!)
gcloud compute ssh my-vm \
  --zone=us-central1-a \
  --tunnel-through-iap

# Or use standard SSH with IAP
ssh -o ProxyCommand="gcloud compute start-iap-tunnel %h %p" my-vm
```

### 2. Enable IAP for RDP (Windows)

```bash
# Grant IAP access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='user:alice@company.com' \
  --role='roles/iap.tunnelResourceAccessor'

# Start IAP tunnel for RDP
gcloud compute start-iap-tunnel windows-vm 3389 \
  --local-host-port=localhost:3389 \
  --zone=us-central1-a

# Connect with RDP client to localhost:3389
```

### 3. IAP for Database Access

```bash
# Access Cloud SQL via IAP tunnel
gcloud compute start-iap-tunnel bastion-vm 3306 \
  --local-host-port=localhost:3306 \
  --zone=us-central1-a

# Connect to MySQL
mysql -h 127.0.0.1 -P 3306 -u root -p

# Access PostgreSQL
gcloud compute start-iap-tunnel bastion-vm 5432 \
  --local-host-port=localhost:5432 \
  --zone=us-central1-a

psql -h 127.0.0.1 -p 5432 -U postgres
```

---

## 🛡️ Verifying IAP Requests

### 1. Validate JWT in Application

```python
# Python: Verify IAP JWT
from google.auth.transport import requests
from google.oauth2 import id_token

def verify_iap_jwt(iap_jwt, expected_audience):
    """Verify IAP JWT token"""
    try:
        decoded_jwt = id_token.verify_token(
            iap_jwt,
            requests.Request(),
            audience=expected_audience,
            certs_url='https://www.gstatic.com/iap/verify/public_key'
        )
        
        # Extract user info
        user_email = decoded_jwt.get('email')
        user_id = decoded_jwt.get('sub')
        
        return user_email, user_id
    except Exception as e:
        print(f"JWT verification failed: {e}")
        return None, None

# In your Flask/Django app
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def index():
    # Get IAP JWT from header
    iap_jwt = request.headers.get('X-Goog-IAP-JWT-Assertion')
    
    if not iap_jwt:
        return 'No IAP JWT found', 401
    
    # Verify JWT
    expected_audience = '/projects/PROJECT_NUMBER/apps/PROJECT_ID'
    user_email, user_id = verify_iap_jwt(iap_jwt, expected_audience)
    
    if not user_email:
        return 'Invalid IAP JWT', 401
    
    return f'Hello {user_email}!'
```

```javascript
// Node.js: Verify IAP JWT
const { OAuth2Client } = require('google-auth-library');

async function verifyIapJwt(iapJwt, expectedAudience) {
  const oAuth2Client = new OAuth2Client();
  
  try {
    const ticket = await oAuth2Client.verifyIdToken({
      idToken: iapJwt,
      audience: expectedAudience
    });
    
    const payload = ticket.getPayload();
    return {
      email: payload.email,
      userId: payload.sub
    };
  } catch (error) {
    console.error('JWT verification failed:', error);
    return null;
  }
}

// Express middleware
app.use(async (req, res, next) => {
  const iapJwt = req.headers['x-goog-iap-jwt-assertion'];
  
  if (!iapJwt) {
    return res.status(401).send('No IAP JWT');
  }
  
  const expectedAudience = '/projects/PROJECT_NUMBER/apps/PROJECT_ID';
  const user = await verifyIapJwt(iapJwt, expectedAudience);
  
  if (!user) {
    return res.status(401).send('Invalid IAP JWT');
  }
  
  req.user = user;
  next();
});
```

### 2. Get User Information

```python
# Extract user info from IAP headers
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def index():
    # IAP automatically adds these headers
    user_email = request.headers.get('X-Goog-Authenticated-User-Email')
    user_id = request.headers.get('X-Goog-Authenticated-User-ID')
    
    # Remove 'accounts.google.com:' prefix
    if user_email:
        user_email = user_email.split(':')[1]
    if user_id:
        user_id = user_id.split(':')[1]
    
    return f'Hello {user_email} (ID: {user_id})'
```

---

## 🎯 Context-Aware Access

### 1. Access Levels

```bash
# Create access level based on IP range
gcloud access-context-manager levels create corporate_network \
  --title="Corporate Network" \
  --basic-level-spec=ip_subnetworks=203.0.113.0/24,198.51.100.0/24 \
  --policy=POLICY_ID

# Create access level based on device policy
gcloud access-context-manager levels create managed_devices \
  --title="Managed Devices" \
  --basic-level-spec=require_screen_lock=true,require_corp_owned=true \
  --policy=POLICY_ID

# Create access level combining conditions
gcloud access-context-manager levels create secure_access \
  --title="Secure Access" \
  --basic-level-spec=ip_subnetworks=203.0.113.0/24,require_screen_lock=true \
  --combine-function=AND \
  --policy=POLICY_ID
```

### 2. Apply Access Levels to IAP

```bash
# Create IAM condition with access level
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --service=default \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --condition='expression=accessPolicies/POLICY_ID/accessLevels/corporate_network,title=Corporate Network Only'

# Multiple access levels
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --service=default \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --condition='expression=accessPolicies/POLICY_ID/accessLevels/corporate_network || accessPolicies/POLICY_ID/accessLevels/managed_devices,title=Corporate or Managed Device'
```

---

## 📊 Monitoring and Logging

### 1. IAP Access Logs

```bash
# View IAP access logs
gcloud logging read \
  'resource.type="gae_app" AND 
   protoPayload.resourceName=~"iap"' \
  --limit=50 \
  --format=json

# View denied access attempts
gcloud logging read \
  'resource.type="gae_app" AND 
   protoPayload.status.code!=0 AND 
   protoPayload.resourceName=~"iap"' \
  --limit=50

# View specific user access
gcloud logging read \
  'protoPayload.authenticationInfo.principalEmail="alice@company.com" AND 
   protoPayload.resourceName=~"iap"' \
  --limit=50
```

### 2. Create Alerts

```bash
# Alert on IAP access denials
gcloud logging sinks create iap-denials \
  --log-filter='resource.type="gae_app" AND protoPayload.status.code!=0 AND protoPayload.resourceName=~"iap"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/security-alerts

# Alert on new IAP users
gcloud logging sinks create iap-new-users \
  --log-filter='protoPayload.methodName="SetIamPolicy" AND protoPayload.request.policy.bindings.role="roles/iap.httpsResourceAccessor"' \
  --destination=pubsub.googleapis.com/projects/PROJECT_ID/topics/iam-changes
```

---

## 🔧 Troubleshooting

### Common Issues

**Issue: "You don't have access"**
```bash
# Check if user has IAP role
gcloud iap web get-iam-policy \
  --resource-type=app-engine \
  --service=default

# Grant access
gcloud iap web add-iam-policy-binding \
  --resource-type=app-engine \
  --service=default \
  --member='user:alice@company.com' \
  --role='roles/iap.httpsResourceAccessor'

# Check OAuth consent screen configuration
# Go to: APIs & Services → OAuth consent screen
```

**Issue: IAP not enabled**
```bash
# Check if IAP is enabled
gcloud iap web get-iam-policy \
  --resource-type=app-engine \
  --service=default

# Enable IAP
gcloud app services update default \
  --ingress=internal-and-cloud-load-balancing
```

**Issue: JWT verification fails**
```python
# Common causes:
# 1. Wrong audience in verification
# 2. Clock skew
# 3. Expired token
# 4. Invalid signature

# Debug JWT
import jwt
import json

iap_jwt = request.headers.get('X-Goog-IAP-JWT-Assertion')
decoded = jwt.decode(iap_jwt, options={"verify_signature": False})
print(json.dumps(decoded, indent=2))

# Check audience matches your project
# audience should be: /projects/PROJECT_NUMBER/apps/PROJECT_ID
```

---

## ✅ Best Practices

### Security
- [ ] Always verify JWT in application code
- [ ] Use context-aware access when possible
- [ ] Enable audit logging
- [ ] Regular access reviews
- [ ] Use groups instead of individual users
- [ ] Implement least privilege
- [ ] Monitor for unusual access patterns

### Configuration
- [ ] Configure OAuth consent screen properly
- [ ] Use meaningful OAuth client names
- [ ] Document IAP-protected resources
- [ ] Test access from different contexts
- [ ] Have break-glass procedures

### Operations
- [ ] Monitor IAP access logs
- [ ] Set up alerts for denials
- [ ] Regular security audits
- [ ] Keep documentation updated
- [ ] Train users on IAP access

---

## 🎓 Next Steps

1. Explore [Advanced IAM](./7-Advanced-IAM.md) features
2. Review [Best Practices](./8-Best-Practices.md) for enterprise IAM
3. Return to [Least Privilege](./5-Least-Privilege.md) for access control strategies
4. Learn about [Service Accounts](./3-Service-Accounts.md) for application identity

---

**Last Updated:** March 2026
**Version:** 2.0
