# Return Aging Logic

Source: Card #1360 ("Return Aging and Count", DB 4) + user correction (2026-06-20)

## Aging Calculation

Return aging measures the time it takes for a return parcel to reach a final resolved state.

**Start timestamp** (parameterized, Card #1360 supports all three):
- `created_at` — when the return order was created in the system
- `sorted_at` — when the parcel was printed, POD stickered, and scanned into the system
- `lmh_at` — when the parcel reached the Last Mile Hub

**End timestamp** (parameterized):
- `transfer_status_updated_at` — when the status changed to a final state
- Referred to as `final_at` in Card #1360

**Aging unit:** `DATE_DIFF(DATE(end), DATE(start), DAY)` — whole days, not hours.

**Final returned statuses considered:**
- 21 — Returned to Merchant
- 35 — Returned to Inventory

## Data Source

Must UNION ALL both live and archived tables for complete historical coverage:

```sql
SELECT ... FROM `courier_realtime_datastream.public_orders`
UNION ALL
SELECT ... FROM `courier_realtime_datastream.public_archived_orders`
```

## Strict Denominator

Card #1360 only counts orders where BOTH start AND end dates are non-null. This ensures percentages sum to exactly 100%.

## Open Questions

- What does `lmh_at` represent exactly and when is it populated?
- When should `sorted_at` vs `created_at` be preferred as the start?
