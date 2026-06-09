# SQL Query Standards & Conventions

These standards ensure consistent calculation of business metrics across the Pathao Courier Data Team.

## 1. Datastream-First Policy
- **Primary Source**: Always query BigQuery `courier_realtime_datastream` dataset tables by default for stakeholder requests.
- **Secondary Source**: Use `hermes_replica` (PostgreSQL) mainly for real-time diagnostics or when explicit real-time transactional needs are specified.
- **Sync latency**: BigQuery datastream refreshes every 2-3 hours. Keep this in mind when comparing with real-time replica numbers.

## 2. Exclude Test Data
- Always exclude test merchant accounts from all business metrics:
  `WHERE merchant_id NOT IN (1, 2, 99)`
- Exclude orders with test flags if any.

## 3. Timezones
- Raw database timestamp fields are stored in UTC.
- For business operations and daily/weekly filters, convert timestamps to local Asia/Dhaka timezone:
  `DATETIME(created_at, "Asia/Dhaka")`
- Return query outputs in the database/Metabase default timezone, not Asia/Dhaka time, unless explicitly requested.

## 4. Completed Deliveries
- Do not count partial deliveries as full completions.
- Filter: `is_full_delivery = true` and `status = 'delivered'`.

## 5. Date Partitioning
- BigQuery tables are partitioned. Always filter on `created_at` or `updated_at` (e.g. `updated_at >= '2026-06-01'`) to restrict partitions and prevent high query costs.
