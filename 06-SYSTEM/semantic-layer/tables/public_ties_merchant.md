# Table: public_ties_merchant

- **Database**: BigQuery / Metabase database 7 in Dashboard 31
- **Dataset**: `courier_realtime_datastream`
- **Grain**: Merchant-to-business-team assignment row

## Key Columns

- `merchant_id`: Merchant identifier used to filter orders.
- `ties_id`: Business team/segment identifier.

## Dashboard 31 Segment Mapping

- `ties_id = 67`: MTM
- `ties_id = 68`: KAM

## Example

```sql
WHERE merchant_id IN (
  SELECT merchant_id
  FROM courier_realtime_datastream.public_ties_merchant
  WHERE ties_id = 67
)
```

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]]
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[06-SYSTEM/semantic-layer/glossary.md|Glossary]]
