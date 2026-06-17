# Pathao Courier SQL Patterns

## Default Datastream Table Pattern

For BigQuery `courier_realtime_datastream` tables, include an `updated_at` predicate for partition elimination when needed.

```sql
WHERE updated_at >= TIMESTAMP('YYYY-MM-DD')
```

For joins across multiple datastream tables, apply partition predicates to each partitioned table where Metabase/BigQuery requires it.

## Standard Orders CTE Snippet

From OPS KPI {{snippet: orders}}:

```sql
WITH orders AS (
  SELECT *
  FROM courier_realtime_datastream.public_orders
  WHERE updated_at IS NOT NULL
  UNION ALL
  SELECT *
  FROM courier_realtime_datastream.public_archived_orders
  WHERE updated_at IS NOT NULL
)
```

## Default Order Analytics Filters

Unless explicitly asked otherwise:

```sql
WHERE merchant_id <> 1
  AND country_id = 1
```

For general date-ranged order analytics, default to `orders.sorted_at` when present.

## Timezone and Operational Day Conventions

**Default: Use UTC+0 (DB default) for all filtering and grouping.**

Rules:
1. Do NOT convert to Asia/Dhaka for date filtering, date grouping, or operational-day logic unless the user explicitly asks for Dhaka/local time.
2. When OUTPUTTING datetime values to stakeholders, convert to Asia/Dhaka (Dhaka time).
3. The operational day boundary: Pathao operations run past midnight Dhaka time. Activities up to approximately 7am Dhaka time (1am UTC) may still be considered previous-day activity. However, since the DB follows UTC+0, using DB/default UTC dates is sufficient for operational day purposes in most cases.
4. Only use `Atlantic/Cape_Verde` (UTC-1) or other timezone hacks if an existing card already uses that pattern and needs to be reproduced exactly.

```sql
-- For stakeholder display (datetime output):
SELECT DATETIME(created_at, "Asia/Dhaka") AS created_at_dhaka
FROM ...

-- For filtering/grouping by date (use UTC+0):
SELECT COUNT(*) 
FROM orders
WHERE DATE(created_at) BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD'
```

## Return/Reverse Aging Pattern

Human Oracle confirmed:
- For return orders, aging starts from the **previous order's (delivery journey) `sorted_at`**.

```sql
CASE
  WHEN o.order_type_id = 2 THEN 
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - previous_order.sorted_at)) / 86400.0
  ELSE
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - o.created_at)) / 86400.0
END AS aging_days
```

Join pattern for return aging:
```sql
LEFT JOIN orders previous_order
  ON o.previous_order_id = previous_order.consignment_id
```

## Returned/Reverse Parcel Grain Warning

A returned physical parcel can have 2 `orders` rows:

```text
Dxxxx = forward-facing journey
Rxxx  = reverse journey for regular return
Pxxx  = reverse journey for reverse pickup
```

When analyzing returns, use `previous_order_id` to link forward and reverse journeys.

## Event Timestamp Pattern

For lifecycle events, prefer `public_order_status_changes.created_at` as the event timestamp.

```sql
SELECT
  o.consignment_id,
  osc.status_id,
  osc.created_at AS event_at
FROM courier_realtime_datastream.public_order_status_changes AS osc
JOIN courier_realtime_datastream.public_orders AS o
  ON o.id = osc.order_id
WHERE osc.updated_at >= TIMESTAMP('YYYY-MM-DD')
  AND o.updated_at >= TIMESTAMP('YYYY-MM-DD')
```

## Open Orders Definition

Human Oracle confirmed: use `on_process = 1` from `hermes_bz_comms.courier_transfer_status`.

```sql
SELECT COUNT(DISTINCT o.consignment_id)
FROM courier_realtime_datastream.public_orders o
JOIN hermes_bz_comms.courier_transfer_status ts
  ON o.transfer_status_id = ts.transfer_status_id
WHERE ts.on_process = 1
  AND o.country_id = 1
```
