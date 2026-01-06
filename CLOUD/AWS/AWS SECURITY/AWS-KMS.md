
## 1. 🌐 Overview of AWS KMS

**AWS Key Management Service (KMS)** is a fully managed service that enables you to create and control encryption keys used to encrypt your data.

- **Region-specific**
    
- **Highly available**
    
- Integrated with 50+ AWS services
    

---

## 2. 🧠 Key Concepts

|Concept|Description|
|---|---|
|CMK|Customer Master Key (symmetric or asymmetric)|
|Key Material|Data used to perform cryptographic operations|
|Key Policy|Defines who can use and manage the key|
|Envelope Encryption|Encrypting data using a data key encrypted with a master key|

---

## 3. 🔑 Types of Keys

|Type|Description|
|---|---|
|Symmetric CMK|Default; used for encryption and decryption|
|Asymmetric CMK|Public-private key pair for signing and encryption|
|AWS Managed CMK|Created and managed by AWS|
|Customer Managed CMK|Full control, custom policies|
|Imported Key Material|Bring Your Own Key (BYOK)|

---

## 4. 🔧 Creating and Managing Keys

### Practical: Create a Symmetric CMK via Console

1. Go to **AWS Console > KMS > Customer managed keys**
    
2. Click **Create key**
    
3. Select **Symmetric**
    
4. Enter an alias (e.g., `alias/my-app-key`)
    
5. Assign IAM users/roles
    
6. Complete creation
    

### Practical: Create a Key Using AWS CLI

```bash
aws kms create-key --description "My Application Key" \
  --tags TagKey=Environment,TagValue=Dev
```

Get the Key ID:

```bash
aws kms list-keys
```

Create alias:

```bash
aws kms create-alias \
  --alias-name alias/my-app-key \
  --target-key-id <your-key-id>
```

---

## 5. 🔐 KMS Permissions and IAM Policies

### IAM Policy Example

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ],
    "Resource": "arn:aws:kms:region:account-id:key/key-id"
  }]
}
```

### Key Policy Example

```json
{
  "Sid": "Enable IAM User Permissions",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::account-id:role/DevOpsRole"
  },
  "Action": "kms:*",
  "Resource": "*"
}
```

---

## 6. 🧪 Use Cases with Practicals

### Encrypt and Decrypt Data

```bash
# Encrypt
aws kms encrypt \
  --key-id alias/my-app-key \
  --plaintext "MySecretData" \
  --output text \
  --query CiphertextBlob

# Decrypt
aws kms decrypt \
  --ciphertext-blob fileb://<(echo "Base64Data" | base64 --decode) \
  --output text \
  --query Plaintext | base64 --decode
```

### Encrypting S3 Buckets

```bash
aws s3api put-bucket-encryption --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "alias/my-app-key"
      }
    }]}'
```

### Encrypting EBS Volumes

Use the key under "Encryption" when creating a volume or EC2 instance.

### Secrets Manager with KMS

```bash
aws secretsmanager create-secret \
  --name MySecret \
  --secret-string '{"username":"admin","password":"pass123"}' \
  --kms-key-id alias/my-app-key
```

### Using KMS in Lambda (Python)

```python
import boto3
kms = boto3.client('kms')

# Encrypt
resp = kms.encrypt(KeyId='alias/my-app-key', Plaintext=b"MySecret")
cipher = resp['CiphertextBlob']

# Decrypt
kms.decrypt(CiphertextBlob=cipher)['Plaintext']
```

### Envelope Encryption

```bash
aws kms generate-data-key \
  --key-id alias/my-app-key \
  --key-spec AES_256
```

---

## 7. 🔀 Key Rotation and Deletion

### Enable Automatic Rotation

```bash
aws kms enable-key-rotation --key-id alias/my-app-key
```

> Only for customer-managed symmetric CMKs. Rotates yearly.

### Schedule Key Deletion (7-Day Retention)

```bash
aws kms schedule-key-deletion \
  --key-id <key-id> \
  --pending-window-in-days 7
```

- Retention must be **between 7 and 30 days**.
    
- The key enters `PendingDeletion` state.
    
- Can be **cancelled**:
    

```bash
aws kms cancel-key-deletion --key-id <key-id>
```

> ⚠ Warning: After 7 days, the key is permanently deleted and **non-recoverable**. All encrypted data becomes inaccessible.

### View Key State

```bash
aws kms describe-key --key-id <key-id>
```

---

## 8. 📜 Audit and Logging (CloudTrail)

All KMS API calls are logged in **CloudTrail**.

Example:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=Encrypt
```

---

## 9. ✅ Best Practices

- Use **customer-managed CMKs** for control
    
- Enable **automatic key rotation**
    
- Apply **least privilege** in IAM and key policies
    
- Use **envelope encryption** for large files
    
- Monitor via **CloudTrail**
    
- Avoid logging plaintext or decrypted data
    

---

## 10. 🚨 Common Errors and Troubleshooting

|Error|Solution|
|---|---|
|`AccessDeniedException`|Check IAM and key policy permissions|
|`KMSInvalidKeyUsageException`|Use correct key type (e.g. symmetric vs asymmetric)|
|`ThrottlingException`|Exceeded KMS request limits, retry with backoff|
|`KeyUnavailableException`|Key is disabled or scheduled for deletion|

---

## 📂 Real-World Project Ideas

1. Encrypt S3 logs before upload
    
2. Lambda decrypts KMS-encrypted config
    
3. KMS encrypt API keys in DynamoDB
    
4. Secure file uploads with KMS + S3
    
5. Automate rotation with CloudWatch alerts
    

---

