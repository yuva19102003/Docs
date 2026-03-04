# Pricing Models

Complete guide to understanding Google Cloud Platform pricing models, structures, and cost calculation methods.

---

## 📚 Overview

GCP uses a pay-as-you-go pricing model with various discount options and pricing structures. Understanding these models is essential for cost optimization and budget planning.

**Key Concepts:**
- **Pay-as-you-go**: No upfront costs, pay only for what you use
- **Per-second billing**: Most services billed by the second
- **Sustained Use Discounts**: Automatic discounts for consistent usage
- **Committed Use Discounts**: Save up to 57% with commitments
- **Free Tier**: Always-free and trial credits

---

## 💰 Core Pricing Principles

### 1. Pay-as-You-Go Model

```
┌────────────────────────────────────────────────────────┐
│  Pay-as-You-Go Benefits                                │
├────────────────────────────────────────────────────────┤
│                                                         │
│  No Upfront Costs:                                     │
│  • No capital expenditure                              │
│  • No minimum commitments (unless CUD)                 │
│  • Start small, scale as needed                        │
│                                                         │
│  Flexible Scaling:                                     │
│  • Scale up during peak times                          │
│  • Scale down during off-peak                          │
│  • Pay only for actual usage                           │
│                                                         │
│  Granular Billing:                                     │
│  • Per-second billing (most services)                  │
│  • No rounding to hours                                │
│  • Precise cost tracking                               │
│                                                         │
│  Example:                                              │
│  VM running for 10 minutes 30 seconds                  │
│  • Billed: 630 seconds                                 │
│  • Not rounded to 1 hour                               │
│  • Savings: ~83% vs hourly billing                     │
└────────────────────────────────────────────────────────┘
```

### 2. Per-Second Billing

```
┌────────────────────────────────────────────────────────┐
│  Per-Second Billing Example                            │
└────────────────────────────────────────────────────────┘

Scenario: n1-standard-4 VM
  • Hourly rate: $0.19
  • Per-second rate: $0.19 / 3600 = $0.0000528

Usage Patterns:

Pattern 1: Continuous (24/7)
  • 30 days × 24 hours = 720 hours
  • Cost: 720 × $0.19 = $136.80

Pattern 2: Business Hours (8 hours/day, 5 days/week)
  • 20 days × 8 hours = 160 hours
  • Cost: 160 × $0.19 = $30.40
  • Savings: $106.40 (78%)

Pattern 3: Batch Jobs (2 hours/day)
  • 30 days × 2 hours = 60 hours
  • Cost: 60 × $0.19 = $11.40
  • Savings: $125.40 (92%)

Pattern 4: Short Tasks (15 minutes each, 10x/day)
  • 30 days × 10 × 0.25 hours = 75 hours
  • Cost: 75 × $0.19 = $14.25
  • With hourly billing: 300 hours = $57.00
  • Savings with per-second: $42.75 (75%)
```

---

## 🎯 Discount Programs

### 1. Sustained Use Discounts (SUD)

```
┌────────────────────────────────────────────────────────┐
│  Sustained Use Discounts (Automatic)                   │
├────────────────────────────────────────────────────────┤
│                                                         │
│  How It Works:                                         │
│  • Automatic discounts for consistent usage            │
│  • No action required                                  │
│  • Up to 30% discount                                  │
│  • Applies to Compute Engine and GKE                   │
│                                                         │
│  Discount Tiers:                                       │
│  ┌──────────────────────────────────────┐             │
│  │ Usage %  │ Discount │ Effective Rate │             │
│  ├──────────────────────────────────────┤             │
│  │ 0-25%    │ 0%       │ 100%           │             │
│  │ 25-50%   │ 20%      │ 80%            │             │
│  │ 50-75%   │ 40%      │ 60%            │             │
│  │ 75-100%  │ 60%      │ 40%            │             │
│  └──────────────────────────────────────┘             │
│                                                         │
│  Example: VM running 24/7 for 30 days                  │
│  • Base cost: $136.80                                  │
│  • With SUD: $95.76 (30% savings)                      │
│  • Automatic - no commitment needed                    │
└────────────────────────────────────────────────────────┘
```

