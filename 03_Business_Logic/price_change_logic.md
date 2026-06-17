# Price Change / COD Reduction Logic — Human Oracle Notes

Status: Phase 3 Metabase Deep Dive — Price Change collection (id=476) and related cards.

## Source Assets Inspected

Metabase / REST inspection:

| Card ID | Name | Notes |
|---:|---|---|
| 2256 | Price Change Consignment Level - Ops | In Price Change collection 476 |
| 2577 | Price Change Consignment Level - Ops | Similar card in collection 513 |
| 2166 | Price Change For QC to Call | QC workflow card |
| 2162 | Price Change Agent Summary - Modified for QC | Agent summary |
| 2164 | Price Change Merchant Summary - Modified | Merchant summary |
| 2098 | Price Change Order Count | Earlier/related count card |
| 2104 | Price Change Agent Summary | Earlier/related agent summary |
| 2128 | Price Change Merchant Summary | Earlier/related merchant summary |

Observed common tables:
- `courier_realtime_datastream.public_orders`
- `courier_realtime_datastream.public_archived_orders`
- `courier_realtime_datastream.public_order_invoices`
- `courier_realtime_datastream.public_merchants`
- `courier_realtime_datastream.public_hubs`
- `courier_realtime_datastream.public_agents`
- `courier_realtime_datastream.public_run_routes_orders`
- `courier_realtime_datastream.public_order_status_changes` (required for canonical price-change detection per Human Oracle)

## Business Definition

Human Oracle guidance:
- Price Change means the order's **collectable amount is changed**.
- After the change, `collectable_amount` and `collected_amount` should match in `public_orders`.
- Therefore, do **not** identify price change only by checking `public_orders.collectable_amount <> public_orders.collected_amount`.
- To identify actual price changes, check **OSC logs** (`public_order_status_changes`).

SQL-generation rule:

```sql
-- Do not use this as canonical price-change detection:
-- o.collectable_amount <> o.collected_amount

-- Canonical detection must inspect OSC logs for collectable amount changes.
-- Exact OSC payload/status/desc pattern still needs documentation.
```

## Merchant OTP Meaning

Human Oracle guidance:
- `merchant_otp = delivery_method` indicates that the merchant-provided OTP was used to change the price.

Observed card pattern:

```sql
CASE
  WHEN o.delivery_method = rro.merchant_otp THEN 'Merchant OTP'
  WHEN o.delivery_method = rro.user_otp THEN 'User OTP'
  WHEN o.delivery_method = rro.hermes_otp THEN 'Hermes OTP'
  ELSE 'Unknown'
END AS otp_medium
```

Interpretation:
- For price-change analytics, `o.delivery_method = rro.merchant_otp` means merchant OTP was the OTP medium used for the price change.
- `rro.merchant_otp IS NOT NULL` alone is weaker than the equality condition; prefer comparing `delivery_method` against OTP fields when identifying the OTP medium.

## Thresholds and Flagging Numbers

Human Oracle guidance:
- Thresholds seen in cards are **changeable flagging numbers**, not permanent business definitions.
- Do not hardcode them as canonical business logic unless the report/card explicitly requires them.

Observed thresholds:

```sql
SAFE_DIVIDE(o.collectable_amount - o.collected_amount, o.collectable_amount) > 0.1
```

Used as a QC-call threshold in observed cards, but not canonical.

```sql
SAFE_DIVIDE(o.collectable_amount - o.collected_amount, o.collectable_amount) >= 0.8
```

Used to bucket `Major COD Reduction(>=80%)`, but not canonical.

```sql
HAVING collusion_orders >= 3
```

Used to flag repeated behavior, but not canonical.

SQL-generation rule:
- Treat these as report parameters / tunable thresholds.
- If a stakeholder asks for “price change” generally, first identify price changes from OSC logs, then apply thresholds only if requested.

## Delivered vs Exchange Orders

Human Oracle guidance:
- Exchange orders (`transfer_status_id = 42`) are part of price-change detection.
- Fraud-case detection may deal only with delivered orders (`transfer_status_id = 13`).

SQL-generation rule:

```sql
-- General price-change detection should include both delivered and exchange orders where relevant:
o.transfer_status_id IN (13, 42)

-- Fraud-specific detection may use delivered only:
o.transfer_status_id = 13
```

## Potential COD Fee Loss Pattern

Observed cards estimate potential COD fee loss from the price-change amount and merchant COD fee rate by delivery hub operation type:

```sql
CASE
  WHEN h.hub_operation_type = 1 THEN ROUND(SAFE_DIVIDE(o.collectable_amount - o.collected_amount, 100) * (SAFE_CAST(COALESCE(m.isd_cod_fee, 1.0) AS FLOAT64) / 100))
  WHEN h.hub_operation_type = 2 THEN ROUND(SAFE_DIVIDE(o.collectable_amount - o.collected_amount, 100) * (SAFE_CAST(COALESCE(m.osd_cod_fee, 1.0) AS FLOAT64) / 100))
  WHEN h.hub_operation_type = 3 THEN ROUND(SAFE_DIVIDE(o.collectable_amount - o.collected_amount, 100) * (SAFE_CAST(COALESCE(m.sub_area_cod_fee, 1.0) AS FLOAT64) / 100))
END AS potential_cod_fee_loss_tk
```

Caution:
- This observed formula is based on `collectable_amount - collected_amount`; after the Human Oracle correction, it may only be suitable for legacy/fraud flagging cards, not canonical price-change detection.
- Canonical price-change amount should come from OSC old/new collectable values once the OSC pattern is documented.

## Open Questions

1. Which OSC event identifies collectable amount change: specific `type`, `status_id`, `desc`, or payload key?
2. In OSC `payload`, what are the exact JSON paths for old/new collectable amount? Example candidates: `$.old.collectable_amount`, `$.new.collectable_amount`.
3. Is `delivery_method` always the OTP value used for the price change, or can it also represent normal delivery OTP outside price-change cases?
4. For fraud-specific detection, should the canonical status filter be `transfer_status_id = 13` only, with exchange excluded unless explicitly requested?
