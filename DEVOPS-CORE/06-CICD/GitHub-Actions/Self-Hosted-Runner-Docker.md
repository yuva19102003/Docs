# Self-Hosted GitHub Actions Runner - Docker Setup

Complete guide to running GitHub Actions runners in Docker containers with various configurations.

## Docker Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Docker-Based Runner Architecture                     │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                         GitHub                                │
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   Workflow   │────────>│  Job Queue   │                  │
│  │   Trigger    │         │              │                  │
│  └──────────────┘         └──────┬───────┘                  │
└─────────────────────────────────┼───────────────────────────┘
                                  │
                                  │ HTTPS
                                  │
┌─────────────────────────────────┼───────────────────────────┐
│                    Docker Host  │                           │
│                                 ▼                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Docker Engine                            │  │
│  └────────────────────────┬─────────────────────────────┘  │
│                           │                                │
│         ┌─────────────────┼─────────────────┐             │
│         │                 │                 │             │
│         ▼                 ▼                 ▼             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │  Runner     │  │  Runner     │  │  Runner     │      │
│  │Container 1  │  │Container 2  │  │Container N  │      │
│  │             │  │             │  │             │      │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │      │
│  │ │ Runner  │ │  │ │ Runner  │ │  │ │ Runner  │ │      │
│  │ │ Process │ │  │ │ Process │ │  │ │ Process │ │      │
│  │ └────┬────┘ │  │ └────┬────┘ │  │ └────┬────┘ │      │
│  │      │      │  │      │      │  │      │      │      │
│  │ ┌────▼────┐ │  │ ┌────▼────┐ │  │ ┌────▼────┐ │      │
│  │ │  Work   │ │  │ │  Work   │ │  │ │  Work   │ │      │
│  │ │   Dir   │ │  │ │   Dir   │ │  │ │   Dir   │ │      │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │      │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │
│         │                │                │             │
│         └────────────────┴────────────────┘             │
│                          │                              │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Shared Resources                        │  │
│  │                                                   │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────┐ │  │
│  │  │Docker Socket │  │   Volumes    │  │Network │ │  │
│  │  │              │  │              │  │        │ │  │
│  │  │/var/run/     │  │  • runner-1  │  │ bridge │ │  │
│  │  │docker.sock   │  │  • runner-2  │  │        │ │  │
│  │  └──────────────┘  └──────────────┘  └────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Docker-in-Docker Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Docker-in-Docker (DinD) Setup                        │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      Host System                              │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Docker Engine (Host)                       │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  Runner Container                             │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Runner Process                                │  │
│  │                                                         │  │
│  │  • Receives jobs from GitHub                           │  │
│  │  • Executes workflow steps                             │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│                           ▼                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Docker Client                                 │  │
│  │                                                         │  │
│  │  • Sends build commands                                │  │
│  │  • Manages containers                                  │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │ TCP/Unix Socket
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  DinD Container                               │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Docker Daemon                                 │  │
│  │                                                         │  │
│  │  • Builds images                                       │  │
│  │  • Runs containers                                     │  │
│  │  • Manages volumes                                     │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                           │                                  │
│                           ▼                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           Build Context                                 │  │
│  │                                                         │  │
│  │  • Source code                                         │  │
│  │  • Dockerfile                                          │  │
│  │  • Dependencies                                        │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  Build Image    │
                   │  Run Tests      │
                   │  Push Image     │
                   └─────────────────┘
```

## Docker Compose Multi-Runner Setup

```
┌────────────────────────────────────────────────────────────────────────┐
│              Docker Compose Multi-Runner Architecture                   │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                  docker-compose.yml                           │
│                                                               │
│  services:                                                    │
│    - runner-prod-1                                           │
│    - runner-prod-2                                           │
│    - runner-staging-1                                        │
│    - runner-dev-1                                            │
└────────────────────────┬─────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┬───────────────┐
         │               │               │               │
         ▼               ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Production     │ │  Production     │ │   Staging       │ │  Development    │
