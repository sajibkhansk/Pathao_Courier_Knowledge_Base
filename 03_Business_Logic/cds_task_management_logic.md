# CDS Task Management Logic

Status: canonical
Source: Human Oracle / user-approved feedback promotion
Last reviewed: 2026-06-27

## Meaning of CDS in this workspace

In this Pathao workflow context, **CDS** refers to Pathao's task-management platform / Courier Data Service task-management system, not only CDS SQL snippets or courier enum descriptions.

When a user asks about CDS tasks, task status, unassigned tasks, weekly CDS summaries, or CDS dashboards, treat it as a task-management reporting request unless the user clearly means CDS key-description snippets.

## Primary task source

For direct CDS task-management reporting:

```sql
public.requests
```

Known task-level fields:

- `status` — string task status.
- `created_at` — task creation timestamp.
- `assigned_data_team_user` — assignment owner used for data-team unassigned reporting.
- `assignee_id` — exists but should not be treated as equivalent to `assigned_data_team_user` unless revalidated.

Never store, expose, or echo direct database credentials in the KB, feedback records, prompts, logs, or user-facing replies.

## Observed status values

Observed CDS task statuses include:

- `To Do`
- `In Progress`
- `Blocker`
- `In Review`
- `Closed`
- `Dropped`
- `Rejected`

## Dashboard-aligned open, closed, and unassigned logic

For CDS dashboard-aligned summary reporting, use these definitions by default:

```sql
-- Open / pending statuses
status IN ('To Do', 'In Progress', 'Blocker')

-- Closed statuses
status IN ('In Review', 'Closed', 'Dropped')

-- Dashboard-aligned unassigned tasks
assigned_data_team_user IS NULL
AND status IN ('To Do', 'In Progress', 'Blocker')
```

Important distinction:

- Raw `assigned_data_team_user IS NULL` counts every null-assignment row, including closed/dropped/rejected rows.
- Dashboard-aligned **Unassigned** excludes closed/dropped/rejected rows and only counts open-status null-assignment rows.
- In the validated example, raw null assignment was 19, but dashboard-aligned Unassigned was 6 because 12 Dropped and 1 Rejected rows were excluded.

## CDS Summary reporting rules

For the weekly CDS Summary report:

- Report title: `CDS Summary`
- Sections: `Last Week`, `Overall`, `Long-Open Tasks`
- Last Week: trailing 7-day window ending at report run time.
- Overall: all rows in `public.requests`.
- Tasks Created: row count in scope.
- Tasks Closed: `status IN ('In Review', 'Closed', 'Dropped')`.
- Tasks Pending: `status IN ('To Do', 'In Progress', 'Blocker')`.
- Tasks Unassigned: `assigned_data_team_user IS NULL AND status IN ('To Do', 'In Progress', 'Blocker')`.
- Long-Open Tasks: open/pending tasks created 15 days ago or earlier.

## Reusable SQL filters

```sql
-- Last-week scope
created_at >= NOW() - INTERVAL '7 days'
AND created_at <= NOW()

-- Open / pending tasks
status IN ('To Do', 'In Progress', 'Blocker')

-- Closed tasks
status IN ('In Review', 'Closed', 'Dropped')

-- Dashboard-aligned unassigned tasks
assigned_data_team_user IS NULL
AND status IN ('To Do', 'In Progress', 'Blocker')

-- Long-open tasks
created_at <= NOW() - INTERVAL '15 days'
AND status IN ('To Do', 'In Progress', 'Blocker')
```

## Evidence

- User correction: "In cds, cds is a platform of our task management".
- User requested promotion of the 2026-06-27 04:06 feedback item.
- User shared a CDS dashboard screenshot where Total Task was 244 and Unassigned was 6.
- Direct DB validation found 19 rows with `assigned_data_team_user IS NULL`, but 12 were `Dropped` and 1 was `Rejected`; open-status null rows were 6.
- User requested promotion of the 2026-06-27 12:26 dashboard-aligned unassigned feedback item.

## Related

- [[03_Business_Logic/cds_key_descriptions]] — CDS SQL snippet enum/key descriptions; separate from task-management CDS context.
- [[04_SQL_Patterns/cds_cte_patterns]] — reusable Courier SQL CTE patterns extracted from CDS snippets.
