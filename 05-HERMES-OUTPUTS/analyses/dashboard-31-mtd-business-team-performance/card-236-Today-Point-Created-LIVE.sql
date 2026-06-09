SELECT COUNT(consignment_id)
FROM orders
WHERE  created_at >= CURRENT_DATE 
  AND created_at < CURRENT_DATE + INTERVAL '1 day'
  AND order_type_id IN (18,16)
