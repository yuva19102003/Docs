When monitoring EC2 instances with **Amazon CloudWatch**, you typically use CloudWatch for **logs**, **metrics**, and **custom monitoring**. There are two main agents involved:

---

## 🔧 1. **CloudWatch Agent Types**

### a. **CloudWatch Logs Agent (Deprecated)**

- **Purpose**: Only sends **log files** to CloudWatch Logs.
    
- **Language**: Written in Python.
    
- **Installation**: Via `awslogs` package.
    
- **Status**: **Deprecated** – use **Unified Agent** instead.
    

### b. **CloudWatch Unified Agent (Recommended)**

- **Purpose**: Sends **logs** and **metrics** (both default and custom) to CloudWatch.
    
- **Features**:
    
    - Collect **CPU, memory, disk, network** metrics.
        
    - Push **custom application logs**.
        
    - Collect **procstat**, **disk IO**, etc.
        
- **Installation**: Single agent; installed from `amazon-cloudwatch-agent` package.
    

---

## 📊 2. **CloudWatch Metrics for EC2**

### a. **Default Metrics (from EC2 without agent)**

Sent automatically every 5 minutes (or 1 minute with detailed monitoring):

- `CPUUtilization`
    
- `NetworkIn`, `NetworkOut`
    
- `DiskReadBytes`, `DiskWriteBytes`
    
- `StatusCheckFailed`, etc.
    

> 🔍 No agent needed for default metrics.

---

### b. **Custom Metrics (with CloudWatch Unified Agent)**

Requires Unified Agent to collect:

- **Memory usage**
    
- **Disk space usage**
    
- **Swap usage**
    
- **Custom app-level metrics** (via `statsd` or embedded API)
    

> 📌 These are **not available** without the agent.

---

## 📂 3. **CloudWatch Logs**

### a. Log Types You Can Send:

- `/var/log/messages`, `/var/log/syslog`, `/var/log/nginx/access.log`, etc.
    
- App logs like Python, Java, Node.js logs.
    

### b. Where to Configure:

- **Unified Agent** config file: `/opt/aws/amazon-cloudwatch-agent/bin/config.json`
    
- Or use the **Wizard**: `amazon-cloudwatch-agent-config-wizard`
    

---

## 🔁 Summary

|Feature|No Agent|Logs Agent (Deprecated)|Unified Agent ✅|
|---|---|---|---|
|Basic EC2 Metrics|✅|❌|✅|
|Custom Metrics (Memory, etc.)|❌|❌|✅|
|Logs Collection|❌|✅|✅|
|StatsD/CollectD Support|❌|❌|✅|
|Recommended|❌|❌|✅|

---
## ☁️ CloudWatch Unified Agent – Setup Workflow (Logs + Metrics)

---

### 🔑 Step 1: **IAM Role/Permissions**

Attach an IAM Role to your EC2 instance with this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ]
}
```

---

### 🛠 Step 2: **Install the Unified CloudWatch Agent**

#### For Amazon Linux / Ubuntu / Debian:

```bash
# Download & Install
sudo yum install amazon-cloudwatch-agent -y      # Amazon Linux
# or
sudo apt-get install amazon-cloudwatch-agent -y  # Ubuntu/Debian
```

---

### ⚙️ Step 3: **Create the Agent Configuration File**

You can use the **wizard** or manually create a config.

#### 🔧 Use Wizard (Recommended):

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

> The wizard prompts you to choose:

- Logs to collect (e.g., `/var/log/syslog`)
    
- Metrics to collect (e.g., memory, disk, swap)
    
- Region
    
- Destination (CloudWatch Logs group)
    

#### 📄 OR Manually create a config:

Example config (`/opt/aws/amazon-cloudwatch-agent/bin/config.json`):

```json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["/"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "ec2-syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

---

### ▶️ Step 4: **Start the Agent**

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
```

---

### ✅ Step 5: **Verify the Setup**

- ✅ **Logs**: Go to **CloudWatch > Logs > Log Groups**.
    
- ✅ **Metrics**: Go to **CloudWatch > Metrics > All metrics > CWAgent**.
    
- 🧪 Run `top`, `df -h`, or write logs to test.
    

---

### 🔁 Optional: Automate with User Data (Cloud Init)

If launching EC2 instances frequently, use this in EC2 **User Data**:

```bash
#!/bin/bash
yum install -y amazon-cloudwatch-agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  ... (your config here)
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
```

---

### 📊 Example Dashboard Metrics to Add:

- `mem_used_percent`
    
- `cpu_usage_user`
    
- `disk_used_percent`
    
- Log stream errors count
    

---