│   Runner 1      │ │   Runner 2      │ │   Runner 1      │ │   Runner 1      │
│                 │ │                 │ │                 │ │                 │
│ Labels:         │ │ Labels:         │ │ Labels:         │ │ Labels:         │
│ • self-hosted   │ │ • self-hosted   │ │ • self-hosted   │ │ • self-hosted   │
│ • docker        │ │ • docker        │ │ • docker        │ │ • docker        │
│ • production    │ │ • production    │ │ • staging       │ │ • development   │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │                   │
         └───────────────────┴───────────────────┴───────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────┐
│                    Shared Services                            │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Docker Socket │  │   Volumes    │  │   Network    │      │
│  │              │  │              │  │              │      │
│  │  Shared by   │  │  • runner-1  │  │  • bridge    │      │
│  │  all runners │  │  • runner-2  │  │  • isolated  │      │
│  │              │  │  • runner-3  │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Table of Contents
    end
    
    subgraph "Production Runners"
        B1[Runner 1]
        B2[Runner 2]
        B3[Runner 3]
    end
    
    subgraph "Staging Runners"
        C1[Runner 4]
        C2[Runner 5]
    end
    
    subgraph "Development Runners"
        D1[Runner 6]
    end
    
    subgraph "Shared Services"
        E[Docker Socket]
        F[Volumes]
        G[Network]
    end
    
    A --> B1
    A --> B2
    A --> B3
    A --> C1
    A --> C2
    A --> D1
    
    B1 --> E
    B2 --> E
    B3 --> E
    C1 --> E
    C2 --> E
    D1 --> E
    
    B1 --> F
    C1 --> F
    D1 --> F
    
    style A fill:#e3f2fd
    style B1 fill:#c8e6c9
    style C1 fill:#fff9c4
    style D1 fill:#e1bee7
```

## Table of Contents
- [Basic Docker Setup](#basic-docker-setup)
- [Docker Compose Setup](#docker-compose-setup)
- [Custom Docker Images](#custom-docker-images)
- [Docker-in-Docker (DinD)](#docker-in-docker-dind)
- [Scaling with Docker](#scaling-with-docker)
- [Security Considerations](#security-considerations)
- [Advanced Configurations](#advanced-configurations)

## Basic Docker Setup

### Quick Start with Official Image

```bash
# Pull the official runner image
docker pull myoung34/github-runner:latest

# Run a single runner
docker run -d \
  --name github-runner \
  --restart unless-stopped \
  -e REPO_URL="https://github.com/YOUR_ORG/YOUR_REPO" \
  -e RUNNER_TOKEN="YOUR_TOKEN" \
  -e RUNNER_NAME="docker-runner-01" \
  -e RUNNER_WORKDIR="/tmp/runner/work" \
  -e LABELS="self-hosted,docker,linux" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/runner:/tmp/runner \
  myoung34/github-runner:latest
```

### Using Environment File

Create `.env` file:

```bash
REPO_URL=https://github.com/YOUR_ORG/YOUR_REPO
RUNNER_TOKEN=YOUR_TOKEN
RUNNER_NAME=docker-runner-01
RUNNER_WORKDIR=/tmp/runner/work
LABELS=self-hosted,docker,linux,x64
RUNNER_GROUP=default
```

Run with env file:

```bash
docker run -d \
  --name github-runner \
  --restart unless-stopped \
  --env-file .env \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/runner:/tmp/runner \
  myoung34/github-runner:latest
```

## Docker Compose Setup

### Basic Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      RUNNER_NAME: docker-runner-01
      RUNNER_WORKDIR: /tmp/runner/work
      LABELS: self-hosted,docker,linux,x64
      RUNNER_GROUP: default
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-data:/tmp/runner
    networks:
      - runner-network

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

Run:
```bash
docker-compose up -d
```

### Multiple Runners with Docker Compose

```yaml
version: '3.8'

services:
  runner-1:
    image: myoung34/github-runner:latest
    container_name: github-runner-1
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN_1}
      RUNNER_NAME: docker-runner-01
      LABELS: self-hosted,docker,linux,x64,production
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-1-data:/tmp/runner
    networks:
      - runner-network
  
  runner-2:
    image: myoung34/github-runner:latest
    container_name: github-runner-2
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN_2}
      RUNNER_NAME: docker-runner-02
      LABELS: self-hosted,docker,linux,x64,staging
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-2-data:/tmp/runner
    networks:
      - runner-network
  
  runner-3:
    image: myoung34/github-runner:latest
    container_name: github-runner-3
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN_3}
      RUNNER_NAME: docker-runner-03
      LABELS: self-hosted,docker,linux,x64,development
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-3-data:/tmp/runner
    networks:
      - runner-network

