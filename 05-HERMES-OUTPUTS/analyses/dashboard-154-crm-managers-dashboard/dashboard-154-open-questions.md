# Dashboard 154: Open Questions & Discrepancies

> **Dashboard:** 154 — CRM Managers Dashboard  
> **Generated:** 2026-06-19  
> **Status:** For Human Oracle Review

---

## 1. Identified Discrepancies

### 1.1 NULL Handling — `is_deleted` Filter

| Severity | Category | Description |
|---|---|---|
| **HIGH** | Data correctness | **7 of 15 cards** use `is_deleted <> TRUE` which does NOT exclude rows where `is_deleted IS NULL`. |

**Cards with incorrect NULL handling:**
- 2013: `is_deleted <> TRUE`
- 2029: `is_deleted <> TRUE`
- 2031: `is_deleted <> TRUE`
- 2033: `is_deleted <> TRUE`
- 2158: `is_deleted <> true`
- 2030: `is_deleted <> true`

**Cards with correct NULL handling:**
- 2050: `is_deleted IS DISTINCT FROM TRUE`
- 2260, 2262, 2060, 2114, 2400, 2402: `is_deleted IS NOT TRUE`

**Cards with no check at all:**
- 2271: No `is_deleted` check — returns deleted records.

> **Impact:** Cards 2013, 2029, 2031, 2033, 2158, 2030 may silently include soft-deleted records where `is_deleted` is NULL, inflating their counts relative to cards with correct handling.

---

### 1.2 Hardcoded Dates

| Card | Hardcoded Value | Impact |
|---|---|---|
| **2031** (Merchant Distribution) | `updated_at >= "2026-01-01"` on orders CTE | Will silently drop all orders before 2026. For merchants with first orders in 2023–2025, `first_order_date` may be wrong or NULL. **This date will become stale.** |

> **Proposed fix:** Change to `updated_at IS NOT NULL` (matching all other cards) or use a parameterized window.

---

### 1.3 Hardcoded Transfer Status ID Lists

| Approach | Cards | Status IDs | Count | Risk |
|---|---|---|---|---|
| Snippet `{{snippet: processed_orders}}` | 2029, 2031, 2050, 2060, 2114, 2260, 2262 | Server-managed | Unknown | ✅ Updates automatically |
| Hardcoded (22 values) | **2158** | `8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42` | 22 | ❌ Won't pick up snippet updates |
| Hardcoded (40 values) | **2400, 2402** | `5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44` | 40 | ❌ Won't pick up snippet updates |

> **Key question for Oracle:** What is in the `processed_orders` snippet? Does it match the 22-status list, the 40-status list, or something else? If snippet ≠ hardcoded, revenue comparisons across tabs are invalid.

**Differences between hardcoded lists:**
- 2158 list (22 values): Missing statuses `5,6,7,16,17,18,19,20,21,27,29,34,35,43,44` — 15 missing
- 2400/2402 list (40 values): Contains all of 2158 plus 18 additional statuses
- The additional statuses (5–7, 16–21, 27, 29, 34–35, 43–44) are included in historical cards but excluded from the current-month "rejected leads" card

---

### 1.4 Join Bug — Card 2271

| Severity | Card | Bug |
|---|---|---|
| **CRITICAL** | 2271 (CRM Merchant Entry Checker) | Second JOIN: `left join business_team_users btu2 on btu.id = CAST(assigner_user_id as INT)` uses `btu.id` instead of `btu2.id` |

