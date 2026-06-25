# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Metabase Deep Dive — Dashboard 154 CRM Managers Dashboard (promoted)

## Current Topic

Processed vs open order volume definitions for merchant reporting (`on_process` vs `is_processed`), plus monthly merchant volume exclusion of cancelled orders.

## Last Completed

- Promoted two user-approved feedback items into canonical business logic:
  - merchant monthly volume should exclude merchant-cancelled orders after creation
  - successful / processed merchant volume should use `hermes_bz_comms.courier_transfer_status.is_processed = 1`, not `on_process`
- Updated `03_Business_Logic/open_orders_business_logic.md` with a new Processed / Successful Orders section.
- Updated `_INDEX_START_HERE.md` to reflect the new canonical rule.
- Appended the corresponding feedback records in `07-FEEDBACK-INBOX/2026-06-25.md`.

## Files Updated Last

- `03_Business_Logic/open_orders_business_logic.md` — added Processed / Successful Orders logic using `is_processed = 1`.
- `_INDEX_START_HERE.md` — updated open-orders note to mention `is_processed` for successful volume.
- `07-FEEDBACK-INBOX/2026-06-25.md` — appended the two approved feedback entries.
- `00_WORKING_STATE.md` — updated this state.

## Pending Open Questions

- [ ] None for this promotion step.

## Next Action For Agent

1. Continue with the current user task using the updated merchant-volume logic.
2. When monthly merchant ranking is needed, use `is_processed = 1` and exclude merchant-cancelled orders.
3. Keep documenting any new reusable merchant/reporting rules in the KB.

## Next Question Batch

- None. The user asked to promote these two feedback items, and that has been completed.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
