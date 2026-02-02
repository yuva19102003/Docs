# Storage Classes

StorageClasses provide dynamic provisioning of persistent volumes in Kubernetes.

## StorageClass Overview

```
┌────────────────────────────────────────────────┐
│      Dynamic Provisioning Flow                │
├────────────────────────────────────────────────┤
│                                                │
│  User Creates PVC                              │
│         ↓                                      │
│  StorageClass Provisions PV                    │
│         ↓                                      │
│  PVC Binds to PV                              │
│         ↓                                      │
│  Pod Uses PVC                                  │
│                                                │
└────────────────────────────────────────────────┘
```

## Basic StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Cloud Provider StorageClasses

### AWS EBS

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-east-1:123456789:key/..."
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### GCP Persistent Disk

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gcp-pd-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Azure Disk

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-premium
provisioner: disk.csi.azure.com
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
  cachingmode: ReadOnly
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Volume Binding Modes

### WaitForFirstConsumer

```yaml
volumeBindingMode: WaitForFirstConsumer
```

**Benefits:**
- Delays provisioning until pod is scheduled
- Ensures volume in same zone as pod
- Prevents cross-zone mounting issues

### Immediate

```yaml
volumeBindingMode: Immediate
```

**Behavior:**
- Provisions volume immediately
- May cause scheduling issues
- Use for pre-provisioned volumes

## Common Provisioners

### CSI Drivers

```yaml
# AWS EBS CSI
provisioner: ebs.csi.aws.com

# GCP PD CSI
provisioner: pd.csi.storage.gke.io

# Azure Disk CSI
provisioner: disk.csi.azure.com

# NFS CSI
provisioner: nfs.csi.k8s.io
```

## StorageClass Examples

### Fast SSD Storage

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  iops: "10000"
  encrypted: "true"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Standard HDD Storage

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard-hdd
provisioner: ebs.csi.aws.com
parameters:
  type: st1
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Using StorageClass

### In PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

## Default StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
```

## Commands

```bash
# List storage classes
kubectl get storageclass
kubectl get sc

# Describe storage class
kubectl describe sc standard

# Get default storage class
kubectl get sc -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}'

# Set default storage class
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Create storage class
kubectl apply -f storageclass.yaml

# Delete storage class
kubectl delete sc standard
```

## Best Practices

1. **Use CSI Drivers**
2. **Enable Volume Expansion**
3. **Use WaitForFirstConsumer**
4. **Set Appropriate Reclaim Policy**
5. **Enable Encryption**
6. **Document Storage Classes**

## References

- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [CSI Drivers](https://kubernetes-csi.github.io/docs/drivers.html)