### 2. Committed Use Discounts (CUD)

```
┌────────────────────────────────────────────────────────┐
│  Committed Use Discounts                               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Spend-Based CUD:                                      │
│  • Commit to minimum spend amount                      │
│  • Flexible across machine types                       │
│  • 1-year: 25% discount                                │
│  • 3-year: 52% discount                                │
│                                                         │
│  Resource-Based CUD:                                   │
│  • Commit to specific vCPU and memory                  │
│  • Higher discounts                                    │
│  • 1-year: 37% discount                                │
│  • 3-year: 55% discount                                │
│                                                         │
│  Example: $10,000/month baseline usage                 │
│  ┌────────────────────────────────────┐               │
│  │ Option      │ Discount │ Monthly   │               │
│  ├────────────────────────────────────┤               │
│  │ No CUD      │ 0%       │ $10,000   │               │
│  │ 1-year CUD  │ 25%      │ $7,500    │               │
│  │ 3-year CUD  │ 52%      │ $4,800    │               │
│  └────────────────────────────────────┘               │
│                                                         │
│  Annual Savings (3-year CUD):                          │
│  • $5,200/month × 12 = $62,400/year                    │
└────────────────────────────────────────────────────────┘
```

### 3. Preemptible and Spot VMs

```
┌────────────────────────────────────────────────────────┐
│  Preemptible/Spot VM Pricing                           │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Discount: Up to 91% off on-demand pricing             │
│  Limitation: Can be terminated anytime                 │
│  Max Runtime: 24 hours                                 │
│                                                         │
│  Example: n1-standard-4                                │
│  • On-demand: $0.19/hour                               │
│  • Spot VM: $0.04/hour                                 │
│  • Savings: $0.15/hour (79%)                           │
│                                                         │
│  Monthly Comparison (24/7):                            │
│  • On-demand: $136.80                                  │
│  • Spot VM: $28.80                                     │
│  • Savings: $108.00 (79%)                              │
│                                                         │
│  Best For:                                             │
│  ✓ Batch processing                                    │
│  ✓ Data analysis                                       │
│  ✓ CI/CD workloads                                     │
│  ✓ Fault-tolerant apps                                 │
└────────────────────────────────────────────────────────┘
```

---

## 💾 Service-Specific Pricing

### 1. Compute Engine

```
┌────────────────────────────────────────────────────────┐
│  Compute Engine Pricing Components                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  VM Instance:                                          │
│  • Machine type (vCPU + memory)                        │
│  • Per-second billing (1 min minimum)                  │
│  • Varies by region                                    │
│  • Example: n1-standard-4 = $0.19/hour                 │
│                                                         │
│  Persistent Disk:                                      │
│  • Standard (HDD): $0.040/GB/month                     │
│  • Balanced (SSD): $0.100/GB/month                     │
│  • SSD: $0.170/GB/month                                │
│  • Snapshots: $0.026/GB/month                          │
│                                                         │
│  Network:                                              │
│  • Ingress: Free                                       │
│  • Egress (internet): $0.12/GB (first 1GB free)        │
│  • Egress (same zone): Free                            │
│  • External IP: $0.004/hour (static)                   │
│                                                         │
│  Example Monthly Cost:                                 │
│  • n1-standard-4 (24/7): $136.80                       │
│  • 100 GB SSD disk: $17.00                             │
│  • 1 TB egress: $120.00                                │
│  • Static IP: $2.88                                    │
│  Total: $276.68/month                                  │
└────────────────────────────────────────────────────────┘
```

### 2. Cloud Storage

