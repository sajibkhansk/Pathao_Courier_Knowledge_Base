# Run Routes Transfer/Basket SQL Patterns

Status: split out from `03_Business_Logic/run_routes_human_oracle.md` during KB structure cleanup.

Scope:
- Transfer run SQL patterns.
- Direct/bulk parcel assignment via `run_routes_orders`.
- Basket-contained parcel assignment via `basket_run_route` + `basket_order`.
- Closed-run summary counts from `run_route_logs.payloads`.

Related business logic file:
- `03_Business_Logic/run_routes_human_oracle.md`

## Pattern: All Parcels in a Transfer Run, Including Basket and Direct Assignments

Source: Human Oracle supplied sample SQL pattern for Hermes app DB / Postgres-style querying.

Purpose:
- Get all parcels in a transfer run (`run_route_type = 2`).
- Include both:
  - direct/bulk parcels from `run_routes_orders`
  - basket-contained parcels through `basket_run_route` + `basket_order`

Important concepts:
- Direct/bulk branch uses `run_routes_orders` and has no basket id/consignment.
- Basket branch joins `basket_run_route` to `basket_order` and `baskets`.
- Use `received_run_id` and basket/order status fields to inspect receipt/missing scenarios.
- Use `orders UNION ALL archived_orders` to resolve consignment IDs in app DB context.

```sql
WITH orders AS (
    SELECT id, consignment_id
    FROM orders 
    
    UNION ALL
    
    SELECT id, consignment_id
    FROM archived_orders
)

SELECT consignment_id, A.*
FROM (    
    SELECT 
    order_id, run_route_id, rr.from_hub, rr.to_hub, received_run_id,
    NULL::integer as basket_id, NULL::TEXT as basket_con,
    TIMEZONE('Asia/Dhaka',  rro.created_at AT TIME ZONE 'UTC') as created_at,
    TIMEZONE('Asia/Dhaka',  rro.updated_at AT TIME ZONE 'UTC') as updated_at, 
    status AS order_status, NULL AS basket_status
    FROM run_routes_orders rro 
    LEFT JOIN run_routes rr ON rro.run_route_id = rr.id 
    
    UNION ALL 
    
    SELECT 
    bo.order_id, run_route_id, rr.from_hub, rr.to_hub, received_run_id,
    brr.basket_id, b.consignment_id AS basket_con,
    TIMEZONE('Asia/Dhaka',  bo.created_at AT TIME ZONE 'UTC') as created_at,
    TIMEZONE('Asia/Dhaka',  bo.updated_at AT TIME ZONE 'UTC') as updated_at, 
    bo.existence_status AS order_status, brr.status AS basket_status
    FROM basket_run_route brr
    LEFT JOIN basket_order bo ON bo.basket_id = brr.basket_id
    LEFT JOIN baskets b ON bo.basket_id = b.id
    LEFT JOIN run_routes rr ON brr.run_route_id = rr.id
) A 
LEFT JOIN orders o ON A.order_id = o.id 
LEFT JOIN run_routes rr ON A.run_route_id = rr.id
WHERE 1=1 
AND run_route_type = 2
-- AND run_route_id = 5381877
-- AND consignment_id = 'DB180625TPJNJM'
-- AND order_id = 117792831
```

## Pattern: Closed Transfer Run Summary Counts from `run_route_logs`

Business rule:
- For transfer runs, standard received/missing counts are available in `run_route_logs.payload` / `payloads` for the `Run Closed` log.
- In Metabase table id `109`, the JSONB column was observed as `payloads`.
- Business users may refer to it as `payload`.

Sample inspection query:

```sql
SELECT *
FROM run_route_logs
WHERE run_route_id = 11347492
  AND name = 'Run Closed'
```

Observed payload keys:
- `Received Order`
- `Missing Order`
- `Removed Order`
- `Received Basket`
- `Missing Basket`
- `Removed Basket`
- `User`

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

SQL-generation notes:
- Use these payload counts as the close summary source for transfer runs.
- Use basket/direct parcel joins mainly for detail-level tracing.
- Treat `Received Order` / `Missing Order` / `Removed Order` as direct/bulk-order counts.
- Treat `Received Basket` / `Missing Basket` / `Removed Basket` as basket counts unless a later Human Oracle correction says otherwise.
- Validate whether all `Run Closed` rows consistently use these exact JSON keys before broad automated reporting.
