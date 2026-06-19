# new_onboards (courier_appsmith)

> **Database:** BigQuery db7 (courier_appsmith) / Postgres db5 (AppSmith-Write-DB)
> **Metabase table IDs:** db7 = 15044, db5 = 13937
> **Source:** Dashboard 154 — CRM Managers Dashboard
> **Promoted:** 2026-06-19

## Purpose

Primary CRM lead/onboarding table. Every row represents a merchant lead onboarded by the CRM acquisition team.

## Field Map

| Field | Type | Description | Notes |
|---|---|---|---|
| `id` | Integer (PK) | Lead identifier | Used to join to crm_activity_logs via CAST as text |
| `business_team_user_id` | STRING/varchar | FK to business_team_users.id | ⚠️ Stored as text — MUST CAST to INT64/INTEGER for joins |
| `merchant_id` | Integer | FK to public_merchants.id | Can be NULL (phone fallback needed) |
| `phone` | Text | Merchant phone number | Fallback when merchant_id IS NULL |
| `business_name` | Text | Business/merchant name | Used in card 2060 output |
| `onboard_type` | Text | Lead type | Values: 'Organic', 'Post Corporate', 'Hunt', 'Churn', etc. |
| `account_status` | Text | CRM account status | Used in Merchant Distribution classification |
| `status` | Text | Lead lifecycle status | 'Active' / 'Inactive' |
| `is_deleted` | Boolean | Soft delete flag | ⚠️ Use `IS NOT TRUE` not `<> TRUE` |
| `estimated_volume` | Integer | KAM-reported expected daily volume | Used in Leaderboard cards |
| `created_at` | DateTime | Lead creation timestamp | Used for KPI window eligibility |

## Standard Filters

```sql
WHERE business_team_user_id <> '1'    -- exclude system user
  AND is_deleted IS NOT TRUE          -- exclude soft-deleted
  AND status <> 'Inactive'            -- exclude rejected/inactive
```

## Team Resolution Chain

```
new_onboards.business_team_user_id
  → CAST AS INT64
  → business_team_users.id
  → business_team_users.team_id
  → business_team.id
  → business_team.team_name
```

Team values: 'Acquisition', 'KAM', 'Post Corporate', 'Pre Corporate'.

## Known Discrepancies

- 7 dashboard cards use `is_deleted <> TRUE` which misses NULLs
- Card 2271 (Admin Checker) does not apply any of the three standard filters
