# CDS Task-Management Reporting Patterns

Status: canonical
Source: User-confirmed CDS Summary/reporting rules and dashboard reconciliation
Last reviewed: 2026-06-27

## Scope

Reusable SQL patterns for Pathao CDS task-management reporting from `public.requests`.

Use these patterns with the canonical business definitions in [[03_Business_Logic/cds_task_management_logic]] and the table notes in [[02_Data_Dictionary/cds_public_requests]].

## Base Table

```sql
FROM public.requests r
```

## Time Windows

```sql
-- Last Week / trailing 7 days at report run time
r.created_at >= NOW() - INTERVAL '7 days'
AND r.created_at <= NOW()

-- Long-open threshold confirmed by user
r.created_at <= NOW() - INTERVAL '15 days'
```

## Status Filters

```sql
-- Pending / open statuses
r.status IN ('To Do', 'In Progress', 'Blocker')

-- Closed statuses for CDS Summary
r.status IN ('In Review', 'Closed', 'Dropped')

-- Dashboard-aligned unassigned tasks
r.assigned_data_team_user IS NULL
AND r.status IN ('To Do', 'In Progress', 'Blocker')
```

## Weekly CDS Summary Metrics

```sql
SELECT
  COUNT(*) AS tasks_created,
  COUNT(*) FILTER (WHERE status IN ('In Review', 'Closed', 'Dropped')) AS tasks_closed,
  COUNT(*) FILTER (WHERE status IN ('To Do', 'In Progress', 'Blocker')) AS tasks_pending,
  COUNT(*) FILTER (
    WHERE assigned_data_team_user IS NULL
      AND status IN ('To Do', 'In Progress', 'Blocker')
  ) AS tasks_unassigned
FROM public.requests
WHERE created_at >= NOW() - INTERVAL '7 days'
  AND created_at <= NOW();
```

## Overall CDS Summary Metrics

```sql
SELECT
  COUNT(*) AS tasks_created,
  COUNT(*) FILTER (WHERE status IN ('In Review', 'Closed', 'Dropped')) AS tasks_closed,
  COUNT(*) FILTER (WHERE status IN ('To Do', 'In Progress', 'Blocker')) AS tasks_pending,
  COUNT(*) FILTER (
    WHERE assigned_data_team_user IS NULL
      AND status IN ('To Do', 'In Progress', 'Blocker')
  ) AS tasks_unassigned
FROM public.requests;
```

## Long-Open Task List

```sql
SELECT
  title,
  created_at,
  status
FROM public.requests
WHERE created_at <= NOW() - INTERVAL '15 days'
  AND status IN ('To Do', 'In Progress', 'Blocker')
ORDER BY created_at ASC;
```

## Reporting Pitfalls

- Do not use raw `assigned_data_team_user IS NULL` for the dashboard Unassigned metric.
- Do not use `assignee_id IS NULL` as the unassigned-task indicator unless the app semantics are revalidated.
- Do not include `In Review` in pending/open for CDS Summary after the dashboard-aligned correction; it is treated as closed for this report.
- Keep direct database credentials out of prompts, logs, feedback, and user-facing answers.

## Related

- [[03_Business_Logic/cds_task_management_logic]] — canonical CDS task-management definitions.
- [[02_Data_Dictionary/cds_public_requests]] — table grain and field meanings.
- [[04_SQL_Patterns/cds_cte_patterns]] — separate CDS SQL-snippet CTE patterns for Courier warehouse reporting.
