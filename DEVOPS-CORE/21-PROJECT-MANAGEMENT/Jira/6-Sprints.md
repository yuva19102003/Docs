# Jira Sprints

## What is a Sprint?

A sprint is a fixed time period (usually 1-4 weeks) during which a team works to complete a set amount of work. Sprints are a core component of Scrum methodology.

## Sprint Lifecycle

```
┌──────────────────────────────────────────────────────┐
│                   Sprint Lifecycle                    │
├──────────────────────────────────────────────────────┤
│                                                       │
│  1. Planning → 2. Execution → 3. Review → 4. Retro  │
│       ↓             ↓             ↓           ↓      │
│   Set goals    Daily work    Demo results  Improve   │
│   Pick issues  Track progress Show features Process  │
│   Estimate     Update board  Get feedback  Adjust    │
│                                                       │
└──────────────────────────────────────────────────────┘
```

## Creating a Sprint

### Step-by-Step

```
1. Navigate to Backlog
2. Click "Create sprint"
3. Sprint appears at top of backlog
4. Drag issues into sprint
5. Click "Start sprint" when ready
```

### Sprint Configuration

```yaml
Sprint Settings:
  Name: "Sprint 5 - User Authentication"
  Duration: 2 weeks
  Start Date: 2024-01-15
  End Date: 2024-01-29
  Sprint Goal: "Complete user login and registration features"
```

## Sprint Planning

### Planning Meeting Agenda

```
Duration: 2-4 hours (for 2-week sprint)

Agenda:
1. Review sprint goal (15 min)
2. Review product backlog (30 min)
3. Team capacity discussion (15 min)
4. Select sprint items (60 min)
5. Break down stories (45 min)
6. Final commitment (15 min)
```

### Capacity Planning

```
Team Capacity Calculation:

Team: 5 developers
Sprint: 2 weeks (10 working days)
Hours per day: 6 (accounting for meetings, etc.)

Total capacity: 5 × 10 × 6 = 300 hours

Or in story points:
Average velocity: 40-50 points per sprint
Plan for: 45 points
```

### Selecting Sprint Items

```
Prioritization Criteria:
1. Business value
2. Dependencies
3. Risk/complexity
4. Team capacity
5. Sprint goal alignment

Example Sprint Backlog:
┌─────────────────────────────────────────┐
│ Sprint 5 Backlog                        │
├─────────────────────────────────────────┤
│ PROJ-101 User registration (8 SP)      │
│ PROJ-102 Email verification (5 SP)     │
│ PROJ-103 Password reset (5 SP)         │
│ PROJ-104 Login page UI (3 SP)          │
│ PROJ-105 Session management (8 SP)     │
│ PROJ-106 Fix login bug (3 SP)          │
│ PROJ-107 Update docs (2 SP)            │
├─────────────────────────────────────────┤
│ Total: 34 story points                  │
└─────────────────────────────────────────┘
```

## Starting a Sprint

### Pre-Start Checklist

- [ ] Sprint goal defined
- [ ] Issues estimated
- [ ] Issues assigned (or ready to assign)
- [ ] Dependencies identified
- [ ] Team capacity confirmed
- [ ] Acceptance criteria clear

### Start Sprint Dialog

```
Sprint Name: Sprint 5
Duration: 2 weeks
Start Date: Today
End Date: Auto-calculated
Sprint Goal: Complete user authentication features

[Start Sprint] [Cancel]
```

## During the Sprint

### Daily Standup

```
Format: 15 minutes, same time daily

Each team member answers:
1. What did I complete yesterday?
2. What will I work on today?
3. Are there any blockers?

Example:
"Yesterday: Completed PROJ-101 user registration
 Today: Starting PROJ-102 email verification
 Blockers: Waiting for API documentation"
```

### Sprint Board