```
┌────────────────────────────────────────────────────────┐
│  Cloud Storage Pricing                                 │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Storage Classes (per GB/month):                       │
│  • Standard: $0.020                                    │
│  • Nearline: $0.010 (30-day minimum)                   │
│  • Coldline: $0.004 (90-day minimum)                   │
│  • Archive: $0.0012 (365-day minimum)                  │
│                                                         │
│  Operations (per 10,000):                              │
│  • Class A (writes): $0.05                             │
│  • Class B (reads): $0.004                             │
│                                                         │
│  Network (per GB):                                     │
│  • Ingress: Free                                       │
│  • Egress (internet): $0.12                            │
│  • Egress (same region): Free                          │
│                                                         │
│  Retrieval (per GB):                                   │
│  • Standard: Free                                      │
│  • Nearline: $0.01                                     │
│  • Coldline: $0.02                                     │
│  • Archive: $0.05                                      │
│                                                         │
│  Example: 1 TB for 1 year                              │
│  • Standard: $240                                      │
│  • Nearline: $120 (50% savings)                        │
│  • Coldline: $48 (80% savings)                         │
│  • Archive: $14.40 (94% savings)                       │
└────────────────────────────────────────────────────────┘
```

### 3. BigQuery

```
┌────────────────────────────────────────────────────────┐
│  BigQuery Pricing                                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Storage:                                              │
│  • Active: $0.020/GB/month                             │
│  • Long-term (90+ days): $0.010/GB/month               │
│                                                         │
│  Analysis (On-Demand):                                 │
│  • $5.00 per TB processed                              │
│  • First 1 TB/month: Free                              │
│  • Charged per query                                   │
│                                                         │
│  Analysis (Flat-Rate):                                 │
│  • 100 slots: $2,000/month                             │
│  • 500 slots: $10,000/month                            │
│  • Predictable costs                                   │
│                                                         │
│  Streaming Inserts:                                    │
│  • $0.010 per 200 MB                                   │
│                                                         │
│  Example Monthly Cost:                                 │
│  • 10 TB storage: $200                                 │
│  • 5 TB queries: $20 (1 TB free)                       │
│  • 100 GB streaming: $5                                │
│  Total: $225/month                                     │
└────────────────────────────────────────────────────────┘
```

### 4. Cloud SQL

```
┌────────────────────────────────────────────────────────┐
│  Cloud SQL Pricing                                     │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Instance (MySQL/PostgreSQL):                          │
│  • db-n1-standard-1: $0.0575/hour ($41.40/month)       │
│  • db-n1-standard-2: $0.115/hour ($82.80/month)        │
│  • db-n1-standard-4: $0.23/hour ($165.60/month)        │
│                                                         │
│  Storage:                                              │
│  • SSD: $0.17/GB/month                                 │
│  • HDD: $0.09/GB/month                                 │
│                                                         │
│  Backups:                                              │
│  • $0.08/GB/month                                      │
│                                                         │
│  Network:                                              │
│  • Egress: $0.12/GB                                    │
│                                                         │
│  Example Monthly Cost:                                 │
│  • db-n1-standard-2: $82.80                            │
│  • 100 GB SSD: $17.00                                  │
│  • 50 GB backups: $4.00                                │
│  Total: $103.80/month                                  │
└────────────────────────────────────────────────────────┘
```

---

## 🌍 Regional Pricing

### Regional Price Differences

```
┌────────────────────────────────────────────────────────┐
│  Regional Pricing Example: n1-standard-4               │
├────────────────────────────────────────────────────────┤
│                                                         │
│  US Regions:                                           │
│  • us-central1 (Iowa): $0.19/hour                      │
│  • us-east1 (S. Carolina): $0.19/hour                  │
│  • us-west1 (Oregon): $0.19/hour                       │
│                                                         │
│  Europe Regions:                                       │
│  • europe-west1 (Belgium): $0.21/hour (+11%)           │
│  • europe-west2 (London): $0.23/hour (+21%)            │
│  • europe-north1 (Finland): $0.19/hour                 │
│                                                         │
│  Asia Regions:                                         │
│  • asia-southeast1 (Singapore): $0.22/hour (+16%)      │
│  • asia-northeast1 (Tokyo): $0.23/hour (+21%)          │
│  • asia-south1 (Mumbai): $0.20/hour (+5%)              │
│                                                         │
│  Factors Affecting Regional Pricing:                   │
│  • Energy costs                                        │
│  • Real estate costs                                   │
│  • Network infrastructure                              │
│  • Local regulations                                   │
│  • Market conditions                                   │
└────────────────────────────────────────────────────────┘
```

