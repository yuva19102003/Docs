
## 🌍 What is Amazon Translate?

**Amazon Translate** is a **fully managed Neural Machine Translation (NMT)** service that delivers **high-quality, real-time language translation** between 75+ languages.

> ✅ It uses deep learning models to provide accurate and context-aware translations for apps, websites, chat, and content pipelines.

---

## 🚀 Use Cases

|Use Case|Description|
|---|---|
|🌐 Website localization|Translate dynamic site content for global users|
|💬 Real-time chat translation|Cross-language messaging between users|
|📚 Document translation|Auto-translate product manuals, reports, articles|
|🛠️ Customer support|Translate helpdesk tickets and responses|
|🎙️ Multimedia subtitles|Use with Amazon Transcribe to subtitle videos|
|📦 Ecommerce product listings|Globalize catalogs and user reviews|

---

## 🧠 Key Features

|Feature|Description|
|---|---|
|**Neural Machine Translation**|Context-aware, high-quality translations|
|**Custom Terminology**|Add brand-specific, domain-specific vocabulary|
|**Batch Translation**|Translate large files in S3 asynchronously|
|**Real-time API**|Low-latency translation for apps and websites|
|**Language auto-detection**|Detect the source language automatically|
|**Secure by design**|TLS encrypted; no data stored after translation|

---

## 🌐 Supported Languages

Supports **75+ languages**, including:

- English (en), Hindi (hi), Tamil (ta), Telugu (te), Kannada (kn), Malayalam (ml)
    
- French, German, Spanish, Portuguese, Arabic, Chinese (zh), Japanese, Korean
    
- Russian, Ukrainian, Turkish, Polish, Vietnamese, Dutch, and more.
    

Full list: [AWS Translate Supported Languages](https://docs.aws.amazon.com/translate/latest/dg/what-is.html#what-is-languages)

---

## 💵 Pricing (2024)

|Service Type|Price|
|---|---|
|**Real-time API**|$15.00 per 1 million characters|
|**Batch Mode**|Same as real-time|
|**Free Tier**|2 million characters per month (12 mo)|

🧠 Tip: You are billed **per character**, not per word.

---

## 🧰 Sample Python Code (Boto3)

### 🔁 Real-time Translation Example

```python
import boto3

translate = boto3.client('translate')

response = translate.translate_text(
    Text="Hello, how are you?",
    SourceLanguageCode="en",
    TargetLanguageCode="fr"
)

print(response['TranslatedText'])  # Bonjour, comment allez-vous ?
```

---

### 🧩 Using Custom Terminology

Custom terminology helps maintain **brand names**, **technical terms**, etc., during translation.

```python
response = translate.translate_text(
    Text="Welcome to OpenAI",
    SourceLanguageCode="en",
    TargetLanguageCode="de",
    TerminologyNames=["BrandTerms"]
)

print(response['TranslatedText'])
```

> 🧠 You must upload a CSV file containing source/target terminology pairs to use this.

---

### 📁 Batch Translation via S3

Steps:

1. Upload source documents to S3.
    
2. Use `start_text_translation_job()` to initiate.
    
3. Translated files will be saved to output S3 bucket.
    

```python
response = translate.start_text_translation_job(
    InputDataConfig={
        'S3Uri': 's3://my-input-bucket/text/',
        'ContentType': 'text/plain'
    },
    OutputDataConfig={
        'S3Uri': 's3://my-output-bucket/translated/'
    },
    DataAccessRoleArn='arn:aws:iam::123456789012:role/TranslateAccessRole',
    SourceLanguageCode='en',
    TargetLanguageCodes=['es']
)
```

---

## 🔐 Security

|Layer|Description|
|---|---|
|IAM|Granular permissions for `translate:*`|
|TLS Encryption|All data in transit is encrypted|
|No Data Stored|Amazon does not retain your content|
|VPC Endpoints|Supported via AWS PrivateLink|

---

## 🧱 Terraform IAM Example

```hcl
resource "aws_iam_role" "translate_batch_role" {
  name = "translate-batch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "translate.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "translate_policy" {
  role = aws_iam_role.translate_batch_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::your-bucket/*"
      }
    ]
  })
}
```

---

## 🧩 Amazon Translate + Other AWS Services

|Integration|Description|
|---|---|
|**Amazon S3**|Batch translation input/output|
|**Amazon Lambda**|Auto-translate text on upload|
|**Amazon Comprehend**|Translate → Sentiment detection|
|**Amazon Transcribe**|Transcribe → Translate for subtitle/voice|
|**Amazon SNS**|Notify when translation job is done|

---

## ✅ TL;DR Summary

|Feature|Amazon Translate|
|---|---|
|Real-time Translation|✅ Yes|
|Batch S3 Translation|✅ Yes|
|Custom Terminology|✅ Yes|
|Auto Language Detection|✅ Yes|
|Text-to-Text Only|✅ Yes (no speech)|
|Free Tier|✅ 2 million characters/month (1st year)|
|Common Pairings|S3, Lambda, Transcribe, Polly|
|Language Support|✅ 75+|

---
