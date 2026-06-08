# Table: [Table Name]

- **Database**: [e.g. BigQuery / Postgres]
- **Schema/Dataset**: [e.g. public / courier_realtime_datastream]
- **Grain**: [e.g. One row per order / One row per merchant]
- **Primary Key**: [e.g. order_id]

## Description
[Brief description of what this table represents]

## Key Columns
| Column Name | Type | Description / Join Target |
|-------------|------|---------------------------|
| column_a    | INT  | ID of the order           |
| column_b    | STR  | Status of the transit     |

## Gotchas & Data Traps
- [e.g. Always filter on updated_at to eliminate partitions]
- [e.g. Exclude test accounts with merchant_id IN (1, 2, 99)]
