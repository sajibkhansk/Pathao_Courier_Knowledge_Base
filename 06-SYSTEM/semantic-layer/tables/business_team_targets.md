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
