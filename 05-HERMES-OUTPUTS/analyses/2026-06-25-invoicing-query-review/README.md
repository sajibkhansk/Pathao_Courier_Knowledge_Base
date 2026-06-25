# Delivery-to-Invoice Timeline Query Review

Status: observed
Type: investigation

## Purpose
Review the user-provided SQL that measures delivery-to-submission, delivery-to-approval, and approval-to-invoice SLA timing for Pathao Courier.

## Context
- **Source:** User-pasted SQL in WhatsApp
- **Theme:** Invoice SLA / delivery-to-invoice reporting
- **Scope:** Delivery date, submission date, approval date, payment invoice creation date

## Static Findings

### 1) Query syntax issue in the orders CTE
The first CTE currently reads:

```sql
WITH orders AS (
    SELECT consignment_iitstransfer_status_updated_at
    FROM `courier_realtime_datastream.public_orders`
```

This looks malformed. It likely intended to select `consignment_id` and `transfer_status_updated_at`.
As written, the query will not run.

### 2) Join grain can duplicate consignments
The query uses:
- `LEFT JOIN public_order_invoices oi ON oi.consignment_id = o.consignment_id`
- `LEFT JOIN public_payment_invoices pi ON pi.id = oi.payment_invoiced_id`

If `public_order_invoices` contains more than one row per consignment, the final result will inflate counts and sums because the final `COUNT(*)` and `SUM(total_fee)` are row-based after the join.

### 3) A label and cutoff do not match
The alias `submitted_by_next_day_1145am` uses a cutoff of `TIME '13:00:00'`.
That is 1:00 PM, not 11:45 AM.

### 4) Denominators are inconsistent across stages
Examples:
- some metrics divide by `COUNT(*)`
- some divide by `COUNT(submitted_at)`
- some divide by `COUNT(approved_at)`

That makes the percentages harder to compare across stages unless the mixed denominator choice is intentional and documented.

### 5) Invoice deduplication is missing
The CDS CTE pattern for `public_payment_invoices` uses `QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1`.
This query does not dedupe payment invoices, so it is less safe than the known pattern.

### 6) Business-metric default filters are incomplete
For Pathao courier business reporting, current KB standards say to exclude the panel merchant with `merchant_id <> 1`.
This query filters `country_id = 1` but does not exclude merchant 1.

### 7) Timezone handling is mixed but acceptable if intentional
The query filters on raw timestamps and then converts output dates to `Asia/Dhaka`.
That is workable for business-day reporting, but it should be stated explicitly because the KB default is UTC unless local time is requested.

## Query Meaning
This query is trying to report the delivery-to-invoice funnel by delivered date:
- delivered orders
- submitted same day / by next day / within 3 days / not within 3 days
- approved same day / within 3 days / not within 3 days
- invoiced same day / within 3 days / within 7 days / uninvoiced counts and revenue

## Reusability Assessment
Reusable idea:
- one-row-per-consignment SLA funnel from delivery → submission → approval → payment invoice
- date-bucketed status counts with percentage strings

Reusable caveats:
- requires deduped invoice tables
- requires a single agreed denominator strategy
- requires the label text to match the actual cutoff

## Confidence
- Score: 7/10
- Why: The logic issues are visible from static inspection of the SQL and the KB-backed CDS pattern comparison.
- Needs: live execution after fixing the syntax and deduping joins.

## Next Step for Canonical KB
If approved by a human reviewer, this should likely become either:
- a reusable SQL pattern under `04_SQL_Patterns/`, or
- an invoicing business-logic note if the SLA cutoffs are formally confirmed.

## Source
- User-provided SQL review, WhatsApp, 2026-06-25
