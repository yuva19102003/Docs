# Jira Workflows

## What is a Workflow?

A workflow defines the lifecycle of an issue from creation to completion. It consists of statuses (stages) and transitions (movements between stages).

## Workflow Components

### Statuses

States that an issue can be in:

```
Common Statuses:
- To Do
- In Progress
- In Review
- Done
- Blocked
- Cancelled
```

### Transitions

Actions that move issues between statuses:

```
Transitions:
- Start Progress (To Do → In Progress)
- Submit for Review (In Progress → In Review)
- Approve (In Review → Done)
- Reject (In Review → In Progress)
- Block (Any → Blocked)
```

### Workflow Diagram

```
┌─────────┐
│  TO DO  │
└────┬────┘
     │ Start Progress
     ↓
┌─────────────┐
│ IN PROGRESS │←──────┐
└──────┬──────┘       │
       │ Submit       │ Reject
       ↓              │
┌─────────────┐       │
│  IN REVIEW  │───────┘
└──────┬──────┘
       │ Approve
       ↓
┌─────────────┐
│    DONE     │
└─────────────┘
```

## Default Workflows

### Simple Workflow

```
To Do → In Progress → Done
```

**Use Case:** Small teams, simple projects

### Standard Workflow

```
To Do → In Progress → In Review → Done
                ↓
            Blocked
```

**Use Case:** Most software development teams

### Complex Workflow

```
Backlog → Selected → In Development → Code Review
                                          ↓
                                      Testing
                                          ↓
                                    QA Approved
                                          ↓
                                      Deployed
                                          ↓
                                       Done
```

**Use Case:** Large teams with strict processes

## Viewing Workflows

### View Project Workflow

```
1. Project Settings → Workflows
2. Click workflow name
3. View diagram or text mode
```

### Workflow Diagram View

```
Visual representation showing:
- All statuses (boxes)
- All transitions (arrows)
- Transition conditions
- Post functions
```

## Customizing Workflows

### Team-Managed Projects

**Adding Status:**
```
1. Board Settings → Columns
2. Click "Add column"
3. Enter status name
4. Click "Add"
```

**Editing Transitions:**
```
1. Board Settings → Columns
2. Drag columns to reorder
3. Statuses automatically connect
```

### Company-Managed Projects

**Creating Custom Workflow:**
```
1. Jira Settings → Issues → Workflows
2. Click "Add workflow"
3. Enter workflow name
4. Click "Add"
5. Design workflow:
   - Add statuses
   - Add transitions
   - Configure conditions
6. Publish workflow
7. Associate with project
```

## Workflow Statuses

### Status Categories

Every status belongs to a category:

| Category | Meaning | Examples |
|----------|---------|----------|
| **To Do** | Not started | Backlog, To Do, Open |
| **In Progress** | Work ongoing | In Progress, In Review, Testing |
| **Done** | Completed | Done, Closed, Resolved |

### Creating Custom Status

```
1. Jira Settings → Issues → Statuses
2. Click "Add status"
3. Enter:
   - Name: "Code Review"
   - Category: In Progress
   - Description: "Awaiting code review"
4. Click "Add"
```

### Status Best Practices

```
✅ Good Status Names:
- Clear and descriptive
- Action-oriented
- Consistent naming
- Examples: "In Development", "Awaiting Review", "Ready for Deploy"

❌ Avoid:
- Vague names: "Status 1", "Phase 2"
- Too many statuses (keep under 10)
- Duplicate meanings
```

## Workflow Transitions

### Transition Properties

```yaml
Transition: "Start Progress"
From Status: To Do
To Status: In Progress
Screen: None
Conditions:
  - User has "Transition Issues" permission
  - Issue is assigned
Validators:
  - Field "Assignee" is not empty
Post Functions:
  - Assign to current user
  - Add comment
  - Update field
```

### Transition Screens

Forms shown during transition:

```
Example: "Resolve Issue" Transition
Screen Fields:
- Resolution (Required)
- Comment (Optional)
- Fix Version (Optional)
- Time Spent (Optional)
```

### Conditions

Rules that must be met to show transition:

```
Common Conditions:
- User is in specific role
- User is assignee
- User is reporter
- Issue has specific field value
- Sub-tasks are resolved
```

**Example:**
```
Transition: "Deploy to Production"
Conditions:
- User is in "Deployers" role
- All sub-tasks are Done
- Field "QA Status" = "Approved"
```

### Validators

Checks performed before transition completes:

```
Common Validators:
- Required fields are filled
- Field has specific value
- User has permission
- Parent issue is in specific status
```

**Example:**
```
Transition: "Close Issue"
Validators:
- Resolution field is not empty
- All sub-tasks are closed
- Time spent is logged
```

### Post Functions

Actions performed after transition:

