
## 1. What is AWS WAF?

**AWS WAF (Web Application Firewall)** is a cloud-based firewall service that helps protect your web applications from common web exploits and attacks such as:

- SQL injection
    
- Cross-site scripting (XSS)
    
- HTTP floods (DDoS)
    
- Bad bots and scrapers
    
- Other OWASP Top 10 threats
    

AWS WAF lets you create customizable rules to allow, block, or monitor (count) web requests based on conditions such as IP addresses, HTTP headers, URI strings, query string parameters, body content, or geographic location.

---

## 2. Key Features

|Feature|Description|
|---|---|
|Custom Rule Creation|Write rules based on IP addresses, strings, headers, etc.|
|Managed Rule Groups|Use pre-built managed rules by AWS and partners|
|Real-time Visibility|Monitor requests with detailed metrics and logs|
|Rate-based Rules|Limit requests from an IP to prevent DDoS or brute force|
|Integration with AWS Shield|Automatic protection against large scale DDoS attacks|
|Bot Control|Block or allow automated traffic from bots|
|CAPTCHA and Challenge Support|Add CAPTCHA to suspicious traffic for better validation|

---

## 3. How AWS WAF Works

AWS WAF operates at the edge (CloudFront) or on regional Application Load Balancers (ALB), API Gateway, and AppSync. It inspects incoming HTTP/HTTPS requests against your configured rules and takes action (allow, block, count).

---

## 4. Components of AWS WAF

- **Web ACL (Access Control List):** Container for your rules; attached to a resource.
    
- **Rules:** Define what traffic to block, allow, or count.
    
- **Rule Groups:** Collections of rules (can be managed or custom).
    
- **Conditions:** Match criteria inside rules (IP sets, regex, geographic location, etc.).
    
- **IP Sets:** Lists of IP addresses/ranges for allow/block.
    
- **Logging and Metrics:** Monitor requests and actions taken.
    

---

## 5. Use Cases

- Block SQL injection and XSS attacks
    
- Limit traffic from suspicious IPs or countries
    
- Prevent brute force login attempts via rate limiting
    
- Block known malicious bots and scrapers
    
- Add CAPTCHA challenges to suspicious users
    
- Protect APIs on API Gateway or AppSync
    

---

## 6. Pricing

- Charged per Web ACL ($5 per month)
    
- Charged per rule ($1 per rule per month)
    
- Charged per million web requests inspected ($0.60 per million requests)
    
- Managed rule groups may have additional fees
    

Refer to the [AWS WAF Pricing page](https://aws.amazon.com/waf/pricing/) for detailed pricing.

---

## 7. How to Set Up AWS WAF — Step-by-Step

### Step 1: Create Web ACL

- Go to AWS WAF Console → Web ACLs → Create Web ACL
    
- Choose resource type (CloudFront, ALB, API Gateway)
    
- Provide a name and set default action (Allow or Block)
    

### Step 2: Add Rules

- Add Managed Rule Groups (e.g., AWS Managed Rules for common threats)
    
- Or create custom rules with your own conditions
    

### Step 3: Define Conditions

- IP Set: Block or allow specific IPs or CIDR ranges
    
- String Match: Block if URI or header contains certain patterns
    
- Regex Pattern: Advanced matching for complex patterns
    
- Geo Match: Block or allow traffic from specific countries
    
- Rate-based Rule: Limit requests per IP to mitigate DDoS
    

### Step 4: Attach Web ACL

- Attach to CloudFront distribution, ALB, API Gateway, or AppSync
    

### Step 5: Enable Logging (Optional)

- Enable logging to an S3 bucket or CloudWatch Logs for detailed request info
    

---

## 8. Practical Examples

### Example 1: Block IP Addresses

```bash
aws wafv2 create-ip-set \
  --name "BlockedIPs" \
  --scope REGIONAL \
  --region us-east-1 \
  --ip-address-version IPV4 \
  --addresses "203.0.113.0/24" "198.51.100.1/32"
```

Add this IP set to a rule blocking those IPs.

### Example 2: Create a Rate-Based Rule to Block IPs Sending > 1000 Requests in 5 Minutes

In Web ACL, add:

- Rule Type: Rate-based
    
- Rate limit: 1000 requests per 5 minutes
    
- Action: Block
    

### Example 3: Use Managed Rule Group (AWS Managed Rules for Common Vulnerabilities)

- Add the **AWSManagedRulesCommonRuleSet** managed rule group in your Web ACL.
    

---

## 9. Integration with Other AWS Services

|Service|Integration Purpose|
|---|---|
|AWS CloudFront|Protect web apps at edge|
|Application Load Balancer|Protect regional web apps|
|API Gateway|Secure APIs|
|AWS Shield|Advanced DDoS protection combined with WAF|
|AWS Firewall Manager|Centralized management of WAF policies across accounts|
|Amazon CloudWatch|Monitoring and alerting on WAF metrics and logs|
|AWS Lambda|Automate responses or update WAF rules dynamically|

---

## 10. Best Practices

- Always start with **Allow** as the default action and add blocking rules gradually.
    
- Use **Managed Rule Groups** to cover common vulnerabilities.
    
- Regularly review and tune your rules based on traffic and alerts.
    
- Enable logging and monitor via CloudWatch or Security Hub.
    
- Use **rate-based rules** to mitigate brute force and DDoS.
    
- Combine with AWS Shield Advanced for critical applications.
    
- Use IP Sets to block known bad IPs or allow trusted IPs.
    

---

## 11. FAQs

**Q:** Can AWS WAF protect against all types of attacks?  
**A:** AWS WAF protects against many common web exploits but should be part of a layered security approach.

**Q:** Does AWS WAF work with non-AWS hosted applications?  
**A:** No, AWS WAF integrates only with AWS resources like CloudFront, ALB, API Gateway, and AppSync.

**Q:** How is AWS WAF different from AWS Shield?  
**A:** AWS Shield protects against large scale DDoS attacks; WAF focuses on application-layer filtering and blocking.

**Q:** Can I write my own rules?  
**A:** Yes, AWS WAF supports custom rules with flexible conditions.

**Q:** Does AWS WAF support IPv6?  
**A:** Yes, AWS WAF supports both IPv4 and IPv6.

---
