# Jira Boards

## What is a Board?

A board is a visual representation of your team's work. It displays issues as cards that move through columns representing different stages of your workflow.

## Board Types

### Scrum Board
- Sprint-based workflow
- Backlog management
- Sprint planning and tracking
- Velocity charts
- Best for: Teams working in fixed iterations

### Kanban Board
- Continuous flow
- WIP (Work In Progress) limits
- Cumulative flow diagram
- No sprints required
- Best for: Teams with continuous delivery

## Board Comparison

| Feature | Scrum | Kanban |
|---------|-------|--------|
| **Sprints** | Yes | No |
| **Backlog** | Sprint + Product | Single backlog |
| **Planning** | Sprint planning | Continuous |
| **WIP Limits** | Optional | Recommended |
| **Reports** | Velocity, burndown | Cumulative flow, cycle time |
| **Releases** | End of sprint | Continuous |

## Creating a Board

### Create Scrum Board

```
1. Click "Boards" → "Create board"
2. Select "Scrum board"
3. Choose:
   - Board from existing project
   - Board from existing filter
4. Enter board name
5. Select project
6. Click "Create board"
```

### Create Kanban Board

```
1. Click "Boards" → "Create board"
2. Select "Kanban board"
3. Choose source
4. Enter board name
5. Select project
6. Click "Create board"
```

## Board Layout

### Standard Board View

```
┌─────────────────────────────────────────────────────────┐
│  Board Name    [Sprint ▼]  [Quick Filters]  [⚙️ Settings]│
├─────────────────────────────────────────────────────────┤
│                                                          │
│  TO DO        IN PROGRESS    IN REVIEW        DONE      │
│  ┌──────┐    ┌──────┐       ┌──────┐        ┌──────┐  │
│  │PROJ-1│    │PROJ-3│       │PROJ-5│        │PROJ-7│  │
│  │Story │    │Bug   │       │Story │        │Task  │  │
│  └──────┘    └──────┘       └──────┘        └──────┘  │
│  ┌──────┐    ┌──────┐       ┌──────┐        ┌──────┐  │
│  │PROJ-2│    │PROJ-4│       │PROJ-6│        │PROJ-8│  │
│  │Task  │    │Story │       │Bug   │        │Story │  │
│  └──────┘    └──────┘       └──────┘        └──────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Issue Card Information

```
┌─────────────────────────────┐
│ PROJ-123          [Avatar]  │
│ ─────────────────────────── │
│ Add user authentication     │
│                             │
│ 🏷️ backend  🏷️ security     │
│ ⏱️ 5 SP    📅 Due: Dec 25   │
└─────────────────────────────┘
```

## Working with Boards

### Moving Issues

**Drag and Drop:**
```
1. Click and hold issue card
2. Drag to target column
3. Release to drop
4. Issue status updates automatically
```

**Keyboard Navigation:**
```
1. Select issue (click)
2. Press 't' to transition
3. Choose new status
4. Press Enter
```

### Quick Filters

Create filters to show/hide specific issues:

```
Examples:
- Only My Issues
- High Priority
- Bugs Only
- Current Sprint
- Unassigned
```

**Creating Quick Filter:**
```
1. Board Settings → Quick Filters
2. Click "Add quick filter"
3. Enter:
   - Name: "My Issues"
   - JQL: assignee = currentUser()
4. Click "Add"
```

### Swimlanes

Horizontal groupings on your board:

```
Board with Swimlanes:

Expedite (Priority: Highest)
├── TO DO │ IN PROGRESS │ DONE
│   PROJ-1│   PROJ-2    │ PROJ-3

Stories
├── TO DO │ IN PROGRESS │ DONE
│   PROJ-4│   PROJ-5    │ PROJ-6

Bugs
├── TO DO │ IN PROGRESS │ DONE
│   PROJ-7│   PROJ-8    │ PROJ-9
```

**Swimlane Options:**
- None
- Stories
- Assignees
- Epics
- Queries (JQL)
- Subtasks

**Configuring Swimlanes:**
```
1. Board Settings → Swimlanes
2. Select base swimlanes on:
   - Queries
   - Stories
   - Assignees
   - Epics
3. Add custom queries if needed
4. Click "Save"
```

## Board Configuration

### Columns

**Adding Columns:**
```
1. Board Settings → Columns
2. Click "Add column"
3. Enter column name
4. Map to workflow status(es)
5. Set column constraint (optional)
6. Click "Add"
```

**Column Mapping:**
```
Column: "In Progress"
Mapped Statuses:
- In Development
- Code Review
- Testing

This allows multiple workflow statuses 
to appear in one board column
```

**Column Constraints (WIP Limits):**
```
Column: In Progress
Min: 1
Max: 5

Benefits:
- Prevents overload
- Improves focus
- Identifies bottlenecks
```

### Card Layout

**Configuring Card Display:**
```
1. Board Settings → Card layout
2. Select fields to show:
   - Issue key
   - Summary
   - Assignee
   - Priority
   - Labels
   - Story points
   - Due date
3. Drag to reorder
4. Click "Save"
```

### Card Colors

**Color by:**
- Issue type
- Priority
- Assignee
- Queries (custom JQL)

```
Example - Color by Priority:
- Red: Highest
- Orange: High
- Yellow: Medium
- Green: Low
- Blue: Lowest
```

## Scrum Board Features

### Backlog View

```
Backlog
├── Sprint 1 (Active)
│   ├── PROJ-1 (5 SP)
│   ├── PROJ-2 (3 SP)
│   └── PROJ-3 (8 SP)
│   Total: 16 SP
│
├── Sprint 2 (Future)
│   ├── PROJ-4 (5 SP)
│   └── PROJ-5 (3 SP)
│   Total: 8 SP
│
└── Backlog (Unplanned)
    ├── PROJ-6
    ├── PROJ-7
    └── PROJ-8
