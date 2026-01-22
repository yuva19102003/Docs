# GitLab CI/CD Pipelines

## Basic Pipeline Structure

```yaml
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - echo "Building application"
    - npm install
    - npm run build

test-job:
  stage: test
  script:
    - echo "Running tests"
    - npm test

deploy-job:
  stage: deploy
  script:
    - echo "Deploying application"
    - ./deploy.sh
```

## Job Configuration

### Image Selection

```yaml
# Global image
image: node:20

# Job-specific image
test-job:
  image: python:3.11
  script:
    - pytest
```

### Services (Docker-in-Docker)

```yaml
build-docker:
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_TLS_CERTDIR: ""
  script:
    - docker build -t myapp:latest .
    - docker push myapp:latest
```

### Scripts

```yaml
job:
  before_script:
    - echo "Setup"
  script:
    - echo "Main script"
  after_script:
    - echo "Cleanup"
```

### Variables

```yaml
variables:
  GLOBAL_VAR: "value"

job:
  variables:
    JOB_VAR: "value"
  script:
    - echo $GLOBAL_VAR
    - echo $JOB_VAR
```

## Artifacts

### Save Artifacts

```yaml
build:
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
      - build/
    expire_in: 1 week
```

### Use Artifacts

```yaml
deploy:
  script:
    - ls dist/
  dependencies:
    - build
```

### Artifact Reports

```yaml
test:
  script:
    - npm test
  artifacts:
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

## Caching

```yaml
cache:
  paths:
    - node_modules/
  key: ${CI_COMMIT_REF_SLUG}

build:
  script:
    - npm install
    - npm run build
```

### Cache Policy

```yaml
build:
  cache:
    key: build-cache
    paths:
      - node_modules/
    policy: pull-push

test:
  cache:
    key: build-cache
    paths:
      - node_modules/
    policy: pull
```

## Conditional Execution

### Only/Except (Legacy)

```yaml
deploy:
  script:
    - ./deploy.sh
  only:
    - main
    - tags
  except:
    - develop
```

### Rules (Recommended)

```yaml
deploy:
  script:
    - ./deploy.sh
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'
    - when: manual
      allow_failure: true
```

### Complex Rules

```yaml
deploy:
  script:
    - ./deploy.sh
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: never
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: on_success
    - if: '$CI_COMMIT_TAG =~ /^v[0-9]+/'
      when: manual
```

## Parallel Jobs

### Matrix

```yaml
test:
  parallel:
    matrix:
      - NODE_VERSION: ['18', '20', '22']
        OS: ['ubuntu', 'alpine']
  image: node:${NODE_VERSION}-${OS}
  script:
    - npm test
```

### Parallel Instances

```yaml
test:
  parallel: 5
  script:
    - npm test -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
```

## Environments

```yaml
deploy-staging:
  stage: deploy
  script:
    - ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
    on_stop: stop-staging

deploy-production:
  stage: deploy
  script:
    - ./deploy.sh production
  environment:
    name: production
    url: https://example.com
  when: manual

stop-staging:
  stage: deploy
  script:
    - ./cleanup.sh staging
  environment:
    name: staging
    action: stop
  when: manual
```

## Triggers

### Downstream Pipeline

```yaml
trigger-downstream:
  trigger:
    project: group/downstream-project
    branch: main
    strategy: depend
```

### Multi-Project Pipeline

```yaml
trigger-api:
  trigger:
    project: group/api-project
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

trigger-frontend:
  trigger:
    project: group/frontend-project
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

## Includes and Templates

### Include External Files

```yaml
include:
  - local: '.gitlab-ci-templates/build.yml'
  - remote: 'https://example.com/ci-template.yml'
  - project: 'group/ci-templates'
    file: '/templates/deploy.yml'
  - template: 'Security/SAST.gitlab-ci.yml'
```

### Extends (Inheritance)

```yaml
.deploy-template:
  script:
    - ./deploy.sh $ENVIRONMENT
  only:
    - main

deploy-staging:
  extends: .deploy-template
  variables:
    ENVIRONMENT: staging

deploy-production:
  extends: .deploy-template
  variables:
    ENVIRONMENT: production
  when: manual
```

## Needs (DAG)

```yaml
build:
  stage: build
  script:
    - npm run build

test-unit:
  stage: test
  needs: [build]
  script:
    - npm run test:unit

test-integration:
  stage: test
  needs: [build]
  script:
    - npm run test:integration

deploy:
  stage: deploy
  needs: [test-unit, test-integration]
  script:
    - ./deploy.sh
```

## Complete Example

```yaml
stages:
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_REGISTRY: registry.gitlab.com
  IMAGE_NAME: $CI_REGISTRY_IMAGE
  DOCKER_TLS_CERTDIR: ""

.docker-login: &docker-login
  - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY

build:
  stage: build
  image: node:20
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 day

test:unit:
  stage: test
  image: node:20
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
    policy: pull
  script:
    - npm run test:unit
  coverage: '/Statements\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:integration:
  stage: test
  image: node:20
  services:
    - postgres:14
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
  script:
    - npm run test:integration

sast:
  stage: security
  include:
    - template: Security/SAST.gitlab-ci.yml

docker-build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - *docker-login
  script:
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker tag $IMAGE_NAME:$CI_COMMIT_SHA $IMAGE_NAME:latest
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA
    - docker push $IMAGE_NAME:latest
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

deploy:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context staging
    - kubectl set image deployment/myapp myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl rollout status deployment/myapp
  environment:
    name: staging
    url: https://staging.example.com
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

deploy:production:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context production
    - kubectl set image deployment/myapp myapp=$IMAGE_NAME:$CI_COMMIT_SHA
    - kubectl rollout status deployment/myapp
  environment:
    name: production
    url: https://example.com
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
```

## Best Practices

✅ **Use Stages**: Organize jobs logically
✅ **Cache Dependencies**: Speed up builds
✅ **Use Artifacts**: Pass data between jobs
✅ **Implement Rules**: Control job execution
✅ **Use Extends**: Reuse configurations
✅ **Parallel Execution**: Run independent jobs in parallel
✅ **Manual Deployments**: Require approval for production
✅ **Use Needs**: Optimize pipeline with DAG
✅ **Security Scanning**: Include SAST/DAST templates
✅ **Monitor Coverage**: Track test coverage

## Next Steps

Continue to:
- **GitLab-Runners.md** - Setting up runners
- **GitLab-CI-Examples.md** - Real-world examples
