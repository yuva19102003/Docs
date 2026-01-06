
## 🧠 What is Amazon SageMaker?

**Amazon SageMaker** is a **fully managed service** that enables **data scientists and developers** to build, train, and deploy **machine learning models** quickly at scale.

> ✅ It supports the full ML lifecycle: **data labeling → training → tuning → hosting → monitoring** — all in one platform.

---

## 🧰 SageMaker: Key Features and Modules

|Module|Purpose|
|---|---|
|**Studio**|Web-based IDE for ML development (JupyterLab-like)|
|**Data Wrangler**|Prepare and visualize data without writing code|
|**Feature Store**|Store and reuse features across models|
|**Ground Truth**|Data labeling with human annotators + ML assistance|
|**Training Jobs**|Train ML models at scale using built-in or custom containers|
|**Hyperparameter Tuning**|Automatically tune model parameters|
|**Inference Endpoints**|Deploy models via REST APIs (real-time or batch)|
|**Model Monitor**|Detect drift in production|
|**Pipelines**|Automate ML workflows (CI/CD for ML)|

---

## 🎯 Use Cases

|Industry|Example Use Case|
|---|---|
|eCommerce|Product recommendation, customer churn|
|Finance|Fraud detection, credit scoring|
|Healthcare|Medical image analysis, disease prediction|
|Manufacturing|Predictive maintenance|
|Retail|Demand forecasting|
|NLP / Vision|Sentiment analysis, object detection|

---

## 🧪 Supported ML Frameworks

- ✅ **Built-in**: XGBoost, Linear Learner, KNN, etc.
    
- ✅ **Frameworks**: TensorFlow, PyTorch, MXNet, Scikit-Learn, HuggingFace
    
- ✅ **Bring Your Own Container** (BYOC): Custom Docker for any toolset
    

---

## 🧑‍💻 Example: Train a Model with Boto3 (Python SDK)

### Step 1: Upload data to S3

```python
import boto3

s3 = boto3.client('s3')
s3.upload_file('train.csv', 'my-sagemaker-bucket', 'train/train.csv')
```

---

### Step 2: Train a built-in XGBoost model

```python
import sagemaker
from sagemaker import image_uris

session = sagemaker.Session()
role = 'arn:aws:iam::123456789012:role/sagemaker-role'

xgboost_image = image_uris.retrieve("xgboost", region='us-east-1', version='1.3-1')

estimator = sagemaker.estimator.Estimator(
    image_uri=xgboost_image,
    role=role,
    instance_count=1,
    instance_type='ml.m5.large',
    output_path='s3://my-sagemaker-bucket/output',
    sagemaker_session=session
)

estimator.set_hyperparameters(objective='reg:squarederror', num_round=100)

estimator.fit({'train': 's3://my-sagemaker-bucket/train/train.csv'})
```

---

### Step 3: Deploy model as a REST API

```python
predictor = estimator.deploy(
    initial_instance_count=1,
    instance_type='ml.m5.large'
)

response = predictor.predict([1.2, 3.4, 5.6](1.2,%203.4,%205.6.md))
print(response)
```

---

## 🚀 SageMaker Deployment Options

|Type|Use Case|
|---|---|
|**Real-time Endpoint**|For low-latency inference|
|**Batch Transform**|For offline, large datasets|
|**Asynchronous**|For long-duration inference|
|**Edge Deployment**|Deploy to IoT devices using SageMaker Neo|

---

## 🧪 Example: SageMaker Pipelines (ML CI/CD)

```python
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.steps import ProcessingStep, TrainingStep
from sagemaker.workflow.parameters import ParameterString

# Define steps using Step Functions syntax
pipeline = Pipeline(
    name="my-ml-pipeline",
    steps=[data_processing_step, model_training_step, model_registration_step]
)
pipeline.upsert(role_arn=role)
pipeline.start()
```

---

## 💰 Pricing Overview

|Component|Pricing Model|
|---|---|
|Studio Notebook|Pay per compute (CPU/GPU) instance-hour|
|Training Jobs|Per instance type/hour + optional S3 storage cost|
|Inference Endpoint|Per instance/hour + data transfer|
|Ground Truth Labeling|Per object labeled|
|Pipelines|Pay only for compute used in each step|

✅ **Free Tier**: 250 hours/month of `ml.t2.medium` for notebooks for 2 months.

---

## 🛡️ Security

|Feature|Support|
|---|---|
|IAM roles and policies|✅ Granular access control|
|VPC support|✅ Yes (training + inference)|
|Encryption|✅ S3 + EBS with KMS|
|PrivateLink|✅ SageMaker via VPC endpoint|
|Audit logging|✅ CloudTrail + Model Monitor|

---

## 🧱 Terraform Support

Amazon SageMaker has rich Terraform support. Example for deploying a model:

### 1. IAM Role

```hcl
resource "aws_iam_role" "sagemaker_execution" {
  name = "sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "sagemaker.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}
```

### 2. Model Deployment

```hcl
resource "aws_sagemaker_model" "example" {
  name               = "my-model"
  execution_role_arn = aws_iam_role.sagemaker_execution.arn
  primary_container {
    image           = "382416733822.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest"
    model_data_url  = "s3://my-sagemaker-bucket/output/model.tar.gz"
  }
}
```

---

## 🧠 Comparison with Other Services

|Service|Use Case|
|---|---|
|**Comprehend**|Pre-trained NLP tasks|
|**Rekognition**|Pre-trained computer vision|
|**SageMaker**|Custom ML models (NLP, CV, etc.)|
|**Bedrock**|Foundation models (LLMs) via API|

---

## ✅ TL;DR Summary

|Feature|SageMaker|
|---|---|
|Full ML lifecycle support|✅ Yes|
|Auto-scaling training|✅ Yes|
|Built-in algorithms|✅ 15+ included|
|Custom model/container|✅ Yes|
|Framework support|TensorFlow, PyTorch, SKLearn|
|Deployment options|Real-time, batch, async, edge|
|CI/CD automation|✅ With SageMaker Pipelines|
|Free Tier|✅ 250 hours/month (2 months)|
|Terraform support|✅ Yes (IAM, model, endpoint)|

---
