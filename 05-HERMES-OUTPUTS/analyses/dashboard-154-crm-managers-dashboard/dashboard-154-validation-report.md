# Dashboard 154 — Validation Report

> **Generated:** 2026-06-19
> **Dashboard:** 154 — CRM Managers Dashboard
> **URL:** https://courierbi.pathaointernal.com/dashboard/154

## Validation Summary

| Check | Result |
|---|---|
| Cards extracted via REST API | ✅ 15/15 |
| Native SQL recovered | ✅ 15/15 |
| Dashboard parameters captured | ✅ 9/9 |
| Tables identified | ✅ 11 tables across db5 and db7 |
| Fields traced per card | ✅ Complete |
| Filter-to-card mappings | ✅ Complete |
| Business logic verified | ✅ 13 topics documented |
| Discrepancies found | 12 identified |
| Oracle questions formulated | 12 questions |

## Card Coverage

| Tab | Card ID | Card Name | SQL Extracted | Analyzed | Has Filters? |
|---|---|---|---|---|---|
| Overview | 2013 | Total Leads | ✅ | ✅ | ❌ None |
| Overview | 2028 | Total Processed | ✅ | ✅ | ❌ None (reads card 2060) |
| Overview | 2029 | Total Expected Revenue | ✅ | ✅ | ❌ None |
| Overview | 2031 | Merchant Distribution | ✅ | ✅ | ❌ None |
| Overview | 2033 | First Trip Conversion (Organic) | ✅ | ✅ | ❌ None |
| Overview | 2050 | Forecast Orders | ✅ | ✅ | ❌ None |
| Overview | 2158 | Total Leads Rejected | ✅ | ✅ | ✅ current_month, start_date, end_date |
| Overview | 2260 | Team Wise Distribution [Orders] | ✅ | ✅ | ✅ merchant_id, crm_member_name, onboard_type |
| Overview | 2262 | Order Trend CRM | ✅ | ✅ | ❌ None |
| Performance Tracker | 2030 | Performance Tracker | ✅ | ✅ | ✅ onboard_type |
| Performance Tracker | 2060 | Sales Overview [Merchants] | ✅ | ✅ | ✅ merchant_id, crm_member_name, onboard_type, team_name, last_day_order |
| Leaderboard | 2114 | Leaderboard | ✅ | ✅ | ✅ onboard_type, team_name, crm_member_name |
| CRM Entry Checker | 2271 | CRM Merchant Entry Checker [Admin] | ✅ | ✅ | ✅ merchant_id, phone |
| Historical | 2400 | Historical Merchant Overview | ✅ | ✅ | ✅ merchant_id, crm_member_name, onboard_type, start_date, end_date |
| Historical | 2402 | Historical Leaderboard | ✅ | ✅ | ✅ onboard_type, team_name, crm_member_name, start_date, end_date |

## Tables Validated

| Database | Table | Cards Referencing | Status |
|---|---|---|---|
| db7 | courier_appsmith.new_onboards | 15 | ✅ Core |
| db7 | courier_realtime_datastream.public_orders | 11 | ✅ Core |
| db7 | courier_realtime_datastream.public_archived_orders | 9 | ✅ Core |
| db7 | courier_realtime_datastream.public_merchants | 10 | ✅ Core |
| db7 | courier_appsmith.business_team_users | 7 | ✅ |
| db7 | courier_appsmith.business_team | 5 | ✅ |
| db7 | hermes_bz_comms.crm_user_targets | 2 | ✅ |
| db7 | hermes_bz_comms.business_team_targets | 1 | ✅ |
| db7 | hermes_bz_comms.courier_transfer_status | 0 (snippet) | ⚠️ Not present |
| db5 | AppSmith-Write-DB.new_onboards | 1 (2271) | ✅ |
| db5 | AppSmith-Write-DB.business_team_users | 1 (2271) | ✅ |
| db5 | AppSmith-Write-DB.public_users | 1 (2271) | ✅ |

## High-Priority Findings

1. **P0: Card 2271 join bug** — `btu.id` used instead of `btu2.id` for assigner name
2. **P0: NULL handling divergence** — 7 cards use `is_deleted <> TRUE` which misses NULLs
3. **P1: Hardcoded date** — Card 2031 has `updated_at >= "2026-01-01"` which will stale
4. **P1: Transfer status divergence** — 3 cards hardcode status lists vs 7 using server snippet
5. **P2: 7 cards ignore dashboard filters** — Overview scalars show all data regardless of filter selection
6. **P2: Card 2402 forecast is identity** — forecast equals actual (days_in_period == total_days_in_period)

## Confidence

- SQL accuracy: 100% (extracted directly from REST API)
- Business logic interpretation: 90% (most logic confirmed by cross-card comparison)
- Filter-to-card mapping: 95% (parameter names may have dashboard-level aliases not visible via API)
- Open questions: Need Human Oracle for 12 items
