
## 📈 What is Amazon Forecast?

**Amazon Forecast** is a **fully managed service** that uses **machine learning** to deliver highly accurate **time series forecasts**. It is based on the same technology Amazon.com uses for predicting demand, sales, and inventory.

> ✅ No ML experience required. Just bring historical time-series data and related metadata (like item ID, category, location).

---

## 📦 Use Cases

|Domain|Example Forecasting Use Case|
|---|---|
|Retail|Demand forecasting, product sales|
|Supply Chain|Inventory planning, stockouts|
|Energy|Power demand prediction|
|Finance|Revenue projection, cost estimation|
|Healthcare|Bed availability, patient intake|
|Workforce|Staff scheduling, call center volume|

---

## 🚀 Forecast Capabilities

|Feature|Description|
|---|---|
|AutoML|Selects the best algorithm automatically|
|Domain-specific models|Includes CNN-QR, DeepAR+, Prophet, ARIMA|
|Related time series|Incorporate external data like weather, price, holiday|
|Item metadata support|Use product category, brand, etc. to improve accuracy|
|Probabilistic forecasts|Predict confidence intervals (P10, P50, P90)|
|Retrainable & reusable models|Models can be retrained and reused|
|Export to S3 or inference|Run batch forecasts or export CSV to S3|

---

## 📁 Required Input Datasets

|Dataset Name|Required|Description|
|---|---|---|
|**Target Time Series**|✅ Yes|Historical demand per item per timestamp|
|**Related Time Series**|Optional|Weather, promotions, price, etc.|
|**Item Metadata**|Optional|Product category, brand, warehouse, etc.|

✅ Must include:

- `item_id`
    
- `timestamp`
    
- `target_value`
    

---

## 🧠 Forecasting Workflow

1. **Prepare Data** → Upload CSVs to S3
    
2. **Create Dataset Group**
    
3. **Create Predictor (train model)**
    
4. **Create Forecast**
    
5. **Query or Export Forecast Results**
    

---

## 🧪 Sample Python (Boto3) Code

### Step 1: Create Dataset Group

```python
import boto3
forecast = boto3.client('forecast')

forecast.create_dataset_group(
    DatasetGroupName='sales-forecast-group',
    Domain='RETAIL',
    DatasetArns=[
        'arn:aws:forecast:...:dataset/target_time_series'
    ]
)
```

---

### Step 2: Train Predictor

```python
forecast.create_predictor(
    PredictorName='sales-predictor',
    ForecastHorizon=30,
    PerformAutoML=True,
    InputDataConfig={
        'DatasetGroupArn': 'arn:aws:forecast:...:dataset-group/sales-forecast-group'
    },
    FeaturizationConfig={
        'ForecastFrequency': 'D',
        'Featurizations': [{'AttributeName': 'target_value', 'FeaturizationPipeline': []}]
    }
)
```

---

### Step 3: Generate Forecast

```python
forecast.create_forecast(
    ForecastName='sales-forecast',
    PredictorArn='arn:aws:forecast:...:predictor/sales-predictor'
)
```

---

### Step 4: Query Forecast Results

```python
query = boto3.client('forecastquery')

response = query.query_forecast(
    ForecastArn='arn:aws:forecast:...:forecast/sales-forecast',
    StartDate='2025-07-01T00:00:00',
    EndDate='2025-07-31T00:00:00',
    Filters={"item_id": "item-001"}
)

print(response['Forecast']['Predictions'])
```

---

## 🧾 Output Example

```json
{
  "Predictions": {
    "p10": [{"Timestamp": "2025-07-01", "Value": "125.5"}, ...],
    "p50": [{"Timestamp": "2025-07-01", "Value": "140.7"}, ...],
    "p90": [{"Timestamp": "2025-07-01", "Value": "160.2"}, ...]
  }
}
```

---

## 💰 Pricing (2024)

|Component|Price|
|---|---|
|**Training (AutoML)**|$0.60 per training hour|
|**Inference**|$0.00075 per forecasted data point (per item, per timestamp)|
|**S3 Storage**|Standard S3 pricing|
|**Free Tier**|10,000 forecast units/month for first 2 months|

🧠 **Forecast Unit** = 1 item × 1 timestamp.

---

## 🛡️ Security

|Feature|Support|
|---|---|
|IAM role for access|✅ Required for S3 + Forecast|
|KMS Encryption|✅ Optional for input/output|
|VPC Support|❌ Not supported|
|CloudTrail|✅ Yes for API logging|

---

## 🧱 Terraform Example

Amazon Forecast has limited Terraform support. Here's how to create a dataset:

```hcl
resource "aws_forecast_dataset" "target_dataset" {
  dataset_name = "my-forecast-dataset"
  domain       = "RETAIL"
  dataset_type = "TARGET_TIME_SERIES"
  data_frequency = "D"
  schema = jsonencode({
    Attributes = [
      { AttributeName = "item_id", AttributeType = "string" },
      { AttributeName = "timestamp", AttributeType = "timestamp" },
      { AttributeName = "target_value", AttributeType = "float" },
    ]
  })
}
```

---

## 🧠 Model Types Used by Forecast

- **DeepAR+** – probabilistic RNN (great for sparse and intermittent demand)
    
- **CNN-QR** – convolutional quantile regression
    
- **ARIMA** – traditional time series
    
- **Prophet** – from Facebook, seasonal forecasting
    
- **ETS** – exponential smoothing
    

> Forecast automatically selects the best model using AutoML (unless overridden).

---

## ✅ TL;DR Summary

|Feature|Amazon Forecast|
|---|---|
|Forecast type|Time series (quantitative)|
|Manual or AutoML|✅ Both supported|
|Forecast horizon|Up to 500 days|
|Confidence intervals|✅ P10, P50, P90|
|Input format|CSV (uploaded to S3)|
|Inference options|Batch queries via API or S3 export|
|Free Tier|✅ 10K forecasts/month (2 months)|
|Terraform support|✅ Partial (dataset/dataset group only)|
|Common integrations|S3, Lambda, Athena, Step Functions|

---
