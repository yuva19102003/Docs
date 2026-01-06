
## 📊 What is VPC Flow Logs?

**VPC Flow Logs** capture **IP traffic** going to and from network interfaces in your **VPC**, allowing you to monitor, troubleshoot, and secure your AWS infrastructure.

> ✅ Think of it as a **network traffic log** for EC2, ENI, subnets, or the entire VPC.

---

## 🎯 Why Use VPC Flow Logs?

|Use Case|Benefit|
|---|---|
|Troubleshoot blocked connections|See if traffic is reaching your EC2|
|Analyze security group/NACL behavior|Understand why traffic is denied|
|Monitor cross-AZ / VPC peering traffic|Ensure proper routing|
|Audit network behavior|Detect anomalies or potential threats|
|Compliance|Proof of network activity|

---

## 🧱 Flow Logs Scope (Attach Level)

You can create a flow log for:

- ✅ **VPC**
    
- ✅ **Subnet**
    
- ✅ **Elastic Network Interface (ENI)**
    

> 📌 More specific levels override broader scopes. ENI > Subnet > VPC

---

## 📄 Flow Log Record Format

A single flow log record includes **metadata about a network connection**.

### 🔹 Default Format (version 2)

```text
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status
```

### 🔹 Example:

```text
2 123456789012 eni-abc123 10.0.1.100 10.0.2.45 443 54823 6 10 1100 1655274920 1655274980 ACCEPT OK
```

|Field|Meaning|
|---|---|
|`eni-abc123`|ENI ID|
|`10.0.1.100`|Source IP|
|`10.0.2.45`|Destination IP|
|`443`|Destination port (HTTPS)|
|`6`|Protocol (6 = TCP, 17 = UDP)|
|`ACCEPT`|Action allowed by SG/NACL|
|`REJECT`|Denied by SG/NACL|

> ✅ You can also enable **custom fields** like `tcp-flags`, `pkt-src-aws-service`, etc.

---

## 📦 Where Are Flow Logs Sent?

You can send flow logs to:

- 🔸 **Amazon CloudWatch Logs**
    
- 🔸 **Amazon S3**
    
- 🔸 **Kinesis Data Firehose** (for near real-time streaming/analytics)
    

---

## 🛠️ How to Create VPC Flow Logs (Console)

1. Go to **VPC > Your VPC > Flow Logs tab**
    
2. Click **Create flow log**
    
3. Choose:
    
    - Filter (All, Accept, or Reject)
        
    - Destination (CloudWatch Logs or S3)
        
    - IAM Role (required for delivery)
        
4. (Optional) Choose custom log format
    
5. Create
    

---

## 🧪 CLI Example

```bash
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-0123456789abcdef0 \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name vpc-flow-logs-group \
  --deliver-logs-permission-arn arn:aws:iam::123456789012:role/vpc-flow-log-role
```

---

## 🔐 IAM Role Required

If logging to **CloudWatch Logs**, you need a role with this permission:

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "*"
}
```

---

## 🧠 Filters

|Filter|Description|
|---|---|
|`ALL`|Log both accepted and rejected traffic|
|`ACCEPT`|Only log allowed traffic|
|`REJECT`|Only log denied traffic|

---

## 🔍 How to Use VPC Flow Logs

|Scenario|What to Check|
|---|---|
|Instance unreachable|See if REJECT on destination port|
|Connection timeout|Verify packets reach instance|
|Unexpected inbound connections|Identify source IPs in flow logs|
|Costly NAT usage|Analyze egress traffic from private subnet|
|Security audit|Review rejected flows|

---

## 💡 Tips & Best Practices

|Tip|Why It’s Important|
|---|---|
|Use filters (ACCEPT/REJECT)|Reduce noise, focus on security or traffic|
|Send to S3 with lifecycle policy|Cheap long-term storage|
|Monitor with Athena or CloudWatch Insights|Enables SQL-style queries or dashboards|
|Use with VPC Traffic Mirroring|For deep packet inspection (DPI)|
|Limit to specific ENIs for fine-grained logs|Cost-effective and focused|
|Enable log rotation and retention|Manage CloudWatch costs|

---

## ⚖️ Cost Consideration

|Cost Component|Detail|
|---|---|
|CloudWatch Logs|Charged per GB ingested|
|S3 Logs|Cheaper, but slower access|
|High-volume traffic|Can generate huge log data quickly|

---

## 🔚 TL;DR Summary

|Feature|Value|
|---|---|
|Purpose|Capture VPC-level network traffic|
|Scope|VPC, Subnet, or ENI|
|Destination|CloudWatch Logs, S3, or Firehose|
|Formats|Default or custom|
|Uses|Troubleshooting, security, audit|
|Cost|Charged based on destination (CloudWatch/S3)|

---
