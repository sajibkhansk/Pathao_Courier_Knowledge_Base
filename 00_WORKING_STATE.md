# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Feedback promotion / CDS task-management logic

## Current Topic

CDS task-management platform meaning and dashboard-aligned unassigned task-count logic.

## Last Completed

- 2026-06-27: Promoted two user-approved feedback entries from `07-FEEDBACK-INBOX/2026-06-27.md`:
  - `04:06 - CDS means task-management platform`
  - `12:26 - CDS dashboard-aligned unassigned count`
- Created canonical CDS task-management logic note.
- Updated index to include the new canonical note.
- Marked the two feedback records as `promoted` with destination and promotion date.

## Files Updated Last

- `03_Business_Logic/cds_task_management_logic.md` — created canonical CDS task-management platform and unassigned-count logic.
- `_INDEX_START_HERE.md` — added the CDS task-management canonical note to the 03_Business_Logic map.
- `07-FEEDBACK-INBOX/2026-06-27.md` — marked the two requested entries as promoted.
- `00_WORKING_STATE.md` — updated this state.

## Pending Open Questions

- [ ] None for this promotion step.

## Next Action For Agent

1. Use `03_Business_Logic/cds_task_management_logic.md` for CDS task-management reporting.
2. For dashboard-aligned CDS Unassigned, use `assigned_data_team_user IS NULL AND status IN ('To Do', 'In Progress', 'Blocker')`.
3. Keep raw null-assignment counts separate from dashboard-aligned unassigned counts.

## Next Question Batch

- None.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