**Impact:** The `user_name_2` column (intended to show the assigner's name) will always show the assignee's name when `business_team_user_id = assigner_user_id`, or NULL otherwise. The assigner name is effectively broken.

---

### 1.5 Dead / Unused CTEs and Joins

| Card | Dead Code | Notes |
|---|---|---|
| **2158** (Total Leads Rejected) | Entire `orders`, `merchants`, `orders_month`, `final` CTEs | Final SELECT only does `COUNT(n.id)`. The complex order/revenue CTEs are computed but never used in output. Only `new_onboards` data matters. |
| **2262** (Order Trend CRM) | `business_team_users` join | Joined but no columns from `btu` appear in final SELECT. |
| **2031** (Merchant Distribution) | `expected_rvn_all` in orders_month CTE | Revenue is computed but not used in the final pie chart output (only `Status` and `Merchant_Count`). |

---

### 1.6 Parameter Name Inconsistency (Parameter Drift)

| Filter Slug | Used in Cards As | Mismatch |
|---|---|---|
| `merchant_id` | `merchant_ID` (2260, 2060, 2400, 2402) | Case difference: `ID` vs `id` |
| `merchant_id` | `merchant_id` (2271) | Lowercase |
| `crm_member_name` | `Acq_Member_Name` (2260, 2060, 2400, 2402) | Different parameter name entirely |
| `crm_member_name` | `Acq_Name` (2114) | Different parameter name entirely |
| `team_name` | `Team_name` (2060) | Case difference |
| `last_day_order_%3F` | `last_day_order` (2060) | URL-encoded slug vs parameter name in SQL |

> **Question for Oracle:** How does Metabase resolve these aliases at the dashboard level? Are all parameter mappings explicitly configured on the dashboard, or do some cards fail to respond to these filters because of name mismatches?

---

### 1.7 Missing Filter Integration

| Card | Missing Filters | Notes |
|---|---|---|
| 2013, 2029, 2031, 2033, 2050, 2262, 2030 | ALL dashboard filters | These 7 cards are hard-wired to current month. They cannot respond to `start_date`/`end_date`, `merchant_id`, `onboard_type`, `team_name`, or any other filter. |
| 2400 | `team_name` | Historical Merchant Overview lacks team_name filtering, unlike its current-month counterpart (2060). |
| 2158 | `merchant_id`, `onboard_type`, `team_name`, `phone` | Only supports `current_month`, `start_date`, `end_date`. |

---

### 1.8 Date Boundary Inconsistencies

| Card | Date Method | Boundary |
|---|---|---|
| Most cards | `DATE_TRUNC(CURRENT_DATE(), MONTH)` | Uses DATE functions |
| 2060, 2114 | `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), MONTH)` and `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)` | Uses TIMESTAMP functions |

> **Risk:** `CURRENT_DATE()` vs `CURRENT_TIMESTAMP()` may resolve at different times during query execution, potentially causing off-by-one issues at day boundaries. `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)` truncates to midnight UTC, which may not match the business day boundary.

---

### 1.9 "Today Exclusion" Inconsistency

| Cards | Today Included? | Boundary |
|---|---|---|
| 2013 | ✅ Yes | `created_at <= CURRENT_DATE()` |
| 2029 | ✅ Yes (orders) | `sorted_at <= CURRENT_DATE()` |
| 2158 | ✅ Yes (orders) | `sorted_at <= CURRENT_DATE()` |
| 2031 | ❌ No | `sorted_at < DATE_ADD(DATE_TRUNC(...), INTERVAL 1 MONTH)` (full month, but orders filtered to `>= "2026-01-01"`) |
| 2260 | ❌ No | `sorted_at < CURRENT_DATE()` |
| 2262 | ❌ No | `sorted_at < CURRENT_DATE()` |
| 2050 | ❌ No | `sorted_at < CURRENT_DATE()` |
| 2060 | ❌ No | `sorted_at < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)` |
| 2114 | ❌ No | `sorted_at < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)` |

> **Impact:** Cards 2013, 2029, and 2158 include today's partial data in their aggregate, while all other current-month cards exclude today. Comparing "Total Leads" (2013, includes today) against "Total Processed" (2028 via 2060, excludes today) mixes different time windows.

---

### 1.10 Revenue Calculation Inconsistency

| Card | Division Method | Notes |
|---|---|---|
| 2029, 2031, 2158, 2260, 2060, 2400 | `SUM(...) / 100` | Plain division by 100 |
| 2114, 2402 | `SAFE_DIVIDE(SUM(...), 100)` | SAFE_DIVIDE returns NULL on division by zero |
| 2050 | `final_fee / 100.0` | Uses pre-computed `final_fee` column instead of individual fee columns |

> **Risk:** `SAFE_DIVIDE` vs plain division: if any intermediate fee is NULL (not COALESCE'd), plain division may produce NULL while SAFE_DIVIDE handles it gracefully. However, all cards COALESCE fees to 0 before division, so the practical difference is minimal. The bigger concern is card 2050 using `final_fee` — if `final_fee` is computed differently from `(delivery + additional - discount - promo + cod) / 100`, the forecast revenue will diverge from all other cards.

---

### 1.11 Funnel Skew — Card 2033

Card 2033 (First Trip Conversion) has asymmetric filters between its two CTEs:

- **`total` CTE:** Only requires `onboard_type = 'Organic'` and `created_at >= month start`
- **`first_trip` CTE:** Additionally requires `business_team_user_id IS NOT NULL`

> **Impact:** A merchant with `business_team_user_id IS NULL` will appear in the "Total Onboarded" count but can NEVER appear in the "First Trip Merchants" count, permanently skewing the conversion funnel downward.

---

### 1.12 Card 2402 Forecast Identity

Card 2402 computes `days_in_period` and `total_days_in_period` as identical values:
```sql
DATE_DIFF(DATE({{end_date}}), DATE({{start_date}}), DAY) + 1 AS days_in_period,
DATE_DIFF(DATE({{end_date}}), DATE({{start_date}}), DAY) + 1 AS total_days_in_period
```

> **Impact:** The forecast formula `SAFE_MULTIPLY(SAFE_DIVIDE(sum, days_in_period), total_days_in_period)` simplifies to `sum` — the forecast IS the actual total, making the "Forecasted_Order" and "Forecasted_Revenue" columns redundant (identical to Processed/Expected_Revenue). This differs from card 2114 which projects to full-month days.

---

## 2. Unresolved Business Logic Questions

### 2.1 Status Classification

**Question:** The dashboard uses `COALESCE(account_status, onboard_type)` in card 2031 to classify merchants into status buckets (Info Pending, First Order Pending, Incubation, Churn, Hunt). What is the business rule that maps `account_status` + `onboard_type` → these five statuses? Is there a reference table or is this logic embedded in the visualization settings?

### 2.2 KAM Exclusion Rationale

**Question:** All merchant queries filter `kam_id IS NULL`. Why are KAM-assigned merchants excluded from the CRM dashboard? Does this mean that once a merchant is assigned to a KAM, they "graduate" from the CRM team's purview and their orders/revenue stop counting toward CRM metrics?

### 2.3 Organic Window Logic

**Question:** The window for Organic onboards is [15th of previous month, end of next month). For example, in June 2026, Organic leads from May 15 through July 31 are included. What is the business rationale for this ~2.5-month window? Why specifically the 15th? Is this tied to a payment cycle or order cycle?

### 2.4 "Post Corporate" Lifetime Inclusion

**Question:** Post Corporate onboards have NO date window — all Post Corporate leads ever created are included. Is this intentional? Does the Post Corporate pipeline never "close" a lead? What is the expected behavior for Post Corporate leads that were onboarded years ago and are dormant?

### 2.5 `business_team_user_id <> '1'` Exclusion

**Question:** What is user ID 1? Is it a system account, a test account, an admin account? Card 2271 (the admin checker) does NOT apply this filter, so user 1 records are visible there but excluded everywhere else. Should card 2271 also exclude user 1 for consistency?

### 2.6 `updated_at IS NOT NULL` as Data Freshness Gate

**Question:** Cards filter `public_orders` and `public_merchants` on `updated_at IS NOT NULL`. Does this mean records that have never been updated are excluded? What scenario creates a `NULL updated_at` — initial ingestion with partial data? How many records are silently dropped by this filter?

### 2.7 `country_id = 1` Scope

**Question:** All order queries filter `country_id = 1`. Is this Bangladesh? Are there plans to expand to other countries? If so, should this be parameterized?

### 2.8 Forecasting Methodology

**Question:** The forecast in cards 2050 and 2114 uses a simple linear projection (`MTD_total / days_passed * total_days_in_month`). Is this acceptable for business decisions? Does the business expect a more sophisticated model accounting for weekends, holidays, and month-end spikes? Card 2402's forecast is identity (see §1.12) — is this intentional?

---

## 3. Questions for Human Oracle

### Critical (Blocking)

1. **What is the authoritative list of "processed" transfer status IDs?** Does `{{snippet: processed_orders}}` contain the 22-status list, the 40-status list, or something else? This determines whether cards 2158, 2400, and 2402 are producing correct numbers.

2. **How are dashboard filter parameters mapped to card-level parameter names?** Specifically, does the dashboard map `crm_member_name` → `Acq_Member_Name` (4 cards) AND `Acq_Name` (1 card)? Does it map `merchant_id` → both `merchant_ID` and `merchant_id`? If not, several cards are silently ignoring user filter selections.

3. **Is the `is_deleted <> TRUE` NULL-handling bug acknowledged?** Are there known cases of `is_deleted IS NULL` in production? If so, how many records are affected and should the 7 affected cards be patched?

4. **Does card 2271's join bug (`btu.id` instead of `btu2.id`) affect downstream processes?** Is the "Assigner Name" column relied upon for any business process?

### Important (Should Resolve)

5. **Should card 2031's hardcoded `"2026-01-01"` be replaced?** As time passes, this becomes a progressively larger data gap.

6. **Should the 7 filter-less cards (2013, 2029, 2031, 2033, 2050, 2262, 2030) be retrofitted with filter support?** When a user selects `onboard_type = 'Organic'` on the dashboard, these cards still show ALL types — creating a confusing UX.

7. **What is the expected behavior for "today's data"?** Cards 2013 and 2029 include today, but card 2028 (Total Processed, via 2060) excludes today. This means "Total Leads" can change intraday while "Total Processed" is frozen at yesterday's value.

8. **Is card 2402's forecast identity intentional?** Should `total_days_in_period` be set to the total days in the FULL MONTH rather than the selected range, to match card 2114's behavior?

### Informational (Nice to Know)

9. **What are the actual values of `onboard_type` in production?** We see `Organic`, `Post Corporate`, and "others" (Hunt, Churn). Are there additional types that would fall into the `NOT IN ('Organic','Post Corporate')` bucket?

10. **Does `business_team_user_id` contain non-integer values?** Many cards use `SAFE_CAST(business_team_user_id AS INT64)`, suggesting it is stored as STRING in BigQuery despite being an integer. Are there valid cases where this cast returns NULL?

11. **Why does card 2029 UNION ALL merchants twice (by merchant_id and by phone) without deduplication?** A merchant that matches on both paths could appear twice. Is this handled by the `new_onboards` CTE joining logic that separates merchant_id-present from merchant_id-NULL records?

12. **Is there a data dictionary or ERD for the `hermes_bz_comms` schema?** The `crm_user_targets` and `business_team_targets` tables are used for target comparisons — what is the update cadence? Who maintains these targets?

---

## 4. Recommended Fix Priority

| Priority | Issue | Cards Affected | Effort |
|---|---|---|---|
| **P0** | Fix card 2271 join bug (`btu.id` → `btu2.id`) | 2271 | Low (1 line) |
| **P0** | Align `is_deleted` handling to `IS NOT TRUE` | 2013, 2029, 2031, 2033, 2158, 2030 | Low (6 lines) |
| **P1** | Replace hardcoded `"2026-01-01"` with `IS NOT NULL` | 2031 | Low (1 line) |
| **P1** | Add `is_deleted IS NOT TRUE` filter to card 2271 | 2271 | Low (1 line) |
| **P1** | Add `status <> 'Inactive'` filter (or make visible) to card 2271 | 2271 | Low (1 line) |
| **P1** | Add `business_team_user_id <> '1'` filter to card 2271 | 2271 | Low (1 line) |
| **P2** | Standardize hardcoded status lists to use snippet | 2158, 2400, 2402 | Medium (snippet verification required) |
| **P2** | Add filter support to Overview scalar cards | 2013, 2029, 2050, 2262 | Medium |
| **P2** | Fix card 2402 forecast to project to full month | 2402 | Low (1 line) |
| **P3** | Normalize date boundary method (DATE vs TIMESTAMP) | 2060, 2114 | Low |
| **P3** | Remove dead CTEs from card 2158 | 2158 | Low |

---

## 5. Dependency Graph (for fix planning)

```
Card 2028
  └── depends on Card 2060 (TOTAL row)
        └── any fix to Card 2060 flows through to Card 2028
```

No other card-to-card dependencies exist. Fixes can be applied independently per card.