volumes:
  runner-1-data:
  runner-2-data:
  runner-3-data:

networks:
  runner-network:
    driver: bridge
```

### Docker Compose with Resource Limits

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      RUNNER_NAME: docker-runner-01
      LABELS: self-hosted,docker,linux
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-data:/tmp/runner
    networks:
      - runner-network
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

## Custom Docker Images

### Dockerfile for Custom Runner

Create `Dockerfile`:

```dockerfile
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install additional tools
RUN npm install -g yarn pnpm
RUN pip3 install --no-cache-dir awscli

# Create runner user
RUN useradd -m -s /bin/bash runner

# Set working directory
WORKDIR /home/runner

# Download and extract GitHub Actions runner
ARG RUNNER_VERSION=2.311.0
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN ./bin/installdependencies.sh

# Change ownership
RUN chown -R runner:runner /home/runner

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]
```

Create `entrypoint.sh`:

```bash
#!/bin/bash

set -e

# Configuration
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_WORKDIR=${RUNNER_WORKDIR:-_work}
RUNNER_GROUP=${RUNNER_GROUP:-default}
LABELS=${LABELS:-self-hosted,docker,linux}

# Register runner
./config.sh \
    --url "${REPO_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "${LABELS}" \
    --runnergroup "${RUNNER_GROUP}" \
    --unattended \
    --replace

# Cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "${RUNNER_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the runner
./run.sh & wait $!
```

Build and run:

```bash
# Build image
docker build -t custom-github-runner:latest .

# Run container
docker run -d \
  --name custom-runner \
  --restart unless-stopped \
  -e REPO_URL="https://github.com/YOUR_ORG/YOUR_REPO" \
  -e RUNNER_TOKEN="YOUR_TOKEN" \
  -e RUNNER_NAME="custom-runner-01" \
  -e LABELS="self-hosted,docker,custom" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  custom-github-runner:latest
```

### Multi-Stage Dockerfile with Tools

```dockerfile
# Stage 1: Base
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git jq ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Node.js
FROM base AS nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn pnpm

# Stage 3: Python
FROM nodejs AS python
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    && pip3 install --no-cache-dir pipenv poetry

# Stage 4: Go
FROM python AS golang
ARG GO_VERSION=1.22.0
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Stage 5: Docker
FROM golang AS docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin

# Stage 6: Cloud CLIs
FROM docker AS cloud-tools
# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-sdk

# Stage 7: Runner
FROM cloud-tools AS runner

# Create runner user
RUN useradd -m -s /bin/bash runner

WORKDIR /home/runner

# Download GitHub Actions runner
ARG RUNNER_VERSION=2.311.0
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh

RUN chown -R runner:runner /home/runner

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]
```

## Docker-in-Docker (DinD)

### DinD with Privileged Mode

```yaml
version: '3.8'

services:
  github-runner-dind:
    image: myoung34/github-runner:latest
    container_name: github-runner-dind
    restart: unless-stopped
    privileged: true
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      RUNNER_NAME: dind-runner-01
      LABELS: self-hosted,docker,dind
      DOCKER_ENABLED: "true"
    volumes:
      - runner-dind-data:/tmp/runner
      - /var/lib/docker
    networks:
      - runner-network

volumes:
  runner-dind-data:

networks:
  runner-network:
    driver: bridge
```

### DinD with Sidecar Container

```yaml
version: '3.8'

services:
  docker-daemon:
    image: docker:24-dind
    container_name: docker-daemon
    privileged: true
    restart: unless-stopped
    environment:
      DOCKER_TLS_CERTDIR: ""
    volumes:
      - docker-data:/var/lib/docker
    networks:
      - runner-network
    command: ["dockerd", "--host=tcp://0.0.0.0:2375"]
  
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    depends_on:
      - docker-daemon
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      RUNNER_NAME: dind-sidecar-runner
      LABELS: self-hosted,docker,dind-sidecar
      DOCKER_HOST: tcp://docker-daemon:2375
    volumes:
      - runner-data:/tmp/runner
    networks:
      - runner-network

