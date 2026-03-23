# Jira Backlogs

## What is a Backlog?

A backlog is a prioritized list of work items (issues) that need to be completed. It serves as the single source of truth for what the team will work on.

## Types of Backlogs

### Product Backlog
- All work for the product
- Continuously refined
- Prioritized by product owner
- Long-term view

### Sprint Backlog
- Work committed for current sprint
- Fixed during sprint
- Managed by development team
- Short-term view

## Backlog Structure

```
Product Backlog
├── Sprint 3 (Active)
│   ├── PROJ-101 (In Progress)
│   ├── PROJ-102 (Done)
│   └── PROJ-103 (To Do)
│
├── Sprint 4 (Planned)
│   ├── PROJ-104
│   ├── PROJ-105
│   └── PROJ-106
│
└── Backlog (Unprioritized)
    ├── High Priority
    │   ├── PROJ-107
    │   └── PROJ-108
    ├── Medium Priority
    │   ├── PROJ-109
    │   └── PROJ-110
    └── Low Priority
        ├── PROJ-111
        └── PROJ-112
```

## Backlog Management

### Accessing the Backlog

```
1. Navigate to your project
2. Click "Backlog" in sidebar
3. View:
   - Active sprint
   - Future sprints
   - Product backlog
```

### Creating Issues in Backlog

```
1. Click "Create" at top of backlog
2. Enter issue summary
3. Press Enter
4. Issue added to backlog
5. Click issue to add details
```

### Prioritizing Issues

**Drag and Drop:**
```
1. Click and hold issue
2. Drag to new position
3. Release to drop
4. Order determines priority
```

**Ranking:**
```
Top = Highest Priority
↓
↓
↓
Bottom = Lowest Priority
```

## Backlog Refinement

### Refinement Meeting

```
Duration: 1-2 hours per week
Attendees: Product Owner + Team
Frequency: Mid-sprint

Agenda:
1. Review upcoming items (30 min)
2. Break down large stories (30 min)
3. Estimate new items (20 min)
4. Clarify requirements (20 min)
5. Update priorities (10 min)
```

### Refinement Activities

**Story Breakdown:**
```
Epic: User Authentication (Too Large)
↓
Break Down Into:
├── Story: User Registration (8 SP)
├── Story: Email Verification (5 SP)
├── Story: Password Reset (5 SP)
└── Story: Social Login (8 SP)
```

**Estimation:**
```
Planning Poker:
1. Present story
2. Team discusses
3. Each member estimates privately
4. Reveal estimates simultaneously
5. Discuss differences
6. Re-estimate until consensus
```

**Acceptance Criteria:**
```
Story: User can reset password

Acceptance Criteria:
- [ ] User clicks "Forgot Password" link
- [ ] User enters email address
- [ ] System sends reset link to email
- [ ] Link expires after 24 hours
- [ ] User creates new password
- [ ] Password meets security requirements
- [ ] User can log in with new password
```

## Backlog Prioritization

### Prioritization Frameworks

**MoSCoW Method:**
```
Must Have:    Critical features
Should Have:  Important but not critical
Could Have:   Nice to have
Won't Have:   Not this time
```

**Value vs Effort Matrix:**
```
High Value, Low Effort  → Do First
High Value, High Effort → Do Second
Low Value, Low Effort   → Do Later
Low Value, High Effort  → Don't Do
```

**RICE Score:**
```
RICE = (Reach × Impact × Confidence) / Effort

Example:
Reach: 1000 users
Impact: 3 (high)
Confidence: 80%
Effort: 5 story points

RICE = (1000 × 3 × 0.8) / 5 = 480
```

### Priority Fields

```
Priority Levels:
- Highest (P0): Critical, blocks everything
- High (P1): Important, do soon
- Medium (P2): Standard priority
- Low (P3): Nice to have
- Lowest (P4): Someday/maybe
```

## Epic Management

### Creating Epics

```
1. Click "Create" → Epic
2. Fill in:
   - Epic Name: "User Authentication"
   - Summary: "Complete user auth system"
   - Description: Detailed requirements
3. Click "Create"
```

### Epic Hierarchy

```
Epic: E-commerce Platform
├── Epic: User Management
│   ├── Story: Registration
│   ├── Story: Login
│   └── Story: Profile
├── Epic: Product Catalog
│   ├── Story: Product Listing
│   ├── Story: Search
│   └── Story: Filters
└── Epic: Shopping Cart
    ├── Story: Add to Cart
    ├── Story: Update Quantity
    └── Story: Checkout
```

### Epic Panel

```
Backlog View with Epic Panel:

┌─────────────────────────────────────┐
│ Epics                               │
├─────────────────────────────────────┤
│ □ User Management (5/10 issues)    │
│ □ Product Catalog (3/8 issues)     │
│ □ Shopping Cart (0/6 issues)       │
└─────────────────────────────────────┘

Filter by Epic:
- Click epic to show only its issues
- Click again to show all issues
```

