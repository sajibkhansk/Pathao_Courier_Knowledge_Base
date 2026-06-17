# Table: business_team_targets

- **Database/Dataset**: `data-cloud-production.hermes_bz_comms.business_team_targets`
- **Grain**: Monthly target by business team

## Key Columns Used in Dashboard 31

- `team_name`: Values observed include `MTM`, `KAM`, `Retail`, and `Total`.
- `start_of_month`: Target month.
- `targets`: Order target.
- `revenue`: Revenue target.

## Usage

- Order target achieved `%` = processed order count / `targets` * 100.
- Revenue target achieved `%` = expected revenue / `revenue` * 100.
- Retail, Point, and Booking Point are the same segment for Dashboard 31; the target table uses `team_name = 'Retail'`.

## Related Notes

- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]]
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]]
- [[06-SYSTEM/semantic-layer/glossary.md|Glossary]]
