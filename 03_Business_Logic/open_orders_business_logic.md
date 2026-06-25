# Open Orders Business Logic — Human Oracle Notes

Status: Phase 3 Metabase Deep Dive — Open Orders Queries collection (id=156).

## Open Order Status Definition

Human Oracle guidance:
- **Use `on_process` aggregation of `hermes_bz_comms.courier_transfer_status`** for open orders / still-processing orders.
- Do not use hardcoded transfer_status_id lists.

SQL-generation rule:

```sql
SELECT o.consignment_id, ...
FROM courier_realtime_datastream.public_orders o
JOIN hermes_bz_comms.courier_transfer_status ts
  ON o.transfer_status_id = ts.transfer_status_id
WHERE ts.on_process = 1
  AND o.country_id = 1
```

## Processed / Successful Orders

Human Oracle guidance:
- **Use `is_processed = 1`** when the reporting goal is successful / processed volume.
- Do not use `on_process` for completed-volume reporting.
- Merchant-cancelled orders after creation should not be counted as successful/processed volume.

SQL-generation rule:

```sql
SELECT o.consignment_id, ...
FROM courier_realtime_datastream.public_orders o
JOIN hermes_bz_comms.courier_transfer_status ts
  ON o.transfer_status_id = ts.transfer_status_id
WHERE ts.is_processed = 1
  AND o.country_id = 1
```

Observed hardcoded lists in older cards (legacy reference, not for new queries):
- Most open order cards: `IN (8,9,10,11,12,15,16,17,18,19,20,24,27,28,30,31,32,33,34,36,37,38,39,40)`
- Cards 586/589 additionally include `7` and `29`.

## Default Open Order Filters

From card 516 (Total Open Orders) — standard base CTE:

```sql
SELECT
    o.consignment_id,
    COALESCE(NULLIF(o.merchant_id, 1), previous_order.merchant_id) AS merchant_id,
    o.transfer_status_id,
    o.current_hub_id,
    DATE(o.created_at) AS created_at,
    DATE(o.sorted_at) AS sorted_at,
    DATE(o.transfer_status_updated_at) AS transfer_status_updated_at,
    o.pickup_hub_id,
    o.delivery_hub_id,
    o.cash_on_delivery_fee
FROM orders o
LEFT JOIN orders previous_order
  ON o.previous_order_id = previous_order.consignment_id
```

Merchant ID handling for returned parcels:
- When an order is a return (`merchant_id = 1`), use the forward journey's merchant:

```sql
COALESCE(NULLIF(o.merchant_id, 1), previous_order.merchant_id) AS merchant_id
```

C2C exclusion (where applicable):
```sql
AND o.merchant_id <> 80297
```

## Responsible Section Logic

The complex CASE logic in cards 516/517/520 was a dashboard-specific implementation to assign a responsible team against every open order. It is **not a reusable general pattern**.

If this logic is needed, refer to the existing cards in the Open Orders collection (cards 516, 517, 520) which use:
- Specific hub IDs for routing: `168 = Return Hub`, `154 = IR`, `53 = On-Demand`, `372 = Central-Inbound`, `96 = Document-Central`
- Hub operation type (ISD/OSD/RSD) + transfer status combinations for hub classification
- Sub-hub detection via specific hub IDs: `IN (282, 302, 161, 274, 211, 304, 199, 160, 305, 307)`

## Return Order Aging

Human Oracle guidance:
- For return orders, aging must start from the **previous order's sorted_at** (the forward/delivery journey), not the return order's created_at.

SQL-generation rule:

```sql
CASE
  WHEN o.order_type_id = 2 THEN
    (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - previous_order.sorted_at)) / 3600) / 24
  ELSE
    (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - o.created_at)) / 3600) / 24
END AS aging_days
```

## Aging Buckets

From card 1762 (Open Orders by Aging) — aging is measured in hours:

```sql
CASE
  WHEN aging_hours < 12 THEN '<12 hrs'
  WHEN aging_hours >= 12 AND aging_hours < 24 THEN '12-24 hrs'
  WHEN aging_hours >= 24 AND aging_hours < 48 THEN '24-48 hrs'
  WHEN aging_hours >= 48 AND aging_hours < 72 THEN '48-72 hrs'
  ELSE '72+ hrs'
END AS aging_bucket
```

Aging reference timestamp varies by card:
- Cards using `sorted_at` (recommended for operational aging): card 1762
- Cards using `created_at`: cards 516, 518, 519, 520
- For return orders, use `previous_order.sorted_at` regardless of which base timestamp is used.

## Stuck Duration

From card 519 — stuck time from last status update:

```sql
(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - o.transfer_status_updated_at)) / 3600) / 24 AS stuck_for
```

## IMS Ticket Integration

From card 519 and 589 — `ticket_id` in `public_orders` links to IMS/issue tracking:

```sql
o.ticket_id AS issue_id
```

## C-Sort Hold Detection (Card 2670)

Specific to central sort holds:

```sql
o.transfer_status_id IN (32, 38, 33, 37)
```

These are hold-related transfer statuses specific to central sort operations.

## Known Cards in Open Orders Collection

| Card ID | Name | Purpose |
|---------|------|---------|
| 516 | Total Open Orders | Count with section classification |
| 517 | Status Wise Scenario | Count by current status |
| 518 | Open Orders by Created Month | Monthly trend |
| 519 | Open Orders [Consignment] | Consignment-level drilldown |
| 520 | Current Responsible Section Wise | Count by responsible section |
| 1762 | Open Orders by Aging | Bucketed by aging hours |
| 1840 | Sort to Attempt buckets | Sorted-to-first-attempt time |
| 586 | Open Orders Trend | Monthly trend over time |
| 589 | Total Open Orders and ticketed | IMS ticket integration |
| 2670 | C-sort live hold linehaul-wise | CSort hold parcels by linehaul |
