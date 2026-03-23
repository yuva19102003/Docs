# Jira Issues

## What is an Issue?

An issue is a single unit of work in Jira. It can represent a user story, task, bug, epic, or any other work item your team needs to track.

## Issue Types

### Standard Issue Types

| Type | Icon | Purpose | Example |
|------|------|---------|---------|
| **Epic** | 🎯 | Large body of work | "User Authentication System" |
| **Story** | 📗 | User requirement | "As a user, I want to reset my password" |
| **Task** | ✓ | Work to be done | "Update API documentation" |
| **Bug** | 🐛 | Defect or problem | "Login button not working on mobile" |
| **Subtask** | 📋 | Part of larger issue | "Write unit tests for login function" |

### Issue Hierarchy

```
Epic (Largest)
  └── Story
       ├── Subtask
       ├── Subtask
       └── Subtask
  └── Story
  └── Bug
  └── Task
```

## Creating Issues

### Quick Create

```
Method 1: Keyboard Shortcut
1. Press 'c' key
2. Fill in required fields
3. Click "Create"

Method 2: Create Button
1. Click "Create" button (top navigation)
2. Fill in issue details
3. Click "Create"

Method 3: From Board
1. Click "+" on board column
2. Enter issue summary
3. Press Enter
```

### Issue Creation Form

```yaml
Required Fields:
  - Project: Select project
  - Issue Type: Story, Task, Bug, etc.
  - Summary: Brief description

Optional Fields:
  - Description: Detailed information
  - Assignee: Who will work on it
  - Reporter: Who created it (auto-filled)
  - Priority: Highest, High, Medium, Low, Lowest
  - Labels: Tags for categorization
  - Sprint: Which sprint (for Scrum)
  - Epic Link: Parent epic
  - Story Points: Effort estimation
  - Due Date: Deadline
  - Components: Project subsection
  - Fix Version: Target release
```

### Creating Different Issue Types

**Creating an Epic:**
```
1. Click "Create"
2. Select Issue Type: Epic
3. Fill in:
   - Epic Name: "User Authentication"
   - Summary: "Implement complete user authentication system"
   - Description: Detailed requirements
4. Click "Create"
```

**Creating a Story:**
```
1. Click "Create"
2. Select Issue Type: Story
3. Fill in:
   - Summary: "User can reset password via email"
   - Description: 
     As a user
     I want to reset my password via email
     So that I can regain access to my account
   - Epic Link: Select parent epic
   - Story Points: 5
4. Click "Create"
```

**Creating a Bug:**
```
1. Click "Create"
2. Select Issue Type: Bug
3. Fill in:
   - Summary: "Login fails with special characters in password"
   - Description:
     Steps to reproduce:
     1. Enter username
     2. Enter password with @ symbol
     3. Click login
     
     Expected: User logs in successfully
     Actual: Error message displayed
   - Priority: High
   - Affects Version: v1.2.0
4. Click "Create"
```

## Issue Fields Explained

### Summary
- Brief, descriptive title
- Appears in lists and boards
- Should be clear and actionable

**Good Examples:**
```
✅ "Add password reset functionality"
✅ "Fix login button alignment on mobile"
✅ "Update user profile API endpoint"

❌ Avoid:
❌ "Bug"
❌ "Fix this"
❌ "Update stuff"
```

### Description

Use Jira's rich text editor or Markdown:

```markdown
## Overview
Brief description of the issue

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Details
- API endpoint: /api/users/reset-password
- Database table: users
- Related issues: PROJ-123, PROJ-456

## Screenshots
!image.png!

## Additional Notes
Any other relevant information
```

### Priority Levels

| Priority | When to Use | SLA Example |
|----------|-------------|-------------|
| **Highest** | Critical production issues | 1 hour |
| **High** | Major features, important bugs | 4 hours |
| **Medium** | Standard work items | 1 day |
| **Low** | Nice-to-have features | 1 week |
| **Lowest** | Future considerations | No SLA |

### Story Points

Estimation of effort using Fibonacci sequence:

