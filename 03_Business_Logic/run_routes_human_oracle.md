# Run Routes Field Meanings — Human Oracle Notes

Status: documented from Human Oracle answers during Phase 2, cross-checked with CDS snippet id `34` (`transfer_type`).

Scope:
- Table: `courier_realtime_datastream.public_run_routes`
- Related table: `courier_realtime_datastream.public_run_routes_orders`
- Purpose: operational semantics for pickup / transfer / delivery route movement and parcel assignment.

## `run_route_type`

Human Oracle mapping:

```text
run_route_type = 1 => pickup
run_route_type = 2 => transfer
run_route_type = 3 => delivery
```

Business meaning:
- There are 3 high-level run route types:
  - pickup run
  - transfer run
  - delivery run

SQL-generation rule:
- Use `run_route_type` for broad pickup / transfer / delivery classification.
- Use `transfer_type` for detailed movement classification inside those broad route types.

Suggested label pattern:

```sql
CASE rr.run_route_type
  WHEN 1 THEN 'pickup'
  WHEN 2 THEN 'transfer'
  WHEN 3 THEN 'delivery'
  ELSE 'unknown'
END AS run_route_type_label
```

## `transfer_type`

Human Oracle guidance:
- `transfer_type` gives further classification of the run route.
- Ranges:
  - `1-2` are pickup.
  - `20-79` are transfer.
  - `80-81` are delivery.
- Detailed descriptions are available in CDS under `transfer_type`.

CDS confirmation:
- Found in CDS snippet id `34`, title `transfer_type`, description `run_routes`.
- Already extracted in `03_Business_Logic/cds_key_descriptions.md`.

CDS range meanings:

```text
1-19 = Pickup
20-79 = Transfer
80-81 = Delivery
```

CDS specific values currently documented:

```text
1 = PICKUP
2 = PICKUP_C2C
20 = HUB_RECEIVED_TO_SORTING_HUB
21 = SORTING_HUB_TO_CENTRAL_WAREHOUSE
22 = SORTING_HUB_TO_CENTRAL_OSD
23 = SORTING_HUB_TO_CENTRAL_OSD_3RD_PARTY
24 = SORTING_HUB_TO_OSD_SORTING
25 = SORTING_HUB_TO_OSD_SORTING_3RD_PARTY
26 = CENTRAL_WAREHOUSE_TO_LMH
27 = CENTRAL_OSD_TO_LMH
28 = CENTRAL_OSD_TO_LMH_3RD_PARTY
29 = CENTRAL_OSD_TO_OSD_SORTING
30 = CENTRAL_OSD_TO_CENTRAL_WAREHOUSE
31 = OSD_SORTING_TO_LMH
32 = OSD_SORTING_TO_LMH_3RD_PARTY
33 = OSD_SORTING_TO_CENTRAL_OSD
34 = OSD_SORTING_TO_OSD_SORTING
35 = OSD_SORTING_TO_CENTRAL_WAREHOUSE
36 = LMH_TO_CENTRAL_WAREHOUSE
37 = LMH_TO_CENTRAL_OSD
38 = LMH_TO_OSD_SORTING
39 = LMH_TO_CENTRAL_RETURN
40 = LMH_TO_SELF_INBOUND
41 = RETURN_AT_SORTING_TO_RETURN_AT_FAST_MILE
42 = LMH_TO_LMH
43 = SAME_HUB_INBOUND_TO_OUTBOUND
44 = SORTING_HUB_TO_LMH
45 = CENTRAL_WAREHOUSE_TO_CENTRAL_OSD
46 = CENTRAL_WAREHOUSE_TO_OSD_SORTING
80 = DELIVERY
81 = DELIVERY_TO_MERCHANT
```

## Transfer runs, baskets, and direct parcel assignment

Operational model:
- When transferring parcels from one facility/hub to another, parcels are usually assigned to a **basket**.
- One or more baskets are then assigned to a `run_route`.
- For transfer runs, an order can also be assigned directly to a run when it is physically too big for basket handling.

