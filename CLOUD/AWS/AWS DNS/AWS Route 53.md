
## ✅ What is AWS Route 53?

**AWS Route 53** is a **scalable and highly available Domain Name System (DNS)** web service that:

- Translates domain names (e.g., `example.com`) into IP addresses (e.g., `192.0.2.1`)
    
- Provides **domain registration**
    
- Enables **health checks and failover**
    
- Supports **traffic flow policies**
    

---

## 🚀 Core Features

|Feature|Description|
|---|---|
|**Domain Registration**|Buy and manage domain names directly from AWS.|
|**DNS Service**|Manage public or private DNS records.|
|**Health Checks**|Automatically monitor endpoints (like EC2, ELB, etc.).|
|**Traffic Flow**|Visual traffic routing across multiple AWS Regions.|
|**Routing Policies**|Use latency, geolocation, failover, and more.|
|**Private Hosted Zones**|Internal DNS management within a VPC.|

---

## 🧭 Routing Policies

|Policy Name|Purpose|
|---|---|
|**Simple**|Basic A/AAAA record routing.|
|**Weighted**|Split traffic based on weight percentages.|
|**Latency-based**|Route users to the lowest-latency region.|
|**Failover**|Route traffic to a backup resource if the primary fails.|
|**Geolocation**|Route based on user's geographical location.|
|**GeoProximity**|Route based on geographic region with bias adjustments (Traffic Flow).|
|**Multivalue Answer**|Return multiple healthy records (like round robin with health check).|

---

## 🛠️ Step-by-Step Tutorial

### 🟢 1. Register a Domain (Optional)

```bash
# Via AWS Console > Route 53 > Domain Registration
```

### 🟢 2. Create a Hosted Zone

1. Open **Route 53 > Hosted Zones**
    
2. Click **Create hosted zone**
    
3. Enter domain name (e.g., `myapp.example`)
    
4. Choose **Public** or **Private Hosted Zone**
    
5. Create zone → You’ll get **NS** and **SOA** records by default
    

### 🟢 3. Add Record Sets

|Record Type|Description|Example|
|---|---|---|
|A / AAAA|Maps domain to IP (IPv4/IPv6)|`A -> 54.123.45.67`|
|CNAME|Maps domain to another domain|`www.example.com -> example.com`|
|MX|Email routing|`10 mail.example.com`|
|TXT|For SPF, DKIM, verification|`"v=spf1 include:..."`|
|Alias|Points to AWS resources like ELB, S3|`Alias to s3-website URL`|

---

## 🧪 Use Cases & Practical Labs

### ✅ **Practical 1: Point a Domain to EC2 Instance**

1. Create EC2 and note its public IP.
    
2. Create an A record in your Hosted Zone.
    
    ```
    Name: myapp.example.com
    Type: A
    Value: <EC2 IP>
    TTL: 300
    ```
    
3. Test via `curl http://myapp.example.com`
    

---

### ✅ **Practical 2: Create Weighted Routing Between 2 EC2s**

1. Launch two EC2 instances in different AZs.
    
2. Create two A records:
    
    - `A -> EC2-1` (Weight: 80)
        
    - `A -> EC2-2` (Weight: 20)
        
3. Test using `dig` and refresh to observe weighted traffic.
    

---

### ✅ **Practical 3: Failover Routing with Health Checks**

1. Create two EC2s: Primary and Secondary.
    
2. Create Route 53 Health Check on Primary EC2.
    
3. Create two A records:
    
    - `Primary`: Failover = Primary
        
    - `Secondary`: Failover = Secondary
        
4. Simulate a failure by stopping the primary EC2.
    

---

### ✅ **Practical 4: Latency-Based Routing Between Regions**

1. Create EC2s in us-east-1 and ap-south-1.
    
2. Add A records with latency routing.
    
3. Test using VPN or simulate latency using curl + `--resolve`.

---

### ✅ **Practical 5: Internal DNS with Private Hosted Zones**

1. Create a Private Hosted Zone for your VPC (e.g., `internal.local`)
    
2. Create records like `api.internal.local → Private IP`
    
3. Test from EC2 inside the VPC using `dig api.internal.local`
    

---

## 🔗 Common Integrations

|Service|Integration Type|
|---|---|
|**ALB/NLB**|Alias records to load balancer DNS names|
|**S3**|Static website hosting with Alias to S3 bucket|
|**CloudFront**|CNAME + Alias to CloudFront distribution|
|**ECS/EKS**|Domain routing to Fargate or Kubernetes services|
|**ACM/SSL**|Use Route 53 for DNS validation for SSL certs|

---

## 📈 Monitoring and Logging

- **CloudWatch Metrics** from Route 53 Health Checks
    
- **Query Logging**: Enable for Hosted Zones (stored in CloudWatch Logs or S3)
    
- **Logging DNS requests** is helpful for security auditing and analytics
    

---

## 🔐 Security Best Practices

- Use **least privilege IAM** permissions for Route 53 access.
    
- Lock **Hosted Zone changes** via IAM policies or AWS Service Control Policies.
    
- Use **MFA** for domain transfers or deletions.
    
- For internal services, use **Private Hosted Zones**.
    
- Enable **Query Logging** for DNS monitoring.
    

---

## ❓ Interview Questions

### 🔹 Basic

1. What is AWS Route 53 used for?
    
2. What are the different record types in Route 53?
    
3. What is the difference between a public and private hosted zone?
    

### 🔹 Intermediate

4. Explain how health checks work in Route 53.
    
5. Describe the difference between Alias and CNAME.
    
6. What is a TTL and how does it impact DNS propagation?
    

### 🔹 Advanced

7. How does latency-based routing determine the best region?
    
8. Can you use Route 53 for internal DNS? How?
    
9. How do Route 53 health checks differ from ELB health checks?
    
10. Explain how Route 53 integrates with CloudFront and ACM for SSL validation.
    

---
