# Return Revamp — Business Logic

Status: documented from Phase 3 Metabase deep dive — Return Revamp collection (id=475).

## Return Lifecycle Statuses

Detected from Return Revamp cards via `public_order_status_changes` with `type = 12` (ORDER_STATUS_CHANGE).

```sql
COUNT(CASE WHEN status_id = 43 AND type = 12 THEN order_id END) AS return_requested_count
COUNT(CASE WHEN status_id = 25 AND type = 12 AND `desc` = 'Return approved by the merchant' THEN order_id END) AS return_approved_count
COUNT(CASE WHEN status_id = 44 AND type = 12 AND `desc` = 'Reattempt requested by the merchant' THEN order_id END) AS reprocess_requested_count
COUNT(CASE WHEN status_id = 11 AND type = 12 AND `desc` LIKE 'Reprocess request approved by%' THEN order_id END) AS reprocess_approved_count
```

Complete lifecycle:

| Step | status_id | type | desc condition | Meaning |
|------|-----------|------|----------------|---------|
| 1 | 43 | 12 | (any) | Return requested by agent |
| 2 | 25 | 12 | `'Return approved by the merchant'` | Merchant approved the return |
| 3 | 44 | 12 | `'Reattempt requested by the merchant'` | Merchant requested reattempt/reprocess |
| 4 | 11 | 12 | `LIKE 'Reprocess request approved by%'` | Reprocess request approved |

## Return Request Cycle Detection

Standard pattern for grouping events per return-request cycle:

```sql
SUM(CASE WHEN status_id = 43 THEN 1 ELSE 0 END) OVER (
  PARTITION BY order_id
  ORDER BY created_at, id
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS cycle_num
```

This starts a new cycle every time `status_id = 43` (Return requested) fires, and labels all subsequent events (approval, reattempt, reprocess) with the same cycle number until the next return request.

## Return Revamp Dashboard

- Dashboard ID: `183` — Return Revamp Dashboard - Ops
- Collection: Return Revamp (475)
- Card 2201: Merchant/Date Wise Report
- Card 2203: order-wise Count Mother (base aggregation)
- Card 2204: Daywise Features
- Card 2205: Hubwise Features
- Card 2292: Hub/Date wise Metrics (uses LAST_VALUE hub_id)
- Card 2301: Hub/Date wise Success Metrics (uses cycle detection)
- Card 2267/2288: Return requested order details with merchant/store info

## Reusable Snippets in Return Revamp

From observed cards:
- `{{snippet: merchants}}` — standard merchants CTE
- `{{snippet: hubs}}` — standard hubs CTE
- `{{snippet: isd/osd/rsd}}` — hub_operation_type CASE label (ISD=1, OSD=2, RSD=3)
- `{{snippet: orders}}` — orders UNION ALL archived_orders CTE
