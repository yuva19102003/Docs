# OpenShift Storage

## Overview

OpenShift provides persistent storage for applications using Persistent Volumes (PV), Persistent Volume Claims (PVC), and Storage Classes.

## Storage Types

### Persistent Volume (PV)
Cluster-level storage resource provisioned by administrator.

### Persistent Volume Claim (PVC)
Request for storage by a user/application.

### Storage Class
Dynamic provisioning template for storage.

## Storage Classes

### List Storage Classes
```bash
oc get storageclass
oc get sc
```

### Default Storage Class
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
```

## Creating PVC

### Basic PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-pvc
  namespace: myproject
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

### Using CLI
```bash
oc create -f pvc.yaml
oc get pvc
oc describe pvc myapp-pvc
```

## Access Modes

| Mode | Abbreviation | Description |
|------|-------------|-------------|
| ReadWriteOnce | RWO | Single node read-write |
| ReadOnlyMany | ROX | Multiple nodes read-only |
| ReadWriteMany | RWX | Multiple nodes read-write |

## Using Storage in Pods

### Mount PVC in Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: myapp-pvc
```

## Dynamic Provisioning

### AWS EBS
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
```

### Azure Disk
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
```

### NFS
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs
provisioner: example.com/nfs
parameters:
  server: nfs-server.example.com
  path: /exports
```

## Static Provisioning

### Create PV
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: nfs-server.example.com
    path: /exports/data
```

### Create Matching PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  volumeName: pv-nfs
```

## Volume Snapshots

### Create VolumeSnapshotClass
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapclass
driver: ebs.csi.aws.com
deletionPolicy: Delete
```

### Create Snapshot
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: myapp-snapshot
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: myapp-pvc
```

### Restore from Snapshot
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-restored
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  dataSource:
    name: myapp-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

## ConfigMaps and Secrets as Volumes

### ConfigMap Volume
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.json: |
    {
      "key": "value"
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

### Secret Volume
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=
---
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: secret
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: secret
    secret:
      secretName: app-secret
```

## EmptyDir Volumes

### Temporary Storage
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: cache
      mountPath: /cache
  volumes:
  - name: emptyDir
    emptyDir: {}
```

## Managing Storage

### CLI Commands
```bash
# List PVCs
oc get pvc

# Describe PVC
oc describe pvc myapp-pvc

# Delete PVC
oc delete pvc myapp-pvc

# Expand PVC (if supported)
oc patch pvc myapp-pvc -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# View PV
oc get pv
```

## Storage Troubleshooting

### Check PVC Status
```bash
# Get PVC status
oc get pvc myapp-pvc

# Common statuses:
# - Pending: Waiting for provisioning
# - Bound: Successfully bound to PV
# - Lost: PV no longer exists
```

### Debug Storage Issues
```bash
# Check events
oc get events --field-selector involvedObject.name=myapp-pvc

# Check storage class
oc describe sc standard

# Verify pod mounting
oc describe pod myapp-pod
```

## Best Practices

1. **Use Storage Classes**: Leverage dynamic provisioning
2. **Right-Size**: Request appropriate storage sizes
3. **Access Modes**: Choose correct access mode for workload
4. **Backup**: Implement regular snapshot/backup strategy
5. **Monitoring**: Monitor storage usage and performance
6. **Reclaim Policy**: Set appropriate reclaim policies
7. **Encryption**: Enable encryption for sensitive data
