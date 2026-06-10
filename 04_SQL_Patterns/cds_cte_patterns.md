# CDS SQL Snippets — Reusable CTE Patterns

Status: extracted from Courier Data Service `/api/sql-snippets`.

Source:
- Raw source: `02_Data_Dictionary/cds_sql_snippets_raw.json`
- Retrieved count: 33 snippets
- Relevant CDS category: `CTE's`

SQL-generation rule:
- Before writing new base CTEs for common Pathao Courier entities, check these CDS snippets.
- Prefer `courier_realtime_datastream` for stakeholder-facing reporting when a datastream table exists.
- Use `updated_at IS NOT NULL` and `country_id = 1` where the CDS snippet includes them.

## Orders Table Union

CDS snippet id: `5`
Title: `Orders Table`
Description: `Orders table Union`

Use this when historical/archived orders are needed:

```sql
WITH orders AS (
  SELECT *
  FROM `courier_realtime_datastream.public_orders`
  WHERE updated_at IS NOT NULL
    AND country_id = 1

  UNION ALL

  SELECT *
  FROM `courier_realtime_datastream.public_archived_orders`
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

Operational note:
- For recent/current operational reports, `public_orders` alone may be enough.
- For historical completeness, use the union with `public_archived_orders`.

## Merchants

CDS snippet id: `11`

```sql
merchants AS (
  SELECT *
  FROM `courier_realtime_datastream.public_merchants`
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

## Hubs

CDS snippet id: `16`

```sql
hubs AS (
  SELECT *
  FROM courier_realtime_datastream.public_hubs
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

## Clusters

CDS snippet id: `24`

```sql
clusters AS (
  SELECT *
  FROM courier_realtime_datastream.public_clusters
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

## Users

CDS snippet id: `22`

```sql
users AS (
  SELECT *
  FROM courier_realtime_datastream.public_users
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

## Kobiraj Users

CDS snippet id: `21`

```sql
WITH users AS (
  SELECT *
  FROM courier_kobiraj_realtime_dstream.public_users
  WHERE updated_at IS NOT NULL
    AND created_at < TIMESTAMP(CURRENT_DATE)
)
```

## Order Invoices

CDS snippet id: `20`

```sql
order_invoices AS (
  SELECT *
    -- COALESCE(collectable_amount,0) AS collectable_amount,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.collected_amount') AS FLOAT64) / 100,0) AS collected_amount,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.cash_on_delivery_fee') AS FLOAT64) / 100,0) AS cod_fee,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.delivery_fee') AS FLOAT64) / 100,0) AS delivery_cost,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.additional_charge') AS FLOAT64) / 100,0) AS additional_charge,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.discount') AS FLOAT64) / 100,0) AS discount,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.promo_discount') AS FLOAT64) / 100,0) AS promo_discount,
    -- COALESCE(SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.compensation_cost') AS FLOAT64) / 100,0) AS compensation_cost,
    -- SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$.total_weight') AS FLOAT64) AS weight
  FROM courier_realtime_datastream.public_order_invoices
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

Finance JSON note:
- Amounts inside `meta` are divided by `100` in this snippet.
- Use `SAFE_CAST(JSON_EXTRACT_SCALAR(...))` for invoice JSON numeric fields.

## Point Orders

CDS snippet id: `19`

```sql
point_orders AS (
  SELECT consignment_id, is_paid_by_sender, delivery_fee, payout_at
  FROM courier_realtime_datastream.public_point_orders
  WHERE created_at IS NOT NULL
)
```

## Hub Payments

CDS snippet id: `17`

```sql
hub_payments AS (
  SELECT id, hub_id, transaction_id, bank_name, submitted_amount
  FROM courier_realtime_datastream.public_hub_payments
  WHERE updated_at IS NOT NULL
    AND country_id = 1
)
```

## Hub Payment Order Invoices

CDS snippet id: `18`

```sql
hub_payment_order_invoices AS (
  SELECT order_invoice_id, hub_payment_id
  FROM hermes.hub_payment_order_invoices
  WHERE created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY hub_payment_id
    ORDER BY created_at DESC
  ) = 1
)
```

## Payment Invoices

CDS snippet id: `15`

```sql
payment_invoices AS (
  SELECT *
  FROM `courier_realtime_datastream.public_payment_invoices`
  WHERE updated_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```

## Transfer Status

CDS snippet id: `14`

```sql
transfer_status AS (
  SELECT *
  FROM hermes.transfer_status
)
```

Important override:
- For Pathao Courier analytics, current user preference/memory says use `hermes_bz_comms.courier_transfer_status` as the source of truth for transfer status aggregation and key descriptions, rather than old manual JSON or older transfer-status snippets, unless specifically asked otherwise.

## Regions

CDS snippet id: `23`

```sql
regions AS (
  SELECT *
  FROM hermes.regions
  WHERE created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```

## Zones

CDS snippet id: `13`

```sql
zones AS (
  SELECT *
  FROM hermes.zones
  WHERE created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```

## Stores

CDS snippet id: `12`

```sql
stores AS (
  SELECT *
  FROM hermes.stores
  WHERE created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```

## Merchant Users

CDS snippet id: `10`

```sql
merchant_users AS (
  SELECT *
  FROM hermes.merchant_users
  WHERE updated_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```

## Merchant Wallet Infos

CDS snippet id: `25`

```sql
merchant_wallet_infos AS (
  SELECT merchant_id, wallet_id
  FROM hermes.merchant_wallet_infos
  WHERE created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY updated_at DESC
  ) = 1
)
```
