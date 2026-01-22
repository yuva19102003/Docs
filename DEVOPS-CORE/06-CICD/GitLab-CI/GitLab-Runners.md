# GitLab Runners

## Runner Types

- **Shared Runners**: Available to all projects
- **Group Runners**: Available to all projects in a group
- **Specific Runners**: Dedicated to specific projects

## Install GitLab Runner

### Linux

```bash
# Add GitLab repository
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

# Install
sudo apt-get install gitlab-runner

# Verify
gitlab-runner --version
```

### Docker

```bash
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
```

### Kubernetes

```bash
helm repo add gitlab https://charts.gitlab.io
helm install gitlab-runner gitlab/gitlab-runner \
  --set gitlabUrl=https://gitlab.com \
  --set runnerRegistrationToken=<token>
```

## Register Runner

```bash
# Interactive registration
sudo gitlab-runner register

# Non-interactive
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "docker,aws" \
  --run-untagged="true" \
  --locked="false"
```

## Executors

### Docker Executor (Recommended)

```toml
[[runners]]
  name = "docker-runner"
  url = "https://gitlab.com/"
  token = "TOKEN"
  executor = "docker"
  [runners.docker]
    image = "alpine:latest"
    privileged = false
    volumes = ["/cache"]
```

### Kubernetes Executor

```toml
[[runners]]
  name = "kubernetes-runner"
  url = "https://gitlab.com/"
  token = "TOKEN"
  executor = "kubernetes"
  [runners.kubernetes]
    image = "alpine:latest"
    namespace = "gitlab-runner"
```

### Shell Executor

```toml
[[runners]]
  name = "shell-runner"
  url = "https://gitlab.com/"
  token = "TOKEN"
  executor = "shell"
```

## Docker-in-Docker Setup

```yaml
build-docker:
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t myapp:latest .
    - docker push myapp:latest
```

## Runner Configuration

Edit `/etc/gitlab-runner/config.toml`:

```toml
concurrent = 4
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "production-runner"
  url = "https://gitlab.com/"
  token = "TOKEN"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
  [runners.cache]
    Type = "s3"
    Shared = true
    [runners.cache.s3]
      ServerAddress = "s3.amazonaws.com"
      BucketName = "runner-cache"
      BucketLocation = "us-east-1"
```

## Best Practices

✅ **Use Docker Executor**: Isolated builds
✅ **Tag Runners**: Organize by capability
✅ **Limit Concurrency**: Prevent resource exhaustion
✅ **Use Cache**: Speed up builds
✅ **Monitor Resources**: Track CPU/memory usage
✅ **Regular Updates**: Keep runners updated
✅ **Secure Runners**: Restrict network access
✅ **Auto-scaling**: Use Docker Machine or Kubernetes

## Next Steps

Continue to:
- **GitLab-CI-Examples.md** - Real-world examples
