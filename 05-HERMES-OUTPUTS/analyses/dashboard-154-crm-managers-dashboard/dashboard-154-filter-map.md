# Dashboard 154: Filter-to-Card Map

> **Dashboard:** 154 — CRM Managers Dashboard  
> **Total Filters:** 9  
> **Total Cards:** 15  
> **Generated:** 2026-06-19

---

## Filter Inventory

| # | Filter Slug | Type | Default | Description |
|---|---|---|---|---|
| 1 | `current_month` | string | `"Yes"` | Toggle to restrict to current calendar month |
| 2 | `merchant_id` | number | — | Filter by specific merchant ID |
| 3 | `crm_member_name` | string | — | Filter by CRM acquisition member name |
| 4 | `onboard_type` | string | — | Filter by merchant onboard type |
| 5 | `team_name` | string | — | Filter by team |
| 6 | `phone` | string | — | Filter by merchant phone |
| 7 | `start_date` | date/single | — | Start date for historical range |
| 8 | `end_date` | date/single | — | End date for historical range |
| 9 | `last_day_order_%3F` | string | `"Last Day order ?"` | Filter by last-day order status |

---

## Parameter Name Aliases (Per Card)

| Canonical Filter Name | Aliases Used in SQL |
|---|---|
| `merchant_id` | `merchant_id` (2271), `merchant_ID` (2260, 2060, 2400, 2402) |
| `crm_member_name` | `Acq_Member_Name` (2260, 2060, 2400, 2402), `Acq_Name` (2114) |
| `team_name` | `team_name` (2260, 2114, 2402), `Team_name` (2060) |
| `last_day_order_%3F` | `last_day_order` (2060) |

---

## Per-Filter Card Map

### 1. `current_month` (string, default "Yes")

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2158** | Total Leads Rejected | `[[AND {{current_month}} = 'Yes' AND DATE(n.created_at) >= DATE_TRUNC(DATE(CURRENT_DATE()), MONTH)]]` | Optional `[[...]]` wrapper; strips when empty/null. When "Yes", applies current-month filter. |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2260, 2262, 2030, 2060, 2114, 2271, 2400, 2402

---

### 2. `merchant_id` (number) / `merchant_ID`

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2260** | Team Wise Distribution [Orders] | `[[AND f.merchant_id = {{merchant_ID}}]]` | Optional filter on final merchant_id |
| **2060** | Sales Overview [Merchants Specific] | `[[AND f.merchant_id = {{merchant_ID}}]]` | Optional filter on final merchant_id |
| **2271** | CRM Merchant Entry Checker [Admin] | `[[and merchant_id = {{merchant_id}}]]` | Optional filter, lowercase `merchant_id` (Postgres, db5) |
| **2400** | Historical Merchant Overview | `[[AND f.merchant_id = {{merchant_ID}}]]` | Optional filter on final merchant_id |
| **2402** | Historical Leaderboard | `[[AND f.merchant_id = {{merchant_ID}}]]` | Optional filter on final merchant_id |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2262, 2030, 2114

> **Note:** Card 2028 (Total Processed) references card #2060 via `{{#2060-sales-overview-merchants-specific}}` and thus *indirectly* inherits this filter when card 2060 is filtered.

---

### 3. `crm_member_name` (string) aliased as `Acq_Member_Name` / `Acq_Name`

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2260** | Team Wise Distribution [Orders] | `[[AND btu.user_name = {{Acq_Member_Name}}]]` | Optional filter on business_team_users.user_name |
| **2060** | Sales Overview [Merchants Specific] | `[[AND btu.user_name = {{Acq_Member_Name}}]]` | Optional filter on business_team_users.user_name |
| **2114** | Leaderboard | `[[AND ff.Acq_Name IN ({{Acq_Name}})]]` | Optional filter on the derived Acq_Name column in filtered_results CTE. Uses `IN` (list) syntax. |
| **2400** | Historical Merchant Overview | `[[AND btu.user_name = {{Acq_Member_Name}}]]` | Optional filter on business_team_users.user_name |
| **2402** | Historical Leaderboard | `[[AND btu.user_name = {{Acq_Member_Name}}]]` | Optional filter on business_team_users.user_name |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2262, 2030, 2271

> **Note:** Card 2028 (Total Processed) references card #2060 and thus *indirectly* inherits this filter.

---

