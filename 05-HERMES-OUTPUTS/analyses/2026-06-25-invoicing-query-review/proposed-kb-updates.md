# Proposed KB Updates — Delivery-to-Invoice Query Review

## Pending candidate

### Delivery-to-invoice funnel pattern
- **Type:** SQL pattern
- **Status:** pending
- **Proposed destination:** `04_SQL_Patterns/delivery_to_invoice_timeline_pattern.md`
- **Scope:** Delivery-to-submission, delivery-to-approval, approval-to-invoice SLA analyses
- **Proposed rule:** Use a single deduped consignment grain before calculating SLA buckets; keep the denominator strategy consistent across stages; make label text match the actual cutoff time.
- **Evidence:** Static review of the user-provided invoicing SQL plus comparison with the CDS `payment_invoices` dedupe pattern.

## Human confirmation needed

The following details should not be promoted without confirmation:
- Whether `11:45am` or `13:00:00` is the intended next-day submission cutoff
- Whether merchant `1` should be excluded from invoicing reports
- Whether the report should be built on UTC or Asia/Dhaka business dates
- Whether invoice counts should be based on submission rows, approval rows, or unique consignments
