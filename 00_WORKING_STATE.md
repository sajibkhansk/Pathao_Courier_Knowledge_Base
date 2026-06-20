# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Metabase Deep Dive — Dashboard 154 CRM Managers Dashboard (promoted)

## Current Topic

CRM onboarding logic, merchant attribution, KPI bonus formula, processed orders definition, and team hierarchy documented from 15 dashboard cards. 12 discrepancies found, 12 Oracle questions pending.

## Last Completed

- Documented Human Oracle answers for Price Change / COD Reduction:
  - Price Change means collectable amount is changed; after change, `collectable_amount = collected_amount`.
  - Canonical price-change detection must check OSC logs, not final `public_orders.collectable_amount <> collected_amount`.
  - `merchant_otp = delivery_method` means merchant-provided OTP was used to change price.
  - Observed thresholds (`>10%`, `>=80%`, `collusion_orders >= 3`) are changeable flagging numbers, not permanent business definitions.
  - Exchange orders (`transfer_status_id = 42`) are part of price-change detection, but fraud-case detection may only use delivered orders (`transfer_status_id = 13`).
- Created dedicated business-logic file for Price Change.
- Added OSC cross-reference because canonical detection depends on `public_order_status_changes`.
- Updated index to include the new Price Change file.

## Files Updated Last

- `03_Business_Logic/crm-kam-feedback-analysis.md` — NEW: KAM feedback analysis rules, dashboard naming, data quality warning (63% dissatisfaction_reason_id = 40).
- `SOUL.md` — Added WhatsApp formatting mandatory workflow step in Communication Style.
- `_INDEX_START_HERE.md` — Added crm-kam-feedback-analysis.md.
- `07-FEEDBACK-INBOX/2026-06-20.md` — Entries 1, 2, 3 marked promoted.
- `00_WORKING_STATE.md` — Updated this state.

## Related Notes

- [[03_Business_Logic/price_change_logic.md|Price Change Logic]] — current active topic
- [[03_Business_Logic/order_status_changes_human_oracle.md|OSC Human Oracle]] — canonical OSC business rules
- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]] — source table for order-level metrics
- [[06-SYSTEM/semantic-layer/metrics/delivery_rate.md|Delivery Rate Metric]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[04_SQL_Patterns/phase2_initial_table_patterns.md|Initial Table Patterns]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]

## Pending Open Questions

- [ ] Which OSC event identifies collectable amount change: specific `type`, `status_id`, `desc`, or payload key?
- [ ] In OSC `payload`, what are the exact JSON paths for old/new collectable amount?
- [ ] Is `delivery_method` always the OTP value used for the price change, or can it also represent normal delivery OTP outside price-change cases?
- [ ] For fraud-specific detection, should the canonical status filter be `transfer_status_id = 13` only, with exchange excluded unless explicitly requested?

## Next Action For Agent

1. Ask the staged 4-question Human Oracle batch below.
2. After the user answers, update:
   - `03_Business_Logic/price_change_logic.md`
   - `03_Business_Logic/order_status_changes_human_oracle.md` if OSC payload/type details are provided
   - `00_WORKING_STATE.md`
3. Update `_INDEX_START_HERE.md` only if new files/sections are materially added.

## Next Question Batch

1. In OSC, what exactly identifies a price/collectable amount change: a specific `type`, `status_id`, `desc`, or only payload old/new fields?
2. What are the exact OSC payload paths for previous and changed collectable amount? For example, are they `$.old.collectable_amount` and `$.new.collectable_amount`, or different keys?
3. Is `delivery_method` generally the OTP value used for any delivery action, or specifically the OTP used for price change when it equals `merchant_otp`?
4. For fraud-specific price-change reports, should the standard filter be delivered only (`transfer_status_id = 13`), while operational price-change reporting includes exchange (`13, 42`)?

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