volumes:
  docker-data:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

## Scaling with Docker

### Docker Swarm Setup

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    deploy:
      mode: replicated
      replicas: 5
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      LABELS: self-hosted,docker,swarm
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - runner-network

networks:
  runner-network:
    driver: overlay
```

Deploy:
```bash
docker stack deploy -c docker-compose.yml github-runners
```

### Auto-Scaling Script

Create `scale-runners.sh`:

```bash
#!/bin/bash

# Configuration
MIN_RUNNERS=2
MAX_RUNNERS=10
QUEUE_THRESHOLD=5

# Get queued jobs count (requires GitHub API token)
QUEUED_JOBS=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?status=queued" \
  | jq '.workflow_runs | length')

# Get current runner count
CURRENT_RUNNERS=$(docker ps --filter "name=github-runner" --format "{{.Names}}" | wc -l)

echo "Queued jobs: $QUEUED_JOBS"
echo "Current runners: $CURRENT_RUNNERS"

# Scale up
if [ $QUEUED_JOBS -gt $QUEUE_THRESHOLD ] && [ $CURRENT_RUNNERS -lt $MAX_RUNNERS ]; then
  NEW_RUNNERS=$((CURRENT_RUNNERS + 2))
  if [ $NEW_RUNNERS -gt $MAX_RUNNERS ]; then
    NEW_RUNNERS=$MAX_RUNNERS
  fi
  echo "Scaling up to $NEW_RUNNERS runners"
  docker-compose up -d --scale github-runner=$NEW_RUNNERS
fi

# Scale down
if [ $QUEUED_JOBS -eq 0 ] && [ $CURRENT_RUNNERS -gt $MIN_RUNNERS ]; then
  NEW_RUNNERS=$((CURRENT_RUNNERS - 1))
  if [ $NEW_RUNNERS -lt $MIN_RUNNERS ]; then
    NEW_RUNNERS=$MIN_RUNNERS
  fi
  echo "Scaling down to $NEW_RUNNERS runners"
  docker-compose up -d --scale github-runner=$NEW_RUNNERS
fi
```

Schedule with cron:
```cron
*/5 * * * * /path/to/scale-runners.sh
```

## Security Considerations

### Rootless Docker

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    user: "1000:1000"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
      RUNNER_NAME: rootless-runner
    volumes:
      - runner-data:/tmp/runner
    networks:
      - runner-network

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

### Network Isolation

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
    volumes:
      - runner-data:/tmp/runner
    networks:
      - runner-internal
      - runner-external
    dns:
      - 8.8.8.8
      - 8.8.4.4

volumes:
  runner-data:

networks:
  runner-internal:
    driver: bridge
    internal: true
  runner-external:
    driver: bridge
```

### Secrets Management

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN_FILE: /run/secrets/runner_token
    secrets:
      - runner_token
    volumes:
      - runner-data:/tmp/runner
    networks:
      - runner-network

secrets:
  runner_token:
    external: true

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

Create secret:
```bash
echo "YOUR_TOKEN" | docker secret create runner_token -
```

## Advanced Configurations

### With Monitoring (Prometheus)

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-data:/tmp/runner
    networks:
      - runner-network
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"
  
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
    networks:
      - runner-network

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

### Cleanup Container

```yaml
version: '3.8'

services:
  github-runner:
    image: myoung34/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    environment:
      REPO_URL: https://github.com/YOUR_ORG/YOUR_REPO
      RUNNER_TOKEN: ${RUNNER_TOKEN}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner-data:/tmp/runner
    networks:
      - runner-network
  
  cleanup:
    image: docker:24
    container_name: runner-cleanup
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - runner-network
    command: >
      sh -c "while true; do
        docker system prune -af --volumes --filter 'until=24h';
        sleep 3600;
      done"

volumes:
  runner-data:

networks:
  runner-network:
    driver: bridge
```

## Management Commands

```bash
# View logs
docker logs -f github-runner

# Execute commands in runner
docker exec -it github-runner bash

# Restart runner
docker restart github-runner

# Stop and remove
docker stop github-runner
docker rm github-runner

# View resource usage
docker stats github-runner

# Inspect runner
docker inspect github-runner

# Scale runners
docker-compose up -d --scale github-runner=5
```
