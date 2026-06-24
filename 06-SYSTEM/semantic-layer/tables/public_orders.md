# Table: public_orders

- **Database**: BigQuery / Metabase database 7
- **Dataset**: `courier_realtime_datastream`
- **Table**: `courier_realtime_datastream.public_orders`
- **Grain**: One row per active parcel order
- **Primary Key Observed**: `id`
- **Business Identifier**: `consignment_id`

## Description

The primary active operational fact table containing parcel orders in Pathao Courier. Dashboard 31 frequently unions this table with `public_archived_orders` to reproduce historical/MTD business performance values.

## Key Columns Observed

| Column Name | Type | Description |
|-------------|------|-------------|
| `id` | INT64 | Internal order row identifier. |
| `consignment_id` | STRING(30) | Business consignment/order identifier used for dashboard counts. |
| `merchant_id` | INT64 | Merchant key; joins to `public_merchants.id` in Dashboard 31 SQL. |
| `country_id` | INT64 | Country filter. Dashboard 31 usually uses `country_id = 1`. |
| `order_type_id` | INT64 | Order/channel type. Dashboard 31 Retail / Point / Booking Point segment uses `order_type_id IN (16,18)`. |
| `transfer_status_id` | INT64 | Courier transfer/status stage used for processed/revenue eligibility. |
| `created_at` | TIMESTAMP | UTC order creation timestamp. Some Retail/Point/Booking Point cards use this for MTD date filtering. |
| `updated_at` | TIMESTAMP | UTC update timestamp; used as a freshness/partition guard with `updated_at IS NOT NULL`. |
| `sorted_at` | TIMESTAMP | Sorting/processing timestamp; main MTD processed/revenue/forecasting cards use this for date filtering. |
| `current_hub_id` | INT64 | Current hub key where applicable. |
| `pickup_hub_id` | INT64 | Pickup hub key where applicable. |
| `delivery_hub_id` | INT64 | Delivery hub key; joins to `public_hubs.id` for hub distribution. |
| `delivery_fee` | INT64 | Delivery fee amount in paisa/cents-style minor unit. Divide by 100 for BDT-style dashboard revenue. |
| `cash_on_delivery_fee` | INT64 | COD fee in minor unit. Divide by 100 for dashboard revenue. |
| `discount` | INT64 | Discount amount in minor unit. |
| `promo_discount` | INT64 | Promo discount amount in minor unit. |
| `additional_charge` | INT64 | Additional charge in minor unit. |
| `final_fee` | INT64 | Final fee amount; observed in forecasting/first-trip/churnback SQL variants. |

## Common Dashboard 31 Union Pattern

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

## Dashboard 31 MTD Date Patterns

Main MTM/KAM/Total processed and revenue cards usually use `sorted_at` and exclude today:

```sql
DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
AND DATE(sorted_at) < CURRENT_DATE()
```

Retail / Point / Booking Point cards may use `created_at`:

```sql
DATE(created_at) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 day')
AND DATE(created_at) < CURRENT_DATE
```

## Dashboard 31 Processed Status Sets

Primary processed count / target status set observed:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42,43,44)
```

Revenue status set often excludes `43,44`:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
```

## Dashboard 31 Segment Filters

- MTM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 67)`
- KAM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 68)`
- Retail / Point / Booking Point: `order_type_id IN (16,18)`
- Total: no team segment filter, but keeps country and merchant process filters.

## Revenue Formula Observed

```sql
(
  SUM(CASE WHEN transfer_status_id IN (<eligible_revenue_statuses>)
           THEN (delivery_fee + additional_charge - (discount + promo_discount)) ELSE 0 END)
  +
  SUM(CASE WHEN transfer_status_id IN (<eligible_revenue_statuses>)
           THEN cash_on_delivery_fee ELSE 0 END)
) / 100
```

## Gotchas & Data Traps

- **Dashboard 31 merchant filter**: Use `merchant_id <> 1` for this process when reproducing Dashboard 31, per business confirmation.
- **General default**: Use `merchant_id <> 1` to exclude the R-ID/Hermes panel merchant. Do NOT exclude merchants 2 or 99.
- **Active + archived**: Dashboard 31 often requires `public_orders UNION ALL public_archived_orders`; querying only `public_orders` can undercount MTD/historical metrics.
- **Date field differs by metric**: Most processed/revenue/forecasting cards use `sorted_at`; Retail/Point/Booking Point cards may use `created_at`.
- **Timestamps**: Raw timestamps are UTC. Use Asia/Dhaka for business-day context when required.
- **Partition/cost guard**: Use practical date filters and `updated_at IS NOT NULL` patterns for Datastream tables.

## Related Notes

- [[06-SYSTEM/semantic-layer/metrics/delivery_rate.md|Delivery Rate]]
- [[03_Business_Logic/order_status_changes_human_oracle.md|Order Status Changes (OSC) Human Oracle]]
- [[06-SYSTEM/semantic-layer/tables/public_archived_orders.md|public_archived_orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]]
- [[06-SYSTEM/semantic-layer/tables/public_ties_merchant.md|public_ties_merchant]]
- [[06-SYSTEM/semantic-layer/tables/business_team_targets.md|business_team_targets]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]
- [[04_SQL_Patterns/cds_cte_patterns.md|CDS CTE Patterns]]
- [[04_SQL_Patterns/phase2_initial_table_patterns.md|Initial Table Patterns]]
