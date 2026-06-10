# Phase 2 Open Enum / Business Logic Mappings

Status: partially resolved from Human Oracle answers and CDS SQL snippets. See `03_Business_Logic/cds_key_descriptions.md` for extracted CDS mappings.

## Already Documented from Phase 1

- **C2C orders:**
  ```sql
  merchant_id = 80297
  ```
- **Reverse Pickup:**
  ```sql
  order_type_id = 3
  ```
  Confirmed via Human Oracle and CDS snippet id `30` (`order_type_id`).
- **ISD hubs:** Dhaka city hubs.
  ```sql
  hub_operation_type = 1
  ```
- **OSD hubs:** outside Dhaka city hubs.
  ```sql
  hub_operation_type = 2
  ```
- **RSD hubs:** suburb hubs outside Dhaka.
  ```sql
  hub_operation_type = 3
  ```

## Confirmed C2C JSON Keys

For `public_orders.c2c_info`, Human Oracle confirmed these important JSON keys for SQL generation:

- `sender_name`
- `sender_phone`
- `pickup_address`
- `pickup_lat`
- `pickup_lon`
- `parcel_weight`
- `payment_method`

Also useful from existing Pathao patterns, pending full CDS snippet extraction:

- `pickup_direction`
- `sender_city_id`

## Mappings Resolved from CDS

Documented in `03_Business_Logic/cds_key_descriptions.md`:

- `public_orders.order_type_id`
- `public_merchants.merchant_type`
- `public_order_status_changes.type`
- `public_run_routes.transfer_type`
- `billing_status_id`
- `payout_status`
- `hub_payment_status`
- `item_type_id`
- `delivery_type(price_plan_slab)`
- `role_type`
- `distance_id`
- C2C dispatch request/attempt statuses, with blanks noted for dispatch attempts `0` and `4`.

## High-Priority Mappings Still Needed

### Orders

All resolved in `order_fields_human_oracle.md`:
- `transfer_status_id`: use `transfer_status` for labels, `hermes_bz_comms.courier_transfer_status` for grouping.
- `closebox_status`: boolean (`0`/`1`).
- `payment_status_id`: `NULL` = not settled, `1` = settled.
- `order_meta`: not used for reporting.

### Order Status Changes

Resolved in `order_status_changes_human_oracle.md`:
- `status_id` / `previous_status_id`: use `transfer_status` for labels and `hermes_bz_comms.courier_transfer_status` for grouping/aggregation.
- `visibility` / `is_public`: ignore for most analytics.
- `caused_by`: maps against `public_agents`.
- `author_id`: maps against `public_users`; `author_id = 1` means system/merchant.
- `payload`: use old/new JSON extraction in OSC when pulling previous and changed values.

### Run Routes

Resolved in `run_routes_human_oracle.md`:
- `run_route_type`: `1 = pickup`, `2 = transfer`, `3 = delivery`.
- `transfer_type`: detailed run classification; CDS snippet id `34` has full mapping.
- `status_id`: pre-assignment `transfer_status_id` of parcels in the run; usually ignore.
- `run_status` / `logistics_type`: ignore for regular analytics.
- `is_close`: whether run is closed; closure logic differs for transfer vs pickup/delivery runs.
- `total`: number of parcels assigned directly to the run.
- `total_baskets`: number of baskets assigned to the run.

### Run Routes Orders

Resolved in `run_routes_human_oracle.md`:
- `public_run_routes_orders.status`: documented from CDS snippet id `40` (`status (run_routes_orders)`).
- `public_run_routes_orders.office_order_status`: hub-side pre-field-run update; `24 = office hold`, `25 = office return`; important for delivery-agent salary/productivity and success-rate calculations.
- `public_run_routes_orders.proceed_method`: ignore for regular analytics.

### Hubs

Resolved in `01_Domain_Basics/README.md` and `02_Data_Dictionary/core_tables_phase2_profile.md`:
- `public_hubs.type = 1`: do not treat as a synonym group for sorting center/sub-sort/sub-hub without additional hub ID/context.
- `public_hubs.type = 3`: pickup & delivery hubs.
- `public_hubs.tier_type`: manually set backend field, mainly used for agent salary calculation based on hub parcel volume.
- `hub_id IN (19, 55)`: central sorts / sorting centers only.
- `hub_id = 55`: Central OSD, processes outside-Dhaka / OSD delivery parcels.
- `hub_id = 19`: Central ISD, processes inside-Dhaka delivery parcels.
- Sub-sorts are downstream from central sorts and send sorted parcels to LMHs.
- Sub-hubs are booking points / shop pickup hubs and are not central sorts or sub-sorts; they do not act as LMH except for returned orders / RID.
- `sorting_centers` and `nearest_hubs` JSON fields: deprecated/not maintained and not exclusively used in reporting.
- None of these are generally important for reporting unless salary/productivity, legacy routing, or central-sort flow context explicitly needs them.

### Merchants

Resolved in `merchant_logic_human_oracle.md`:
- `merchant_category`: manually maintained, not reliable for reporting. Use `merchant_type` instead.
- `product_category`: manually maintained, not reliable for reporting. Use `merchant_type` instead.
- `category`: not used.
- `source`:
  - `1` = merchant panel
  - `2` = hermes panel
- KAM assignment: `kam_id` maps to `users`.
- KAM threshold: 300+ parcels/month triggers assignment from the upcoming month.

Open gaps:
- CRM schema detail for `AppSmith-Write-DB > public` — pending future documentation.
