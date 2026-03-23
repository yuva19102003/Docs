# Jira Projects

## What is a Jira Project?

A project is a collection of issues that are related to a specific product, service, or initiative. Projects provide structure and organization for your team's work.

## Project Types

### 1. Team-Managed Projects
- Simplified setup and configuration
- Team controls their own settings
- Best for small, autonomous teams
- Limited customization options

### 2. Company-Managed Projects
- Advanced configuration options
- Centralized administration
- Shared workflows and schemes
- Best for large organizations

## Creating a New Project

### Step-by-Step Guide

```
1. Click "Projects" in top navigation
2. Click "Create project"
3. Choose project template:
   - Scrum
   - Kanban
   - Bug tracking
   - DevOps
   - Custom
4. Select project type (Team-managed or Company-managed)
5. Enter project details:
   - Name: e.g., "E-commerce Platform"
   - Key: e.g., "ECOM" (2-10 characters)
   - Description (optional)
6. Click "Create"
```

### Project Templates

| Template | Use Case | Features |
|----------|----------|----------|
| **Scrum** | Sprint-based development | Backlog, sprints, velocity charts |
| **Kanban** | Continuous flow | WIP limits, cumulative flow |
| **Bug Tracking** | Issue management | Bug workflows, priority fields |
| **DevOps** | CI/CD integration | Deployment tracking, releases |

## Project Configuration

### Basic Settings

```
Project Settings → Details

Configure:
- Project name
- Project key (cannot be changed)
- Project avatar
- Project description
- Project category
- Default assignee
```

### Project Key

The project key is a unique identifier used in issue keys:
```
Format: [PROJECT-KEY]-[NUMBER]
Example: ECOM-123
         ↑      ↑
      Project  Issue
       Key    Number
```

**Best Practices:**
- Keep it short (2-5 characters)
- Make it memorable
- Use uppercase letters
- Avoid special characters

## Project Components

Components are subsections of a project that group related issues.

### Creating Components

```
1. Project Settings → Components
2. Click "Create component"
3. Enter:
   - Name: e.g., "Frontend", "Backend", "API"
   - Description
   - Component lead (optional)
   - Default assignee
4. Click "Create"
```

### Example Component Structure

```
E-commerce Platform (ECOM)
├── Frontend (ECOM-FE)
│   ├── User Interface
│   ├── Shopping Cart
│   └── Checkout
├── Backend (ECOM-BE)
│   ├── API
│   ├── Database
│   └── Authentication
└── DevOps (ECOM-DO)
    ├── CI/CD
    ├── Infrastructure
    └── Monitoring
```

## Project Versions/Releases

Versions represent releases or milestones in your project.

### Creating Versions

```
1. Project Settings → Releases
2. Click "Create version"
3. Enter:
   - Name: e.g., "v1.0.0", "Sprint 1"
   - Start date
   - Release date
   - Description
4. Click "Create"
```

### Version States

- **Unreleased**: Work in progress
- **Released**: Completed and deployed
- **Archived**: Historical record

### Managing Versions

```bash
# Release a version
1. Go to Releases
2. Click "..." on version
3. Select "Release"
4. Confirm release date

# Archive a version
1. Click "..." on version
2. Select "Archive"
```

## Project Roles and Permissions

### Default Roles

| Role | Permissions |
|------|-------------|
| **Administrator** | Full project control |
| **Member** | Create, edit, assign issues |
| **Viewer** | Read-only access |

### Adding Team Members

```
1. Project Settings → People
2. Click "Add people"
3. Search for users
4. Select role
5. Click "Add"
```

### Custom Roles (Company-managed)

```
1. Project Settings → Permissions
2. Click "Actions" → "Add role"
3. Define permissions:
   - Browse project
   - Create issues
   - Edit issues
   - Delete issues
   - Assign issues
   - Manage sprints
4. Save role
```

## Project Settings Overview

### Essential Settings

```
Project Settings
├── Details
│   ├── Name, key, description
│   └── Avatar and category
├── People
│   ├── Add/remove members
│   └── Assign roles
├── Issue types
│   ├── Story, Task, Bug, Epic
│   └── Custom issue types
├── Workflows
│   ├── Status transitions
│   └── Workflow rules
├── Screens
│   ├── Create screen
│   ├── Edit screen
│   └── View screen
├── Fields
│   ├── Custom fields
│   └── Field configuration
├── Components
│   └── Project subsections
├── Releases
│   └── Version management
└── Permissions
    └── Role-based access
```

