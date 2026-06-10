# KB Working State

## Purpose

Persistent state file for the Pathao Courier HITL Markdown knowledge-base process. Future sessions must read this file and `_INDEX_START_HERE.md` before asking questions or continuing the KB.

## Current Phase

Phase 3: Metabase Deep Dive — IR Queries

## Current Topic

Issue Resolution / IR queries from the Kobiraj database schema.

## Last Completed

- Phase 1 and Phase 2 fully documented for all core operational tables.
- Phase 3 started with IR Queries folder.

## Files Updated Last

- `00_WORKING_STATE.md` — updated current phase and topic.

## Pending Action

Waiting for user to paste SQL from IR Queries Metabase cards, one folder at a time.

## Phase 3 Protocol

1. User pastes SQL from one card at a time.
2. I identify magic numbers, filters, timeframe logic.
3. I ask Human Oracle what specific conditions mean.
4. I document reusable rules in `03_Business_Logic/metabase_ir_patterns.md` and `04_SQL_Patterns/metabase_ir_snippets.md`.
5. We move to the next card/folder.

## Kobiraj DB Tables

Notable tables from the `courier_kobiraj_realtime_dstream` and `hermes_kobiraj_realtime_dstream` schemas observed during scanning:
- `public_issues`
- `public_teams`
- `public_responsible_ends`
- `public_issue_acticity_logs`
- `public_issue_categories`
- `public_issue_types`
- `public_issue_statuses`
- `public_waiting_reasons`
- `public_issues_issue_type`
- `public_teams_categories`
- `public_checklists`
- `public_checklist_items`

I can search/inspect these in Metabase if needed for column context.

## Guardrails

- Never guess ambiguous IDs/statuses/types/JSON keys.
- Ask maximum 3–4 related questions per prompt.
- Check CDS key descriptions before asking about enum mappings.
- Always update this file before ending any KB continuation turn.
