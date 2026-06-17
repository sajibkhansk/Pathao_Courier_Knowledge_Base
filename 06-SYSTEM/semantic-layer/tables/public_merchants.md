# Table: public_merchants

- **Database**: BigQuery / Metabase database 7
- **Dataset**: `courier_realtime_datastream`
- **Table**: `courier_realtime_datastream.public_merchants`
- **Grain**: One row per registered merchant snapshot/current merchant record
- **Primary Key Observed**: `id`

## Description

Merchant registry containing merchant profile information and configurations. Dashboard 31 uses this table for merchant names, phone-based onboarding joins, merchant type classification, and channel/category distribution.

## Key Columns Observed

| Column Name | Type | Description |
|-------------|------|-------------|
| `id` | INT64 | Internal merchant identifier. Dashboard 31 joins `orders.merchant_id = public_merchants.id`. |
| `name` | STRING(70) | Registered merchant name. Used as `merchant_name` in distribution cards. |
| `merchant_type` | INT64 | Merchant type/category flag. Dashboard 31 labels `merchant_type = 1` as `Kiosk`. |
| `discount` | INT64 | Merchant-level discount field observed in schema. |
| `additional_charge` | INT64 | Merchant-level additional charge field observed in schema. |
| `created_at` | TIMESTAMP | UTC merchant creation timestamp. Dashboard SQL often filters merchant snapshots with `created_at < TIMESTAMP(CURRENT_DATE)`. |
| `updated_at` | TIMESTAMP | UTC update timestamp; commonly filtered with `updated_at IS NOT NULL`. |
| `phone` | STRING(25) | Merchant phone. Used in Dashboard 31 onboarding join when `new_onboards.merchant_id` is null. |
| `merchant_id` | STRING(255) | External/string merchant identifier observed in schema; do not confuse with `public_orders.merchant_id`. |
| `country_id` | INT64 | Country filter. Dashboard 31 often uses `country_id = 1`. |

## Common Dashboard 31 Patterns

Merchant CTE:

```sql
merchants AS (
  SELECT *
  FROM `courier_realtime_datastream.public_merchants`
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

Snapshot guard pattern used in several distribution cards:

```sql
SELECT *
FROM courier_realtime_datastream.public_merchants
WHERE updated_at IS NOT NULL
  AND created_at < TIMESTAMP(CURRENT_DATE)
```

## Important Joins Observed

Orders to merchants:

```sql
orders.merchant_id = public_merchants.id
```

CRM/onboarding fallback join in Channel Wise Distribution:

```sql
LEFT JOIN merchants m
  ON  (p.merchant_id IS NOT NULL AND m.id = p.merchant_id)
  OR  (p.merchant_id IS NULL AND m.phone = p.phone)
```

## Dashboard 31 Category Logic Involving Merchants

Channel Wise Distribution category priority includes merchant metadata:

1. `merchant_id = 80297` → Pathao C2C override, labeled using merchant `name`.
2. CRM/Post Corporate onboarding category from `courier_appsmith.new_onboards`.
3. KAM/MTM from `public_ties_merchant`.
4. Retail / Point / Booking Point from `orders.order_type_id IN (18,16)`.
5. Kiosk from `public_merchants.merchant_type = 1`.
6. Fallback: `Unguided`.

## Gotchas & Data Traps

- **Primary key naming**: Dashboard 31 uses `public_merchants.id` as the join key, not `public_merchants.merchant_id`.
- **`merchant_id` column ambiguity**: `public_merchants.merchant_id` exists as `STRING(255)`, while `public_orders.merchant_id` is `INT64`; use `public_merchants.id` for order joins unless another process explicitly documents otherwise.
- **Dashboard 31 merchant exclusion**: Merchant/order filtering for this process uses `orders.merchant_id <> 1`.
- **General default outside Dashboard 31**: Use standard test-merchant exclusions unless a dashboard/process-specific rule is documented.
