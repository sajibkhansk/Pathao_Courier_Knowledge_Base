# Dashboard 154: CRM Managers Dashboard — Business Logic Reference

> **Derived from:** 15 Metabase cards across 5 dashboard tabs  
> **Databases:** BigQuery (db 7) for 14 cards; PostgreSQL (db 5) for card 2271  
> **Generated:** 2026-06-19  
> **Status:** Complete analysis of all business rules, formulas, and dependencies

---

## 1. CRM Onboarding Window Logic

Every card that joins `new_onboards` applies a three-way filtering rule based on `onboard_type`. This rule determines which leads are considered "active" for the reporting period.

### 1.1 The Three-Way Rule

| Onboard Type | Window Rule | Rationale |
|---|---|---|
| **Post Corporate** | Always included — no date restriction | Corporate accounts have ongoing value irrespective of onboarding date |
| **Organic** | `created_at` must fall within the **KPI window**: [15th of *previous* month, start of *next* month) | Organic leads are only measured within a sliding 45-day-ish window anchored on the reporting month |
| **All Others** (Hunt, Churn, Incubation, etc.) | `first_order_date_after_lead_creation` must fall within the same KPI window | Non-Organic, non-Corporate leads are measured by when they placed their first order, not when they were onboarded |

### 1.2 KPI Window Boundaries

For current-month cards, the KPI window is:

```
Start: DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY)
End:   DATE_TRUNC(DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
```

**In plain English:** The 15th of last month through the end of next month.

**Example for June 2026:**
- Window start: 2026-05-15
- Window end: 2026-07-01 (exclusive)

### 1.3 Historical Card Adaptation

Cards **2400** and **2402** adapt the same logic using `{{start_date}}` and `{{end_date}}` parameters. The 15th-of-prior-month anchor is computed from `{{start_date}}` instead of `CURRENT_DATE()`.

### 1.4 Implementation Patterns

**Pattern A — Pre-filtered CTE** (Cards 2060, 2114, 2400, 2402):
```sql
filtered_new_onboards AS (
  SELECT * FROM new_onboards n
  WHERE
    n.onboard_type = 'Post Corporate'
    OR (
      n.onboard_type = 'Organic'
      AND DATE(n.created_at) >= <window_start>
      AND DATE(n.created_at) <  <window_end>
    )
    OR (n.onboard_type NOT IN ('Organic','Post Corporate'))
)
```
Non-Organic/non-Corporate types are kept in this CTE and filtered later via `first_order_date`.

**Pattern B — Inline filter** (Cards 2029, 2050, 2260, 2262):
The logic is applied directly in the `new_onboards` or `final` CTE WHERE clause.

**Pattern C — Organic-only** (Cards 2030, 2033):
These cards only track Organic leads. They use `created_at >= DATE_TRUNC(CURRENT_DATE(), MONTH)` — simpler than the full KPI window.

### 1.5 Cards That Do NOT Use Window Logic

- **2013** (Total Leads): Simple current-month `created_at` filter — no type differentiation.
- **2158** (Total Leads Rejected): Only counts `status = 'Inactive'` — no type windowing.
- **2271** (CRM Entry Checker): No date filters at all.

---

## 2. Revenue Formula

### 2.1 Standard Formula

Used by cards **2029, 2031, 2060, 2114, 2158, 2260, 2400, 2402**:

```
Expected_Revenue =
    ((COALESCE(delivery_fee, 0) + COALESCE(additional_charge, 0))
     -
     (COALESCE(discount, 0) + COALESCE(promo_discount, 0)))
    / 100
    +
    COALESCE(cash_on_delivery_fee, 0) / 100
```

**Key properties:**
- All monetary columns are in **subunits** (paisa equivalent); dividing by 100 converts to display currency (BDT).
- Only orders whose `transfer_status_id` is in the processed-orders list are included.
- `COALESCE(col, 0)` wraps all nullable fee columns, defaulting to 0 for NULLs.
- The formula is wrapped in a `SUM(IF(...))` — non-processed orders contribute 0.

### 2.2 Formula Variants

