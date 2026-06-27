# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process.

## Current Phase

Phase 3: Feedback promotion / CDS task-management logic

## Current Topic

CDS task-management platform meaning, dashboard-aligned unassigned task-count logic, and interlinked KB documentation.

## Last Completed

- 2026-06-27: Promoted two user-approved feedback entries from `07-FEEDBACK-INBOX/2026-06-27.md`:
  - `04:06 - CDS means task-management platform`
  - `12:26 - CDS dashboard-aligned unassigned count`
- Created canonical CDS task-management logic note.
- Added interconnected docs so the promoted logic is discoverable from related KB areas:
  - table note for `public.requests`
  - SQL pattern note for CDS Summary/reporting queries
  - cross-links from CDS SQL snippet/key-description notes to the task-management note
  - README and index links across 02_Data_Dictionary, 03_Business_Logic, and 04_SQL_Patterns
- Marked the two feedback records as `promoted` with destination and promotion date.

## Files Updated Last

- `03_Business_Logic/cds_task_management_logic.md` — canonical CDS task-management platform and unassigned-count logic; related links expanded.
- `02_Data_Dictionary/cds_public_requests.md` — created table note for direct CDS `public.requests`.
- `04_SQL_Patterns/cds_task_management_reporting_patterns.md` — created reusable CDS reporting SQL patterns.
- `03_Business_Logic/cds_key_descriptions.md` — added terminology distinction and links to CDS task-management docs.
- `04_SQL_Patterns/cds_cte_patterns.md` — added terminology distinction and links to CDS task-management docs.
- `02_Data_Dictionary/README.md` — added link to `cds_public_requests`.
- `03_Business_Logic/README.md` — added link to `cds_task_management_logic`.
- `04_SQL_Patterns/README.md` — added link to `cds_task_management_reporting_patterns`.
- `_INDEX_START_HERE.md` — added new interlinked CDS task-management docs.
- `07-FEEDBACK-INBOX/2026-06-27.md` — marked the two requested entries as promoted.
- `00_WORKING_STATE.md` — updated this state.

## Pending Open Questions

- [ ] None for this promotion/linking step.

## Next Action For Agent

1. Use `03_Business_Logic/cds_task_management_logic.md` for CDS task-management reporting.
2. Use `02_Data_Dictionary/cds_public_requests.md` for table/field meanings.
3. Use `04_SQL_Patterns/cds_task_management_reporting_patterns.md` for reusable CDS Summary SQL patterns.
4. For dashboard-aligned CDS Unassigned, use `assigned_data_team_user IS NULL AND status IN ('To Do', 'In Progress', 'Blocker')`.
5. Keep raw null-assignment counts separate from dashboard-aligned unassigned counts.

## Next Question Batch

- None.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions.
- Check CDS key descriptions before asking about enum mappings.
- Inspect Metabase/table metadata before asking about table/column ambiguity when tool access exists.
- Store business facts in Markdown, not only in chat memory.
- When promoting feedback, interconnect related Markdown docs so canonical logic is discoverable from business logic, data dictionary, SQL patterns, index, and relevant README files.
