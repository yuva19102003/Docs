# Cloud KMS (Key Management Service)

Cryptographic key management for encryption.

---

## Overview

Cloud KMS allows you to create, use, rotate, and destroy cryptographic keys for encryption and signing.

---

## Key Concepts

**Key Ring:** Container for keys in a specific location  
**Key:** Cryptographic key for encryption/decryption  
**Key Version:** Specific version of a key  
**Purpose:** Encryption, signing, or MAC

---

## Creating Keys

```bash
# Create key ring
gcloud kms keyrings create my-keyring \
  --location=global

# Create encryption key
gcloud kms keys create my-key \
  --keyring=my-keyring \
  --location=global \
  --purpose=encryption

# Create signing key
gcloud kms keys create signing-key \
  --keyring=my-keyring \
  --location=global \
  --purpose=asymmetric-signing \
  --default-algorithm=rsa-sign-pkcs1-4096-sha512
```

---

## Encryption/Decryption

```bash
# Encrypt data
gcloud kms encrypt \
  --key=my-key \
  --keyring=my-keyring \
  --location=global \
  --plaintext-file=data.txt \
  --ciphertext-file=data.enc

# Decrypt data
gcloud kms decrypt \
  --key=my-key \
  --keyring=my-keyring \
  --location=global \
  --ciphertext-file=data.enc \
  --plaintext-file=decrypted.txt
```

**Python:**
```python
from google.cloud import kms

def encrypt_symmetric(project_id, location_id, key_ring_id, key_id, plaintext):
    client = kms.KeyManagementServiceClient()
    key_name = client.crypto_key_path(project_id, location_id, key_ring_id, key_id)
    
    response = client.encrypt(request={'name': key_name, 'plaintext': plaintext.encode('utf-8')})
    return response.ciphertext
```

---

## CMEK (Customer-Managed Encryption Keys)

**Cloud Storage:**
```bash
# Create bucket with CMEK
gsutil mb -p PROJECT_ID \
  -c STANDARD \
  -l US \
  -k projects/PROJECT/locations/global/keyRings/KEYRING/cryptoKeys/KEY \
  gs://my-bucket
```

**Compute Engine:**
```bash
# Create disk with CMEK
gcloud compute disks create my-disk \
  --size=100GB \
  --kms-key=projects/PROJECT/locations/global/keyRings/KEYRING/cryptoKeys/KEY
```

---

## Key Rotation

```bash
# Set rotation period
gcloud kms keys update my-key \
  --keyring=my-keyring \
  --location=global \
  --rotation-period=90d \
  --next-rotation-time=2026-06-01T00:00:00Z

# Manual rotation
gcloud kms keys versions create \
  --key=my-key \
  --keyring=my-keyring \
  --location=global \
  --primary
```

---

## Best Practices

✓ Use automatic key rotation  
✓ Separate keys by environment  
✓ Use regional keys for data residency  
✓ Enable audit logging  
✓ Implement least privilege  
✓ Regular key review  

---

**Last Updated:** March 2026
