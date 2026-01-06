
## 1. 🔍 What is AWS Inspector?

**Amazon Inspector** is an automated vulnerability management service that continuously scans Amazon EC2 instances and container images in Amazon ECR for:

- Software vulnerabilities (CVEs)
    
- Network exposure
    
- Misconfigurations (IAM, VPC, etc.)
    

---

## 2. 🧩 Key Concepts

|Term|Description|
|---|---|
|Inspector Agent|Installed on EC2 for deep OS scans|
|EC2 Scanning|Looks for known vulnerabilities (CVEs)|
|ECR Scanning|Scans container images automatically|
|Findings|List of identified vulnerabilities|
|Score|CVSS score (severity of vulnerability)|

---

## 3. ⚙️ How AWS Inspector Works

- AWS Inspector uses the **Systems Manager (SSM) agent** and **Inspector Agent** to collect data from EC2.
    
- For ECR, scans are triggered automatically on image push.
    
- Generates findings with metadata:
    
    - CVE ID
        
    - Severity
        
    - Description
        
    - Remediation steps
        

---

## 4. 🔄 Inspector vs Inspector Classic

|Feature|Inspector (v2)|Inspector Classic|
|---|---|---|
|EC2 Scanning|✅|✅|
|ECR Scanning|✅|❌|
|Continuous Scanning|✅|❌ (manual)|
|Managed Agent|✅ (via SSM)|❌|
|Recommendations|✅|✅|

---

## 5. 🚀 Enabling Inspector

### Console:

1. Go to **Amazon Inspector** in AWS Console.
    
2. Click **Enable Inspector**.
    
3. Select EC2 and ECR scanning.
    

### CLI:

```bash
aws inspector2 enable
```

---

## 6. ✍️ Practical Examples

### List Findings:

```bash
aws inspector2 list-findings
```

### Get Finding Details:

```bash
aws inspector2 get-findings --finding-arns <finding-arn>
```

### Get Scan Status:

```bash
aws inspector2 list-coverage
```

### List Covered Resources:

```bash
aws inspector2 list-coverage --filter resourceType=EC2
```

---

## 7. 🧪 Vulnerability Scanning

### EC2 Instances:

- Requires SSM Agent + Inspector Agent
    
- Detects OS-level CVEs, vulnerable packages
    

### ECR Images:

- Triggers scan on image push
    
- Finds vulnerable OS libraries and packages
    
- Supports Amazon Linux, Ubuntu, Alpine, etc.
    

---

## 8. 🔗 Integration with Other AWS Services

|Service|Integration Purpose|
|---|---|
|AWS Security Hub|Centralize findings|
|EventBridge|Automate responses|
|AWS Lambda|Remediate vulnerabilities|
|Amazon SNS|Notify admins|

### Example EventBridge Rule for Critical CVEs:

```json
{
  "source": ["aws.inspector2"],
  "detail-type": ["Inspector2 Finding"],
  "detail": {
    "severity": ["CRITICAL"]
  }
}
```

---

## 9. 💰 Pricing

- **EC2 scanning**: Per instance per month
    
- **ECR scanning**: Per image scan
    
- **Free 15-day trial** available
    

Refer to the official [AWS Inspector Pricing](https://aws.amazon.com/inspector/pricing/) page for up-to-date details.

---

## 10. ✅ Best Practices

- Ensure all EC2s are managed via SSM
    
- Enable Inspector in all regions
    
- Automate responses to critical CVEs using Lambda
    
- Regularly monitor coverage gaps
    
- Tag findings and resources for categorization
    

---

## 11. 📈 Use Cases

- Identify and patch critical CVEs in EC2
    
- Detect outdated and vulnerable libraries in Docker containers
    
- Meet compliance requirements (e.g., PCI DSS)
    
- Reduce attack surface of cloud workloads
    
- Enforce security best practices in CI/CD pipelines
    

---

## 12. ❓ FAQs

### Q: Does Inspector scan unmanaged instances?

> No. EC2 must be managed by SSM to be scanned.

### Q: How long are findings stored?

> Up to 90 days.

### Q: Can I export findings?

> Yes. Use CLI or EventBridge to forward them to SIEM/S3.

### Q: Does Inspector support Kubernetes/EKS?

> Not directly. Use ECR scans for container vulnerabilities.

---