```
Active Sprint Board:

TO DO (5)    IN PROGRESS (3)    REVIEW (2)    DONE (7)
┌────────┐   ┌────────┐        ┌────────┐    ┌────────┐
│PROJ-104│   │PROJ-101│        │PROJ-103│    │PROJ-107│
│PROJ-105│   │PROJ-102│        │PROJ-106│    │PROJ-108│
│PROJ-109│   │PROJ-110│        └────────┘    │PROJ-111│
│PROJ-112│   └────────┘                       │PROJ-113│
│PROJ-113│                                    │PROJ-114│
└────────┘                                    │PROJ-115│
                                              │PROJ-116│
                                              └────────┘

Sprint Progress: 7/17 issues completed (41%)
Story Points: 18/34 completed (53%)
Days Remaining: 6/10
```

### Tracking Progress

**Sprint Burndown Chart:**
```
Story Points
50 │╲
   │ ╲
40 │  ╲___
   │      ╲___
30 │          ╲___
   │              ╲___
20 │                  ╲___
   │                      ╲___
10 │                          ╲___
   │                              ╲___
 0 │────────────────────────────────────╲
   Day 1  2  3  4  5  6  7  8  9  10

   ─── Ideal Burndown
   ─── Actual Burndown
```

### Handling Changes

**Adding Issues Mid-Sprint:**
```
Acceptable:
✅ Critical bugs
✅ Blocking issues
✅ Small tasks (< 2 SP)

Avoid:
❌ New features
❌ Scope creep
❌ Unplanned work

Process:
1. Discuss with team
2. Remove equal work if adding
3. Update sprint goal if needed
4. Document reason
```

**Removing Issues:**
```
Valid Reasons:
- Blocked by external dependency
- Requirements changed
- Higher priority work emerged
- Team capacity reduced

Process:
1. Move to backlog
2. Document reason
3. Inform stakeholders
4. Adjust sprint goal
```

## Sprint Review

### Review Meeting

```
Duration: 1-2 hours
Attendees: Team + Stakeholders

Agenda:
1. Sprint goal review (5 min)
2. Demo completed work (45 min)
3. Discuss incomplete items (10 min)
4. Stakeholder feedback (20 min)
5. Next sprint preview (10 min)
```

### Demo Guidelines

```
For Each Story:
1. Show the feature working
2. Explain user value
3. Highlight technical approach
4. Gather feedback
5. Note action items

Example Demo Script:
"This is PROJ-101, user registration.
 Users can now create accounts with email validation.
 We implemented OAuth integration for social login.
 Let me show you the flow..."
```

## Sprint Retrospective

### Retrospective Meeting

```
Duration: 1-1.5 hours
Attendees: Team only (no stakeholders)

Agenda:
1. Set the stage (5 min)
2. Gather data (15 min)
3. Generate insights (20 min)
4. Decide actions (20 min)
5. Close retrospective (10 min)
```

### Retrospective Format

**Start, Stop, Continue:**
```
START:
- Pair programming for complex features
- Writing more unit tests
- Daily code reviews

STOP:
- Last-minute commits
- Skipping standup updates
- Working in silos

CONTINUE:
- Good documentation
- Helping team members
- Regular communication
```

**What Went Well / What Didn't:**
```
WENT WELL:
✅ Completed all planned stories
✅ Good collaboration
✅ Clear requirements

DIDN'T GO WELL:
❌ Too many meetings
❌ Unclear acceptance criteria
❌ Technical debt accumulated

ACTION ITEMS:
→ Reduce meeting time by 30%
→ Define acceptance criteria in planning
→ Allocate 20% time for tech debt
```

## Completing a Sprint

### Complete Sprint Dialog

```
Sprint 5 Complete

Completed: 15 issues (34 SP)
Incomplete: 2 issues (8 SP)

What to do with incomplete issues?
○ Move to backlog
○ Move to next sprint
● Let me choose for each issue

[Complete Sprint] [Cancel]
```

### Post-Sprint Actions

```
1. Complete sprint in Jira
2. Move incomplete issues
3. Generate sprint report
4. Update velocity metrics
5. Archive sprint
6. Plan next sprint
```

