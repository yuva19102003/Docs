# Cloud CDN

## Overview

Cloud CDN (Content Delivery Network) uses Google's globally distributed edge points of presence to cache HTTP(S) load-balanced content close to users, reducing latency and improving performance.

---

## Table of Contents

1. [CDN Fundamentals](#cdn-fundamentals)
2. [Enabling Cloud CDN](#enabling-cloud-cdn)
3. [Cache Configuration](#cache-configuration)
4. [Cache Invalidation](#cache-invalidation)
5. [Best Practices](#best-practices)

---

## CDN Fundamentals

### How Cloud CDN Works

```
┌────────────────────────────────────────────────────────┐
│              Cloud CDN Architecture                    │
└────────────────────────────────────────────────────────┘

User (Tokyo)
    │
    ├─→ Request: example.com/image.jpg
    │   └─→ Nearest Edge Location (Tokyo)
    │       ├─ Cache HIT → Return cached content ✓
    │       └─ Cache MISS → Fetch from origin
    │           └─→ Backend (us-central1)
    │               └─→ Cache at edge
    │                   └─→ Return to user
    │
    └─→ Subsequent requests served from cache

Benefits:
├─ Reduced latency
├─ Lower bandwidth costs
├─ Reduced load on origin
└─ Improved user experience
```

### Key Features

```yaml
features:
  - Global edge network (200+ locations)
  - Automatic caching
  - Cache invalidation
  - Signed URLs/Cookies
  - Custom cache keys
  - Negative caching
  - Compression
```

---

## Enabling Cloud CDN

### Enable on Backend Service

```bash
# Enable Cloud CDN on existing backend
gcloud compute backend-services update web-backend \
    --enable-cdn \
    --global

# Disable Cloud CDN
gcloud compute backend-services update web-backend \
    --no-enable-cdn \
    --global
```

### Terraform

```hcl
# Backend service with Cloud CDN
resource "google_compute_backend_service" "web" {
  name          = "web-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.web.id]
  port_name     = "http"

  backend {
    group = google_compute_instance_group_manager.web.instance_group
  }

  # Enable Cloud CDN
  enable_cdn = true

  cdn_policy {
    cache_mode                   = "CACHE_ALL_STATIC"
    default_ttl                  = 3600
    max_ttl                      = 86400
    client_ttl                   = 3600
    negative_caching             = true
    serve_while_stale            = 86400
    
    negative_caching_policy {
      code = 404
      ttl  = 120
    }

    negative_caching_policy {
      code = 500
      ttl  = 60
    }

    cache_key_policy {
      include_host           = true
      include_protocol       = true
      include_query_string   = false
      query_string_whitelist = ["id", "page"]
    }
  }
}
```

---

## Cache Configuration

### Cache Modes

```yaml
# CACHE_ALL_STATIC (default)
cache_all_static:
  description: "Cache static content automatically"
  caches:
    - Images (jpg, png, gif, webp)
    - CSS and JavaScript
    - Fonts
    - Videos
  use_case: "Most web applications"

# USE_ORIGIN_HEADERS
use_origin_headers:
  description: "Respect Cache-Control headers from origin"
  behavior: "Cache based on origin headers"
  use_case: "Fine-grained control"

# FORCE_CACHE_ALL
force_cache_all:
  description: "Cache all content regardless of headers"
  behavior: "Override origin headers"
  use_case: "Maximum caching"
```

### TTL Configuration

```hcl
resource "google_compute_backend_service" "web" {
  name       = "web-backend"
  enable_cdn = true

  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    
    # Default TTL (if origin doesn't specify)
    default_ttl = 3600  # 1 hour
    
    # Maximum TTL (cap for Cache-Control: max-age)
    max_ttl = 86400  # 24 hours
    
    # Client TTL (sent to browser)
    client_ttl = 3600  # 1 hour
    
    # Serve stale content while revalidating
    serve_while_stale = 86400  # 24 hours
  }
}
```

### Cache Key Policy

```hcl
resource "google_compute_backend_service" "web" {
  name       = "web-backend"
  enable_cdn = true

  cdn_policy {
    cache_key_policy {
      # Include in cache key
      include_host         = true
      include_protocol     = true
      include_query_string = false
      
      # Whitelist specific query parameters
      query_string_whitelist = ["id", "page", "sort"]
      
      # Or blacklist parameters
      # query_string_blacklist = ["utm_source", "utm_medium"]
      
      # Include headers in cache key
      include_http_headers = ["Accept-Language"]
    }
  }
}
```

### Negative Caching

```hcl
resource "google_compute_backend_service" "web" {
  name       = "web-backend"
  enable_cdn = true

  cdn_policy {
    negative_caching = true
    
    # Cache 404 errors for 2 minutes
    negative_caching_policy {
      code = 404
      ttl  = 120
    }
    
    # Cache 500 errors for 1 minute
    negative_caching_policy {
      code = 500
      ttl  = 60
    }
    
    # Cache 502/503 errors for 30 seconds
    negative_caching_policy {
      code = 502
      ttl  = 30
    }
  }
}
```

---

## Cache Invalidation

### Invalidate Cache

```bash
# Invalidate all cached content
gcloud compute url-maps invalidate-cdn-cache web-map \
    --path="/*" \
    --async

# Invalidate specific path
gcloud compute url-maps invalidate-cdn-cache web-map \
    --path="/images/*" \
    --async

# Invalidate specific file
gcloud compute url-maps invalidate-cdn-cache web-map \
    --path="/style.css" \
    --async

# Invalidate multiple paths
gcloud compute url-maps invalidate-cdn-cache web-map \
    --path="/images/*" \
    --path="/css/*" \
    --path="/js/*" \
    --async
```

### Terraform

```hcl
# Trigger cache invalidation
resource "null_resource" "invalidate_cache" {
  triggers = {
    # Invalidate when deployment changes
    deployment_id = var.deployment_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute url-maps invalidate-cdn-cache ${google_compute_url_map.web.name} \
        --path="/*" \
        --async
    EOT
  }

  depends_on = [google_compute_backend_service.web]
}
```

### Python

```python
# Invalidate cache programmatically
from google.cloud import compute_v1

def invalidate_cdn_cache(project_id, url_map_name, paths):
    """
    Invalidate CDN cache for specified paths
    """
    client = compute_v1.UrlMapsClient()
    
    request = compute_v1.InvalidateCacheUrlMapRequest(
        project=project_id,
        url_map=url_map_name,
        cache_invalidation_rule_resource=compute_v1.CacheInvalidationRule(
            path=paths[0] if len(paths) == 1 else None,
            paths=paths if len(paths) > 1 else None
        )
    )
    
    operation = client.invalidate_cache(request=request)
    print(f"Cache invalidation started: {operation.name}")
    return operation

# Usage
invalidate_cdn_cache(
    "my-project",
    "web-map",
    ["/images/*", "/css/*", "/js/*"]
)
```

---

## Best Practices

### 1. Use Appropriate Cache Modes

```hcl
# For static websites
resource "google_compute_backend_service" "static" {
  name       = "static-backend"
  enable_cdn = true

  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 86400  # 24 hours for static content
    max_ttl     = 604800 # 7 days
  }
}

# For dynamic content with cache headers
resource "google_compute_backend_service" "dynamic" {
  name       = "dynamic-backend"
  enable_cdn = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"
  }
}
```

### 2. Configure Cache Keys Properly

```hcl
resource "google_compute_backend_service" "web" {
  name       = "web-backend"
  enable_cdn = true

  cdn_policy {
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = false
      
      # Only cache based on important parameters
      query_string_whitelist = ["id", "page"]
      
      # Ignore tracking parameters
      # This improves cache hit ratio
    }
  }
}
```

### 3. Set Appropriate TTLs

```yaml
# TTL guidelines
static_assets:
  type: "Images, CSS, JS, fonts"
  ttl: "86400 (24 hours) to 604800 (7 days)"
  reason: "Rarely change"

html_pages:
  type: "HTML content"
  ttl: "300 (5 minutes) to 3600 (1 hour)"
  reason: "May update frequently"

api_responses:
  type: "API data"
  ttl: "60 (1 minute) to 300 (5 minutes)"
  reason: "Dynamic data"

error_pages:
  type: "404, 500 errors"
  ttl: "60 (1 minute) to 120 (2 minutes)"
  reason: "May be temporary"
```

### 4. Use Compression

```hcl
resource "google_compute_backend_service" "web" {
  name       = "web-backend"
  enable_cdn = true

  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    
    # Enable compression
    compression_mode = "AUTOMATIC"
  }
}
```

### 5. Monitor Cache Performance

```python
# Monitor CDN metrics
from google.cloud import monitoring_v3

def monitor_cdn_performance(project_id):
    """
    Monitor Cloud CDN cache hit ratio
    """
    client = monitoring_v3.MetricServiceClient()
    
    # Query cache hit ratio
    interval = monitoring_v3.TimeInterval({
        "end_time": {"seconds": int(time.time())},
        "start_time": {"seconds": int(time.time()) - 3600},
    })
    
    results = client.list_time_series(
        request={
            "name": f"projects/{project_id}",
            "filter": 'metric.type="loadbalancing.googleapis.com/https/backend_request_count"',
            "interval": interval,
        }
    )
    
    for result in results:
        cache_hit = result.metric.labels.get('cache_result') == 'HIT'
        print(f"Cache Hit: {cache_hit}")

monitor_cdn_performance("my-project")
```

---

## Summary

Cloud CDN provides:
- Global content delivery
- Automatic caching
- Reduced latency
- Lower bandwidth costs
- Improved performance

### Quick Reference

```bash
# Enable CDN
gcloud compute backend-services update BACKEND \
    --enable-cdn --global

# Invalidate cache
gcloud compute url-maps invalidate-cdn-cache URL_MAP \
    --path="/*" --async

# Disable CDN
gcloud compute backend-services update BACKEND \
    --no-enable-cdn --global
```

---

## Next Steps

- [Load Balancing](./7-Load-Balancing.md) - Traffic distribution
- [Cloud DNS](./8-Cloud-DNS.md) - DNS management
- [Network Security](./12-Network-Security.md) - Security features

---

**Last Updated:** March 2026