```

### Sprint Planning

```
1. Go to Backlog
2. Click "Create sprint"
3. Drag issues into sprint
4. Click "Start sprint"
5. Configure:
   - Sprint name
   - Duration (1-4 weeks)
   - Start date
   - Sprint goal
6. Click "Start"
```

### Active Sprint View

```
Sprint Information:
- Sprint name: Sprint 5
- Duration: 2 weeks
- Days remaining: 8
- Story points: 45 / 50
- Issues: 12 / 15 completed
```

### Completing Sprint

```
1. Click "Complete sprint"
2. Review:
   - Completed issues → Done
   - Incomplete issues → Next sprint or backlog
3. Click "Complete"
4. View sprint report
```

## Kanban Board Features

### WIP Limits

```
Column Configuration:
TO DO: No limit
IN PROGRESS: Max 5 (Warning at 4)
IN REVIEW: Max 3 (Warning at 2)
DONE: No limit

Visual Indicators:
- Green: Under limit
- Yellow: At warning
- Red: Over limit
```

### Continuous Delivery

```
Workflow:
Backlog → Selected → In Progress → Review → Done
  ↓         ↓           ↓           ↓        ↓
 Ideas    Planned    Active      Testing  Released
```

## Board Best Practices

### Column Structure

**Simple (3 columns):**
```
To Do → In Progress → Done
```

**Standard (4 columns):**
```
To Do → In Progress → In Review → Done
```

**Detailed (6+ columns):**
```
Backlog → Ready → Dev → Code Review → Testing → Done
```

### WIP Limit Guidelines

```
Formula: WIP Limit = Team Size × 1.5

Example:
Team of 5 developers
WIP Limit = 5 × 1.5 = 7-8 issues

Adjust based on:
- Issue complexity
- Team experience
- Dependencies
```

### Board Hygiene

**Daily:**
- Update issue statuses
- Add comments on progress
- Move completed items to Done

**Weekly:**
- Review blocked items
- Clean up old issues
- Update estimates

**Sprint/Monthly:**
- Archive completed work
- Review board configuration
- Adjust WIP limits if needed

## Board Filters

### Board Query (JQL)

Every board has a filter that determines which issues appear:

```jql
# Default Scrum board filter
project = ECOM 
  AND type in (Story, Bug, Task) 
  AND status != Done
  ORDER BY rank

# Custom filter examples
# Show only high priority
project = ECOM AND priority in (Highest, High)

# Show specific components
project = ECOM AND component = "Frontend"

# Show current sprint only
project = ECOM AND sprint in openSprints()
```

### Editing Board Filter

```
1. Board Settings → General
2. Click "Edit Filter Query"
3. Modify JQL
4. Click "Save"
```

## Multiple Boards

### When to Create Multiple Boards

- Different teams working on same project
- Different workflows (dev vs. ops)
- Different views (management vs. team)
- Different projects combined

### Example Multi-Board Setup

```
Project: E-commerce Platform

Board 1: Development Team
- Filter: component = "Backend"
- Type: Scrum
- Team: Backend developers

Board 2: Frontend Team
- Filter: component = "Frontend"
- Type: Kanban
- Team: Frontend developers

Board 3: Management View
- Filter: priority in (Highest, High)
- Type: Kanban
- Team: All teams
```

## Board Shortcuts

| Shortcut | Action |
|----------|--------|
| `j` | Next issue |
| `k` | Previous issue |
| `t` | Transition issue |
| `a` | Assign issue |
| `i` | Assign to me |
| `m` | Mention user |
| `z` | Toggle fullscreen |
| `n` | Next column |
| `p` | Previous column |

## Board Reports

### Available Reports (Scrum)

1. **Burndown Chart**: Sprint progress
2. **Velocity Chart**: Team capacity over sprints
3. **Sprint Report**: Sprint summary
4. **Epic Burndown**: Epic progress
5. **Release Burndown**: Release progress

### Available Reports (Kanban)

1. **Cumulative Flow Diagram**: Work distribution
2. **Control Chart**: Cycle time analysis
3. **Velocity Chart**: Throughput over time

## Troubleshooting

### Issues Not Appearing on Board

```
Check:
1. Board filter (JQL)
2. Issue status mapping
3. Project permissions
4. Quick filters active
5. Swimlane configuration
```

### Can't Move Issues

```
Check:
1. Workflow permissions
2. Issue status transitions
3. Column mapping
4. Edit permissions
```

### Board Performance Issues

```
Solutions:
1. Limit issues with JQL filter
2. Reduce card fields displayed
3. Use quick filters instead of complex JQL
4. Archive old sprints
5. Split into multiple boards
```

## Next Steps

Learn about [Workflows](./5-Workflows.md) to understand and customize how issues move through your board.

## Additional Resources

- [Atlassian: Use your Scrum board](https://support.atlassian.com/jira-software-cloud/docs/use-your-scrum-board/)
- [Atlassian: Use your Kanban board](https://support.atlassian.com/jira-software-cloud/docs/use-your-kanban-board/)
- [Board configuration guide](https://support.atlassian.com/jira-software-cloud/docs/configure-your-board/)
