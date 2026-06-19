# Dashboard 154 — Proposed KB Updates (Awaiting Approval)

> **Status:** DO NOT PROMOTE — requires human review first

## Recommended Canonical Additions

### 1. 03_Business_Logic/crm_onboard_logic.md (NEW)

Content: CRM onboarding window rules, KPI bonus formula, processed orders definition, lead eligibility rules.

Evidence: Extracted from all 15 dashboard cards, cross-verified across cards.

Key knowledge:
- Onboard window logic (Organic: created_at in [15th prev month, next month end); Post Corporate: lifetime; Others: first_order_date in same window)
- Revenue formula: ((delivery_fee+additional_charge)-(discount+promo_discount))/100 + cash_on_delivery_fee/100
- KPI Bonus: Post Corporate=0, Organic=0.005×revenue, others=0.02×revenue
- Lead eligibility: business_team_user_id<>'1', is_deleted IS NOT TRUE, status<>'Inactive'

### 2. 03_Business_Logic/crm_merchant_attribution.md (NEW)

Content: CRM merchant-to-lead matching logic with merchant_id primary + phone fallback.

Evidence: Used in 10 of 15 cards with consistent pattern.

### 3. 06-SYSTEM/semantic-layer/tables/new_onboards.md (NEW or UPDATE)

Content: Full field map for courier_appsmith.new_onboards table including:
- business_team_user_id (STRING, requires CAST to INT64 for joins)
- merchant_id, phone (attribution keys)
- is_deleted, status, onboard_type (filtering fields)
- estimated_volume, created_at, business_name, account_status

### 4. 06-SYSTEM/semantic-layer/tables/crm_user_targets.md (NEW)

Content: hermes_bz_comms.crm_user_targets schema: target fields, month filtering, join to business_team_users.

### 5. 06-SYSTEM/semantic-layer/tables/business_team_targets.md (UPDATE)

Content: Add forecast card usage: team-level targets joined by team_name and month.

### 6. 06-SYSTEM/query-standards.md (UPDATE — add section)

Content: Document the `is_deleted IS NOT TRUE` standard (not `<> TRUE`) for better NULL handling. Document that `{{snippet: processed_orders}}` is the canonical processed definition.

### 7. Update crm-manager-dashboard-analytics skill

Content: Link to all staging documents. Add card IDs, SQL summaries, filter maps. Add known discrepancies and Oracle questions.

## Items NOT to Promote (Staging Only)

- dashboard-154-card-queries.json — raw extraction, useful for reference
- dashboard-154-inventory.md — staging document
- dashboard-154-filter-map.md — staging document
- dashboard-154-table-field-map.md — staging document
- dashboard-154-business-logic.md — staging document
- dashboard-154-open-questions.md — staging, pending Oracle answers
- dashboard-154-validation-report.md — staging

## Promotion Workflow

1. Human reviews feedback inbox entries for Dashboard 154
2. Human answers Oracle questions (12 total)
3. Staging documents updated with Oracle answers
4. Human explicitly approves items for promotion
5. Approved items moved to 03_Business_Logic/ or 06-SYSTEM/
6. _INDEX_START_HERE.md and 00_WORKING_STATE.md updated
7. crm-manager-dashboard-analytics skill updated with links

Do NOT auto-promote. This awaits explicit human approval.
