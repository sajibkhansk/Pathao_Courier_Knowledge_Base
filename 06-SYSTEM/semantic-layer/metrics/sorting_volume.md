# Metric: Sorting Volume

- **Definition**: The total count of parcels scanned and sorted at hubs.
- **Owner**: Pathao Courier Data Team

## Context Meanings
- **Data Context (SQL)**: Any order that has transitioned through `transfer_status_id = 9` (in the transfer history table).
- **Operations Context**: A physical scan/label print at `pickup_hub_id`.

## Canonical SQL (Data Context)
```sql
SELECT 
  COUNT(DISTINCT order_id) as sorted_volume
FROM `courier_realtime_datastream.public_orders`
WHERE transfer_status_id = 9
  AND merchant_id NOT IN (1, 2, 99)
  AND updated_at >= '2026-06-01' -- Partition filter
```
