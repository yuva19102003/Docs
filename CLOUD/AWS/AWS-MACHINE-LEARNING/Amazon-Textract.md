
## 📄 What is Amazon Textract?

**Amazon Textract** is a **machine learning-based OCR service** that automatically extracts **printed and handwritten text**, **tables**, **forms**, and **key-value pairs** from scanned documents, PDFs, and images — without needing templates or custom code.

> ✅ It goes beyond basic OCR by understanding the **structure and relationships** in your documents.

---

## 🎯 Key Use Cases

|Industry|Use Case|
|---|---|
|Banking|Extract KYC data from ID documents|
|Healthcare|Digitize handwritten prescriptions or records|
|Insurance|Read claim forms and policy documents|
|HR|Process resumes, forms, or offer letters|
|Legal|Extract clauses from contracts|
|Logistics|Read invoices, receipts, and bills of lading|

---

## 📚 What Textract Can Extract

|Feature|Description|
|---|---|
|**Raw Text**|Plain text from PDFs, images, scans|
|**Forms**|Key-value pairs (e.g., “Name: John”)|
|**Tables**|Structured rows and columns|
|**Handwriting**|Supports both printed and cursive|
|**Checkboxes**|Detects selection states (ON/OFF)|
|**Identity Documents**|Structured fields from ID cards, licenses|
|**Expense Analysis**|Categorize receipts, totals, vendors, etc.|

---

## 🧠 Textract API Operations

|API Method|Purpose|
|---|---|
|`DetectDocumentText`|Extract raw lines and words|
|`AnalyzeDocument`|Extract forms, tables, checkboxes|
|`AnalyzeExpense`|Specialized for receipts, invoices|
|`AnalyzeID`|Specialized for identity documents|
|`StartDocumentAnalysis`|Async operation for large docs|
|`GetDocumentAnalysis`|Retrieve results from async jobs|

---

## 🧪 Sample Python Code (Boto3)

### Extract Form & Table Data (Sync)

```python
import boto3

textract = boto3.client('textract')

with open("form.png", "rb") as document:
    image_bytes = document.read()

response = textract.analyze_document(
    Document={'Bytes': image_bytes},
    FeatureTypes=["FORMS", "TABLES"]
)

for block in response['Blocks']:
    if block['BlockType'] == 'KEY_VALUE_SET':
        print(block.get('Text'))
```

---

### Extract from S3 (Async for Large Docs)

```python
response = textract.start_document_analysis(
    DocumentLocation={'S3Object': {'Bucket': 'my-bucket', 'Name': 'invoice.pdf'}},
    FeatureTypes=["TABLES", "FORMS"]
)

job_id = response['JobId']
```

---

## 🧾 Output Format Example

Textract returns nested blocks with relationships:

```json
{
  "Blocks": [
    {
      "BlockType": "KEY_VALUE_SET",
      "EntityTypes": ["KEY"],
      "Text": "Name"
    },
    {
      "BlockType": "KEY_VALUE_SET",
      "EntityTypes": ["VALUE"],
      "Text": "John Smith"
    }
  ]
}
```

---

## 🧮 Textract vs Other OCR

|Feature|Textract|Simple OCR (e.g., Tesseract)|
|---|---|---|
|Text|✅ Yes|✅ Yes|
|Tables|✅ Yes|❌ No|
|Forms/Key-Value|✅ Yes|❌ No|
|Handwriting|✅ Yes|Limited|
|Identity Docs|✅ Prebuilt parser|❌ Manual|
|Expense Docs|✅ Yes|❌ No|

---

## 🧾 Pricing (2024)

|API|Price per Page|
|---|---|
|`DetectDocumentText`|$0.0015/page|
|`AnalyzeDocument`|$0.015/page (tables/forms)|
|`AnalyzeExpense`|$0.05/page|
|`AnalyzeID`|$0.025/page|

🧠 **Free Tier**: 1,000 pages/month for first 3 months (analyze or detect text).

---

## 🔐 Security

|Feature|Support|
|---|---|
|IAM integration|✅ Yes|
|Encryption|✅ With KMS|
|S3 Integration|✅ Yes|
|VPC endpoint support|✅ Yes (via PrivateLink)|
|HIPAA eligible|✅ Yes|

---

## 🧱 Terraform Integration (Indirect)

No direct Terraform resource for Textract, but you can:

- Automate Textract through **Lambda functions**
    
- Trigger it via **S3 events** using:
    

```hcl
resource "aws_lambda_function" "textract_handler" {
  ...
}

resource "aws_s3_bucket_notification" "notify" {
  bucket = "my-textract-bucket"

  lambda_function {
    lambda_function_arn = aws_lambda_function.textract_handler.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".pdf"
  }
}
```

---

## ⚙️ Integration With Other Services

|Service|Purpose|
|---|---|
|**S3**|Store source and output files|
|**Lambda**|Trigger processing logic|
|**Comprehend**|NLP on extracted text|
|**Athena**|Query structured output|
|**Step Functions**|Orchestrate large pipelines|
|**OpenSearch**|Index documents for search|

---

## ✅ TL;DR Summary

|Feature|Amazon Textract|
|---|---|
|OCR for scanned docs|✅ Yes|
|Forms/key-value pairs|✅ Yes|
|Tables|✅ Yes|
|Handwriting|✅ Yes|
|Identity/receipts|✅ Specialized APIs|
|Real-time + batch|✅ Both supported|
|Output format|JSON with structured blocks|
|Free Tier|✅ 1000 pages for 3 months|

---