Important fields:
- `total` = number of parcels assigned directly to that run.
- `total_baskets` = number of baskets assigned to that run.

SQL-generation note:
- For transfer route volume, do not assume `total` is the full parcel volume if baskets exist.
- `total` only counts directly assigned parcels.
- Use basket linkage/logs when basket-level parcel counts are needed.

## `is_close`

Business meaning:
- Defines whether the run is closed.

Closure logic:
- For transfer runs:
  - A run is closed systematically when the run is transferred and every parcel and basket is either received or declared missing.
- For pickup/delivery runs:
  - A run is considered closed when the agent ends the assigned run from the app.

Suggested label pattern:

```sql
CASE rr.is_close
  WHEN 1 THEN 'closed'
  WHEN 0 THEN 'open'
  ELSE 'unknown'
END AS run_close_status
```

Open technical gap:
- Exact stored values are assumed boolean-like (`1` / `0`) but not yet profiled from data.

## `status_id`

Human Oracle guidance:
- `status_id` denotes the `transfer_status_id` of the parcels before the parcels were assigned to the run.
- It has limited significance in regular querying.
- It is not possible to assign parcels of multiple statuses in a single run.

SQL-generation rule:
- Ignore `public_run_routes.status_id` for most regular run-route analytics unless the question specifically asks for pre-assignment parcel status.
- If used, interpret it as the common pre-assignment transfer status for all parcels in that run.

## `run_status` and `logistics_type`

Human Oracle guidance:
- Ignore `run_status`.
- Ignore `logistics_type`.

SQL-generation rule:

```sql
-- Do not use rr.run_status or rr.logistics_type unless an inspected existing card explicitly depends on them.
```

## `public_run_routes_orders.status`

CDS confirmation:
- Found in CDS snippet id `40`, title `status (run_routes_orders)`, schema `hermes-appdb-replica-3`.
- Extracted in `03_Business_Logic/cds_key_descriptions.md`.

CDS values:

```text
1 = Delivered
2 = Returned
3 = Hold
4 = Missing (received in a different run)
5 = Order Damaged received
7 = Partially Delivered
8 = Price Change
9 = Paid Return
10 = Exchange
11 = Waiting for agent approval
12 = Reassigned from waiting for agent approval state
```

SQL-generation rule:
- Use this field when reporting order/parcel outcome within a run-route assignment.
- Preserve the raw `status` alongside the label when auditability matters.

## `public_run_routes_orders.office_order_status`

Human Oracle guidance:
- `office_order_status` signifies a parcel status updated at the hub before the delivery agent starts the field run.
- Operational example: before the agent goes to the field, the agent/hub calls some customers to confirm availability. If the customer refuses to receive the parcel, the parcel is updated as left in hub.
- Important values:
  - `24` = hold / office hold
  - `25` = returned / office return

Business importance:
- This is important for delivery-agent salary/productivity models.
- A major part of agent salary is calculated using delivered parcels and success rate.
- Office hold and office return are deducted from total parcels assigned for delivery, because these were not field-attempt parcels.

SQL-generation rule:
- For delivery-agent productivity, salary, or success-rate calculations, exclude/deduct office hold and office return from assigned delivery parcels as required by the metric definition.
- Do not count office hold/office return as normal field-attempt failures.

## `public_run_routes_orders.proceed_method`

Human Oracle guidance:
- Ignore `proceed_method`.

SQL-generation rule:

```sql
-- Do not use rro.proceed_method unless a specific legacy query/card already depends on it.
```

## Basket status mappings from CDS

### `basket_run_route.status`

CDS confirmation:
- Found in CDS snippet id `41`, title `status (basket_run_route)`, schema `hermes-appdb-replica-3`.
- Extracted in `03_Business_Logic/cds_key_descriptions.md`.

CDS values:

