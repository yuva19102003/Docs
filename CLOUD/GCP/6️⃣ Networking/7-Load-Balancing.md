# Load Balancing

## Overview

Google Cloud Load Balancing distributes traffic across multiple instances, providing high availability, scalability, and performance. GCP offers various load balancer types for different use cases.

---

## Table of Contents

1. [Load Balancer Types](#load-balancer-types)
2. [HTTP(S) Load Balancing](#https-load-balancing)
3. [Network Load Balancing](#network-load-balancing)
4. [Internal Load Balancing](#internal-load-balancing)
5. [Best Practices](#best-practices)

---

## Load Balancer Types

### Overview

```
┌────────────────────────────────────────────────────────┐
│          GCP Load Balancer Types                       │
└────────────────────────────────────────────────────────┘

EXTERNAL (Internet-facing)
├─ HTTP(S) Load Balancer (Global, Layer 7)
│  └─ Use for: Web applications, APIs
├─ SSL Proxy (Global, Layer 4)
│  └─ Use for: SSL/TLS traffic
├─ TCP Proxy (Global, Layer 4)
│  └─ Use for: TCP traffic
└─ Network Load Balancer (Regional, Layer 4)
   └─ Use for: UDP, high performance

INTERNAL (Private)
├─ Internal HTTP(S) Load Balancer (Regional, Layer 7)
│  └─ Use for: Internal microservices
└─ Internal TCP/UDP Load Balancer (Regional, Layer 4)
   └─ Use for: Internal services
```

### Selection Guide

```yaml
use_cases:
  web_application:
    type: "HTTP(S) Load Balancer"
    features:
      - Global load balancing
      - SSL termination
      - URL-based routing
      - CDN integration
  
  tcp_application:
    type: "TCP Proxy or Network LB"
    features:
      - Layer 4 load balancing
      - Preserve client IP
      - High throughput
  
  internal_services:
    type: "Internal Load Balancer"
    features:
      - Private load balancing
      - No external IP needed
      - Low latency
```

---

## HTTP(S) Load Balancing

### Architecture

```
Internet
    │
    ├─→ Global HTTP(S) Load Balancer
    │   ├─→ URL Map (routing rules)
    │   ├─→ Backend Service
    │   │   ├─→ Instance Group (us-central1)
    │   │   ├─→ Instance Group (us-east1)
    │   │   └─→ Instance Group (europe-west1)
    │   └─→ Health Checks
    │
    └─→ Cloud CDN (optional)
```

### Creating HTTP(S) Load Balancer

```bash
# 1. Create instance template
gcloud compute instance-templates create web-template \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install -y nginx
      echo "Hello from $(hostname)" > /var/www/html/index.html'

# 2. Create managed instance group
gcloud compute instance-groups managed create web-mig \
    --template=web-template \
    --size=3 \
    --zone=us-central1-a

# 3. Create health check
gcloud compute health-checks create http web-health-check \
    --port=80 \
    --request-path=/

# 4. Create backend service
gcloud compute backend-services create web-backend \
    --protocol=HTTP \
    --health-checks=web-health-check \
    --global

# 5. Add instance group to backend
gcloud compute backend-services add-backend web-backend \
    --instance-group=web-mig \
    --instance-group-zone=us-central1-a \
    --global

# 6. Create URL map
gcloud compute url-maps create web-map \
    --default-service=web-backend

# 7. Create target HTTP proxy
gcloud compute target-http-proxies create web-proxy \
    --url-map=web-map

# 8. Create forwarding rule
gcloud compute forwarding-rules create web-forwarding-rule \
    --global \
    --target-http-proxy=web-proxy \
    --ports=80

# Get load balancer IP
gcloud compute forwarding-rules describe web-forwarding-rule \
    --global \
    --format="get(IPAddress)"
```

### Terraform

```hcl
# Instance template
resource "google_compute_instance_template" "web" {
  name         = "web-template"
  machine_type = "e2-medium"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc.id
    access_config {}
  }

  tags = ["http-server"]

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "Hello from $(hostname)" > /var/www/html/index.html
  EOF
}

# Managed instance group
resource "google_compute_instance_group_manager" "web" {
  name               = "web-mig"
  base_instance_name = "web"
  zone               = "us-central1-a"
  target_size        = 3

  version {
    instance_template = google_compute_instance_template.web.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Health check
resource "google_compute_health_check" "web" {
  name = "web-health-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Backend service
resource "google_compute_backend_service" "web" {
  name          = "web-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.web.id]
  port_name     = "http"

  backend {
    group           = google_compute_instance_group_manager.web.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  enable_cdn = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
  }
}

# URL map
resource "google_compute_url_map" "web" {
  name            = "web-map"
  default_service = google_compute_backend_service.web.id

  host_rule {
    hosts        = ["example.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.web.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api.id
    }

    path_rule {
      paths   = ["/static/*"]
      service = google_compute_backend_service.static.id
    }
  }
}

# HTTP proxy
resource "google_compute_target_http_proxy" "web" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web.id
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "web" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_http_proxy.web.id
  port_range = "80"
}

# HTTPS with SSL
resource "google_compute_ssl_certificate" "web" {
  name        = "web-cert"
  private_key = file("private-key.pem")
  certificate = file("certificate.pem")
}

resource "google_compute_target_https_proxy" "web" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.web.id
  ssl_certificates = [google_compute_ssl_certificate.web.id]
}

resource "google_compute_global_forwarding_rule" "web_https" {
  name       = "web-https-forwarding-rule"
  target     = google_compute_target_https_proxy.web.id
  port_range = "443"
}
```

---

## Network Load Balancing

### Creating Network Load Balancer

```bash
# 1. Create instance group (same as above)

# 2. Create health check
gcloud compute health-checks create tcp tcp-health-check \
    --port=80

# 3. Create target pool
gcloud compute target-pools create tcp-pool \
    --region=us-central1 \
    --health-check=tcp-health-check

# 4. Add instances to target pool
gcloud compute target-pools add-instances tcp-pool \
    --instances=instance-1,instance-2,instance-3 \
    --zone=us-central1-a

# 5. Create forwarding rule
gcloud compute forwarding-rules create tcp-forwarding-rule \
    --region=us-central1 \
    --ports=80 \
    --target-pool=tcp-pool
```

### Terraform

```hcl
# Health check
resource "google_compute_health_check" "tcp" {
  name = "tcp-health-check"

  tcp_health_check {
    port = 80
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Target pool
resource "google_compute_target_pool" "tcp" {
  name   = "tcp-pool"
  region = "us-central1"

  instances = [
    google_compute_instance.vm1.self_link,
    google_compute_instance.vm2.self_link,
    google_compute_instance.vm3.self_link,
  ]

  health_checks = [
    google_compute_health_check.tcp.name,
  ]
}

# Forwarding rule
resource "google_compute_forwarding_rule" "tcp" {
  name   = "tcp-forwarding-rule"
  region = "us-central1"

  port_range = "80"
  target     = google_compute_target_pool.tcp.id
}
```

---

## Internal Load Balancing

### Internal HTTP(S) Load Balancer

```hcl
# Backend service (internal)
resource "google_compute_region_backend_service" "internal" {
  name          = "internal-backend"
  region        = "us-central1"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.internal.id]

  backend {
    group          = google_compute_instance_group_manager.internal.instance_group
    balancing_mode = "UTILIZATION"
  }

  load_balancing_scheme = "INTERNAL_MANAGED"
}

# URL map (internal)
resource "google_compute_region_url_map" "internal" {
  name            = "internal-map"
  region          = "us-central1"
  default_service = google_compute_region_backend_service.internal.id
}

# HTTP proxy (internal)
resource "google_compute_region_target_http_proxy" "internal" {
  name    = "internal-proxy"
  region  = "us-central1"
  url_map = google_compute_region_url_map.internal.id
}

# Forwarding rule (internal)
resource "google_compute_forwarding_rule" "internal" {
  name   = "internal-forwarding-rule"
  region = "us-central1"

  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.internal.id
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.internal.id
}
```

---

## Best Practices

### 1. Use Health Checks

✓ **Configure appropriate health checks**
```hcl
resource "google_compute_health_check" "web" {
  name = "web-health-check"

  http_health_check {
    port         = 80
    request_path = "/health"  # Dedicated health endpoint
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}
```

### 2. Enable Cloud CDN

```hcl
resource "google_compute_backend_service" "web" {
  name          = "web-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.web.id]

  enable_cdn = true

  cdn_policy {
    cache_mode       = "CACHE_ALL_STATIC"
    default_ttl      = 3600
    max_ttl          = 86400
    client_ttl       = 3600
    negative_caching = true
  }
}
```

### 3. Use SSL/TLS

```hcl
# Managed SSL certificate
resource "google_compute_managed_ssl_certificate" "web" {
  name = "web-cert"

  managed {
    domains = ["example.com", "www.example.com"]
  }
}

resource "google_compute_target_https_proxy" "web" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.web.id
  ssl_certificates = [google_compute_managed_ssl_certificate.web.id]
}
```

### 4. Configure Autoscaling

```hcl
resource "google_compute_autoscaler" "web" {
  name   = "web-autoscaler"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.web.id

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}
```

---

## Summary

GCP Load Balancing provides:
- Global and regional options
- Layer 4 and Layer 7 load balancing
- Automatic scaling
- Health checking
- SSL termination

### Quick Reference

```bash
# Create HTTP(S) load balancer
gcloud compute backend-services create BACKEND \
    --protocol=HTTP --health-checks=HEALTH_CHECK --global

gcloud compute url-maps create URL_MAP \
    --default-service=BACKEND

gcloud compute target-http-proxies create PROXY \
    --url-map=URL_MAP

gcloud compute forwarding-rules create RULE \
    --global --target-http-proxy=PROXY --ports=80
```

---

## Next Steps

- [Cloud DNS](./8-Cloud-DNS.md) - DNS management
- [Cloud CDN](./9-Cloud-CDN.md) - Content delivery
- [Network Security](./12-Network-Security.md) - Security features

---

**Last Updated:** March 2026