### 4. `onboard_type` (string)

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2260** | Team Wise Distribution [Orders] | `[[AND n.onboard_type = {{onboard_type}}]]` | Optional filter on new_onboards.onboard_type |
| **2060** | Sales Overview [Merchants Specific] | `[[AND n.onboard_type = {{onboard_type}}]]` | Optional filter on new_onboards.onboard_type |
| **2114** | Leaderboard | `[[AND onboard_type = {{onboard_type}}]]` | Optional filter on new_onboards CTE (early filter, before filtered_new_onboards) |
| **2400** | Historical Merchant Overview | `[[AND n.onboard_type = {{onboard_type}}]]` | Optional filter on new_onboards.onboard_type |
| **2402** | Historical Leaderboard | `[[AND n.onboard_type = {{onboard_type}}]]` | Optional filter on new_onboards.onboard_type |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2262, 2030, 2271

> **Note:** Card 2028 (Total Processed) references card #2060 and thus *indirectly* inherits this filter.

---

### 5. `team_name` (string) aliased as `Team_name`

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2260** | Team Wise Distribution [Orders] | `[[AND bt.team_name IN ({{team_name}})]]` | Optional filter on business_team.team_name. Uses `IN` (list) syntax. |
| **2060** | Sales Overview [Merchants Specific] | `[[AND bt.team_name = {{Team_name}}]]` | Optional filter on business_team.team_name. Aliased as `Team_name`. |
| **2114** | Leaderboard | `[[AND ff.team_name IN ({{team_name}})]]` | Optional filter on derived team_name in filtered_results CTE. Uses `IN` (list). |
| **2402** | Historical Leaderboard | `[[AND bt.team_name IN ({{team_name}})]]` | Optional filter on business_team.team_name. Uses `IN` (list). |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2262, 2030, 2271, 2400

> **Note:** Card 2400 (Historical Merchant Overview) does NOT support team_name filtering despite having a structurally similar query to 2060. Card 2028 indirect via #2060.

---

### 6. `phone` (string)

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2271** | CRM Merchant Entry Checker [Admin] | `[[and phone = {{phone}}]]` | Optional filter on new_onboards.phone (Postgres, db5) |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402

> **Note:** Only card 2271 supports phone filter. This is the ONLY card using db5 (Postgres). All other cards use db7 (BigQuery).

---

### 7. `start_date` (date/single)

| Card ID | Card Name | Parameter Pattern(s) | Notes |
|---|---|---|---|
| **2158** | Total Leads Rejected | `[[AND date(n.created_at) >= {{start_date}}]]` | Optional `[[...]]` wrapper. Used alongside `current_month` toggle. |
| **2400** | Historical Merchant Overview | `DATE({{start_date}})` (×8 references) | **MANDATORY** — not wrapped in `[[...]]`. Used in: filtered_new_onboards CTE (×2), daily_orders WHERE (×1), orders_month WHERE (×1), details CTE WHERE (×4) |
| **2402** | Historical Leaderboard | `DATE({{start_date}})` (×8 references) | **MANDATORY** — not wrapped in `[[...]]`. Used in: filtered_new_onboards CTE (×2), orders_month WHERE (×1), days_in_range (×1), details CTE WHERE (×4) |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2260, 2262, 2030, 2060, 2114, 2271

---

### 8. `end_date` (date/single)

| Card ID | Card Name | Parameter Pattern(s) | Notes |
|---|---|---|---|
| **2158** | Total Leads Rejected | `[[AND date(n.created_at) <= {{end_date}}]]` | Optional `[[...]]` wrapper. |
| **2400** | Historical Merchant Overview | `DATE({{end_date}})` (×8 references) | **MANDATORY** — not wrapped in `[[...]]`. Used in: filtered_new_onboards CTE (×2), last_day CTE (×1), daily_orders WHERE (×1), orders_month WHERE (×1), details CTE WHERE (×3) |
| **2402** | Historical Leaderboard | `DATE({{end_date}})` (×8 references) | **MANDATORY** — not wrapped in `[[...]]`. Used in: filtered_new_onboards CTE (×2), orders_month WHERE (×1), days_in_range (×2), details CTE WHERE (×3) |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2260, 2262, 2030, 2060, 2114, 2271

---

### 9. `last_day_order_%3F` (string)

