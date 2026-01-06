
## 🧊 What is AWS Snow Family?

The **AWS Snow Family** is a set of **physical, rugged devices** designed for:

- **Offline data migration to AWS**
    
- **Edge computing** in disconnected or bandwidth-limited environments
    
- **Tactical deployments** in rugged or mobile scenarios
    

> ✅ Snow devices help **transfer terabytes to exabytes of data** securely and efficiently when using the internet isn’t feasible or practical.

---

## 🧬 Snow Family Devices Overview

|Device|Storage Capacity|Use Case|Ports / Power|
|---|---|---|---|
|**Snowcone**|8 TB usable|Edge computing, drones, vehicles|USB-C, battery-powered|
|**Snowball Edge**|42/80 TB usable|Bulk data transfer, local compute|RJ45, fiber, ruggedized|
|**Snowmobile**|Up to 100 PB|Data center migration|45-foot rugged truck|

---

### 📦 1. AWS Snowcone

- **Smallest form factor**
    
- Weighs ~4.5 lbs (~2.1 kg)
    
- Ideal for **tight spaces**, **mobile deployments**, or **military use**
    
- Supports **EC2, EBS, and AWS IoT Greengrass**
    

✅ Can be **battery-powered** or powered via **USB-C**  
✅ Supports **offline and online** data transfer via **AWS OpsHub**

---

### 📦 2. AWS Snowball Edge

Two variants:

|Variant|Storage (usable)|Compute?|Networking|
|---|---|---|---|
|**Storage Optimized**|~80 TB|Basic|1/10/25 GbE|
|**Compute Optimized**|~42 TB|Yes|GPU option available|

- Supports **EC2 AMIs**, **EBS**, **Lambda**, and **S3-compatible storage**
    
- Comes with **Amazon S3 Adapter**, **AWS OpsHub**, and **CLI**
    
- Often used for **disaster recovery, edge processing, machine learning**, or **shipboard computing**
    

---

### 📦 3. AWS Snowmobile

- 45-foot **ruggedized shipping container** on a truck
    
- Transfers up to **100 PB per job**
    
- Ideal for **massive data center migrations**
    
- Uses **tamper-resistant enclosures**, **GPS tracking**, **24/7 monitoring**
    

---

## 🔒 Security Features

|Feature|Description|
|---|---|
|**256-bit encryption**|All Snow devices encrypt data at rest|
|**KMS integration**|Keys managed via AWS Key Management Service|
|**Tamper resistance**|Snowball and Snowmobile detect physical tampering|
|**Secure Erasure**|Cryptographic erasure after data upload|

---

## 🧠 Use Cases

|Scenario|Why Snow Family?|
|---|---|
|🛳️ Shipboard or remote site data|Transfer data without internet|
|🚁 Tactical military edge compute|Secure, portable, rugged compute + storage|
|🌐 Slow or expensive internet|Cheaper and faster than uploading 100s of TB over net|
|💽 Data center shutdown/migration|Transfer 100 PB+ using Snowmobile|
|📉 Disaster recovery|Backup or restore from cloud to edge via Snowball|

---

## 🛠️ Workflow: How Snowball Data Transfer Works

1. **Create a job** in AWS Snow console
    
2. **AWS ships** a Snow device to you
    
3. You **copy data** to device using `aws snowball cp` or AWS OpsHub
    
4. **Ship it back** to AWS
    
5. AWS **ingests the data into S3**
    
6. Device is **securely wiped**
    

---

## 🔧 Tools for Working with Snow Devices

|Tool|Purpose|
|---|---|
|**AWS OpsHub**|GUI for managing Snowcone/Snowball|
|**Snowball CLI**|Local command-line utility for file transfers|
|**Amazon S3 Adapter**|Mount Snowball as S3-compatible interface|
|**SSH/EC2**|Run apps on-device (if compute optimized)|

---

## 📊 Pricing (as of 2024)

|Device|Pricing Basis|
|---|---|
|**Snowcone**|~$60 per job + $6/day usage|
|**Snowball Edge**|~$300/job + $30–60/day (varies)|
|**Snowmobile**|Custom pricing (~$0.005–0.01 per GB)|

🟨 Shipping charges are additional  
🟨 Data transfer into AWS is free; **outbound from AWS is charged**

---

## 🌍 Region Support

- Snow devices are available in **most AWS regions**
    
- Snowmobile is only available in **select large-scale enterprise regions**
    
- Check **[AWS Snowball region support](https://docs.aws.amazon.com/snowball/latest/developer-guide/what-is-snowball.html#snowball-region)**
    

---

## ✅ TL;DR Summary

|Feature|Snowcone|Snowball Edge|Snowmobile|
|---|---|---|---|
|Storage Capacity|~8 TB|42–80 TB|Up to 100 PB|
|Use Case|Small edge apps|Bulk ingest/compute|Data center migration|
|Portability|Handheld|Rugged suitcase|45-foot truck|
|Compute Support|Yes (EC2)|Yes (Lambda, EC2)|No|
|Security|✅ End-to-end encrypted, KMS managed|||
|Offline Upload|✅ Yes for all|||

---

## 🔄 Snow Family vs DataSync vs Transfer Appliance

|Feature|**Snow Family**|**AWS DataSync**|**AWS Transfer Family**|
|---|---|---|---|
|Connection|Offline + Online|Online (NFS, SMB, S3)|Online (FTP/SFTP)|
|Speed|High offline throughput|10 Gbps over internet|Up to 10K sessions|
|Use case|Massive or disconnected|Hybrid or medium-sized|SFTP server replacement|

---
