# Dashboard 154: CRM Managers Dashboard — Full Inventory

> **Dashboard URL:** https://courierbi.pathaointernal.com/dashboard/154-crm-managers-dashboard  
> **Collection:** Various (428, 50)  
> **Total Cards:** 15  
> **Tabs:** 5 (Overview, Performance Tracker, Leaderboard, CRM Entry Checker, Historical)  
> **Dashboard Filters:** 9  
> **Generated:** 2026-06-19

---

## Dashboard Filters

| # | Parameter Name | Type | Default | Description |
|---|---|---|---|---|
| 1 | `current_month` | string | `"Yes"` | Toggle to restrict to current calendar month |
| 2 | `merchant_id` | number | — | Filter by specific merchant ID |
| 3 | `crm_member_name` / `Acq_Member_Name` / `Acq_Name` | string | — | Filter by CRM acquisition member name (parameter name varies by card) |
| 4 | `onboard_type` | string | — | Filter by merchant onboard type (Organic, Post Corporate, etc.) |
| 5 | `team_name` / `Team_name` | string | — | Filter by team (KAM, Acquisition, Corporate) |
| 6 | `phone` | string | — | Filter by merchant phone number |
| 7 | `start_date` | date/single | — | Start date for historical range queries |
| 8 | `end_date` | date/single | — | End date for historical range queries |
| 9 | `last_day_order_%3F` / `last_day_order` | string | `"Last Day order ?"` | Filter by last-day order status (`'0 Orders'` or `'Has Orders'`) |

> **Note:** Parameter name inconsistency across cards. `merchant_ID` vs `merchant_id`, `Acq_Member_Name` vs `Acq_Name`, `Team_name` vs `team_name`. The `[[AND ...]]` template syntax wraps optional WHERE clauses that are stripped by Metabase when the filter value is empty/null.

---

## Shared SQL Patterns

### The `{{snippet: processed_orders}}` Reference
Cards **2029, 2031, 2050, 2060, 2114, 2260, 2262** reference a Metabase snippet called `processed_orders`. This snippet expands to a comma-separated list of `transfer_status_id` values representing "processed" (completed/delivered) order statuses. The exact list is managed server-side as a Metabase snippet.

**Cards that hardcode the status list instead of using the snippet:**
- **2158:** `(8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42)` — 22 statuses
- **2400, 2402:** `(5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44)` — 40 statuses

The historical cards (2400, 2402) include a broader set of statuses (including early statuses 5–7 and later ones 43–44) compared to the current-month cards.

### Revenue Formula
Used by cards **2029, 2031, 2060, 2114, 2158, 2260, 2400, 2402:**

```
((delivery_fee + additional_charge) - (discount + promo_discount)) / 100
  +
cash_on_delivery_fee / 100
```

All monetary fields are in subunit (paisa/cent equivalent), divided by 100 for display currency. `COALESCE(col, 0)` wraps all nullable fee columns. Only orders with processed transfer_status_id are included in the sum. Cards 2114 and 2402 additionally wrap each division in `SAFE_DIVIDE()`.

Card **2050** uses a simpler variant via the `final_fee` column on `public_orders`:
```sql
CASE WHEN transfer_status_id IN (processed) THEN final_fee / 100.0 ELSE 0 END
```

### KPI Bonus Formula
Used by cards **2060, 2114, 2260, 2400, 2402:**

| Onboard Type | Bonus Rate |
|---|---|
| Post Corporate | 0 (excluded) |
| Organic | 0.5% of Expected Revenue (`0.005 * revenue`) |
| All others (Hunt, Churn, etc.) | 2% of Expected Revenue (`0.02 * revenue`) |

### Onboard Type Window Logic
Most cards apply a three-way filtering rule on `new_onboards`:

1. **Post Corporate:** Lifetime inclusion — no date window applied.
2. **Organic:** Filter by `created_at` in window: [15th of *previous* month, end of *next* month).  
   For current-month cards: `>= DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 15 DAY)` to `< DATE_TRUNC(DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)`.
   For historical cards: same logic but anchored on `{{start_date}}` and `{{end_date}}`.
3. **Others (Hunt, Churn, etc.):** Filter by `first_order_date_after_lead_creation` in same window.

### Merchant Matching (Phone Fallback)
All cards that join `new_onboards` to `public_merchants` use a two-path approach:
1. **Primary:** Match on `merchant_id` (when `new_onboards.merchant_id IS NOT NULL`)
2. **Fallback:** Match on `phone` (when `new_onboards.merchant_id IS NULL`)

Cards **2029, 2050** implement this as two separate CTE branches (`merchants_by_merchant_id` UNION ALL `merchants_by_phone`). Others use a single LEFT JOIN with OR condition.

### KAM Exclusion
All merchant queries include `m.kam_id IS NULL` — only merchants without an assigned Key Account Manager.

---

## Core Source Tables

| Table | Fully Qualified | Usage |
|---|---|---|
| `public_orders` | `courier_realtime_datastream.public_orders` | Live orders |
| `public_archived_orders` | `courier_realtime_datastream.public_archived_orders` | Historical archived orders |
| `public_merchants` | `courier_realtime_datastream.public_merchants` | Merchant master data |
| `new_onboards` | `courier_appsmith.new_onboards` | CRM lead/onboarding records (BigQuery) |
| `business_team_users` | `courier_appsmith.business_team_users` | CRM team member info (name, team) |
| `business_team` | `courier_appsmith.business_team` | Team definitions (KAM, Acquisition, etc.) |
| `business_team_targets` | `hermes_bz_comms.business_team_targets` | Monthly team order/revenue targets |
| `crm_user_targets` | `hermes_bz_comms.crm_user_targets` | Per-CRM-user targets |
| `new_onboards` | `new_onboards` (Postgres, db 5) | CRM lead records (card 2271 only) |
| `business_team_users` | `business_team_users` (Postgres, db 5) | User info (card 2271 only) |

