# Merchant Business Logic — Human Oracle Notes

Status: documented from Human Oracle answers during Phase 2.

Scope:
- Table: `courier_realtime_datastream.public_merchants`
- Related: CRM system, KAM assignment, merchant panel vs Hermes panel source.
- Related CDS: `03_Business_Logic/cds_key_descriptions.md` for `merchant_type` mapping.

## Active Merchant Volume

Human Oracle:
- Pathao Courier has **20k+ active merchants** per month.
- Only **3k–4k merchants** drive most of the parcel volume.

## KAM Assignment

Human Oracle:
- Merchants who give **300+ parcels in a month** are assigned a **KAM (Key Account Manager)** from the **upcoming month**.
- `kam_id` in `public_merchants` maps against `public_users`.

SQL join pattern:

```sql
LEFT JOIN courier_realtime_datastream.public_users u
  ON m.kam_id = u.id
```

## CRM System

Human Oracle:
- A CRM system is used to manage KAM merchants better.
- Database name: `AppSmith-Write-DB`
- Schema: `public`
- More details about CRM tables and data to be provided later.

SQL-generation note:
- The `AppSmith-Write-DB > public` schema contains CRM tables for KAM merchant management.
- Treat CRM joins as a future enrichment once the schema is documented.

## Merchant Classification Source of Truth

Human Oracle:
- **Do NOT use** `merchant_category`, `product_category`, or `category` for stakeholder reporting.
  - `merchant_category`: manually maintained, not reliable.
  - `product_category`: manually maintained, not reliable.
  - `category`: not used at all.
- **For categorization, use `merchant_type`.**

Source for `merchant_type` mapping:
- CDS snippet id `9` (`Merchant Type Keys Desc`).
- CDS snippet id `26` (`merchant type` case function).
- See `03_Business_Logic/cds_key_descriptions.md`.

Reusable label:

```sql
CASE m.merchant_type
  WHEN 0 THEN 'Regular_merchant'
  WHEN 1 THEN 'C2C_Kiosk_merchant'
  WHEN 2 THEN 'B2B_merchant'
  WHEN 3 THEN 'C2C_agent'
  WHEN 4 THEN 'corporate_merchant'
  WHEN 5 THEN 'Book_merchant'
  WHEN 6 THEN 'Point_merchant'
  WHEN 7 THEN 'Post_paid_merchant'
  ELSE 'Other'
END AS merchant_type_label
```

## `source` Field

Human Oracle mapping:

```text
source = 1 => merchant panel
source = 2 => hermes panel
```

SQL-generation rule:

```sql
CASE m.source
  WHEN 1 THEN 'merchant_panel'
  WHEN 2 THEN 'hermes_panel'
  ELSE CONCAT('Unknown: ', CAST(m.source AS STRING))
END AS source_label
```

Operational meaning:
- Source means the system through which the merchant was onboarded/registered.
- Merchant panel is the primary self-service platform.
- Hermes panel is the internal operations panel.

## Open Gaps

- CRM table schema and content details for `AppSmith-Write-DB > public` — pending future documentation.
- Exact logic for monthly 300-parcel KAM assignment threshold in automated reporting.