| Cards | Division Method | Notes |
|---|---|---|
| 2029, 2031, 2060, 2158, 2260 | `/100` | Plain division — `COALESCE` upstream ensures non-NULL operands |
| 2114, 2402 | `SAFE_DIVIDE(..., 100)` | Returns NULL if numerator is NULL; COALESCE still wraps operands so effective result is same |
| 2050 | `final_fee / 100.0` | Uses pre-computed `final_fee` column on `public_orders` instead of component columns |

### 2.3 SQL Implementation (Canonical)

```sql
SUM(
  IF(
    o.transfer_status_id IN ({{snippet: processed_orders}}),
    (COALESCE(o.delivery_fee, 0) + COALESCE(o.additional_charge, 0))
    - (COALESCE(o.discount, 0) + COALESCE(o.promo_discount, 0)),
    0
  )
) / 100
+
SUM(
  IF(
    o.transfer_status_id IN ({{snippet: processed_orders}}),
    COALESCE(o.cash_on_delivery_fee, 0),
    0
  )
) / 100
```

---

## 3. KPI Bonus Formula

The KPI Bonus is a commission/proxy metric computed per merchant and aggregated per CRM user. The rate depends on `onboard_type`.

| Onboard Type | Bonus Rate | Formula |
|---|---|---|
| **Post Corporate** | 0% | `0` |
| **Organic** | 0.5% | `0.005 * Expected_Revenue` |
| **All Others** (Hunt, Churn, Incubation, etc.) | 2% | `0.02 * Expected_Revenue` |

### 3.1 Implementation

```sql
CASE
  WHEN onboard_type = 'Post Corporate' THEN 0
  WHEN onboard_type = 'Organic'       THEN 0.005 * Expected_Revenue
  ELSE                                      0.02  * Expected_Revenue
END
```

Cards 2114 and 2402 use `SAFE_MULTIPLY(rate, revenue)` for safety.

### 3.2 Cards That Compute KPI Bonus

Cards **2060, 2114, 2260, 2400, 2402** compute and display KPI Bonus. Cards **2029, 2031, 2050, 2158, 2262** compute revenue but not the bonus.

---

## 4. Processed Orders Definition

### 4.1 The `{{snippet: processed_orders}}` Reference

Seven cards use the Metabase snippet:
> **2029, 2031, 2050, 2060, 2114, 2260, 2262**

This snippet is a server-side managed comma-separated list of `transfer_status_id` integers. The exact list is maintained as a Metabase snippet and expands at query time. It represents all "successfully completed" order statuses.

### 4.2 Hardcoded Status Lists

| Card(s) | Count | Status IDs | Context |
|---|---|---|---|
| **2158** | 22 | `8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42` | Current-month rejected leads (status values above 8) |
| **2400, 2402** | 40 | `5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44` | Historical — includes early statuses (5–7) and later ones (43–44) |

### 4.3 Risk: Snippet vs Hardcoded Divergence

If the `processed_orders` snippet is updated on the Metabase server (e.g., to add status 45 or remove deprecated statuses), cards 2158, 2400, and 2402 will **not** reflect the change. This creates a silent divergence between current-month and historical card outputs.

---

## 5. Merchant Attribution (Merchant Matching)

All cards that join `new_onboards` to `public_merchants` use a **two-path attribution**:

### 5.1 Primary Path: `merchant_id`
```sql
ON m.id = nob.merchant_id
WHERE nob.merchant_id IS NOT NULL
```
When the lead record has a `merchant_id`, it is the authoritative link.

### 5.2 Fallback Path: `phone`
```sql
ON m.phone = nob.phone
WHERE nob.merchant_id IS NULL
```
When `merchant_id` is NULL on the lead record, the system falls back to matching by phone number.

### 5.3 Implementation Variations

| Pattern | Cards | SQL Approach |
|---|---|---|
| **UNION ALL** | 2029, 2050 | Two separate CTEs (`merchants_by_merchant_id`, `merchants_by_phone`) with UNION ALL |
| **OR join** | 2031, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Single LEFT/INNER JOIN with OR condition: `(nob.merchant_id IS NOT NULL AND m.id = nob.merchant_id) OR (nob.merchant_id IS NULL AND m.phone = nob.phone)` |

The UNION ALL approach avoids potential BigQuery performance issues with OR-joins (enabling hash joins). The OR approach is more concise but may force a slower join strategy.

---

## 6. KAM Exclusion

### Rule

All merchant queries exclude merchants assigned to a Key Account Manager:

