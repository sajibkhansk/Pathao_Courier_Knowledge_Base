# LMH > 48h and Unassigned Count by ISD Hub

Date: 2026-06-25

Assumption used:
- "hasn't been assigned once" was interpreted as `current_agent_id IS NULL`.
- Filter used: `lmh_at` older than 48 hours, `country_id = 1`, and `updated_at >= 2025-01-01` for partition elimination.

Top hubs:
- Pathao Central LTL: 24
- Mohammadpur: 21
- Uttara: 17
- Lost & Damaged: 6
- Banani / Pallabi / Mirpur-1: 5 each

CSV: /home/ubuntu/Hermes_Knowledge_Base/05-HERMES-OUTPUTS/analyses/2026-06-25-lmh48-unassigned-isd-hubs/hub_wise_lmh_over_48_unassigned_once.csv

Exact MBQL-native query shape used:
1. Source: `public_orders`
2. Filters:
   - `country_id = 1`
   - `updated_at >= 2025-01-01`
   - `lmh_at IS NOT NULL`
   - `lmh_at < now() - 48h`
   - `current_agent_id IS NULL`
3. Breakout: `current_hub_id`
4. Aggregate: `count(*)`

Then ISD hubs were mapped by `public_hubs.hub_operation_type = 1`.
