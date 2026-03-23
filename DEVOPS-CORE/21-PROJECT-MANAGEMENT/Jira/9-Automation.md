# Jira Automation

## What is Jira Automation?

Automation rules help eliminate repetitive tasks by automatically performing actions based on triggers and conditions.

## Automation Components

### Triggers
Events that start the automation:
- Issue created
- Issue transitioned
- Field value changed
- Comment added
- Sprint started/completed
- Scheduled (daily, weekly)

### Conditions
Criteria that must be met:
- Issue type is Bug
- Priority is High
- Assignee is empty
- Status equals "Done"

### Actions
What happens when triggered:
- Assign issue
- Transition issue
- Add comment
- Send notification
- Create sub-task
- Update field

## Common Automation Examples

### Auto-assign to Reporter
```
Trigger: Issue created
Condition: Assignee is empty
Action: Assign to reporter
```

### Auto-close Old Issues
```
Trigger: Scheduled (daily)
Condition: Status = Resolved AND updated < -30d
Action: Transition to Closed
```

### Notify on High Priority
```
Trigger: Issue created
Condition: Priority = Highest
Action: Send Slack notification
```

## Creating Automation Rules

```
1. Project Settings → Automation
2. Click "Create rule"
3. Select trigger
4. Add conditions (optional)
5. Add actions
6. Name and enable rule
7. Click "Turn it on"
```

## Best Practices

- Start simple
- Test thoroughly
- Document rules
- Monitor execution
- Avoid infinite loops
- Use conditions wisely

## Next Steps

Learn about [Integrations](./10-Integrations.md) to connect Jira with other tools.
