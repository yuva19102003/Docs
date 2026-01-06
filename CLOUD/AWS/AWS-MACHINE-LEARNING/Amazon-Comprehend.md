
## 🧠 What is Amazon Comprehend?

**Amazon Comprehend** is a **fully managed NLP service** that uses **machine learning** to extract insights and relationships from **text** — no ML expertise required.

> ✅ It can detect **sentiment**, **key phrases**, **named entities**, **language**, and even supports **custom classification and entity recognition**.

---

## 📦 Key Use Cases

|Use Case|Description|
|---|---|
|🧠 Sentiment analysis|Understand tone in product reviews, emails, tweets, etc.|
|🏷️ Entity extraction|Extract names, dates, organizations, locations|
|🔍 Text classification|Categorize support tickets, feedback, news, etc.|
|📑 Key phrase extraction|Pull important terms from paragraphs|
|🌍 Language detection|Identify the language of the given text|
|🧾 Custom classifiers|Train models to classify content in domain-specific ways|
|📄 Custom entity recognition|Detect domain-specific entities (e.g., product codes, IDs)|
|🏥 Medical text analysis|(Comprehend Medical) Extract protected health info (PHI)|

---

## 🚀 Features Overview

|Feature|API / Feature Name|Description|
|---|---|---|
|Language detection|`DetectDominantLanguage`|Auto-detects the language of the input text|
|Entity recognition|`DetectEntities`|Extracts people, places, dates, organizations|
|Key phrase detection|`DetectKeyPhrases`|Highlights important phrases|
|Sentiment analysis|`DetectSentiment`|Positive, Negative, Neutral, Mixed|
|Syntax analysis|`DetectSyntax`|Parts of speech tagging (noun, verb, etc.)|
|PII detection|`ContainsPiiEntities`|Finds PII (email, SSN, phone, etc.)|
|Custom classification|`CreateDocumentClassifier`|Train and use a classifier with your labeled dataset|
|Custom entity recognition|`CreateEntityRecognizer`|Train model to detect domain-specific named entities|
|Comprehend Medical|`comprehendmedical:*`|Specialized medical text analysis (HIPAA compliant)|

---

## 🌐 Supported Languages (Standard Comprehend)

- English, Spanish, French, German, Italian, Portuguese
    
- Hindi (limited), Japanese, Korean, Chinese (Simplified)
    
- Many APIs (like sentiment) support 6–10 languages
    

---

## 💡 Example: Analyze a Product Review

### Input:

> “The new headphones are amazing! Great sound and battery life.”

### Output:

- **Sentiment**: `Positive`
    
- **Entities**: `headphones` (Product)
    
- **Key Phrases**: `new headphones`, `great sound`, `battery life`
    

---

## 🧪 Python (Boto3) Examples

### 🔍 Detect Sentiment

```python
import boto3

client = boto3.client('comprehend')

response = client.detect_sentiment(
    Text="I love this product. It works flawlessly.",
    LanguageCode='en'
)

print(response['Sentiment'])  # POSITIVE
```

---

### 📌 Detect Key Phrases

```python
response = client.detect_key_phrases(
    Text="The movie had great visual effects and soundtrack.",
    LanguageCode='en'
)

for phrase in response['KeyPhrases']:
    print(phrase['Text'], " - Confidence:", phrase['Score'])
```

---

### 🏷️ Detect Entities

```python
response = client.detect_entities(
    Text="Barack Obama was the 44th President of the United States.",
    LanguageCode='en'
)

for entity in response['Entities']:
    print(entity['Type'], entity['Text'])
```

---

## 🧑‍🏫 Custom Classification (Advanced)

You can:

- Train a custom classifier using labeled text documents in **S3** (CSV format)
    
- Create and train with `CreateDocumentClassifier`
    
- Use `ClassifyDocument` API on new text
    

### Dataset Format (CSV)

```
__label__billing   The customer has a billing issue with their last invoice.
__label__support   I can't connect to the internet since yesterday.
```

---

## 💸 Pricing (2024)

|Feature|Price (per unit)|
|---|---|
|Text analysis (standard)|~$1.00 per 1000 units (100 units = 100 tokens ≈ 100 words)|
|Custom classification|~$3.00 per hour (training) + usage fees|
|PII detection|~$0.0001 per unit|
|Comprehend Medical|~$0.0015 per unit|
|Free tier|50K units/month for 12 months|

---

## 🛡️ Security & Compliance

|Feature|Support|
|---|---|
|IAM control|✅ Yes|
|Logging with CloudTrail|✅ Yes|
|HIPAA compliance|✅ Comprehend Medical|
|KMS integration|✅ For S3 training data|
|VPC endpoints|✅ Via AWS PrivateLink|

---

## 🧱 Terraform Support

Comprehend support in Terraform is limited to **custom classifier resources**.

### Custom Classifier Example:

```hcl
resource "aws_comprehend_document_classifier" "my_classifier" {
  document_classifier_name = "support-ticket-classifier"
  data_access_role_arn     = aws_iam_role.comprehend_access.arn
  language_code            = "en"
  input_data_config {
    s3_uri     = "s3://my-dataset/classifier/train.csv"
    data_format = "COMPREHEND_CSV"
  }
}
```

---

## 🔗 Service Integrations

|AWS Service|Integration Use Case|
|---|---|
|**S3**|Store input documents or training datasets|
|**Lambda**|Analyze text as it is uploaded or submitted|
|**SNS / SQS**|Alert when classification is complete|
|**Translate**|Translate → Comprehend for multi-language support|
|**QuickSight**|Analyze sentiment trends or classification breakdowns|
|**OpenSearch**|Index structured text from Comprehend analysis|

---

## ✅ TL;DR Summary

|Feature|Amazon Comprehend|
|---|---|
|Ready-made NLP|✅ Yes|
|Language detection|✅ Yes|
|Sentiment & key phrases|✅ Yes|
|Entity recognition|✅ Yes (standard and custom)|
|PII detection|✅ Yes|
|Custom classification|✅ Yes (via S3 CSV)|
|Terraform support|⚠️ Partial (custom only)|
|Free tier|✅ 50K units/mo for 12 months|
|Common integration|Lambda, Translate, S3, QuickSight|

---
