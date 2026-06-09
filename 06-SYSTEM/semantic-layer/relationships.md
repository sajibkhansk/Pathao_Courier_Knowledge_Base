# Table Relationships & Joins

Use these standard join paths to combine tables in `courier_realtime_datastream` (BigQuery):

## 1. Orders and Merchants
- `public_orders` joins `public_merchants` on:
  `public_orders.merchant_id = public_merchants.merchant_id`

## 2. Order Transfer Status Mapping
- To group transfer statuses and get descriptions:
  - Join `public_orders` with `hermes_bz_comms.courier_transfer_status` on:
    `public_orders.transfer_status_id = hermes_bz_comms.courier_transfer_status.id`
  - Use `courier_transfer_status` in `hermes_bz_comms` as the single source of truth for transfer status aggregation and key descriptions.

## Business Team Dashboard Joins

- Dashboard 31 unions active and archived orders for MTD performance:
  - `courier_realtime_datastream.public_orders`
  - `courier_realtime_datastream.public_archived_orders`
- Merchant-team mapping:
  - `orders.merchant_id = public_ties_merchant.merchant_id`
  - MTM: `public_ties_merchant.ties_id = 67`
  - KAM: `public_ties_merchant.ties_id = 68`
- Merchant metadata in Dashboard 31 SQL commonly joins `orders.merchant_id = public_merchants.id`.
- Hub distribution:
  - `orders.delivery_hub_id = public_hubs.id`
  - `public_hubs.hub_operation_type`: `1 = ISD`, `2 = OSD`, `3 = RSD`.
- Target achievement:
  - `data-cloud-production.hermes_bz_comms.business_team_targets.team_name` maps to `MTM`, `KAM`, `Retail`, and `Total`.
  - Target month is matched by `DATE(start_of_month) = DATE_TRUNC(CURRENT_DATE(), MONTH)` or by the selected `start_date` month.
- Forecasting uses `data-cloud-production.hermes_bz_comms.business_working_days.days` for the current month.