```
1 point  = Very simple (< 1 hour)
2 points = Simple (2-4 hours)
3 points = Moderate (1 day)
5 points = Complex (2-3 days)
8 points = Very complex (1 week)
13 points = Extremely complex (consider breaking down)
```

### Labels

Tags for categorization and filtering:

```
Examples:
- technical-debt
- frontend
- backend
- urgent
- customer-request
- security
- performance
- documentation
```

## Editing Issues

### Inline Editing

```
1. Click on any field in issue view
2. Edit the value
3. Click outside or press Enter to save
```

### Bulk Editing

```
1. Select multiple issues (checkbox)
2. Click "..." → "Bulk change"
3. Choose operation:
   - Edit issues
   - Move issues
   - Transition issues
   - Delete issues
4. Select fields to update
5. Apply changes
```

## Issue Linking

### Link Types

| Link Type | Meaning | Example |
|-----------|---------|---------|
| **Blocks** | This issue prevents another | PROJ-1 blocks PROJ-2 |
| **Clones** | Duplicate of another issue | PROJ-3 clones PROJ-4 |
| **Duplicates** | Same as another issue | PROJ-5 duplicates PROJ-6 |
| **Relates to** | General relationship | PROJ-7 relates to PROJ-8 |
| **Causes** | This issue causes another | PROJ-9 causes PROJ-10 |

### Creating Links

```
1. Open issue
2. Click "Link" → "Link issue"
3. Select link type
4. Enter issue key or search
5. Click "Link"
```

### Parent-Child Relationships

```
Epic: PROJ-100 "User Management"
  ├── Story: PROJ-101 "User registration"
  │   ├── Subtask: PROJ-102 "Create registration form"
  │   ├── Subtask: PROJ-103 "Implement validation"
  │   └── Subtask: PROJ-104 "Add email verification"
  ├── Story: PROJ-105 "User login"
  └── Story: PROJ-106 "Password reset"
```

## Issue Transitions

### Workflow States

```
To Do → In Progress → In Review → Done
  ↓         ↓            ↓         ↓
Backlog   Active      Testing   Closed
```

### Transitioning Issues

```
Method 1: Drag and Drop (Board)
- Drag issue card to new column

Method 2: Issue View
1. Open issue
2. Click status button (e.g., "To Do")
3. Select new status
4. Add comment (optional)
5. Click "Transition"

Method 3: Keyboard Shortcut
- Press '.' to open actions menu
- Select transition
```

## Watching and Notifications

### Watching Issues

```
1. Open issue
2. Click "Watch" (eye icon)
3. Receive notifications for:
   - Comments
   - Status changes
   - Field updates
   - Attachments
```

### Notification Settings

```
Profile → Personal Settings → Email
Configure:
- My changes: On/Off
- Watched issues: On/Off
- Mentions: On/Off
- Custom filters: Create rules
```

## Commenting and Mentions

### Adding Comments

```
1. Scroll to Comments section
2. Type your comment
3. Use @ to mention users
4. Use formatting:
   - *bold*
   - _italic_
   - {code}code{code}
   - [link|url]
5. Click "Save"
```

### Mentioning Users

```
@john.doe - Mentions specific user
@team-developers - Mentions entire team
```

### Internal Comments

```
1. Add comment
2. Check "Internal comment" (if available)
3. Only team members can see it
```

## Attachments

### Adding Attachments

```
1. Open issue
2. Click "Attach" or drag files
3. Supported formats:
   - Images: PNG, JPG, GIF
   - Documents: PDF, DOC, XLS
   - Code: TXT, JSON, XML
   - Archives: ZIP, TAR
4. Max size: Usually 10-100MB
```

### Viewing Attachments

```
- Click thumbnail to view
- Click filename to download
- Delete if you have permission
```

## Time Tracking

### Logging Work

```
1. Open issue
2. Click "..." → "Log work"
3. Enter:
   - Time spent: 2h 30m
   - Date started
   - Description
4. Click "Log"
```

### Time Format

