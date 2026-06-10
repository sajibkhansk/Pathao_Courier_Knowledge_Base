# Hub and Facility Logic — Human Oracle Notes

Status: consolidated from Human Oracle answers and Phase 2 profiling cleanup.

Scope:
- Table: `courier_realtime_datastream.public_hubs`
- Related reporting concepts: hub operation type, central sort, sub-sort, sub-hub / booking point, LMH, hub `type`, `tier_type`, deprecated hub JSON fields.

## Hub Operation Type

Human Oracle confirmed:

```sql
CASE hub_operation_type
  WHEN 1 THEN 'ISD'
  WHEN 2 THEN 'OSD'
  WHEN 3 THEN 'RSD'
END AS hub_operation_type_label
```

Business meanings:
- **ISD:** hubs inside Dhaka city.
- **OSD:** hubs outside Dhaka city.
- **RSD:** suburb hubs outside Dhaka.

## Central Sort / Sorting Center

Canonical reporting rule:
- **Sorting Center** = **Central Sort**.
- Sorting Center / Central Sort always means:

```sql
hub_id IN (19, 55)
```

Specific hubs:
- `hub_id = 19` = **Central ISD**
  - Processes parcels for inside-Dhaka delivery.
- `hub_id = 55` = **Central OSD**
  - Processes parcels for outside-Dhaka / OSD delivery.

Operational flow:
- Pickup hubs / inbound facilities transfer parcels to central sorts.
- Central sort processes/sorts parcels by linehaul.
- Central sort sends unsorted parcels to downstream **sub-sorts**.
- Sub-sorts sort further and send parcels to LMHs.

Important warning:
- Sub-sorts may sometimes be called sorting centers operationally, but for canonical reporting:

```text
Sorting Center / Central Sort = hub IDs 19 and 55 only
```

## Sub-sort

Business meaning:
- A downstream sorting facility after central sort.
- Receives parcels from central sort.
- Sorts further and sends parcels to LMHs.

Non-synonym warning:
- A sub-sort is not the same as central sort in canonical reporting.
- Do not use `public_hubs.type = 1` alone to identify sub-sorts or central sorts without hub ID/context.

## Sub-hub / Booking Point

Human Oracle correction:
- **Sub-hub** = **booking point**.
- Sub-hubs are shops in shopping malls that act as pickup hubs.
- Sub-hubs are completely different from central sort and sub-sort.
- Sub-hubs do not act as LMH except for returned orders / RID.

Non-synonym warning:
- Sub-hub is not central sort.
- Sub-hub is not sub-sort.
- Sub-hub is not generally LMH, except for returned orders / RID context.

## LMH

Meaning:
- **LMH** = **Last Mile Hub**.

Context:
- Delivery Hub may be used with LMH depending on context, especially for the next destination after central/sub-sort.

## Hub `type`

Human Oracle guidance:
- `public_hubs.type = 1` is not a single synonym group.
- Do not collapse sorting center, sub-sort, and sub-hub together using only `type = 1`.
- `public_hubs.type = 3` means pickup & delivery hub.

SQL-generation rule:

```sql
-- Use hub IDs/context for central sort/sub-sort/sub-hub reporting.
-- Do not use public_hubs.type = 1 as a broad canonical facility label.
```

## `tier_type`

Human Oracle guidance:
- `public_hubs.tier_type` is manually set from backend.
- Mainly used for agent salary calculation based on parcel volume handled by the hub.
- Generally not important for stakeholder reporting unless salary/productivity context explicitly requires it.

## Deprecated / Low-Priority Hub JSON Fields

Fields:
- `sorting_centers`
- `nearest_hubs`

Human Oracle guidance:
- These fields are deprecated / not maintained.
- They are not exclusively used in reporting.
- Ignore by default unless an inspected legacy query/card explicitly depends on them.

## Reporting Priority

Use these rules by default:

1. For ISD/OSD/RSD reporting, use `hub_operation_type`.
2. For central sort reporting, use `hub_id IN (19, 55)`.
3. For Central ISD vs Central OSD, use `hub_id = 19` and `hub_id = 55`.
4. For sub-sort and sub-hub reporting, do not infer from `type = 1` alone; use explicit hub IDs, names, or inspected business logic.
5. Ignore `tier_type`, `sorting_centers`, and `nearest_hubs` unless salary/productivity/legacy routing context requires them.
