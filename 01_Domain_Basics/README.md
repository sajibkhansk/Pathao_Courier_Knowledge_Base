- [ ] # Domain Basics

Status: Phase 1 documented from Human Oracle answers. Ready for Phase 2 database profiling.

This file stores Human Oracle answers about Pathao Courier’s core business model and terminology.

## Hermes Terminology

- In Pathao Courier context, **Hermes** usually means Pathao's internal OMS / panel used by operations and panel users.
- Do not confuse **Hermes OMS / panel** with **Hermes Agent**, the autonomous AI runtime used by this assistant.
- When SQL references `hermes.*` tables, OMS, or panel activity, interpret Hermes as Pathao's internal system unless the user explicitly means the AI runtime.

## Business Segments

- **Pathao Courier business model:** Pathao Courier operates as a **3PL logistics service**.
- **High-level business segments:**
  - **B2C**
  - **C2C**
- **B2C:**
  - Main source of courier revenue.
  - Meaning: parcels are picked up from **merchants** and delivered to their customers across the country.
  - Order placement source: **merchant panel** or **merchant app**.
  - Has further classification based on **merchant_types**.
- **C2C:**
  - Meaning: parcels are picked up from **individual customers** and delivered as needed.
  - Request placement source: **Pathao superapp**.
  - SQL identifier:
    ```sql
    merchant_id = 80297
    ```

## Hub Operation Types and Facility Terms

- Hub geography/operation classification is identified by **hub_operation_type** in the **hubs** table.
- **ISD:** hubs inside Dhaka city.
  - Known mapping from Human Oracle wording:
    ```sql
    hub_operation_type = 1
    ```
- **OSD:** hubs outside Dhaka city.
  - Human Oracle mapping:
    ```sql
    hub_operation_type = 2
    ```
- **RSD:** suburb hubs outside Dhaka.
  - Human Oracle mapping:
    ```sql
    hub_operation_type = 3
    ```

Reusable SQL label:
```sql
CASE hub_operation_type
  WHEN 1 THEN 'ISD'
  WHEN 2 THEN 'OSD'
  WHEN 3 THEN 'RSD'
END AS hub_operation_type_label
```

### Hub `type` and `tier_type`

Human Oracle guidance:
- `public_hubs.type = 1` is NOT a single synonym group; do not collapse sorting center, sub-sort, and sub-hub together without additional hub ID/context.
- `public_hubs.type = 3` means pickup & delivery hubs.
- `public_hubs.tier_type` is manually set from the backend.
- `tier_type` is mainly used for agent salary calculation based on parcel volume handled by the hub.
- `sorting_centers` and `nearest_hubs` JSON fields are deprecated/not maintained and are not exclusively used in reporting.
- These fields are generally not important for reporting unless a salary/productivity or legacy routing question explicitly needs them.

### Central Sorts, Sub-sorts, and Linehaul Flow

Human Oracle correction:
- **Sorting Center** and **Central Sort** are synonymous.
- Sorting Center / Central Sort always means `hub_id IN (19, 55)`.
- `hub_id = 55` is **Central OSD**: processes parcels that are to be delivered outside Dhaka / OSD.
- `hub_id = 19` is **Central ISD**: processes parcels for inside Dhaka.
- All pickup hubs / inbound facilities transfer their parcels to the central sorts.
- Central sort processes/sorts parcels by linehaul and sends unsorted parcels to downstream **sub-sorts**.
- Sub-sorts sort those parcels further and send them down to LMHs.
- Sub-sorts are downstream from central sort. They may sometimes be called sorting centers operationally, but for canonical reporting, **Sorting Center / Central Sort = 19,55 only**.

SQL shorthand:
```sql
hub_id IN (19, 55)  -- central sorts / sorting centers
```

### Sub-hubs / Booking Points

Human Oracle correction:
- **Sub-hub** is completely different from Central Sort and sub-sort.
- Sub-hubs are also called **booking points**.
- They are shops in different shopping malls that act as pickup hubs.
- Sub-hubs do not act as LMH except for returned orders / RID.

### Company/Operational Synonyms and Non-synonyms

Preserve these mappings when interpreting future tasks:

