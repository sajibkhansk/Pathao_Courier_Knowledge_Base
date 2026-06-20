# CRM KAM Feedback Analysis

> Canonical rules for analyzing KAM feedback data from the Monthly Merchant Feedback dashboard.

## Primary Analytical Field

**`detailed_response` (field 41515 in `monthly_kam_followups`) is the primary analytical layer.**

The categorical FK fields serve as structured indexing/filtering on top of the free-text narratives, not as the primary analysis:

- `dissatisfaction_reason_id` → `static_values_kam_followups` WHERE `key_type='dissatisfaction_reason'`
- `impact_or_order_degrowth_reason_id` → `static_values_kam_followups` WHERE `key_type='impact'`
- `moved_to_competitor_courier_id` → `static_values_kam_followups` WHERE `key_type='other_courier'`

**Always treat `detailed_response` as the primary insight source.** The categorical fields are supplementary.

## Dashboard Identity

| User Name | Actual Name | ID | Collection |
|---|---|---|---|
| Monthly KAM Feedback | Monthly Merchant Feedback | 191 | Kam Followup (490) |

When searching, try "Monthly Merchant Feedback" first.

## Data Quality: dissatisfaction_reason_id = 40

- 63% of records (~12,997 of 20,637) have `dissatisfaction_reason_id = 40`
- ID 40 does NOT exist in `static_values_kam_followups` for `key_type='dissatisfaction_reason'` (values start at 80)
- Treat ID 40 as "Not Specified / Not Dissatisfied" sentinel
- Only ~37% of records have resolvable dissatisfaction reasons
- Always note this blind spot in dissatisfaction analysis

## Source

Promoted from `07-FEEDBACK-INBOX/2026-06-20.md` entries #1 and #3.
