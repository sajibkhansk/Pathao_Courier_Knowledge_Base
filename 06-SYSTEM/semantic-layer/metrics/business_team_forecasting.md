# Metric: Business Team Forecasting

## Definition

Forecasted month-end orders based on MTD daily average and configured business working days.

## Formula Observed

```sql
daily_average = COUNT(DISTINCT consignment_id) / (EXTRACT(DAY FROM CURRENT_DATE()) - 1)
forecasted_orders = daily_average * business_working_days.days
forecast_target_achieved_pct = forecasted_orders * 100 / business_team_targets.targets
```

## Date Window

Uses current month through yesterday:

```sql
DATE(sorted_at) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
AND DATE(sorted_at) < CURRENT_DATE()
```

## Segment Variants

- Global/Total: no KAM/MTM ties filter.
- KAM: `ties_id = 68`.
- MTM: `ties_id = 67`.

## Dashboard 31 Merchant Filter

Use `merchant_id <> 1` for this dashboard process.

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]] — source table
- [[06-SYSTEM/semantic-layer/tables/public_ties_merchant.md|public_ties_merchant]] — team segment mapping
- [[06-SYSTEM/semantic-layer/tables/business_team_targets.md|business_team_targets]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/query-standards.md|SQL Query Standards]]
