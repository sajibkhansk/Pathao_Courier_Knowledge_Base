# Core Tables — Phase 2 Profile

Status: initial profiling from Metabase metadata/search. Updated with Human Oracle answers and CDS SQL snippet mappings.

## Source/Scope

- Primary analytics layer: `courier_realtime_datastream` on Metabase database `7` / BigQuery.
- Initial top operational tables identified from existing Pathao Courier navigation patterns and Metabase metadata search:
  1. `courier_realtime_datastream.public_orders` — table id `14654`
  2. `courier_realtime_datastream.public_order_status_changes` — table id `14650`
  3. `courier_realtime_datastream.public_run_routes` — table id `14659`
  4. `courier_realtime_datastream.public_run_routes_orders` — table id `14645`
  5. `courier_realtime_datastream.public_hubs` — table id `14643`
  6. Supporting dimension: `courier_realtime_datastream.public_merchants` — table id `14666`

Note: these are treated as the first high-utilization operational set for Phase 2. Phase 3 Metabase deep dive may refine the ranking by actual report/query usage.

## `public_orders`

- Table grain: appears to be one order journey row, not always one physical parcel.
- Primary key: `id`.
- Important identifiers:
  - `consignment_id`
  - `merchant_id`
  - `merchant_order_id`
  - `store_id`
  - `old_merchant_id`
  - `previous_order_id`
- Important lifecycle/status fields:
  - `order_type_id`
  - `transfer_status_id`
  - `transfer_status_updated_at`
  - `billing_status_id`
  - `next_status`
  - `is_incomplete`
  - `closebox_status`
  - `payment_status_id`
- Important hub/area/agent fields:
  - `current_hub_id`
  - `pickup_hub_id`
  - `delivery_hub_id`
  - `current_agent_id`
  - `pickup_area_id`
  - `delivery_area_id`
- Important timestamps:
  - `created_at`
  - `updated_at` — partition-elimination filter may be required.
  - `sorted_at`
  - `last_attempt_at`
  - `lmh_at`
  - `deleted_at`
- JSON fields:
  - `c2c_info`
  - `order_meta`
  - `datastream_metadata`
- Resolved mappings:
  - `order_type_id` is documented from CDS snippet id `30`; see `03_Business_Logic/cds_key_descriptions.md`.
  - `billing_status_id` is documented from CDS snippet id `38`; see `03_Business_Logic/cds_key_descriptions.md`.
  - Important `c2c_info` JSON keys confirmed by Human Oracle: `sender_name`, `sender_phone`, `pickup_address`, `pickup_lat`, `pickup_lon`, `parcel_weight`, `payment_method`.
  - `next_status` is invalid/unusable for analytics; ignore by default.
  - `is_incomplete` means delivery-required recipient information is incomplete, especially `recipient_phone` and `recipient_address`.
  - `closebox_status` indicates whether the customer is allowed to check/open parcel during delivery; closebox parcels generally should be delivered, and customer-requested return must be handled through reverse pickup.
  - `payment_status_id = 1` means invoice paid / COD settled with merchant.
  - `transfer_status_id`: use `transfer_status` for labels and `hermes_bz_comms.courier_transfer_status` for grouping.
  - `closebox_status` stored values: boolean (`0`/`1`).
  - `payment_status_id` values: `NULL` = not settled, `1` = settled.
  - `order_meta`: not used for reporting.
- No remaining open gaps in `public_orders`.

## `public_order_status_changes`

- Table grain: status-change/event rows per order.
- Primary key: `id`.
- Join key to orders: `order_id` -> `public_orders.id`.
- Status fields:
  - `status_id`
  - `previous_status_id`
  - Use `transfer_status` table for raw status names/labels.
  - Use `hermes_bz_comms.courier_transfer_status` for grouping/aggregation/business buckets.
- Ambiguous enum-like fields:
  - `author_type`
- Resolved mappings / usage notes:
  - `type` is documented from CDS snippet id `8`; see `03_Business_Logic/cds_key_descriptions.md`.
  - `visibility` and `is_public` can be ignored for most analytics.
  - `caused_by` maps against `courier_realtime_datastream.public_agents` and usually represents operations-level users / agents.
  - `author_id` maps against `courier_realtime_datastream.public_users`; `author_id = 1` means system/merchant; `users` contains internal users only.
- JSON/string payload fields:
  - `payload` — serialized JSON string; in OSC, use old/new JSON extraction when pulling previous and changed values, e.g. `JSON_EXTRACT_SCALAR(payload, '$.old.recipient_address')` and `JSON_EXTRACT_SCALAR(payload, '$.new.recipient_address')`.
  - `notes`
  - `desc`
- Hub/user fields:
  - `hub_id`
  - `author_id`
- Important timestamps:
  - `created_at` — event timestamp.
  - `updated_at` — partition-elimination filter may be required.

## `public_run_routes`