| Card ID | Card Name | Parameter Pattern | Notes |
|---|---|---|---|
| **2060** | Sales Overview [Merchants Specific] | `[[AND (({{last_day_order}} = '0 Orders' AND last_day_orders = 0) OR ({{last_day_order}} = 'Has Orders' AND last_day_orders > 0))]]` | Optional filter. Two-state toggle: `'0 Orders'` shows merchants with zero yesterday orders; `'Has Orders'` shows merchants with >0 yesterday orders. |

**Cards NOT using this filter:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2114, 2271, 2400, 2402

> **Note:** Card 2028 indirect via #2060.

---

## Cards With NO Dashboard Parameter References

These cards use only `CURRENT_DATE()` / `CURRENT_TIMESTAMP()` for date logic and have no `[[AND {{param}}]]` or direct `{{param}}` references in their SQL:

| Card ID | Card Name | Tab | Uses `CURRENT_DATE()`? |
|---|---|---|---|
| **2013** | Total Leads | Overview | ✅ (`DATE_TRUNC(CURRENT_DATE(), MONTH)` → `CURRENT_DATE()`) |
| **2029** | Total Expected Revenue | Overview | ✅ (multiple `CURRENT_DATE()` references) |
| **2031** | Merchant Distribution | Overview | ✅ (`DATE_TRUNC(CURRENT_DATE(), MONTH)`) |
| **2033** | First Trip Conversion (Organic) | Overview | ✅ (`DATE_TRUNC(CURRENT_DATE(), MONTH)`) |
| **2050** | Forecast Orders | Overview | ✅ (extensive `CURRENT_DATE()` usage) |
| **2262** | Order Trend CRM | Overview | ✅ (`DATE_TRUNC(CURRENT_DATE(), MONTH)`) |
| **2030** | Performance Tracker | Performance Tracker | ✅ (`DATE_TRUNC(CURRENT_DATE(), MONTH)`) |

> **Note:** Card 2028 is a pass-through referencing card #2060; it inherits 2060's filters indirectly but has no parameter references in its own SQL.

---

## Parameter Wrapping Mode Summary

| Wrapping Mode | Syntax | Cards | Behavior |
|---|---|---|---|
| **Optional `[[AND ...]]`** | `[[AND col = {{param}}]]` | 2158, 2260, 2060, 2114, 2271, 2400, 2402 (partial) | Metabase strips the entire clause when the filter is empty/null |
| **Mandatory `{{param}}`** | `DATE({{start_date}})` | 2400, 2402 | Parameter MUST have a value; query fails without it |
| **Snippet `{{snippet: name}}`** | `{{snippet: processed_orders}}` | 2029, 2031, 2050, 2060, 2114, 2260, 2262 | Server-side snippet expansion; not a dashboard filter |
| **Card Reference `{{#id}}`** | `{{#2060-sales-overview-merchants-specific}}` | 2028 | References another Metabase card's result as a subquery |

---

## Combined Filter Coverage Matrix

| Card | `current_month` | `merchant_id` | `crm_member` | `onboard_type` | `team_name` | `phone` | `start_date` | `end_date` | `last_day_order` |
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

---

## Key Observations

1. **7 of 15 cards** have zero dashboard parameter integration (2013, 2029, 2031, 2033, 2050, 2262, 2030). They are *always scoped to the current month only* via hardcoded `CURRENT_DATE()`.

2. **Parameter name inconsistency:** `merchant_ID` (4 cards) vs `merchant_id` (1 card, 2271); `Acq_Member_Name` (4 cards) vs `Acq_Name` (1 card, 2114); `Team_name` (1 card, 2060) vs `team_name` (3 cards). Metabase's parameter mapping must handle these aliases for the dashboard filter to work across all cards.

3. **Mandatory vs optional:** Historical cards (2400, 2402) use `{{start_date}}`/`{{end_date}}` **without** `[[...]]` wrappers — these parameters are **required** for the queries to run. Card 2158 uses `[[...]]` wrappers for the same parameters, making them optional.

4. **`current_month` toggle is under-utilized:** Only card 2158 uses it. No other card supports switching between "current month" and "custom date range" modes.

5. **`phone` filter is isolated:** Only card 2271 (the Postgres admin checker) supports phone filtering. No BigQuery cards use it directly.

6. **`last_day_order` is single-card:** Only card 2060 supports this filter. The historical counterpart (2400) does not.
