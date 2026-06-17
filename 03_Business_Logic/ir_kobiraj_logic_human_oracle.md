# IR/Kobiraj Business Logic — Human Oracle Notes

Status: Phase 3 Metabase Deep Dive — IR Queries collection (collection id=37). Status lifecycle documented by Human Oracle. Tag type confirmed. Activity log types pending.

## Source Tables

Primary source: `courier_kobiraj_realtime_dstream.public_issues` (also known as `hermes.kobiraj_issues`)
Supporting tables:
- `courier_kobiraj_realtime_dstream.public_issue_acticity_logs`
- `courier_kobiraj_realtime_dstream.public_teams`
- `courier_kobiraj_realtime_dstream.public_users`
- `courier_kobiraj_realtime_dstream.public_issue_categories`
- `courier_kobiraj_realtime_dstream.public_issue_types`
- `courier_kobiraj_realtime_dstream.public_issue_statuses`
- `courier_kobiraj_realtime_dstream.public_waiting_reasons`
- `courier_kobiraj_realtime_dstream.public_issues_issue_type`
- `courier_kobiraj_realtime_dstream.public_teams_categories`

Alternative schema names (older):
- `hermes.kobiraj_issues`
- `hermes.kobiraj_issue_acticity_logs`
- `hermes.kobiraj_teams`

## Issue Status Lifecycle

Confirmed by Human Oracle:

```
draft → pending → assigned → (waiting_for_ir → assigned_to_ir → solved_by_ir →) solved → closed
```

Detailed lifecycle:
1. **draft** — Some issues (e.g. delivery delay) stay as draft until the parcel's SLA is breached. The issue's `consignment_id` links to the order.
2. **pending** — SLA breached. Waiting for a reporter to be assigned.
3. **assigned** — A reporter is assigned to the issue.
4. **waiting_for_ir** — If IR (Issue Resolution) team's intervention is required. Issues with critical category land directly here, skipping pending/assigned.
5. **assigned_to_ir** — An IR team member is assigned.
6. **solved_by_ir** — IR team has solved the issue.
7. **solved** — Issue is resolved.
8. **closed** — Reporter confirms the resolution is satisfactory and closes the ticket.

Special rules:
- If the reporter self-creates the issue, **pending and assigned may be skipped** (directly to waiting_for_ir or further).
- Issues with **critical category** lands directly to **waiting_for_ir** regardless of workflow.

SQL-generation rule for open/solved grouping:

```sql
CASE
  WHEN status IN ('solved', 'closed', 'solved_by_ir') THEN 'solved_or_closed'
  ELSE 'open'
END AS issue_health
```

## Tag Type

Human Oracle confirmation:
- `tag_type = 1` → Urgent
- `tag_type = 2` → Critical
- `tag_type = 3` → Regular

Reusable label:

```sql
CASE i.tag_type
  WHEN 1 THEN 'Urgent'
  WHEN 2 THEN 'Critical'
  WHEN 3 THEN 'Regular'
END AS issue_priority
```

## Team Mapping (Functional/Lead Teams)

Verified from `hermes.kobiraj_teams` (table id=13633):

| Team ID | Name | Reporting Group |
|---------|------|----------------|
| 2 | Issue_resolution | IR |
| 5 | Cx_team | CX |
| 6 | Kam_team | KAM |
| 7 | First_mile_team | First Mile |
| 8 | Picknreturn | Pick & Return |
| 16 | CX_Lead | CX |
| 17 | IR_Lead | IR |
| 18 | KAM_Lead | KAM |

Observed aggregation from card 463:

```sql
CASE
  WHEN t.id IN (5, 16) THEN 'CX'
  WHEN t.id IN (6, 18) THEN 'KAM'
  WHEN t.id IN (2, 17) THEN 'IR'
  ELSE 'Others'
END AS reporter_team
```

Note: The `courier_kobiraj_realtime_dstream.public_teams` table contains 346 teams, mostly hub/area specific. For functional team grouping, use the case-function above or join by the specific team IDs from `hermes.kobiraj_teams`.

## Activity Logs

Table: `courier_kobiraj_realtime_dstream.public_issue_acticity_logs`

Important fields:
- `status` — filterable values include 'assigned_to_ir', 'assigned'
- `type` — various integer types (observed: 0-28). Human Oracle will provide details later.

## Known IR Card Patterns

### Card 389 — Tickets created (Breakdown)
Common filters: `start_date`, `till_date`, `enable_MTD`, `ir_involved`, `source`
Key logic:
```sql
COUNT(DISTINCT CASE WHEN status IN ('solved', 'closed', 'solved_by_ir') THEN id END) AS closed_count
COUNT(DISTINCT CASE WHEN status NOT IN ('solved', 'closed', 'solved_by_ir') THEN id END) AS open_count
```

### Card 534 — Category-wise Tickets created (SLA tracking)
Key SLA logic:
```sql
-- SLA met:
sla_time >= COALESCE(ir_closed_at, resolved_at)
-- SLA breached:
sla_time < COALESCE(ir_closed_at, resolved_at)
-- Open ticket SLA breached:
sla_time < NOW()
```

### Card 463 — Reporter/Team open issues
Source table: `hermes.kobiraj_issues` with QUALIFY dedupe on id.

### Card 426 — IMS Adoption Checker
Combines courier orders with kobiraj issues to measure IMS ticket rate per merchant.

### Card 466 — Current Days' Solved (Event Detection)

For counting tickets actually solved on a specific day, use `issue_acticity_logs` payload pattern instead of `issues.status`. Reason: `issues.status` may change later (e.g. a solved issue gets reopened), while the activity log records the actual event.

Preferred event-timestamp pattern:

```sql
SELECT COUNT(DISTINCT issue_id)
FROM issue_acticity_logs
JOIN issues ON issue_acticity_logs.issue_id = issues.id
WHERE 1=1
  AND DATE(issue_acticity_logs.created_at) = CURRENT_DATE
  AND (payload -> 'New' ->> 'status') IN ('closed', 'solved', 'solved_by_ir')
```

Current-state pattern (for "how many issues are currently open/solved"):
```sql
CASE
  WHEN status IN ('solved', 'closed', 'solved_by_ir') THEN 'solved_or_closed'
  ELSE 'open'
END AS issue_health
```

### Card 1513, 1480, 480 — Processed Order Status List for Ticket Rate

Cards that compute "tickets per 10k orders" or "IMS tickets vs Orders" filter orders by:

```sql
transfer_status_id IN (
  8,9,10,11,12,13,14,22,23,24,25,26,28,30,31,32,33,37,38,39,40,41,42,43,44
)
```

Human Oracle confirmed: This list represents **processed** orders that are tracked against IMS tickets.

### Card 550 — Open Tickets Aging Breakdown

Aging buckets used (stakeholder-defined, not a standard IR definition):
- 0-2 days: `created_at >= CURRENT_DATE - INTERVAL '2 days'`
- 3-10 days: `created_at < CURRENT_DATE - INTERVAL '2 days'` AND `created_at >= CURRENT_DATE - INTERVAL '10 days'`
- 10+ days: `created_at < CURRENT_DATE - INTERVAL '10 days'`

## Open Items

None.
