# DevOps Topics

## DevOps

DevOps combines development and operations to streamline software delivery through collaboration, automation, and continuous integration.

### DevOps Workflow Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DevOps Lifecycle                                 │
└─────────────────────────────────────────────────────────────────────────┘

    ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
    │   PLAN   │─────▶│   CODE   │─────▶│  BUILD   │─────▶│   TEST   │
    │          │      │          │      │          │      │          │
    │ • Jira   │      │ • Git    │      │ • Maven  │      │ • JUnit  │
    │ • Agile  │      │ • GitHub │      │ • Gradle │      │ • PyTest │
    └──────────┘      └──────────┘      └──────────┘      └──────────┘
         ▲                                                       │
         │                                                       │
         │                                                       ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
    │ MONITOR  │◀─────│  OPERATE │◀─────│  DEPLOY  │◀─────│ RELEASE  │
    │          │      │          │      │          │      │          │
    │• Grafana │      │• K8s     │      │• ArgoCD  │      │• Jenkins │
    │• Prom    │      │• Ansible │      │• Helm    │      │• GitLab  │
    └──────────┘      └──────────┘      └──────────┘      └──────────┘

                    ← Continuous Feedback Loop →
```

## Difference between Agile vs Sprint vs Devops

- **Agile** is a project management methodology focused on iterative development, where requirements and solutions evolve through collaboration.
- **Sprint** is a short, time-boxed iteration in Agile, typically lasting 1-4 weeks, where a specific set of tasks is completed. A team will work for short periods called "sprints" to manage complex projects and improve efficiencies.
- **DevOps** is a culture and set of practices that focus on automating and integrating development and operations to speed up software delivery and improve reliability.

## Continuous Improvement

A **retrospective** is a meeting held at the end of a sprint or iteration in Agile development. The team reflects on what went well, what didn't, and how to improve processes for the next cycle. It's a key practice for continuous improvement, encouraging open feedback and adjustments.

## Cross functional teams

- **Developers**: Build and maintain code for application functionality.
- **Operations (Ops)**: Manage infrastructure and deployment for smooth software delivery.
- **Quality Assurance (QA)**: Test software for bugs and ensure quality standards.
- **Security**: Ensure system security by identifying vulnerabilities and enforcing protection measures.

## SRE vs DEVOPS vs PLATFORM ENGINEER

### Comparison Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SRE vs DevOps vs Platform Engineering                │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│        SRE           │  │       DevOps         │  │  Platform Engineer   │
│  (Reliability First) │  │  (Collaboration)     │  │  (Developer Tools)   │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
         │                          │                          │
         │                          │                          │
         ▼                          ▼                          ▼
┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│ • Monitor SLOs/SLAs  │  │ • CI/CD Pipelines    │  │ • Self-Service       │
│ • Incident Response  │  │ • Infrastructure     │  │   Platforms          │
│ • Error Budgets      │  │   as Code            │  │ • Developer Portal   │
│ • Capacity Planning  │  │ • Automation         │  │ • Internal Tools     │
│ • Performance        │  │ • Collaboration      │  │ • API Gateways       │
│ • Toil Reduction     │  │ • Deployment         │  │ • Security/Compliance│
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
         │                          │                          │
         └──────────────────────────┴──────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │   Shared Responsibilities:    │
                    │   • Automation                │
                    │   • Monitoring                │
                    │   • Infrastructure            │
                    │   • Security                  │
                    │   • Scalability               │
                    └───────────────────────────────┘
```

### Site Reliability Engineering (SRE)

- **Focus**: Reliability and performance of services.
- **Goals**: Ensure uptime and scalability.
- **Responsibilities**: Monitor systems, automate processes, manage incidents, set SLOs/SLAs.

### DevOps

- **Focus**: Collaboration between development and operations.
- **Goals**: Improve software delivery and quality.
- **Responsibilities**: Implement CI/CD, manage infrastructure as code, enhance communication.

### Platform Engineering

- **Focus**: Building infrastructure and tools for developers.
- **Goals**: Create self-service platforms.
- **Responsibilities**: Design scalable infrastructure, provide developer tooling, ensure security and compliance.

### Summary

- **SRE**: Emphasizes reliability.
- **DevOps**: Focuses on collaboration and automation.
- **Platform Engineering**: Centers on developer platform support.
