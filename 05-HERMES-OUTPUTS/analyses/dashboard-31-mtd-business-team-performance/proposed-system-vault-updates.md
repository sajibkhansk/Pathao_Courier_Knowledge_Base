# Proposed System Vault Updates — Dashboard 31: MTD Business Team Performance

Source inspected: Metabase dashboard `31` — `MTD Business Team Performance`
Default dashboard filter: `current_month = ['Yes']`
Inspection artifacts saved in: `05-HERMES-OUTPUTS/analyses/dashboard-31-mtd-business-team-performance/`

## Proposed files to create/update inside `06-SYSTEM/`

### 1) Update `06-SYSTEM/semantic-layer/glossary.md`

Add business-team and dashboard terms:

```md
## Business Team Segments

- **MTM**: Merchant segment identified through `courier_realtime_datastream.public_ties_merchant` where `ties_id = 67`.
- **KAM**: Merchant segment identified through `courier_realtime_datastream.public_ties_merchant` where `ties_id = 68`.
- **Retail / Point / Booking Point**: Dashboard point/retail segment uses `order_type_id IN (16, 18)`. Target table label uses `team_name = 'Retail'`.
- **Processed Orders**: Dashboard business-team performance context counts orders with eligible processed `transfer_status_id` values and usually filters by `DATE(sorted_at)` for MTM/KAM/Total, but Point/Retail cards sometimes use `DATE(created_at)`.
- **Revenue**: Dashboard expected revenue formula sums delivery revenue plus COD fee for eligible processed statuses: `((delivery_fee + additional_charge) - (discount + promo_discount) + cash_on_delivery_fee) / 100`.
- **First Trip Merchant**: Merchant whose first sorted order date is within the acquisition window used by the dashboard. Flow chart uses first order date after the 15th day of the previous month, and current-month first trip metrics isolate those whose first order date is in the current month.
- **Churnback Merchant**: Merchant who had orders before the cutoff date, had no orders in the gap period from cutoff to month start, and has orders in the current month. Dashboard cutoff is 45 days before current month start.
- **Channel Wise Distribution**: Categorization priority from dashboard: Pathao C2C merchant override (`merchant_id = 80297`), CRM/Post Corporate onboarding, KAM/MTM ties, Booking Points (`order_type_id IN (18,16)`), Kiosk (`merchant_type = 1`), then Unguided.
```

### 2) Update `06-SYSTEM/semantic-layer/relationships.md`

Add relationship/join rules:

```md
## Business Team Dashboard Joins

- Dashboard 31 unions active and archived orders for MTD performance:
  - `courier_realtime_datastream.public_orders`
  - `courier_realtime_datastream.public_archived_orders`
- Merchant-team mapping:
  - `orders.merchant_id = public_ties_merchant.merchant_id`
  - MTM: `public_ties_merchant.ties_id = 67`
  - KAM: `public_ties_merchant.ties_id = 68`
- Merchant metadata:
  - Dashboard SQL usually joins `orders.merchant_id = public_merchants.id`.
  - Existing vault docs mention `public_merchants.merchant_id`; confirm actual field naming before standardizing.
- Hub distribution:
  - `orders.delivery_hub_id = public_hubs.id`
  - `public_hubs.hub_operation_type`: `1 = ISD`, `2 = OSD`, `3 = RSD`.
- Target achievement:
  - `data-cloud-production.hermes_bz_comms.business_team_targets.team_name` maps to `MTM`, `KAM`, `Retail`, and `Total`.
  - Target month matched by `DATE(start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)` or by the selected `start_date` month.
- Forecasting:
  - Uses `data-cloud-production.hermes_bz_comms.business_working_days.days` for the current month.
```

### 3) Create `06-SYSTEM/semantic-layer/tables/public_archived_orders.md`

```md
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

## Gotchas

- Dashboard 31 often filters `country_id = 1` and `merchant_id <> 1`; existing vault standard says `merchant_id NOT IN (1,2,99)`. This needs confirmation before making canonical.
- Use date predicates on `sorted_at`, `created_at`, or `updated_at` depending on metric context.
```

### 4) Create `06-SYSTEM/semantic-layer/tables/public_ties_merchant.md`

```md
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
```

### 5) Create `06-SYSTEM/semantic-layer/tables/business_team_targets.md`

```md
# Table: business_team_targets

- **Database/Dataset**: `data-cloud-production.hermes_bz_comms.business_team_targets`
- **Grain**: Monthly target by business team

## Key Columns Used in Dashboard 31

- `team_name`: Values observed include `MTM`, `KAM`, `Retail`, `Total`.
- `start_of_month`: Target month.
- `targets`: Order target.
- `revenue`: Revenue target.

## Usage

- Order target achieved `%` = processed order count / `targets` * 100.
- Revenue target achieved `%` = expected revenue / `revenue` * 100.
```

### 6) Create `06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md`

```md
# Metric: Business Team MTD Processed Orders

## Definition

Count of eligible processed orders for the month-to-date dashboard period, excluding current day.

## Dashboard 31 Default Date Window

When `current_month = 'Yes'`:

```sql
DATE(sorted_at) >= DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
AND DATE(sorted_at) < CURRENT_DATE()
```

Point/Retail cards are an exception in some SQL and use `DATE(created_at)`.

## Eligible Statuses Observed

Primary set used for processed count / target:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42,43,44)
```

Revenue cards often use the same set without `43,44`:

```sql
transfer_status_id IN (8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)
```

## Segment Filters

- MTM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 67)`
- KAM: `merchant_id IN (SELECT merchant_id FROM public_ties_merchant WHERE ties_id = 68)`
- Retail/Point: `order_type_id IN (16,18)`
- Total: no segment filter except country/test merchant filters.
```

### 7) Create `06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md`

```md
# Metric: Business Team MTD Revenue

## Definition

Expected revenue for eligible processed orders in the MTD Business Team Performance dashboard.

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
```

### 8) Create `06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md`

```md
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
```

### 9) Update `06-SYSTEM/query-standards.md`

Add dashboard-specific caveats:

```md
## Dashboard 31 Caveats: MTD Business Team Performance

- Dashboard 31 often unions `public_orders` and `public_archived_orders`; do not query only active orders when reproducing dashboard values.
- Default dashboard `current_month = Yes` usually means month start through yesterday, excluding today.
- Processed/revenue metrics usually use `sorted_at`; Point/Retail cards may use `created_at`.
- Dashboard SQL mostly excludes only `merchant_id <> 1`, while global vault standard says `merchant_id NOT IN (1,2,99)`. Ask before changing dashboard-replica queries.
- Some cards use Metabase database 2 Postgres (`orders`) while most use BigQuery datastream database 7. Prefer Datastream-first unless exact dashboard replication requires the card's original database.
```

## Clarifications needed before writing to `06-SYSTEM/`

1. Should the system vault preserve Dashboard 31 exactly with `merchant_id <> 1`, or should we normalize all business metrics to the existing standard `merchant_id NOT IN (1,2,99)`?
2. Should the segment be named **Retail**, **Point**, or **Booking Point** in the semantic layer? The dashboard card names say Point/Retail, SQL uses `order_type_id IN (16,18)`, and target table uses `team_name = 'Retail'`.

## Confidence

- High confidence on dashboard parameters, card inventory, segment constants (`ties_id` 67/68, `order_type_id` 16/18), main tables, status sets, target tables, revenue formula, and forecasting formula because these were directly extracted from Dashboard 31 SQL.
- Medium confidence on canonical business naming and merchant exclusion standard because dashboard SQL differs from current vault standards.
