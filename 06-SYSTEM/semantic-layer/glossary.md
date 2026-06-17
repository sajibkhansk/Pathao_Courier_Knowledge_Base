# Glossary of Business Terms

- **Open Orders**: Orders currently in-process. Maps to status `on_process` in database.
- **Sorting**:
  - **Data Context (SQL)**: Any order that has transitioned through `transfer_status_id = 9` (sorting status).
  - **Operations Context**: A physical scan/label print at `pickup_hub_id`.
- **Hermes**: In the Pathao Courier context, "Hermes" refers to the internal OMS/panel database, NOT the AI agent.
- **Completed Delivery**: Successful final delivery of the parcel, excluding partial completions. Filter: `status = 'delivered'` and `is_full_delivery = true`.

## Business Team Segments

- **MTM**: Merchant segment identified through `courier_realtime_datastream.public_ties_merchant` where `ties_id = 67`.
- **KAM**: Merchant segment identified through `courier_realtime_datastream.public_ties_merchant` where `ties_id = 68`.
- **Retail / Point / Booking Point**: Same business segment for Dashboard 31 purposes. SQL uses `order_type_id IN (16, 18)` and target table uses `team_name = 'Retail'`.
- **Processed Orders**: In Dashboard 31 business-team performance context, processed orders count eligible transfer statuses and usually filter by `DATE(sorted_at)` for MTM/KAM/Total. Retail/Point/Booking Point cards may use `DATE(created_at)`.
- **Revenue**: Dashboard 31 expected revenue formula sums delivery revenue plus COD fee for eligible processed statuses: `((delivery_fee + additional_charge) - (discount + promo_discount) + cash_on_delivery_fee) / 100`.
- **First Trip Merchant**: Merchant whose first sorted order date is within the acquisition window used by Dashboard 31. Flow chart uses first order date after the 15th day of the previous month; current-month first-trip metrics isolate merchants whose first order date is in the current month.
- **Churnback Merchant**: Merchant who had orders before the cutoff date, had no orders in the gap period from cutoff to month start, and has orders in the current month. Dashboard 31 cutoff is 45 days before current month start.
- **Channel Wise Distribution**: Dashboard 31 category priority: Pathao C2C merchant override (`merchant_id = 80297`), CRM/Post Corporate onboarding, KAM/MTM ties, Retail/Point/Booking Point (`order_type_id IN (18,16)`), Kiosk (`merchant_type = 1`), then Unguided.

## Related Notes

- [[06-SYSTEM/semantic-layer/tables/public_orders.md|public_orders]]
- [[06-SYSTEM/semantic-layer/tables/public_merchants.md|public_merchants]]
- [[06-SYSTEM/semantic-layer/tables/public_ties_merchant.md|public_ties_merchant]]
- [[06-SYSTEM/semantic-layer/tables/business_team_targets.md|business_team_targets]]
- [[06-SYSTEM/semantic-layer/metrics/delivery_rate.md|Delivery Rate]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_revenue.md|MTD Revenue]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_mtd_processed_orders.md|MTD Processed Orders]]
- [[06-SYSTEM/semantic-layer/metrics/business_team_forecasting.md|Business Team Forecasting]]
- [[03_Business_Logic/cds_key_descriptions.md|CDS Key Descriptions]]
- [[03_Business_Logic/merchant_logic_human_oracle.md|Merchant Logic Human Oracle]]
- [[06-SYSTEM/semantic-layer/relationships.md|Table Relationships]]
- [[04_SQL_Patterns/phase2_initial_table_patterns.md|Initial Table Patterns]]
- [[06-SYSTEM/query-standards.md|SQL Query Standards]]
