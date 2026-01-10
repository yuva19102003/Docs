# DigitalOcean GPU Droplets Overview

## Introduction

GPU Droplets are virtual machines equipped with dedicated NVIDIA GPUs, designed for compute-intensive workloads like machine learning, AI training, video processing, and scientific computing. They provide high-performance GPU acceleration in the cloud.

## Key Features

- **NVIDIA GPUs**: H100, A100, RTX 6000 Ada
- **High Performance**: Optimized for ML/AI workloads
- **Flexible Sizing**: Multiple GPU configurations
- **Pre-installed Drivers**: CUDA, cuDNN ready
- **Docker Support**: GPU-enabled containers
- **Jupyter Notebooks**: Pre-configured environments
- **Hourly Billing**: Pay only for what you use
- **Fast Networking**: High-bandwidth connections
- **Persistent Storage**: Block storage volumes
- **Snapshots**: Save GPU configurations


## GPU Droplet Types

### H100 GPU Droplets (Latest)
```
NVIDIA H100 80GB
├─> 80 GB HBM3 memory
├─> 3.35 TB/s memory bandwidth
├─> 4th Gen Tensor Cores
├─> Best for: Large language models, training

Configurations:
├─> 1x H100: $3.89/hour (~$2,800/month)
├─> 2x H100: $7.78/hour (~$5,600/month)
├─> 4x H100: $15.56/hour (~$11,200/month)
└─> 8x H100: $31.12/hour (~$22,400/month)
```

### A100 GPU Droplets
```
NVIDIA A100 40GB/80GB
├─> 40 GB or 80 GB HBM2e memory
├─> 1.6 TB/s memory bandwidth
├─> 3rd Gen Tensor Cores
├─> Best for: Deep learning, HPC

Configurations:
├─> 1x A100 40GB: $2.38/hour (~$1,714/month)
├─> 2x A100 40GB: $4.76/hour (~$3,428/month)
├─> 1x A100 80GB: $3.21/hour (~$2,312/month)
└─> 2x A100 80GB: $6.42/hour (~$4,624/month)
```

### RTX 6000 Ada GPU Droplets
```
NVIDIA RTX 6000 Ada
├─> 48 GB GDDR6 memory
├─> 4th Gen Tensor Cores
├─> Ray tracing support
├─> Best for: Rendering, visualization

Configurations:
├─> 1x RTX 6000: $1.79/hour (~$1,290/month)
└─> 2x RTX 6000: $3.58/hour (~$2,580/month)
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GPU Droplet                               │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Operating System (Ubuntu 22.04 LTS)                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  NVIDIA Drivers & CUDA Toolkit                         │ │
│  │  ├─> CUDA 12.x                                         │ │
│  │  ├─> cuDNN 8.x                                         │ │
│  │  └─> NVIDIA Container Toolkit                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  GPU Hardware                                          │ │
│  │  ├─> NVIDIA H100 / A100 / RTX 6000                    │ │
│  │  ├─> Tensor Cores                                      │ │
│  │  ├─> CUDA Cores                                        │ │
│  │  └─> High-bandwidth memory                             │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Resources:                                                 │
│  ├─> vCPU: 8-96 cores                                      │
│  ├─> RAM: 64-768 GB                                        │
│  ├─> Storage: 200-1,000 GB NVMe SSD                       │
│  └─> Network: 10-25 Gbps                                   │
└─────────────────────────────────────────────────────────────┘
```

## Use Cases

### 1. Machine Learning Training
```
Deep Learning:
├─> Neural network training
├─> Large language models (LLMs)
├─> Computer vision models
├─> Natural language processing
└─> Reinforcement learning

Frameworks:
├─> PyTorch
├─> TensorFlow
├─> JAX
├─> MXNet
└─> Keras
```

### 2. AI Inference
```
Model Serving:
├─> Real-time predictions
├─> Batch inference
├─> Model optimization
└─> Edge deployment testing

Tools:
├─> NVIDIA Triton
├─> TensorRT
├─> ONNX Runtime
└─> TorchServe
```

