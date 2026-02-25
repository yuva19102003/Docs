# OpenShift Projects and Namespaces

## Overview

Projects in OpenShift are an extension of Kubernetes namespaces with additional features for multi-tenancy, access control, and resource management.

## Projects vs Namespaces

### Kubernetes Namespace
- Basic resource isolation
- Logical grouping of resources
- Simple RBAC

### OpenShift Project
- Wraps Kubernetes namespace
- Additional annotations and labels
- Built-in network isolation
- Resource quotas and limits
- Self-provisioning capabilities

## Creating Projects

### Using oc CLI
```bash
# Create a new project
oc new-project myproject

# Create with display name and description
oc new-project myproject \
  --display-name="My Application" \
  --description="Production application"
```

### Using YAML
```yaml
apiVersion: project.openshift.io/v1
kind: Project
metadata:
  name: myproject
  annotations:
    openshift.io/description: "Production application"
    openshift.io/display-name: "My Application"
```

## Managing Projects

### List Projects
```bash
# List all projects
oc projects

# Get current project
oc project

# Switch to a project
oc project myproject
```

### Project Information
```bash
# Describe project
oc describe project myproject

# Get project details
oc get project myproject -o yaml
```

### Delete Project
```bash
# Delete a project (deletes all resources)
oc delete project myproject
```

## Resource Quotas

### Define Resource Limits
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: myproject
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
    pods: "20"
```

### Apply Quota
```bash
oc create -f resource-quota.yaml -n myproject

# View quotas
oc get quota -n myproject
oc describe quota compute-quota -n myproject
```

## Limit Ranges

### Define Default Limits
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: myproject
spec:
  limits:
  - type: Pod
    max:
      cpu: "2"
      memory: 4Gi
    min:
      cpu: 100m
      memory: 128Mi
  - type: Container
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    max:
      cpu: "2"
      memory: 4Gi
    min:
      cpu: 50m
      memory: 64Mi
```

## Network Policies

### Isolate Project Network
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: myproject
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Allow Specific Traffic
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-same-namespace
  namespace: myproject
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
```

## Project Templates

### Custom Project Template
```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-request
objects:
- apiVersion: project.openshift.io/v1
  kind: Project
  metadata:
    name: ${PROJECT_NAME}
    annotations:
      openshift.io/description: ${PROJECT_DESCRIPTION}
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: default-quota
    namespace: ${PROJECT_NAME}
  spec:
    hard:
      requests.cpu: "4"
      requests.memory: 8Gi
parameters:
- name: PROJECT_NAME
- name: PROJECT_DESCRIPTION
```

## RBAC in Projects

### Grant User Access
```bash
# Add admin role
oc adm policy add-role-to-user admin user1 -n myproject

# Add edit role
oc adm policy add-role-to-user edit user2 -n myproject

# Add view role
oc adm policy add-role-to-user view user3 -n myproject
```

### Service Account Permissions
```bash
# Create service account
oc create sa myapp-sa -n myproject

# Grant permissions
oc adm policy add-role-to-user edit system:serviceaccount:myproject:myapp-sa
```

## Best Practices

1. **Naming Convention**: Use descriptive, consistent names
2. **Resource Quotas**: Always set quotas to prevent resource exhaustion
3. **Network Policies**: Implement network isolation
4. **RBAC**: Follow principle of least privilege
5. **Labels**: Use labels for organization and selection
6. **Cleanup**: Regularly remove unused projects

## Common Commands

```bash
# Create project with quota
oc new-project myproject
oc create quota my-quota --hard=pods=10,services=5 -n myproject

# View all resources in project
oc get all -n myproject

# Export project configuration
oc get project myproject -o yaml > project.yaml

# Check project status
oc status -n myproject

# View project events
oc get events -n myproject
```
