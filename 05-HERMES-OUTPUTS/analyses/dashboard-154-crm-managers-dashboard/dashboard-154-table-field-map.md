# Dashboard 154: Table & Field Map

> **Dashboard:** 154 — CRM Managers Dashboard  
> **Total Cards:** 15  
> **Generated:** 2026-06-19

---

## Database Summary

| DB ID | Type | Cards Using |
|---|---|---|
| **7** | BigQuery (`courier_realtime_datastream`, `courier_appsmith`, `hermes_bz_comms`) | 14 cards (all except 2271) |
| **5** | PostgreSQL (AppSmith Write DB) | 1 card (2271 only) |

---

## BigQuery Tables (db7)

### 1. `courier_appsmith.new_onboards`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | — | 2050, 2030 | Lead record ID |
| `business_team_user_id` | STRING/INT | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | CRM member assignment. Filtered: `<> '1'`. Cast to INT64 in many cards. |
| `merchant_id` | — | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Links to `public_merchants.id`. Can be NULL (phone fallback). |
| `phone` | STRING | 2029, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Phone fallback join key. |
| `is_deleted` | BOOLEAN | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Soft-delete flag. Handling varies: `<> TRUE` (misses NULLs) vs `IS NOT TRUE` / `IS DISTINCT FROM TRUE` (correct). |
| `status` | STRING | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Lead status. Most cards filter `<> 'Inactive'`. Card 2158 filters `= 'Inactive'` only. Card 2013 does NOT filter on status. |
| `onboard_type` | STRING | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Values: `Organic`, `Post Corporate`, and others (Hunt, Churn, etc.). Drives window logic. |
| `estimated_volume` | NUMERIC | 2060, 2114, 2400, 2402 | Estimated merchant order volume. Used in KPI display. |
| `created_at` | TIMESTAMP | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Lead creation timestamp. Primary date anchor for window logic. |
| `business_name` | STRING | 2060, 2400 | Merchant business name. Used in display output. |
| `account_status` | STRING | 2031 | Used in `COALESCE(account_status, onboard_type)` for status distribution. |
| `text_status` | STRING | 2030 | `'YES'` / NULL. Tracks whether lead was texted. |
| `call_status` | STRING | 2030 | `'YES'` / NULL. Tracks whether lead was called. |