```
Common Post Functions:
- Update field value
- Assign issue
- Create sub-task
- Send notification
- Trigger webhook
- Add comment
```

**Example:**
```
Transition: "Start Sprint"
Post Functions:
1. Set "Sprint Start Date" to current date
2. Assign to current user
3. Send email to team
4. Add comment "Sprint started"
```

## Workflow Examples

### Bug Workflow

```
Open → In Progress → Fixed → Verified → Closed
  ↓                    ↓
Duplicate          Reopened
  ↓                    ↓
Closed              In Progress
```

### Feature Workflow

```
Backlog → Planned → In Development → Code Review
                                          ↓
                                      Merged
                                          ↓
                                      Testing
                                          ↓
                                    Deployed
                                          ↓
                                      Done
```

### Support Ticket Workflow

```
New → Assigned → In Progress → Waiting for Customer
                      ↓              ↓
                  Resolved ←─────────┘
                      ↓
                   Closed
```

## Workflow Schemes

### What is a Workflow Scheme?

Maps issue types to workflows:

```
Workflow Scheme: "Software Development"

Issue Type Mappings:
- Story → Feature Workflow
- Bug → Bug Workflow
- Task → Simple Workflow
- Epic → Epic Workflow
```

### Creating Workflow Scheme

```
1. Jira Settings → Issues → Workflow schemes
2. Click "Add workflow scheme"
3. Enter scheme name
4. Add issue type mappings:
   - Select issue type
   - Select workflow
   - Click "Add"
5. Click "Create"
```

### Assigning to Project

```
1. Project Settings → Workflows
2. Click "Switch scheme"
3. Select workflow scheme
4. Click "Associate"
5. Migrate existing issues (if needed)
```

## Advanced Workflow Features

### Parallel Transitions

Multiple paths from one status:

```
In Progress
    ├─→ Submit for Review
    ├─→ Block
    ├─→ Cancel
    └─→ Back to To Do
```

### Looping Transitions

Return to previous status:

```
In Review
    ├─→ Approve → Done
    └─→ Reject → In Progress
```

### Global Transitions

Available from any status:

```
Any Status
    ├─→ Block
    ├─→ Cancel
    └─→ Reopen
```

## Workflow Automation

### Automated Transitions

```
Example: Auto-close after 30 days
Rule:
- Trigger: Scheduled (daily)
- Condition: Status = "Resolved" AND updated < -30d
- Action: Transition to "Closed"
```

### Webhook Integration

```
Example: Notify Slack on deployment
Post Function:
- Trigger: Transition to "Deployed"
- Action: Send webhook to Slack
- Payload: Issue key, summary, assignee
```

## Workflow Best Practices

### Keep It Simple

```
✅ Good: 4-6 statuses
❌ Too Complex: 15+ statuses

Simple is better:
To Do → In Progress → Review → Done
```

### Clear Naming

```
✅ Good:
- "Awaiting Code Review"
- "Ready for Testing"
- "Deployed to Production"

❌ Confusing:
- "Status 1"
- "Phase A"
- "Step 3"
```

### Logical Flow

```
✅ Linear progression:
Backlog → Dev → Review → Test → Deploy → Done

❌ Confusing loops:
Status A ⇄ Status B ⇄ Status C ⇄ Status A
```

### Minimize Transitions

```
✅ Essential transitions only:
- Start work
- Submit for review
- Complete

❌ Too many options:
- 10+ transitions from one status
- Redundant paths
```

## Workflow Migration

### Changing Workflows

```
1. Create new workflow
2. Test in separate project
3. Create migration plan
4. Communicate to team
5. Perform migration:
   - Map old statuses to new
   - Update automation rules
   - Update reports
6. Monitor and adjust
```

### Status Mapping

```
Old Workflow → New Workflow

Open → To Do
In Progress → In Development
Review → Code Review
Testing → QA Testing
Done → Completed
```

## Troubleshooting

### Issue Stuck in Status

```
Check:
1. Available transitions
2. Transition conditions
3. User permissions
4. Required fields
5. Validators
```

### Transition Not Visible

```
Check:
1. Workflow configuration
2. User role permissions
3. Conditions on transition
4. Issue current status
```

### Workflow Changes Not Applied

```
Solutions:
1. Publish workflow (draft mode)
2. Clear browser cache
3. Check workflow scheme association
4. Verify project uses correct scheme
```

## Next Steps

Learn about [Sprints](./6-Sprints.md) to understand sprint planning and execution in Scrum projects.

## Additional Resources

- [Atlassian: Working with workflows](https://support.atlassian.com/jira-cloud-administration/docs/working-with-workflows/)
- [Workflow best practices](https://www.atlassian.com/agile/project-management/workflow)
- [Advanced workflow configuration](https://support.atlassian.com/jira-cloud-administration/docs/advanced-workflow-configuration/)
