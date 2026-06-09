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
