# Table Relationships & Joins

- `public_orders` joins `public_merchants` on `merchant_id`.
- `public_orders` joins `public_transfers` on `order_id` (or appropriate transfer status field).
