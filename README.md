# DevOps & Cloud Documentation

Comprehensive documentation for DevOps, Cloud, Cybersecurity, Development, and GenAI topics.

## 📚 Documentation Structure

- **DEVOPS-CORE/** - DevOps fundamentals, tools, and practices
- **CLOUD/** - AWS and Azure cloud services documentation
- **CYBERSECURITY/** - Security fundamentals, tools, and SOC
- **DEVELOPMENT/** - MERN Stack and Go Lang development
- **GENAI/** - MLflow and AI/ML topics

## 🚀 Quick Start

### Prerequisites

- Python 3.x
- pip

### Setup

1. Create and activate virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

### Running the Documentation Site

**Option 1: Using the serve script**
```bash
./serve.sh
```

**Option 2: Using mkdocs directly**
```bash
source venv/bin/activate
mkdocs serve -f .mkdocs/mkdocs.yml
```

The site will be available at: http://127.0.0.1:8000/your-repo-name/

### Building for Production

**Option 1: Using the build script**
```bash
./build.sh
```

**Option 2: Using mkdocs directly**
```bash
source venv/bin/activate
mkdocs build -f .mkdocs/mkdocs.yml
```

The built site will be in the `site/` directory.

## 📝 Configuration

The MkDocs configuration is located at `.mkdocs/mkdocs.yml`. This setup allows the documentation to be built directly from the root folders without needing a separate `docs/` directory.

## 🎨 Features

- Material theme with dark/light mode toggle
- Collapsible navigation sections
- Full-text search
- Code syntax highlighting
- Responsive design
- Custom CSS for optimized layout

## 📖 Documentation Topics

### DevOps Core
- Operating Systems (Linux)
- Git & Version Control
- Networking
- Containerization (Docker)
- CI/CD (Jenkins, GitHub Actions, GitLab CI, ArgoCD)
- Infrastructure as Code (Terraform, Packer)
- Configuration Management (Ansible, Consul)
- Message Queues (Kafka, RabbitMQ, Airflow)
- NGINX
- Observability (Prometheus, Grafana, Loki, OpenTelemetry)
- Caching (Redis)
- Secrets Management (HashiCorp Vault)
- System Design
- Interview Questions

### Cloud Platforms
- **AWS**: 100+ services including EC2, S3, Lambda, RDS, VPC, Security, and more
- **Azure**: Virtual Machines, Networking, Storage, Databases, and PaaS services

### Cybersecurity
- Fundamentals (CIA Triad, Zero Trust, Defense in Depth)
- Security Operations Center (SOC)
- Security Tools (Wireshark, Nmap, Metasploit, Burp Suite)
- Vulnerability Scanning (Trivy, Snyk, OpenVAS)

### Development
- MERN Stack (MongoDB, Express, React, Node.js)
- Go Lang

### GenAI
- MLflow

## 🤝 Contributing

Feel free to contribute by adding new documentation or improving existing content.

## 📄 License

This documentation is for educational purposes.