**Cards NOT using this table:** 2028 (references card #2060 instead), 2271 (uses Postgres `new_onboards`)

---

### 2. `courier_realtime_datastream.public_orders`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | — | 2060, 2114, 2400, 2402 | Order ID (column-selected in narrowed scans) |
| `merchant_id` | — | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Join key to merchants |
| `created_at` | TIMESTAMP | 2029, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Order creation time. Used for first-order detection. |
| `sorted_at` | TIMESTAMP | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Order processing time. Primary date anchor for monthly aggregation. |
| `transfer_status_id` | INT | 2029, 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Order status code. Filtered by snippet or hardcoded list for "processed" orders. |
| `delivery_fee` | NUMERIC | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 | Revenue component. COALESCE'd to 0. |
| `additional_charge` | NUMERIC | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 | Revenue component. COALESCE'd to 0. |
| `discount` | NUMERIC | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 | Revenue deduction. COALESCE'd to 0. |
| `promo_discount` | NUMERIC | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 | Revenue deduction. COALESCE'd to 0. |
| `cash_on_delivery_fee` | NUMERIC | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 | Revenue component. COALESCE'd to 0. |
| `updated_at` | TIMESTAMP | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Filter: `IS NOT NULL` — used as a data freshness gate. |
| `country_id` | INT | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Filter: `= 1` (Bangladesh). |
| `final_fee` | NUMERIC | 2050 | Pre-computed fee column. Used ONLY in card 2050 (Forecast Orders) — all other cards compute revenue from individual fee columns. |

**Cards NOT using this table:** 2013, 2028, 2271

---

### 3. `courier_realtime_datastream.public_archived_orders`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| *(same fields as `public_orders`)* | — | 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | `UNION ALL` with `public_orders`. Same columns used. |

**Cards NOT using this table:** 2013, 2028, 2029, 2271

> **Note:** Card 2029 is the only Overview card that does NOT use `public_archived_orders`. Card 2031 does not use it either, accessing only `public_orders`.

---

### 4. `courier_realtime_datastream.public_merchants`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | — | 2029, 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Merchant ID. Primary join key with new_onboards.merchant_id. |
| `phone` | STRING | 2029, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Fallback join key when new_onboards.merchant_id IS NULL. |
| `name` | STRING | 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Merchant display name. Output as `merchant_name`. |
| `updated_at` | TIMESTAMP | 2029, 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Filter: `IS NOT NULL` (data freshness gate). |
| `kam_id` | — | 2029, 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Key Account Manager ID. Filter: `IS NULL` — only non-KAM merchants. |

**Cards NOT using this table:** 2013, 2028, 2033, 2030, 2271

---

### 5. `courier_appsmith.business_team_users`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | INT | 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 | Join key. Matched via `SAFE_CAST(business_team_user_id AS INT64)`. |
| `user_name` | STRING | 2030, 2158, 2260, 2262, 2060, 2114, 2400, 2402 | Display name of CRM member. Output as `Acq_Name` / `user_name`. |
| `team_id` | INT | 2260, 2060, 2114, 2402 | FK to `business_team.id`. |
| `is_active` | BOOLEAN | — | Not directly referenced in any card's WHERE clause. |

**Cards NOT using this table:** 2013, 2028, 2029, 2031, 2033, 2050, 2271

> **Note:** Card 2262 joins `business_team_users` but none of its columns appear in the final SELECT — dead join.

---

### 6. `courier_appsmith.business_team`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | INT | 2260, 2060, 2114, 2402 | Join key. Matched via `btu.team_id`. |
| `team_name` | STRING | 2260, 2060, 2114, 2402 | Team display name (e.g., KAM, Acquisition, Corporate). |

**Cards NOT using this table:** 2013, 2028, 2029, 2031, 2033, 2050, 2158, 2262, 2030, 2271, 2400

> **Note:** Card 2400 does NOT join `business_team` (no team_name output column).

---

### 7. `hermes_bz_comms.crm_user_targets`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | INT | 2114, 2402 | Join key to `crm_id` (business_team_user_id). |
| `order_target` | NUMERIC | 2114, 2402 | Monthly order target per CRM user. |
| `revenue_target` | NUMERIC | 2114, 2402 | Monthly revenue target per CRM user. |

**Cards using this table:** 2114 (Leaderboard), 2402 (Historical Leaderboard)

---

### 8. `hermes_bz_comms.business_team_targets`

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `team_name` | STRING | 2050 | Filter: `= 'ACQ'`. |
| `start_of_month` | DATE | 2050 | Filter: `= this_month_start`. |
| `targets` | NUMERIC | 2050 | Team-level order target. Used as forecast run-rate denominator. |

**Cards using this table:** 2050 (Forecast Orders) only

---

## PostgreSQL Tables (db5)

### 9. `new_onboards` (AppSmith Write DB, db5)

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | — | 2271 | CRM lead ID |
| `merchant_id` | — | 2271 | Filterable via `[[and merchant_id = {{merchant_id}}]]` |
| `business_team_user_id` | — | 2271 | Cast to INT for join |
| `assigner_user_id` | — | 2271 | Cast to INT for join |
| `business_name` | — | 2271 | Display column |
| `business_owner_name` | — | 2271 | Display column |
| `phone` | — | 2271 | Filterable via `[[and phone = {{phone}}]]` |
| `onboard_type` | — | 2271 | Display column |
| `status` | — | 2271 | Display column. No filter — includes Inactive. |
| `estimated_volume` | — | 2271 | Display column |
| `created_at` | — | 2271 | Display column |
| `updated_at` | — | 2271 | Display column |
| `text_status` | — | 2271 | Display column |
| `call_status` | — | 2271 | Display column |
| `is_deleted` | — | 2271 | Display column. No filter — includes deleted. |
| `account_status` | — | 2271 | Display column |
| `assigned_at` | — | 2271 | Display column |
| `product_category_id` | — | 2271 | Display column (disabled) |
| `website` | — | 2271 | Display column (disabled) |
| `competitor_id` | — | 2271 | Display column (disabled) |
| `cnr_status` | — | 2271 | Display column (disabled) |

**Cards using this table:** 2271 only

---

### 10. `business_team_users` (AppSmith Write DB, db5)

| Field | Type | Cards Referencing | Notes |
|---|---|---|---|
| `id` | — | 2271 | Joined as `btu` (assignee) |
| `user_name` | — | 2271 | Displayed as "Crm Member Name" |
| `user_email` | — | 2271 | Disabled column |
| `user_phone` | — | 2271 | Disabled column |
| `team_id` | — | 2271 | Disabled column |
| `supervisor_id` | — | 2271 | Disabled column |
| `created_at` | — | 2271 | Disabled column |
| `updated_at` | — | 2271 | Disabled column |
| `is_active` | — | 2271 | Disabled column |
| `is_admin` | — | 2271 | Disabled column |

**Cards using this table:** 2271 only. Joined twice — once as assignee (`btu`) and once incorrectly as assigner (`btu2`).

> **BUG:** The second join uses `btu.id = CAST(assigner_user_id as INT)` instead of `btu2.id` — the assigner name column (`user_name_2`) will always show the assignee's name (when ids match) or NULL.

---

### 11. `public_users` (db5, referenced in context)

Not directly referenced in any card's SQL. Possibly available as a related table but unused.

---

## Cross-Card Table Usage Matrix

| Card ID | `new_onboards` (db7) | `public_orders` | `public_archived_orders` | `public_merchants` | `business_team_users` | `business_team` | `crm_user_targets` | `business_team_targets` | `new_onboards` (db5) | `business_team_users` (db5) |
|---|---|---|---|---|---|---|---|---|---|---|
| 2013 | ✅ | — | — | — | — | — | — | — | — | — |
| 2028 | — | — | — | — | — | — | — | — | — | — |
| 2029 | ✅ | ✅ | — | ✅ | — | — | — | — | — | — |
| 2031 | ✅ | ✅ | — | ✅ | — | — | — | — | — | — |
| 2033 | ✅ | ✅ | ✅ | — | — | — | — | — | — | — |
| 2050 | ✅ | ✅ | ✅ | ✅ | — | — | — | ✅ | — | — |
| 2158 | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | — | — |
| 2260 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | — |
| 2262 | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | — | — |
| 2030 | ✅ | ✅ | ✅ | — | ✅ | — | — | — | — | — |
| 2060 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | — |
| 2114 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — |
| 2271 | — | — | — | — | — | — | — | — | ✅ | ✅ |
| 2400 | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | — | — |
| 2402 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — |

---

## Field-Level Detail: Card References per Field

### `courier_appsmith.new_onboards` fields → cards

| Field | Cards |
|---|---|
| `business_team_user_id` | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `merchant_id` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `phone` | 2029, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 |
| `is_deleted` | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `status` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `onboard_type` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `estimated_volume` | 2060, 2114, 2400, 2402 |
| `created_at` | 2013, 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `business_name` | 2060, 2400 |
| `account_status` | 2031 |
| `text_status` | 2030 |
| `call_status` | 2030 |
| `id` | 2050, 2030 |

### `courier_realtime_datastream.public_orders` fields → cards

| Field | Cards |
|---|---|
| `merchant_id` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 |
| `created_at` | 2029, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `sorted_at` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2030, 2060, 2114, 2400, 2402 |
| `transfer_status_id` | 2029, 2031, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 |
| `delivery_fee` | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 |
| `additional_charge` | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 |
| `discount` | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 |
| `promo_discount` | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 |
| `cash_on_delivery_fee` | 2029, 2031, 2158, 2260, 2060, 2114, 2400, 2402 |
| `updated_at` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 |
| `country_id` | 2029, 2031, 2033, 2050, 2158, 2260, 2262, 2060, 2114, 2400, 2402 |
| `final_fee` | 2050 |
| `id` | 2060, 2114, 2400, 2402 |
