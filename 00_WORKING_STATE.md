# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Feedback promotion / global SQL query standards

## Current Topic

Global Pathao SQL/reporting timezone defaults.

## Last Completed

- 2026-06-27: Promoted two user-approved CDS task-management feedback entries and interlinked the canonical CDS docs.
- 2026-06-28: Promoted the Pathao SQL timezone correction into `06-SYSTEM/query-standards.md` after explicit user instruction.
- Strengthened the timezone rule so it applies globally for everyone: use UTC/default database time by default; use BD/Bangladesh/Asia-Dhaka only when explicitly requested in the current ask.
- Marked the related feedback inbox entry as promoted.

## Files Updated Last

- `06-SYSTEM/query-standards.md` — strengthened the Timezones section: no timezone inference from WhatsApp, user profile, location, or machine timezone; phrases like `today` and `so far` use UTC/default DB day unless BD is explicitly requested.
- `07-FEEDBACK-INBOX/2026-06-28.md` — marked `00:17 - Pathao data query default timezone correction` as promoted with destination and promotion date.
- `00_WORKING_STATE.md` — updated this state.

## Pending Open Questions

- [ ] None for this promotion step.

## Next Action For Agent

1. For any Pathao SQL/reporting query, read `06-SYSTEM/query-standards.md` before applying date/time filters.
2. Use UTC/default database time by default for all users and channels.
3. Only use Asia/Dhaka / Bangladesh / BD time if explicitly requested in the current ask.
4. Do not infer query timezone from WhatsApp, user profile, user location, or local machine timezone.

## Next Question Batch

- None.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
- When promoting feedback, interconnect related Markdown docs so canonical logic is discoverable from business logic, data dictionary, SQL patterns, index, and relevant README files.
