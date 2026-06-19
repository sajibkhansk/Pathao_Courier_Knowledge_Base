# crm_user_targets (hermes_bz_comms)

> **Database:** BigQuery db7 (hermes_bz_comms)
> **Source:** Dashboard 154 — CRM Managers Dashboard, cards 2114, 2402
> **Promoted:** 2026-06-19

## Purpose

Per-acquisition-member monthly order and revenue targets used in Leaderboard cards.

## Usage

Joined via `btu.user_name = crm_user_targets.user_name` after resolving the CRM user from `new_onboards.business_team_user_id`.

## Fields (observed from card SQL)

| Field | Type | Description |
|---|---|---|
| `user_name` | Text | Maps to business_team_users.user_name |
| `order_target` | Numeric | Monthly processed order target |
| `revenue_target` | Numeric | Monthly revenue target |
| `month` | Date/Text | Target month |

## Target Achievement Formulas

```
Order_Goal = Processed / order_target
revenue_goal = Expected_Revenue / revenue_target
order_remaining = order_target - Processed
revenue_remaining = revenue_target - Expected_Revenue
```

## Related Table: business_team_targets

Same schema at team level — used in card 2050 (Forecast Orders) for run_rate calculation:

```
run_rate = forecast / business_team_targets.target
```
