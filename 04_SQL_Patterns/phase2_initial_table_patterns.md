# Phase 2 Initial Table SQL Patterns

Status: initial patterns documented from known Pathao Courier data navigation conventions and table metadata.

## Default Datastream Table Pattern

For BigQuery `courier_realtime_datastream` tables, include an `updated_at` predicate for partition elimination when needed.

```sql
WHERE updated_at >= TIMESTAMP('YYYY-MM-DD')
```

For joins across multiple datastream tables, apply partition predicates to each partitioned table where Metabase/BigQuery requires it.

## Default Order Analytics Filters

Unless the user explicitly asks otherwise:

```sql
WHERE merchant_id <> 1
  AND country_id = 1
```

For general date-ranged order analytics, default to `orders.sorted_at` when present because this is when a parcel is physically in Pathao's system and SLA countdown starts.

Default operational-day convention:
- Pathao Courier operations run overnight; the operational day is considered **6:00 AM to 6:00 AM**.
- Even though operations are in Dhaka, Bangladesh, use the database default timestamp/date context (`UTC+0`) for default date filtering/aggregation unless the user explicitly requests a Dhaka-local calendar day.
- Parcels processed/handled after 12:00 AM Dhaka time can still belong to the previous operations date/day.
- For ordinary stakeholder date aggregation, use the DB/default timestamp treatment on `sorted_at`; do not automatically convert to `Asia/Dhaka` unless explicitly requested.

Default pattern:

```sql
WHERE DATE(sorted_at) BETWEEN DATE('YYYY-MM-DD') AND DATE('YYYY-MM-DD')
```

If a metric explicitly requires a 6AM Dhaka operational-day bucketing, label it clearly and use an adjusted operational date expression rather than silently changing the default.

Do not add this by habit unless needed/requested:

```sql
-- Do not add by default:
-- deleted_at IS NULL
```

## Returned/Reverse Parcel Grain Warning

A returned physical parcel can have two `orders` rows:

```text
Dxxxx = forward-facing journey
Rxxx = reverse journey for regular return
Pxxx = reverse journey for reverse pickup
```

When analyzing returns/reverse pickup, avoid blindly counting `orders.id` as physical parcel count.

## Event Timestamp Pattern

For lifecycle events, prefer `public_order_status_changes.created_at` as the event timestamp and join back to `public_orders` for merchant/country/consignment context.

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
