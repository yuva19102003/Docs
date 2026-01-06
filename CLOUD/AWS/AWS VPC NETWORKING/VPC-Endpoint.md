
## 🌐 What is a VPC Endpoint?

A **VPC Endpoint** allows you to **privately connect your VPC to AWS services** and **other AWS VPCs** without traversing the public internet, VPN, or NAT Gateway.

> ✅ It keeps traffic **inside the AWS network** and is more secure and cost-efficient.

---

## 🧱 Types of VPC Endpoints

|Type|Full Name|Connects To|Underlying Technology|
|---|---|---|---|
|**Interface Endpoint**|Elastic Network Interface (ENI)|Most AWS services (e.g., S3, SSM, DynamoDB, Secrets Manager)|PrivateLink|
|**Gateway Endpoint**|Gateway-based|Only **S3** and **DynamoDB**|Route table entry|
|**Gateway Load Balancer Endpoint**|GWLB Endpoint|Load-balanced appliances like firewalls|Gateway Load Balancer|

---

## ✅ 1. **Gateway VPC Endpoint**

- **Free**
    
- Only for **S3** and **DynamoDB**
    
- Adds a route in the **route table** for private communication
    

### 🛠️ Example:

|Route Table Rule|
|---|
|`S3 (pl-123abc)` → Target: `vpce-abc123`|

---

## ✅ 2. **Interface VPC Endpoint**

- Powered by **AWS PrivateLink**
    
- Uses a **private IP address in your subnet**
    
- Adds **ENI** to your VPC
    
- Works for services like:
    
    - SSM
        
    - Secrets Manager
        
    - SNS, SQS, STS
        
    - API Gateway (private APIs)
        
    - Third-party SaaS products
        

> 💰 **Charged per hour + data transferred**

---

## 🎯 Use Cases

|Use Case|Recommended Endpoint Type|
|---|---|
|Access S3 privately from private subnet|Gateway|
|Connect to SSM without NAT Gateway|Interface (SSM)|
|Lambda accessing Secrets Manager securely|Interface|
|Private subnet downloading from DynamoDB|Gateway|
|SaaS or partner service integration|Interface (via PrivateLink)|

---

## 🛠️ How to Create a VPC Endpoint

### ✅ Console Steps:

1. Go to **VPC > Endpoints**
    
2. Click **Create Endpoint**
    
3. Choose:
    
    - Service name (e.g., `com.amazonaws.region.s3`)
        
    - VPC
        
    - Subnets (for Interface endpoints)
        
    - Security groups (Interface only)
        
4. Add policy (optional IAM restrictions)
    
5. Create
    

---

### ✅ AWS CLI Example (S3 Gateway Endpoint):

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-abc123 \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids rtb-xyz456 \
  --vpc-endpoint-type Gateway
```

---

### ✅ AWS CLI Example (SSM Interface Endpoint):

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-abc123 \
  --service-name com.amazonaws.us-east-1.ssm \
  --vpc-endpoint-type Interface \
  --subnet-ids subnet-aaa111 subnet-bbb222 \
  --security-group-ids sg-0123456789abcdef0
```

---

## 🔐 Security Considerations

|Feature|Gateway Endpoint|Interface Endpoint|
|---|---|---|
|Security Groups|❌ Not used|✅ Required|
|IAM Policies|✅ Can restrict access|✅ Can restrict access|
|VPC Flow Logs|✅ Supported|✅ Supported|
|Data encrypted|✅ Yes (TLS for Interface)|✅ Yes (TLS + KMS for services)|

---

## 💵 Pricing

|Type|Cost|
|---|---|
|Gateway|✅ Free (only standard data transfer fees)|
|Interface|💰 Charged per hour + per GB|

Example:

- Interface Endpoint: ~$0.01/hour + $0.01/GB in us-east-1
    

---

## 🧠 VPC Endpoint vs NAT Gateway

|Feature|VPC Endpoint|NAT Gateway|
|---|---|---|
|Internet required?|❌ No|✅ Yes|
|Secure traffic inside AWS?|✅ Yes|❌ No (uses internet path)|
|Cost|Gateway: free, Interface: cheap|💰 Costly (~$0.045/hour + data)|
|Can access all services?|❌ No (only supported ones)|✅ Yes|
|Use in private subnet?|✅ Yes|✅ Yes|
|Common use case|Secure AWS service access|General outbound internet|

---

## 🎨 Diagram: Interface VPC Endpoint

```text
     +-------------------+             +------------------+
     |     EC2 (private) |──(HTTPS)──▶ | Interface ENI     |
     +-------------------+             | (com.amazonaws.ssm)|
                                       +------------------+
                                              │
                                     Internal AWS Service
```

---

## ✅ Best Practices

|Best Practice|Why|
|---|---|
|Use Gateway Endpoints for S3/DynamoDB|Free, fast, simple|
|Use Interface Endpoints for other services|Private, secure|
|Use endpoints in each AZ|For high availability|
|Restrict access via endpoint policies|Enforce least privilege|
|Combine with security groups + NACLs|Full control of traffic|
|Tag endpoints clearly|Cost and usage tracking|

---

## 🔚 Summary Table

|Feature|Gateway Endpoint|Interface Endpoint|
|---|---|---|
|Services Supported|S3, DynamoDB|Most other AWS services|
|Route Table|✅ Required|❌ Not used|
|Security Groups|❌ Not supported|✅ Used|
|IP Assigned|❌ No|✅ Private ENI|
|Cost|✅ Free|💰 Charged|
|AZ-specific|❌ No|✅ Yes|

---
