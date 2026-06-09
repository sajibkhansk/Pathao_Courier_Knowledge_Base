# Metric: Open Orders

- **Definition**: The volume of orders currently active in the delivery pipeline.
- **Owner**: Pathao Courier Data Team

## Canonical SQL
```sql
SELECT 
  COUNT(order_id) as open_orders_count
FROM `courier_realtime_datastream.public_orders`
WHERE status = 'on_process'
  AND merchant_id NOT IN (1, 2, 99)
  AND updated_at >= '2026-06-01' -- Partition filter
```
