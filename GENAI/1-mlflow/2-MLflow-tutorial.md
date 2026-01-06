
# 🚀 Full MLflow Tutorial (End-to-End, with Docker)

---

## 🧩 Step 1: Folder Structure

Create a project folder named `mlflow-docker`:

```
mlflow-docker/
│
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
└── train.py
```

---

## 🐋 Step 2: docker-compose.yml

This file sets up:

- MLflow Tracking Server
    
- MLflow Client (training job)
    
- Shared volume for logs & artifacts
    

```yaml
version: '3.9'

services:
  mlflow-server:
    image: ghcr.io/mlflow/mlflow:v2.14.1
    container_name: mlflow-server
    environment:
      MLFLOW_TRACKING_URI: http://0.0.0.0:5000
      BACKEND_STORE_URI: sqlite:///mlflow.db
      ARTIFACT_ROOT: /mlflow/artifacts
    command: >
      mlflow server
      --backend-store-uri sqlite:///mlflow.db
      --default-artifact-root /mlflow/artifacts
      --host 0.0.0.0
      --port 5000
    ports:
      - "5000:5000"
    volumes:
      - ./mlruns:/mlflow/artifacts
      - ./mlflow.db:/mlflow/mlflow.db

  mlflow-client:
    build:
      context: .
    container_name: mlflow-client
    depends_on:
      - mlflow-server
    environment:
      MLFLOW_TRACKING_URI: http://mlflow-server:5000
      GIT_PYTHON_REFRESH: quiet
    volumes:
      - ./mlruns:/mlflow/artifacts    # 👈 shared volume so artifacts appear locally
    command: ["python", "train.py"]
```

---

## 🧱 Step 3: Dockerfile (for `mlflow-client`)

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY train.py .

CMD ["python", "train.py"]
```

---

## 🧠 Step 4: requirements.txt

```
mlflow==2.14.1
scikit-learn
pandas
numpy
```

---

## 🧪 Step 5: train.py — Regression Example

```python
import mlflow
import mlflow.sklearn
from sklearn.datasets import load_diabetes
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

# Set experiment
mlflow.set_experiment("Regression_Example")

# Load dataset
X, y = load_diabetes(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)
predictions = model.predict(X_test)
mse = mean_squared_error(y_test, predictions)

# Log with MLflow
with mlflow.start_run(run_name="RandomForestRegression"):
    mlflow.log_param("n_estimators", 100)
    mlflow.log_metric("mse", mse)
    mlflow.sklearn.log_model(model, artifact_path="model")

print("✅ Training complete")
print("🌐 MLflow tracking URI:", mlflow.get_tracking_uri())
```

---

## ▶️ Step 6: Build and Run Everything

From your terminal inside the folder:

```bash
docker compose up --build
```

When you see:

```
mlflow-server  | Listening at: http://0.0.0.0:5000
```

Go to your browser:  
👉 **[http://localhost:5000](http://localhost:5000/)**

You’ll see:

- **Experiment**: `Regression_Example`
    
- **Run**: `RandomForestRegression`
    
- **Metrics**: `mse`
    
- **Artifacts**: `model/`
    

---

## 🧩 Step 7: Verify Artifacts on Your Host

After training completes, check locally:

```bash
ls mlruns/0/
```

You should see a folder with your `run_id`, like:

```
mlruns/0/fe3f0745d91548c38c8b8f0a3f3c4759/
```

Inside:

```
artifacts/model/
```

✅ This is your trained model, stored locally.

---

## 🧠 Step 8: Serve the Model for Inference

You can serve the trained model using MLflow’s model server.

1️⃣ **Find your run ID:**

Look inside:

```
mlruns/0/
```

Pick the folder name (e.g. `fe3f0745d91548c38c8b8f0a3f3c4759`).

2️⃣ **Run model serve:**

```bash
mlflow models serve -m "mlruns/0/fe3f0745d91548c38c8b8f0a3f3c4759/artifacts/model" -p 1234 --no-conda
```

Now it’s live at:  
👉 `http://127.0.0.1:1234/invocations`

---

## 🧪 Step 9: Test Predictions

Send a sample request using `curl`:

```bash
curl -X POST http://127.0.0.1:1234/invocations \
     -H "Content-Type: application/json" \
     -d '{"columns": ["age","sex","bmi","bp","s1","s2","s3","s4","s5","s6"], 
          "data": [0.0380759,0.0506801,0.0616962,0.0218724,-0.0442235,-0.0348208,-0.0434008,-0.0025923,0.0199075,-0.0176461](0.0380759,0.0506801,0.0616962,0.0218724,-0.0442235,-0.0348208,-0.0434008,-0.0025923,0.0199075,-0.0176461.md)}'
```

Output example:

```json
{"predictions": [211.42]}
```

---

## 🧹 Step 10: Stop and Clean Up

Stop containers:

```bash
docker compose down
```

Remove all data (if needed):

```bash
docker compose down -v
```

---

## 📊 Summary

|Component|Purpose|
|---|---|
|**mlflow-server**|Hosts MLflow tracking UI & artifact storage|
|**mlflow-client**|Trains model and logs runs|
|**mlruns/**|Stores all experiments, models, and metadata|
|**UI (port 5000)**|Visualize runs, metrics, and artifacts|
|**Model Serve (port 1234)**|Deploy trained models for inference|

---

## 🧰 Optional Upgrades

- Replace SQLite with **PostgreSQL** for multi-user production setups
    
- Add **MinIO or S3** for scalable artifact storage
    
- Integrate **FastAPI** or **Flask** with the MLflow model
    
- Use **Jenkins/GitHub Actions** for CI/CD automation
    

---
