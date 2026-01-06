## 1. What is AWS Config?

**AWS Config** is a fully managed service that provides you with:

- An **inventory of your AWS resources**, including how they are configured.
    
- A **history of configuration changes**.
    
- The ability to **audit and evaluate resource configurations** for compliance against desired settings or regulatory requirements.
    

It helps in **governance, compliance auditing, and security analysis**.

---

## 2. Key Concepts

|Term|Description|
|---|---|
|**Configuration Item**|A snapshot of resource configuration at a point in time|
|**Configuration Recorder**|Records configuration changes for supported AWS resources|
|**Delivery Channel**|Defines where configuration snapshots and notifications are delivered|
|**Rules**|Set of compliance checks, can be managed or custom|
|**Compliance**|Status of a resource against the rule (Compliant / Non-Compliant)|
|**Conformance Pack**|Collection of Config rules and remediation actions|

---

## 3. How AWS Config Works

- **Configuration Recorder** tracks changes to your AWS resources (e.g., EC2, S3, RDS, Lambda).
    
- Changes and snapshots are stored in an **S3 bucket**.
    
- When changes happen, **AWS Config evaluates** your resource against rules to determine compliance.
    
- It **alerts** or triggers automated workflows based on rule evaluation.
    

---

## 4. AWS Managed Rules

AWS provides **predefined rules** for common compliance checks, for example:

|Rule Name|Description|
|---|---|
|`s3-bucket-public-read-prohibited`|Ensure S3 buckets are not publicly readable|
|`ec2-instance-no-public-ip`|EC2 instances must not have public IPs|
|`rds-instance-engine-version-check`|Check if RDS instances run a specified engine version|
|`iam-password-policy`|Check if IAM password policy meets complexity|

Managed rules save you the effort of writing your own compliance logic.

---

## 5. Custom Rules & Lambda Integration

- For specific compliance checks not covered by managed rules, you can **create custom rules**.
    
- Custom rules use **AWS Lambda functions** triggered by AWS Config.
    
- Your Lambda function evaluates a resource’s configuration item and returns compliance status.
    

**Steps to create a custom rule:**

1. Write a Lambda function that evaluates compliance.
    
2. Create the custom rule in AWS Config, associating the Lambda function.
    
3. AWS Config invokes the Lambda function on configuration changes.
    

---

## 6. Practical Examples

### Example: Enabling AWS Config

```bash
aws configservice put-configuration-recorder \
  --configuration-recorder name=default,roleARN=arn:aws:iam::123456789012:role/AWSConfigRole
```

```bash
aws configservice put-delivery-channel \
  --delivery-channel name=default,s3BucketName=my-config-bucket
```

```bash
aws configservice start-configuration-recorder --configuration-recorder-name default
```

---

### Example: Using Managed Rule for RDS Version

Create a rule to enforce MySQL 8.0.35 version:

```bash
aws configservice put-config-rule --config-rule file://rds-engine-version-rule.json
```

Where `rds-engine-version-rule.json`:

```json
{
  "ConfigRuleName": "rds-instance-engine-version-check",
  "Description": "Checks that RDS instances are running MySQL 8.0.35",
  "Scope": {
    "ComplianceResourceTypes": ["AWS::RDS::DBInstance"]
  },
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "RDS_ENGINE_VERSION_CHECK"
  },
  "InputParameters": "{\"engine\":\"mysql\",\"engineVersion\":\"8.0.35\"}",
  "ConfigRuleState": "ACTIVE"
}
```

---

## 7. Checking Elastic Beanstalk & RDS Versions

### Elastic Beanstalk Version Checking

- AWS Config **does not provide a managed rule** for checking Elastic Beanstalk platform versions.
    
- You must **create a custom AWS Config rule backed by Lambda** to:
    
    - Call Elastic Beanstalk’s `describe-environments`.
        
    - Fetch platform versions (`PlatformArn` or `SolutionStackName`).
        
    - Compare against a list of approved platform versions.
        
    - Return compliance status accordingly.
        

**Pseudo-code Lambda example:**

