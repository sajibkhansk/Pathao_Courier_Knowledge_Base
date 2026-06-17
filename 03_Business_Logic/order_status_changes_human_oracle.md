# `public_order_status_changes` Field Meanings — Human Oracle Notes

Status: documented from Human Oracle answers during Phase 2.

Scope:
- Table: `courier_realtime_datastream.public_order_status_changes`
- Alias used by team: `OSC`
- Purpose: business/SQL semantics for status history fields, joins, and payload extraction.

## Important Terminology: Hermes OMS vs Hermes Agent

Pathao internal OMS / panel is called **Hermes**.

Important distinction:
- **Hermes OMS / panel:** Pathao internal order-management system used by operations/panel users.
- **Hermes Agent:** the autonomous AI agent runtime used by this assistant.

SQL-generation rule:
- When Pathao Courier data, `hermes.*` tables, OMS, or panel activity is mentioned, interpret **Hermes** as the Pathao internal OMS/panel unless the user explicitly means the AI agent platform.

## Status Labels vs Status Grouping

Human Oracle guidance:
- Use the **transfer_status** table for raw status names/labels.
- Use `hermes_bz_comms.courier_transfer_status` for grouping/aggregation/business buckets.

SQL-generation rule:

```sql
-- For raw status label/name lookup:
-- join/use transfer_status table

-- For grouped reporting / aggregate status buckets:
-- join/use hermes_bz_comms.courier_transfer_status
```

Practical use:
- `public_order_status_changes.status_id` and `previous_status_id` map to transfer status IDs.
- For display labels, join to `transfer_status`.
- For reporting buckets such as open/on_process/final/processed/delivered-family, use `hermes_bz_comms.courier_transfer_status`.

## `visibility` and `is_public`

Human Oracle guidance:
- Ignore these fields for most analytics.

SQL-generation rule:

```sql
-- Do not filter or group by visibility / is_public unless the user explicitly asks for public/customer-visible event logic.
```

## `caused_by`

Human Oracle guidance:
- `caused_by` maps against the `agents` table.
- It usually represents operations-level users / agents involved in the event.

Recommended join pattern:

```sql
LEFT JOIN courier_realtime_datastream.public_agents a
  ON osc.caused_by = a.id
```

Open detail:
- Exact semantic categories of `caused_by` are not fully documented yet; treat it as an agent/user actor reference rather than an enum.

## `author_id`

Human Oracle guidance:
- `author_id` maps against the `users` table.
- It represents the `user_id` of agents / panel users who interacted with the order.
- `author_id = 1` means **system / merchant**.
- The `users` table contains internal users only.

Recommended join pattern:

```sql
LEFT JOIN courier_realtime_datastream.public_users u
  ON osc.author_id = u.id
```

Special handling:

```sql
CASE
  WHEN osc.author_id = 1 THEN 'system_or_merchant'
  ELSE 'internal_user'
END AS osc_author_class
```

Important note:
- Because `users` contains internal users only, do not expect merchant/customer/user-app identities to resolve there except the special `author_id = 1` case.

## `payload`

Human Oracle guidance:
- Payload usage depends on use case and table.
- For `public_order_status_changes` / OSC, `payload` is used when pulling both previous and changed values.
- Standard old/new extraction is valid for OSC use cases where the payload contains previous and changed values.

Standard BigQuery extraction pattern for OSC:

```sql
JSON_EXTRACT_SCALAR(payload, '$.old.<field_name>') AS old_value,
JSON_EXTRACT_SCALAR(payload, '$.new.<field_name>') AS new_value
```

Example pattern:

```sql
JSON_EXTRACT_SCALAR(payload, '$.old.recipient_address') AS old_recipient_address,
JSON_EXTRACT_SCALAR(payload, '$.new.recipient_address') AS new_recipient_address
```

Caution:
- Do not assume every table’s payload/meta JSON follows the same `old` / `new` structure.
- Use the old/new pattern specifically when the OSC event is expected to record previous and changed values.

## Price Change Detection Uses OSC Logs

Human Oracle guidance:
- To identify price changes, inspect OSC logs rather than comparing final `public_orders.collectable_amount` and `public_orders.collected_amount`.
- In a completed price-change order, collectable amount is changed and then `collectable_amount = collected_amount`.

SQL-generation rule:

```sql
-- Do not use this as the canonical price-change detector:
-- public_orders.collectable_amount <> public_orders.collected_amount

-- Use public_order_status_changes payload/status/desc evidence for collectable amount changes.
-- Exact OSC payload paths are tracked in 03_Business_Logic/price_change_logic.md open questions.
```

See also:
- `03_Business_Logic/price_change_logic.md`

## Known OSC Type Mapping

CDS snippet id `8` documents `public_order_status_changes.type`; see:
- `03_Business_Logic/cds_key_descriptions.md`

Important commonly used value:

```text
type = 12 => ORDER_STATUS_CHANGE
```

Example sorted-status event pattern from CDS:

```sql
SELECT COUNT(DISTINCT order_id)
FROM courier_realtime_datastream.public_order_status_changes
WHERE 1=1
  AND (updated_at IS NOT NULL OR updated_at IS NULL)
  AND status_id = 9
  AND type IN (12)
  AND DATE(created_at) BETWEEN '2026-02-01' AND '2026-02-10'
```
