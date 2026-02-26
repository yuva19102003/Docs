# Podman Compose

## Overview

podman-compose is a tool for defining and running multi-container applications using Compose files (docker-compose.yml compatible).

## Installation

```bash
# Using pip
pip3 install podman-compose

# Using dnf (Fedora)
sudo dnf install podman-compose

# Verify
podman-compose --version
```

## Compose File Basics

### Simple Example

```yaml
# docker-compose.yml
version: '3'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html

  app:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./app:/app
    command: npm start
    environment:
      - NODE_ENV=production
```

### Run Compose

```bash
# Start services
podman-compose up

# Start in detached mode
podman-compose up -d

# Stop services
podman-compose down

# View logs
podman-compose logs

# List services
podman-compose ps
```

## Multi-Container Application

### WordPress Example

```yaml
version: '3.8'

services:
  db:
    image: mysql:8
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    restart: always

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html
    depends_on:
      - db
    restart: always

volumes:
  db_data:
  wp_data:
```

### LAMP Stack

```yaml
version: '3.8'

services:
  web:
    image: php:8.1-apache
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myapp
    volumes:
      - db_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin:latest
    ports:
      - "8081:80"
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: secret
    depends_on:
      - db

volumes:
  db_data:
```

## Service Configuration

### Build from Dockerfile

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - VERSION=1.0
    ports:
      - "3000:3000"
```

### Environment Variables

```yaml
services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=production
      - API_KEY=secret
    env_file:
      - .env
      - .env.prod
```

### Networking

```yaml
services:
  frontend:
    image: nginx
    networks:
      - frontend-net

  backend:
    image: api-server
    networks:
      - frontend-net
      - backend-net

  database:
    image: postgres
    networks:
      - backend-net

networks:
  frontend-net:
  backend-net:
```

### Health Checks

```yaml
services:
  web:
    image: nginx
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Commands

### Basic Commands

```bash
# Start services
podman-compose up

# Start specific service
podman-compose up web

# Build and start
podman-compose up --build

# Recreate containers
podman-compose up --force-recreate

# Scale service
podman-compose up --scale web=3
```

### Service Management

```bash
# Stop services
podman-compose stop

# Start stopped services
podman-compose start

# Restart services
podman-compose restart

# Pause services
podman-compose pause

# Unpause services
podman-compose unpause
```

### Logs and Monitoring

```bash
# View logs
podman-compose logs

# Follow logs
podman-compose logs -f

# Logs for specific service
podman-compose logs web

# Tail logs
podman-compose logs --tail=100
```

### Execute Commands

```bash
# Run command in service
podman-compose exec web sh

# Run one-off command
podman-compose run web ls /app

# Run without dependencies
podman-compose run --no-deps web npm test
```

## Alternative: Podman with Kubernetes YAML

### Generate Kubernetes YAML

```bash
# From running pod
podman generate kube mypod > pod.yaml

# From compose file (using podman-compose)
podman-compose up -d
podman generate kube --service webapp > webapp.yaml
```

### Play Kubernetes YAML

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80
      hostPort: 8080
  - name: app
    image: node:18-alpine
    env:
    - name: NODE_ENV
      value: production
```

```bash
# Deploy from YAML
podman play kube pod.yaml

# Remove deployment
podman play kube --down pod.yaml

# Replace existing
podman play kube --replace pod.yaml
```

## Best Practices

1. **Use Version Control**: Track compose files in Git
2. **Environment Files**: Use .env for secrets
3. **Named Volumes**: For persistent data
4. **Health Checks**: Monitor service health
5. **Resource Limits**: Set CPU/memory limits
6. **Depends On**: Define service dependencies
7. **Networks**: Segment services properly
8. **Logging**: Configure log drivers
9. **Restart Policies**: Set appropriate policies
10. **Documentation**: Comment complex configurations

## Next Steps

- [systemd Integration](9-Systemd-Integration.md) - Service management
- [Security](10-Security.md) - Security best practices
- [Best Practices](12-Best-Practices.md) - Production guidelines