```python
import boto3

def evaluate_compliance(event, context):
    beanstalk_client = boto3.client('elasticbeanstalk')
    approved_versions = [
        "arn:aws:elasticbeanstalk:us-west-2::platform/Python 3.7 running on 64bit Amazon Linux 2/3.3.7",
        "arn:aws:elasticbeanstalk:us-west-2::platform/Node.js 14 running on 64bit Amazon Linux 2/3.3.7"
    ]

    environment_name = event['configurationItem']['resourceId']
    response = beanstalk_client.describe_environments(EnvironmentNames=[environment_name])
    platform_arn = response['Environments'][0]['PlatformArn']

    if platform_arn in approved_versions:
        return 'COMPLIANT'
    else:
        return 'NON_COMPLIANT'
```

---

### RDS Version Checking

- AWS Config provides a **managed rule** named `rds-instance-engine-version-check`.
    
- This rule ensures your RDS instances run a specified engine and version.
    
- You specify the database engine and version in the rule parameters.
    

**Rule configuration example:**

```json
{
  "ConfigRuleName": "rds-instance-engine-version-check",
  "Description": "Ensure RDS instances run approved MySQL version",
  "Scope": {
    "ComplianceResourceTypes": ["AWS::RDS::DBInstance"]
  },
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "RDS_ENGINE_VERSION_CHECK"
  },
  "InputParameters": "{\"engine\":\"mysql\",\"engineVersion\":\"8.0.35\"}",
  "ConfigRuleState": "ACTIVE"
}
```

---

### Summary Table

|AWS Service|Version Checking Available?|Managed or Custom Rule?|
|---|---|---|
|Elastic Beanstalk|No (must create custom rule)|Custom AWS Lambda rule|
|RDS|Yes (with managed rule)|Managed rule|

---

### Automating Alerts and Remediation

- Combine AWS Config with **Amazon SNS**, **EventBridge**, and **AWS Lambda** to automate alerts or remediation:
    
    - Trigger Lambda functions for upgrades or patches.
        
    - Notify teams on Slack, email, or ticketing systems.
        
    - Integrate into CI/CD pipelines for continuous compliance.
        

---

## 8. Integration with Other AWS Services

|Service|Use Case|
|---|---|
|AWS CloudTrail|Correlate config changes with API calls|
|AWS Lambda|Custom rule evaluation & automated remediation|
|Amazon SNS|Send notifications on compliance changes|
|AWS Security Hub|Centralize security and compliance findings|
|Amazon EventBridge|Automate workflows based on config events|

---

## 9. Pricing

- AWS Config charges based on:
    
    - Number of recorded configuration items.
        
    - Number of active rules evaluated per resource.
        
- Pricing varies by region and usage.
    
- Refer to [AWS Config Pricing](https://aws.amazon.com/config/pricing/) for detailed, up-to-date info.
    

---

## 10. Best Practices

- Enable AWS Config in **all regions** where resources exist.
    
- Use **tags** to scope rules for relevant resources.
    
- Automate remediation where possible.
    
- Regularly review **conformance packs** for compliance frameworks.
    
- Monitor **compliance dashboards** and set alerts.
    

---

## 11. Use Cases

- Continuous compliance monitoring (PCI-DSS, HIPAA, GDPR).
    
- Ensuring infrastructure configuration standards.
    
- Auditing resource configuration changes.
    
- Automating remediation of drifted resources.
    
- Monitoring versions of critical services like RDS and Elastic Beanstalk.
    

---

## 12. FAQs

**Q1: Can AWS Config check if all Elastic Beanstalk environments run the latest platform version?**

> Not directly. You must create a custom Lambda-backed Config rule that queries the platform version and compares it with an approved list.

**Q2: How do I check if RDS instances are running a particular engine version?**

> Use the managed AWS Config rule `rds-instance-engine-version-check` and specify the required version.

**Q3: How long does AWS Config keep configuration history?**

> Config keeps historical configuration data for **7 years** by default.

**Q4: Can I export AWS Config compliance reports?**

> Yes, compliance data is stored in S3 and can be queried or exported for external reporting.

---