---

## Tab 1: Overview

### Card 2013 — Total Leads

| Property | Value |
|---|---|
| **Display** | Scalar |
| **Database** | 7 (BigQuery) |
| **Business Question** | How many new leads/onboards were created this month? |
| **Output Grain** | Single scalar value |
| **Source Tables** | `courier_appsmith.new_onboards` |
| **Key Fields** | `business_team_user_id`, `is_deleted`, `created_at` |
| **Join Paths** | None (single table) |
| **Filter / WHERE** | `business_team_user_id <> '1'` (exclude system user), `is_deleted <> TRUE`, `created_at` in current month (month start → today) |
| **Dashboard Parameters** | None |
| **Date Window** | `DATE_TRUNC(CURRENT_DATE(), MONTH)` ≤ `created_at` ≤ `CURRENT_DATE()` |
| **Aggregation** | `COUNT(*)` |
| **Metric Formulas** | None — simple count |
| **Inclusion/Exclusion** | INCLUDE: `business_team_user_id <> '1'`, `is_deleted <> TRUE`. EXCLUDE: None beyond WHERE. |
| **Snippet References** | None |
| **Known Limitations** | No dashboard filter integration. Does not exclude `status = 'Inactive'` (rejected leads), so it counts all onboard records in the month regardless of status. This differs from cards like 2033, 2031 that exclude `Inactive`. |

---

### Card 2028 — Total Processed

