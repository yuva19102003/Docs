Amazon CloudWatch Alarms are used to **monitor metrics** and **automatically perform actions** based on the value of those metrics. For example, you can create an alarm to notify you if your EC2 instance CPU usage goes above 80% for 5 minutes.

---

### 🔔 What is a CloudWatch Alarm?

A **CloudWatch Alarm** watches a single metric (or the result of a math expression) and triggers an action based on the configured threshold. It can:
- Send an Amazon SNS notification
- Trigger Auto Scaling policies
- Stop, terminate, reboot, or recover an EC2 instance
- Invoke an AWS Lambda function

---

### 📚 Types of CloudWatch Alarms

1. # **Metric Alarms**
   - Most common type.
   - Monitors a single CloudWatch metric or a math expression based on metrics.
   - Compares against a static threshold.

   **Example**: CPUUtilization > 70% for 5 minutes.

    ### ✅ **Use Case**  
    Alert when an EC2 instance’s **CPUUtilization > 80%** for 5 minutes.

    ---

    ### 🖥️ **Console Method**

    1. Go to **Amazon CloudWatch** in AWS Console.
    2. Click **"Alarms"** on the left menu → **"Create Alarm"**.
    3. Under **Select metric**, choose:
    - **Browse** → AWS → EC2 → Per-Instance Metrics
    - Select `CPUUtilization` for your desired `InstanceId`
    4. Click **"Select metric"**.
    5. Under **Conditions**:
    - Threshold type: **Static**
    - Whenever CPUUtilization **is greater than 80**
    6. Under **Additional settings**, set:
    - Period: `5 minutes`
    - Evaluation periods: `1`
    7. Under **Actions**, choose:
    - Notification → Send to an existing or new **SNS topic**
    8. Name the alarm (e.g., `HighCPUAlarm`) and click **"Create alarm"**.

    ---

    ### 💻 **CLI Method**
    ```bash
    aws cloudwatch put-metric-alarm \
    --alarm-name "HighCPUAlarm" \
    --metric-name "CPUUtilization" \
    --namespace "AWS/EC2" \
    --statistic "Average" \
    --period 300 \
    --evaluation-periods 1 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=i-0123456789abcdef0 \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:NotifyMe \
    --unit Percent
    ```
    
    ---

2. ## **Composite Alarms**
   - Combines multiple alarms using **AND/OR logic**.
   - Reduces alarm noise by only triggering when multiple conditions are met.
   - Cannot trigger EC2 actions (only notification actions).

   **Example**: Alarm only triggers if:
   - CPUUtilization > 70%
   - AND
   - DiskReadOps > 1000

    ### ✅ **Use Case**  
    Trigger alert **only if both** CPU > 80% **and** DiskReadOps > 1000.

    ---

    ### 🖥️ **Console Method**

    > ⚠️ Composite alarms require **existing metric alarms**.

    1. Create two metric alarms:
    - `HighCPUAlarm` → CPUUtilization > 80%
    - `HighDiskReadAlarm` → DiskReadOps > 1000
    2. Go to CloudWatch → **Alarms** → **Create Alarm**.
    3. Choose **"Composite Alarm"**.
    4. Under **Conditions**, enter:
    ```txt
    ALARM(HighCPUAlarm) AND ALARM(HighDiskReadAlarm)
    ```
    5. Choose notification or action.
    6. Name it (e.g., `CompositePerformanceAlarm`) and click **"Create alarm"**.

    ---

    ### 💻 **CLI Method**
    ```bash
    aws cloudwatch put-composite-alarm \
    --alarm-name "CompositePerformanceAlarm" \
    --alarm-rule "ALARM(HighCPUAlarm) AND ALARM(HighDiskReadAlarm)" \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:NotifyMe
    ```

    ---

3. ## **Anomaly Detection Alarms**
   - Uses **machine learning** to automatically detect anomalies in metric behavior.
   - You set it up to learn from historical data.
   - Great for **dynamic thresholds** (vs. static ones).

   **Example**: Alarm triggers when a metric goes outside of the "normal" expected range.

    ### ✅ **Use Case**  
    Detect **unexpected spikes** in EC2 `NetworkIn` traffic.

    ---

    ### 🖥️ **Console Method**

    1. Go to CloudWatch → **Alarms** → **Create Alarm**.
    2. Choose `NetworkIn` under EC2 → Select your instance.
    3. On the **Conditions** step:
    - Check the box: **"Use anomaly detection"**
    - Set the deviation value (default is `2`).
    4. Choose **Greater than the upper band**.
    5. Set period and evaluation settings.
    6. Add notification → Name it → Click **"Create alarm"**.

    ---

    ### 💻 **CLI Method**
    ```bash
    aws cloudwatch put-metric-alarm \
    --alarm-name "NetworkInAnomalyAlarm" \
    --metric-name "NetworkIn" \
    --namespace "AWS/EC2" \
    --statistic "Average" \
    --period 300 \
    --evaluation-periods 2 \
    --threshold-metric-id "ad1" \
    --comparison-operator GreaterThanUpperThreshold \
    --metrics '[ 
        {
            "Id": "m1",
            "MetricStat": {
            "Metric": {
                "Namespace": "AWS/EC2",
                "MetricName": "NetworkIn",
                "Dimensions": [
                {
                    "Name": "InstanceId",
                    "Value": "i-0123456789abcdef0"
                }
                ]
            },
            "Period": 300,
            "Stat": "Average"
            },
            "ReturnData": true
        },
        {
            "Id": "ad1",
            "Expression": "ANOMALY_DETECTION_BAND(m1, 2)",
            "Label": "Expected NetworkIn (with band)",
            "ReturnData": true
        }
        ]' \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:NotifyMe
    ```

    ---

## ✅ Summary Table

| 🔔 Alarm Type           | 🛠️ Use Case                            | 📋 Console Setup       | 💻 CLI Command |
|------------------------|----------------------------------------|-------------------------|----------------|
| **Metric Alarm**        | CPU > 80% for 5 mins                   | ✔️ Yes                  | ✔️ Yes         |
| **Composite Alarm**     | CPU > 80% **AND** DiskReadOps > 1000   | ✔️ Yes (with sub-alarms)| ✔️ Yes         |
| **Anomaly Detection**   | Detect spike in NetworkIn              | ✔️ Yes                  | ✔️ Yes         |

---

### ⏱️ Alarm States

CloudWatch Alarms can be in one of three states:
- **OK** – Metric is within the defined threshold.
- **ALARM** – Metric is outside the threshold.
- **INSUFFICIENT_DATA** – Not enough data to determine the state.

---

### 🚀 Common Use Cases

- **EC2**: Trigger Auto Scaling when CPU is high.
- **Billing**: Alert when estimated charges exceed a budget.
- **Lambda**: Alert if invocation errors exceed a threshold.
- **RDS**: Notify when disk space is running low.
- **Custom**: Create your own metrics using the CloudWatch API and set alarms on them.

---
