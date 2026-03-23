# Getting Started with Jira

## Creating a Jira Account

### Sign Up Options

1. **Jira Cloud (Recommended for beginners)**
   - Visit: https://www.atlassian.com/software/jira
   - Click "Get it free"
   - Sign up with email or Google account
   - Free for up to 10 users

2. **Jira Data Center**
   - Self-hosted option
   - For large enterprises
   - Requires infrastructure setup

### Account Setup Steps

```bash
1. Go to https://www.atlassian.com/software/jira/free
2. Click "Sign up for free"
3. Enter your email address
4. Verify your email
5. Create your site name (e.g., yourcompany.atlassian.net)
6. Choose your product (Jira Software)
7. Complete the setup wizard
```

## Jira Interface Overview

### Main Navigation

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Your Work  Projects  Filters  Dashboards  [👤] │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Sidebar          Main Content Area        Right Panel  │
│  ┌──────┐        ┌──────────────────┐    ┌──────────┐ │
│  │      │        │                  │    │          │ │
│  │ Nav  │        │   Work Area      │    │ Details  │ │
│  │      │        │                  │    │          │ │
│  └──────┘        └──────────────────┘    └──────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Top Navigation Bar

- **Your Work**: View all issues assigned to you
- **Projects**: Access all your projects
- **Filters**: Saved searches and custom filters
- **Dashboards**: Visual reports and metrics
- **Apps**: Marketplace apps and integrations
- **Create**: Quick button to create new issues

### Left Sidebar

- **Roadmap**: Timeline view of epics and releases
- **Backlog**: Product and sprint backlogs
- **Board**: Scrum or Kanban board
- **Reports**: Sprint reports and analytics
- **Issues**: List view of all issues
- **Components**: Logical groupings of issues
- **Releases**: Version management

## Basic Navigation

### Accessing Your Work

```
1. Click "Your Work" in top navigation
2. View:
   - Worked on: Recently viewed/edited issues
   - Viewed: Recently viewed items
   - Assigned to me: Your current assignments
   - Starred: Favorited items
```

### Searching for Issues

**Quick Search**
```
1. Click search icon (🔍) or press "/"
2. Type issue key (e.g., PROJ-123) or keywords
3. Select from results
```

**Advanced Search (JQL)**
```
1. Click "Filters" → "Advanced issue search"
2. Use Jira Query Language (JQL)
3. Example: assignee = currentUser() AND status = "In Progress"
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `g` + `d` | Go to Dashboard |
| `g` + `i` | Go to Issues |
| `c` | Create issue |
| `/` | Quick search |
| `?` | View all shortcuts |
| `.` | Open issue actions |
| `e` | Edit issue |
| `a` | Assign issue |

## User Profile Setup

### Configuring Your Profile

```
1. Click your avatar (top-right)
2. Select "Profile"
3. Update:
   - Profile picture
   - Full name
   - Email preferences
   - Time zone
   - Language
```

### Notification Settings

```
1. Click avatar → "Personal settings"
2. Go to "Email" section
3. Configure:
   - Issue updates
   - Mentions
   - Watching
   - Custom notifications
```

### Setting Up Preferences

```
1. Avatar → "Personal settings"
2. Configure:
   - Default dashboard
   - Issue view preferences
   - Keyboard shortcuts
   - Autowatch settings
```

## Understanding Permissions

### Permission Levels

1. **Browse Projects**: View project and issues
2. **Create Issues**: Create new issues
3. **Edit Issues**: Modify existing issues
4. **Assign Issues**: Assign work to team members
5. **Administer Projects**: Full project control
6. **Jira Administrators**: System-wide control

### Checking Your Permissions

```
1. Go to Project Settings
2. Click "Permissions"
3. View your role and permissions
4. Contact admin if you need additional access
```

## First-Time Setup Checklist

- [ ] Create Jira account
- [ ] Set up profile with photo and details
- [ ] Configure notification preferences
- [ ] Learn keyboard shortcuts
- [ ] Explore the interface
- [ ] Join or create your first project
- [ ] Create your first issue
- [ ] Customize your dashboard
- [ ] Install Jira mobile app (optional)

## Jira Mobile App

### Installation

```
iOS: Download from App Store
Android: Download from Google Play
```

### Mobile Features

- View and update issues
- Comment and mention team members
- Receive push notifications
- Quick issue creation
- Offline access to recent issues

## Common First-Time Questions

**Q: What's the difference between Jira Cloud and Data Center?**
- Cloud: Hosted by Atlassian, easier setup, automatic updates
- Data Center: Self-hosted, more control, requires infrastructure

**Q: How many projects can I create?**
- Free plan: Unlimited projects for up to 10 users
- Paid plans: Unlimited projects and users

**Q: Can I import data from other tools?**
- Yes, Jira supports imports from Trello, Asana, CSV, and more

**Q: Is training available?**
- Yes, Atlassian University offers free courses
- Community forums and documentation available

## Next Steps

Now that you're familiar with the basics, proceed to [Projects](./2-Projects.md) to learn how to create and configure your first project.

## Additional Resources

- [Atlassian University](https://university.atlassian.com/)
- [Jira Documentation](https://support.atlassian.com/jira-software-cloud/)
- [Community Forums](https://community.atlassian.com/)
- [Jira Keyboard Shortcuts](https://support.atlassian.com/jira-software-cloud/docs/keyboard-shortcuts/)
