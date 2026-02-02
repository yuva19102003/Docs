# Custom Resources (CRDs)

Extend Kubernetes API with custom resource definitions.

## Custom Resource Definition (CRD)

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: applications.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: ["replicas", "image"]
            properties:
              replicas:
                type: integer
                minimum: 1
                maximum: 10
              image:
                type: string
              port:
                type: integer
                default: 8080
          status:
            type: object
            properties:
              availableReplicas:
                type: integer
              conditions:
                type: array
                items:
                  type: object
                  properties:
                    type:
                      type: string
                    status:
                      type: string
                    lastTransitionTime:
                      type: string
                      format: date-time
    subresources:
      status: {}
      scale:
        specReplicasPath: .spec.replicas
        statusReplicasPath: .status.availableReplicas
  scope: Namespaced
  names:
    plural: applications
    singular: application
    kind: Application
    shortNames:
    - app
```

## Custom Resource

```yaml
apiVersion: example.com/v1
kind: Application
metadata:
  name: my-app
spec:
  replicas: 3
  image: myapp:1.0
  port: 8080
```

## CRD Validation

```yaml
schema:
  openAPIV3Schema:
    type: object
    properties:
      spec:
        type: object
        required: ["size"]
        properties:
          size:
            type: string
            enum: ["small", "medium", "large"]
          replicas:
            type: integer
            minimum: 1
            maximum: 100
          resources:
            type: object
            properties:
              cpu:
                type: string
                pattern: '^[0-9]+m?$'
              memory:
                type: string
                pattern: '^[0-9]+[MGT]i$'
```

## Subresources

### Status Subresource

```yaml
subresources:
  status: {}
```

### Scale Subresource

```yaml
subresources:
  scale:
    specReplicasPath: .spec.replicas
    statusReplicasPath: .status.replicas
    labelSelectorPath: .status.labelSelector
```

## Versions

```yaml
versions:
- name: v1
  served: true
  storage: true
  schema:
    openAPIV3Schema:
      # v1 schema
- name: v1beta1
  served: true
  storage: false
  schema:
    openAPIV3Schema:
      # v1beta1 schema
```

## Conversion Webhook

```yaml
conversion:
  strategy: Webhook
  webhook:
    clientConfig:
      service:
        namespace: default
        name: conversion-webhook
        path: /convert
    conversionReviewVersions: ["v1", "v1beta1"]
```

## Additional Printer Columns

```yaml
additionalPrinterColumns:
- name: Replicas
  type: integer
  jsonPath: .spec.replicas
- name: Available
  type: integer
  jsonPath: .status.availableReplicas
- name: Age
  type: date
  jsonPath: .metadata.creationTimestamp
```

## CRD Commands

```bash
# Create CRD
kubectl apply -f crd.yaml

# List CRDs
kubectl get crds

# Describe CRD
kubectl describe crd applications.example.com

# Delete CRD
kubectl delete crd applications.example.com

# List custom resources
kubectl get applications

# Create custom resource
kubectl apply -f application.yaml

# Get custom resource
kubectl get application my-app -o yaml

# Delete custom resource
kubectl delete application my-app
```

## Best Practices

1. **Use Validation**
2. **Version Your CRDs**
3. **Use Status Subresource**
4. **Add Printer Columns**
5. **Document Your CRD**
6. **Use Short Names**

## References

- [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [CRD Versioning](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/)
