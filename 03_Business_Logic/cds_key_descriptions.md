# CDS SQL Snippets — Key Descriptions

Status: extracted from Courier Data Service `/api/sql-snippets` after Human Oracle said key descriptions are maintained in **CDS > SQL Snippets > Key's Description**.

Source:
- App: `https://cds-pathao.vercel.app`
- Endpoint: `https://cds-pathao.vercel.app/api/sql-snippets`
- Raw JSON saved at: `02_Data_Dictionary/cds_sql_snippets_raw.json`
- Retrieved count: 33 snippets
- Categories found: `CTE's`, `Key's Description`, `Case Functions`

SQL-generation rule:
- For enum/key mappings, check this CDS snippet source before asking the Human Oracle.
- If a mapping is incomplete or ambiguous in CDS, ask a focused follow-up.

## Hub Operation Type

Human Oracle confirmed:

```sql
CASE hub_operation_type
  WHEN 1 THEN 'ISD' -- Dhaka city hubs
  WHEN 2 THEN 'OSD' -- outside Dhaka city hubs
  WHEN 3 THEN 'RSD' -- suburb hubs outside Dhaka
END AS hub_operation_type_label
```

## Order Type ID

CDS snippet id: `30`
Title: `order_type_id`
Description: `Order_invoices`
Category: `Key's Description`

```text
delivery = 1
return = 2
reverse pickup = 3
partial = 4
exchange = 5
DRTO = 6
C2C = 9
link = 11
C2C agent = 12
B2B = 13
C2C app = 15
hermes point = 16
merchant point = 17
point to home = 18
fake order = 20
```

Reusable SQL:

```sql
CASE order_type_id
  WHEN 1 THEN 'delivery'
  WHEN 2 THEN 'return'
  WHEN 3 THEN 'reverse_pickup'
  WHEN 4 THEN 'partial'
  WHEN 5 THEN 'exchange'
  WHEN 6 THEN 'DRTO'
  WHEN 9 THEN 'C2C'
  WHEN 11 THEN 'link'
  WHEN 12 THEN 'C2C_agent'
  WHEN 13 THEN 'B2B'
  WHEN 15 THEN 'C2C_app'
  WHEN 16 THEN 'hermes_point'
  WHEN 17 THEN 'merchant_point'
  WHEN 18 THEN 'point_to_home'
  WHEN 20 THEN 'fake_order'
  ELSE 'unknown'
END AS order_type_label
```

Important business note:
- Human Oracle separately confirmed **C2C business segment** is identified by `merchant_id = 80297`.
- CDS also lists `order_type_id = 15` as `C2C app` and `order_type_id = 9` as `C2C`.
- Do not assume order-type alone defines all C2C reporting unless the request explicitly asks for order-type categories; use `merchant_id = 80297` for C2C segment filtering by default.

## Merchant Type

CDS snippet id: `9`
Title: `Merchant Type Keys Desc`
Category: `Key's Description`
Schema: `hermes-appdb-replica-3`

```text
REGULAR_MERCHANT = 0
C2C_KIOSK_MERCHANT = 1
B2B_MERCHANT = 2
C2C_AGENT = 3
CORPORATE_MERCHANT = 4
BOOK_MERCHANT = 5
POINT_MERCHANT = 6
POST_PAID_MERCHANT = 7
```

CDS snippet id: `26`
Title: `merchant type`
Category: `Case Functions`
Schema: `courier-bi-metabase-ro-dcp-bq`

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

## Order Status Changes Type (`public_order_status_changes.type`)

CDS snippet id: `8`
Title: `OSC Type`
Category: `Key's Description`
Schema: `hermes-appdb-replica-3`

