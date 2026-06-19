# CRM Onboard Logic

> **Source:** Dashboard 154 — CRM Managers Dashboard (15 cards)
> **Promoted:** 2026-06-19
> **Confidence:** High (cross-verified across all dashboard cards)

## Lead Eligibility Rules

Standard filters applied to `courier_appsmith.new_onboards`:

| Rule | Filter | Used By |
|---|---|---|
| Exclude system user | `business_team_user_id <> '1'` | 14 of 15 cards |
| Exclude deleted leads | `is_deleted IS NOT TRUE` | Standard (7 cards use `<> TRUE` which misses NULLs — see discrepancy) |
| Exclude inactive leads | `status <> 'Inactive'` | Most cards |
| Active leads only (rejected counter) | `status = 'Inactive'` | Card 2158 only |

## Onboard Type Window Logic

The dashboard uses three different inclusion windows based on `onboard_type`:

### 1. Post Corporate — Lifetime Inclusion

```
n.onboard_type = 'Post Corporate'
```

No date window. All Post Corporate leads ever created are included.

### 2. Organic — KPI Window

```
n.onboard_type = 'Organic'
AND DATE(n.created_at) >= DATE_ADD(
    DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH),
    INTERVAL 15 DAY)
AND DATE(n.created_at) < DATE_TRUNC(
    DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
```

Window: [15th of previous month, 1st of next month)

Example (June 2026): Organic leads created from May 15 through July 1 (exclusive) are included.

### 3. Others (Hunt, Churn, etc.) — First Order Window

```
n.onboard_type NOT IN ('Organic', 'Post Corporate')
AND f.first_order_date_after_lead_creation >= DATE_ADD(
    DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH),
    INTERVAL 15 DAY)
AND f.first_order_date_after_lead_creation < DATE_TRUNC(
    DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
```

Same window as Organic, but applied to `first_order_date_after_lead_creation` instead of `created_at`.

## Revenue Formula

```
((COALESCE(delivery_fee, 0) + COALESCE(additional_charge, 0))
 - (COALESCE(discount, 0) + COALESCE(promo_discount, 0)))
 / 100
 + COALESCE(cash_on_delivery_fee, 0) / 100
```

Applied only to processed orders (`transfer_status_id IN ({{snippet: processed_orders}})`).

Variants:
- Cards 2114, 2402 use `SAFE_DIVIDE()` instead of `/ 100`
- Card 2050 uses `final_fee / 100.0` (pre-computed column)

All variants produce equivalent results with COALESCE guards active.

## KPI Bonus Formula

| Onboard Type | Multiplier | Formula |
|---|---|---|
| Post Corporate | 0.00 | `0` |
| Organic | 0.005 | `0.005 * expected_revenue` |
| Others (Hunt, Churn, etc.) | 0.02 | `0.02 * expected_revenue` |

Computed per merchant in cards 2060, 2114, 2260, 2400, 2402.

## Processed Orders Definition

Two approaches exist in dashboard cards:

### Snippet-based (preferred)
```
transfer_status_id IN ({{snippet: processed_orders}})
```
Used by 7 cards: 2029, 2031, 2050, 2060, 2114, 2260, 2262.

### Hardcoded (legacy)
- **Card 2158**: 22 status IDs (8-14, 22-26, 28, 30-33, 36-42)
- **Cards 2400, 2402**: 40 status IDs (5-44, excluding 15 only)

⚠️ The hardcoded lists may diverge from the server snippet. See discrepancy in open-questions.

## First Order After Lead Creation

```sql
MIN(DATE(o.created_at)) AS first_order_date_after_lead_creation
FROM merchants m
LEFT JOIN orders o
    ON m.id = o.merchant_id
    AND DATE(o.created_at) >= m.leads_created_at
GROUP BY m.id
```

Used for non-Organic, non-Post-Corporate onboard types to determine KPI window eligibility.

## Forecast Logic

```
days_passed = EXTRACT(DAY FROM CURRENT_DATE()) - 1
total_days_in_month = last day of month
daily_average = MTD_processed / days_passed
forecast = daily_average * total_days_in_month
```

MTD excludes today's partial data (all forecast cards filter `sorted_at < CURRENT_DATE()`).

⚠️ Card 2402 (Historical Leaderboard) computes `days_in_period = total_days_in_period`, making forecast = actual (redundant). See discrepancy.

## Target Logic

Two target tables used:
- `hermes_bz_comms.crm_user_targets` — per-acquisition-member targets (cards 2114, 2402)
- `hermes_bz_comms.business_team_targets` — team-level targets (card 2050)

Target achievement formulas:
```
Order_Goal = Processed / order_target
revenue_goal = Expected_Revenue / revenue_target
order_remaining = order_target - Processed
revenue_remaining = revenue_target - Expected_Revenue
```

## Hub Payment Status (reused in CRM context)

CDS mapping for `public_order_invoices.hub_payment_status` (field 26576):
- `0` = Not submitted
- `1` = Submitted
- `2` = Accounts approved

## Known Discrepancies

1. `is_deleted <> TRUE` misses NULLs in 7 cards (2013, 2029, 2031, 2033, 2158, 2030)
2. 3 cards hardcode transfer status lists that may diverge from server snippet
3. Card 2271 has a join bug: `btu.id` used instead of `btu2.id` for assigner name
4. Card 2031 hardcodes `updated_at >= "2026-01-01"` which will stale
5. 7 Overview cards ignore all dashboard filter selections
6. Card 2402 forecast = actual (identity)