- Table grain: operational run route / movement route instance.
- Primary key: `id`.
- Important route fields:
  - `route_id`
  - `from_hub`
  - `to_hub`
  - `agent_id`
  - `driver_agent_id`
  - `vehicle_id`
  - `total` — number of parcels assigned directly to the run.
  - `total_baskets` — number of baskets assigned to the run.
- Resolved mappings / usage notes:
  - `run_route_type`: `1 = pickup`, `2 = transfer`, `3 = delivery`.
  - `transfer_type` is documented from CDS snippet id `34`; see `03_Business_Logic/cds_key_descriptions.md` and `03_Business_Logic/run_routes_human_oracle.md`.
  - `transfer_type` further classifies routes: `1-2` pickup, `20-79` transfer, `80-81` delivery.
  - Transfer runs usually move baskets; directly assigned parcels are used when the parcel is physically too big for a basket.
  - `is_close` indicates whether the run is closed. Transfer runs close systematically after transfer when every parcel/basket is received or declared missing; pickup/delivery runs close when the agent ends the run from the app.
  - `status_id` denotes the `transfer_status_id` of parcels before assignment into the run; it has limited significance in regular querying. A run cannot contain parcels with multiple statuses.
  - Ignore `run_status` and `logistics_type` for regular analytics.
- Lower-priority / usually ignored fields:
  - `run_status`
  - `logistics_type`
  - `soho_agent`
- JSON fields:
  - `meta`
- Important timestamps:
  - `created_at`
  - `updated_at` — partition-elimination filter may be required.
  - `deleted_at`

## `public_run_routes_orders`

- Table grain: bridge between route instances and orders.
- Primary key: `id`.
- Join keys:
  - `run_route_id` -> `public_run_routes.id`
  - `order_id` -> `public_orders.id`
- Ambiguous status fields:
  - `status` — documented from CDS snippet id `40` (`status (run_routes_orders)`): parcel/order outcome within a run-route assignment. See `03_Business_Logic/cds_key_descriptions.md`.
  - `office_order_status` — hub-side status updated before delivery agent starts the field run. Important values: `24 = office hold`, `25 = office return`; deduct/exclude these from assigned delivery parcels for delivery-agent salary/productivity and success-rate models as required.
  - `proceed_method` — ignore for regular analytics.
- Operational receipt/handover fields:
  - `received_run_id` — run where the parcel was actually received. If `run_route_id <> received_run_id`, interpret as received in another run. If an unassigned parcel is received directly into a run, records may have `created_at = updated_at` and `run_route_id = received_run_id`.
  - `receiver_id`
  - `handover_at`
  - `sorted_position`
- JSON fields:
  - `meta`
- OTP/slip fields:
  - `merchant_otp`
  - `user_otp`
  - `hermes_otp`
  - `otp_context`
  - `otp_attempt`
  - `otp_amount`
  - `delivery_slip`
- Important timestamps:
  - `created_at`
  - `updated_at` — partition-elimination filter may be required.
  - `deleted_at`

## `run_route_logs`

- Table grain: route/run event logs.
- Important usage from Human Oracle:
  - For transfer runs, authoritative closed-run received/missing counts are available in `payload` / `payloads` for rows where `name = 'Run Closed'`.
- Metabase/app DB note:
  - Postgres `public.run_route_logs` is Metabase table id `109`.
  - The inspected JSONB column is named `payloads` in Metabase metadata.
- Key fields to inspect/use:
  - `run_route_id`
  - `name`
  - `payloads`
- Sample lookup:

```sql
SELECT *
FROM run_route_logs
WHERE run_route_id = 11347492
  AND name = 'Run Closed'
```

- Verified sample payload keys:
  - `Received Order`
  - `Missing Order`
  - `Removed Order`
  - `Received Basket`
  - `Missing Basket`
  - `Removed Basket`
  - `User`

- SQL-generation note:
  - Use these payload counts as the close summary source for transfer runs; use basket/direct parcel joins mainly for detail tracing.

## `public_hubs`

- Table grain: hub dimension row.
- Primary key: `id`.
- Important hub classification fields:
  - `type`
  - `is_isd`
  - `tier_type`
  - `hub_operation_type`
  - `region_id`
  - `line_haul_id`
  - `cluster_id`
- Geography fields:
  - `city_id`
  - `zone_id`
  - `country_id`
  - `latitude`
  - `longitude`
- JSON fields:
  - `sorting_centers`
  - `nearest_hubs`
  - `cron_schedules`
- Resolved mappings / usage notes:
  - `hub_operation_type = 1` means `ISD`.
  - `hub_operation_type = 2` means `OSD`.
  - `hub_operation_type = 3` means `RSD`.
  - `type = 1` should not be treated as a synonym group for sorting center/sub-sort/sub-hub without additional hub ID/context.
  - `type = 3` means pickup & delivery hubs.
  - `tier_type` is manually set in backend and mainly used for agent salary calculation based on parcel volume handled by the hub.
  - `hub_id IN (19, 55)` are the two central sorts / sorting centers.
  - `hub_id = 55` is Central OSD and processes outside-Dhaka / OSD delivery parcels.
  - `hub_id = 19` is Central ISD and processes inside-Dhaka delivery parcels.
  - Central sort receives pickup/inbound parcels, sorts by linehaul, and sends unsorted parcels to downstream sub-sorts; sub-sorts sort further and send parcels to LMHs.
  - Sub-hub is not central sort or sub-sort. Sub-hub = booking point: shops in malls that act as pickup hubs; they do not act as LMH except for returned orders / RID.
  - `sorting_centers` and `nearest_hubs` JSON fields are deprecated/not maintained and not exclusively used in reporting.