```sql
WHERE m.kam_id IS NULL
```

This is applied universally across all cards that join `public_merchants`. The rationale: KAM-managed merchants are handled by a separate team and should not appear in CRM acquisition metrics.

### Application

| Cards | Where Applied |
|---|---|
| 2029, 2031, 2050, 2060, 2114, 2260, 2262, 2400, 2402 | In the merchants CTE or join condition |
| 2158 | Applied in the merchants CTE |
| 2013, 2030, 2033, 2271 | Not applicable (no merchant join or different database) |

---

## 7. Lead Eligibility Rules

### 7.1 The Three Core Filters

All cards that query `new_onboards` for active analysis apply three eligibility filters:

| Filter | Expression | Meaning |
|---|---|---|
| Exclude system user | `business_team_user_id <> '1'` | User ID 1 is a system/placeholder account |
| Exclude deleted | `is_deleted` (varies — see below) | Soft-deleted leads should not be counted |
| Exclude rejected | `status <> 'Inactive'` | Inactive status means rejected/abandoned |

### 7.2 Cards With Different Rules

| Card | Filters | Notes |
|---|---|---|
| **2158** (Rejected Leads) | `status = 'Inactive'` | Intentionally counts ONLY rejected leads |
| **2271** (Admin Checker) | None | Returns all records including deleted, inactive, system user |
| **2013** (Total Leads) | `business_team_user_id <> '1'`, `is_deleted <> TRUE` | Does **not** exclude `Inactive` — counts rejected leads too |

### 7.3 `is_deleted` Handling: The NULL Problem

This is a **critical inconsistency** across the dashboard (see §12.1 for full analysis).

---

## 8. Date Window Variations

### 8.1 Summary of All Date Windows

| Window Type | Cards | Definition | Notes |
|---|---|---|---|
| **Current Month (start → today)** | 2013 | `DATE_TRUNC(CURRENT_DATE(), MONTH)` ≤ `created_at` ≤ `CURRENT_DATE()` | Inclusive of today |
| **Current Month (start → yesterday)** | 2050, 2060, 2114, 2260, 2262 | `sorted_at >= month_start` AND `sorted_at < CURRENT_DATE()` | Excludes today (day not yet complete) |
| **KPI Window (Organic)** | 2029, 2031, 2050, 2060, 2114, 2260, 2262, 2400, 2402 | `created_at >= 15th_of_prior_month` AND `created_at < start_of_next_month` | See §1 for full definition |
| **Hardcoded fixed date** | 2031 | `updated_at >= '2026-01-01'` | ⚠️ **Hardcoded** — will silently drop pre-2026 orders over time (see §12.2) |
| **Parameter-driven** | 2158, 2400, 2402 | `{{start_date}}` / `{{end_date}}` | User-selected historical range |
| **None** | 2271 | No date filter | Full table scan |

### 8.2 Card 2029: Dual Date Scope

Card 2029 (Total Expected Revenue) applies **two** date scopes on orders:
1. `sorted_at >= month_start` **AND** `sorted_at <= CURRENT_DATE()`
2. `created_at >= 15th_of_last_month` **OR** condition (broader fetch for first-order detection)

This dual scope means the `orders` CTE in 2029 fetches a superset of orders (going back to the 15th of last month) but the monthly revenue aggregation is scoped to current month only.

### 8.3 Date Function Inconsistency (Card 2060)

Card 2060 uses `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), MONTH)` while all other cards use `DATE_TRUNC(CURRENT_DATE(), MONTH)`. This can cause **off-by-one-day** misalignment around UTC midnight boundaries.

---

## 9. Target Logic

### 9.1 Target Tables

| Table | Used By | Grain |
|---|---|---|
| `hermes_bz_comms.crm_user_targets` | Cards **2114, 2402** | Per CRM user, per month, with `order_target` and `revenue_target` columns |
| `hermes_bz_comms.business_team_targets` | Card **2050** | Per team (`team_name = 'ACQ'`), per month |

### 9.2 CRM User Targets (Leaderboard Cards)

Cards 2114 and 2402 join `crm_user_targets` on:
```sql
LEFT JOIN hermes_bz_comms.crm_user_targets t
  ON t.crm_id = crm_id
  AND t.month = DATE_TRUNC(CURRENT_DATE(), MONTH)  -- or parameter-driven for 2402
```

