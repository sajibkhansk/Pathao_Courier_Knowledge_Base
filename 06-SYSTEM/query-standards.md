# SQL Query Standards & Conventions

These standards ensure consistent calculation of business metrics.

## 1. Exclude Test Data
- Always exclude test merchant accounts: `merchant_id NOT IN (1, 2, 99)`.
- Exclude orders with test flags if any.

## 2. Timezones
- Raw timestamp fields are stored in UTC.
- For business operations and daily/weekly filters, convert timestamps to local timezone:
  `DATETIME(created_at, "Asia/Dhaka")`

## 3. Completed Deliveries
- Do not count partial deliveries as full completions.
- Filter: `is_full_delivery = true` and `status = 'delivered'`.

## 4. Date Partitioning
- BigQuery tables are partitioned. Always filter on `created_at` or `updated_at` (e.g. `updated_at >= '2026-06-01'`) to restrict partitions and prevent high query costs.
