# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Feedback promotion / global SQL query standards

## Current Topic

Global Pathao SQL/reporting defaults for timezone and country filters.

## Last Completed

- 2026-06-27: Promoted two user-approved CDS task-management feedback entries and interlinked the canonical CDS docs.
- 2026-06-28: Promoted the Pathao SQL timezone correction into `06-SYSTEM/query-standards.md` after explicit user instruction.
- 2026-06-28: Promoted the default country filter correction into query standards and order table notes after explicit user instruction.
- Strengthened default query rules:
  - use UTC/default database time by default; use BD/Bangladesh/Asia-Dhaka only when explicitly requested in the current ask.
  - include `country_id = 1` in all Pathao Courier query results and returned SQL by default unless all-country/global or another country scope is explicitly requested.
- Marked the related feedback inbox entries as promoted.

## Files Updated Last

- `06-SYSTEM/query-standards.md` — added Important standard filter: default Pathao Courier business filter is `country_id = 1 AND merchant_id <> 1`; omit `country_id = 1` only for explicit all-country/global or non-BD scope.
- `06-SYSTEM/semantic-layer/tables/public_orders.md` — added Important default country filter and standard business filter in Gotchas & Data Traps.
- `06-SYSTEM/semantic-layer/tables/public_archived_orders.md` — added Important default country filter and standard business filter for archived-order reporting.
- `07-FEEDBACK-INBOX/2026-06-28.md` — marked default-country-filter correction as promoted with destinations and promotion date.
- `00_WORKING_STATE.md` — updated this state.

## Pending Open Questions

- [ ] None for this promotion step.

## Next Action For Agent

1. For any Pathao SQL/reporting query, read `06-SYSTEM/query-standards.md` before applying date/time or business filters.
2. Use UTC/default database time by default for all users and channels.
3. Only use Asia/Dhaka / Bangladesh / BD time if explicitly requested in the current ask.
4. Include `country_id = 1` in all Pathao Courier query results and returned SQL by default.
5. Pair `country_id = 1` with `merchant_id <> 1` for standard courier order counts.
6. Omit `country_id = 1` only when the user explicitly asks for all-country/global data or another country scope.

## Next Question Batch

- None.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
- When promoting feedback, interconnect related Markdown docs so canonical logic is discoverable from business logic, data dictionary, SQL patterns, index, and relevant README files.