Target columns used:
- **`order_target`** — monthly order count target per CRM user
- **`revenue_target`** — monthly revenue target per CRM user

Goal attainment is computed as:
- **Order_Goal:** `SAFE_DIVIDE(Processed, order_target)` → shown as percentage
- **Revenue_Goal:** `SAFE_DIVIDE(Expected_Revenue, revenue_target)` → shown as percentage
- **order_remaining:** `CONCAT('🔴 - ', target - processed)` or `CONCAT('🟢 +', processed - target)`

### 9.3 Team Targets (Forecast Card)

Card 2050 uses `business_team_targets` for a single row:
```sql
WHERE team_name = 'ACQ'
  AND start_of_month = DATE_TRUNC(CURRENT_DATE(), MONTH)
```
Uses the `target` column (order count target for the Acquisition team) as denominator for run-rate.

---

## 10. Forecast Logic

### 10.1 Simple Linear Projection

Both cards 2050 (Forecast Orders) and 2114/2402 (Leaderboard) use the same pattern:

```
daily_average = MTD_total / days_passed
forecast      = daily_average * total_days_in_month
```

### 10.2 Card 2050 Implementation

```sql
-- days_passed: number of days from month start to yesterday
DATE_DIFF(CURRENT_DATE(), DATE_TRUNC(CURRENT_DATE(), MONTH), DAY)

-- total_days: total days in current month
EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE()))

-- daily_average
SAFE_DIVIDE(total_processed, days_passed)

-- forecast
SAFE_MULTIPLY(daily_average, total_days)
```

The card also computes:
- **Run Rate:** `SAFE_DIVIDE(forecast, target_from_team_targets)` → percentage of team target

### 10.3 Leaderboard Implementation (Cards 2114, 2402)

Uses `days_in_month` or `days_in_range` CTE:
```sql
CROSS JOIN (
  SELECT
    DATE_DIFF(LAST_DAY(CURRENT_DATE()), DATE_TRUNC(CURRENT_DATE(), MONTH), DAY) + 1 AS total_days_in_month,
    DATE_DIFF(CURRENT_DATE(), DATE_TRUNC(CURRENT_DATE(), MONTH), DAY) AS days_passed
) AS days_in_month
```

Forecasted_Order and Forecasted_Revenue are computed per CRM user.

### 10.4 Historical Card Quirk (2402)

Card 2402 uses `days_in_period` (the actual difference between `{{start_date}}` and `{{end_date}}`) for BOTH the denominator and the multiplier:
```sql
days_in_period = DATE_DIFF({{end_date}}, {{start_date}}, DAY) + 1
forecast = SAFE_MULTIPLY(SAFE_DIVIDE(sum, days_in_period), days_in_period)
```
This means the "forecast" equals the actual sum — the forecast is a no-op for historical date ranges. This differs from card 2114 which always projects to full-month.

### 10.5 Known Limitations

- **Linear assumption:** Does not account for month-end ramp, weekends, or seasonality.
- **Early-month instability:** In the first few days, `days_passed` is small, making the forecast highly volatile.
- **Excludes today:** Today's orders are excluded from MTD (day not complete), but `days_passed` also excludes today — consistent but may slightly under-project.

---

## 11. CRM Team Hierarchy

### 11.1 Join Chain

The team hierarchy is resolved through a three-step join chain:

```
new_onboards.business_team_user_id
    → CAST to INT64
    → business_team_users.id
    → business_team_users.team_id
    → business_team.id
    → business_team.team_name
```

### 11.2 Implementation

```sql
LEFT JOIN courier_appsmith.business_team_users btu
  ON btu.id = SAFE_CAST(nob.business_team_user_id AS INT64)
LEFT JOIN courier_appsmith.business_team bt
  ON bt.id = btu.team_id
```

### 11.3 Team Name Values

| team_name | Display Name | Description |
|---|---|---|
| `KAM` | KAM | Key Account Management |
| `Acquisition` | Acquisition | CRM acquisition team |
| `Pre Corporate` | Corporate | Pre/Post Corporate accounts |

### 11.4 Cards That Resolve Team Hierarchy

Cards **2060, 2114, 2260, 2402** resolve and display `team_name`. Cards **2260** additionally rolls up by team. Card **2400** joins `business_team_users` but does NOT join `business_team` — `team_name` is not available in the Historical Merchant Overview.