```
Examples:
- 1w = 1 week (40 hours)
- 1d = 1 day (8 hours)
- 1h = 1 hour
- 30m = 30 minutes
- 2h 30m = 2 hours 30 minutes
```

### Viewing Time Tracking

```
Issue View:
- Original Estimate: 8h
- Time Spent: 5h
- Remaining: 3h
- Progress bar visualization
```

## Issue Search and Filters

### Quick Search

```
Search by:
- Issue key: PROJ-123
- Summary text: "login bug"
- Assignee: assignee = currentUser()
```

### JQL (Jira Query Language)

```jql
# My open issues
assignee = currentUser() AND status != Done

# High priority bugs
type = Bug AND priority = High

# Issues in current sprint
sprint in openSprints()

# Overdue issues
duedate < now() AND status != Done

# Recently updated
updated >= -7d

# Complex query
project = ECOM 
  AND type in (Story, Bug) 
  AND status = "In Progress" 
  AND assignee in (john.doe, jane.smith)
  ORDER BY priority DESC, created ASC
```

### Saving Filters

```
1. Create JQL query
2. Click "Save as"
3. Enter filter name
4. Choose:
   - Private: Only you
   - Shared: Select groups/users
5. Click "Submit"
```

## Issue Best Practices

### Writing Good Summaries

```
✅ Good:
- "Add user authentication to API"
- "Fix memory leak in image processing"
- "Update checkout flow for mobile users"

❌ Bad:
- "Fix bug"
- "Update code"
- "Do the thing"
```

### Writing Good Descriptions

```markdown
## Problem
Clear description of the issue or requirement

## Solution
Proposed approach or fix

## Acceptance Criteria
- [ ] Specific, testable criteria
- [ ] Another criterion
- [ ] Final criterion

## Technical Notes
- Dependencies
- API changes
- Database migrations

## Testing
- Unit tests required
- Integration tests needed
- Manual testing steps
```

### Using Labels Effectively

```
Categorization:
- frontend, backend, database, api
- bug, feature, enhancement, refactor
- urgent, blocked, needs-review
- customer-facing, internal
- security, performance, ux
```

### Estimation Guidelines

```
Story Points:
1 - Trivial change (typo fix)
2 - Simple feature (add button)
3 - Moderate feature (form validation)
5 - Complex feature (authentication)
8 - Very complex (payment integration)
13+ - Break down into smaller stories
```

## Common Issue Patterns

### User Story Format

```
Title: User can reset password

Description:
As a registered user
I want to reset my password via email
So that I can regain access if I forget it

Acceptance Criteria:
- [ ] User clicks "Forgot Password" link
- [ ] User enters email address
- [ ] System sends reset link to email
- [ ] Link expires after 24 hours
- [ ] User creates new password
- [ ] User can log in with new password
```

### Bug Report Format

```
Title: Login fails with special characters

Environment:
- Browser: Chrome 120
- OS: Windows 11
- Version: v1.2.3

Steps to Reproduce:
1. Navigate to login page
2. Enter username: test@example.com
3. Enter password with @ symbol
4. Click "Login"

Expected Result:
User successfully logs in

Actual Result:
Error message: "Invalid credentials"

Screenshots:
[Attach screenshot]

Additional Info:
- Works fine without special characters
- Affects 15% of users
- Started after v1.2.3 deployment
```

## Troubleshooting

### Common Issues

**Can't create issue:**
- Check project permissions
- Verify required fields are filled
- Check issue type is enabled

**Can't edit issue:**
- Check edit permissions
- Issue may be in restricted status
- Field may be locked

**Can't find issue:**
- Check project access
- Verify issue key is correct
- Issue may be archived

## Next Steps

Learn about [Boards](./4-Boards.md) to visualize and manage your issues effectively.

## Additional Resources

- [Atlassian: What is an issue](https://support.atlassian.com/jira-software-cloud/docs/what-is-an-issue/)
- [JQL Reference](https://support.atlassian.com/jira-software-cloud/docs/use-advanced-search-with-jira-query-language-jql/)
- [Issue linking guide](https://support.atlassian.com/jira-software-cloud/docs/link-issues/)
