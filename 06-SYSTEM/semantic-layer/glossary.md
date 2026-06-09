# Glossary of Business Terms

- **Open Orders**: Orders currently in-process. Maps to status `on_process` in database.
- **Sorting**:
  - **Data Context (SQL)**: Any order that has transitioned through `transfer_status_id = 9` (sorting status).
  - **Operations Context**: A physical scan/label print at `pickup_hub_id`.
- **Hermes**: In the Pathao Courier context, "Hermes" refers to the internal OMS/panel database, NOT the AI agent.
- **Completed Delivery**: Successful final delivery of the parcel, excluding partial completions. Filter: `status = 'delivered'` and `is_full_delivery = true`.