```text
ORDER_CREATED = 1
ORDER_ACCEPTED = 2
ORDER_EDIT = 3
ORDER_ASSIGN = 4
ORDER_UPDATE = 5
ORDER_INVOICED = 6
ORDER_PAID = 7
ORDER_HOLD = 8
ORDER_REJECT = 9
ORDER_MISSING = 10
ORDER_FOUND = 11
ORDER_STATUS_CHANGE = 12
ORDER_STATUS_PICKED = 13
ORDER_STATUS_SORTED = 14
ORDER_STATUS_IN_TRANSIT = 15
ORDER_STATUS_LMH = 16
ORDER_STATUS_ASSIGN_FOR_DELIVERY = 17
ORDER_STATUS_HOLD = 18
ORDER_STATUS_DELIVERED = 19
ORDER_STATUS_RETURNED = 20
TRANSFER_ORDER_REACHED = 21
TRANSFER_ORDER_RECEIVED = 22
ISSUE_RESOLUTION = 23
```

Important pattern from CDS snippet id `39`:
- Sorted status log in OSC:

```sql
SELECT COUNT(DISTINCT order_id)
FROM courier_realtime_datastream.public_order_status_changes
WHERE 1=1
  AND (updated_at IS NOT NULL OR updated_at IS NULL)
  AND status_id = 9
  AND type IN (12)
  AND DATE(created_at) BETWEEN '2026-02-01' AND '2026-02-10'
```

## Run Routes Transfer Type

CDS snippet id: `34`
Title: `transfer_type`
Description: `run_routes`
Category: `Key's Description`

Range meanings:

```text
1-19 = Pickup
20-79 = Transfer
80-81 = Delivery
```

Specific values:

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

## Run Routes Orders Status

CDS snippet id: `40`
Title: `status (run_routes_orders)`
Description: `[blank in CDS]`
Schema: `hermes-appdb-replica-3`

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

## Basket Run Route Status

CDS snippet id: `41`
Title: `status (basket_run_route)`
Description: `[blank in CDS]`
Schema: `hermes-appdb-replica-3`

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

## Basket Orders Existence Status

CDS snippet id: `42`
Title: `existence_status (basket_orders)`
Description: `[blank in CDS]`
Schema: `hermes-appdb-replica-3`

```text
0 = Assigned
1 = Confirmed
2 = Missing
3 = extra
4 = found
```

## Dispatch Requests Status

CDS snippet id: `37`
Title: `dispatch_requests`
Description: `C2C - dispatch_requests`
Schema: `hermes-appdb-replica-3`

```text
0 = Requested
1 = Attempting
2 = Dispatched
3 = TimedOut
4 = Ineligible
5 = ScheduleForNextDay
```

## Dispatch Attempts Status

CDS snippet id: `36`
Title: `dispatch_attempts`
Description: `C2C - dispatch_attempts`
Schema: `hermes-appdb-replica-3`

```text
0 = [blank in CDS]
1 = accepted
2 = rejected
3 = timed_out
4 = [blank in CDS]
```

Open mapping gap:
- CDS has blank values for `dispatch_attempts` status `0` and `4`; ask Human Oracle before using those labels.

## Billing Status ID

CDS snippet id: `38`
Title: `billing_status_id`
Description: `Orders table`
Category: `Case Functions`

```sql
CASE billing_status_id
  WHEN 0 THEN 'Pending'
  WHEN 1 THEN 'Waiting for accounts approval'
  WHEN 2 THEN 'Approved by accounts'
  WHEN 3 THEN 'Invoice generated'
  WHEN 4 THEN 'Invoice processing'
  WHEN 5 THEN 'Invoice paid'
END AS payment_status
```

## Payout Status

CDS snippet id: `29`
Title: `payout_status`
Description: `Order_invoices`

```text
not invoice = 0
pending = 3
processing = 4
paid = 5
in queue = 8
```

## Hub Payment Status

CDS snippet id: `28`
Title: `hub_payment_status`
Description: `Order_invoices`

```text
not_submitted = 0
submitted = 1
accounts approved = 2
```

## Order Invoices Status ID

CDS snippet id: `35`
Title: `status_id (order_invoices)`
Description: `Order_invoices`

```text
Waiting for accounts approval = 1
```

Open mapping gap:
- CDS only documents value `1`; ask before mapping other `order_invoices.status_id` values.

## Item Type ID

CDS snippet id: `31`
Title: `item_type_id`
Category: `Key's Description`
Schema: `hermes-appdb-replica-3`

