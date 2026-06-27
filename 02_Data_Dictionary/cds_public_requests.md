# CDS `public.requests` Table

Status: canonical
Source: User-confirmed CDS task-management workflow and direct DB schema inspection
Last reviewed: 2026-06-27

## Purpose

`public.requests` is the primary task table for Pathao's CDS task-management platform.

Use this table when the user asks for CDS task counts, task status summaries, unassigned tasks, weekly CDS summaries, dashboard-aligned task metrics, or long-open CDS tasks.

## Grain

One row represents one CDS task/request.

## Key Fields

| Field | Meaning | Reporting note |
|---|---|---|
| `status` | String task status | Use for open/closed/pending classification. |
| `created_at` | Task creation timestamp | Use for last-week and long-open task windows. |
| `assigned_data_team_user` | Data-team assignment owner | Use for dashboard-aligned unassigned logic with open statuses only. |
| `assignee_id` | Secondary assignment-like field | Observed NULL for all inspected rows; do not use as the unassigned indicator unless revalidated. |

## Observed Status Values

Observed values include:

- `To Do`
- `In Progress`
- `Blocker`
- `In Review`
- `Closed`
- `Dropped`
- `Rejected`

## Validated Assignment Rule

Dashboard-aligned unassigned tasks are:

```sql
assigned_data_team_user IS NULL
AND status IN ('To Do', 'In Progress', 'Blocker')
```

Do not use raw `assigned_data_team_user IS NULL` as the dashboard Unassigned number, because it can include closed/dropped/rejected rows.

## Related

- [[03_Business_Logic/cds_task_management_logic]] — canonical business definitions for CDS task-management reporting.
- [[04_SQL_Patterns/cds_task_management_reporting_patterns]] — reusable SQL filters and query patterns for CDS task reports.
- [[03_Business_Logic/cds_key_descriptions]] — CDS SQL snippet enum/key descriptions; separate from task-management CDS.
