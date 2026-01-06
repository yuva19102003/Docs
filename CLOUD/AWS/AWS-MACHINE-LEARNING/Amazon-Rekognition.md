
## 🧠 What is Amazon Rekognition?

**Amazon Rekognition** is a **fully managed computer vision service** that enables you to extract information from images and videos using **pre-trained deep learning models**.

> ✅ It supports facial analysis, object detection, celebrity recognition, text detection (OCR), content moderation, and custom labels — all **without needing to build and train your own ML model**.

---

## 🧰 Key Use Cases

|Use Case|Rekognition Feature|
|---|---|
|👁️ Face detection & analysis|Detect faces, emotions, age range, gender|
|🧍 Person tracking in video|Detect and track people frame by frame|
|🛡️ Content moderation|Flag unsafe or explicit content|
|🆔 Face search/recognition|Match faces against a collection|
|🔠 OCR (text in image/video)|Detect printed or handwritten text|
|📦 Object detection|Detect people, animals, vehicles, etc.|
|🎬 Video analysis|Use Rekognition Video for temporal data|
|🧠 Custom image classification|Train your own model using Rekognition Custom Labels|

---

## 🔎 Feature Overview

|Feature|Image|Video|Description|
|---|---|---|---|
|**Detect Faces**|✅|✅|Bounding box, age, emotions, gender|
|**Recognize Celebrities**|✅|✅|Prebuilt celeb face database|
|**Detect Labels**|✅|✅|Identify scenes, objects, activities|
|**Detect Text (OCR)**|✅|✅|Print or handwritten text from images/videos|
|**Content Moderation**|✅|✅|Flag adult/violent/inappropriate content|
|**Custom Labels**|✅|❌|Train on your own labeled dataset (no coding)|
|**Face Comparison**|✅|❌|Compare two faces or against a face collection|
|**Person Pathing**|❌|✅|Track individuals across frames in a video|

---

## 🛠️ Rekognition vs SageMaker vs OpenCV

|Task|Rekognition|SageMaker|OpenCV / Custom|
|---|---|---|---|
|Face & label detection|✅ Fully managed|❌ Custom only|❌ Needs own model|
|Custom classification|✅ No-code (Custom Labels)|✅ Full training pipeline|✅ From scratch|
|Video analytics|✅ Yes|❌ Not native|❌ Hard to scale|
|Serverless deployment|✅ Yes|❌ Needs infrastructure|❌ Manual setup|

---

## 💵 Pricing Summary (2024)

|Feature|Image Price (per image)|Video Price (per minute)|
|---|---|---|
|Label detection|$0.001|$0.12|
|Face detection|$0.001|$0.12|
|Face comparison|$0.0015|N/A|
|Custom Labels training|$1.00/hour (training)|N/A|
|Custom Labels inference|$4.00 per 1,000 images|N/A|
|Content moderation|$0.001|$0.10|

🧠 **Tip**: For large datasets, use batch processing (e.g., with S3 and Lambda) to reduce cost.

---

## 🧪 Sample Python Code (Boto3)

### 1. **Detect Labels in an Image**

```python
import boto3

rekognition = boto3.client('rekognition')

response = rekognition.detect_labels(
    Image={'S3Object': {'Bucket': 'my-bucket', 'Name': 'my-image.jpg'}},
    MaxLabels=5,
    MinConfidence=80
)

for label in response['Labels']:
    print(f"{label['Name']} - {label['Confidence']:.2f}%")
```

---

### 2. **Face Comparison**

```python
response = rekognition.compare_faces(
    SourceImage={'S3Object': {'Bucket': 'my-bucket', 'Name': 'face1.jpg'}},
    TargetImage={'S3Object': {'Bucket': 'my-bucket', 'Name': 'face2.jpg'}},
    SimilarityThreshold=80
)

for faceMatch in response['FaceMatches']:
    print("Similarity:", faceMatch['Similarity'])
```

---

### 3. **Detect Text in Image**

```python
response = rekognition.detect_text(
    Image={'S3Object': {'Bucket': 'my-bucket', 'Name': 'receipt.jpg'}}
)

for text in response['TextDetections']:
    print(text['DetectedText'], text['Confidence'])
```

---

## 📦 Rekognition Custom Labels (No-code ML)

Train your own model using S3-labeled images:

- Step 1: Label images via Ground Truth or CSV manifest
    
- Step 2: Create a **Rekognition Custom Labels Project**
    
- Step 3: Train the model (serverless training)
    
- Step 4: Deploy the model endpoint and invoke via API
    

⚠️ Note: Custom Labels pricing is different (more expensive, but very powerful)

---

## 🔐 Security and Access Control

|Feature|Details|
|---|---|
|IAM Role|Required to use Rekognition APIs|
|S3 Integration|Uses S3Object for media input|
|KMS Encryption|Supported if S3 bucket uses SSE-KMS|
|VPC Support|Not applicable (Rekognition is regional API only)|

---

## 🛠️ Terraform Integration (Basic)

Amazon Rekognition does not have extensive Terraform support (e.g., no `aws_rekognition_custom_label`), but you can:

- Manage IAM roles/policies
    
- Automate image pipelines (S3 + Lambda + Rekognition)
    
- Use **AWS Lambda** to invoke Rekognition API programmatically
    

Example: S3 + Rekognition + Lambda can be orchestrated via Terraform for event-driven analysis.

---

## ✅ TL;DR Summary

|Feature|Amazon Rekognition|
|---|---|
|Pre-trained Models|✅ Yes|
|Custom Models|✅ Rekognition Custom Labels|
|Real-time Video|✅ Yes (via Kinesis Video Stream)|
|Face Search/Compare|✅ Yes|
|OCR|✅ Yes (text detection in images/videos)|
|Content Moderation|✅ Yes|
|Serverless|✅ Fully managed APIs|
|Terraform Support|⚠️ Limited|
|Ideal For|Fast, no-ML-code visual recognition tasks|

---

## 🔄 Popular Integrations

|Service|How It Works|
|---|---|
|**S3**|Store and analyze media (image/video)|
|**Lambda**|Trigger analysis on file upload|
|**Step Functions**|Build image moderation pipelines|
|**SNS/SQS**|Notify users based on Rekognition results|
|**SageMaker**|Extend with more complex model use cases|

---