---

## 🆓 Free Tier

### 1. Always Free Products

```
┌────────────────────────────────────────────────────────┐
│  Always Free Tier (No Expiration)                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Compute Engine:                                       │
│  • 1 f1-micro VM instance/month (US regions)           │
│  • 30 GB standard persistent disk                      │
│  • 5 GB snapshot storage                               │
│  • 1 GB network egress (North America)                 │
│                                                         │
│  Cloud Storage:                                        │
│  • 5 GB standard storage                               │
│  • 5,000 Class A operations/month                      │
│  • 50,000 Class B operations/month                     │
│  • 1 GB network egress                                 │
│                                                         │
│  BigQuery:                                             │
│  • 10 GB storage                                       │
│  • 1 TB queries/month                                  │
│                                                         │
│  Cloud Functions:                                      │
│  • 2 million invocations/month                         │
│  • 400,000 GB-seconds compute time                     │
│  • 200,000 GHz-seconds compute time                    │
│  • 5 GB network egress                                 │
│                                                         │
│  Cloud Run:                                            │
│  • 2 million requests/month                            │
│  • 360,000 GB-seconds memory                           │
│  • 180,000 vCPU-seconds                                │
│  • 1 GB network egress                                 │
└────────────────────────────────────────────────────────┘
```

### 2. Trial Credits

```
┌────────────────────────────────────────────────────────┐
│  $300 Free Trial (New Customers)                       │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Benefits:                                             │
│  • $300 credit                                         │
│  • Valid for 90 days                                   │
│  • No automatic charges after trial                    │
│  • Access to all GCP services                          │
│                                                         │
│  Limitations:                                          │
│  • One per billing account                             │
│  • Cannot be used for:                                 │
│    - Cryptocurrency mining                             │
│    - Certain high-cost services                        │
│  • Some quotas may be limited                          │
│                                                         │
│  After Trial:                                          │
│  • Upgrade to paid account                             │
│  • Keep always-free tier benefits                      │
│  • No automatic charges                                │
│  • Explicit upgrade required                           │
└────────────────────────────────────────────────────────┘
```

---

## 🧮 Pricing Calculator

### Using the Pricing Calculator

```
URL: https://cloud.google.com/products/calculator

Steps:
1. Select services to estimate
2. Configure each service:
   • Instance type/size
   • Region
   • Usage hours
   • Storage amount
   • Network egress
3. Add discounts (CUD, SUD)
4. Review total estimate
5. Save or share estimate

Example Estimate:
┌────────────────────────────────────────┐
│ Service          │ Monthly Cost        │
├────────────────────────────────────────┤
│ Compute Engine   │ $136.80             │
│ Cloud Storage    │ $20.00              │
│ Cloud SQL        │ $103.80             │
│ Network Egress   │ $120.00             │
│ Load Balancing   │ $18.00              │
├────────────────────────────────────────┤
│ Subtotal         │ $398.60             │
│ CUD (25%)        │ -$99.65             │
├────────────────────────────────────────┤
│ Total            │ $298.95/month       │
└────────────────────────────────────────┘
```

---

## 📊 Cost Optimization Tips

```
✓ Use appropriate machine types (don't over-provision)
✓ Leverage sustained use discounts (automatic)
✓ Purchase committed use discounts for predictable workloads
✓ Use preemptible/spot VMs for fault-tolerant workloads
✓ Choose appropriate storage classes
✓ Implement lifecycle policies for storage
✓ Optimize network egress (use CDN, keep traffic in region)
✓ Right-size resources regularly
✓ Delete unused resources
✓ Use labels for cost tracking
✓ Monitor and alert on spending
✓ Review Recommender suggestions
```

---

## 🎓 Next Steps

1. Implement [Cost Allocation](./7-Cost-Allocation.md) strategies
2. Follow [Best Practices](./8-Best-Practices.md) for cost management
3. Review [Cost Optimization](./4-Cost-Optimization.md) techniques
4. Use [Recommender](./5-Recommender.md) for AI-powered insights

---

**Last Updated:** March 2026
**Version:** 2.0