### 3. Data Science
```
Analytics:
├─> Large dataset processing
├─> Feature engineering
├─> Model experimentation
└─> Hyperparameter tuning

Tools:
├─> RAPIDS (GPU-accelerated pandas)
├─> cuDF
├─> cuML
└─> Dask
```

### 4. Video Processing
```
Media Workloads:
├─> Video transcoding
├─> Real-time streaming
├─> Video analysis
└─> Effects rendering

Tools:
├─> FFmpeg with NVENC
├─> GStreamer
├─> OpenCV
└─> NVIDIA Video Codec SDK
```

### 5. Scientific Computing
```
HPC Workloads:
├─> Molecular dynamics
├─> Climate modeling
├─> Computational fluid dynamics
└─> Quantum simulations

Tools:
├─> GROMACS
├─> LAMMPS
├─> OpenFOAM
└─> Quantum ESPRESSO
```

## Pre-installed Software

### NVIDIA Stack
```
Drivers & Libraries:
├─> NVIDIA Driver 535+
├─> CUDA Toolkit 12.x
├─> cuDNN 8.x
├─> NCCL (multi-GPU communication)
├─> TensorRT (inference optimization)
└─> NVIDIA Container Toolkit
```

### ML Frameworks
```
Python Packages:
├─> PyTorch 2.x
├─> TensorFlow 2.x
├─> JAX
├─> Transformers (Hugging Face)
├─> scikit-learn
└─> NumPy, Pandas
```

### Development Tools
```
IDEs & Notebooks:
├─> Jupyter Lab
├─> VS Code Server
├─> Docker
└─> Git
```

## Quick Start

### Create GPU Droplet
```bash
# Install doctl
brew install doctl

# Authenticate
doctl auth init

# List available GPU sizes
doctl compute size list | grep gpu

# Create GPU Droplet
doctl compute droplet create ml-gpu-01 \
  --region nyc3 \
  --size gpu-h100x1-80gb \
  --image gpu-h100-base \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header) \
  --wait

# Get IP address
doctl compute droplet list --format Name,PublicIPv4

# SSH into Droplet
ssh root@<droplet-ip>
```

### Verify GPU
```bash
# Check NVIDIA driver
nvidia-smi

# Check CUDA version
nvcc --version

# Test PyTorch GPU
python3 << EOF
import torch
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU count: {torch.cuda.device_count()}")
print(f"GPU name: {torch.cuda.get_device_name(0)}")
EOF
```

## Performance Optimization

### 1. Multi-GPU Training
```python
# PyTorch DataParallel
import torch
import torch.nn as nn

model = MyModel()
if torch.cuda.device_count() > 1:
    model = nn.DataParallel(model)
model = model.cuda()

# PyTorch DistributedDataParallel (recommended)
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel

dist.init_process_group(backend='nccl')
model = MyModel().cuda()
model = DistributedDataParallel(model)
```

### 2. Mixed Precision Training
```python
# PyTorch AMP
from torch.cuda.amp import autocast, GradScaler

scaler = GradScaler()

for data, target in dataloader:
    optimizer.zero_grad()
    
    with autocast():
        output = model(data)
        loss = criterion(output, target)
    
    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()
```

### 3. Memory Optimization
```python
# Gradient checkpointing
from torch.utils.checkpoint import checkpoint

def forward(self, x):
    x = checkpoint(self.layer1, x)
    x = checkpoint(self.layer2, x)
    return x

# Clear cache
torch.cuda.empty_cache()

# Monitor memory
print(torch.cuda.memory_summary())
```

## Best Practices

### 1. Cost Optimization
```
Strategies:
├─> Use snapshots for long-term storage
├─> Power off when not training
├─> Use smaller GPUs for development
├─> Batch multiple experiments
└─> Monitor GPU utilization

Tips:
├─> Destroy Droplet after training
├─> Save models to Spaces
├─> Use spot instances (when available)
└─> Schedule training jobs
```