- Reporting guidance:
  - `type`, `tier_type`, `sorting_centers`, and `nearest_hubs` are generally not important for reporting unless salary/productivity, legacy routing, or central-sort flow context explicitly needs them.

## `public_merchants`

- Table grain: merchant dimension row.
- Primary key: `id`.
- Important merchant classification fields:
  - `merchant_type`
  - `merchant_category`
  - `product_category`
  - `category`
  - `source`
  - `acquisition_id`
- Owner/team fields:
  - `kam_id`
  - `owner_id`
  - `operator_id`
  - `referred_by`
- Finance/payment fields:
  - `payment_information_id`
  - `is_prepaid`
  - `is_cod_enable`
  - `active_payment_method`
  - `payment_method_changed_at`
  - `isd_cod_fee`, `osd_cod_fee`, `sub_area_cod_fee`
- JSON fields:
  - `meta`
  - `ogrim_meta`
  - `insta_pay_meta`
  - `on_demand_meta`
- Resolved mappings:
  - `merchant_type` is documented from CDS snippet ids `9` and `26`; see `03_Business_Logic/cds_key_descriptions.md`.
  - `source`: `1 = merchant panel`, `2 = hermes panel`.
- Reporting guidance:
  - `merchant_type` is the reliable source for merchant categorization.
  - `merchant_category` and `product_category` are manually maintained and NOT reliable for reporting.
  - `category` is not used.
- KAM logic:
  - Merchants with 300+ parcels/month get a KAM assigned from the upcoming month.
  - `kam_id` maps to `courier_realtime_datastream.public_users`.
- Open mapping gaps:
  - CRM schema detail for `AppSmith-Write-DB > public` — pending future documentation.

## Additional Table Overviews (Human Oracle)

The following tables were not deeply profiled but have known business purposes:

### `public_dispatch_attempts` and `public_dispatch_requests`

Purpose:
- These tables are **exclusive to the C2C business**.
- They support a feature that dispatches pickup requests to nearby agents.

Dispatch flow:
1. For a C2C order, a **dispatch_request** is sent out.
2. A single order may have more than one dispatch request.
3. Each dispatch request hits the nearest available agent.
4. The agent can: **accept**, **reject**, or **time out**.
5. The cycle continues until the parcel is accepted and picked up successfully.

Join key:

```sql
dispatch_requests.id = dispatch_attempts.dispatch_id
```

Key descriptions:
- CDS snippet id `37`: `dispatch_requests` statuses (0=Requested through 5=ScheduleForNextDay).
- CDS snippet id `36`: `dispatch_attempts` statuses (0=blank, 1=accepted, 2=rejected, 3=timed_out, 4=blank).
- Note: CDS has blank descriptions for `dispatch_attempts` status `0` and `4`.

### `public_basket_run_route`, `public_basket_order`, `public_baskets`

Purpose:
- Self-explanatory: baskets are used to group parcels for transfer runs.

Key descriptions available in CDS:
- CDS snippet id `41`: `basket_run_route.status` (0=run assigned through 10=Received through PTN).
- CDS snippet id `42`: `basket_order.existence_status` (0=Assigned through 4=found).
- See `03_Business_Logic/cds_key_descriptions.md` and `04_SQL_Patterns/run_routes_transfer_basket_patterns.md` for full mappings and SQL patterns.

### `public_agents`

Purpose:
- Contains all relevant information about agents (delivery, pickup, sort, van duty, etc.).

Key mapping:
- `role_type` is documented in CDS snippet id `7` (Agent Role Type).

### `public_order_invoices`

Purpose:
- When an order reaches a **final status**, a record is generated in `order_invoices`.
- If the order is **COD**, the hub needs to settle payment against that invoice ID (also known as **hub_payment**).

Related CTE in `04_SQL_Patterns/cds_cte_patterns.md`:
- Includes commented-out `SAFE_CAST(JSON_EXTRACT_SCALAR(meta, '$...') AS FLOAT64) / 100` for financial fields in the `meta` JSON.

### `public_point_orders`

Purpose:
- Stores orders for **sub-hub / booking point** transactions.
- Sub-hubs are shop/mall pickup points.

### `public_payment_invoices`

Purpose:
- Used for tracking **COD settlement and delivery charges** against merchants.

### `public_users`

Purpose:
- Contains details of **all internal users** (operations staff, panel users).
- Does NOT contain merchant or customer user-app identities except the special `author_id = 1` (system/merchant).
