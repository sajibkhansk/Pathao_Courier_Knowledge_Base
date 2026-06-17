# Table: public_archived_orders

- **Database**: BigQuery / Metabase database 7 in Dashboard 31
- **Dataset**: `courier_realtime_datastream`
- **Grain**: One row per archived parcel order
- **Common Use**: Union with `public_orders` for historical/MTD business performance reporting.

## Standard Union Pattern

```sql
WITH orders AS (
  SELECT *
  FROM `courier_realtime_datastream.public_orders`
  WHERE updated_at IS NOT NULL

  UNION ALL

  SELECT *
  FROM `courier_realtime_datastream.public_archived_orders`
  WHERE updated_at IS NOT NULL
)
```

## Dashboard 31 Gotchas

- Dashboard 31 uses `merchant_id <> 1` for this process.
- Dashboard 31 usually filters `country_id = 1`.
- Use date predicates on `sorted_at`, `created_at`, or `updated_at` depending on metric context.

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/glossary.md|Glossary]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]
- [[04_SQL_Patterns/cds_cte_patterns.md|CDS CTE Patterns]]