| Property | Value |
|---|---|
| **Display** | Scalar |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the total number of processed orders across all CRM merchants this month? |
| **Output Grain** | Single scalar value |
| **Source Tables** | References Metabase card **#2060** (`{{#2060-sales-overview-merchants-specific}}`) |
| **Key Fields** | `Processed`, `MERCHANT_ID` |
| **Join Paths** | N/A (sub-query from card #2060) |
| **Filter / WHERE** | `MERCHANT_ID = 'TOTAL'` — picks the total aggregation row from card 2060 |
| **Dashboard Parameters** | Inherits all parameters applied to card #2060 |
| **Date Window** | Inherited from card #2060 (current month) |
| **Aggregation** | Direct column selection |
| **Metric Formulas** | None applied here; value comes pre-computed from card #2060 |
| **Inclusion/Exclusion** | Inherited from card #2060 |
| **Snippet References** | Indirectly via card #2060 |
| **Known Limitations** | This is a pass-through card that depends entirely on card #2060 being correct and populated. If card #2060 returns no data or no TOTAL row, this card shows nothing. |

---

### Card 2029 — Total Expected Revenue

| Property | Value |
|---|---|
| **Display** | Scalar |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the total expected revenue from all CRM-sourced merchants this month? |
| **Output Grain** | Single scalar value |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants` |
| **Key Fields** | `merchant_id`, `phone`, `created_at`, `onboard_type`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee`, `transfer_status_id`, `sorted_at`, `kam_id` |
| **Join Paths** | `new_onboards` → `public_merchants` (merchant_id + phone fallback) → `public_orders` (LEFT JOIN, first order detection) → `public_orders` (LEFT JOIN, monthly aggregation). Uses UNION ALL for merchant_id/phone join paths. Final output joins `new_onboards` back to the merchant-level results via `final` CTE. |
| **Filter / WHERE** | `orders.updated_at IS NOT NULL`, `orders.country_id = 1`. Orders scoped to: `sorted_at >= month start` OR `created_at >= 15th of last month`. `new_onboards`: `business_team_user_id <> '1'`, `is_deleted <> TRUE`, `status <> 'Inactive'`. Merchants: `kam_id IS NULL`. Final filter applies onboard type window logic. |
| **Dashboard Parameters** | None — no `[[AND ...]]` markers in SQL |
| **Date Window** | Orders: `sorted_at >= DATE_TRUNC(CURRENT_DATE(), MONTH)` AND `sorted_at <= CURRENT_DATE()`. Lead creation window for Organic: 15th of last month to end of next month. |
| **Aggregation** | `SUM(expected_rvn_all)` at outermost query |
| **Metric Formulas** | **Revenue:** `((COALESCE(delivery_fee,0)+COALESCE(additional_charge,0)) - (COALESCE(discount,0)+COALESCE(promo_discount,0))) / 100 + COALESCE(cash_on_delivery_fee,0) / 100`. Only for orders where `transfer_status_id IN ({{snippet: processed_orders}})`. |
| **Inclusion/Exclusion** | EXCLUDE: `status = 'Inactive'`, `kam_id IS NOT NULL`, `business_team_user_id = '1'`. INCLUDE: Post Corporate (lifetime), Organic (windowed), Others (by first_order_date). |
| **Snippet References** | `{{snippet: processed_orders}}` (×3) |
| **Known Limitations** | Uses two different date scopes for orders (sorted_at and created_at), which may lead to double-counting edge cases. The `first_order_date_after_lead_creation` for non-Organic types is computed from the same orders table which is date-filtered. |

---

### Card 2033 — First Trip Conversion (Organic)

| Property | Value |
|---|---|
| **Display** | Funnel |
| **Database** | 7 (BigQuery) |
| **Business Question** | What percentage of organically onboarded merchants placed their first order this month? |
| **Output Grain** | Two rows: `Total Onboarded` and `First Trip Merchants` |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards` |
| **Key Fields** | `merchant_id`, `created_at`, `sorted_at`, `onboard_type`, `business_team_user_id`, `status`, `is_deleted` |
| **Join Paths** | `new_onboards` → `orders` (EXISTS subquery on `merchant_id` for first trip detection) |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `status <> 'Inactive'`, `is_deleted <> TRUE`, `onboard_type = 'Organic'`. Orders: `updated_at IS NOT NULL`, `country_id = 1`. |
| **Dashboard Parameters** | None |
| **Date Window** | Current month: `created_at >= DATE_TRUNC(CURRENT_DATE(), MONTH)` and `sorted_at >= DATE_TRUNC(CURRENT_DATE(), MONTH)` |
| **Aggregation** | `COUNT(*)` for total; `COUNT(DISTINCT merchant_id)` with EXISTS for first trip |
| **Metric Formulas** | Implicit conversion rate (First Trip / Total Onboarded) rendered by funnel viz |
| **Inclusion/Exclusion** | INCLUDE: `Organic` only, `business_team_user_id IS NOT NULL` (for first_trip CTE). EXCLUDE: `Inactive` status, deleted records, system user (id=1). |
| **Snippet References** | None |
| **Known Limitations** | Only covers Organic onboard type. The total count CTE does not require `business_team_user_id IS NOT NULL` but first_trip does, so a lead with NULL business_team_user_id can appear in the total but never convert — skewing the funnel. Orders UNION ALL of live + archived may produce duplicate order rows if archiving happens mid-month. |

---

### Card 2050 — Forecast Orders

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the projected monthly order volume and revenue based on MTD run rate? |
| **Output Grain** | Single row with forecast metrics |
| **Source Tables** | `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `hermes_bz_comms.business_team_targets` |
| **Key Fields** | `merchant_id`, `phone`, `created_at`, `onboard_type`, `transfer_status_id`, `final_fee`, `sorted_at` |
| **Join Paths** | `new_onboards` → `public_merchants` (merchant_id + phone UNION ALL paths) → `public_orders` (first_order via orders_all CTE, monthly metrics via orders_this_month CTE). Target table joined via `team_name = 'ACQ'` and `start_of_month`. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS DISTINCT FROM TRUE`, `status <> 'Inactive'`. Organic: `created_at` >= 15th last month AND < end of next month. Non-Organic: kept and filtered later. Orders: `country_id = 1`, `updated_at IS NOT NULL`. Monthly orders: `sorted_at >= month start` AND `< today`. |
| **Dashboard Parameters** | None |
| **Date Window** | Current month to date (month_start → today - 1). Organic window: 15th last month → end of next month. |
| **Aggregation** | `COUNTIF` for processed count, `SUM(final_fee/100)` for revenue. `SAFE_DIVIDE` for daily averages, `SAFE_MULTIPLY` for forecasts. |
| **Metric Formulas** | **Revenue:** `final_fee / 100.0` (uses pre-computed `final_fee` column). **Daily Average:** `total_processed / days_passed`. **Forecast:** `daily_average * total_days_in_month`. **Run Rate:** `forecast / target` (from `business_team_targets`). |
| **Inclusion/Exclusion** | EXCLUDE: system user, deleted, Inactive. INCLUDE: all onboard types, windowed per rules. `is_deleted IS DISTINCT FROM TRUE` correctly handles NULLs. |
| **Snippet References** | `{{snippet: processed_orders}}` (×2) |
| **Known Limitations** | Forecast is linear projection from MTD average — does not account for month-end ramp effects, weekends, or holidays. The `final_fee` column usage differs from other cards that compute revenue from individual fee columns; consistency depends on `final_fee` being correctly maintained. Run rate denominator is the ACQ team target only. Uses `is_deleted IS DISTINCT FROM TRUE` while most other cards use `is_deleted <> TRUE` (which mishandles NULLs). |

---

### Card 2031 — Merchant Distribution

| Property | Value |
|---|---|
| **Display** | Pie |
| **Database** | 7 (BigQuery) |
| **Business Question** | How are merchants distributed across statuses (Info Pending, First Order Pending, Incubation, Churn, Hunt)? |
| **Output Grain** | One row per Status value |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants` |
| **Key Fields** | `merchant_id`, `phone`, `account_status`, `onboard_type`, `created_at`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee` |
| **Join Paths** | `new_onboards` → `public_merchants` (LEFT JOIN, OR condition) → `orders` (LEFT JOIN, first order) → `orders` (LEFT JOIN, monthly aggregation) |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted <> TRUE`, `status <> 'Inactive'`. Merchants: `updated_at IS NOT NULL`, `kam_id IS NULL`, `nob.created_at IS NOT NULL`. Window logic on onboard_type as described in Shared Patterns. Orders: `updated_at >= "2026-01-01"` (hardcoded date!). |
| **Dashboard Parameters** | None |
| **Date Window** | Orders: `sorted_at >= month start` AND `< next month start`. NOTE: orders CTE has hardcoded `updated_at >= "2026-01-01"` which is a fixed date — may exclude older archived orders. |
| **Aggregation** | `COUNT(*)` after `GROUP BY COALESCE(account_status, onboard_type)` |
| **Metric Formulas** | Revenue formula computed in CTE but not used in final output (only processed count is indirectly used). |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, `kam_id IS NOT NULL`, deleted. INCLUDE: All non-Inactive onboards windowed by type. |
| **Snippet References** | `{{snippet: processed_orders}}` (×3) |
| **Known Limitations** | The hardcoded `"2026-01-01"` filter on the orders CTE will silently drop orders before 2026, potentially undercounting for merchants with first orders in 2025 or earlier. The orders_month CTE computes revenue but it is not used in the final SELECT — only `Status` and `Merchant_Count` are output. Uses `<> TRUE` for is_deleted (misses NULLs). |

---

### Card 2158 — Total Leads Rejected

| Property | Value |
|---|---|
| **Display** | Scalar |
| **Database** | 7 (BigQuery) |
| **Business Question** | How many leads were rejected (status = Inactive) in the selected period? |
| **Output Grain** | Single scalar count |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users` |
| **Key Fields** | `id`, `merchant_id`, `phone`, `status`, `is_deleted`, `created_at`, `business_team_user_id` |
| **Join Paths** | `new_onboards` → `public_merchants` (LEFT JOIN, OR condition) → `orders_month` (LEFT JOIN on merchant_id). `business_team_users` joined on `business_team_user_id`. Though orders and merchants are computed, the final SELECT only counts `n.id`. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `status = 'Inactive'` (note: INACTIVE ONLY), `is_deleted <> TRUE`. Orders: `country_id = 1`, `updated_at IS NOT NULL`. |
| **Dashboard Parameters** | `{{current_month}}` (line 83), `{{start_date}}` (line 84), `{{end_date}}` (line 85) |
| **Date Window** | If `current_month = 'Yes'`: `created_at >= month start`. Otherwise: parameter-driven via `start_date`/`end_date`. |
| **Aggregation** | `COUNT(n.id)` |
| **Metric Formulas** | Revenue formula computed in orders_month CTE but NOT used in final output. Hardcoded transfer_status_id list in orders_month. |
| **Inclusion/Exclusion** | INCLUDE ONLY: `status = 'Inactive'` (rejected), `business_team_user_id <> '1'`, `is_deleted <> TRUE`. EXCLUDE: all active/non-rejected onboards. |
| **Snippet References** | None — uses hardcoded transfer_status_id list (8,9,...,42) |
| **Known Limitations** | Despite building complex orders/merchant CTEs with revenue calculations, the final SELECT only performs `COUNT(n.id)` — the order and revenue CTEs are unused dead weight. The merchants CTE has a commented-out phone filter: `-- AND phone IN (SELECT phone FROM new_onboards)`. The hardcoded status list (22 values) differs from the snippet used by other cards and from the historical cards (40 values); this may cause subtle discrepancies in processed order counts between this card and Overview cards. Mixing `current_month` string parameter with date parameters can lead to confusing filter combinations. |

---

### Card 2260 — Team Wise Distribution [Orders]

| Property | Value |
|---|---|
| **Display** | Pie |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the share of processed orders across teams (KAM, Acquisition, Corporate)? |
| **Output Grain** | One row per `team_name` |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users`, `courier_appsmith.business_team` |
| **Key Fields** | `merchant_id`, `phone`, `user_name`, `team_name`, `onboard_type`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee` |
| **Join Paths** | `new_onboards` → `public_merchants` (LEFT JOIN, OR) → `orders` (LEFT JOIN, first order) → `orders` (LEFT JOIN, monthly agg). Results joined to `business_team_users` via `SAFE_CAST(business_team_user_id AS INT64)` and then to `business_team`. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`. Merchants: `kam_id IS NULL`. Orders: `country_id = 1`, `updated_at IS NOT NULL`, `sorted_at >= month start` AND `< CURRENT_DATE()` (excludes today). Window logic on onboard_type. |
| **Dashboard Parameters** | `{{merchant_ID}}`, `{{Acq_Member_Name}}`, `{{onboard_type}}`, `{{team_name}}` |
| **Date Window** | Current month (start → yesterday, excluding today) |
| **Aggregation** | `SUM(processed)`, `SUM(expected_rvn_all)`, `COUNT(DISTINCT merchant_id)`, `SUM(KPI_Bonus)`. GROUP BY `user_name`, `team_name` then team_summary rollup: `GROUP BY team_name`. |
| **Metric Formulas** | **Revenue:** Standard formula with `{{snippet: processed_orders}}`. **KPI Bonus:** 0 (Post Corporate), 0.005×revenue (Organic), 0.02×revenue (others). |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, `kam_id IS NOT NULL`, deleted, `business_team_user_id = '1'`. INCLUDE: all onboard types per window logic. |
| **Snippet References** | `{{snippet: processed_orders}}` (×3) |
| **Known Limitations** | The `details` CTE groups by `user_name` and `team_name`, then `team_summary` re-aggregates by `team_name` — `Processed` and revenue are re-summed (correct) but `Merchant_Count` from details uses `COUNT(DISTINCT merchant_id)` which is lost in the second aggregation. A merchant assigned to multiple team members could be double-counted. Excludes today's orders (`sorted_at < CURRENT_DATE()`). Uses `is_deleted IS NOT TRUE` (correct NULL handling) unlike some other cards. |

---

### Card 2262 — Order Trend CRM

| Property | Value |
|---|---|
| **Display** | Area |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the daily processed order trend for CRM merchants this month? |
| **Output Grain** | One row per `order_date` (daily) |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users` |
| **Key Fields** | `merchant_id`, `phone`, `sorted_at`, `transfer_status_id`, `created_at`, `onboard_type` |
| **Join Paths** | `new_onboards` → `public_merchants` (LEFT JOIN, OR) → `orders` (LEFT JOIN, first order) → `orders_day` (LEFT JOIN, daily aggregation) → `business_team_users` (LEFT JOIN) |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`. Merchants: `kam_id IS NULL`, `nob.created_at IS NOT NULL`. Orders: `sorted_at >= month start` AND `< CURRENT_DATE()` (excludes today). Window logic on onboard_type. |
| **Dashboard Parameters** | None — no `[[AND ...]]` markers |
| **Date Window** | Current month (start → yesterday) |
| **Aggregation** | `SUM(processed)` and `COUNT(DISTINCT merchant_id)` per day. GROUP BY `order_date`. |
| **Metric Formulas** | `COUNTIF(transfer_status_id IN ({{snippet: processed_orders}}))` for daily processed count |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, `kam_id IS NOT NULL`, deleted, `business_team_user_id = '1'`. INCLUDE: all types per window logic. WHERE `order_date IS NOT NULL` — only days with orders appear. |
| **Snippet References** | `{{snippet: processed_orders}}` (×1) |
| **Known Limitations** | Days with zero orders do not appear in the chart (LEFT JOIN with `order_date IS NOT NULL` filter drops them). This means the area chart shows only active days, not a continuous time series. The `business_team_users` join is performed but none of its columns are used in the final output — dead join. `is_deleted IS NOT TRUE` provides correct NULL handling. |

---

## Tab 2: Performance Tracker

### Card 2030 — Performance Tracker

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | How are CRM acquisition members performing on lead assignments, first trips, and outreach (text/call) this month? |
| **Output Grain** | One row per CRM user + one TOTAL row |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_appsmith.business_team_users` |
| **Key Fields** | `id`, `merchant_id`, `business_team_user_id`, `user_name`, `status`, `text_status`, `call_status`, `onboard_type`, `is_deleted`, `created_at`, `sorted_at` |
| **Join Paths** | `new_onboards` → `business_team_users` (LEFT JOIN on `business_team_user_id`). `first_trip` CTE runs an independent query with EXISTS on orders. |
| **Filter / WHERE** | Organic ONLY. `business_team_user_id <> '1'`, `is_deleted <> TRUE`. `created_at >= month start`. First trip: additional EXISTS check for orders in current month. |
| **Dashboard Parameters** | None |
| **Date Window** | Current month (start → now) |
| **Aggregation** | `COUNT(id)` for Total Assign, `COUNTIF(status = 'Inactive')` for rejected, `COUNTIF(text_status = 'YES')` for Texted, `COUNTIF(call_status = 'YES')` for Called. Arithmetic for Remaining. `COUNT(DISTINCT merchant_id)` with EXISTS for First Trip. `SAFE_DIVIDE` for % First Trip. |
| **Metric Formulas** | **Text Remaining:** `COUNT(*) - COUNTIF(text_status = 'YES')`. **Call Remaining:** `COUNT(*) - COUNTIF(call_status = 'YES')`. **% First Trip:** `SAFE_DIVIDE(First_Trip_count, Total_Assign)` with `NULLIF(Total_Assign, 0)`. |
| **Inclusion/Exclusion** | INCLUDE ONLY: `Organic`, non-deleted, `business_team_user_id <> '1'`. EXCLUDE: all non-Organic onboards. For first trip: EXCLUDE when `business_team_user_id IS NULL` or `business_team_user_id = '1'`. |
| **Snippet References** | None |
| **Known Limitations** | Only tracks Organic onboards — Post Corporate and other types are excluded entirely. The `% First Trip` formula in the TOTAL row uses a correlated subquery that re-counts from `new_onboards` rather than summing the per-user `First Trip` values, which could produce different results if a merchant is assigned to multiple CRM users. `is_deleted <> true` (lowercase) used inconsistently with other cards. |

---

### Card 2060 — Sales Overview [Merchants Specific]

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the detailed per-merchant sales performance for CRM-managed merchants this month? |
| **Output Grain** | One row per merchant + one TOTAL row |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users`, `courier_appsmith.business_team` |
| **Key Fields** | `merchant_id`, `business_name`, `phone`, `onboard_type`, `estimated_volume`, `leads_created_at`, `first_order_date_after_lead_creation`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee`, `user_name` (as Acq_Name), `team_name` |
| **Join Paths** | `new_onboards` → `filtered_new_onboards` (pre-filter) → `public_merchants` (INNER JOIN, OR) → `orders` (LEFT JOIN, first_order) → `daily_orders` (LEFT JOIN) → `orders_extras` (aggregated) → `orders_month` (LEFT JOIN) → `final` (merchant summary) → `details` (grouped by merchant + CRM user) → final output with TOTAL. Also joins `business_team_users` and `business_team`. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`, `created_at IS NOT NULL`. Pre-filtered by onboard type window logic. Merchants: `kam_id IS NULL`. Orders: `country_id = 1`, `updated_at IS NOT NULL`. Monthly: `sorted_at >= month start` AND `< today`. |
| **Dashboard Parameters** | `{{merchant_ID}}`, `{{Acq_Member_Name}}`, `{{onboard_type}}`, `{{Team_name}}`, `{{last_day_order}}` (with special OR logic: `'0 Orders'` → `last_day_orders = 0`, `'Has Orders'` → `last_day_orders > 0`) |
| **Date Window** | Current month (start → yesterday). Organic window: 15th last month → end of next month. |
| **Aggregation** | `SUM(processed)`, `SUM(expected_rvn_all)`, `SUM(last_day_orders)`, `SUM(active_days)`, `ROUND(AVG(avg_daily_orders), 2)`. GROUP BY merchant-level fields. TOTAL row: additional `SUM` across all details. |
| **Metric Formulas** | **Revenue:** Standard formula with `{{snippet: processed_orders}}`. **KPI Bonus:** 0 / 0.005 / 0.02 per onboard_type. **Last_Day_Orders:** count on yesterday specifically. **Active_Days:** `COUNT(DISTINCT order_date)` within month. **Avg_Daily_Orders:** `SAFE_DIVIDE(total excluding yesterday, days excluding yesterday)`. **cases:** `'Low'` if `Last_Day_Orders < Avg_Daily_Orders`, else `'High'`. |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, deleted, system user, `kam_id IS NOT NULL`. INCLUDE: all onboard types per window logic. |
| **Snippet References** | `{{snippet: processed_orders}}` (×4) |
| **Known Limitations** | The `daily_orders` CTE uses `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), MONTH)` and `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)` for date boundaries instead of `DATE_TRUNC(CURRENT_DATE(), ...)` used by other cards — potential off-by-one at day boundaries. The `cases` column is set to NULL for the TOTAL row. Active_Days and Avg_Daily_Orders include yesterday in counts but exclude yesterday from the average denominator — correct but potentially confusing. `is_deleted IS NOT TRUE` correctly handles NULLs. |

---

## Tab 3: Leaderboard

### Card 2114 — Leaderboard

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | How do CRM acquisition members rank against each other on orders, revenue, and KPI bonus, with target tracking? |
| **Output Grain** | One row per CRM user + one TOTAL row |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users`, `courier_appsmith.business_team`, `hermes_bz_comms.crm_user_targets` |
| **Key Fields** | `business_team_user_id` (crm_id), `user_name` (Acq_Name), `team_name`, `estimated_volume`, `merchant_id`, `phone`, `onboard_type`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee` |
| **Join Paths** | `new_onboards` (with optional onboard_type filter) → `filtered_new_onboards` → `public_merchants` (INNER JOIN, OR) → `orders` (LEFT JOIN, first_order) → `orders_month` (LEFT JOIN, monthly agg) → `final` → `details` (GROUP BY crm_id, Acq_Name, team_name) → CROSS JOIN `days_in_month` → `final_final` (ROW_NUMBER rank) → `filtered_results` (LEFT JOIN `crm_user_targets`) → TOTAL row appended via UNION ALL. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`, `created_at IS NOT NULL`. Pre-filter (filtered_new_onboards): onboard type window logic. Orders: `sorted_at >= month start` AND `< today`. results filter: window logic on `first_order_date_after_lead_creation`. |
| **Dashboard Parameters** | `{{onboard_type}}` (line 53, on `new_onboards` CTE), `{{team_name}}` (line 266), `{{Acq_Name}}` (line 267) |
| **Date Window** | Current month (start → yesterday) |
| **Aggregation** | `SUM(n.estimated_volume)`, `SUM(f.processed)`, `SUM(f.expected_rvn_all)`, `COUNT(DISTINCT f.merchant_id)`, `COUNTIF(f.processed > 0)` for Active Merchants. Forecast formulas via `SAFE_DIVIDE` + `SAFE_MULTIPLY`. |
| **Metric Formulas** | **Revenue:** Standard formula with `SAFE_DIVIDE` wrapping each division (differs from e.g. card 2029 which uses plain `/100`). **KPI Bonus:** 0 / 0.005 / 0.02 with `SAFE_MULTIPLY`. **AOV:** `SAFE_DIVIDE(Expected_Revenue, Processed)`. **Forecasted Order:** `SAFE_MULTIPLY(SAFE_DIVIDE(SUM(processed), days_passed), total_days_in_month)`. **Order_Goal:** `SAFE_DIVIDE(Processed, order_target)`. **Revenue_Goal:** `SAFE_DIVIDE(Expected_Revenue, revenue_target)`. **order_remaining:** `CONCAT('🔴 - ', ROUND(target - processed))` or `CONCAT('🟢 +', ROUND(...))`. |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, deleted, system user, `kam_id IS NULL`. INCLUDE: all types per window logic. |
| **Snippet References** | `{{snippet: processed_orders}}` (×3) |
| **Known Limitations** | The TOTAL row's `revenue_goal` formula uses a convoluted expression `SAFE_DIVIDE(SUM(Expected_Revenue), SUM(revenue_goal * Expected_Revenue / NULLIF(Expected_Revenue,0)))`. This appears to be attempting a weighted average but may produce incorrect results when Expected_Revenue is 0 for some rows. The `forecast` is a simple linear projection and does not account for team-specific seasonality. `is_deleted IS NOT TRUE` correctly handles NULLs. Rank is computed by `ROW_NUMBER() OVER (ORDER BY KPI_Bonus DESC)`. |

---

## Tab 4: CRM Entry Checker

### Card 2271 — CRM Merchant Entry Checker [Admin]

| Property | Value |
|---|---|
| **Display** | Object (detail table) |
| **Database** | 5 (**PostgreSQL**) |
| **Business Question** | What are the full details of a specific CRM merchant lead entry? |
| **Output Grain** | One row per matching `new_onboards` record |
| **Source Tables** | `new_onboards` (Postgres), `business_team_users` (Postgres, joined twice: assignee + assigner) |
| **Key Fields** | `id`, `merchant_id`, `business_team_user_id`, `assigner_user_id`, `business_name`, `business_owner_name`, `phone`, `onboard_type`, `status`, `estimated_volume`, `created_at`, `updated_at`, `text_status`, `call_status`, `is_deleted`, `account_status`, `assigned_at` |
| **Join Paths** | `new_onboards no` → `business_team_users btu` (ON `btu.id = CAST(no.business_team_user_id AS INT)`) → `business_team_users btu2` (ON `btu.id = CAST(no.assigner_user_id AS INT)`) — **Note:** The second join incorrectly joins on `btu.id` instead of `btu2.id`, which is a bug. |
| **Filter / WHERE** | `1=1` base. Optional: `[[and phone = {{phone}}]]`, `[[and merchant_id = {{merchant_id}}]]`. No business_team_user_id filter, no status filter, no is_deleted filter. |
| **Dashboard Parameters** | `{{phone}}`, `{{merchant_id}}` |
| **Date Window** | None — no date filters |
| **Aggregation** | None — `SELECT *` returns raw rows |
| **Metric Formulas** | None |
| **Inclusion/Exclusion** | No exclusion rules. Returns all rows including deleted and Inactive (unlike all other cards). |
| **Snippet References** | None |
| **Known Limitations** | **Critical:** The second JOIN (`btu2`) uses `btu.id = CAST(assigner_user_id as INT)` instead of `btu2.id` — this means the assigner name column (`user_name_2`) will incorrectly show the assignee's name whenever `business_team_user_id = assigner_user_id`, or NULL otherwise. **Only card using Postgres (db 5)** — all other cards use BigQuery (db 7). No `is_deleted`, `status`, or `business_team_user_id <> '1'` filters, so this card can return system records and deleted entries. Raw `SELECT *` with no column filtering. |

---

## Tab 5: Historical

### Card 2400 — Historical Merchant Overview

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | What is the detailed per-merchant performance for a user-selected historical date range? |
| **Output Grain** | One row per merchant + one TOTAL row |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users` |
| **Key Fields** | `merchant_id`, `business_name`, `phone`, `onboard_type`, `estimated_volume`, `leads_created_at`, `first_order_date_after_lead_creation`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee`, `user_name` (Acq_Name), `sorted_at` |
| **Join Paths** | Same structure as card 2060 but: (a) uses `{{start_date}}`/`{{end_date}}` everywhere instead of `CURRENT_DATE()`; (b) no `business_team` join; (c) no `team_name` output column. `filtered_new_onboards` → `public_merchants` (INNER JOIN, OR) → `orders` (first_order) → `daily_orders` → `orders_extras` → `orders_month` → `final` → `details` → UNION ALL TOTAL row. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`, `created_at IS NOT NULL`. Organic window anchored on `{{start_date}}` and `{{end_date}}`. Orders: `sorted_at >= DATE({{start_date}})` AND `sorted_at <= DATE({{end_date}})`. results (details): same window logic using parameters. |
| **Dashboard Parameters** | `{{start_date}}` and `{{end_date}}` (used extensively — 8 references), `{{merchant_ID}}`, `{{Acq_Member_Name}}`, `{{onboard_type}}` |
| **Date Window** | Fully parameter-driven: `{{start_date}}` to `{{end_date}}`. Last_day = `DATE_SUB({{end_date}}, INTERVAL 1 DAY)`. |
| **Aggregation** | `SUM(processed)`, `SUM(expected_rvn_all)`, `SUM(last_day_orders)`, `SUM(active_days)`, `ROUND(AVG(avg_daily_orders), 2)`. TOTAL row: additional SUM. GROUP BY merchant-level columns. |
| **Metric Formulas** | **Revenue:** Standard formula but with **hardcoded** transfer_status_id list `(5,6,7,...,44)` — 40 statuses. **KPI Bonus:** 0 / 0.005 / 0.02. **cases:** `'Low'` / `'High'` by comparing `Last_Day_Orders` vs `Avg_Daily_Orders`. |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, deleted, system user, `kam_id IS NULL`. INCLUDE: all types per window logic. |
| **Snippet References** | None — uses hardcoded transfer_status_id list |
| **Known Limitations** | **No `{{snippet: processed_orders}}`** — the hardcoded transfer_status_id list (40 values) differs from the snippet used by current-month cards. If the snippet is updated on the server, this card will not pick up the change. The `cases` column is NULL for the TOTAL row. No team_name column unlike card 2060, making team-based filtering unavailable. No `{{Team_name}}` parameter despite having a team concept in the org. `last_day` CTE uses `SELECT DATE_SUB(DATE({{end_date}}), INTERVAL 1 DAY) AS d` — scoped subquery that may be inefficient at scale. |

---

### Card 2402 — Historical Leaderboard

| Property | Value |
|---|---|
| **Display** | Table |
| **Database** | 7 (BigQuery) |
| **Business Question** | How did CRM members rank historically over a user-selected date range, with target comparisons? |
| **Output Grain** | One row per CRM user + one TOTAL row |
| **Source Tables** | `courier_realtime_datastream.public_orders`, `courier_realtime_datastream.public_archived_orders`, `courier_appsmith.new_onboards`, `courier_realtime_datastream.public_merchants`, `courier_appsmith.business_team_users`, `courier_appsmith.business_team`, `hermes_bz_comms.crm_user_targets` |
| **Key Fields** | `business_team_user_id` (crm_id), `user_name` (Acq_Name), `team_name`, `estimated_volume`, `merchant_id`, `phone`, `onboard_type`, `transfer_status_id`, `delivery_fee`, `additional_charge`, `discount`, `promo_discount`, `cash_on_delivery_fee` |
| **Join Paths** | Same structure as card 2114 but parameterized. `filtered_new_onboards` (with `{{start_date}}`/`{{end_date}}`) → `public_merchants` (INNER JOIN) → `orders` (first_order) → `orders_month` (parameterized date range) → `final` → CROSS JOIN `days_in_range` → `details` → UNION ALL TOTAL → `final_final` → LEFT JOIN `crm_user_targets`. |
| **Filter / WHERE** | `new_onboards`: `business_team_user_id <> '1'`, `is_deleted IS NOT TRUE`, `status <> 'Inactive'`, `created_at IS NOT NULL`. Organic window on `{{start_date}}`/`{{end_date}}`. Orders: `sorted_at >= DATE({{start_date}})` AND `sorted_at <= DATE({{end_date}})`. Details: same window logic. |
| **Dashboard Parameters** | `{{start_date}}` and `{{end_date}}` (used in 8 locations), `{{merchant_ID}}`, `{{Acq_Member_Name}}`, `{{onboard_type}}`, `{{team_name}}` |
| **Date Window** | Fully parameter-driven: `{{start_date}}` to `{{end_date}}`. `days_in_period` = `DATE_DIFF(end_date, start_date, DAY) + 1`. |
| **Aggregation** | `SUM(estimated_volume)`, `SUM(processed)`, `SUM(expected_rvn_all)`, `COUNT(DISTINCT merchant_id)`. Forecasts: `SAFE_MULTIPLY(SAFE_DIVIDE(..., days_in_period), total_days_in_period)`. |
| **Metric Formulas** | **Revenue:** Standard formula with `SAFE_DIVIDE` + hardcoded 40-value transfer_status_id list `(5,6,7,...,44)`. **KPI Bonus:** 0 / `SAFE_MULTIPLY(0.005, ...)` / `SAFE_MULTIPLY(0.02, ...)`. **AOV:** `SAFE_DIVIDE(Expected_Revenue, NULLIF(Processed, 0))`. **Order_Goal / Revenue_Goal:** `SAFE_DIVIDE` against `crm_user_targets`. **order_remaining / revenue_remaining:** with emoji indicators. |
| **Inclusion/Exclusion** | EXCLUDE: `Inactive`, deleted, system user, `kam_id IS NULL`. INCLUDE: all types per window logic. |
| **Snippet References** | None — uses hardcoded transfer_status_id list |
| **Known Limitations** | Same hardcoded status list issue as card 2400 (40 values vs snippet). `days_in_range` CTE computes the same value for both `days_in_period` and `total_days_in_period` — the forecast is essentially `sum * (days / days) = sum`, making the forecast identical to the actual when the range is the same as the analysis window. This differs from card 2114 which projects to full-month. The TOTAL row's rank is computed as `ROW_NUMBER() ... - 1` giving it Rank 0. No `last_day_order` filter parameter unlike card 2060. |

---

## Parameter Mapping Summary

| Card ID | `current_month` | `merchant_id` | `crm_member` | `onboard_type` | `team_name` | `phone` | `start_date` | `end_date` | `last_day_order` |
|---|---|---|---|---|---|---|---|---|---|
| 2013 | — | — | — | — | — | — | — | — | — |
| 2028 | (via 2060) | (via 2060) | (via 2060) | (via 2060) | (via 2060) | — | — | — | (via 2060) |
| 2029 | — | — | — | — | — | — | — | — | — |
| 2031 | — | — | — | — | — | — | — | — | — |
| 2033 | — | — | — | — | — | — | — | — | — |
| 2050 | — | — | — | — | — | — | — | — | — |
| 2158 | ✅ | — | — | — | — | — | ✅ | ✅ | — |
| 2260 | — | ✅ | ✅ | ✅ | ✅ | — | — | — | — |
| 2262 | — | — | — | — | — | — | — | — | — |
| 2030 | — | — | — | — | — | — | — | — | — |
| 2060 | — | ✅ | ✅ | ✅ | ✅ | — | — | — | ✅ |
| 2114 | — | — | ✅ | ✅ | ✅ | — | — | — | — |
| 2271 | — | ✅ | — | — | — | ✅ | — | — | — |
| 2400 | — | ✅ | ✅ | ✅ | — | — | ✅ | ✅ | — |
| 2402 | — | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ | — |

> Parameter names are case-sensitive across cards. `merchant_ID` vs `merchant_id`, `Acq_Member_Name` vs `Acq_Name`, `Team_name` vs `team_name`.

---

## Snippet vs Hardcoded Status IDs

| Approach | Cards Using | Transfer Status IDs |
|---|---|---|
| `{{snippet: processed_orders}}` | 2029, 2031, 2050, 2060, 2114, 2260, 2262 | Server-defined (dynamic) |
| Hardcoded (22 values) | 2158 | `8,9,10,11,12,13,22,23,24,26,28,25,14,30,31,32,33,36,37,38,39,40,41,42` |
| Hardcoded (40 values) | 2400, 2402 | `5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44` |

**Risk:** If the snippet is updated (e.g., adding new transfer statuses), cards 2158, 2400, and 2402 will diverge from the current-month cards.

---

## NULL Handling Comparison

| Card IDs | `is_deleted` Check | Notes |
|---|---|---|
| 2013, 2029, 2031, 2033, 2158, 2030 | `<> TRUE` or `<> true` | MISSES NULL — records with `is_deleted IS NULL` are NOT excluded |
| 2050, 2260, 2262, 2060, 2114, 2400, 2402 | `IS NOT TRUE` or `IS DISTINCT FROM TRUE` | CORRECT — excludes both TRUE and NULL |
| 2271 | No check at all | All records returned |

---

## Card-to-Card Dependencies

```
Card 2028 (Total Processed)
  └── References Card 2060 (Sales Overview) → picks TOTAL row
```

No other card-to-card dependencies exist within the dashboard. Card 2028 is the only pass-through card.

---

## Key Discrepancies & Risks

1. **NULL handling inconsistency:** 7 of 15 cards use `<> TRUE` for `is_deleted` (missing NULLs), 6 use `IS NOT TRUE`/`IS DISTINCT FROM TRUE` (correct), and 1 (2271) omits the check entirely.

2. **Transfer status divergence:** Historical cards (2400, 2402) and card 2158 hardcode status lists that may differ from the snippet. If the server-side snippet is updated, these cards will not reflect the change.

3. **Date boundary inconsistency:** Card 2060 uses `TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), ...)` while other cards use `DATE_TRUNC(CURRENT_DATE(), ...)`. This can cause off-by-one-day issues around UTC midnight.

4. **Join bug in card 2271:** The assigner user join incorrectly references `btu.id` instead of `btu2.id`.

5. **Hardcoded date in card 2031:** The orders CTE filters `updated_at >= "2026-01-01"` — this fixed date will become increasingly problematic over time.

6. **Unused CTEs in card 2158:** Complex order/merchant CTEs are built but only `COUNT(n.id)` is used in the final output — dead computation that increases query cost.

7. **Parameter name drift:** `merchant_ID` vs `merchant_id`, `Acq_Member_Name` vs `Acq_Name`, `Team_name` vs `team_name` — not all cards respond to all filter widgets.

8. **Card 2029 has no dashboard parameter integration** despite being on the Overview tab alongside parameter-driven cards.

9. **Revenue formula variance:** Cards 2114/2402 use `SAFE_DIVIDE(..., 100)`, others use plain `/100`. If the sum is NULL for zero-order merchants, SAFE_DIVIDE returns NULL while `/100` returns 0 after COALESCE. The effective output is similar due to COALESCE wrapping but the intent is different.

10. **Organic window logic:** The 15th-of-last-month rule is hardcoded across most cards. If business rules change, all cards with this logic need updating individually.

---

*End of inventory. Document covers all 15 cards across 5 dashboard tabs with SQL-level detail extracted from the production Metabase instance.*
