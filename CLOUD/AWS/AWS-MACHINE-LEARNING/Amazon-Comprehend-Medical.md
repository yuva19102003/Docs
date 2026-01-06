
## 🧠 What is Amazon Comprehend Medical?

**Amazon Comprehend Medical** is a **HIPAA-eligible NLP service** designed to extract **clinical information** from unstructured medical documents such as doctor's notes, prescriptions, and EHRs (Electronic Health Records).

> ✅ It identifies **PHI (Protected Health Information)**, **medical conditions**, **anatomy**, **medications**, **dosage**, and **treatment plans** from free-form text.

---

## 🩺 Key Use Cases

|Use Case|Description|
|---|---|
|🧾 EHR processing|Extract structured info from free-text medical records|
|🧑‍⚕️ Clinical data mining|Identify patterns in patient histories|
|💊 Medication reconciliation|Detect drug names, dosages, frequency, and route|
|🔍 PHI de-identification|Automatically detect PII/PHI from clinical text|
|📑 Clinical trial eligibility|Match patients to trials based on diagnoses and history|
|📚 Medical document search|Index patient records for search based on conditions or medications|

---

## 🔍 Extracted Entities by Comprehend Medical

|Category|Description|
|---|---|
|**MEDICATION**|Drug names, dosages, frequency, route, etc.|
|**CONDITION**|Diagnoses, symptoms, and diseases|
|**ANATOMY**|Body parts and anatomical terms|
|**TEST_TREATMENT_PROCEDURE**|Medical procedures or treatments|
|**PROTECTED_HEALTH_INFORMATION (PHI)**|Names, IDs, dates, addresses|
|**TIME_EXPRESSION**|Durations, frequencies, timeframes|
|**ICD-10-CM, RxNorm**|Coding for diseases and drugs (optional SNOMED)|

---

## 🧪 Example: Input and Output

### Input:

> “John Smith was prescribed 5 mg of Lipitor once daily for high cholesterol.”

### Output:

```json
[
  {
    "Type": "MEDICATION",
    "Text": "Lipitor",
    "Attributes": [
      { "Type": "DOSAGE", "Text": "5 mg" },
      { "Type": "FREQUENCY", "Text": "once daily" }
    ]
  },
  {
    "Type": "CONDITION",
    "Text": "high cholesterol"
  },
  {
    "Type": "PHI",
    "Text": "John Smith"
  }
]
```

---

## 📊 API Operations

|Operation|Description|
|---|---|
|`DetectEntitiesV2`|Extract medical concepts from text|
|`InferICD10CM`|Map text to **ICD-10-CM** medical codes|
|`InferRxNorm`|Map medications to **RxNorm** identifiers|
|`DetectPHI`|Detect and classify **PHI (Protected Health Information)**|

> 📎 Supports plain text input of **10–20 KB** per call.

---

## 🌐 Supported Language

- **English** only (as of 2024).
    

---

## 💰 Pricing (2024)

|API Operation|Price per unit (1 unit = 100 characters)|
|---|---|
|`DetectEntitiesV2`|$0.0015 per unit|
|`DetectPHI`|$0.0015 per unit|
|`InferRxNorm`|$0.0015 per unit|
|`InferICD10CM`|$0.0015 per unit|

🧠 **Free Tier**: Not included in AWS Free Tier (unlike Amazon Comprehend).

---

## 🔒 HIPAA Eligibility & Security

|Compliance Feature|Status|
|---|---|
|**HIPAA Eligible**|✅ Yes (BAA required)|
|**Encryption**|TLS in transit, KMS at rest|
|**IAM & CloudTrail**|✅ Yes|
|**PrivateLink Support**|✅ Yes (via VPC endpoint)|

---

## 🧑‍💻 Sample Python Code (Boto3)

### Detect Entities in Clinical Text

```python
import boto3

client = boto3.client('comprehendmedical')

response = client.detect_entities_v2(
    Text="Patient was prescribed 10 mg of Lisinopril for hypertension."
)

for entity in response['Entities']:
    print(f"{entity['Type']} → {entity['Text']}")
```

---

### Detect PHI

```python
response = client.detect_phi(
    Text="John Smith was seen at St. Joseph Hospital on 2023-06-12."
)

for phi in response['Entities']:
    print(f"PHI: {phi['Text']} - Type: {phi['Type']}")
```

---

## 🧱 Terraform Support

Amazon Comprehend Medical has **no direct Terraform resources**, but you can:

- Set up **IAM roles and policies**
    
- Automate via **Lambda**, **Step Functions**, or **S3 triggers**
    

### Example IAM Policy

```hcl
resource "aws_iam_policy" "comprehend_medical_access" {
  name = "ComprehendMedicalPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "comprehendmedical:DetectEntitiesV2",
        "comprehendmedical:DetectPHI",
        "comprehendmedical:InferRxNorm",
        "comprehendmedical:InferICD10CM"
      ],
      Resource = "*"
    }]
  })
}
```

---

## 🔁 Integrations

|AWS Service|Usage|
|---|---|
|**S3**|Store patient records or extracted entities|
|**Lambda**|Run entity extraction on document upload|
|**Step Functions**|Build ETL pipelines for medical text analysis|
|**Athena**|Query extracted structured data|
|**OpenSearch**|Search by medication, conditions, etc.|
|**Amazon Translate**|Translate non-English text first (limited use)|

---

## ✅ TL;DR Summary

|Feature|Amazon Comprehend Medical|
|---|---|
|HIPAA eligible|✅ Yes|
|Entity types|MEDICATION, CONDITION, PHI, ANATOMY, etc.|
|Language support|English only|
|Code standard support|✅ RxNorm, ICD-10-CM|
|Real-time API|✅ Yes|
|Pricing|~$0.0015 per 100 characters|
|Free Tier|❌ Not available|
|Terraform support|⚠️ Only IAM-based setup|

---