## Sprint Reports

### Sprint Report

```
Sprint 5 Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Goal: Complete user authentication features
Duration: Jan 15 - Jan 29 (2 weeks)

Commitment: 17 issues (42 SP)
Completed: 15 issues (34 SP)
Completion Rate: 88% (issues), 81% (SP)

Added Mid-Sprint: 3 issues (6 SP)
Removed Mid-Sprint: 1 issue (3 SP)

Issues by Status:
- Done: 15
- In Progress: 1
- To Do: 1

Issues by Type:
- Stories: 8
- Tasks: 4
- Bugs: 3
```

### Velocity Chart

```
Story Points Completed per Sprint:

Sprint 1: ████████████████ 32 SP
Sprint 2: ██████████████████ 36 SP
Sprint 3: ██████████████ 28 SP
Sprint 4: ████████████████████ 40 SP
Sprint 5: █████████████████ 34 SP

Average Velocity: 34 SP
Trend: Stable
```

### Burndown Chart Analysis

```
Ideal vs Actual Burndown:

Good Pattern:
- Actual follows ideal closely
- Steady progress
- Completed on time

Warning Signs:
- Flat line (no progress)
- Steep drop at end (last-minute rush)
- Above ideal line (behind schedule)
```

## Sprint Best Practices

### Sprint Length

```
1 Week:
✅ Fast feedback
✅ High urgency
❌ Less planning time
❌ More overhead

2 Weeks (Recommended):
✅ Balanced planning/execution
✅ Sustainable pace
✅ Good for most teams

4 Weeks:
✅ More planning flexibility
❌ Delayed feedback
❌ Risk of scope creep
```

### Sprint Goals

```
✅ Good Sprint Goals:
- "Enable users to create and manage accounts"
- "Improve application performance by 50%"
- "Complete payment integration"

❌ Poor Sprint Goals:
- "Complete 10 stories"
- "Work on stuff"
- "Fix bugs"
```

### Story Point Guidelines

```
Don't Overcommit:
- Use historical velocity
- Account for holidays/PTO
- Leave buffer (10-20%)
- Consider team changes

Example:
Average velocity: 40 SP
Team member on vacation: -8 SP
Buffer (15%): -6 SP
Sprint commitment: 26 SP
```

### Mid-Sprint Adjustments

```
When to Adjust:
✅ Critical production bug
✅ Blocked by external dependency
✅ Team capacity changed

When NOT to Adjust:
❌ Stakeholder requests new feature
❌ Team wants to add "quick wins"
❌ Scope creep
```

## Common Sprint Anti-Patterns

### Sprint Smells

```
❌ Carrying over many issues
   → Overcommitting or poor estimation

❌ Adding lots of work mid-sprint
   → Poor planning or scope creep

❌ Completing everything day 1
   → Undercommitting

❌ Flat burndown until last day
   → Procrastination or blocked work

❌ No sprint goal
   → Lack of focus

❌ Skipping retrospectives
   → Missing improvement opportunities
```

## Troubleshooting

### Sprint Not Starting

```
Check:
- Issues in sprint backlog
- User has permission
- Previous sprint completed
- Board configuration
```

### Can't Complete Sprint

```
Check:
- Active sprint exists
- User is admin/project lead
- All issues transitioned
- No blocking dependencies
```

### Velocity Inconsistent

```
Possible Causes:
- Team size changes
- Estimation inconsistency
- Scope changes
- External dependencies

Solutions:
- Normalize for team size
- Calibrate estimation
- Track scope changes
- Identify patterns
```

## Next Steps

Learn about [Backlogs](./7-Backlogs.md) to understand backlog management and prioritization.

## Additional Resources

- [Atlassian: Plan sprints](https://support.atlassian.com/jira-software-cloud/docs/plan-sprints/)
- [Sprint planning guide](https://www.atlassian.com/agile/scrum/sprint-planning)
- [Sprint retrospectives](https://www.atlassian.com/team-playbook/plays/retrospective)
