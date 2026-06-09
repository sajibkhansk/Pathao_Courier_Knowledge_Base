# Table: public_merchants

- **Database**: BigQuery (Data Warehouse)
- **Dataset**: `courier_realtime_datastream`
- **Grain**: One row per registered merchant
- **Primary Key**: `merchant_id`

## Description
Merchant registry containing merchant profile information and configurations.

## Key Columns
| Column Name | Type | Description |
|-------------|------|-------------|
| merchant_id | INT64  | Unique merchant identifier |
| name        | STRING | Registered name of the merchant |
| created_at  | TIMESTAMP | UTC timestamp of registration |

## Gotchas & Data Traps
- **Test Merchants**: Always filter out test accounts: `merchant_id NOT IN (1, 2, 99)`.
