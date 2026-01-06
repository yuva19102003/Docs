
## 🔍 What is Amazon Kendra?

**Amazon Kendra** is a **highly accurate, intelligent search service** powered by machine learning. It enables organizations to search unstructured and structured data across **documents, websites, knowledge bases**, and more.

> ✅ Kendra understands **natural language questions** like “How do I reset my password?” and returns the most relevant documents and direct answers.

---

## 📚 Use Cases

|Industry|Use Case Example|
|---|---|
|IT Support|Internal documentation search, FAQs|
|Healthcare|Search medical manuals, policies, compliance|
|Legal|Discover case laws, compliance docs|
|Education|Course materials, knowledge base search|
|Enterprise|Unified search across SharePoint, Confluence, etc|

---

## 🧠 Key Features

|Feature|Description|
|---|---|
|**Natural language queries**|Understands context and intent|
|**Direct answers**|Extracts specific snippets from documents|
|**FAQs support**|You can upload CSV/JSON question-answer pairs|
|**Document ranking**|Uses ML to rank and score documents by relevance|
|**Synonyms**|You can define synonyms (e.g., "laptop" = "notebook")|
|**Access control**|Secure document-level filtering with ACLs|
|**Multi-language support**|English, French, Spanish, German, Japanese, etc.|
|**Real-time & batch indexing**|Automatically sync documents from data sources|
|**Prebuilt connectors**|S3, SharePoint, Salesforce, ServiceNow, RDS, Box, etc.|

---

## 🗂️ Supported Data Sources

|Source|Notes|
|---|---|
|Amazon S3|PDFs, DOCX, HTML, TXT, CSV|
|SharePoint|Online and on-prem|
|Salesforce|Knowledge base, CRM|
|ServiceNow|Incident, change, problem KBs|
|Confluence, Box|Enterprise documentation|
|RDS / Databases|SQL-based connectors|

✅ You can also create **custom connectors** using Lambda.

---

## 🧪 Example: Kendra Query API with Python

```python
import boto3

kendra = boto3.client('kendra')

response = kendra.query(
    IndexId='your-index-id',
    QueryText="How do I reset my password?"
)

for result in response['ResultItems']:
    print(result['Type'], "→", result['DocumentTitle']['Text'])
    print("Answer:", result['DocumentExcerpt']['Text'])
```

---

## ⚙️ Kendra Architecture Overview

```text
User Query → Kendra API
         ↓
Index (ML-powered search)
         ↓
Connected data sources (S3, SharePoint, Salesforce, etc.)
```

✅ **Kendra supports ACLs**, so you can restrict results based on user identity.

---

## 💰 Pricing Overview (2024)

|Kendra Edition|Developer Edition|Enterprise Edition|
|---|---|---|
|Ideal for|Testing, small workloads|Production, large-scale|
|Documents/month|~100K|Up to millions|
|Queries/month|750/month included|Pay-per-query|
|Cost|~$810/month|Starts at ~$1,620/month|

🧠 Pricing also includes:

- Connector fees (per source)
    
- API queries beyond free tier
    

---

## 🔐 Security & Access

|Feature|Support|
|---|---|
|IAM Policies|✅ Yes|
|KMS Encryption|✅ For data at rest|
|Access Control List (ACL)|✅ For user-specific results|
|VPC Endpoints|✅ Yes (via PrivateLink)|

---

## 🧱 Terraform Support

Terraform support for Amazon Kendra is **partial** via the `aws_kendra_index` and `aws_kendra_data_source` resources.

### Create a Kendra Index

```hcl
resource "aws_kendra_index" "example" {
  name                   = "example-kendra-index"
  role_arn               = aws_iam_role.kendra_role.arn
  edition                = "DEVELOPER_EDITION"

  server_side_encryption_configuration {
    kms_key_id = aws_kms_key.example.arn
  }
}
```

---

### Add a Data Source (e.g., S3)

```hcl
resource "aws_kendra_data_source" "s3_source" {
  name        = "my-s3-source"
  index_id    = aws_kendra_index.example.id
  type        = "S3"
  role_arn    = aws_iam_role.kendra_role.arn

  configuration {
    s3_configuration {
      bucket_name = "my-kendra-documents"
    }
  }
}
```

---

## ✅ TL;DR Summary

|Feature|Amazon Kendra|
|---|---|
|Purpose|Enterprise search across unstructured data|
|NLP-powered search|✅ Yes|
|Prebuilt connectors|✅ 10+ supported|
|Fine-grained access control|✅ Document-level filtering|
|Supports FAQ|✅ Yes|
|Pricing|Developer & Enterprise Edition|
|Languages supported|10+ (incl. EN, FR, DE, ES, JP)|
|Terraform support|✅ Partial (index, data source)|
|Free trial|❌ No Free Tier|

---