```text
0 = run assigned
2 = Missing
4 = Reached
5 = Reused
6 = Unverified Opened
7 = Scanned Opened
9 = Received
10 = Received through PTN
```

### `basket_order.existence_status`

CDS confirmation:
- Found in CDS snippet id `42`, title `existence_status (basket_orders)`, schema `hermes-appdb-replica-3`.
- Extracted in `03_Business_Logic/cds_key_descriptions.md`.

CDS values:

```text
0 = Assigned
1 = Confirmed
2 = Missing
3 = extra
4 = found
```

## `received_run_id` and unassigned receipt cases

Human Oracle guidance:
- Technically, `received_run_id` means the run where the parcel/basket was actually received.
- If `run_route_id <> received_run_id`, interpret it as received in another run.
- Special case: if a parcel/basket is received in a `run_route` without being previously assigned, business users call this an **unassigned** receipt.
- For unassigned receipt records, the row is entered as if:
  - `created_at = updated_at`
  - `run_route_id = received_run_id`

SQL-generation rule:
- Do not use `run_route_id = received_run_id` alone to infer normal assigned-and-received behavior; also check assignment/creation semantics when distinguishing normal assigned parcels from unassigned receipts.
- Use `run_route_id <> received_run_id` as evidence that the parcel/basket was received in a different run than it was assigned to.

## Transfer run close/count source

Human Oracle guidance:
- For transfer runs, the standard received/missing counts are available in `run_route_logs.payload` / `payloads` for the `Run Closed` log.
- Sample inspection query:

```sql
SELECT * 
FROM run_route_logs
WHERE run_route_id = 11347492
  AND name = 'Run Closed'
```

Verified sample row from Metabase app DB table `public.run_route_logs` (table id `109`):

```json
{
  "User": "Pathao System",
  "Missing Order": 0,
  "Removed Order": 0,
  "Missing Basket": 0,
  "Received Order": 78,
  "Removed Basket": 0,
  "Received Basket": 60
}
```

Observed field name:
- In Metabase table id `109`, the JSONB field is named `payloads`.
- Human/business references may call it `payload`.

Payload count keys observed:
- `Received Order`
- `Missing Order`
- `Removed Order`
- `Received Basket`
- `Missing Basket`
- `Removed Basket`
- `User`

SQL-generation rule:
- When reporting successfully received vs missing parcels for a closed transfer run, inspect `run_route_logs` where `name = 'Run Closed'` and parse the payload/payloads column for the authoritative counts.
- Use basket/direct parcel joins for detail-level tracing, but prefer `run_route_logs.payloads` for the close summary counts when available.
- Treat `Received Order` / `Missing Order` / `Removed Order` as direct/bulk-order counts and `Received Basket` / `Missing Basket` / `Removed Basket` as basket counts unless a later Human Oracle correction says otherwise.

Postgres JSON extraction example:

```sql
SELECT
  run_route_id,
  (payloads ->> 'Received Order')::int AS received_order_count,
  (payloads ->> 'Missing Order')::int AS missing_order_count,
  (payloads ->> 'Removed Order')::int AS removed_order_count,
  (payloads ->> 'Received Basket')::int AS received_basket_count,
  (payloads ->> 'Missing Basket')::int AS missing_basket_count,
  (payloads ->> 'Removed Basket')::int AS removed_basket_count
FROM run_route_logs
WHERE name = 'Run Closed'
```

Open technical note:
- Validate whether all `Run Closed` payload rows consistently use these exact JSON keys before relying on them in broad reporting.

## SQL Patterns

The large transfer-run SQL examples have been moved to:

- `04_SQL_Patterns/run_routes_transfer_basket_patterns.md`

That file contains:
- all parcels in a transfer run, including direct/bulk assignments and basket-contained parcels
- closed transfer run summary counts from `run_route_logs.payloads`
- Postgres JSON extraction for `Run Closed` payload keys
