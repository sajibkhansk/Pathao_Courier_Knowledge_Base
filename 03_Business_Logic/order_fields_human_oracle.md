# `public_orders` Field Meanings — Human Oracle Notes

Status: fully documented from Human Oracle answers during Phase 2. All open gaps resolved.

Scope:
- Table: `courier_realtime_datastream.public_orders`
- Purpose: operational/business meaning for ambiguous order-level fields that are not fully covered in CDS SQL snippets.

## `next_status`

Human Oracle guidance:
- Treat `next_status` as an **invalid / unusable column** for analytics.
- Ignore this field in SQL generation unless a future inspected Metabase card explicitly uses it and the logic is confirmed.

SQL-generation rule:

```sql
-- Do not use public_orders.next_status for analytics by default.
```

## `is_incomplete`

Business meaning:
- Marks orders/parcels where the information required to deliver the parcel is incomplete.
- The key missing/incomplete information is generally:
  - `recipient_phone`
  - `recipient_address`

Interpretation:
- Use this field for incomplete parcel/contact/address data checks.
- Do not interpret it as an operational lifecycle status like hold, return, or failed delivery.

Suggested label pattern:

```sql
CASE
  WHEN is_incomplete = 1 THEN 'Incomplete delivery info'
  WHEN is_incomplete = 0 THEN 'Complete delivery info'
  ELSE 'Unknown / null'
END AS incomplete_info_status
```

Open technical gap:
- Exact stored values are assumed boolean-like (`1` / `0`) but not yet profiled from data.

## `transfer_status_id`

Human Oracle guidance:
- Resolved. See `order_status_changes_human_oracle.md` for label/aggregation sources.
- Use `transfer_status` table for labels.
- Use `hermes_bz_comms.courier_transfer_status` for grouping/aggregation.

## `closebox_status`

Business meaning:
- Signifies whether the customer is allowed to check/open the parcel during delivery.
- For a **closebox parcel**, the customer is **not allowed** to check/open the parcel while delivery is being attempted.

Operational rule:
- In general, a closebox parcel must be delivered, not returned directly by the customer at delivery attempt.
- If the customer wants to return a closebox parcel, they must contact the merchant and initiate a **reverse pickup**.

SQL-generation note:
- Closebox logic is relevant for delivery/return exception analysis.
- Do not treat closebox return behavior as a normal immediate return flow.
- Reverse pickup is separately identified by:

```sql
order_type_id = 3
```

Stored values:
- `closebox_status` is **boolean**: `0` or `1`.
- Human Oracle confirmed no other values exist.

## `payment_status_id`

Human Oracle mapping:

```text
payment_status_id = 1 => invoice paid / COD settled with merchant
payment_status_id = NULL => COD amount has NOT been settled with the merchant yet
```

Business meaning:
- Indicates settlement status of COD/invoice with the merchant.
- `payment_status_id = 1` means the invoice has been paid and COD has been settled with the merchant.
- `payment_status_id = NULL` (or absent) means the COD amount has not been settled yet.

SQL-generation note:
- This is distinct from general order lifecycle status.
- Do not confuse with `billing_status_id`, which has a CDS case-function mapping.
- For unsolved/null check, use `payment_status_id IS NULL` rather than assuming any numeric "not paid" value.

All values documented. No remaining gaps for this field.

## `order_meta`

Human Oracle guidance:
- **Not used for reporting.**

SQL-generation rule:

```sql
-- Do not inspect or extract from public_orders.order_meta for stakeholder reporting.
```

## Status Summary

All `public_orders` fields that were ambiguous during Phase 2 are now documented:
- `next_status`: invalid column, ignore.
- `transfer_status_id`: use `transfer_status` for labels, `hermes_bz_comms.courier_transfer_status` for grouping.
- `is_incomplete`: boolean-like, marks missing recipient info.
- `closebox_status`: boolean, marks closebox parcel.
- `payment_status_id`: `NULL` = not settled, `1` = settled.
- `order_meta`: not used for reporting.