### 2. Performance
```
Optimization:
├─> Use mixed precision training
├─> Enable TensorFloat-32 (TF32)
├─> Optimize data loading
├─> Use gradient accumulation
└─> Profile GPU usage

Tools:
├─> NVIDIA Nsight Systems
├─> PyTorch Profiler
├─> TensorBoard
└─> nvidia-smi
```

### 3. Data Management
```
Storage:
├─> Use Block Storage for datasets
├─> Store models in Spaces
├─> Use fast local NVMe for training
└─> Implement data caching

Transfer:
├─> Compress datasets
├─> Use parallel downloads
├─> Cache preprocessed data
└─> Use data loaders efficiently
```

## Monitoring

### GPU Metrics
```bash
# Real-time monitoring
nvidia-smi -l 1

# Detailed stats
nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free --format=csv -l 1

# Process monitoring
nvidia-smi pmon -i 0

# Install monitoring tools
pip install gpustat
gpustat -i 1
```

### System Monitoring
```bash
# CPU and memory
htop

# Disk I/O
iotop

# Network
iftop

# All-in-one
pip install nvitop
nvitop
```

## Common Workflows

### Training Workflow
```bash
# 1. Create GPU Droplet
doctl compute droplet create training-job \
  --size gpu-h100x1-80gb \
  --image gpu-h100-base

# 2. Upload dataset
scp -r dataset/ root@<ip>:/data/

# 3. Run training
ssh root@<ip> << 'EOF'
cd /workspace
python train.py --epochs 100 --batch-size 32
EOF

# 4. Download model
scp root@<ip>:/workspace/model.pth ./

# 5. Destroy Droplet
doctl compute droplet delete training-job
```

### Jupyter Notebook Workflow
```bash
# 1. Create GPU Droplet with Jupyter
doctl compute droplet create jupyter-gpu \
  --size gpu-a100x1-80gb \
  --image gpu-a100-base

# 2. SSH tunnel
ssh -L 8888:localhost:8888 root@<ip>

# 3. Start Jupyter
jupyter lab --ip=0.0.0.0 --allow-root

# 4. Access in browser
# http://localhost:8888
```

## Troubleshooting

### GPU Not Detected
```bash
# Check driver
nvidia-smi

# Reinstall driver if needed
sudo apt-get update
sudo apt-get install --reinstall nvidia-driver-535

# Reboot
sudo reboot
```

### Out of Memory
```python
# Reduce batch size
batch_size = 16  # Try smaller

# Enable gradient checkpointing
model.gradient_checkpointing_enable()

# Clear cache
torch.cuda.empty_cache()

# Use CPU offloading
model = model.cpu()
```

### Slow Training
```bash
# Check GPU utilization
nvidia-smi

# Profile code
python -m torch.utils.bottleneck train.py

# Check data loading
# Increase num_workers in DataLoader
```

## Pricing Comparison

| GPU | Memory | Price/Hour | Best For |
|-----|--------|------------|----------|
| **H100** | 80 GB | $3.89 | Large models, LLMs |
| **A100 80GB** | 80 GB | $3.21 | Deep learning, HPC |
| **A100 40GB** | 40 GB | $2.38 | ML training |
| **RTX 6000** | 48 GB | $1.79 | Rendering, viz |

## Documentation Structure

1. **[GPU Droplets Overview](./0-GPU-DROPLETS-OVERVIEW.md)** - This page
2. **[Creating GPU Droplets](./1-CREATING-GPU-DROPLETS.md)** - Setup guide
3. **[ML Workflows](./2-ML-WORKFLOWS.md)** - Training and inference
4. **[Performance Tuning](./3-PERFORMANCE-TUNING.md)** - Optimization

## Next Steps

- [Create your first GPU Droplet](./1-CREATING-GPU-DROPLETS.md)
- [Learn ML workflows](./2-ML-WORKFLOWS.md)
- [Optimize performance](./3-PERFORMANCE-TUNING.md)
