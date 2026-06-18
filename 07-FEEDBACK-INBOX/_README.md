# 07-FEEDBACK-INBOX — Feedback Inbox

**Purpose:** Temporary staging area for unreviewed knowledge observations discovered during agent sessions. Humans review and promote approved items to canonical knowledge.

**Structure:** One file per day: `YYYY-MM-DD.md`. Append-only, never modify existing entries.

## Allowed Statuses

| Status | Meaning |
|--------|---------|
| `pending` | New observation, not yet reviewed |
| `under-review` | Human is evaluating this item |
| `approved` | Confirmed as accurate, pending promotion |
| `rejected` | Determined to be incorrect or not reusable |
| `promoted` | Moved to canonical KB (`03_Business_Logic/` or `06-SYSTEM/semantic-layer/`) |

## Routing Rules

- **Hermes Agent** may create entries with status `pending`. Never mark anything `approved` or `promoted` without explicit human authorization.
- **Humans** review, update statuses, and promote to canonical knowledge.
- When promoted, the human adds a reference link to the canonical destination file.

## Entry Format

```markdown
## HH:MM — Short descriptive title

- Status: pending
- Source: user correction | Human Oracle | Metabase observation | agent observation
- Context: What task produced this learning
- Feedback: Exact correction or learning
- Proposed rule: Possible reusable rule
- Scope: Where the rule may apply
- Evidence: Why it was recorded
- Candidate destination: Suggested canonical file
- Session reference: Platform/session identifier when available
```

## What to Store

| Store | Don't Store |
|-------|-------------|
| Business-rule corrections | Query results |
| Enum/status meanings | Merchant/customer/consignment lists |
| Reusable default filters | Temporary dates |
| Table/field/join corrections | One-time filters |
| SQL methodology corrections | Tool logs |
| Stable user preferences | Generated reports |
| Human Oracle knowledge | Conversation summaries |
| Corrections to existing docs | Unverified guesses |
| | Row-level data |

## Current Status

- 2026-06-18: Inbox created, initial reorganization entries seeded.