## Versions and Releases

### Creating Versions

```
1. Backlog → Releases
2. Click "Create version"
3. Enter:
   - Name: "v1.0.0"
   - Start date: 2024-01-01
   - Release date: 2024-03-31
   - Description: "Initial release"
4. Click "Create"
```

### Assigning Issues to Versions

```
Method 1: Drag and Drop
- Drag issue to version in Releases panel

Method 2: Issue Field
- Open issue
- Set "Fix Version" field
- Select version
```

### Release Planning

```
Version: v1.0.0 (Q1 2024)
├── Must Have (MVP)
│   ├── User authentication
│   ├── Product listing
│   └── Basic checkout
├── Should Have
│   ├── Search functionality
│   ├── User profiles
│   └── Order history
└── Could Have
    ├── Wishlist
    ├── Product reviews
    └── Social sharing
```

## Backlog Grooming Best Practices

### Definition of Ready

```
Story is Ready when:
- [ ] Clear user story format
- [ ] Acceptance criteria defined
- [ ] Estimated by team
- [ ] Dependencies identified
- [ ] Testable
- [ ] Small enough for one sprint
- [ ] Value is clear
```

### Story Sizing

```
Too Large (> 13 SP):
❌ "Build entire authentication system"
→ Break down into smaller stories

Just Right (3-8 SP):
✅ "Implement password reset via email"
→ Can be completed in one sprint

Too Small (< 1 SP):
❌ "Fix typo in button text"
→ Combine with other small tasks
```

### Backlog Health

```
Healthy Backlog:
✅ Top 2-3 sprints refined
✅ Clear priorities
✅ Estimated items
✅ No duplicates
✅ Regular grooming
✅ Reasonable size (not too large)

Unhealthy Backlog:
❌ Hundreds of unrefined items
❌ No clear priorities
❌ Many unestimated items
❌ Duplicate issues
❌ Never groomed
❌ Overwhelming size
```

## Backlog Views

### List View

```
Standard backlog list showing:
- Issue key
- Summary
- Assignee
- Priority
- Story points
- Epic link
```

### Epic View

```
Group issues by epic:

Epic: User Management
├── PROJ-101: Registration
├── PROJ-102: Login
└── PROJ-103: Profile

Epic: Product Catalog
├── PROJ-104: Listing
├── PROJ-105: Search
└── PROJ-106: Filters
```

### Version View

```
Group issues by fix version:

v1.0.0
├── PROJ-101 (Done)
├── PROJ-102 (In Progress)
└── PROJ-103 (To Do)

v1.1.0
├── PROJ-104 (To Do)
└── PROJ-105 (To Do)

Unscheduled
├── PROJ-106
└── PROJ-107
```

## Backlog Filters

### Quick Filters

```
Common Filters:
- Only my issues
- Unestimated
- Unassigned
- High priority
- Bugs only
- Ready for sprint
```

### JQL Filters

```jql
# Unestimated stories
type = Story AND "Story Points" is EMPTY

# High priority unassigned
priority = High AND assignee is EMPTY

# Ready for next sprint
labels = ready-for-sprint

# Technical debt
labels = technical-debt ORDER BY priority DESC
```

## Backlog Metrics

### Backlog Size

```
Total Issues: 150
├── Ready: 30 (20%)
├── In Progress: 20 (13%)
├── Needs Refinement: 80 (54%)
└── Blocked: 20 (13%)

Recommendation: Refine top 30-40 issues
```

### Backlog Age

```
Issue Age Distribution:
< 1 month: 40 issues
1-3 months: 60 issues
3-6 months: 30 issues
> 6 months: 20 issues (consider closing)
```

### Backlog Velocity

```
Completion Rate:
Sprint 1: 10 issues
Sprint 2: 12 issues
Sprint 3: 11 issues
Average: 11 issues/sprint

Backlog Burn Rate:
Current backlog: 150 issues
Completion rate: 11 issues/sprint
Time to clear: ~14 sprints (7 months)
```

## Troubleshooting

### Backlog Too Large

```
Solutions:
1. Archive old issues (> 6 months)
2. Close "won't do" items
3. Merge duplicates
4. Move to separate project
5. Implement backlog limits
```

### Can't Prioritize

```
Solutions:
1. Use prioritization framework
2. Involve stakeholders
3. Consider business value
4. Assess technical dependencies
5. Review with product owner
```

### Issues Not Appearing

```
Check:
1. Board filter (JQL)
2. Quick filters active
3. Issue status
4. Sprint assignment
5. Project permissions
```

## Next Steps

Learn about [Reports](./8-Reports.md) to track progress and gain insights from your backlog and sprints.

## Additional Resources

- [Atlassian: Manage your backlog](https://support.atlassian.com/jira-software-cloud/docs/manage-your-backlog/)
- [Backlog refinement guide](https://www.atlassian.com/agile/scrum/backlog-refinement)
- [Prioritization techniques](https://www.atlassian.com/agile/project-management/prioritization)
