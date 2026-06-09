# Table: public_orders

- **Database**: BigQuery (Data Warehouse)
- **Dataset**: `courier_realtime_datastream`
- **Grain**: One row per parcel order
- **Primary Key**: `order_id`

## Description
The primary operational fact table containing all parcel orders in Pathao Courier.

## Key Columns
| Column Name | Type | Description |
|-------------|------|-------------|
| order_id    | STRING | Unique identifier for the order |
| merchant_id | INT64  | Joins with `public_merchants.merchant_id` |
| status      | STRING | Order status (e.g. `delivered`, `on_process`, `cancelled`) |
| is_full_delivery | BOOLEAN | `true` if the order was fully delivered, `false` for partial |
| created_at  | TIMESTAMP | UTC timestamp of order placement |
| updated_at  | TIMESTAMP | UTC timestamp of latest status update |

## Gotchas & Data Traps
- **Test Data**: Always filter out test accounts: `merchant_id NOT IN (1, 2, 99)`.
- **Partitioning**: This is a partitioned table. You must filter on `created_at` or `updated_at` (e.g. `updated_at >= '2026-06-01'`) to restrict partitions and prevent high query costs.
- **Delivered Status**: `status = 'delivered'` can include partial deliveries. Use `is_full_delivery = true` for complete delivery.
