## 1. 🔍 What is AWS GuardDuty?

**Amazon GuardDuty** is a continuous threat detection service that monitors for malicious activity and unauthorized behavior using:

- VPC Flow Logs
    
- AWS CloudTrail Logs (including DNS logs)
    
- EKS Audit Logs
    

It uses machine learning, anomaly detection, and threat intelligence feeds (e.g. AWS Threat Intel, CrowdStrike).

---

## 2. 🔮 GuardDuty Concepts

|Concept|Description|
|---|---|
|Detector|Core component that analyzes events|
|Findings|GuardDuty's analysis results|
|Threat Intel Sets|Known bad IPs or domains used for detection|
|Trusted IP List|Safe-listed IP addresses|
|Member Accounts|Monitored by a master account|

---

## 3. ⚖️ How GuardDuty Works

- Collects logs from VPC Flow Logs, CloudTrail, DNS logs, and EKS audit logs
    
- Analyzes data for threats
    
- Generates security findings with severity and metadata
    

---

## 4. 🚀 Enabling GuardDuty

### Console:

1. Go to **Amazon GuardDuty** in the AWS Console
    
2. Click **Enable GuardDuty**
    
3. Done! It starts analyzing your data immediately
    

### CLI:

```bash
aws guardduty create-detector --enable
```

Get Detector ID:

```bash
aws guardduty list-detectors
```

---

## 5. ✍️ Practical Examples

### List Findings:

```bash
aws guardduty list-findings --detector-id <detector-id>
```

### Get Finding Details:

```bash
aws guardduty get-findings \
  --detector-id <detector-id> \
  --finding-ids <finding-id>
```

### Create Trusted IP List:

```bash
aws guardduty create-ip-set \
  --detector-id <detector-id> \
  --name trusted-ips \
  --format TXT \
  --location https://example.com/trusted_ips.txt \
  --activate
```

### Create Threat Intel Set:

```bash
aws guardduty create-threat-intel-set \
  --detector-id <detector-id> \
  --name threat-list \
  --format TXT \
  --location https://example.com/bad_ips.txt \
  --activate
```

---

## 6. 🚨 Findings and Severity Levels

|Severity|Description|
|---|---|
|Low|Suspicious activity with low impact|
|Medium|Activity indicating possible compromise|
|High|Confirmed malicious activity|

Each finding includes:

- AccountId
    
- Resource type (e.g., EC2)
    
- Type (e.g., Backdoor:EC2/DenialOfService)
    
- Severity (0–8.9)
    
- Description
    

---

## 7. 📊 Integrations with Other Services

|Service|Usage|
|---|---|
|Amazon EventBridge|Create rules to respond to findings|
|AWS Security Hub|Aggregate findings for compliance|
|AWS Lambda|Automated remediation (e.g., isolate instance)|
|SNS|Notification for alerts|

### Example: Send Finding to Lambda

```json
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
```

---

## 8. 💸 GuardDuty Pricing

- Based on volume of:
    
    - VPC Flow logs
        
    - DNS logs
        
    - CloudTrail events
        

No charges for enabling or running in free trial (30 days).

---

## 9. ✅ Best Practices

- Enable GuardDuty in all regions
    
- Use delegated admin for multi-account setup
    
- Integrate with EventBridge or Lambda for automated response
    
- Regularly review and archive old findings
    
- Suppress benign findings using trusted IP lists
    

---

## 10. 🚔 GuardDuty vs Other Services

|Service|Use Case|
|---|---|
|GuardDuty|Threat detection (intelligence + ML)|
|AWS Inspector|Vulnerability scanning|
|Security Hub|Centralized security findings|
|Macie|Sensitive data discovery|

---

## 11. 📊 Use Cases

- Detect brute-force or port scanning attacks
    
- Alert on exfiltration of data from EC2
    
- Monitor suspicious login locations
    
- Integrate with Lambda to isolate infected EC2
    
- Export findings to SIEM
    

---

## 12. ❓ Troubleshooting and FAQs

### Q: Can GuardDuty be enabled per region?

> Yes. Must be enabled separately in each region.

### Q: How long are findings retained?

> Findings are stored for **90 days**.

### Q: Can I customize detection rules?

> Only by supplying custom threat lists and trusted IP sets.

### Q: Does it support multi-account?

> Yes. Use Organizations to configure delegated admin.

---