- **Sorting Center** = **Central Sort** = hub IDs `19` and `55`.
- **Central OSD** = hub ID `55`; processes outside-Dhaka / OSD delivery parcels.
- **Central ISD** = hub ID `19`; processes inside-Dhaka delivery parcels.
- **Sub-sort** = downstream sorting facility after central sort; not the same as central sort in canonical reporting.
- **Sub-hub** = **booking point**; shop/mall pickup point; not the same as central sort or sub-sort.
- **LMH** = **Last Mile Hub**.
- **Delivery Hub** may be used with LMH depending on context, especially for the next destination after central/sub-sort.
- **pickup hub / inbound hub / inbound facility** may refer to facilities transferring parcels into central sort.

## Forward Parcel SLA Matrix

- SLA is maintained for the **complete lifecycle** of a forward-facing parcel.
- SLA is based on **pickup hub type** and **delivery hub type**.
- Individual milestone SLAs for **pickup**, **sort**, **delivery**, and **return** are not currently defined/maintained.
- For now, use this full-lifecycle forward parcel SLA matrix:

| Pickup Hub Type | Delivery Hub Type | SLA |
|---|---:|---:|
| ISD | ISD | 2 days |
| ISD | RSD | 3 days |
| ISD | OSD | 5 days |
| RSD | ISD | 3 days |
| RSD | RSD | 3 days |
| RSD | OSD | 5 days |
| OSD | ISD | 5 days |
| OSD | RSD | 5 days |
| OSD | OSD | 7 days |

Reusable SQL interpretation:
```sql
CASE
  WHEN pickup_hub_type = 'ISD' AND delivery_hub_type = 'ISD' THEN 2
  WHEN pickup_hub_type = 'ISD' AND delivery_hub_type = 'RSD' THEN 3
  WHEN pickup_hub_type = 'ISD' AND delivery_hub_type = 'OSD' THEN 5
  WHEN pickup_hub_type = 'RSD' AND delivery_hub_type = 'ISD' THEN 3
  WHEN pickup_hub_type = 'RSD' AND delivery_hub_type = 'RSD' THEN 3
  WHEN pickup_hub_type = 'RSD' AND delivery_hub_type = 'OSD' THEN 5
  WHEN pickup_hub_type = 'OSD' AND delivery_hub_type = 'ISD' THEN 5
  WHEN pickup_hub_type = 'OSD' AND delivery_hub_type = 'RSD' THEN 5
  WHEN pickup_hub_type = 'OSD' AND delivery_hub_type = 'OSD' THEN 7
END AS forward_lifecycle_sla_days
```

## Reverse Pickup vs Regular Return

### Reverse Pickup

- Operational meaning: a parcel is picked from a **customer** to whom a parcel was previously delivered, and then delivered to the **merchant's store**.
- SQL/order identifier:
  ```sql
  order_type = 3
  ```
- Reverse pickup consignment pattern:
  ```text
  Pxxx
  ```

### Regular Return

- Operational meaning: the customer denies receiving the initial parcel, so the return process starts immediately.
- Return reverse-journey consignment pattern:
  ```text
  Rxxx
  ```

### Important Order Table Grain Rule for Returned Parcels

- In the **orders** table, a single returned parcel can have **2 records**:
  - Forward-facing journey consignment:
    ```text
    Dxxxx
    ```
  - Reverse journey consignment:
    ```text
    Rxxx  -- regular return
    Pxxx  -- reverse pickup
    ```

SQL-generation warning:
- Do not assume one physical parcel always equals one row in `orders` when analyzing returns/reverse flows.
- For returned/reverse parcels, account for both forward and reverse journey records.

## Resolved / Remaining Questions for Later Phases

Resolved after Phase 2:
- `hub_operation_type` numeric mappings are documented above: `ISD = 1`, `OSD = 2`, `RSD = 3`.
- Reverse pickup is confirmed in the database as `order_type_id = 3` and documented in `03_Business_Logic/cds_key_descriptions.md` plus `03_Business_Logic/order_fields_human_oracle.md`.

Remaining:
- Confirm which merchant classification field should be used as the source of truth for B2C stakeholder reporting: `merchant_type`, `merchant_category`, `product_category`, `category`, or another business-team field.
