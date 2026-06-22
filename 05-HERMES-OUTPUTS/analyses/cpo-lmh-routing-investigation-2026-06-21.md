# CPO-to-LMH Routing Classification — Direct vs Sub-Sort vs No-CPO

Status: observed
Type: investigation

## Purpose
Document the routing classification query and extraction patterns used to identify parcels that reached three Chittagong/Sylhet LMH delivery hubs via direct CPO routing, via sub-sort, or without CPO involvement at all.

## Related
- [[03_Business_Logic/hub_facility_logic_human_oracle]] — hub type/operation definitions, Central Sort = hubs 19 (ISD) and 55 (OSD)
- [[06-SYSTEM/semantic-layer/tables/public_orders]] — primary orders fact table
- [[06-SYSTEM/semantic-layer/tables/public_archived_orders]] — historical coverage
- [[04_SQL_Patterns/cds_cte_patterns]] — CDS CTE patterns for orders/hubs

## Context
- **Task:** User requested consignments for Chittagong-Halishahar, Chittagong-Nasirabad, Sylhet-Jalalabad that bypassed sub-sort and went direct from CPO to LMH. Then followed up for parcels that reached LMH without CPO involvement at all.
- **Period:** `sorted_at >= 2026-06-18` (Dhaka time)
- **Tables:** `public_orders`, `public_order_status_changes`, `public_basket_order`, `public_basket_logs`, `public_hubs`
- **User-provided diagnostic query** classified routing into: ALWAYS_DIRECT, MOSTLY_DIRECT, MIXED, ALWAYS_VIA_SUBSORT, and no_cpo_involvement.

## Observation

### Hub-level routing classification (sorted >= June 18, 2026)

| Delivery Hub | CPO→Direct LMH | No CPO Involved | Total Observed |
|---|---|---|---|
| Chittagong-Halishahar | 6,299 | 1,912 | 8,211 |
| Chittagong-Nasirabad | 3,616 | 1,345 | 4,961 |
| Sylhet-Jalalabad | 2,132 | 629 | 2,761 |

All three hubs showed **zero** orders routed via sub-sort (CPO → intermediate hub → LMH). Every order was either CPO direct or no CPO at all.

The diagnostic query's `order_routing` classifications:
- **has_direct_cpo_to_lmh = 1 AND has_cpo_to_subsort = 0** → CPO (hub 55) appeared as a direct predecessor to the delivery hub; no intermediate sub-sort hub detected.
- **has_direct_cpo_to_lmh = 0 AND has_cpo_to_subsort = 0** → No evidence of CPO (55) anywhere in the order's routing chain. Likely routed from Central ISD (hub 19) or other origin.
- **Neither hub showed the "via sub-sort" pattern** — meaning if CPO touched these orders, it was always the last hop before the LMH.

## Interpretation

- **Chittagong-Halishahar, Nasirabad, and Sylhet-Jalalabad are ALWAYS_DIRECT from CPO** — no sub-sort intermediate stage for any parcel in the observation window.
- The ~24% of parcels with no CPO involvement (1,912 + 1,345 + 629) may have originated from the ISD sort center (hub 19) rather than OSD CPO (hub 55). This is plausible for Chittagong/Sylhet destinations if some volume flows through the ISD network.
- **The "100% breach rate" mentioned in the original diagnostic query** for these hubs' central_to_lmh stage is NOT because of sub-sort delays — it appears to be inherent to the direct CPO→LMH routing itself, possibly due to transit time on this long-distance leg.

## Reusability
- **Candidate SQL pattern:** The two-stage approach (diagnostic → extraction) is reusable.
  - Stage 1: Diagnostic query classifies routing per delivery hub (CPO→direct, CPO→subsort, no CPO, mixed).
  - Stage 2: Extraction query filters for specific routing type + hub and outputs consignment IDs.
- **Candidate business logic:** The routing classification (has_direct_cpo_to_lmh / has_cpo_to_subsort flags) could become canonical hub routing logic.
- The CTE chain (`target_orders → order_status_events ∪ basket_received_events → sequenced_events → hops_enriched → order_routing`) is a reusable hop-tracking pattern.

## Validation Status
- [x] Query executed and verified against live BigQuery data
- [x] Consignment counts cross-checked (count query + extraction query match)
- [ ] Hub 19 (Central ISD) hypothesis for no-CPO parcels not yet confirmed
- [ ] Transit time analysis for direct CPO→LMH not yet run
- [ ] Whether this pattern holds beyond June 18-21 window not yet checked
- [ ] User approval for promotion not yet received

## Query / Extraction Notes

### Classification Query (diagnostic — original from user)

Core logic:
1. `target_orders`: parcels with `delivery_hub_id` matching target hubs
2. `order_status_events`: OSC events filtered to in-transit statuses (8-40 range, excluding pickup/return/delivery terminals); deduplicated per `(order_id, hub_id, status_id)`
3. `basket_received_events`: basket receive events (`basket_status = '9'`, `name = 'Basket Status Updated'`) for parcels in baskets
4. `sequenced_events`: both sources UNION ALL, then `LAG(hub_id)` partitioned by `order_id` ordered by event time
5. `hops_enriched`: filter `prev_hub_id IS NOT NULL AND hub_id != prev_hub_id` — actual hub-to-hub hops
6. `order_routing`: per-order flags:
   - `has_direct_cpo_to_lmh`: `from_hub_id = 55 AND to_hub_id = delivery_hub_id`
   - `has_cpo_to_subsort`: `from_hub_id = 55 AND to_hub_id NOT IN (delivery_hub_id, 19, 15, 55)`

### Extraction Query (for consignment lists)

Identical CTE chain. Final SELECT filters:
```sql
-- Direct CPO→LMH
WHERE has_direct_cpo_to_lmh = 1 AND has_cpo_to_subsort = 0

-- No CPO involvement
WHERE has_direct_cpo_to_lmh = 0 AND has_cpo_to_subsort = 0
```

### Partition keys used
| Table | Partition Key | Filter |
|---|---|---|
| `public_orders` | `updated_at` (26643) | `>= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 DAY)` |
| `public_order_status_changes` | `created_at` (26614) | `>= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 DAY)` |
| `public_basket_order` | `updated_at` | `>= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 DAY)` |
| `public_basket_logs` | `updated_at` | `>= TIMESTAMP('2026-05-20', 'Asia/Dhaka')` |

### REST API cap workaround
Metabase REST API caps at 2000 rows. For Halishahar (6,299 direct) and Nasirabad (3,616), pagination was required using `consignment_id > 'last_seen_id'` anchor in the `target_orders` CTE, followed by deduplication.

### Files produced
- `05_HERMES_OUTPUT/analyses/direct_lmh_combined.txt` — 12,047 CPO-direct consignments
- `05_HERMES_OUTPUT/analyses/no_cpo_lmh_combined.txt` — 3,886 no-CPO consignments

## Next Actions
- [ ] Confirm hub 19 (Central ISD) routing for no-CPO parcels
- [ ] Run transit time analysis for the direct CPO→LMH leg (these are the "100% breach" hubs)
- [ ] Test whether pattern holds for other date windows
- [ ] Ask user: promote routing classification to canonical business logic?

## Source Notes
- Original diagnostic query provided by user (Sajib Khan, WhatsApp, 2026-06-21)
- [[03_Business_Logic/hub_facility_logic_human_oracle]] — Sorting Center = hubs 19, 55