## Project Templates Best Practices

### Scrum Project Setup

```yaml
Project: Mobile App Development
Key: MAD
Template: Scrum

Components:
  - iOS App
  - Android App
  - Backend API
  - QA Testing

Versions:
  - v1.0.0 (MVP)
  - v1.1.0 (Feature Release)
  - v2.0.0 (Major Update)

Issue Types:
  - Epic
  - Story
  - Task
  - Bug
  - Spike
```

### Kanban Project Setup

```yaml
Project: Customer Support
Key: SUP
Template: Kanban

Components:
  - Technical Support
  - Billing
  - Account Management
  - Feature Requests

Issue Types:
  - Support Ticket
  - Bug
  - Feature Request
  - Task

WIP Limits:
  - To Do: No limit
  - In Progress: 5
  - In Review: 3
  - Done: No limit
```

## Project Archiving

### When to Archive

- Project is completed
- No longer actively maintained
- Historical reference only

### Archiving Process

```
1. Project Settings → Details
2. Scroll to "Archive project"
3. Click "Archive"
4. Confirm action
```

**Note:** Archived projects are read-only but can be restored.

## Project Cloning

### Cloning a Project

```
1. Go to Projects → View all projects
2. Find project to clone
3. Click "..." → "Copy project"
4. Configure:
   - New project name
   - New project key
   - What to copy (issues, versions, components)
5. Click "Copy"
```

## Multi-Project Management

### Project Categories

Organize projects into categories:

```
Categories:
├── Development
│   ├── Web Platform
│   ├── Mobile Apps
│   └── API Services
├── Operations
│   ├── Infrastructure
│   ├── Security
│   └── Monitoring
└── Business
    ├── Marketing
    ├── Sales
    └── Support
```

### Cross-Project Features

**Filters Across Projects:**
```jql
project in (ECOM, MAD, API) AND status = "In Progress"
```

**Dashboards:**
- Create dashboards showing data from multiple projects
- Share insights across teams

## Project Best Practices

### Naming Conventions

```
✅ Good:
- E-commerce Platform (ECOM)
- Mobile App Development (MAD)
- Customer Support (SUP)

❌ Avoid:
- Project 1 (PROJ1)
- Test (TEST)
- Untitled (UNT)
```

### Project Structure

1. **Keep it Simple**: Don't over-complicate with too many components
2. **Consistent Naming**: Use clear, descriptive names
3. **Regular Cleanup**: Archive completed projects
4. **Documentation**: Add project descriptions and README
5. **Access Control**: Grant appropriate permissions

### Component Guidelines

- **Logical Grouping**: Group by feature, team, or technology
- **Limit Number**: 5-10 components per project
- **Clear Ownership**: Assign component leads
- **Consistent Naming**: Use standard naming conventions

## Common Project Scenarios

### Scenario 1: Software Development Team

```yaml
Project: Web Application
Type: Scrum
Team Size: 8 developers

Components:
  - Frontend (React)
  - Backend (Node.js)
  - Database (PostgreSQL)
  - DevOps (AWS)

Sprint Duration: 2 weeks
Release Cycle: Monthly
```

### Scenario 2: IT Support Team

```yaml
Project: IT Helpdesk
Type: Kanban
Team Size: 5 support agents

Components:
  - Hardware Issues
  - Software Issues
  - Network Issues
  - Access Requests

SLA: 24-hour response time
Priority Levels: Critical, High, Medium, Low
```

### Scenario 3: Marketing Campaign

```yaml
Project: Q1 Marketing Campaign
Type: Kanban
Team Size: 4 marketers

Components:
  - Content Creation
  - Social Media
  - Email Marketing
  - Analytics

Timeline: 3 months
Budget Tracking: Custom field
```

## Troubleshooting

### Common Issues

**Issue: Can't create project**
- Check if you have "Create Projects" permission
- Contact Jira administrator

**Issue: Project key already exists**
- Choose a unique project key
- Check archived projects

**Issue: Can't add team members**
- Verify you have admin permissions
- Check user licenses available

## Next Steps

Now that you understand projects, learn about [Issues](./3-Issues.md) to start creating and managing work items.

## Additional Resources

- [Atlassian: Configure a project](https://support.atlassian.com/jira-software-cloud/docs/configure-a-project/)
- [Project templates guide](https://www.atlassian.com/software/jira/templates)
- [Best practices for project setup](https://www.atlassian.com/agile/project-management/project-management-intro)
