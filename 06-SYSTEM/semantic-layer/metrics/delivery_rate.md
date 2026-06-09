# Metric: Delivery Rate

- **Definition**: The percentage of successfully delivered parcels out of total placed orders (excluding test merchants).
- **Owner**: Pathao Courier Data Team

## Canonical SQL
```sql
SELECT 
  SAFE_DIVIDE(
    COUNT(CASE WHEN status = 'delivered' AND is_full_delivery = TRUE THEN 1 END) * 100.0,
    COUNT(*)
  ) as delivery_rate_pct
FROM `courier_realtime_datastream.public_orders`
WHERE merchant_id NOT IN (1, 2, 99)
  AND updated_at >= '2026-06-01' -- Ensure partition filter
```

## Gotchas & Constraints
- Exclude test merchants: `merchant_id NOT IN (1, 2, 99)`.
- Ensure `is_full_delivery = TRUE` is used to represent actual completed deliveries, not partial completions.
