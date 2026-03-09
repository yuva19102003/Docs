# VPC Service Controls

Perimeter security for GCP services.

---

## Overview

VPC Service Controls creates security perimeters around GCP resources to prevent data exfiltration and unauthorized access.

---

## Key Concepts

**Service Perimeter:** Security boundary around GCP resources  
**Access Level:** Conditions for accessing resources  
**Access Policy:** Container for perimeters and levels  
**Bridge:** Connection between perimeters

---

## Creating Access Policy

```bash
# Create access policy
gcloud access-context-manager policies create \
  --organization=ORGANIZATION_ID \
  --title="My Access Policy"

# List policies
gcloud access-context-manager policies list \
  --organization=ORGANIZATION_ID
```

---

## Access Levels

```bash
# Create access level
gcloud access-context-manager levels create corporate_network \
  --policy=POLICY_ID \
  --title="Corporate Network" \
  --basic-level-spec=access-level.yaml
```

**access-level.yaml:**
```yaml
conditions:
  - ipSubnetworks:
    - "203.0.113.0/24"
    - "198.51.100.0/24"
  - members:
    - "user:admin@example.com"
  - devicePolicy:
      requireScreenlock: true
      requireCorpOwned: true
```

---

## Service Perimeters

```bash
# Create service perimeter
gcloud access-context-manager perimeters create my-perimeter \
  --policy=POLICY_ID \
  --title="Production Perimeter" \
  --resources=projects/PROJECT_NUMBER \
  --restricted-services=storage.googleapis.com,bigquery.googleapis.com \
  --access-levels=corporate_network

# Add project to perimeter
gcloud access-context-manager perimeters update my-perimeter \
  --add-resources=projects/NEW_PROJECT_NUMBER \
  --policy=POLICY_ID
```

---

## Restricted Services

Common services to restrict:
- storage.googleapis.com
- bigquery.googleapis.com
- bigtable.googleapis.com
- container.googleapis.com
- pubsub.googleapis.com
- spanner.googleapis.com

```bash
# List supported services
gcloud access-context-manager supported-services list
```

---

## Ingress/Egress Rules

**Ingress Policy:**
```yaml
ingressPolicies:
  - ingressFrom:
      sources:
        - accessLevel: accessPolicies/POLICY_ID/accessLevels/corporate_network
      identities:
        - serviceAccount:app@project.iam.gserviceaccount.com
    ingressTo:
      resources:
        - projects/PROJECT_NUMBER
      operations:
        - serviceName: storage.googleapis.com
          methodSelectors:
            - method: "*"
```

**Egress Policy:**
```yaml
egressPolicies:
  - egressFrom:
      identities:
        - serviceAccount:app@project.iam.gserviceaccount.com
    egressTo:
      resources:
        - projects/EXTERNAL_PROJECT_NUMBER
      operations:
        - serviceName: bigquery.googleapis.com
```

---

## Perimeter Bridges

```bash
# Create bridge between perimeters
gcloud access-context-manager perimeters create bridge-perimeter \
  --policy=POLICY_ID \
  --title="Bridge" \
  --perimeter-type=bridge \
  --resources=projects/PROJECT1_NUMBER,projects/PROJECT2_NUMBER
```

---

## Dry Run Mode

```bash
# Create perimeter in dry run mode
gcloud access-context-manager perimeters dry-run create my-perimeter \
  --policy=POLICY_ID \
  --resources=projects/PROJECT_NUMBER \
  --restricted-services=storage.googleapis.com

# Enforce dry run configuration
gcloud access-context-manager perimeters dry-run enforce my-perimeter \
  --policy=POLICY_ID
```

---

## Monitoring

```bash
# View VPC-SC logs
gcloud logging read \
  'protoPayload.metadata."@type"="type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata"' \
  --limit=50

# Create alert for violations
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="VPC-SC Violation" \
  --condition-filter='resource.type="audited_resource" AND protoPayload.metadata.vpcServiceControlsUniqueId!=""'
```

---

## Best Practices

✓ Start with dry run mode  
✓ Use access levels for conditions  
✓ Implement least privilege  
✓ Monitor violations  
✓ Regular perimeter review  
✓ Document perimeter design  
✓ Test before enforcement  

---

**Last Updated:** March 2026