### 11.5 Card 2271 Join Bug

Card 2271 (Postgres, db 5) has a join bug on the assigner name:
```sql
-- First join (correct):
LEFT JOIN business_team_users btu ON btu.id = CAST(business_team_user_id AS INT)

-- Second join (INCORRECT):
LEFT JOIN business_team_users btu2 ON btu.id = CAST(assigner_user_id AS INT)
--                                    ^^^^^^ should be btu2.id
```
The second join matches on `btu.id` instead of `btu2.id`, so `user_name_2` (assigner name) will only show correctly when `business_team_user_id = assigner_user_id`.

---

## 12. Conflicting Logic Across Cards

### 12.1 NULL Handling Divergence (`is_deleted`)

| Approach | Cards | Behavior |
|---|---|---|
| `is_deleted <> TRUE` / `is_deleted <> true` | 2013, 2029, 2031, 2033, 2158, 2030 | **MISSES NULLS** — rows where `is_deleted IS NULL` are NOT excluded |
| `is_deleted IS NOT TRUE` | 2050, 2260, 2262, 2060, 2114, 2400, 2402 | **Correct** — excludes both TRUE and NULL |
| No check | 2271 | All records returned |

**Impact:** 7 out of 15 cards (47%) have the incorrect `<> TRUE` pattern. If any `new_onboards` records have `is_deleted IS NULL`, these cards will silently include them while the other 6 cards will exclude them — producing inconsistent counts.

### 12.2 Hardcoded Date `'2026-01-01'` in Card 2031

Card 2031 (Merchant Distribution) applies a hardcoded filter on the orders CTE:
```sql
WHERE updated_at >= '2026-01-01'
```

**Impact:**
- Orders before 2026 are silently excluded.
- This affects `first_order_date_after_lead_creation` detection for older merchants.
- Over time, this becomes increasingly problematic as the "lookback window" 2026-01-01 never advances.
- No other card has this hardcoded date.

### 12.3 Different `transfer_status` Approaches

| Approach | Cards | Risk |
|---|---|---|
| `{{snippet: processed_orders}}` | 2029, 2031, 2050, 2060, 2114, 2260, 2262 | Centralized — single source of truth |
| Hardcoded 22-value list | 2158 | Diverges from snippet if updated |
| Hardcoded 40-value list | 2400, 2402 | Includes early statuses (5–7) and later ones (43–44) not in snippet |

### 12.4 Revenue Formula Variance: `/100` vs `SAFE_DIVIDE`

