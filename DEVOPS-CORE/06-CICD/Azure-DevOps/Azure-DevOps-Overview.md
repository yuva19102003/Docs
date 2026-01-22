# Azure DevOps Overview

## What is Azure DevOps?

Azure DevOps is Microsoft's comprehensive DevOps platform providing services for the entire software development lifecycle. It offers source control, CI/CD, project management, testing, and artifact management in an integrated suite.

### Key Services

- **Azure Repos**: Git repositories and TFVC
- **Azure Pipelines**: CI/CD automation
- **Azure Boards**: Agile project management
- **Azure Test Plans**: Manual and automated testing
- **Azure Artifacts**: Package management

## Azure DevOps Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                AZURE DEVOPS ARCHITECTURE                      │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              AZURE DEVOPS SERVICES                      │ │
│  ├────────────────────────────────────────────────────────┤ │
│  │                                                         │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │  Azure   │  │  Azure   │  │  Azure   │            │ │
│  │  │  Repos   │  │ Pipelines│  │  Boards  │            │ │
│  │  └────┬─────┘  └────┬─────┘  └──────────┘            │ │
│  │       │             │                                  │ │
│  │       │             ▼                                  │ │
│  │       │    ┌─────────────────┐                        │ │
│  │       │    │  Build Agents   │                        │ │
│  │       │    │  • Microsoft    │                        │ │
│  │       │    │  • Self-hosted  │                        │ │
│  │       │    └────────┬────────┘                        │ │
│  │       │             │                                  │ │
│  │       │             ▼                                  │ │
│  │       │    ┌─────────────────┐                        │ │
│  │       └───►│  Azure          │                        │ │
│  │            │  Artifacts      │                        │ │
│  │            └─────────────────┘                        │ │
│  │                     │                                  │ │
│  └─────────────────────┼──────────────────────────────────┘ │
│                        │                                     │
│                        ▼                                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           DEPLOYMENT TARGETS                            │ │
│  ├────────────────────────────────────────────────────────┤ │
│  │  • Azure Cloud    • Kubernetes    • On-Premises       │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

## Azure Pipelines

### Pipeline Types

**Build Pipeline**: Compile and test code
**Release Pipeline**: Deploy applications
**YAML Pipeline**: Pipeline as code (recommended)
**Classic Pipeline**: Visual designer (legacy)

### Basic YAML Pipeline

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: NodeTool@0
  inputs:
    versionSpec: '20.x'
  
- script: |
    npm install
    npm run build
  displayName: 'Build'

- script: |
    npm test
  displayName: 'Test'
```

## Azure Repos

Git-based source control with:
- Pull requests with code review
- Branch policies
- Git LFS support
- Integration with Azure Pipelines

## Azure Boards

Agile project management:
- Work items (User Stories, Tasks, Bugs)
- Kanban boards
- Sprint planning
- Backlogs
- Queries and dashboards

## Azure Artifacts

Package management for:
- NuGet packages
- npm packages
- Maven artifacts
- Python packages
- Universal packages

## Best Practices

✅ **Use YAML Pipelines**: Version control your CI/CD
✅ **Implement Branch Policies**: Protect main branches
✅ **Use Service Connections**: Secure credential management
✅ **Organize with Projects**: Separate concerns
✅ **Use Variable Groups**: Centralize configuration
✅ **Implement Approvals**: Manual gates for production
✅ **Monitor Pipelines**: Set up alerts
✅ **Use Templates**: Reuse pipeline configurations

## Next Steps

Continue to:
- **Azure-Pipelines.md** - Creating pipelines
- **Azure-Agents.md** - Setting up agents
- **Azure-DevOps-Examples.md** - Real-world examples
