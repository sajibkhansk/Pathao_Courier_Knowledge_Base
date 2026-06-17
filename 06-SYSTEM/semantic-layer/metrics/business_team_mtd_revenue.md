# Metric: Business Team MTD Revenue

## Definition

Expected revenue for eligible processed orders in Dashboard 31: MTD Business Team Performance.

## Formula Observed

```sql
(
  SUM(CASE WHEN transfer_status_id IN (<eligible_revenue_statuses>)
           THEN (delivery_fee + additional_charge - (discount + promo_discount)) ELSE 0 END)
  +
  SUM(CASE WHEN transfer_status_id IN (<eligible_revenue_statuses>)
           THEN cash_on_delivery_fee ELSE 0 END)
) / 100
```

Equivalent simplified expression:

```sql
((delivery_fee + additional_charge) - (discount + promo_discount) + cash_on_delivery_fee) / 100
```

## Eligible Revenue Statuses Observed

```sql
8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42
```

## Target Achievement

```sql
revenue_target_achieved_pct = expected_revenue * 100 / business_team_targets.revenue
```

## Dashboard 31 Merchant Filter

Use `merchant_id <> 1` for this dashboard process.

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]] — source order fact table
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]] — merchant metadata
- [[06-SYSTEM/semantic-layer/tables/business_team_targets.md|business_team_targets]] — target achievement denominator
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/tables/public_ties_merchant.md|public_ties_merchant]] — team segment mapping
- [[06-SYSTEM/semantic-layer/relationships.md|Table Relationships]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]