Cards 2114 and 2402 use `SAFE_DIVIDE(..., 100)` while others use plain `/100`. While the effective output is the same (operands are COALESCE'd to 0), the intent differs:
- `SAFE_DIVIDE` returns NULL if any input is NULL
- `/100` returns 0 when COALESCE sets operands to 0

### 12.5 Parameter Name Inconsistency

Dashboard filter parameters have inconsistent naming across cards:
- `merchant_ID` vs `merchant_id`
- `Acq_Member_Name` vs `Acq_Name`
- `Team_name` vs `team_name`

This means not all parameter widgets filter all cards — a dashboard user may select a team filter that silently doesn't apply to some visualizations.

### 12.6 Card 2158: Unused Dead Computation

Card 2158 builds complex order/merchant CTEs with revenue calculations and then:
```sql
SELECT COUNT(n.id) AS total_leads_rejected FROM new_onboards n ...
```
None of the revenue CTEs feed into the final output. This is dead computation that increases query cost with no benefit.

### 12.7 Card 2029: No Dashboard Parameter Integration

Despite being on the Overview tab, card 2029 has no `[[AND ...]]` template markers — it ignores all dashboard filters.

---

## 13. Card Dependencies

### 13.1 Direct Dependency

```
Card 2028 (Total Processed)
  └── References Card 2060 (Sales Overview [Merchants Specific])
       └── Picks the 'TOTAL' row: WHERE MERCHANT_ID = 'TOTAL'
```

Card 2028 is the **only pass-through card** in the dashboard. It does not query tables directly; it reads from Metabase card #2060 and selects the pre-computed total aggregation row.

**Implication:** If card 2060 fails, returns no data, or returns incorrect data, card 2028 silently fails. Any filters applied to the dashboard that affect card 2060 automatically propagate to card 2028.

### 13.2 No Other Dependencies

All other 14 cards are independent queries. There is no shared CTE or materialized intermediate between cards (beyond what Metabase handles internally for the snippet).

### 13.3 Implicit Dependencies

While not Metabase-level dependencies, these cards share business logic that should be changed in concert:

| Domain | Cards That Must Be Updated Together |
|---|---|
| Onboard type window logic | 2029, 2031, 2050, 2060, 2114, 2260, 2262, 2400, 2402 |
| Revenue formula | 2029, 2031, 2050, 2060, 2114, 2158, 2260, 2400, 2402 |
| KPI Bonus formula | 2060, 2114, 2260, 2400, 2402 |
| `is_deleted` handling | All 15 cards (for consistency) |
| Processed orders list | 2029, 2031, 2050, 2060, 2114, 2158, 2260, 2262, 2400, 2402 |

---

## Appendix A: Card Quick Reference

| Card ID | Name | Tab | Display | Key Business Logic |
|---|---|---|---|---|
| 2013 | Total Leads | Overview | Scalar | Count `new_onboards` this month |
| 2028 | Total Processed | Overview | Scalar | Reads TOTAL from card 2060 |
| 2029 | Total Expected Revenue | Overview | Scalar | Revenue sum with KPI window logic |
| 2031 | Merchant Distribution | Overview | Pie | Status buckets with ⚠️ hardcoded 2026 date |
| 2033 | First Trip Conversion (Organic) | Overview | Funnel | Organic onboarded → first-trip conversion |
| 2050 | Forecast Orders | Overview | Table | MTD run-rate → month-end forecast |
| 2158 | Total Leads Rejected | Overview | Scalar | Count of `status = 'Inactive'` |
| 2260 | Team Wise Distribution [Orders] | Overview | Pie | Orders by team (KAM/Acquisition/Corporate) |
| 2262 | Order Trend CRM | Overview | Area | Daily processed orders trend |
| 2030 | Performance Tracker | Performance Tracker | Table | Organic lead assignments + outreach |
| 2060 | Sales Overview [Merchants Specific] | Performance Tracker | Table | Per-merchant sales with KPI bonus |
| 2114 | Leaderboard | Leaderboard | Table | Ranked CRM members with targets |
| 2271 | CRM Merchant Entry Checker | CRM Entry Checker | Object | Raw lead lookup (Postgres, db 5) |
| 2400 | Historical Merchant Overview | Historical | Table | Parameter-driven historical sales |
| 2402 | Historical Leaderboard | Historical | Table | Parameter-driven historical leaderboard |

## Appendix B: Source Table Reference

| Table | Fully Qualified | Database | Primary Keys / Join Columns |
|---|---|---|---|
| `public_orders` | `courier_realtime_datastream.public_orders` | BigQuery | `id`, `merchant_id`, `transfer_status_id` |
| `public_archived_orders` | `courier_realtime_datastream.public_archived_orders` | BigQuery | Same schema as `public_orders` |
| `public_merchants` | `courier_realtime_datastream.public_merchants` | BigQuery | `id`, `phone`, `kam_id` |
| `new_onboards` | `courier_appsmith.new_onboards` | BigQuery | `id`, `merchant_id`, `phone`, `business_team_user_id` |
| `business_team_users` | `courier_appsmith.business_team_users` | BigQuery | `id`, `team_id`, `user_name` |
| `business_team` | `courier_appsmith.business_team` | BigQuery | `id`, `team_name` |
| `crm_user_targets` | `hermes_bz_comms.crm_user_targets` | BigQuery | `crm_id`, `month`, `order_target`, `revenue_target` |
| `business_team_targets` | `hermes_bz_comms.business_team_targets` | BigQuery | `team_name`, `start_of_month`, `target` |
| `new_onboards` (PG) | `new_onboards` | PostgreSQL (db 5) | `id`, `merchant_id`, `phone`, `business_team_user_id` |
| `business_team_users` (PG) | `business_team_users` | PostgreSQL (db 5) | `id`, `team_id`, `user_name` |

---

*End of business logic reference. This document captures all rules, formulas, and behavioral variations extracted from the 15 production SQL queries and the dashboard inventory analysis.*
