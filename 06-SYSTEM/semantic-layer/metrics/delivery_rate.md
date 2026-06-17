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

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]] — source table
- [[03_Business_Logic/order_status_changes_human_oracle.md|Order Status Changes Human Oracle]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]
- [[06-SYSTEM/semantic-layer/glossary.md|Glossary]] (defines "Completed Delivery")
- [[04_SQL_Patterns/phase2_initial_table_patterns.md|Initial Table Patterns]]