```text
1 = Document
2 = Parcel
3 = Fragile
4 = Book
5 = Secured Document
6 = SKU
```

## Delivery Type / Price Plan Slab

CDS snippet id: `27`
Title: `delivery_type(price_plan_slab)`
Category: `Key's Description`

```text
on_demand = 12
regular = 48
```

## Agent Role Type

CDS snippet id: `7`
Title: `Agent Role Type`
Category: `Case Functions`

```sql
CASE role_type
  WHEN 1 THEN 'Delivery Agent'
  WHEN 2 THEN 'Pickup Agent'
  WHEN 3 THEN 'Van Duty Agent'
  WHEN 4 THEN 'On-Demand Agent'
  WHEN 5 THEN NULL
  WHEN 11 THEN 'Driver Agent'
  WHEN 16 THEN 'Sort Agent'
  ELSE NULL
END AS role_type
```

## Distance ID Mapping

CDS snippet id: `32`
Title: `Distance ID Mapping`
Category: `Case Functions`

```sql
CASE
  WHEN pickup_hub = 'ISD' AND delivery_hub = 'ISD' THEN 1
  WHEN pickup_hub = 'ISD' AND delivery_hub = 'OSD' THEN 2
  WHEN pickup_hub = 'ISD' AND delivery_hub = 'RSD' THEN 3
  WHEN pickup_hub = 'RSD' AND delivery_hub = 'ISD' THEN 4
  WHEN pickup_hub = 'RSD' AND delivery_hub = 'RSD' THEN 5
  WHEN pickup_hub = 'RSD' AND delivery_hub = 'OSD' THEN 6
  WHEN pickup_hub = 'OSD' AND delivery_hub = 'ISD' THEN 7
  WHEN pickup_hub = 'OSD' AND delivery_hub = 'RSD' THEN 8
  WHEN pickup_hub = 'OSD' AND delivery_hub = 'OSD' THEN 9
END AS distance_id

## Issue Activity Logs Type

CDS snippet id: `43`
Title: `issue_acticity_logs type`
Category: `Key's Description`

```text
1 - New Issue
2 - BULK_REPORTER_ASSIGN
3 - BULK_ASSIGNEE_ASSIGN
4 - ISSUE_SOLVED
5 - ISSUE_CLOSED
6 - REPORTER_ASSIGNED
7 - CATEGORY_CHANGED
8 - SUB_CATEGORY_CHANGED
9 - REPORTER_REASSIGN
10 - HANDOVER_TO_IR
11 - ASSIGNED_TO_IR
12 - ISSUE_SOLVED_BY_IR
13 - ISSUE_TIME_EXTENDED
14 - CC_ADDED
15 - CC_REMOVED
```

SQL-generation note:
- `type IN (2, 11)` is used in IR agent productivity cards for 'assigned' events (BULK_REPORTER_ASSIGN and ASSIGNED_TO_IR).
- `type = 10` (HANDOVER_TO_IR) is used for IR handover events.
- `type = 11` (ASSIGNED_TO_IR) is used when an issue is assigned specifically to an IR team member.

## Related Notes

- [[04_SQL_Patterns/cds_cte_patterns.md|CDS CTE Patterns]] — reusable CTEs from same CDS source
- [[03_Business_Logic/order_status_changes_human_oracle.md|OSC Human Oracle]] — uses CDS OSC type mapping
- [[03_Business_Logic/order_fields_human_oracle.md|Order Fields Human Oracle]]
- [[03_Business_Logic/merchant_logic_human_oracle.md|Merchant Logic Human Oracle]] — references merchant_type from CDS
- [[03_Business_Logic/hub_facility_logic_human_oracle.md|Hub Facility Logic]] — hub_operation_type mapping
- [[03_Business_Logic/run_routes_human_oracle.md|Run Routes Human Oracle]] — transfer_type mapping from CDS
- [[06-SYSTEM/semantic-layer/glossary.md|Glossary]]
- [[04_SQL_Patterns/phase2_initial_table_patterns.md|Initial Table Patterns]]
